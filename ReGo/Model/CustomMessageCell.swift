//
//  CustomMessageCell.swift
//  ReGo
//
//  Created by Анна Мельхова on 12.05.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {

    @IBOutlet var messageBackground: UIView!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var disanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
