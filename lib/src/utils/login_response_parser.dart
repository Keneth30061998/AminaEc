import 'dart:convert';

/// Normaliza únicamente la respuesta de login del backend de AMINA.
/// No depende de Flutter, GetX ni del modelo ResponseApi.
Map<String, dynamic> parseLoginResponse({
  required int? statusCode,
  required Object? body,
}) {
  if (statusCode == null || statusCode == 0) {
    return _failure(
      'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.',
    );
  }

  final json = decodeJsonObject(body);
  final serverMessage = _readMessage(json);

  // Conservar los mensajes JSON del backend corregido. Un proxy también puede
  // devolver HTML: ese texto no se envía al modelo ResponseApi.
  if (statusCode >= 500 && statusCode <= 599) {
    if (json?['success'] == false && serverMessage != null) {
      return _failure('$serverMessage (HTTP $statusCode)');
    }
    return _failure(
      'El servicio de inicio de sesión no está disponible temporalmente '
          '(HTTP $statusCode). Inténtalo más tarde.',
    );
  }

  // Un cuerpo con success:true nunca convierte un HTTP de error en un login.
  if (statusCode < 200 || statusCode >= 300) {
    if (json?['success'] == false && serverMessage != null) {
      return _failure(serverMessage);
    }

    switch (statusCode) {
      case 401:
        return _failure('Correo o contraseña incorrectos.');
      case 403:
        return _failure('El servidor no autorizó el inicio de sesión.');
      case 404:
        return _failure(
          'No se encontró el servicio de inicio de sesión (HTTP 404).',
        );
      case 429:
        return _failure(
          'Se realizaron demasiados intentos. Espera un momento y vuelve a intentar.',
        );
      default:
        return _failure('No se pudo iniciar sesión (HTTP $statusCode).');
    }
  }

  if (json == null) {
    return _failure('El servidor no devolvió una respuesta JSON válida.');
  }

  if (json['success'] == false) {
    return _failure(serverMessage ?? 'No se pudo iniciar sesión.');
  }

  if (json['success'] != true) {
    return _failure(
      'El servidor devolvió un formato de inicio de sesión inesperado.',
    );
  }

  final user = _normalizeSessionUser(json['data']);
  final token = user?['session_token'];
  if (user == null || token is! String || token.trim().isEmpty) {
    return _failure(
      'La respuesta de inicio de sesión no contiene un usuario, roles y token válidos.',
    );
  }

  return <String, dynamic>{
    'success': true,
    'message': serverMessage ?? 'El usuario fue autenticado',
    'data': user,
  };
}

Map<String, dynamic> _failure(String message) => <String, dynamic>{
  'success': false,
  'message': message,
};

/// Admite un objeto JSON y un objeto guardado como texto JSON. Nunca devuelve
/// una lista, un escalar o HTML. No escribe ni elimina el almacenamiento local.
Map<String, dynamic>? decodeJsonObject(Object? body) {
  Object? value = body;
  if (value is String) {
    if (value.trim().isEmpty) return null;
    try {
      value = jsonDecode(value);
    } on FormatException {
      return null;
    }
  }
  return _stringKeyedMap(value);
}

Map<String, dynamic>? _normalizeSessionUser(Object? value) {
  final user = decodeJsonObject(value);
  if (user == null) return null;
  final id = _stringId(user['id']);
  if (id == null) return null;

  Object? roles = user['roles'];
  if (roles is String) {
    try {
      roles = jsonDecode(roles);
    } on FormatException {
      return null;
    }
  }
  if (roles is! List || roles.isEmpty) return null;

  final normalizedRoles = <Map<String, dynamic>>[];
  for (final value in roles) {
    final role = decodeJsonObject(value);
    if (role == null) return null;
    final roleId = _stringId(role['id']);
    if (roleId == null) return null;
    normalizedRoles.add(<String, dynamic>{...role, 'id': roleId});
  }
  return <String, dynamic>{...user, 'id': id, 'roles': normalizedRoles};
}

String? _stringId(Object? value) {
  if (value is String && value.trim().isNotEmpty) return value;
  if (value is int) return value.toString();
  return null;
}

Map<String, dynamic>? _stringKeyedMap(Object? value) {
  if (value is! Map) return null;
  final result = <String, dynamic>{};
  for (final entry in value.entries) {
    if (entry.key is! String) return null;
    result[entry.key as String] = entry.value;
  }
  return result;
}

String? _readMessage(Map<String, dynamic>? json) {
  final message = json?['message'];
  return message is String && message.trim().isNotEmpty ? message.trim() : null;
}
