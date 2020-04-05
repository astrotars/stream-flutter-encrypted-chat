import UIKit
import Flutter
import VirgilE3Kit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var eThree: EThree?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let virgilChannel = FlutterMethodChannel(name: "io.getstream/virgil",
                                                 binaryMessenger: controller.binaryMessenger)
        virgilChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            let args = call.arguments as!  Dictionary<String, String>
            if call.method == "initVirgil" {
                do {
                    try self!.initVirgil(args: args, result: result)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_initVirgil",
                                             message: error.localizedDescription,
                                             details: nil))
                }
            } else if call.method == "encrypt" {
                do {
                    self!.encrypt(args: args, result: result)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_encrypt",
                                             message: error.localizedDescription,
                                             details: nil))
                }
            } else if call.method == "decryptMine" {
                do {
                    self!.decryptMine(args: args, result: result)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_decryptMine",
                                             message: error.localizedDescription,
                                             details: nil))
                }
            } else if call.method == "decryptTheirs" {
                do {
                    self!.decryptTheirs(args: args, result: result)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_decryptTheirs",
                                             message: error.localizedDescription,
                                             details: nil))
                }
            } else {
                result(FlutterError.init(code: "IOS_EXCEPTION_NO_METHOD_FOUND",
                                         message: "no method found for: " + call.method,
                                         details: nil));
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    private func initVirgil(args: Dictionary<String, String>, result: FlutterResult) {
        let tokenCallback: EThree.RenewJwtCallback = { completion in
            completion(args["token"]!, nil)
        }
        eThree = try! EThree(identity: args["user"]!, tokenCallback: tokenCallback)
        
        eThree!.register { error in
            if let error = error {
                if error as? EThreeError == .userIsAlreadyRegistered {
                    print("Already registered")
                } else {
                    print("Failed registering: \(error.localizedDescription)")
                }
            }
        }
        
        result(true)
    }
    
    private func encrypt(args: Dictionary<String, String>, result: @escaping FlutterResult) {
        eThree!.findUser(with: args["otherUser"]!) { card, _ in
            let encryptedText: String = try! self.eThree!.authEncrypt(text: args["text"]!, for: card!)
            
            result(encryptedText)
        }
    }
    
    private func decryptMine(args: Dictionary<String, String>, result: FlutterResult) {
        let decryptedText = try! eThree!.authDecrypt(text: args["text"]!)
        result(decryptedText)
    }
    
    private func decryptTheirs(args: Dictionary<String, String>, result: @escaping FlutterResult) {
        eThree!.findUser(with: args["otherUser"]!) { card, _ in
            let encryptedText: String = try! self.eThree!.authDecrypt(text: args["text"]!, from: card!)
            
            result(encryptedText)
        }
    }
}
