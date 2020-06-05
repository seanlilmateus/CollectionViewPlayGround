## Rubymotion CollectionView Playground
this is a Rubymotion port of [@mpospese's](https://github.com/mpospese/) Introducing UICollectionViews [talk](https://github.com/mpospese/IntroducingCollectionViews), in opposite to the original example app, this application contains no xib or storyboards. Everything is RubyMotion code.

This code was written for educational purposes, if you're using this code in production, Whenever you meet Mr. @mpospese or myself don't hesitate in buying us a beer.

To incentive yourself in taking a look into Mr. @mpospese's [great slides](https://dl.dropbox.com/u/108108523/CocoaConf%20RTP/Introducing%20Collection%20Views.pdf) . I removed a lot of comments from my code! 😜. His presentation is probably the best introduction to UICollectionView around.
Actually this example app consist of 5 different UICollectionViews layout.

## Requirements
- iOS 6+
- Rubymotion

## Summary
  
The app presents the speaker roster from various CocoaConf conferences.  Each conference date is a section and the speakers at that event are the items in that section.  It has 5 different layouts.  Use a 2-finger tap to switch between layouts.  (A 3 finger tap will switch back to previous layout, i.e. cycles through the layouts in the opposite direction.)  
##Grid Layout
A standard UICollectionViewFlowLayout-derived layout.  Demonstrates the flow layout plus use of supplementary and decoration views.

![gridlayout](https://github.com/seanlilmateus/CollectionViewPlayGround/blob/master/screenshots/gridlayout.png?raw=true "Grid Layout")

## Line Layout
Another UICollectionViewFlowLayout-derived layout.  This one is adapted from the Apple sample of the same name from WWDC 2012 Session 219.  Demonstrates a single line horizontal layout and use of shouldInvalidateLayoutForBoundsChange: as well as use of custom layout attributes. 

![linelayout](https://github.com/seanlilmateus/CollectionViewPlayGround/blob/master/screenshots/linelayout.png?raw=true "Line Layout")

##Cover Flow Layout
Derived from Line Layout but adapted to look more like Cover Flow.

![coverflow](https://github.com/seanlilmateus/CollectionViewPlayGround/blob/master/screenshots/coverflow.png?raw=true "Coverflow Layout")

## Stacks Layout
A UICollectionViewLayout-derived layout (not flow layout).  Pinch out on the photo stacks to expand them and it will switch to Grid Layout.  Demonstrates custom layouts, gestures, and custom layout attributes.

![stacks](https://github.com/seanlilmateus/CollectionViewPlayGround/blob/master/screenshots/stacks.png?raw=true "Stacks Layout")

## Spiral Layout
Another UICollectionViewLayout-derived layout.  This one is adapted from the Apple sample CircleLayout from WWDC 2012 Session 219.  Only instead of a circle, items are arranged in a spiral that wraps 1 1/2 times around and fits the screen in either landscape or portrait.  It was also adapted to support multiple sections (1 spiral per screen) in a horizontally scrolling layout.  Swipe up on a speaker card and it will be flicked off screen and disappear.  Tap on the header to add a speaker back (expands out from center).  Demonstrates custom layouts, gestures, and custom delete and insert animations. 
  
![spiral](https://github.com/seanlilmateus/CollectionViewPlayGround/blob/master/screenshots/spiral.png?raw=true "Spiral Layout")

## Thanks
My thanks goes to Mark Pospesel, for his great [UICollectionView talk](https://dl.dropbox.com/u/108108523/CocoaConf%20RTP/Introducing%20Collection%20Views.pdf) don't miss his slides. On his Website are also great content to learn from [http://markpospesel.com/](http://markpospesel.com/).

The Background are by [Glyphish](http://www.glyphish.com/backgrounds/)

## Licensing:
this projekt is licensed under the [BSD license](http://www.opensource.org/licenses/bsd-license.php).
