class ConferenceHeader < UICollectionReusableView
  
  MARGIN_HORIZONTAL_LARGE = 20
  MARGIN_HORIZONTAL_SMALL = 10
  MARGIN_VERTICAL_LARGE = 5
  MARGIN_VERTICAL_SMALL = 3
  
  attr_reader :small, :background_set, :center_text
  attr_accessor :conference_name_label
  
  def initWithFrame(frame)
    super.tap do |header|
      header.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin
      @conference_name_label =  UILabel.alloc.init.tap do |cnl|
         cnl.font = UIFont.fontWithName("Courier-Bold", size:17)
         cnl.textColor = UIColor.blackColor
         cnl.textAlignment = NSTextAlignmentCenter
      end
      
      header.create_background_view
      header.addSubview(@conference_name_label)
      @small = false
      @center_text = false
    end
  end
    
  def applyLayoutAttributes(conf_attrs)
    if conf_attrs.is_a?(ConferenceLayoutAttributes)
      @center_text = conf_attrs.headerTextAlignment == NSTextAlignmentCenter
    end
  end
  
  def create_background_view
    @background_view ||= MaskingTapeView.alloc.initWithFrame(@conference_name_label.bounds).tap do |bgv|
      self.insertSubview(bgv, belowSubview:@conference_name_label)
      @conference_name_label.backgroundColor = UIColor.clearColor
    end
  end
  
  def horizontalMargin
    self.small ? MARGIN_HORIZONTAL_SMALL : MARGIN_HORIZONTAL_LARGE
  end
  
  def verticalMargin
    self.small ? MARGIN_VERTICAL_SMALL : MARGIN_VERTICAL_LARGE
  end
  
  def layoutSubviews
    @conference_name_label.sizeToFit
    label_bounds = CGRectInset(@conference_name_label.bounds, -self.horizontalMargin, -self.verticalMargin)
    if @center_text
        @conference_name_label.bounds = CGRect.new(CGPoint.new, label_bounds.size)
        @conference_name_label.center = CGPoint.new(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
    else
      left_margin = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? 20 : 5
      rect = CGRect.new([left_margin, ((self.bounds.size.height - label_bounds.size.height)/2).round.to_f], label_bounds.size)
      @conference_name_label.frame = rect
    end
    @background_view.frame = @conference_name_label.frame
  end
  
  def center_text=(flag)
    @center_text = flag
    self.setNeedsLayout
  end
  
  def conference=(new_conference)
    self.create_background_view
    @conference_name_label.text = new_conference.name
    self.layoutSubviews
  end
end