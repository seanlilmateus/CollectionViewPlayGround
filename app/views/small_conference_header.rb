class SmallConferenceHeader < ConferenceHeader
  
  def initWithFrame(frame)
    super.tap do |header|
      @small = true
      @center_text = true
      @conference_name_label.font = UIFont.fontWithName("Courier-Bold", size:13)
    end
  end
  
  SMALL_HEADER_KIND = "ConferenceHeaderSmall"
  def self.kind
    SMALL_HEADER_KIND
  end
end
