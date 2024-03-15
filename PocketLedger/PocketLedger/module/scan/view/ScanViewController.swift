//
//  ScanViewController.swift
//  PocketLedger
//
//  Created by Yang Gao on 2024/3/15.
//

import Foundation
import UIKit
import Vision

class ScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //scan and then retrieve data (itemName:Apple price:$10.99)
    private var dataItems: [(itemName: String, price: Double)] = []
    
    
    //initialization
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        //Scaling according to view size
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    //scan button
    private lazy var scanButton:UIButton = {
        let button = UIButton()
        button.setTitle("Scan Receipt", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(scanReceipt), for: .touchUpInside)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    @objc
    func scanReceipt(){
        
    }

    
    
    
    

}
