//
//  TemplateViewController.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

let cellIdentifier = "TemplateCell"

class TemplateViewController: UICollectionViewController {
    
    let dataSource = TemplateDataSource()
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource.refresh()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSections
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfTemplates(inSection: section)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath)
        if let template = dataSource.template(atIndexPath: indexPath) {
        }
        
        return cell
    }
}