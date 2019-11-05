//
//  CustomExtension.swift
//  testDemo
//
//  Created by 聂飞安 on 2018/9/3.
//  Copyright © 2018年 聂飞安. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    
    public typealias CustomScrollHandle = (UIScrollView) -> Void
    
    private struct CustomHandleKey {
        static var key = "gethandle"
        static var tKey = "getisTableViewPlain"
        static var MKey = "getModel"
    }
    
    public var scrollHandle: CustomScrollHandle? {
        get { return objc_getAssociatedObject(self, &CustomHandleKey.key) as? CustomScrollHandle }
        set { objc_setAssociatedObject(self, &CustomHandleKey.key, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    
    public var vcModel : AnyObject? {
        get { return objc_getAssociatedObject(self, &CustomHandleKey.MKey) as AnyObject}
        set { objc_setAssociatedObject(self, &CustomHandleKey.MKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    
    @objc public var isTableViewPlain: Bool {
        get { return (objc_getAssociatedObject(self, &CustomHandleKey.tKey) as? Bool) ?? false}
        set { objc_setAssociatedObject(self, &CustomHandleKey.tKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
}

extension UIScrollView {
    
    public class func initializeOnce() {
        DispatchQueue.once(token: UIDevice.current.identifierForVendor?.uuidString ?? "CustomScrollView") {
            let originSelector = Selector(("_notifyDidScroll"))
            let swizzleSelector = #selector(getscrollViewDidScroll)
            getswizzleMethod(self, originSelector, swizzleSelector)
        }
    }
    
    @objc dynamic func getscrollViewDidScroll() {
        self.getscrollViewDidScroll()
        guard let scrollHandle = scrollHandle else { return }
        scrollHandle(self)
    }
}

extension NSObject {
    /*方法混淆*/
    static func getswizzleMethod(_ cls: AnyClass?, _ originSelector: Selector, _ swizzleSelector: Selector)  {
        let originMethod = class_getInstanceMethod(cls, originSelector)
        let swizzleMethod = class_getInstanceMethod(cls, swizzleSelector)
        guard let swMethod = swizzleMethod, let oMethod = originMethod else { return }
        let didAddSuccess: Bool = class_addMethod(cls, originSelector, method_getImplementation(swMethod), method_getTypeEncoding(swMethod))
        if didAddSuccess {
            class_replaceMethod(cls, swizzleSelector, method_getImplementation(oMethod), method_getTypeEncoding(oMethod))
        } else {
            method_exchangeImplementations(oMethod, swMethod)
        }
    }
}


extension UIViewController {
    
    private struct CustomVCKey {
        static var sKey = "getscrollViewKey"
        static var oKey = "getupOffsetKey"
    }
    
    /*t通过 objc_setAssociatedObject 给 UIViewController 添加属性 */
    @objc public var getscrollView: UIScrollView? {
        get { return objc_getAssociatedObject(self, &CustomVCKey.sKey) as? UIScrollView }
        set { objc_setAssociatedObject(self, &CustomVCKey.sKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public var getupOffset: String? {
        get { return objc_getAssociatedObject(self, &CustomVCKey.oKey) as? String }
        set { objc_setAssociatedObject(self, &CustomVCKey.oKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

extension UICollectionViewFlowLayout {
    
    public class func loadOnce() {
        DispatchQueue.once(token: "CustomFlowLayout") {
            let originSelector = #selector(getter: UICollectionViewLayout.collectionViewContentSize)
            let swizzleSelector = #selector(UICollectionViewFlowLayout.getcollectionViewContentSize)
            getswizzleMethod(self, originSelector, swizzleSelector)
        }
    }
    
    @objc dynamic func getcollectionViewContentSize() -> CGSize {

        let contentSize = self.getcollectionViewContentSize()

        guard let collectionView = collectionView else { return contentSize }

        let collectionViewH = collectionView.bounds.height - 60

        return contentSize.height < collectionViewH ? CGSize(width: contentSize.width, height: collectionViewH) : contentSize
    }
}

extension DispatchQueue {
    private static var _onceTracker = [String]()
    public class func once(token: String, block: () -> ()) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
     
    func after(_ delay: TimeInterval, execute: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: execute)
    }
}



