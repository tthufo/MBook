//
//  OwnTableView.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 4/9/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class OwnTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
    
    override var contentSize: CGSize {
        didSet{
            self.invalidateIntrinsicContentSize()
        }
    }
}
