//
//  ViewController.swift
//  ScanQRCode
//
//  Created by admin on 2016/11/25.
//  Copyright © 2016年 admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Tool.shareTool.doPrintNum()
    }

    @IBAction func doNext(){
        let scan = ScanCodeViewController()
//        self.present(scan, animated: true, completion: nil)
        self.navigationController?.pushViewController(scan, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

