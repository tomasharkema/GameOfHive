//
//  Dictionary.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 02/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import Foundation

///Extension to be able to map a function over Dictionaries
extension Dictionary {
    /**
     The combine function to use when reducing a list of key,value tuples into a Dictionary
     
     - parameter dict: The Dictionary that accumulates all the keys and values
     - parameter element: A single tuple with a key and value type
     - returns: The provided dictionary with the key set to the value from the element tuple
     */
    static func combine<K,V>(dict: Dictionary<K,V>, element: (K,V)) -> Dictionary<K,V> {
        var dictionary = dict
        let (key, value) = element
        dictionary[key] = value
        return dictionary
    }
    
    /**
     Map a transform function over the values of the `Dictionary`. Comparable to `Dictionary.map`, but it doesn't change the keys of the `Dictionary`.
     
     - parameter transform: A function that takes a `Value`-type from the `Dictonary` and returns another value, possibly of another type.
     - returns: A `Dictionary` with the same keys as the original, but with the transform function applied to every value.
     */
    func mapValues<T>(transform: Value -> T) -> Dictionary<Key,T> {
        var result: [Key:T] = [:]
        for (key, value) in self {
            result[key] = transform(value)
        }
        return result
    }
}