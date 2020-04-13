//
//  Tag_Cell.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 4/13/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Tag_Cell: UICollectionViewCell {
    
    @IBOutlet var tagName: UILabel!
    
    @IBOutlet var tagNameMaxWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        self.layer.cornerRadius = 4
        self.tagNameMaxWidthConstraint.constant = UIScreen.main.bounds.size.width - 8 * 2 - 8 * 2
    }
}
