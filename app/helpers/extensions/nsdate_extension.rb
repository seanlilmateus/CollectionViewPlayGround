class NSDate
  def self.dateWithYear(year, month:month, day:day)
    date_components = NSDateComponents.alloc.init
    date_components.year, date_components.month, date_components.day = year, month, day
    @calendar ||= NSCalendar.currentCalendar
    @calendar.dateFromComponents(date_components)
  end
end

