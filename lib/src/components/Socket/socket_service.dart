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
    final initialToken = userSession.session_token ?? '';
    _recreateSocketWithToken(initialToken, autoConnect: false);
  }

  IO.Socket _buildSocket(String authToken) {
    final s = IO.io(
      Environment.API_URL_SOCKET,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io')
          .setAuth({'token': authToken})
          .enableForceNew()
          .disableAutoConnect()
          .build(),
    );
    return s;
  }

  void _attachDefaultHandlers() {
    // Limpiar handlers previos de forma explícita
    try {
      socket.off('connect');
      socket.off('disconnect');
      socket.off('connect_error');
      socket.off('error');
    } catch (_) {}

    socket.onConnect((_) {
      print("✅ [SocketService] conectado: id=${socket.id}");
      _joinPrivateRoom(); // aseguramos unión a sala privada al conectar
    });

    socket.onDisconnect((reason) {
      print("⛔ [SocketService] desconectado: $reason");
    });

    socket.onConnectError((err) {
      print("⚠️ [SocketService] connect_error: $err");
    });

    socket.onError((err) {
      print("❌ [SocketService] error: $err");
    });

    // Opcional: escuchar reintentos automáticos
    socket.io!.on('reconnect_attempt', (data) {
      print("🔁 [SocketService] intento de reconexión: $data");
    });
  }

  void _recreateSocketWithToken(String token, {bool autoConnect = false}) {
    // Evitar crash si socket no fue inicializado aún
    try {
      if (socket != null) {
        socket.disconnect();
        try { socket.dispose(); } catch (_) {}
        try { socket.close(); } catch (_) {}
      }
    } catch (_) {}

    socket = _buildSocket(token);
    _attachDefaultHandlers();

    if (autoConnect && token.isNotEmpty) {
      socket.connect();
    }
  }

  void updateUserSession(User newUser) {
    userSession = newUser;
    final token = userSession.session_token ?? '';
    // Reconstruir socket y conectar si hay token
    _recreateSocketWithToken(token, autoConnect: token.isNotEmpty);
  }

  void connect() {
    if (socket.connected) {
      print("ℹ️ [SocketService] ya conectado");
      _joinPrivateRoom();
      return;
    }
    socket.connect();
  }

  void disconnect() {
    try {
      socket.disconnect();
      try { socket.dispose(); } catch (_) {}
      try { socket.close(); } catch (_) {}
    } catch (_) {}
  }

  bool isConnected() => socket.connected;

  // 🚨 Cambiado: ya no bloqueamos por hasListeners. Permitimos múltiples
  // listeners en distintos controladores.
  void on(String event, Function(dynamic) callback) {
    socket.on(event, (data) {
      callback(data);
    });
  }

  void once(String event, Function(dynamic) callback) {
    socket.once(event, callback);
  }

  void off(String event) {
    socket.off(event);
  }

  void emit(String event, dynamic data) {
    if (!socket.connected && userSession.session_token?.isNotEmpty == true) {
      print("🔌 [SocketService] no conectado — intentando conectar antes de emitir...");
      socket.connect();
    }
    socket.emit(event, data);
  }

  void emitSafe(String event, dynamic data) {
    if (socket.connected) {
      socket.emit(event, data);
    } else {
      print("⚠️ [SocketService] emitSafe ignorado (no conectado): $event");
    }
  }

  void _joinPrivateRoom() {
    if (userSession.id != null) {
      final room = userSession.id.toString();
      socket.emit('join', {'room': room});
    }
  }

  void join(String room) {
    socket.emit('join', {'room': room});
  }

  void leaveRoom(String room) {
    socket.emit('leave', {'room': room});
  }

  void dispose() {
    try {
      socket.off('connect');
      socket.off('disconnect');
      socket.off('error');
      socket.dispose();
      socket.close();
    } catch (_) {}
  }
}
