//
//  TemplateViewController.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

class TemplateCell: UICollectionViewCell {
    static let reuseIdentifier = "TemplateCell"
    @IBOutlet weak var imageView: UIImageView?
}

protocol TemplatePickerDelegate {
    func didSelectTemplate(template: Template)
}

class TemplateViewController: UICollectionViewController {
    
    let dataSource = TemplateDataSource()
    var delegate: TemplatePickerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource.refresh()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(view.frame)
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            let cellWidth = (view.frame.width - 20)/2
            let screenBounds = UIScreen.mainScreen().bounds
            let ratio = screenBounds.height/screenBounds.width
            layout.itemSize = CGSize(width: cellWidth, height: cellWidth*ratio)
            
        }
    }
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSections
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(dataSource.numberOfTemplates(inSection: section))
        return dataSource.numberOfTemplates(inSection: section)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TemplateCell.reuseIdentifier, forIndexPath: indexPath) as? TemplateCell,
                template = dataSource.template(atIndexPath: indexPath) else {
                return UICollectionViewCell()
        }
        
        cell.imageView?.image = template.image
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let template = dataSource.template(atIndexPath: indexPath) else {
            return
        }
        delegate?.didSelectTemplate(template)
        dismissViewControllerAnimated(true, completion: nil)
    }
}