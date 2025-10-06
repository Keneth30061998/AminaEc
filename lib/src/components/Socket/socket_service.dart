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
    //print("📲 [SocketService] Inicializando con token: $initialToken");
    _recreateSocketWithToken(initialToken, autoConnect: false);
  }

  IO.Socket _buildSocket(String authToken) {
    final s = IO.io(
      Environment.API_URL_SOCKET,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io')
          .setAuth({'token': authToken})
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );
    //print("🔧 [SocketService] _buildSocket con token: $authToken");
    return s;
  }

  void _attachDefaultHandlers() {
    socket.off('connect');
    socket.off('disconnect');
    socket.off('connect_error');
    socket.off('error');

    socket.onConnect((_) {
      //print("✅ [SocketService] Conectado al socket, id=${socket.id}");
      _joinPrivateRoom(); // 🔑 cada vez que se conecta, entra en su sala privada
    });

    socket.onDisconnect((reason) {
      //print("⛔️ [SocketService] Desconectado del socket, reason=$reason");
    });

    socket.onConnectError((err) {
      //print("⚠️ [SocketService] Error al conectar: $err");
    });

    socket.onError((err) {
      //print("❌ [SocketService] Error en socket: $err");
    });
  }

  void _recreateSocketWithToken(String token, {bool autoConnect = false}) {
    try {
      socket.disconnect();
      socket.dispose();
      socket.close();
    } catch (_) {}

    socket = _buildSocket(token);
    _attachDefaultHandlers();

    if (autoConnect && token.isNotEmpty) {
      //print("📡 [SocketService] autoConnect=true, iniciando conexión...");
      socket.connect();
    }
  }

  void updateUserSession(User newUser) {
    userSession = newUser;
    final token = userSession.session_token ?? '';
    //print("🔄 [SocketService] updateUserSession, nuevo token: $token");
    _recreateSocketWithToken(token, autoConnect: token.isNotEmpty);
  }

  void connect() {
    if (socket.connected) {
      //print("ℹ️ [SocketService] Ya conectado");
      _joinPrivateRoom(); // 🔑 reforzar unión aunque ya esté conectado
      return;
    }
    //print("📡 [SocketService] Intentando conectar...");
    socket.connect();
  }

  void disconnect() {
    //print("🛑 [SocketService] Disconnect llamado");
    try {
      socket.disconnect();
      socket.dispose();
      socket.close();
    } catch (_) {}
  }

  bool isConnected() => socket.connected;

  void on(String event, Function(dynamic) callback) {
    //print("👂 [SocketService] Listening al evento: $event");
    if (socket.hasListeners(event)) return; // evita duplicados
    socket.on(event, (data) {
      //print("👂 [SocketService] Evento recibido: $event → $data");
      callback(data);
    });
  }


  void once(String event, Function(dynamic) callback) {
    socket.once(event, callback);
  }

  void off(String event) {
    socket.off(event);
    //print("🗑️ [SocketService] Listener removido: $event");
  }

  void emit(String event, dynamic data) {
    if (!socket.connected && userSession.session_token?.isNotEmpty == true) {
      //print("🔌 [SocketService] No conectado, intentando reconectar antes de emitir...");
      socket.connect();
    }
    //print("📤 [SocketService] Emitting $event → $data");
    socket.emit(event, data);
  }

  void emitSafe(String event, dynamic data) {
    if (socket.connected) {
      //print("📤 [SocketService] Emitting seguro $event → $data");
      socket.emit(event, data);
    }
  }

  // 🚪 Unirse a la sala privada del usuario actual
  void _joinPrivateRoom() {
    if (userSession.id != null) {
      final room = userSession.id.toString();
      //print("🚪 [SocketService] Uniéndose a sala privada: $room");
      socket.emit('join', {'room': room});
    }
  }

  void join(String room) {
    //print("🚪 [SocketService] join room → $room");
    socket.emit('join', {'room': room});
  }

  void leaveRoom(String room) {
    //print("🚪 [SocketService] leave room → $room");
    socket.emit('leave', {'room': room});
  }

  void dispose() {
    //print("🗑️ [SocketService] dispose socket");
    socket.off('connect');
    socket.off('disconnect');
    socket.off('error');
    socket.dispose();
    socket.close();
  }
}
