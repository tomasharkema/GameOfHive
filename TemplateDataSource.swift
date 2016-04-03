//
//  TemplateDataSource.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import Foundation

class TemplateDataSource {
    var templates: [Template] = []
   
    func refresh() {
        self.templates = TemplateManager.shared.allTemplates()
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfTemplates(inSection section: Int) -> Int {
        return templates.count
    }
    
    func template(atIndexPath indexPath: NSIndexPath) -> Template? {
        guard indexPath.item < numberOfTemplates(inSection: indexPath.section) else {
            return nil
        }
        return templates[indexPath.item]
    }
    
}
