import 'dart:convert';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class CalendarSyncService {
  CalendarSyncService._();
  static final CalendarSyncService instance = CalendarSyncService._();

  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();
  final GetStorage _box = GetStorage();

  bool _tzReady = false;
  tz.Location? _localLocation;

  String? _cachedCalendarId;

  static const String _mapKey = 'calendar_event_map_v1';

  Future<void> _ensureTimezoneReady() async {
    if (_tzReady) return;

    tzdata.initializeTimeZones();

    try {
      final name = await FlutterTimezone.getLocalTimezone();
      _localLocation = tz.getLocation(name as String);
      tz.setLocalLocation(_localLocation!);
    } catch (_) {
      _localLocation = tz.UTC;
      tz.setLocalLocation(tz.UTC);
    }

    _tzReady = true;
  }

  Future<bool> _ensurePermissions() async {
    final perm = await _plugin.hasPermissions();
    if (perm.isSuccess == true && perm.data == true) return true;

    final req = await _plugin.requestPermissions();
    return req.isSuccess == true && req.data == true;
  }

  Future<String?> _getWritableCalendarId() async {
    if (_cachedCalendarId != null) return _cachedCalendarId;

    final result = await _plugin.retrieveCalendars();
    if (result.isSuccess != true || result.data == null || result.data!.isEmpty) {
      return null;
    }

    final calendars = result.data!;
    final writable = calendars.firstWhere(
          (c) => (c.isReadOnly ?? false) == false,
      orElse: () => calendars.first,
    );

    final id = (writable.id ?? '').trim();
    if (id.isEmpty) return null;

    _cachedCalendarId = id;
    return _cachedCalendarId;
  }

  Map<String, dynamic> _loadMap() {
    final raw = _box.read(_mapKey);
    if (raw == null) return {};

    if (raw is Map) {
      // Convertimos a Map<String, dynamic>
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }

    if (raw is String) {
      try {
        final decoded = json.decode(raw);
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {}
    }

    return {};
  }

  Future<void> _saveMap(Map<String, dynamic> m) async {
    await _box.write(_mapKey, json.encode(m));
  }

  /// ✅ A) Crear o actualizar evento ligado a una reserva
  Future<String?> createOrUpdateEvent({
    required String reservationId,
    required String title,
    required DateTime start,
    int durationMinutes = 50,
    String? description,
    String? location,
  }) async {
    await _ensureTimezoneReady();

    final okPerm = await _ensurePermissions();
    if (!okPerm) return null;

    final defaultCalId = await _getWritableCalendarId();
    if (defaultCalId == null) return null;

    final map = _loadMap();
    final existing = map[reservationId];

    String? existingEventId;
    String? existingCalendarId;

    if (existing is Map) {
      existingEventId = existing['eventId']?.toString();
      existingCalendarId = existing['calendarId']?.toString();
    }

    final finalCalendarId =
    (existingCalendarId != null && existingCalendarId.trim().isNotEmpty)
        ? existingCalendarId.trim()
        : defaultCalId;

    final loc = _localLocation ?? tz.local;
    final startTz = tz.TZDateTime.from(start, loc);
    final endTz = startTz.add(Duration(minutes: durationMinutes));

    final event = Event(
      finalCalendarId,
      eventId: (existingEventId != null && existingEventId.trim().isNotEmpty)
          ? existingEventId.trim()
          : null,
      title: title,
      description: description,
      start: startTz,
      end: endTz,
      reminders: <Reminder>[
        Reminder(minutes: 60),
        Reminder(minutes: 15),
      ],
    );

    final result = await _plugin.createOrUpdateEvent(event);

    if (result?.isSuccess != true) return null;

    final newEventId = (result?.data ?? '').toString().trim();
    if (newEventId.isEmpty) return null;

    map[reservationId] = {
      "calendarId": finalCalendarId,
      "eventId": newEventId,
    };
    await _saveMap(map);

    return newEventId;
  }

  /// ✅ B) Eliminar evento ligado a una reserva
  Future<bool> deleteEvent({required String reservationId}) async {
    await _ensureTimezoneReady();

    final okPerm = await _ensurePermissions();
    if (!okPerm) return false;

    final map = _loadMap();
    final entry = map[reservationId];

    if (entry is! Map) return false;

    final calendarId = entry['calendarId']?.toString().trim();
    final eventId = entry['eventId']?.toString().trim();

    if (calendarId == null || calendarId.isEmpty || eventId == null || eventId.isEmpty) {
      // Limpieza defensiva
      map.remove(reservationId);
      await _saveMap(map);
      return false;
    }

    final res = await _plugin.deleteEvent(calendarId, eventId);
    final ok = res.isSuccess == true && res.data == true;

    // Limpia mapping aunque no exista ya (evita basura)
    map.remove(reservationId);
    await _saveMap(map);

    return ok;
  }
}
