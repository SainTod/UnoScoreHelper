//
//  TopBarViewController.swift
//  Crypto
//
//  Created by Vlad on 4/2/20.
//  Copyright © 2020 Alexx. All rights reserved.
//

import UIKit
import BoxView

class TopBarViewController: BaseViewController {
    
    let contentBoxView = BoxView()

    let topBarView = TopBarView()

    override func setupViewContent() {
        super.setupViewContent()
        topBarView.backgroundColor = .clear
        safeView.items = [
            topBarView.boxed.height(52.0),
            contentBoxView.boxed
        ]
    }
    
    override func updateViewContent() {
        super.updateViewContent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        print("self: \(self)")
//        print("self.view: \(self.view)")
    }
    
    override func updateSkin(_ skin: Skin) {
        super.updateSkin(skin)
        view.backgroundColor = skin.bgColor
        topBarView.setSkin(skin)
//        topBarView.backgroundColor = .red
    }
    
    func setupBackButton() {
        topBarView.leftButton.setTitle("◄", for: .normal)
        topBarView.leftButton.onClick = { [unowned self] _ in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showDropMenuItems( _ items: [DropMenuItem], sender: UIView, offset: CGPoint = .zero) {
        dropMenuView = DropMenuView()
        dropMenuView?.setItemViews(items)
        dropMenuView?.setSkin(self.skin)
//        print("sender: \(sender)")
        let fromRect = sender.convert(sender.bounds, to: view)
        showDropMenu(dropMenuView!, from: fromRect, offset: offset)
    }
}



