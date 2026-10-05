import Flutter
import UIKit
import Firebase
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Configurar Firebase una sola vez.
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // Mantener las notificaciones en primer plano.
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if let error = error {
                print("❌ Error solicitando permisos de notificación: \(error)")
            } else {
                print("🔔 Permisos de notificación concedidos: \(granted)")
            }
        }

        application.registerForRemoteNotifications()

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }

    // Registrar los plugins cuando Flutter inicialice su motor.
    func didInitializeImplicitFlutterEngine(
        _ engineBridge: FlutterImplicitEngineBridge
    ) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }

    // Mostrar notificaciones con la app abierta.
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge, .list])
    }
}