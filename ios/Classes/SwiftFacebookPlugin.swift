import Flutter
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
    
public class SwiftFacebookPlugin: NSObject, FlutterPlugin, UIApplicationDelegate {
    
    private static let channelName  = "plugins.flutter.io/facebook"
    private static let methodLogInWithPublishPermissions: String = "logInWithPublishPermissions"
    private static let methodLogInWithReadPermissions: String = "logInWithReadPermissions"
    private static let methodLogOut: String = "logOut"
    private static let methodIsLoggedIn: String = "isLoggedIn"
    private static let methodGetAccessToken: String = "getAccessToken"
    private static let methodInitSdk: String = "initSdk"

    
    private var initialized: Bool = false
    private var loginManager: FBSDKLoginManager?!
    private var permissions = ["public_profile", "email"]
    private var fileds = "id,name,email"
    
    private var flutterResult: FlutterResult?!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = SwiftFacebookPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        registrar.addApplicationDelegate(instance)
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication){
        print("applicationDidBecomeActive")
        FBSDKAppEvents.activateApp()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        
        switch call.method {
        case SwiftFacebookPlugin.methodInitSdk:
            self.flutterResult = result
            self.initSdk()
            break
        case SwiftFacebookPlugin.methodIsLoggedIn:
            self.flutterResult = result
            self.isLoggedIn()
            break
        case SwiftFacebookPlugin.methodGetAccessToken:
            self.flutterResult = result
            self.getAccessToken()
            break
        case SwiftFacebookPlugin.methodLogInWithPublishPermissions:
            self.flutterResult = result
            self.logInWithPublishPermissions()
            break
        case SwiftFacebookPlugin.methodLogInWithReadPermissions:
            self.flutterResult = result
            self.logInWithReadPermissions()
            break
        case SwiftFacebookPlugin.methodLogOut:
            self.flutterResult = result
            self.logOut()
            break
        default:
            result(FlutterMethodNotImplemented)
            
        }
    }
    
    func initSdk() {
        self.loginManager = FBSDKLoginManager.init()
        if self.loginManager != nil {
            self.initialized = true
            
            self.flutterResult!!(NSDictionary.init(dictionary: ["status": "success"]))
        }else{
            self.flutterResult!!(NSDictionary.init(dictionary: ["status": "error", "message": "facebook sdk not initialized"]))
        }
    }
    
    func isLoggedIn() {
        let accessToken = FBSDKAccessToken.current()
        if accessToken != nil {
            self.flutterResult!!(true)
        } else {
            self.flutterResult!!(false)
        }
    }
    
    func getAccessToken() {
        if self.initialized {
            let accessToken = FBSDKAccessToken.current()
            if accessToken != nil {
                self.flutterResult!!(NSDictionary.init(dictionary: ["token": accessToken?.tokenString, "userId": accessToken?.userID]))
            } else {
                self.flutterResult!!(NSDictionary.init(dictionary: ["status": "error", "message": "not logged in"]))
            }
        } else {
            self.flutterResult!!(NSDictionary.init(dictionary: ["status": "error", "message": "facebook sdk not initialized"]))
        }
    }
    
    func logInWithPublishPermissions() {
        if self.initialized {
            let viewController = UIApplication.shared.delegate?.window!!.rootViewController
            self.loginManager!!.logIn(withPublishPermissions: self.permissions, from: viewController) {
                (result, error) in
                if error != nil {
                    let args = NSDictionary.init(dictionary: ["status": "error", "message": error?.localizedDescription])
                    self.flutterResult!!(args)
                } else {
                    let accessToken = result?.token
                    self.flutterResult!!(NSDictionary.init(dictionary: ["status": "success","token": accessToken?.tokenString, "userId": accessToken?.userID]))
                }
            }
        } else {
            self.flutterResult!!(NSDictionary.init(dictionary: ["status": "error", "message": "facebook sdk not initialized"]))
        }
    }
    
    func logInWithReadPermissions() {
        if self.initialized {
            let viewController = UIApplication.shared.delegate?.window!!.rootViewController
            self.loginManager!!.logIn(withReadPermissions: self.permissions, from: viewController) {
                (result, error) in
                if error != nil {
                    let args = NSDictionary.init(dictionary: ["status": "error", "message": error?.localizedDescription])
                    self.flutterResult!!(args);
                } else {
                    let accessToken = result?.token
                    self.flutterResult!!(NSDictionary.init(dictionary: ["status": "success","token": accessToken?.tokenString, "userId": accessToken?.userID]))
                }
            }
        } else {
            self.flutterResult!!(NSDictionary.init(dictionary: ["status": "error", "message": "facebook sdk not initialized"]))
        }
    }
    
    func logOut(){
        if self.initialized {
            self.loginManager!!.logOut()
        }
        
        self.flutterResult!!(true)
    }
}
