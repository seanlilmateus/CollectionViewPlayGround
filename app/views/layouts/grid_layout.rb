class GridLayout < UICollectionViewFlowLayout
  def self.layoutAttributesClass
    ConferenceLayoutAttributes
  end
  
  def init
    super.tap do
      self.scrollDirection = UICollectionViewScrollDirectionVertical
      self.itemSize = CGSize.new(170, 197)
      self.sectionInset = UIEdgeInsetsMake(4, 10, 14, 10)
      size = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? CGSize.new(50, 50) : CGSize.new(43, 43)
      self.headerReferenceSize = size
      self.footerReferenceSize = CGSize.new(44, 44) #// 88
      self.minimumInteritemSpacing = 10
      self.minimumLineSpacing = 10
      self.registerClass(ShelfView, forDecorationViewOfKind:ShelfView.kind)
      @shelf_rects = {}
    end
  end
    
  # Return attributes of all items (cells, supplementary views, decoration views) that appear within this rect
  def layoutAttributesForElementsInRect(rect)
    array = super
    array.map { |attrs| attrs.zIndex = 1 }
  
    # make label vertical if scrolling is horizontal
    array.select { |attrs| self.scrollDirection == UICollectionViewScrollDirectionHorizontal && attrs.representedElementCategory == UICollectionElementCategorySupplementaryView }
         .map do |attrs|
           attrs.transform3D = CATransform3DMakeRotation(-90 * Math::PI / 180, 0, 0, 1) 
           attrs.size = CGSizeMake(attrs.size.height, attrs.size.width)
         end
       
    array.select { |attrs| attrs.representedElementCategory == UICollectionElementCategorySupplementaryView && attrs.is_a?(ConferenceLayoutAttributes) }
         .map    { |attrs| attrs.headerTextAlignment = NSTextAlignmentLeft }
  
    # Add our decoration views (shelves)
    new_array = array.mutableCopy
    @shelf_rects.select { |key, value| CGRectIntersectsRect(value.CGRectValue, rect) }
                .map do |key, value|
                  attrs = UICollectionViewLayoutAttributes.layoutAttributesForDecorationViewOfKind(ShelfView.kind, withIndexPath:key)
                  attrs.frame = value.CGRectValue
                  attrs.zIndex = 0
                  new_array.addObject(attrs)
                end
              
    NSArray.arrayWithArray(new_array)
  end

  def prepareLayout
    super
    dictionary = {}
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical)
      number_of_sections = self.collectionView.numberOfSections
      y = 0.0
      avail_width = self.collectionViewContentSize.width - (self.sectionInset.left + self.sectionInset.right)
      items_across = ((avail_width + self.minimumInteritemSpacing) / (self.itemSize.width + self.minimumInteritemSpacing)).floor
      number_of_sections.times do |section|
        y += self.headerReferenceSize.height
        y += self.sectionInset.top
        
        item_count = self.collectionView.numberOfItemsInSection(section)
        
        rows = (item_count / items_across.to_f).ceil
        rows.times do |row|
          y += self.itemSize.height
          hash_value = NSValue.valueWithCGRect(CGRect.new([0, y - 32], [self.collectionViewContentSize.width, 37]))
          dictionary[NSIndexPath.indexPathForItem(row, inSection:section)] = hash_value
          y += self.minimumLineSpacing if row < rows - 1
        end
        
        y += self.sectionInset.bottom
        y += self.footerReferenceSize.height
      end
    else
      y = self.sectionInset.top
      avail_height = self.collectionViewContentSize.height - (self.sectionInset.top + self.sectionInset.bottom)
      items_across = ((avail_height + self.minimumInteritemSpacing)/(self.itemSize.height + self.minimumInteritemSpacing)).floor
      interval = ((avail_height - self.itemSize.height) / (items_across <= 1 ? 1 : items_across - 1)) - self.itemSize.height
      items_across.times do |row|
        y += self.itemSize.height
        hash_value = NSValue.valueWithCGRect(CGRectMake(0, (y - 32).round.to_f, self.collectionViewContentSize.width, 37))
        dictionary[NSIndexPath.indexPathForItem(row, inSection:0)] = hash_value
        y += interval
      end
    end

    @shelf_rects = dictionary
  end
  
  def layoutAttributesForItemAtIndexPath(path)
    super.tap { |attrs| attrs.zIndex = 1 }
  end
  
  def layoutAttributesForSupplementaryViewOfKind(kind, atIndexPath:path)
    return nil if kind == SmallConferenceHeader.kind
    attrs = super
    attrs.zIndex = 1
    if self.scrollDirection == UICollectionViewScrollDirectionHorizontal
      # make label vertical if scrolling is horizontal
      attrs.transform3D = CATransform3DMakeRotation(-90 * Math::PI / 180, 0, 0, 1)
      attrs.size = CGSize.new(attrs.size.height, attrs.size.width)
    end          
    attrs.headerTextAlignment = NSTextAlignmentLeft if attrs.is_a?(ConferenceLayoutAttributes)
    attrs
  end
  
  # layout attributes for a specific decoration view
  def layoutAttributesForDecorationViewOfKind(decorationViewKind, atIndexPath:indexPath)
    shelf_rect = @shelf_rects[indexPath]
    return unless shelf_rect
    UICollectionViewLayoutAttributes.layoutAttributesForDecorationViewOfKind(ShelfView.kind, withIndexPath:indexPath).tap do |attrs|
      attrs.frame = shelf_rect.CGRectValue
      attrs.zIndex = 0 # shelves go behind other views
    end
  end
end
