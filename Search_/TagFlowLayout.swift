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
        var leftMargin: CGFloat = 0.0;
        for attributes in attributesForElementsInRect! {
            if !(attributes.representedElementKind == UICollectionView.elementKindSectionHeader
                || attributes.representedElementKind == UICollectionView.elementKindSectionFooter) {
              let refAttributes = attributes
              if (refAttributes.frame.origin.x == self.sectionInset.left) {
                leftMargin = self.sectionInset.left
              } else {
                var newLeftAlignedFrame = refAttributes.frame
                newLeftAlignedFrame.origin.x = leftMargin
                refAttributes.frame = newLeftAlignedFrame
              }
              leftMargin += refAttributes.frame.size.width + 8
              newAttributesForElementsInRect.append(refAttributes)
            } else {
                return attributesForElementsInRect
            }
        }
        return (newAttributesForElementsInRect as! [UICollectionViewLayoutAttributes])
  }
}
