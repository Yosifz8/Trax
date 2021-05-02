//
//  ProductListVC.swift
//  Trax
//
//  Created by Yosi Faroh Zada on 26/04/2021.
//

import UIKit
import CoreData

class ProductListVC: UIViewController {
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 66.0
        tableView.separatorStyle = .singleLine
        tableView.allowsMultipleSelectionDuringEditing = true

        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
}

// MARK:- ProductListVC Lifecycle

extension ProductListVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Products"
                
        setupUI()
        
        
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .edit, target: self, action: #selector(didPressEditModeBtn))
        
        self.navigationItem.leftBarButtonItem = .init(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(didPressAddItemBtn))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ProductModel.shared().getAllItems()
        self.tableView.reloadData()
    }
}

// MARK:- ProductListVC UI Setup

extension ProductListVC {
    private func setupUI() {
        self.view.addSubview(tableView)
        
        tableView.fillSuperview()
    }
}

// MARK:- ProductListVC IBActions

extension ProductListVC {
    @objc private func didPressAddItemBtn() {
        let vc = NewProductVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didPressEditModeBtn() {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        
        self.navigationItem.rightBarButtonItems = self.tableView.isEditing ? [.init(barButtonSystemItem: .edit, target: self, action: #selector(didPressEditModeBtn)), .init(title: "Delete", style: .plain, target: self, action: #selector(didPressDeleteBtn))] : [.init(barButtonSystemItem: .edit, target: self, action: #selector(didPressEditModeBtn))]
    }
    
    @objc private func didPressDeleteBtn() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            ProductModel.shared().deleteItems(indexPaths: selectedIndexPaths)
            self.tableView.deleteRows(at: selectedIndexPaths, with: .none)
        }
    }
}

// MARK:- UITableView Protocol

extension ProductListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Category.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let category = Category(rawValue: section),
              let productsArray = ProductModel.shared().models[category] else { return 0 }
                
        return productsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        guard let category = Category(rawValue: indexPath.section),
              let productsArr = ProductModel.shared().models[category] else { return cell }
        
        let product = productsArr[indexPath.row]
                
        cell.imageView?.image = UIImage(data: product.imgName!)
        cell.textLabel?.text = product.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
            
            guard let category = Category(rawValue: indexPath.section),
                  let productsArr = ProductModel.shared().models[category] else { return }
                        
            self.navigationController?.pushViewController(DetailsVC(productItem: productsArr[indexPath.row]), animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let category = Category(rawValue: section) else { return "" }
        return category.description
    }
}
