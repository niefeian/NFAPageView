//
//  ViewController.swift
//  NFAPageView
//
//  Created by niefeian on 08/13/2019.
//  Copyright (c) 2019 niefeian. All rights reserved.
//

import UIKit
import NFAPageView

class ViewController: UIViewController {
    
    
    private lazy  var viewControllers: [UIViewController]  = {
        var  viewCons = [UIViewController]()
        let fistVC = SubVC()
        let lastVC = SubVC()
        fistVC.view.backgroundColor = UIColor.red
        lastVC.view.backgroundColor = UIColor.blue
        viewCons.append(fistVC)
        viewCons.append(lastVC)
        return viewCons
    }()

    private lazy var titles: [String] = {
        return ["第一个视图", "第二个视图"]
    }()
    
    private lazy var layout: CustomLayout = {
        let layout = CustomLayout()
        layout.isAverage = true
        layout.sliderWidth = UIScreen.main.bounds.size.width/CGFloat(titles.count+1)
        layout.sliderHeight = 40
        layout.lrMargin = 0
        layout.titleMargin = 0
        layout.bottomLineHeight = 0.5
        layout.titleColor = colorConversion(colorValue: "c3c3c3")
        layout.titleSelectColor = colorConversion(colorValue: "29BEFD")
        layout.bottomLineColor = colorConversion(colorValue: "29BEFD")
        layout.pageBottomLineColor = colorConversion(colorValue: "c3c3c3",alpha: 0.5)
        //
        /* 更多属性设置请参考 Layout 中 public 属性说明 */
        return layout
    }()
    
    
    private lazy var advancedManager: CustomAdvancedManager = {
        let statusBarH = UIApplication.shared.statusBarFrame.size.height
        let Y: CGFloat = statusBarH + 44
        let H: CGFloat = getiphoneX ? (view.bounds.height - Y - 34) : view.bounds.height - Y
        let advancedManager = CustomAdvancedManager(frame: CGRect(x: 0, y: Y, width: view.bounds.width, height: H), viewControllers: viewControllers, titles: titles, currentViewController: self, layout: layout, headerViewHandle: {[weak self] in
            guard let strongSelf = self else { return UIView() }
            let headerView = strongSelf.headerView()
            return headerView
        })
        /* 点击切换滚动过程动画 */
        advancedManager.isClickScrollAnimation = true
        /* 代码设置滚动到第几个位置 */
        advancedManager.scrollToIndex(index: 0)
        
        advancedManager.updataSubViewsConfig(300) //f更新头部高度  留
        return advancedManager
    }()
    
    private func headerView() -> UIView {
       let headerView = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 100))
        headerView.text = "顶部区域"
        headerView.textAlignment = .center
        headerView.backgroundColor = colorConversion(colorValue: "c3c3c3")
        return headerView
    }
    
    @objc func updataTryLable(){
        advancedManager.updataSubViewsConfig(30)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(advancedManager)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   func colorConversion(colorValue: String, alpha: CGFloat = 1) -> UIColor {
        var str = colorValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if str.hasPrefix("#") {
            str = str.replacingOccurrences(of: "#", with: "")
        }
        if str.count != 6 {
            return .white
        }
        let redStr = str.subString(start: 0, length: 2)
        let greenStr = str.subString(start: 2, length: 2)
        let blueStr = str.subString(start: 4, length: 2)
        var r:UInt64 = 0, g:UInt64 = 0, b:UInt64 = 0
        Scanner(string: redStr).scanHexInt64(&r)
        Scanner(string: greenStr).scanHexInt64(&g)
        Scanner(string: blueStr).scanHexInt64(&b)
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
    }

}

extension String {
    func subString(start:Int, length:Int = -1)->String {
        var len = length
        if len == -1 {
            len = count - start
        }
        let st = index(startIndex, offsetBy:start)
        let en = index(st, offsetBy:len)
        let range = st ..< en
        return substring(with:range)
    }
}
