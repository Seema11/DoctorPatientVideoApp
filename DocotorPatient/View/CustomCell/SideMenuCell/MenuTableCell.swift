//
//  MenuTableCell.swift
//  bogo
//
//  Created by Appernaut on 06/07/19.
//  Copyright © 2019 Appernaut. All rights reserved.
//

import UIKit

class MenuTableCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var menuTitleLabel: UILabel!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    var menuItem: MenuItem = MenuItem(title: "", icon: UIImage(named: "video-call 50-30")!) {
        didSet {
            iconImageView.image = menuItem.icon
            menuTitleLabel.text = menuItem.title
        }
    }

}
