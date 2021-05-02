//
//  TextFieldCell.swift
//  Trax
//
//  Created by Yosi Faroh Zada on 27/04/2021.
//

import UIKit

class TextFieldCell: UITableViewCell, UITextFieldDelegate {
    let textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Title"
        tf.autocorrectionType = .no
        return tf
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textField.delegate = self
        
        addSubview(textField)
        textField.frame = .init(x: bounds.origin.x + 20, y:  bounds.origin.y, width:  bounds.size.width, height: bounds.size.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
