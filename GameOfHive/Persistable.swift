//
//  Persistable.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import Foundation
import Argo

enum LoadError: ErrorType {
    case FileDoesNotExist
    case DecodeFailed(error: DecodeError)
}

protocol Persistable: Saveable, Loadable { }

protocol Saveable {
    func save(path: String) throws
}

extension Saveable where Self:Encodable {
    func save(path: String) throws {
        try self.encode().toJSONString.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
    }
}

protocol Loadable {
    static func load(path: String) throws -> Self
}

extension Loadable where Self:Decodable {
    static func load(path: String) throws -> Self.DecodedType {
        guard let data = NSData(contentsOfFile: path) else {
            throw LoadError.FileDoesNotExist
        }
        
        let object = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        let json = JSON.parse(object)
        let decoded: Decoded<Self.DecodedType> = self.decode(json)
        
        switch decoded {
        case .Success(let value):
            return value
        case .Failure(let error):
            throw LoadError.DecodeFailed(error: error)
            
        }
    }
}