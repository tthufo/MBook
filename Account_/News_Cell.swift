//
//  News_Cell.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 5/11/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class News_Cell: UITableViewCell {

    @IBOutlet var avatarImage: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        
        if avatarImage != nil {
            avatarImage.heightConstaint?.constant = avatarImage.frame.size.width * 9 / 16
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if avatarImage != nil {
            avatarImage.heightConstaint?.constant = avatarImage.frame.size.width * 9 / 16
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
