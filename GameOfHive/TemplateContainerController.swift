//
//  TemplateContainerController.swift
//  GameOfHive
//
//  Created by Tomas Harkema on 03-04-16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

class TemplateContainerController: UIViewController {
    @IBOutlet weak var leftOffsetConstraint: NSLayoutConstraint!

    
    weak var templateDelegate: TemplatePickerDelegate?
    var leftOffset: CGFloat = 120
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func dismissButtonPressed(sender: UIButton) {
        templateDelegate?.contentWillClose(self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        leftOffsetConstraint.constant = leftOffset + 60
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let destination = segue.destinationViewController as? TemplateViewController where segue.identifier == "embedTemplates" else {
            return
        }

        destination.delegate = templateDelegate
    }
}
