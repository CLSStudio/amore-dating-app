import Flutter
import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase 初始化
    FirebaseApp.configure()
    
    // Facebook SDK 初始化
    ApplicationDelegate.shared.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
    
    // Flutter 插件註冊
    GeneratedPluginRegistrant.register(with: self)
    
    // Google Sign-In 配置
    if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
       let plist = NSDictionary(contentsOfFile: path),
       let clientId = plist["CLIENT_ID"] as? String {
      GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // URL Scheme 處理
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    // Google Sign-In URL 處理
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    
    // Facebook URL 處理
    if ApplicationDelegate.shared.application(app, open: url, options: options) {
      return true
    }
    
    // Flutter URL 處理
    return super.application(app, open: url, options: options)
  }
  
  // Universal Links 處理
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
  
  // Remote Notifications 註冊
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  // Remote Notifications 處理
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
  }
}
