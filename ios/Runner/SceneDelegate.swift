import UIKit
import Flutter

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var flutterEngine: FlutterEngine?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // 創建 Flutter 引擎
        flutterEngine = FlutterEngine(name: "my flutter engine")
        flutterEngine?.run()
        
        // 創建 Flutter 視圖控制器
        let flutterViewController = FlutterViewController(engine: flutterEngine!, nibName: nil, bundle: nil)
        
        // 設置窗口
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = flutterViewController
        window?.makeKeyAndVisible()
        
        // 處理啟動時的 URL
        if let urlContext = connectionOptions.urlContexts.first {
            handleURL(urlContext.url)
        }
        
        // 處理用戶活動（Universal Links）
        if let userActivity = connectionOptions.userActivities.first {
            handleUserActivity(userActivity)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleURL(url)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        handleUserActivity(userActivity)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }
    
    // MARK: - Private Methods
    
    private func handleURL(_ url: URL) {
        // 將 URL 處理委託給 AppDelegate
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            _ = appDelegate.application(UIApplication.shared, open: url, options: [:])
        }
    }
    
    private func handleUserActivity(_ userActivity: NSUserActivity) {
        // 處理 Universal Links 和其他用戶活動
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            handleURL(url)
        }
    }
} 