class StacksLayout < UICollectionViewLayout
  MINIMUM_INTERSTACK_SPACING_IPAD   = 50.0
  MINIMUM_INTERSTACK_SPACING_IPHONE = 20.0
  STACKS_LEFT_MARGIN   = 20.0
  STACKS_TOP_MARGIN    = 20.0
  STACKS_RIGHT_MARGIN  = -20.0
  STACKS_BOTTOM_MARGIN = 20.0
  STACK_WIDTH      = 180.0
  STACK_HEIGHT     = 180.0
  STACK_FOOTER_GAP = 8.0  
  ITEM_SIZE = 170.0
  MIN_PINCH_SCALE = 1.0
  MAX_PINCH_SCALE = 4.0
  FADE_PROGRESS = 0.75
  STACK_FOOTER_HEIGHT     = 25.0
  VISIBLE_ITEMS_PER_STACK = 3
  
  attr_accessor :pinching, :collapsing; alias_method :pinching?, :pinching; alias_method :collapsing?, :collapsing
  
  def stack?; true; end
  
  def init
    super.tap do
      iPad = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
      @min_inter_stack_spacing = iPad ? MINIMUM_INTERSTACK_SPACING_IPAD : MINIMUM_INTERSTACK_SPACING_IPHONE
      @min_line_spacing = @min_inter_stack_spacing
      @stacks_insets = UIEdgeInsets.new(STACKS_TOP_MARGIN, STACKS_LEFT_MARGIN, STACKS_BOTTOM_MARGIN, STACKS_RIGHT_MARGIN)
      @stack_size = CGSize.new(STACK_WIDTH, STACK_HEIGHT)
      @number_of_stack_rows = @number_of_stacks_across = 0
      @content_size = CGSize.new
      @pinched_stack_scale = @pinched_stack_index = -1
    end
  end
  
  # UICollectionViewLayout
  def shouldInvalidateLayoutForBoundsChange(old_bounds)
    !CGSizeEqualToSize(old_bounds.size, @page_size)
  end
  
  def self.layoutAttributesClass
    ConferenceLayoutAttributes
  end
  
  def pinchedStackIndex
    @pinched_stack_index
  end
  
  def pinchedStackScale
    @pinched_stack_scale
  end
  
  def pinchedStackCenter
    @pinched_stack_center
  end
  
  def collectionViewContentSize
    @content_size
  end
  
  def prepareLayout
    super
    prepareStacksLayout # calculate everything!
    prepareItemsLayout if self.pinching?
  end
  
  def layoutAttributesForItemAtIndexPath(path)
    ConferenceLayoutAttributes.layoutAttributesForCellWithIndexPath(path).tap do |attrs|
      stack_frame = @stack_frames[path.section].CGRectValue
      attrs.size = CGSize.new(ITEM_SIZE, ITEM_SIZE)
      attrs.center = CGPoint.new(CGRectGetMidX(stack_frame), CGRectGetMidY(stack_frame))
      angle = if path.item == 1
                5
              elsif path.item == 2
                -5
              else 
                0
              end
              
      attrs.transform3D = CATransform3DMakeRotation(angle * Math::PI / 180, 0, 0, 1)
      attrs.alpha  = path.item >= VISIBLE_ITEMS_PER_STACK ? 0 : 1
      attrs.zIndex = path.item >= VISIBLE_ITEMS_PER_STACK ? 0 : VISIBLE_ITEMS_PER_STACK - path.item
      attrs.hidden = @collapsing ? false : path.item >= VISIBLE_ITEMS_PER_STACK
      attrs.shadowOpacity = path.item >= VISIBLE_ITEMS_PER_STACK ? 0 : 0.5
    
      if self.pinching?
        # convert pinch scale to progress: 0 to 1
      
        progress = calc_progress
        
        if path.section == @pinched_stack_index
          item_count = @item_frames.count
          if path.item < item_count
            item_frame = @item_frames[path.item].CGRectValue
            new_x = attrs.center.x * (1 - progress) + CGRectGetMidX(item_frame) * progress
            new_y = attrs.center.y * (1 - progress) + CGRectGetMidY(item_frame) * progress
          
            attrs.center = CGPoint.new(new_x, new_y)
            angle *= (1 - progress)
            attrs.transform3D = CATransform3DMakeRotation(angle * Math::PI / 180, 0, 0, 1)
            attrs.alpha = 1
            attrs.zIndex = item_count + VISIBLE_ITEMS_PER_STACK - path.item
            attrs.hidden = false
            attrs.shadowOpacity = 0.5 * progress if path.item >= VISIBLE_ITEMS_PER_STACK
          end
        else
          unless attrs.hidden?
            attrs.alpha = progress >= FADE_PROGRESS ? 0 : 1 - (progress / FADE_PROGRESS)
          end
        end
      end
    end
  end
  
  def layoutAttributesForSupplementaryViewOfKind(kind, atIndexPath:path)
    return nil unless kind == SmallConferenceHeader.kind
    UICollectionViewLayoutAttributes.layoutAttributesForSupplementaryViewOfKind(kind, withIndexPath:path).tap do |attrs|
      attrs.size = CGSize.new(STACK_WIDTH, STACK_FOOTER_HEIGHT)
      stack_frame = @stack_frames[path.section].CGRectValue
      attrs.center = CGPoint.new(CGRectGetMidX(stack_frame), CGRectGetMaxY(stack_frame) + STACK_FOOTER_GAP + (STACK_FOOTER_HEIGHT/2))
      if self.pinching?
        # convert pinch scale to progress: 0 to 1
        progress = calc_progress
        attrs.alpha =  progress >= FADE_PROGRESS ? 0 : 1 - (progress/FADE_PROGRESS)
      end
    end
  end
  
  def layoutAttributesForElementsInRect(rect)
    [].tap do |attrs|
      @stack_frames.each_with_index do |stack, idx|
        stack_frame = stack.CGRectValue
        stack_frame.size.height += (STACK_FOOTER_GAP + STACK_FOOTER_HEIGHT)
        if CGRectIntersectsRect(stack_frame, rect)
          item_count = self.collectionView.numberOfItemsInSection(idx)
          item_count.times { |item_index| attrs << self.layoutAttributesForItemAtIndexPath(NSIndexPath.indexPathForItem(item_index, inSection:idx)) }
          attrs << self.layoutAttributesForSupplementaryViewOfKind(SmallConferenceHeader.kind, atIndexPath:NSIndexPath.indexPathForItem(0, inSection:idx))
        end
      end
    end
  end
  
  # Properties
  def pinchedStackScale=(new_scale)
    @pinched_stack_scale = new_scale
    self.invalidateLayout
  end
      
  def pinchedStackCenter=(new_center)
    @pinched_stack_center = new_center
    self.invalidateLayout
  end
  
  def pinchedStackIndex=(new_index)  
    @pinched_stack_index = new_index
    was_pinching  = @pinching
    self.pinching = new_index >= 0
    unless self.pinching == was_pinching
      @grid_layout = @pinching ?  GridLayout.alloc.init : nil                    
    end
    self.invalidateLayout
  end
  
  private
  # Private Instance Methods
  def prepareStacksLayout
    @number_of_stacks = self.collectionView.numberOfSections
    @page_size = self.collectionView.bounds.size
    
    avail_width = @page_size.width - @stacks_insets.left + @stacks_insets.right
    @number_of_stacks_across = ((avail_width + @min_inter_stack_spacing) / (@stack_size.width + @min_inter_stack_spacing)).floor
    spacing = ((avail_width - (@number_of_stacks_across * @stack_size.width)) / (@number_of_stacks_across - 1).floor)
    @number_of_stack_rows = (@number_of_stacks / @number_of_stacks_across.to_f).ceil
    
    @stack_frames = []
    stack_column = stack_row = 0
    left = @stacks_insets.left
    top  = @stacks_insets.top
    
    @number_of_stacks.times do |stack|
      stack_frame = CGRect.new([left, top], @stack_size)
      @stack_frames << NSValue.valueWithCGRect(stack_frame)
      
      left += @stack_size.width + spacing
      stack_column += 1
      
      if stack_column >= @number_of_stacks_across
        left = @stacks_insets.left
        top += @stack_size.height + STACK_FOOTER_GAP + STACK_FOOTER_HEIGHT + @min_line_spacing
        stack_column = 0
        stack_row += 1
      end
    end
    height = [@page_size.height, @stacks_insets.top + (@number_of_stack_rows * 
              (@stack_size.height + STACK_FOOTER_GAP + STACK_FOOTER_HEIGHT)) + 
              ((@number_of_stack_rows - 1) * @min_line_spacing) + @stacks_insets.bottom].max
    @content_size = CGSize.new(@page_size.width, height)
  end
  
  def prepareItemsLayout
    @item_frames = []
    number_of_items = self.collectionView.numberOfItemsInSection(@pinched_stack_index)
    
    avail_width = @page_size.width - (@grid_layout.sectionInset.left + @grid_layout.sectionInset.right)
    number_of_items_across = ((avail_width + @grid_layout.minimumInteritemSpacing) / 
                              (@grid_layout.itemSize.width + @grid_layout.minimumInteritemSpacing)).floor
    spacing = ((avail_width - (number_of_items_across * @grid_layout.itemSize.width)) / (number_of_items_across - 1))
    
    column = row = 0
    left = @grid_layout.sectionInset.left
    top  = @grid_layout.sectionInset.top
    number_of_items.times do |item|
      item_frame = CGRect.new([left, top + self.collectionView.contentOffset.y], @grid_layout.itemSize)
      @item_frames << NSValue.valueWithCGRect(item_frame)
      
      left += @grid_layout.itemSize.width + spacing
      column += 1
      
      if column >= number_of_items_across
        left = @grid_layout.sectionInset.left
        top += @grid_layout.itemSize.height + @grid_layout.minimumLineSpacing
        column = 0
        row += 1
      end
      break if top >= @page_size.height
    end
    
    number_of_item_rows = (@item_frames.count / number_of_items_across).ceil.to_f
    height = @grid_layout.sectionInset.top + (number_of_item_rows * @grid_layout.itemSize.height) + 
            ((number_of_item_rows - 1) * @grid_layout.minimumLineSpacing) + @grid_layout.sectionInset.bottom
    item_content_size = CGSize.new(@page_size.width, height)
    stack_content_size = @content_size
    @content_size = CGSize.new([item_content_size.width, stack_content_size.width].max, [item_content_size.height, stack_content_size.height].max)
  end
  
  def calc_progress
    if @pinched_stack_scale
      [[(@pinched_stack_scale - MIN_PINCH_SCALE) / (MAX_PINCH_SCALE - MIN_PINCH_SCALE), 0].max, 1].min
    else
      0
    end
  end
end