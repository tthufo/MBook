//
//  TagFlowLayout.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 4/13/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class TagFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let attributesForElementsInRect = super.layoutAttributesForElements(in: rect)
    var newAttributesForElementsInRect = [AnyObject]()
    // use a value to keep track of left margin
    var leftMargin: CGFloat = 0.0;
    for attributes in attributesForElementsInRect! {
        let refAttributes = attributes
      // assign value if next row
      if (refAttributes.frame.origin.x == self.sectionInset.left) {
        leftMargin = self.sectionInset.left
      } else {
        // set x position of attributes to current margin
        var newLeftAlignedFrame = refAttributes.frame
        newLeftAlignedFrame.origin.x = leftMargin
        refAttributes.frame = newLeftAlignedFrame
      }
      // calculate new value for current margin
      leftMargin += refAttributes.frame.size.width + 12
      newAttributesForElementsInRect.append(refAttributes)
    }
        return (newAttributesForElementsInRect as! [UICollectionViewLayoutAttributes])
  }
}
