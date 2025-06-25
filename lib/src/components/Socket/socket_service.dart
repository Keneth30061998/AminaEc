import 'package:amina_ec/src/environment/environment.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../models/user.dart';

class SocketService {
  static final SocketService _singleton = SocketService._internal();
  factory SocketService() => _singleton;
  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  late IO.Socket socket;

  SocketService._internal() {
    // Inicializa socket con el token actual (aunque sea null al principio)
    socket = IO.io(
      Environment.API_URL_SOCKET,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': userSession.session_token ?? ''})
          .disableAutoConnect()
          .build(),
    );
  }

  void setUser(User user) {
    userSession = user;
  }

  // Actualiza el usuario y reconecta el socket
  void updateUserSession(User newUser) {
    userSession = newUser;

    // Si el socket está conectado, desconéctalo antes de reconectar
    if (socket != null && socket.connected) {
      socket.disconnect();
    }
    connect();
  }

  void connect() {
    print('🔌 Intentando conectar al socket...');
    print('🔑 Token usado: ${userSession.session_token}');
    socket = IO.io(
      Environment.API_URL_SOCKET,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': userSession.session_token})
          .disableAutoConnect()
          .build(),
    );

    socket.connect(); // conectar manualmente

    socket.onConnect((_) {
      print('🟢 Socket conectado');
    });

    socket.onDisconnect((_) {
      print('🔴 Socket desconectado');
    });

    socket.onConnectError((err) {
      print('⚠️ Error de conexión al socket: $err');
    });

    socket.onError((err) {
      print('❌ Socket error: $err');
    });
  }

  void on(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void emit(String event, dynamic data) {
    socket.emit(event, data);
  }
}
