//
//  CategorySelectVC.swift
//  Trax
//
//  Created by Yosi Faroh Zada on 27/04/2021.
//

import UIKit

protocol CategoryDelegate: class {
    func didSelectCategory(with category:Category)
}

class CategorySelectVC: UIViewController {
    private var currentCategory: Category? = nil
    private weak var delegate: CategoryDelegate?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine

        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    init(delegate: CategoryDelegate,category:Category) {
        self.delegate = delegate
        self.currentCategory = category
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- CategorySelectVC Lifecycle

extension CategorySelectVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Products"
                
        setupUI()
    }
}

// MARK:- CategorySelectVC UI Setup

extension CategorySelectVC {
    private func setupUI() {
        self.view.addSubview(tableView)
        
        tableView.fillSuperview()
    }
}

// MARK:- UITableView Protocol

extension CategorySelectVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Category.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        guard let category = Category(rawValue: indexPath.row) else { return UITableViewCell() }
                        
        cell.textLabel?.text = category.description
        cell.accessoryType = self.currentCategory == category ? .checkmark : .none
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let category = Category(rawValue: indexPath.row),
              let delegate = self.delegate else { return }
        
        delegate.didSelectCategory(with: category)
        self.navigationController?.popViewController(animated: true)
    }
}
