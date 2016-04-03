//
//  Template.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import Foundation
import Argo



struct Template: Persistable {
    let identifier: String
    let title: String
    let date: NSDate
    let gridPath: String
    let imagePath: String
    
    var image: UIImage? {
        return UIImage(contentsOfFile: imagePath)
    }
    
    func grid() throws -> HexagonGrid  {
        return try HexagonGrid.load(gridPath)
    }
}

extension Template: Decodable {
    static var curriedInit: String -> String -> NSDate -> String -> String -> Template = { identifier in
        return { title in
            return { date in
                return { gridPath in
                    return { imagePath in
                        return Template(
                            identifier: identifier,
                            title: title,
                            date: date,
                            gridPath: gridPath,
                            imagePath: imagePath)
                    }
                }
            }
        }
    }
    
    static func decode(json: JSON) -> Decoded<Template> {
        return curriedInit  <^> json <| "identifier"
            <*> json <| "title"
            <*> json <| "date"
            <*> json <| "jsonPath"
            <*> json <| "imagePath"
    }
}

extension Template: Encodable {
    func encode() -> JSON {
        return ["identifier":identifier, "title":title, "date":date, "jsonPath":gridPath, "imagePath":imagePath]
    }
}