platform :ios, '8.0'
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'
source 'git@bitbucket.org:shashlov/cocorespecs.git'

target 'Cocore' do

    # Main application core
    #   > Cocore
    
    pod 'Alamofire', '3.1.4'
    pod 'RealmSwift', '0.98.6'
    pod 'ReactiveCocoa', '4.0.4-alpha-4'
    pod 'ObjectMapper', '1.1.1'
    pod 'AlamofireObjectMapper', '2.1.0'
    
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'Reachability'
    pod 'DeepLinkKit'
    pod 'OneSignal', '1.13.3'
    pod 'Helpshift', '5.8.0'
    pod 'UXCam'
    
    # Sentry client
    pod 'Raven'
    
    # State machine (own GitHub fork with updates)
    #   > Cocore/StateMachine
    pod 'SwiftState', '4.1.1'
    
    # Used in TaskListController.swift
    #   > Cocore/CustomSegmentedControl
    # pod 'NPSegmentedControl'
    
    # Used in TaskService.swift and LocalTaskPerformController.swift
    #   > Cocore/CloudStore/Cloudinary
    # pod 'Cloudinary'
    
    # Modal onscreen progress notifier 
    #   > Cocore/ProgressNotifier
    pod 'ARSLineProgress', :git => 'git@github.com:dmitryshashlov/ARSLineProgress.git', :tag => 'custom'
    
    # Used in StatusBarNotifier.swift
    #   > Cocore/StatusBarNotifier
    pod 'JDStatusBarNotification'
    
    # Used in StrintUtils.swift for rendering HTML inside UILabel
    #   > Cocore/HTMLUtils
    pod 'TTTAttributedLabel'
    
    # Logging
    #   > Cocore/Logging
    pod 'CocoaLumberjack/Swift'
    pod 'PaperTrailLumberjack', :git => 'git@github.com:dmitryshashlov/papertrail-lumberjack-ios.git'
    pod 'CocoaAsyncSocket', '7.4.3'
    
    # Used for TwitterAuthorization
    #   > Cocore/OAuth
    # pod 'OAuthSwift', '0.6.0'
    # pod 'OAuthSwift-Alamofire', :git => 'git@github.com:OAuthSwift/OAuthSwift-Alamofire.git', :tag => '0.0.2'
    
    # Used in ViewModels
    #   > Cocore/TimeUtils
    # pod 'DateTools'
    
    # Used for NSTimer.after(..) calls, mostly for navigation
    pod 'SwiftyTimer', '1.4.1'

end
