class SpeakerCell < UICollectionViewCell
  attr_accessor :name_label, :speaker_image
    
  def initWithFrame(frame)
    super.tap do |cell|
      cell.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
      @speaker_image =  UIImageView.alloc.initWithFrame([[4, 4], [self.frame.size.width, 162]]).tap do |imgv|
        #imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin
        imgv.backgroundColor = UIColor.clearColor
        cell.contentView.addSubview(imgv)
      end
      
      @name_label = UILabel.alloc.initWithFrame([[4, 173], [self.frame.size.width, 21]]).tap do |label|
         #label.translatesAutoresizingMaskIntoConstraints = false
         label.numberOfLines = 0
         label.font = UIFont.boldSystemFontOfSize(17.0)
         label.textAlignment = UITextAlignmentCenter
         label.backgroundColor = UIColor.clearColor
         label.textColor = UIColor.whiteColor
         label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
         cell.contentView.addSubview(label)
      end
      
      cell.contentView.backgroundColor = UIColor.underPageBackgroundColor
      cell.contentView.autoresizesSubviews = true
      cell.contentView.backgroundColor = UIColor.clearColor
    end
  end
    
  def hidde_name!(flag)
    UIView.animateWithDuration(0.0, animations:-> { @name_label.alpha = flag ? 0.0 : 1.0 })
  end
  
  def speaker_name=(speaker_name)
    unless @speaker_name == speaker_name
      @speaker_name = speaker_name
      @name_label.text     = speaker_name
      @speaker_image.image = AnimationHelper.renderImage(UIImage.imageNamed(speaker_name), withMargin:10.0, color:UIColor.whiteColor)
    end
  end
  
  def willMoveToSuperview(new_superview)
    super
    if new_superview
      @speaker_image.layer.shadowOpacity = 0.5
      @speaker_image.layer.shadowOffset  = CGSize.new(0, 3)
      @speaker_image.layer.shadowPath    = UIBezierPath.bezierPathWithRect(CGRectInset(@speaker_image.bounds, 1, 1)).CGPath
    end
  end
  # cell.name_label.alpha = clv.collectionViewLayout.is_a?(StacksLayout) ? 0.0 : 1.0
  # 
  def applyLayoutAttributes(conference_attrs)
    if conference_attrs.is_a?(ConferenceLayoutAttributes)
      @speaker_image.layer.shadowOpacity = conference_attrs.shadowOpacity
    end
  end
  
  def willTransitionFromLayout(old_layout, toLayout:new_layout)
    @name_label.alpha = 0.0 if new_layout.is_a?(StacksLayout)
    @name_label.alpha = 1.0 if old_layout.is_a?(StacksLayout)
  end
end
