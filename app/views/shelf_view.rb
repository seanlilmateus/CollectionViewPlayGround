class ShelfView < UICollectionReusableView
  
  def initWithFrame(frame)
    super.tap do |sv|
      sv.backgroundColor = UIColor.colorWithPatternImage(UIImage.imageNamed("Apple-Wood"))
      sv.layer.shadowOpacity = 0.5
      sv.layer.shadowOffset = CGSize.new(0, 5)
    end
  end
  
  def layoutSubviews
    shadow_bounds = CGRect.new([0, -5], [self.bounds.size.width, self.bounds.size.height + 5])
    self.layer.shadowPath = UIBezierPath.bezierPathWithRect(shadow_bounds).CGPath
  end
  
  SHELF_VIEW_KIND = "ShelfView"
  def self.kind
    SHELF_VIEW_KIND
  end
end