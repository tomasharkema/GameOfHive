//
//  TemplatesViewController.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

private let lastSavedTemplateIdentifierKey = "org.gameofhive.lastSavedTemplateIdentifier"

private var lastSavedTemplateIdentifier: String {
    return NSUserDefaults.standardUserDefaults().objectForKey(lastSavedTemplateIdentifierKey)! as! String
}

class TemplateManager {
    enum Error: ErrorType {
        case ImageFailedSaving
    }
    
    static let shared = TemplateManager()
    private let fileManager = NSFileManager.defaultManager()
    
    init() {
        createDirectory(atPath: jsonDirectory as String)
        createDirectory(atPath: imageDirectory as String)
    }
    
    private func createDirectory(atPath path: String) {
        guard !fileManager.fileExistsAtPath(path) else {
            return
        }
        
        do {
            try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error)")
        }
    }
    
    func loadTemplate(identifier: String? = nil) throws -> Template {
        let templateIdentifier = identifier ?? lastSavedTemplateIdentifier
        let templateFileName = "\(templateIdentifier).json"
        let templatePath = templateDirectory.stringByAppendingPathComponent(templateFileName)
        return try Template.load(templatePath)
    }
    
    func saveTemplate(grid grid: HexagonGrid, image: UIImage, title: String? = nil) throws {
        let identifier = String(grid.hashValue)
        let date = NSDate()
        let title = title ?? date.iso8601 ?? identifier
        
        let imageFileName = "\(identifier).png"
        let imagePath = imageDirectory.stringByAppendingPathComponent(imageFileName)
        guard let imageData = UIImagePNGRepresentation(image) where imageData.writeToFile(imagePath, atomically: true) else {
            throw Error.ImageFailedSaving
        }
        
        let gridFileName = "\(identifier).json"
        let gridPath = jsonDirectory.stringByAppendingPathComponent(gridFileName)
        try grid.save(gridPath)
        
        let templateFileName = gridFileName
        let templatePath = templateDirectory.stringByAppendingPathComponent(templateFileName)
        let template = Template(identifier: identifier, title: title, date: date, gridPath: gridPath, imagePath: imagePath)
        try template.save(templatePath)
        
        NSUserDefaults.standardUserDefaults().setObject(identifier, forKey: lastSavedTemplateIdentifierKey)
    }
    
    func allTemplates() -> [Template] {
        
        guard let filenames = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(templateDirectory as String) else {
            return []
        }
        let paths = filenames.filter { $0.hasSuffix(".json") }.map(templateDirectory.stringByAppendingPathComponent)
        print(paths)
        return paths.flatMap { path in
            do { return try Template.load(path) }
            catch { return nil }
        }
    }
}
