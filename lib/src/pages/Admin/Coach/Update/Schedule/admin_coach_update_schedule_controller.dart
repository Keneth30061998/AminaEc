import 'package:amina_ec/src/models/coach.dart';
import 'package:amina_ec/src/models/schedule.dart';
import 'package:amina_ec/src/providers/coachs_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/Socket/socket_service.dart';

class AdminCoachUpdateScheduleController extends GetxController {
  final CoachProvider _coachProvider = CoachProvider();
  final List<String> dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  Map<String, List<Map<String, TimeOfDay?>>> horariosPorDia = {};
  late Coach coach;

  @override
  void onInit() {
    super.onInit();
    coach = Get.arguments as Coach;
    _cargarHorariosExistentes();
  }

  void _cargarHorariosExistentes() {
    for (var dia in dias) {
      horariosPorDia[dia] = [];
    }

    for (var horario in coach.schedules) {
      String dia = _capitalizar(horario.day ?? '');
      TimeOfDay entrada = _parseTime(horario.start_time!);
      TimeOfDay salida = _parseTime(horario.end_time!);

      if (dias.contains(dia)) {
        horariosPorDia[dia]!.add({'entrada': entrada, 'salida': salida});
      }
    }

    update();
  }

  void agregarRango(String dia) {
    horariosPorDia[dia]?.add({'entrada': null, 'salida': null});
    update();
  }

  void eliminarRango(String dia, int index) {
    horariosPorDia[dia]?.removeAt(index);
    update();
  }

  void seleccionarHora(
      String dia, int index, String tipo, BuildContext context) async {
    TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      horariosPorDia[dia]?[index][tipo] = hora;
      update();
    }
  }

  String formatHora(TimeOfDay? hora) {
    if (hora == null) return '--:--';
    final horaStr = hora.hour.toString().padLeft(2, '0');
    final minutoStr = hora.minute.toString().padLeft(2, '0');
    return '$horaStr:$minutoStr';
  }

  Future<void> updateSchedule(BuildContext context) async {
    List<Schedule> nuevosHorarios = [];

    horariosPorDia.forEach((dia, rangos) {
      for (var rango in rangos) {
        if (rango['entrada'] != null && rango['salida'] != null) {
          nuevosHorarios.add(Schedule(
            day: dia,
            start_time: formatHora(rango['entrada']),
            end_time: formatHora(rango['salida']),
          ));
        }
      }
    });

    if (nuevosHorarios.isEmpty) {
      Get.snackbar('Error', 'Debes ingresar al menos un horario válido');
      return;
    }

    final res = await _coachProvider.updateSchedule(coach.id!, nuevosHorarios);
    if (res.statusCode == 201) {
      SocketService()
          .emit('coach:update', {'id': coach.id, 'type': 'schedule'});
      Get.back();
      Get.snackbar('Éxito', 'Horarios actualizados correctamente');
    } else {
      Get.snackbar('Error', 'No se pudo actualizar los horarios');
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _capitalizar(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}
