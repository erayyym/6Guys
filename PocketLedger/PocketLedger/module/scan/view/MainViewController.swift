//
//  MainViewController.swift
//  PocketLedger
//
//  Created by Chen Yang on 3/15/24.
//

import UIKit

class MainViewController: UIViewController{
    private lazy var scanButton:UIButton =
    {
        let button = UIButton()
        button.setTitle("SCAN", for: .normal)
        button.setTitleColor(.purple, for: .normal)
        button.addTarget(self, action: #selector(scanReceipt), for: .touchUpInside)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.purple.cgColor
        return button
    }()
    override func viewWillApepar(_ animated: Bool)
    {
        super.viewWillApepar(animated)
    }
    override func viewWillDisAppear(_ animated: Bool)
    {
        super.viewWillDisAppear(animated)
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        sutupUI()
    }
    private func setupUI()
    {
        view.addSubview(scanButton)
        scanButton.snp.makeConstraints
        {
            make in make.leading.trailing.equalToSuperview().inset(12)
            make.buttom.equalToSuperview().offset(-KDefaultBottom() - 12)
            make.height.equalTo(44)
        }
    }
    @objc func scanReceipt() {
        navigationController?.pushViewController(ScanViewController(), animated: false)
    }
}
