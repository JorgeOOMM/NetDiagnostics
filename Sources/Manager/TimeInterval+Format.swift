//
//  TimeInterval.swift
//
//  Created by Mac on 3/12/25.
//

import Foundation

extension TimeInterval {
    var sec: TimeInterval {
        self.truncatingRemainder(dividingBy: 60)
    }
    var minutes: TimeInterval {
        (self / 60).truncatingRemainder(dividingBy: 60)
    }
    var hours: TimeInterval {
        (self / 3600)
    }
    var millisecs: TimeInterval {
        (self.truncatingRemainder(dividingBy: 1)) * 1000
    }
    var millisecsString: String {
        let millisecs = self.millisecs
        let nfmt = NumberFormatter()
        nfmt.minimumFractionDigits = 3
        nfmt.maximumFractionDigits = 3
        if let result = nfmt.string(from: NSNumber(value: millisecs)) {
            return result
        } else {
            return "\(millisecs)"
        }
    }
    
    func string() -> String {
        let millisecs = self.millisecs
        let seconds = self.sec
        let minutes = self.minutes
        let hours = self.hours
        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d", hours, minutes, seconds, millisecs)
    }
}
