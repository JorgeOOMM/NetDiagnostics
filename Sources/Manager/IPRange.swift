//
//  IPRange.swift
//  NetDiagnostics
//
//  Created by Mac on 7/12/25.
//

// https://medium.com/@aclaytonscott/exploding-ipv4-ranges-using-swift-b7fba6c9ce28

protocol IPRangeProtocol {
    func IPToInt(ip: String) -> Int
    func intToIP(int: Int) -> String
    func range(lower: String, upper: String) -> [String]
}

struct IPRange: IPRangeProtocol {
    
    func range(lower: String, upper: String) -> [String] {
        precondition(!(lower.isEmpty || upper.isEmpty))
        precondition(IPToInt(ip: lower) < IPToInt(ip: upper))
        var ips: [String] = []
        for index in stride(from:IPToInt(ip: lower), through: IPToInt(ip:upper), by: 1) {
            ips.append(intToIP(int: index))
        }
        return ips
    }
    

    func IPToInt(ip: String) -> Int {
        let octets: [Int] = ip.split(separator: ".").map({Int($0)!})
        var numValue: Int = 0
        for index in stride(from:3, through:0, by:-1) {
            numValue += octets[3-index] << (index * 8)
        }
        return numValue
    }
    
    func intToIP(int: Int) -> String {
        return String((int >> 24) & 0xFF) + "." + String((int >> 16) & 0xFF) + "." + String((int >> 8) & 0xFF) + "." + String(int & 0xFF)
    }
}



class IPRangeIterator: IteratorProtocol, Sequence {
    var range = [String]()
    var index = 0
    var count: Int {
        return self.range.count
    }
    init(lower: String, upper: String, ranger: IPRangeProtocol = IPRange()) {
        self.range = ranger.range(lower: lower, upper: upper)
    }

    func next() -> String? {
        guard index < count else {
            return nil
        }
        index += 1
        return range[index - 1]
    }
}


//func IPToInt(ip: String) -> Int {
//    let octets: [Int] = ip.split(separator: ".").map({Int($0)!})
//    var numValue: Int = 0
//    for (i, n) in octets.enumerated() {
//        let p: Int = NSDecimalNumber(decimal: pow(256, (3-i))).intValue
//        numValue += n * p
//    }
//    return numValue
//}
//
//IPToInt(ip: "127.0.0.1") // 2130706433
//IPToInt(ip: "0.0.1.1") // 257
//IPToInt(ip: "0.0.0.1") // 1

//func IPToInt(ip: String) -> Int {
//    let octets: [Int] = ip.split(separator: ".").map({Int($0)!})
//    var numValue: Int = 0
//    for i in stride(from:3, through:0, by:-1) {
//        numValue += octets[3-i] << (i * 8)
//    }
//    return numValue
//}
//
//IPToInt(ip: "127.0.0.1") // 2130706433
//IPToInt(ip: "0.0.1.1") // 257
//IPToInt(ip: "0.0.0.1") // 1


//func IntToIP(int: Int) -> String {
//    var octet: [Int] = []
//    var total = 0
//    for i in stride(from: 3, to: 0, by: -1) {
//        var tmp: Int
//        if i < 3 {
//            tmp = Int((int-total) / Int(pow(Float(256), Float(i))))
//        } else {
//            tmp = Int((int) / Int(pow(Float(256), Float(i))))
//        }
//        total += tmp * Int(pow(Float(256), Float(i)))
//        octet.append(tmp)
//    }
//    
//    octet.append(int % 256)
//    return octet.map({String($0)}).joined(separator: ".")
//}
//
//IntToIP(int: 2130706433) // 127.0.0.1
//IntToIP(int: 257) // 0.0.1.1
//IntToIP(int: 1) // 0.0.0.1

//
//func IntToIP(int: Int) -> String {
//    return String((int >> 24) & 0xFF) + "." + String((int >> 16) & 0xFF) + "." + String((int >> 8) & 0xFF) + "." + String(total & 0xFF)
//}
//
//IntToIP(int: 2130706433) // 127.0.0.1
//IntToIP(int: 257) // 0.0.1.1
//IntToIP(int: 1) // 0.0.0.1


//func explodeRange(lower: String, upper: String) -> [String] {
//    var ips: [String] = []
//    for i in stride(from:IPToInt(ip: lower), through: IPToInt(ip:upper), by: 1) {
//        ips.append(IntToIP(int: i))
//    }
//    return ips
//}
//
//explodeRange(lower: "127.0.0.1", upper: "127.0.0.5")
//// "127.0.0.1-127.0.0.5" -> ["127.0.0.1", "127.0.0.2", "127.0.0.3", "127.0.0.4", "127.0.0.5"]
