//
//  DetailsVC.swift
//  Trax
//
//  Created by Yosi Faroh Zada on 27/04/2021.
//

import UIKit

class DetailsVC: UIViewController {
    
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
//    private var productImage:UIImage?
    var productItem: Product
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: "titleCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    init(productItem: Product) {
        self.productItem = productItem
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- DetailsVC Lifecycle

extension DetailsVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "Item"
        
        setupUI()
        
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save, target: self, action: #selector(didPressSaveBtn))
    }
}

// MARK:- DetailsVC UI Setup

extension DetailsVC {
    private func setupUI() {
        self.view.addSubview(tableView)
        
        tableView.fillSuperview()
    }
}

// MARK:- DetailsVC Methods

extension DetailsVC {
    private func startPhotoSelect(with source:UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
    }
}

// MARK:- DetailsVC IBActions

extension DetailsVC {
    @objc private func didPressSaveBtn() {
        
        guard let cell = tableView.cellForRow(at: .init(item: 0, section: 0)) as? TextFieldCell,
              cell.textField.hasText,
              let productName = cell.textField.text else { return }

        self.productItem.name = productName

        ProductModel.shared().update()

        self.navigationController?.popViewController(animated: true)
    }
}

// MARK:- UITableView Protocol

extension DetailsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TextFieldCell
            cell.textField.text = self.productItem.name
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Category: \(Category(rawValue: Int(self.productItem.category))!.description)"
            
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Select Image"
            
            if let img = productItem.imgName {
                cell.imageView?.image = UIImage(data: img)
            }
            
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            if let barcode = productItem.barcode {
                cell.textLabel?.text = "Scan BarCode: \(barcode)"
            } else {
                cell.textLabel?.text = "Scan BarCode"
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.accessoryType = .none
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = ""
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            if let cell = tableView.cellForRow(at: indexPath) as? TextFieldCell {
                cell.textField.becomeFirstResponder()
            }
        } else if indexPath.row == 1 {
            self.navigationController?.pushViewController(CategorySelectVC(delegate: self, category: Category(rawValue: Int(self.productItem.category))!), animated: true)
        } else if indexPath.row == 2 {
            
            let selectAlert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
            selectAlert.addAction(.init(title: "Camera", style: .default, handler: { [weak self] (action) in
                self?.startPhotoSelect(with: .camera)
            }))
            selectAlert.addAction(.init(title: "Photo Library", style: .default, handler: { [weak self] (action) in
                self?.startPhotoSelect(with: .photoLibrary)
            }))
            selectAlert.addAction(.init(title: "Cancel", style: .destructive, handler: nil))
            
            selectAlert.pruneNegativeWidthConstraints()
            present(selectAlert, animated: true, completion: nil)
        } else if indexPath.row == 3 {
            let scannerVC = BarCodeScannerVC(delegate: self)
            scannerVC.modalPresentationStyle = .fullScreen
            
            present(scannerVC, animated: true, completion: nil)
        }
    }
}

extension DetailsVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let productImage = info[.editedImage] as? UIImage,
              let data = productImage.jpegData(compressionQuality: 1.0) else {
            print("No image found")
            return
        }
        
        self.productItem.imgName = data
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK:- CategoryDelegate

extension DetailsVC: CategoryDelegate {
    func didSelectCategory(with category: Category) {
        self.productItem.category = Int64(category.rawValue)
        tableView.reloadData()
    }
}

// MARK:- BarCodeScannerDelegate

extension DetailsVC: BarCodeScannerDelegate {
    func didSelectBarcode(with barcode: String) {
        self.productItem.barcode = barcode
        tableView.reloadData()
    }
}
