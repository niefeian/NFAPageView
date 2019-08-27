//
//  CustomTableViewProtocal.swift
//  testDemo
//
//  Created by 聂飞安 on 2018/9/3.
//  Copyright © 2018年 聂飞安. All rights reserved.
//

import Foundation
import UIKit
/*创建table比较快这样子*/
public protocol CustomTableViewProtocal { }

public extension CustomTableViewProtocal {
    
    private func configIdentifier(_ identifier: inout String) -> String {
        var index = identifier.firstIndex(of: ".")
        guard index != nil else { return identifier }
        index = identifier.index(index!, offsetBy: 1)
        identifier = String(identifier[index! ..< identifier.endIndex])
        return identifier
    }
    
    public func registerCell(_ tableView: UITableView, _ cellCls: AnyClass) {
        var identifier = NSStringFromClass(cellCls)
        identifier = configIdentifier(&identifier)
        tableView.register(cellCls, forCellReuseIdentifier: identifier)
    }
    
    public func cellWithTableView<T: UITableViewCell>(_ tableView: UITableView) -> T {
        var identifier = NSStringFromClass(T.self)
        identifier = configIdentifier(&identifier)
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        return cell as! T
    }
    
    /*快速构建表格*/
    public func tableViewConfig(_ delegate: UITableViewDelegate, _ dataSource: UITableViewDataSource, _ style: UITableView.Style?) -> UITableView  {
        let tableView = UITableView(frame:  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: style ?? .plain)
        tableView.delegate = delegate
        tableView.dataSource = dataSource
        return tableView
    }
    
    public func tableViewConfig(_ frame: CGRect ,_ delegate: UITableViewDelegate, _ dataSource: UITableViewDataSource, _ style: UITableView.Style?) -> UITableView  {
        let tableView = UITableView(frame: frame, style: style ?? .plain)
        tableView.delegate = delegate
        tableView.dataSource = dataSource
        return tableView
    }
}
