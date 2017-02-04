//
//  Tool.swift
//  ScanQRCode
//
//  Created by admin on 2016/11/25.
//  Copyright © 2016年 admin. All rights reserved.
//

import UIKit

class Tool: NSObject {
    //实现单例
    static let shareTool = Tool()
    private override init() {}

    func doPrintNum()  {
        print(1)
        print(2)
        print(3)
        print(4)

    }

}
