class SpiralLayout < UICollectionViewLayout
  ITEM_SIZE = 170
  
  def prepareLayout
    super
    @page_size = self.collectionView.frame.size
    ipad = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
    scale_factor = ipad ? 1 : 0.5
    @radius = [(@page_size.width - (ITEM_SIZE * scale_factor)), (@page_size.height - (ITEM_SIZE * scale_factor)) * 1.2].min / 2 - 5
    
    @page_count = self.collectionView.numberOfSections
    
    @cell_counts = Array.new(@page_count) { |section| self.collectionView.numberOfItemsInSection(section) }
    @page_rects  = Array.new(@page_count) { |section| NSValue.valueWithCGRect(CGRect.new([section * @page_size.width, 0], @page_size)) }
        
    @content_size = CGSize.new(@page_size.width * @page_count, @page_size.height)
  end
  
  
  def collectionViewContentSize
    @content_size
  end
  
  
  def self.layoutAttributesClass
    ConferenceLayoutAttributes
  end
  
  
  def shouldInvalidateLayoutForBoundsChange(new_bounds)
    !CGSizeEqualToSize(@page_size, new_bounds.size)
  end
  
  
  def layoutAttributesForItemAtIndexPath(path)
    UICollectionViewLayoutAttributes.layoutAttributesForCellWithIndexPath(path).tap do |attrs|
      attrs.size = CGSize.new(ITEM_SIZE, ITEM_SIZE)
        
      count = self.cellCountForSection(path.section)
      denominator = [count-1, 1].max
    
      page_rect = @page_rects[path.section].CGRectValue
      point = CGPoint.new(CGRectGetMidX(page_rect) + (@radius * path.item / denominator) * Math.cos(3 * path.item * Math::PI / denominator), 
                         CGRectGetMidY(page_rect) + (@radius * path.item / denominator) * Math.sin(3 * path.item * Math::PI / denominator))
      attrs.center = point
      attrs.zIndex = path.row
      ipad = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
      scale_factor = ipad ? 1 : 0.5
      scale = (0.25 + 0.75 * path.item / denominator) * scale_factor
      attrs.transform3D = CATransform3DMakeScale(scale, scale, 1)
    end
  end
  
  
  def layoutAttributesForSupplementaryViewOfKind(kind, atIndexPath:path)
    ConferenceLayoutAttributes.layoutAttributesForSupplementaryViewOfKind(kind, withIndexPath:path).tap do |attrs|
      page_rect    = @page_rects[path.section].CGRectValue
      attrs.size   = CGSize.new(page_rect.size.width, 50)
      attrs.center = CGPoint.new(CGRectGetMidX(page_rect), 35)
      attrs.headerTextAlignment = NSTextAlignmentCenter
    end
  end
  
  
  def cellCountForSection(section)
    @cell_counts[section].intValue
  end
  
  
  def layoutAttributesForElementsInRect(rect)
    attrs = []
    @page_rects.each_with_index do |page_rect, page_idx|
      if CGRectIntersectsRect(rect, page_rect.CGRectValue)
        cell_count = self.cellCountForSection(page_idx)
        cell_count.times { |idx| attrs << self.layoutAttributesForItemAtIndexPath(NSIndexPath.indexPathForItem(idx, inSection:page_idx))}
        # add header
        path = NSIndexPath.indexPathForItem(0, inSection:page_idx)
        attrs << self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath:path)
      end
    end
    attrs
  end
  
  
  def targetContentOffsetForProposedContentOffset(prop_content_offset, withScrollingVelocity:velocity)
    closest_page = (prop_content_offset.x / @page_size.width).round.to_i
    closest_page = 0 if closest_page < 0
    closest_page = @page_count - 1 if closest_page >= @page_count
    CGPoint.new(closest_page * @page_size.width, prop_content_offset.y)
  end
  
  
  def prepareForCollectionViewUpdates(update_items)
    super
    @delete_index_paths = update_items.select { |update| update.updateAction == UICollectionUpdateActionDelete }
                                      .map    { |update| update.indexPathBeforeUpdate }
    @insert_index_paths = update_items.select { |update| update.updateAction == UICollectionUpdateActionInsert }
                                      .map    { |update| update.indexPathAfterUpdate }
  end
  
  
  def finalizeCollectionViewUpdates
    @delete_index_paths = nil
    @insert_index_paths = nil
  end
  
  
  def initialLayoutAttributesForAppearingItemAtIndexPath(path)
    attributes = super
    if @insert_index_paths.is_a?(Array) && @insert_index_paths.include?(path)
      # Configure attributes ...
      attributes ||= self.layoutAttributesForItemAtIndexPath(path)
      
      attributes.alpha  = 0.0
      attributes.zIndex = path.row
      page_rect    = @page_rects[path.section].CGRectValue
      attributes.center = CGPoint.new(CGRectGetMidX(page_rect), CGRectGetMidY(page_rect))
      attributes.transform3D = CATransform3DMakeScale(0.25, 0.25, 1)
    end
    attributes
  end
  
  
  def finalLayoutAttributesForDisappearingItemAtIndexPath(path)
    attributes = super
    if @delete_index_paths.is_a?(Array) && @delete_index_paths.include?(path)
      attributes ||= self.layoutAttributesForItemAtIndexPath(path)
      attributes.alpha  = 0.0
      attributes.center = CGPoint.new(attributes.center.x, 0 - ITEM_SIZE)
    end
    attributes
  end
end