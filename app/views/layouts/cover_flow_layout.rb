class CoverFlowLayout < UICollectionViewFlowLayout
  ACTIVE_DISTANCE = 100
  TRANSLATE_DISTANCE = 100
  ZOOM_FACTOR = 0.3
  FLOW_OFFSET = 5 #40
  
  def init
    super.tap do
      iPad = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
      self.scrollDirection = UICollectionViewScrollDirectionHorizontal
      self.itemSize = CGSize.new(170, 194)
      self.sectionInset = UIEdgeInsets.new((iPad ? 225 : 0), 35, (iPad ? 225 : 0), 135);
      self.minimumLineSpacing = -51.0
      self.minimumInteritemSpacing = 200
      self.headerReferenceSize = iPad ? CGSize.new(50, 50) : CGSize.new(43, 43)
    end    
  end
  
  def shouldInvalidateLayoutForBoundsChange(old_bounds); true; end
  
  def self.layoutAttributesClass; ConferenceLayoutAttributes; end
  
  def layoutAttributesForElementsInRect(rect)
    visible_rect = CGRect.new(self.collectionView.contentOffset, self.collectionView.bounds.size)
    array = super
    array.select { |attrs| attrs.representedElementCategory == UICollectionElementCategoryCell }
         .select { |attrs| CGRectIntersectsRect(attrs.frame, rect) }
         .map    { |attrs| self.setCellAttributes(attrs, forVisibleRect:visible_rect) }
         
    array.select { |attrs| attrs.representedElementCategory == UICollectionElementCategorySupplementaryView }
         .map    { |attrs| self.setHeaderAttributes(attrs) }
    array
  end
  
  def layoutAttributesForItemAtIndexPath(path)
    visible_rect = CGRect.new(self.collectionView.contentOffset, self.collectionView.bounds.size)    
    super.tap { |attrs| self.setCellAttributes(attrs, forVisibleRect:visible_rect) }
  end
  
  def layoutAttributesForSupplementaryViewOfKind(kind, atIndexPath:path)
    super.tap { |attrs| self.setHeaderAttributes(attrs) }
  end
  
  def setHeaderAttributes(attrs)
    unless attrs.nil?
      attrs.transform3D = CATransform3DMakeRotation(-90 * Math::PI / 180, 0, 0, 1)
      attrs.size = CGSize.new(attrs.size.height, attrs.size.width)
      attrs.headerTextAlignment = NSTextAlignmentCenter if attrs.is_a?(ConferenceLayoutAttributes)
    end
  end
  
  def setCellAttributes(attrs, forVisibleRect:visible_rect)
    distance = CGRectGetMidX(visible_rect) - attrs.center.x
    normalized_distance = distance / ACTIVE_DISTANCE
    is_left = distance > 0
    transform = CATransform3DIdentity
    transform.m34 = -1/(4.6777 * self.itemSize.width)
    
    if distance.abs < ACTIVE_DISTANCE
      transform.m34 = 0.0
      transform = if distance.abs < TRANSLATE_DISTANCE
        CATransform3DTranslate(CATransform3DIdentity, (is_left ? -FLOW_OFFSET : FLOW_OFFSET)*(distance/TRANSLATE_DISTANCE).abs, 0, (1 - normalized_distance.abs) * 40000 + (is_left ? 200 : 0))
      else
        CATransform3DTranslate(CATransform3DIdentity, (is_left ? -FLOW_OFFSET : FLOW_OFFSET), 0, (1 - normalized_distance.abs) * 40000 + (is_left ? 200 : 0))
      end
      
      transform.m34 = -1 / (4.6777 * self.itemSize.width)
      zoom = 1 + ZOOM_FACTOR * (1 - normalized_distance.abs)
      transform = CATransform3DRotate(transform, (is_left ? 1 : -1) * normalized_distance.abs * 45 * Math::PI / 180, 0, 1, 0)
      transform = CATransform3DScale(transform, zoom, zoom, 1);
      attrs.zIndex = 1 #(ACTIVE_DISTANCE - distance.abs).abs + 1;
    else
      transform = CATransform3DTranslate(transform, is_left ? -FLOW_OFFSET : FLOW_OFFSET, 0, 0)
      transform = CATransform3DRotate(transform, (is_left ? 1 : -1) * 45 * Math::PI / 180, 0, 1, 0)
      attrs.zIndex = 0
    end
    
    attrs.transform3D = transform
  end
  
  def targetContentOffsetForProposedContentOffset(proposed_cont_offset, withScrollingVelocity:velocity)
    offset_adjustment = Float::MAX
    horizontal_center = proposed_cont_offset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0)
    
    target_rect = CGRect.new([proposed_cont_offset.x, 0.0], self.collectionView.bounds.size)
    array = layoutAttributesForElementsInRect(target_rect)
    
    array.select { |attrs| attrs.representedElementCategory == UICollectionElementCategoryCell } # skip headers
         .reject { |attrs| (attrs.center.x - horizontal_center).abs > offset_adjustment.abs }
         .map    { |attrs| offset_adjustment = attrs.center.x - horizontal_center }
    CGPoint.new(proposed_cont_offset.x + offset_adjustment, proposed_cont_offset.y)
  end
end
