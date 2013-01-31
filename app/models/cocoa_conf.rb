class CocoaConf
  CONFERENCE_HEADER_ID = "ConferenceHeader"
  CONFERENCE_HEADER_SMALL_ID = "ConferenceHeaderSmall"
  STAR_RATING_FOOTER_ID = "StarRatingFooter"
  
  
  def initWithConferences(*conferences)
    init.tap { @conferences = conferences }
  end
  
  # UICollectionViewDataSource
  def numberOfSectionsInCollectionView(clv)
    @conferences.count
  end
  
  def collectionView(clv, numberOfItemsInSection:section)
    return 0 if section < 0 || section >= @conferences.count
    @conferences[section].speakers.count
  end
  
  def collectionView(clv, cellForItemAtIndexPath:path)
    clv.dequeueReusableCellWithReuseIdentifier(Speaker::CELL_ID, forIndexPath:path).tap do |cell|
      cell.speaker_name = @conferences[path.section].speakers[path.item]
      cell.hidde_name!(clv.collectionViewLayout.is_a?(StacksLayout))
    end
  end
  
  def collectionView(clv, viewForSupplementaryElementOfKind:kind, atIndexPath:path)
    section = path.section
    if kind == UICollectionElementKindSectionFooter
      return clv.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier:STAR_RATING_FOOTER_ID, forIndexPath:path)
    end
    
    small = kind == SmallConferenceHeader.kind # ConferenceHeaderSmall
    identifier =  small ? CONFERENCE_HEADER_SMALL_ID : CONFERENCE_HEADER_ID
    clv.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier:identifier, forIndexPath:path).tap do |header|
      header.conference = @conferences[section]
    end
  end
  
  def deleteSpeakerAtPath(path)
    return false if path.section < 0 || path.section >= @conferences.count
    conference = @conferences[path.section]
    conference.deleteSpeakerAtIndex(path.item)
  end
  
  def restoreSpeakerInSection(section)
    return false if path.section < 0 || path.section >= @conferences.count
    conference = @conferences[path.section]
    conference.restoreSpeaker
  end
  
  # Private Class Methods
  class << self
    def columbus2011
      Conference.conferenceWithName("CocoaConf Columbus 2011", 
                          startDate: NSDate.dateWithYear(2011, month:8, day:11),
                           duration: 3, 
                           speakers: ["Chris Adamson", "Randy Beiter", "Craig Castelaz", 
                                      "Mark Dalrymple", "Bill Dudney", "Mark Gilicinski", 
                                      "Chris Judd", "Dave Koziol", "Mac Liaw", "Steve Madsen", 
                                      "Jonathan Penn", "Doug Sjoquist", "Josh Smith", "Daniel Steinberg"])
    end
    
    def raleigh2011
      Conference.conferenceWithName("CocoaConf Raleigh 2011", 
                          startDate: NSDate.dateWithYear(2011, month:12, day:1), 
                           duration: 3,
                           speakers: ["Chris Adamson", "Jeff Biggus", "Collin Donnell", 
                                      "Bill Dudney", "Nathan Eror", "Andy Hunt", "Andria Jensen", 
                                      "Josh Johnson", "Chris Judd", "Saul Mora", "Jonathan Penn", 
                                      "Jared Richardson", "Josh Smith", "Daniel Steinberg"])
    end
    
    def chicago2012
      Conference.conferenceWithName("CocoaConf Chicago 2012", 
                          startDate: NSDate.dateWithYear(2012, month:3, day:15), 
                           duration: 3,
                           speakers: ["Chris Adamson", "Randy Beiter", "Jeff Biggus", "Jonathan Blocksom", 
                                      "Heath Borders", "Brian Coyner", "Bill Dudney", "Dave Koziol", "Brad Larson", 
                                      "Eric Meyer", "Jonathan Penn", "Boisy Pitre", "Mark Pospesel", "Josh Smith", 
                                      "Daniel Steinberg", "Whitney Young"])
                  
    end
    
    def dc2012
      Conference.conferenceWithName("CocoaConf DC 2012", startDate: NSDate.dateWithYear(2012, month:6, day:28), 
                          duration: 3, 
                          speakers: ["Chris Adamson", "Mike Ash", "Jonathan Blocksom", "Step Christopher", 
                                     "Mark Dalrymple", "Jason Hunter", "Chris Judd", "Jonathan Lehr", "Scott McAlister", 
                                     "Saul Mora", "Jonathan Penn", "Mark Pospesel", "Jonathan Saggau", "Chad Sellers", "David Smith", 
                                     "Daniel Steinberg", "Walter Tyree", "Whitney Young"])
    end
    
    def columbus2012
      Conference.conferenceWithName("CocoaConf Columbus 2012", 
                          startDate: NSDate.dateWithYear(2012, month:9, day:11), 
                           duration: 3,
                           speakers: ["Josh Abernathy", "Chris Adamson", "Randy Beiter", "Brian Coyner", 
                                      "Mark Dalrymple", "Bill Dudney", "Jason Felice", "Geoff Goetz", 
                                      "Chris Judd", "Jeff Kelley", "Dave Koziol", "Steve Madsen", "Kevin Munc", 
                                      "Jaimee Newberry", "Jonathan Penn", "Doug Sjoquist", "Josh Smith", "Daniel Steinberg", 
                                      "Mattt Thompson"])
    end
    
    def portland2012
      Conference.conferenceWithName("CocoaConf Portland 2012", 
                          startDate: NSDate.dateWithYear(2012, month:10, day:25), 
                           duration: 3, 
                           speakers: ["Josh Abernathy", "Chris Adamson", "Tim Burks", "James Dempsey", 
                                      "Collin Donnell", "Pete Hodgson", "Andria Jensen", "Justin Miller", "Saul Mora", 
                                      "Jaimee Newberry", "Janine Ohmer", "Daniel Pasco", "Jonathan Penn", "Mark Pospesel", 
                                      "Ben Scheirman", "Brent Simmons", "Josh Smith", "Daniel Steinberg", "Elizabeth Taylor", 
                                      "Mattt Thompson"])
    end
    
    def raleigh2012
      Conference.conferenceWithName("CocoaConf Raleigh 2012", 
                          startDate: NSDate.dateWithYear(2012, month:11, day:29), 
                           duration: 3, 
                           speakers: ["Chris Adamson", "Ameir Al-Zoubi", "Ken Auer", "Jonathan Blocksom", 
                                      "Kevin Conner", "Jack Cox", "Mark Dalrymple", "Bill Dudney", "Aaron Hillegass", 
                                      "Josh Johnson", "Chris Judd", "Jonathan Lehr", "Scott McAlister", "Rob Napier", 
                                      "Josh Nozzi", "Jonathan Penn", "Mark Pospesel", "Daniel Steinberg", "Jay Thrash", "Walter Tyree"])
    end
    
    def combined
        *speakers = "Josh Abernathy", "Chris Adamson", "Ameir Al-Zoubi", "Mike Ash", "Ken Auer", "Randy Beiter", "Jeff Biggus", 
                    "Jonathan Blocksom", "Heath Borders", "Tim Burks", "Craig Castelaz", "Step Christopher", "Kevin Conner", 
                    "Jack Cox", "Brian Coyner", "Mark Dalrymple", "James Dempsey", "Collin Donnell", "Bill Dudney", "Nathan Eror", 
                    "Jason Felice", "Mark Gilicinski", "Geoff Goetz", "Aaron Hillegass", "Pete Hodgson", "Andy Hunt", "Jason Hunter", 
                    "Andria Jensen", "Josh Johnson", "Chris Judd", "Jeff Kelley", "Dave Koziol", "Brad Larson", "Jonathan Lehr", 
                    "Mac Liaw", "Steve Madsen", "Scott McAlister", "Eric Meyer", "Justin Miller", "Saul Mora", "Kevin Munc", 
                    "Rob Napier", "Jaimee Newberry", "Josh Nozzi", "Janine Ohmer", "Daniel Pasco", "Jonathan Penn", "Boisy Pitre", 
                    "Mark Pospesel", "Jared Richardson", "Jonathan Saggau", "Ben Scheirman", "Chad Sellers", "Brent Simmons", 
                    "Doug Sjoquist", "Josh Smith", "David Smith", "Daniel Steinberg", "Elizabeth Taylor", "Mattt Thompson", 
                    "Jay Thrash", "Walter Tyree", "Whitney Young"
        @combined_cocoa_confs ||= self.alloc.initWithConferences(Conference.conferenceWithName("CocoaConf", 
                                                                                     startDate: NSDate.dateWithYear(2011, month:8, day:11), 
                                                                                      duration:3, speakers: speakers))
    end
    
    def all
      @all ||= self.alloc.initWithConferences(self.raleigh2012, self.portland2012, self.columbus2012, self.dc2012, self.chicago2012, self.raleigh2011, self.columbus2011)
    end
    
    def currentCocoaConf
      @current ||= self.alloc.initWithConferences(self.portland2012)
    end
    
    def recent
      @recent ||= self.alloc.initWithConferences(self.portland2012, self.raleigh2012 )
    end
    
    def smallHeaderReuseID
      CONFERENCE_HEADER_SMALL_ID
    end
  end
end