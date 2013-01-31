class LineLayout < UICollectionViewFlowLayout
  ACTIVE_DISTANCE = 200
  ZOOM_FACTOR     = 0.3
  
  def init
    super.tap do
      iPad = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
      self.scrollDirection = UICollectionViewScrollDirectionHorizontal
      self.itemSize = CGSize.new(170, 200)
      self.sectionInset = UIEdgeInsetsMake(iPad ? 225 : 0, 35, iPad ? 225 : 0, 35)
      self.minimumLineSpacing = 30.0
      self.minimumInteritemSpacing = 200
      self.headerReferenceSize = iPad ? CGSize.new(50, 50) : CGSize.new(43, 43)
    end
  end
  
  def shouldInvalidateLayoutForBoundsChange(old_bounds)
    true
  end
  
  def self.layoutAttributesClass
    ConferenceLayoutAttributes
  end
  
  def layoutAttributesForElementsInRect(rect)
    visible_rect = CGRect.new(self.collectionView.contentOffset, self.collectionView.bounds.size)
    array = super
    array.select { |attrs| attrs.representedElementCategory == UICollectionElementCategoryCell }
         .select { |attrs| CGRectIntersectsRect(attrs.frame, rect) }
         .map    { |attrs| self.setLineAttributes(attrs, visibleRect:visible_rect) }
         
    array.select { |attrs| attrs.representedElementCategory == UICollectionElementCategorySupplementaryView }
         .map    { |attrs| self.setHeaderAttributes(attrs) }
    NSArray.arrayWithArray(array)
  end
  
  def layoutAttributesForItemAtIndexPath(path)
    visible_rect = CGRect.new(self.collectionView.contentOffset, self.collectionView.bounds.size)    
    super.tap { |attrs| self.setLineAttributes(attrs, visibleRect:visible_rect) }
  end
  
  def layoutAttributesForSupplementaryViewOfKind(kind, atIndexPath:path)
    super.tap { |attrs| self.setHeaderAttributes(attrs) if attrs  }
  end
  
  def setHeaderAttributes(attrs)
    attrs.transform3D = CATransform3DMakeRotation(-90 * Math::PI / 180, 0, 0, 1)
    attrs.size = CGSizeMake(attrs.size.height, attrs.size.width)
    attrs.headerTextAlignment = NSTextAlignmentCenter if attrs.is_a?(ConferenceLayoutAttributes)
  end
  
  def setLineAttributes(attrs, visibleRect:visible_rect)
    distance = CGRectGetMidX(visible_rect) - attrs.center.x
    normalized_distance = distance / ACTIVE_DISTANCE
    if distance.abs < ACTIVE_DISTANCE
      zoom = 1 + ZOOM_FACTOR * (1 - normalized_distance.abs)
      attrs.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0)
      attrs.zIndex = 1
    else
      attrs.transform3D = CATransform3DIdentity
      attrs.zIndex = 0
    end
  end
  
  def targetContentOffsetForProposedContentOffset(proposedContentOffset, withScrollingVelocity:velocity)
    offset_adjustment = Float::MAX
    horizontal_center = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0)
    
    target_rect = CGRect.new([proposedContentOffset.x, 0.0], self.collectionView.bounds.size)
    array = layoutAttributesForElementsInRect(target_rect)
    array.select { |attrs| attrs.representedElementCategory == UICollectionElementCategoryCell } # skip headers
         .reject { |attrs| (attrs.center.x - horizontal_center).abs < offset_adjustment.abs }
         .map    { |attrs| offset_adjustment = attrs.center.x - horizontal_center }
         
    CGPoint.new(proposedContentOffset.x + offset_adjustment, proposedContentOffset.y)
  end
end