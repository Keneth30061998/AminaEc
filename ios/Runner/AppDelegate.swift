import Flutter
import UIKit
import Firebase
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Configurar Firebase
    FirebaseApp.configure()

    // Permitir notificaciones en foreground (iOS)
    UNUserNotificationCenter.current().delegate = self

    // Registrar permisos de notificaciones
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if let error = error {
            print("❌ Error solicitando permisos de notificación: \(error)")
        } else {
            print("🔔 Permisos de notificación concedidos: \(granted)")
        }
    }

    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Mostrar notificaciones cuando la app está abierta
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
    @escaping (UNNotificationPresentationOptions) -> Void
  ) {
      completionHandler([.banner, .sound, .badge, .list])
  }
}
