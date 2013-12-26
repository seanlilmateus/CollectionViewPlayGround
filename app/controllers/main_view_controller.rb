class MainViewController < UICollectionViewController
  LAYOUT_GRID = 0
  LAYOUT_LINE = 1
  LAYOUT_COVERFLOW = 2
  LAYOUT_STACKS = 3
  LAYOUT_SPIRAL = 4
  LAYOUT_COUNT = 5
  
  def init
    super.tap { setup }
  end
  
  def canBecomeFirstResponder
    true
  end
  
  def initWithCollectionViewLayout(layout)
    super.tap { setup }
  end
  
  # starting from xib/Storyboards
  def initWithNibName(name, bundle:bundle)
    super.tap { setup }
  end
  
  # starting from xib/Storyboards
  def initWithCoder(decoder)
    super.tap { setup }
  end
  
  
  def viewDidLoad
    super
    self.collectionView.collectionViewLayout = GridLayout.alloc.init
    self.collectionView.backgroundColor = UIColor.colorWithPatternImage(UIImage.imageNamed("Wood-Planks"))
    
    # register collectionView cell
    self.collectionView.registerClass(SpeakerCell, forCellWithReuseIdentifier:Speaker::CELL_ID)
    
    # register section (conference) default header
    self.collectionView.registerClass(ConferenceHeader, 
           forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, 
                  withReuseIdentifier: CocoaConf::CONFERENCE_HEADER_ID)
    
    # register section (conference) small header
    self.collectionView.registerClass(SmallConferenceHeader, 
            forSupplementaryViewOfKind: SmallConferenceHeader.kind, 
                   withReuseIdentifier: CocoaConf::CONFERENCE_HEADER_SMALL_ID)
    
    # register section (conference) footer
    self.collectionView.registerClass(StarRatingFooter, 
            forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, 
                   withReuseIdentifier: CocoaConf::STAR_RATING_FOOTER_ID)
    
    # setup the collectionView Data Source 
    self.collectionView.dataSource = CocoaConf.all
    self.collectionView.allowsSelection = true
    
    create_tap_recognizer(1, 'handleTap:') # create UITapGestureRecognizer with one tap
    create_tap_recognizer(2, 'handle2FingerTap:') # create UITapGestureRecognizer with two taps
    create_tap_recognizer(3, 'handle3FingerTap:') # create UITapGestureRecognizer with three taps   
    
    pinch = UIPinchGestureRecognizer.alloc.initWithTarget(self, action:'handlePinch:')
    self.collectionView.addGestureRecognizer(pinch)
    
    UISwipeGestureRecognizer.alloc.initWithTarget(self, action:'handleSwipeUp:').tap do |swipeUp|
      swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
      self.collectionView.addGestureRecognizer(swipeUp)
    end
  end
  
  def collectionView(clv, didSelectItemAtIndexPath:indexPath)
    return unless @layout_style == LAYOUT_COVERFLOW || @layout_style == LAYOUT_LINE
    clv.scrollToItemAtIndexPath(indexPath, atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally, animated:true)
    clv.deselectItemAtIndexPath(indexPath, animated:true)
  end
  
  def collectionView(clv, shouldDeselectItemAtIndexPath:indexPath)
    true
  end
  
  def collectionView(clv, shouldSelectItemAtIndexPath:indexPath)
    true
  end
  
  
  def changeToLayout(layout, animated:animated)
    return if @layout_style == layout
    reload_data = false
    delayed_reload = false
    new_layout = case layout
                 when LAYOUT_GRID
                   GridLayout.alloc.init
                 when LAYOUT_LINE
                   delayed_reload = true
                   CoverFlowLayout.alloc.init
                 when LAYOUT_COVERFLOW
                   delayed_reload = true
                   LineLayout.alloc.init
                 when LAYOUT_STACKS
                   reload_data = true
                   StacksLayout.alloc.init
                 when LAYOUT_SPIRAL
                   SpiralLayout.alloc.init
                 end

    new_layout.invalidateLayout
    @layout_style = layout
    flag = (animated && !reload_data)

    self.collectionView.setCollectionViewLayout(new_layout, animated:true)
    
    if reload_data
      self.collectionView.reloadData
    elsif delayed_reload
      Dispatch::Queue.main.after(0.5) { self.collectionView.reloadData }
    end
    
    unless layout == LAYOUT_STACKS
      # Find all the leftover supplementary views (Small Headers)
      # remove them from the view hierarchy
      self.collectionView.subviews.select { |subview| subview.is_a?(SmallConferenceHeader) }
                                  .map    { |subview| subview.removeFromSuperview }
    end
  end
  
  def layoutSupportsInsert
    @layout_style == LAYOUT_SPIRAL
  end
    
  def layoutSupportsDelete
    @layout_style == LAYOUT_SPIRAL
  end
  
  # one tap (UITapGestureRecognizer) gesture handler
  def handleTap(gesture)
    point = gesture.locationInView(self.collectionView)
    
    unless self.layoutSupportsInsert
      indexPath = self.collectionView.indexPathForItemAtPoint(point)
      delegate = self.collectionView.delegate
      if delegate.respond_to?('collectionView:didSelectItemAtIndexPath:')
        delegate.collectionView(self.collectionView, didSelectItemAtIndexPath:indexPath)
      end
      return
    end
    
    number_of_sections = self.collectionView.numberOfSections

    number_of_sections.times do |section|
      
      kind = @layout_style == LAYOUT_STACKS ? SmallConferenceHeader.kind : UICollectionElementKindSectionHeader
      clv_layout = self.collectionView.collectionViewLayout
      
      indexPath = NSIndexPath.indexPathForItem(0, inSection:section)
      attrs = clv_layout.layoutAttributesForSupplementaryViewOfKind(kind, atIndexPath:indexPath)
            
      if attrs && CGRectContainsPoint(attrs.frame, point)
        number_of_speakers = self.collectionView.numberOfItemsInSection(section)
        cocoa_conf = self.collectionView.dataSource
        if (cocoa_conf.restoreSpeakerInSection(section))
          if number_of_speakers.zero?
            self.collectionView.reloadData
          else
            indexPath = NSIndexPath.indexPathForItem(number_of_speakers, inSection:section)
            self.collectionView.insertItemsAtIndexPaths([indexPath])
          end
        end
        break
      end 
    end
  end
  
  
  # two taps (UITapGestureRecognizer) gesture handler
  def handle2FingerTap(gesture)
    layout = @layout_style + 1
    layout = 0 if layout >= LAYOUT_COUNT
    self.changeToLayout(layout, animated:true)
  end
  
  
  # three taps (UITapGestureRecognizer) gesture handler
  def handle3FingerTap(gesture)
    layout = @layout_style - 1
    layout = LAYOUT_COUNT - 1 if layout < 0
    self.changeToLayout(layout, animated:true)
  end
  
  
  def handlePinch(gesture)
    if @layout_style == LAYOUT_STACKS
      pinch_on_stacks(gesture)
    elsif @layout_style == LAYOUT_GRID
      pinch_on_grid(gesture)
    end
  end
  
  def pinch_on_grid(gesture)
    if (gesture.velocity < 0)
        puts :close_pinch
    elsif (gesture.velocity > 0)
      puts :open_pinch
    end
  end
  
  
  def pinch_on_stacks(gesture)
    stacks_layout = self.collectionView.collectionViewLayout
    
    if gesture.state == UIGestureRecognizerStateBegan
      initial_pinch_point = gesture.locationInView(self.collectionView)
      pinched_cell_path   = self.collectionView.indexPathForItemAtPoint(initial_pinch_point)
      stacks_layout.pinchedStackIndex = pinched_cell_path.section if pinched_cell_path
      
    elsif gesture.state == UIGestureRecognizerStateChanged
      stacks_layout.pinchedStackScale  = gesture.scale
      stacks_layout.pinchedStackCenter = gesture.locationInView(self.collectionView)
      
    else
      if (stacks_layout.pinchedStackIndex >= 0)
        if stacks_layout.pinchedStackScale > 2.5
          self.changeToLayout(LAYOUT_GRID, animated:true) # switch to GridLayout
        else
          # Find all the supplementary views
          small_header_to_remove = self.collectionView.subviews.select { |subview| subview.is_a?(SmallConferenceHeader) } 
          stacks_layout.collapsing = true
          self.collectionView.performBatchUpdates(-> {
            stacks_layout.pinchedStackIndex = -1
            stacks_layout.pinchedStackScale = 1.0
          }, completion:-> _ {
            stacks_layout.collapsing = false
            # remove them from the view hierarchy
            small_header_to_remove.map(&:removeFromSuperview)
          })
        end
      end
    end
  end
  
  
  def handleSwipeUp(gesture)
    return unless self.layoutSupportsDelete
    start_point = gesture.locationInView(self.collectionView)
    cell_path   = self.collectionView.indexPathForItemAtPoint(start_point)
    
    if cell_path
      cocoa_conf = self.collectionView.dataSource
      speaker_count = self.collectionView.numberOfItemsInSection(cell_path.section)
      if cocoa_conf.deleteSpeakerAtPath(cell_path)        
        if speaker_count <= 1
          self.collectionView.reloadData
        else
          self.collectionView.deleteItemsAtIndexPaths([cell_path])
        end
      end
    end
  end
  
  private
  def setup
    @layout_style = LAYOUT_GRID
  end
  
  def create_tap_recognizer(number_of_taps, action_handler)
    UITapGestureRecognizer.alloc.initWithTarget(self, action:action_handler).tap do |the_tap| 
      the_tap.numberOfTouchesRequired = number_of_taps
      self.view.addGestureRecognizer(the_tap)
    end
  end
end
