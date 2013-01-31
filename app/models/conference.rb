class Conference
  attr_accessor :name, :startDate, :durationDays, :speakers, :deletedSpeakers
  def initWithName(name, startDate:startDate, duration:durationDays, speakers:speakers)
    init.tap do |conf|
      @name = name
      @startDate = startDate
      @durationDays = durationDays
      @speakers = speakers
      @deletedSpeakers = []
    end
  end
  
  def self.conferenceWithName(name, startDate:startDate, duration: durationDays, speakers:speakers)
    Conference.alloc.initWithName(name, startDate:startDate, duration:durationDays, speakers:speakers)
  end
  
  def deleteSpeakerAtIndex(idx)
    return false if idx >= @speakers.count
    @deletedSpeakers << @speakers.delete_at(idx)
    true
  end
  
  def restoreSpeaker
    return false if @deletedSpeakers.count.zero?
    @speakers << @deletedSpeakers.delete_at(0)
    true
  end
end