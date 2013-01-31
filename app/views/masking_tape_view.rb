class MaskingTapeView < UIView
  ZIG_SIZE = 3
  
  def initWithFrame(frame)
    super.tap do
      self.backgroundColor = UIColor.clearColor
      @tape_color = UIColor.colorWithPatternImage(UIImage.imageNamed("Aged-Paper"))
    end
  end
  
  def drawRect(dirty_rect)
    # zig-zag edge like tap cut marks on left and right edges of label
    mask = UIBezierPath.bezierPath
    mask.moveToPoint(CGPoint.new)

    0.0.step(self.bounds.size.height, ZIG_SIZE) do |steps| 
      zig = steps.modulo(2).zero?
      point = CGPoint.new(zig ? ZIG_SIZE : 0, steps)
      mask.addLineToPoint(point)
    end

    point = CGPoint.new(self.bounds.size.width, self.bounds.size.height)
    mask.addLineToPoint(point)

    # zig-zag back up the right edge
    self.bounds.size.height.step(0.0, -ZIG_SIZE) do |steps| 
      zig = steps.modulo(2).zero?
      point = CGPoint.new(self.bounds.size.width - (zig ? ZIG_SIZE : 0), steps)
      mask.addLineToPoint(point)
    end
    
    mask.addLineToPoint(CGPoint.new)
    @tape_color.set
    mask.fill
  end
end