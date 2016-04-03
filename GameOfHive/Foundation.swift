//
//  Foundation.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 02/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import Foundation

let documentsDirectory: NSString = {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
}()

let templateDirectory: NSString = documentsDirectory.stringByAppendingPathComponent("template")
let jsonDirectory: NSString = templateDirectory.stringByAppendingPathComponent("json")
let imageDirectory: NSString = templateDirectory.stringByAppendingPathComponent("images")