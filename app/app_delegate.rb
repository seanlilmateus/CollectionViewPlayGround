class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
     @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap do |win|
       @main_view_controller = MainViewController.alloc.initWithCollectionViewLayout(GridLayout.alloc.init)
       win.rootViewController = @main_view_controller
       win.makeKeyAndVisible
     end
    true
  end  
end
