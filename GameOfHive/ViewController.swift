//
//  ViewController.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let height: CGFloat = 50
        let s = height/2
        let width = CGFloat(sqrt(3.0)) * s
        
        
        let hex = HexagonView(frame: CGRect(x: 200, y: 200, width: width, height: height))
        view.addSubview(hex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

