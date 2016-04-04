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
    @IBOutlet weak var dateLabel: UILabel?
    
    override func awakeFromNib() {
        dateLabel?.textColor = UIColor.lightAmberColor
    }
}

protocol TemplatePickerDelegate: class, SubMenuDelegate  {
    func didSelectTemplate(template: Template)
}

class TemplateViewController: UICollectionViewController {
    
    let dataSource = TemplateDataSource()
    weak var delegate: TemplatePickerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource.refresh()
        collectionView!.backgroundColor = UIColor.backgroundColor
        collectionView!.layer.borderColor = UIColor.darkAmberColor.CGColor
        collectionView!.layer.borderWidth = 1
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
        let dateFormat = NSDateFormatter.init()
        dateFormat.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormat.timeStyle = NSDateFormatterStyle.MediumStyle
        cell.dateLabel?.text = dateFormat.stringFromDate(template.date)
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