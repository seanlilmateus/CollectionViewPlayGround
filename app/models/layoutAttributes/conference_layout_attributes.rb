class ConferenceLayoutAttributes < UICollectionViewLayoutAttributes
  attr_accessor :headerTextAlignment, :shadowOpacity
  
  def init
    super.tap do
      @headerTextAlignment = NSTextAlignmentLeft
      @shadowOpacity       = 0.5
    end
  end
  
  def copyWithZone(zone)
    super.tap do |attrs|
      attrs.headerTextAlignment = self.headerTextAlignment
      attrs.shadowOpacity = self.shadowOpacity
      attrs
    end
  end
end
