//
//  Encode.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 02/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import Foundation
import Argo

public protocol Encodable {
    func encode() -> JSON
}

//MARK: LiteralConvertible

extension JSON : StringLiteralConvertible {
    public typealias UnicodeScalarLiteralType = StringLiteralType
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public init(stringLiteral value: StringLiteralType) {
        self =  .String(value)
    }
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self =  .String(value)
    }
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .String(value)
    }
}

extension JSON : IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .Number(value)
    }
}

extension JSON : FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .Number(value)
        
    }
}

extension JSON : BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .Number(value)
    }
}

extension JSON : DictionaryLiteralConvertible {
    public typealias Key = Swift.String
    public typealias Value = Encodable?
    public init(dictionaryLiteral elements: (Key, Value)...) {
        let dictionary = elements.reduce([:], combine: Dictionary<Key,Value>.combine)
        self = dictionaryEncode(dictionary)
    }
}

extension JSON : ArrayLiteralConvertible {
    public typealias Element = Encodable
    public init(arrayLiteral elements: Element...) {
        self = elements.encode() ?? .Null
    }
}

extension JSON : NilLiteralConvertible {
    public init(nilLiteral: ()) {
        self = .Null
    }
}


//MARK: Standard Types
extension JSON: Encodable {
    public func encode() -> JSON {
        return self
    }
}

extension String: Encodable {
    public func encode() -> JSON {
        return .String(self)
    }
}

extension Int: Encodable {
    public func encode() -> JSON {
        return .Number(self)
    }
}

extension Double: Encodable {
    public func encode() -> JSON {
        return .Number(self)
    }
}

extension Bool: Encodable {
    public func encode() -> JSON {
        return .Number(self)
    }
}

extension Float: Encodable {
    public func encode() -> JSON {
        return .Number(self)
    }
}

extension Array: Encodable {
    public func encode() -> JSON {
        let encodables: [Encodable] = self.map{ ($0 as? Encodable) ?? JSON.Null }
        return .Array(encodables.map {$0.encode()})
    }
}

extension Dictionary: Encodable {
    public func encode() -> JSON {
        guard Key.self == String.self else {
            return .Null
        }
        var result: [String:JSON] = [:]
        for (key,value) in self {
            result[String(key)] = (value as? Encodable)?.encode() ?? .Null
        }
        return .Object(result)
    }
}

func dictionaryEncode(dict: Dictionary<String,Encodable?>?) -> JSON {
    if dict == nil {
        return .Null
    }
    
    let result: [String : JSON] = dict!.mapValues { value in
        return value?.encode() ?? .Null
    }
    
    return .Object(result)
}

//MARK: Helper function
extension JSON {
    public func filterJSONNull() -> JSON {
        switch self {
        case let .Object(o):
            var dict: [Swift.String : JSON] = [:]
            for (key,value) in o {
                if value != .Null {
                    dict[key] = value.filterJSONNull()
                }
            }
            return .Object(dict)
        case let .Array(a):
            let filtered = a.filter({ (e:JSON) in e != .Null})
            let mapped = filtered.map({$0.filterJSONNull()})
            return .Array(mapped)
        default:
            return self
        }
    }
}