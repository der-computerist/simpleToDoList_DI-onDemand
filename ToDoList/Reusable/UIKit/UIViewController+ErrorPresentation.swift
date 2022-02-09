//
//  UIViewController+ErrorPresentation.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/29/22.
//

import UIKit

extension UIViewController {
    
    public func presentErrorAlert(title: String?, message: String?) {
        let errorAlertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default)
        errorAlertController.addAction(okAction)
        present(errorAlertController, animated: true, completion: nil)
    }
}
