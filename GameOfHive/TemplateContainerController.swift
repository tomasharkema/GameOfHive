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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let destination = segue.destinationViewController as? TemplateViewController where segue.identifier == "embedTemplates" else {
            return
        }

        destination.delegate = templateDelegate
    }
}
