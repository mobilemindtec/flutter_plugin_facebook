import Flutter
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
    
public class SwiftFacebookPlugin: NSObject, FlutterPlugin, UIApplicationDelegate, FBSDKAppInviteDialogDelegate, FBSDKSharingDelegate {
    
    private static let channelName  = "plugins.flutter.io/facebook"
    private static let methodLogInWithPublishPermissions: String = "logInWithPublishPermissions"
    private static let methodLogInWithReadPermissions: String = "logInWithReadPermissions"
    private static let methodLogOut: String = "logOut"
    private static let methodIsLoggedIn: String = "isLoggedIn"
    private static let methodGetAccessToken: String = "getAccessToken"
    private static let methodInitSdk: String = "initSdk"
    
    private static let methodIsinstalled: String = "isInstalled"
    private static let methodCanInvite: String = "canInvite"
    private static let methodInvite: String = "invite"
    
    private static let methodRequestGraphPath: String = "requestGraphPath"
    private static let methodRequestMe: String = "requestMe"
    
    private static let methodShareLink: String = "shareLink"
    private static let methodSharePhotos: String = "sharePhotos"
    private static let methodShareVideo: String = "shareVideo"

    
    private var initialized: Bool = false
    private var loginManager: FBSDKLoginManager?!
    private var permissions = ["public_profile", "email"]
    private var fields = "id,name,email"
    private var appLinkUrl: String = ""
    private var appPreviewImageUrl: String = ""
    private var graphRequestPath: String = ""
    private var graphRequestParameters: [String: String] = [:]
    private var shareLinkUrl: String = ""
    private var shareVideoUrl: String = ""
    private var sharePhotosUrl: [String] = [String]()
    
    private var flutterResult: FlutterResult?!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = SwiftFacebookPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        
        switch call.method {
        case SwiftFacebookPlugin.methodInitSdk:
            self.readArgs(call: call)
            self.flutterResult = result
            self.initSdk()
            break
        case SwiftFacebookPlugin.methodIsLoggedIn:
            self.readArgs(call: call)
            self.flutterResult = result
            self.isLoggedIn()
            break
        case SwiftFacebookPlugin.methodGetAccessToken:
            self.readArgs(call: call)
            self.flutterResult = result
            self.getAccessToken()
            break
        case SwiftFacebookPlugin.methodLogInWithPublishPermissions:
            self.readArgs(call: call)
            self.flutterResult = result
            self.logInWithPublishPermissions()
            break
        case SwiftFacebookPlugin.methodLogInWithReadPermissions:
            self.readArgs(call: call)
            self.flutterResult = result
            self.logInWithReadPermissions()
            break
        case SwiftFacebookPlugin.methodLogOut:
            self.readArgs(call: call)
            self.flutterResult = result
            self.logOut()
            break
        case SwiftFacebookPlugin.methodIsinstalled:
            self.readArgs(call: call)
            self.flutterResult = result
            self.isInstalled()
            break
        case SwiftFacebookPlugin.methodCanInvite:
            self.readArgs(call: call)
            self.flutterResult = result
            self.canInvite()
            break
        case SwiftFacebookPlugin.methodIsinstalled:
            self.readArgs(call: call)
            self.flutterResult = result
            self.invite()
            break
        case SwiftFacebookPlugin.methodRequestGraphPath:
            self.readArgs(call: call)
            self.flutterResult = result
            self.requestGraphPath()
            break
        case SwiftFacebookPlugin.methodRequestMe:
            self.readArgs(call: call)
            self.flutterResult = result
            self.requestGraphMe()
            break
        case SwiftFacebookPlugin.methodShareLink:
            self.readArgs(call: call)
            self.flutterResult = result
            self.shareLink()
            break
        case SwiftFacebookPlugin.methodShareVideo:
            self.readArgs(call: call)
            self.flutterResult = result
            self.shareVideo()
            break
        case SwiftFacebookPlugin.methodSharePhotos:
            self.readArgs(call: call)
            self.flutterResult = result
            self.sharePhotos()
            break
        default:
            result(FlutterMethodNotImplemented)
            
        }
    }
    
    func readArgs(call: FlutterMethodCall) {
        
        if call.arguments is Dictionary<String, String> {
            var map = call.arguments as! Dictionary<String, Any>
            if let value = map["permissions"]{
                var val = value as! String
                self.permissions = val.components(separatedBy: ",")
            }

            if let value = map["fields"] {
                self.fields = value  as! String
            }

            if let value = map["appLinkUrl"] {
                self.appLinkUrl = value  as! String
            }

            if let value = map["appPreviewImageUrl"] {
                self.appPreviewImageUrl = value  as! String
            }

            if let value = map["graphRequestPath"] {
                self.graphRequestPath = value as! String
            }

            if let value = map["graphRequestParameters"] {
                var map = value as! Dictionary<String, String>
                graphRequestParameters = [:]
                for (key, value) in map {
                    graphRequestParameters[key as! String] = value as! String
                }
            }
            
            if let value = map["videoUrl"] {
                self.shareVideoUrl = value  as! String
            }

            if let value = map["linkUrl"] {
                self.shareLinkUrl = value  as! String
            }

            if let value = map["sharePhotosUrl"] {
                var photos = value as! Array<String>
                self.sharePhotosUrl = [String]()
                
                for it in photos {
                    self.sharePhotosUrl.append(it)
                }
            }

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
    
    func isInstalled(){
        let nsUrl = URL.init(string: "fbapi://")
        let isInstalled = UIApplication.shared.canOpenURL(nsUrl!)
        self.flutterResult!!(isInstalled)
    }
    
    func canInvite() {
        let can = FBSDKAppInviteDialog.init().canShow()
        self.flutterResult!!(can)
    }
    
    func invite() {
        
        let content = FBSDKAppInviteContent.init();
        
        content.appLinkURL = URL.init(string: self.appLinkUrl)
        
        content.appInvitePreviewImageURL = URL.init(string: self.appPreviewImageUrl)
        
        let viewController = UIApplication.shared.delegate?.window!!.rootViewController
        
        let dialog = FBSDKAppInviteDialog.init()
        dialog.content = content
        dialog.fromViewController = viewController
        dialog.delegate = self
        dialog.show()
    }
    
    func shareVideo() {
        
        let content = FBSDKShareVideoContent.init()
        let video = FBSDKShareVideo.init()
        video.videoURL = URL.init(string: self.shareVideoUrl)
        content.video = video
        
        let viewController = UIApplication.shared.delegate?.window!!.rootViewController
        FBSDKShareDialog.show(from: viewController, with: content, delegate: self)
    }
    
    func sharePhotos() {
        
        let content = FBSDKSharePhotoContent.init()
        content.photos = []
        
        for it in self.sharePhotosUrl {
            let photo = FBSDKSharePhoto.init()
            photo.imageURL = URL.init(string: it)
            photo.isUserGenerated = true
            content.photos.append(photo)
        }
        
        let viewController = UIApplication.shared.delegate?.window!!.rootViewController
        FBSDKShareDialog.show(from: viewController, with: content, delegate: self)
    }
    
    func shareLink() {
        let content = FBSDKShareLinkContent.init()
        content.contentURL = URL.init(string: self.shareLinkUrl)
        let viewController = UIApplication.shared.delegate?.window!!.rootViewController
        FBSDKShareDialog.show(from: viewController, with: content, delegate: self)
    }

    
    func requestGraphMe(){
        self.graphPathRequest(graphPath: "me", parameters: ["fields": self.fields])
    }
    
    func requestGraphPath(){
        self.graphPathRequest(graphPath: self.graphRequestPath, parameters: self.graphRequestParameters)
    }
    
    func graphPathRequest(graphPath: String!, parameters: [AnyHashable: Any]!) {
        
        let request = FBSDKGraphRequest.init(graphPath: graphPath, parameters: parameters)
        request?.start() {
            (_, result, error) in
            if error != nil {
                let args = ["status": "error", "message": error?.localizedDescription]
                self.flutterResult!!(args)
            } else {
                //let map = result as! [AnyHashable: Any]
                
                //- Parameter result:          The result of the request.  This is a translation of
                // JSON data to `NSDictionary` and `NSArray` objects.  This
                // is nil if there was an error.

                var data = ["status": "success", "result": result ]                
                self.flutterResult!!(data)
                
                
            }
        }
        
    }
    
    func toJson(data: [AnyHashable: Any]) -> [String: Any] {
        var item = Dictionary<String, Any>()
        
        for (key, val) in data {
            if val is Dictionary<AnyHashable, Any> {
                item[key as! String] = self.toJson(data: val as! Dictionary<AnyHashable, Any> )
            } else if val is Array<Any> {
                item[key as! String] = self.toJsonArray(data: val as! Array<Any>)
            } else {
                item[key as! String] = val as! String
            }
        }
        
        return item
    }
    
    func toJsonArray(data: [Any]) -> [Any] {
        var items = [Any]()
        
        for it in data {
            
            if it is Dictionary<AnyHashable, Any> {
                items.append(self.toJson(data: it as! Dictionary<AnyHashable, Any>))
            } else if it is Array<Any> {
                items.append(self.toJsonArray(data: it as! Array<Any>))
            } else {
                items.append(it)
            }
        }
        
        return items
    }
    
    public func sharerDidCancel(_ sharer: FBSDKSharing!) {
        self.flutterResult!!(["status": "cancel"])
    }
    
    public func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        self.flutterResult!!(["status": "error", "message": error?.localizedDescription])
    }
    
    public func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        self.flutterResult!!(["status": "success"])
    }
    
    public func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        
        self.flutterResult!!(["status": "success"])
    }
    
    public func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        let args = ["status": "error", "message": error?.localizedDescription]
        self.flutterResult!!(args)
    }

    public func applicationDidBecomeActive(_ application: UIApplication){
        print("applicationDidBecomeActive")
        FBSDKAppEvents.activateApp()
    }

}
