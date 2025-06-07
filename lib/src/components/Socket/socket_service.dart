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
    connect();
  }

  void connect() {
    socket = IO.io(
      '${Environment.API_URL}?token=${userSession.session_token}',
      IO.OptionBuilder()
          .setTransports(['websocket'])
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
