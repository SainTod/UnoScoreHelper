//
//  HistoryTableViewCell.swift
//  GameCountHelper
//
//  Created by Vlad on 7/10/20.
//  Copyright © 2020 Alexx. All rights reserved.
//

import UIKit
import BoxView

class HistoryTableViewCell: UITableViewCell {

    let dateLabel = SkinLabel()
    let playersLabel = SkinLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let boxView = BoxView()
        contentView.addBoxItem(boxView.boxed)
        boxView.items = [dateLabel.boxed, playersLabel.boxed]
        boxView.insets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
