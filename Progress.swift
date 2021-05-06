//
//  Progress.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 5/5/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Progress: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet var percentage: UILabel!
    
    @IBOutlet var inner: UIView!

    @IBOutlet var outer: UIView!
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    func setUp() {
        Bundle.main.loadNibNamed("Progress", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
