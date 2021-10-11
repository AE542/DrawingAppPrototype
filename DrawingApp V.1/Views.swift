//
//  Views.swift
//  DrawingApp V.1
//
//  Created by Mohammed Qureshi on 2021/08/22.
//

import Foundation
import UIKit

class Views {

let mainView = UIView()

func setMainViewConstraints(view: UIView) {
    mainView.translatesAutoresizingMaskIntoConstraints = false
    mainView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
    
    mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20).isActive = true
    
    mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
}

}
