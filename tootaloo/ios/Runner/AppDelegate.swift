import UIKit
import Flutter
import GoogleMaps
import flutter_config

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Google Maps API
    GMSServices.provideAPIKey(FlutterConfigPlugin.env(for: "GOOGLE_MAPS_API_KEY"))
    //GMSServices.provideAPIKey("AIzaSyDFbzpRo8sZlSo4TQP6MT7ykJlyDOq4rdo")


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
