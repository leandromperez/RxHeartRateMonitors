//
//  CellProvider.swift
//  RxHeartRateMonitors
//
//  Created by Leandro Perez on 9/26/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import Foundation

import Foundation
import UIKit

public struct CellProvider <Cell : UITableViewCell> {
    
    public init() {}
    
    public var cellIdentifier: String{
        get{
            return String(describing: Cell.self)
        }
    }
    
    
    public func cell(for tableView:UITableView, at row: Int, section:Int = 0) -> Cell{
        
        let indexPath = IndexPath(row: row, section: section)
        
        return self.cell(for: tableView, at: indexPath)
    }
    
    public func cell(for tableView:UITableView, at indexPath: IndexPath) -> Cell{
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier,for: indexPath)
            as? Cell
            else{fatalError()}
        
        return cell
    }
    
    public func registerCell(for tableView:UITableView, automaticRowHeight:Bool = false){
        
        let nib = UINib(nibName: self.cellIdentifier, bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: self.cellIdentifier)
        
        if automaticRowHeight{
            tableView.estimatedRowHeight = 100
            tableView.rowHeight = UITableView.automaticDimension
        }
    }
}

public struct CollectionCellProvider <Cell : UICollectionViewCell> {
    
    public var cellIdentifier: String{
        get{
            return String(describing: Cell.self)
        }
    }
    
    public func cell(for collectionView:UICollectionView, at row: Int, section:Int = 0) -> Cell{
        let indexPath = IndexPath(row: row, section: section)

        return self.cell(for: collectionView, at: indexPath)
    }
    
    public func cell(for collectionView:UICollectionView, at indexPath: IndexPath) -> Cell{
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath)
            as? Cell
            else{fatalError()}
        
        return cell
    }
    
    public func registerCell(for collectionView:UICollectionView){
        
        let nib = UINib(nibName: self.cellIdentifier, bundle: nil)
        
        collectionView.register(nib, forCellWithReuseIdentifier: self.cellIdentifier)
    }
}
