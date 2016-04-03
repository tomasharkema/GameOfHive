//
//  NSDate.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import Foundation
import Argo

extension NSDate : Decodable {
    public static func decode(json: JSON) -> Decoded<NSDate> {
        switch(json) {
        case .Number(let number):
            let date = NSDate(timeIntervalSince1970: number.doubleValue)
            return pure(date)
        case .String(let string):
            if let date = ISO8601.parse(string) {
                return pure(date)
            } else {
                return .Failure(.TypeMismatch(expected: "ISO8601 formatted String", actual: string))
            }
        default:
            return .Failure(.TypeMismatch(expected: "String or Number", actual: json.description))
        }
    }
}

extension NSDate : Encodable {
    public func encode() -> JSON {
        if let string = ISO8601.format(self) {
            return .String(string)
        } else {
            return .Null
        }
    }
}

extension NSDate {
    var iso8601 : String? {
        return ISO8601.format(self)
    }
    convenience init?(iso8601: String) {
        if let date = ISO8601.parse(iso8601) {
            self.init(timeIntervalSinceNow: date.timeIntervalSinceNow)
            return
        }
        self.init()
        return nil
    }
}