//
//  ControlsViewController.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

@objc protocol ControlsDelegate {
    func didTapUndo(sender: UIButton)
    func didTapPlay(sender: UIButton)
    func didTapStep(sender: UIButton)
    func didTapSave(sender: UIButton)
    func didTapLoad(sender: UIButton)
    func didTapMenu(sender: UIButton)
}

class ControlsViewController: UIViewController {
    @IBOutlet weak var delegate: ControlsDelegate?
    
    
    @IBOutlet var undoButton: UIButton?
    @IBOutlet var playButton: UIButton?
    @IBOutlet var stepButton: UIButton?
    @IBOutlet var loadButton: UIButton?
    @IBOutlet var saveButton: UIButton?
    @IBOutlet var menuButton: UIButton?
    
    @IBAction func undo(sender: UIButton) {
        delegate?.didTapUndo(sender)
    }
    
    @IBAction func play(sender: UIButton) {
        delegate?.didTapPlay(sender)
    }
    
    @IBAction func step(sender: UIButton) {
        delegate?.didTapStep(sender)
    }
    
    @IBAction func save(sender: UIButton) {
        delegate?.didTapSave(sender)
    }
    
    @IBAction func load(sender: UIButton) {
        delegate?.didTapLoad(sender)
    }
    @IBAction func menu(sender: UIButton) {
        delegate?.didTapMenu(sender)
    }
}