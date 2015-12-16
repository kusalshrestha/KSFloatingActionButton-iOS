//
//  ViewController.swift
//  FloatButton
//
//  Created by Kusal Shrestha on 12/10/15.
//  Copyright © 2015 Kusal Shrestha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var floatButton: FloatButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        floatButton = FloatButton(addFloatButtonOverView: self.view)
        
        let images = ["1.png","2.png","3.png","4.png","1.png","2.png","3.png","4.png","1.png","2.png","3.png","4.png"]
        floatButton.items = images
        floatButton.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        floatButton.layoutViewDuringOrientation()
    }
}

extension ViewController: FloatButtonDelegate {
    
    func menuTable(menuTable: UITableView, didSelectItemAtIndex index: Int) {
        print(index)
    }
    
}
