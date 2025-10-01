// lib/src/components/Socket/socket_service.dart
import 'package:amina_ec/src/environment/environment.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../models/user.dart';

/// SocketService (singleton) — maneja conexión y listeners
/// -----------------------------------------------------
/// - Reconstruye la instancia de socket cuando cambia el token (evita manipular socket.io.options)
/// - Evita listeners duplicados (socket.off(event) antes de socket.on)
/// - Envía token por auth al crear el socket (acepta el session_token que contiene 'JWT ...')
/// - Emite join con { room: '<id>' } (coincide con backend)
/// - Provee helpers (connect, disconnect, on, once, off, emitSafe, join, leaveRoom)
class SocketService {
  static final SocketService _singleton = SocketService._internal();
  factory SocketService() => _singleton;

  User userSession = User.fromJson(GetStorage().read('user') ?? {});
  late IO.Socket socket;

  SocketService._internal() {
    // Inicializar socket con el token actual (si hay)
    final initialToken = userSession.session_token ?? '';
    _recreateSocketWithToken(initialToken, autoConnect: false);
  }

  // Construye la instancia del socket con las opciones necesarias
  IO.Socket _buildSocket(String authToken) {
    // El OptionBuilder ya coloca el token en auth correctamente
    final s = IO.io(
      Environment.API_URL_SOCKET,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': authToken})
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );
    return s;
  }

  // Atacha handlers básicos al socket (connect/disconnect/errors).
  // Esto se llama cada vez que se crea un nuevo socket para evitar handlers duplicados.
  void _attachDefaultHandlers() {
    // Limpiar handlers previos por seguridad
    try {
      socket.off('connect');
      socket.off('disconnect');
      socket.off('connect_error');
      socket.off('error');
    } catch (e) {}

    socket.onConnect((_) {
      // Cuando conectamos, nos unimos a la sala privada del usuario (si existe id)
      try {
        if (userSession.id != null) {
          final room = userSession.id.toString();
          // En backend se espera: socket.on("join", ({ room }) => { ... })
          socket.emit('join', {'room': room});
        }
      } catch (e) {
        // ignore
      }
    });

    socket.onDisconnect((_) {
      // Opcional: registrar para debugging
      // print('SocketService: disconnected');
    });

    socket.onConnectError((err) {
      // Opcional: registrar para debugging
      // print('SocketService: connect error -> $err');
    });

    socket.onError((err) {
      // Opcional: registrar para debugging
      // print('SocketService: error -> $err');
    });
  }

  // Reconstruye la instancia del socket con el token dado. Si autoConnect=true,
  // llama a connect() al final.
  void _recreateSocketWithToken(String token, {bool autoConnect = false}) {
    // Si existe una instancia previa, limpiarla
    try {
      try {
        socket.disconnect();
      } catch (e) {}
      try {
        socket.dispose();
      } catch (e) {}
      try {
        socket.close();
      } catch (e) {}
        } catch (e) {
      // ignore: no-op si no existía
    }

    // Crear nueva instancia
    socket = _buildSocket(token);

    // Atachar handlers básicos
    _attachDefaultHandlers();

    if (autoConnect && token.isNotEmpty) {
      try {
        socket.connect();
      } catch (e) {
        // ignore
      }
    }
  }

  /// Actualiza la sesión del usuario (token/id).
  /// Reconstruye el socket con el nuevo token y conecta.
  void updateUserSession(User newUser) {
    userSession = newUser;

    final token = userSession.session_token ?? '';
    // Reconstruir socket con nuevo token y conectar (si el token existe)
    _recreateSocketWithToken(token, autoConnect: token.isNotEmpty);
  }

  /// Fuerza la conexión del socket actual.
  void connect() {
    if (socket.connected) return;
    try {
      socket.connect();
    } catch (e) {
      // ignore
    }
  }

  /// Desconecta (limpia) la instancia actual del socket.
  void disconnect() {
    try {
      socket.disconnect();
      socket.dispose();
      socket.close();
    } catch (e) {
      // ignore
    }
  }

  /// Indica si está conectado
  bool isConnected() {
    try {
      return socket.connected;
    } catch (e) {
      return false;
    }
  }

  /// Registra un listener. Antes de registrar, elimina cualquier listener previo
  /// para evitar duplicados (importante cuando pantallas se reconstruyen).
  void on(String event, Function(dynamic) callback) {
    try {
      socket.off(event);
    } catch (e) {}
    socket.on(event, (data) {
      callback(data);
    });
  }

  /// Registra un listener que se dispara solo una vez
  void once(String event, Function(dynamic) callback) {
    try {
      socket.once(event, callback);
    } catch (e) {}
  }

  /// Elimina listener para evento específico
  void off(String event) {
    try {
      socket.off(event);
    } catch (e) {}
  }

  /// Emite un evento (si no está conectado, intenta conectar si hay token)
  void emit(String event, dynamic data) {
    if (!isConnected()) {
      // intenta conectar si hay token
      if (userSession.session_token != null &&
          userSession.session_token!.isNotEmpty) {
        connect();
      }
    }
    try {
      socket.emit(event, data);
    } catch (e) {
      // ignore
    }
  }

  /// Emite solo si está conectado. (útil para evitar errores)
  void emitSafe(String event, dynamic data) {
    if (isConnected()) {
      try {
        socket.emit(event, data);
      } catch (e) {}
    }
  }

  /// Unirse a una sala (backend espera { room: '...' })
  void join(String room) {
    if (room.isEmpty) return;
    emit('join', {'room': room});
  }

  /// Salir de sala (si lo usa)
  void leaveRoom(String room) {
    if (room.isEmpty) return;
    emit('leave', {'room': room});
  }

  /// Liberar recursos
  void dispose() {
    try {
      socket.off('connect');
      socket.off('disconnect');
      socket.off('error');
      socket.dispose();
      socket.close();
    } catch (e) {}
  }
}
