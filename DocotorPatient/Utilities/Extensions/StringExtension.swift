//
//  StringExtension.swift
//  TemplateProjSwift
//
//  Created by Mac22 on 13/09/18.
//  Copyright © 2018 Mac22. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    mutating func encodeURL() {
        self = self.encodedURL()
    }
    
    mutating func decodeURL() {
        self = self.decodedURL()
    }
    
    mutating func encodeURLQuery() {
        self = self.encodedURLQuery()
    }
    
    func encodedURL() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) ?? self
    }
    
    func decodedURL() -> String {
        return self.removingPercentEncoding ?? self
    }
    
    func encodedURLQuery() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? self
    }
    
    static func base64Encode(_ data: Data?) -> String {
        if data != nil {
            return data!.base64EncodedString()
        }
        return ""
    }
    
    static func base64Encode(_ image: UIImage) -> String {
        let data = image.pngData()
        return String.base64Encode(data)
    }
    
    static func base64Encode(_ filepath: String) -> String {
        do {
            let data = try Data.init(contentsOf: URL.init(fileURLWithPath: filepath))
            return String.base64Encode(data)
        } catch let error {
            print(error)
        }
        return ""
    }
    
    func base64Decode() -> Data? {
        let decodedData = Data.init(base64Encoded: self)
        return decodedData
    }
    
    func utf8Encoded() -> Data {
        return self.data(using: String.Encoding.utf8)!
    }
    
    mutating func encodeBase64() {
        self = self.utf8Encoded().base64EncodedString()
    }
    
    func encodedBase64() -> String {
        return self.utf8Encoded().base64EncodedString()
    }
    
    mutating func decodeBase64() {
        self = self.decodedBase64()
    }
    
    func decodedBase64() -> String {
        if let decodedData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            return String.init(data: decodedData, encoding: String.Encoding.utf8) ?? self
        }
        return self
    }
    
    func trimmed() -> String {
        let whitespace = CharacterSet.whitespacesAndNewlines
        let stringTrimmed = self.trimmingCharacters(in: whitespace)
        let stringWithoutSpace = stringTrimmed.replacingOccurrences(of: " ", with: "")
        return stringWithoutSpace
    }
    
    mutating func trim() {
        self = self.trimmed()
    }
    
    func toInt() -> Int {
        let intValue = Int(self)
        return intValue ?? 0
    }
    
    func toDouble() -> Double {
        let doubleValue = Double(self)
        return doubleValue ?? 0
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.width)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    static func currenyString(fromDouble value: Double?) -> String {
        if value == nil {
            return ""
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .currency
        if let string = numberFormatter.string(from: NSNumber.init(value: value!)) {
            return string
        }
        return ""
    }
    
    static func fromDouble(_ value: Double?) -> String {
        if value == nil {
            return ""
        }
        return "\(value!)"
    }
    
}

extension Double {
    var string: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Int {
    
    func toHoursMinutesSeconds() -> (hours: Int, minutes: Int, seconds: Int) {
        return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
    }
    
    func toLeadingZeroString() -> String {
        return String(format: "%02d", self)
    }
    
}
extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
