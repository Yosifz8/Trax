//
//  NewProductVC.swift
//  Trax
//
//  Created by Yosi Faroh Zada on 26/04/2021.
//

import UIKit

class NewProductVC: UIViewController {
    private var productImage:UIImage?
    private var category:Category = Category.General
    private var barcode:String?
    
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
}

// MARK:- NewProductVC Lifecycle

extension NewProductVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "Add Item"
        
        setupUI()
        
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save, target: self, action: #selector(didPressSaveBtn))
    }
}

// MARK:- NewProductVC UI Setup

extension NewProductVC {
    private func setupUI() {
        self.view.addSubview(tableView)
        
        tableView.fillSuperview()
    }
}

// MARK:- NewProductVC Class Methods
extension NewProductVC {
    private func startPhotoSelect(with source:UIImagePickerController.SourceType) {
        Camera.checkCameraPermission { [weak self] (authorized) in
            if authorized {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = source
                imagePicker.allowsEditing = true
                
                self?.present(imagePicker, animated: true, completion: nil)
            } else {
                self?.perform(#selector(self?.showPermissionAlert), with: nil, afterDelay: 0.1)
            }
        }
    }
    
    @objc private func showPermissionAlert() {
        let alert = UIAlertController(title: "Camera Permission", message: "The app need permission to access your camera", preferredStyle: .alert)
        alert.addAction(.init(title: "Settings", style: .default, handler: { (action) in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }))
        alert.addAction(.init(title: "Cancel", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK:- NewProductVC IBActions

extension NewProductVC {
    @objc private func didPressSaveBtn() {
        
        guard let cell = tableView.cellForRow(at: .init(item: 0, section: 0)) as? TextFieldCell,
              cell.textField.hasText,
              let productName = cell.textField.text,
              let productImage = self.productImage,
              let barcode = self.barcode,
              let data = productImage.jpegData(compressionQuality: 1.0) else { return }
        
        if ProductModel.shared().addNewItem(with: productName, barCode: barcode, category: self.category, imgData: data) {
            self.navigationController?.popViewController(animated: true)
        } else {
            print("fail to save product")
        }
    }
}

// MARK:- UITableView Protocol

extension NewProductVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TextFieldCell
            
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Category: \(self.category.description)"
            
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Select Image"
            if let img = self.productImage {
                cell.imageView?.image = img
            }
            
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            if let barcode = self.barcode {
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
            self.navigationController?.pushViewController(CategorySelectVC(delegate: self, category: category), animated: true)
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

extension NewProductVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        self.productImage = image
        
        picker.dismiss(animated: true) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK:- CategoryDelegate

extension NewProductVC: CategoryDelegate {
    func didSelectCategory(with category: Category) {
        self.category = category
        tableView.reloadData()
    }
}

// MARK:- BarCodeScannerDelegate

extension NewProductVC: BarCodeScannerDelegate {
    func didSelectBarcode(with barcode: String) {
        self.barcode = barcode
        tableView.reloadData()
    }
}
