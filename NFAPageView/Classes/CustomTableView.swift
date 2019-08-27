//
//  CustomTableView.swift
//  cloudclass
//
//  Created by 聂飞安 on 2018/9/3.
//  Copyright © 2018年 accfun. All rights reserved.
//

import UIKit
/*
 为了媚媚的心情，重写小白的代码，新建一个类写代码
 
 */

class CustomTableView: UITableView ,UIGestureRecognizerDelegate{

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
