import 'package:amina_ec/src/models/coach.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/providers/class_reservation_provider.dart';
import 'package:amina_ec/src/providers/coachs_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminChangeCoachController extends GetxController {
  final CoachProvider _coachProvider = CoachProvider();
  final ClassReservationProvider _reservationProvider = ClassReservationProvider();

  var oldCoachId = ''.obs;
  var oldCoachName = ''.obs;
  var classDate = ''.obs;
  var classTime = ''.obs;
  var endTime = ''.obs;

  var coaches = <Coach>[].obs;
  var selectedCoachId = ''.obs;
  var loading = false.obs;
  var loadingCoaches = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};

    oldCoachId.value = (args['coach_id'] ?? args['old_coach_id'] ?? '').toString();
    oldCoachName.value = (args['coach_name'] ?? args['old_coach_name'] ?? '').toString();
    classDate.value = (args['class_date'] ?? '').toString();
    classTime.value = (args['class_time'] ?? '').toString();

    if (classTime.value.contains('.')) {
      classTime.value = classTime.value.split('.')[0];
    }

    loadCoachesAndInferEndTime();
  }

  Future<void> loadCoachesAndInferEndTime() async {
    loadingCoaches.value = true;
    try {
      final list = await _coachProvider.getAll();
      coaches.value = list;

      // inferir end_time desde el coach actual
      final old = coaches.firstWhereOrNull((c) => c.id == oldCoachId.value);
      if (old != null) {
        final match = old.schedules.firstWhereOrNull((s) =>
        s.date == classDate.value &&
            (s.start_time ?? '').startsWith(classTime.value.substring(0, min(5, classTime.value.length))));
        if (match != null && (match.end_time ?? '').isNotEmpty) {
          endTime.value = match.end_time!.split('.').first;
        }
      }

      // fallback si no se encontró end_time
      if (endTime.value.isEmpty) {
        try {
          final parts = classTime.value.split(':');
          final hh = int.tryParse(parts[0]) ?? 0;
          final mm = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
          final startDt = DateTime(2000, 1, 1, hh, mm);
          final endDt = startDt.add(const Duration(hours: 1));
          final hhStr = endDt.hour.toString().padLeft(2, '0');
          final mmStr = endDt.minute.toString().padLeft(2, '0');
          endTime.value = '$hhStr:$mmStr:00';
        } catch (_) {
          endTime.value = classTime.value;
        }
      }

      // formatear HH:MM:SS
      if (!classTime.value.contains(':')) {
        classTime.value = '${classTime.value}:00:00';
      } else if (classTime.value.split(':').length == 2) {
        classTime.value = '${classTime.value}:00';
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al cargar los coaches: $e');
    } finally {
      loadingCoaches.value = false;
    }
  }

  int min(int a, int b) => a < b ? a : b;

  void selectCoach(String id) {
    selectedCoachId.value = id;
  }

  Future<void> confirmAndSend(BuildContext context) async {
    if (selectedCoachId.value.isEmpty) {
      Get.snackbar('Aviso', 'Seleccione un nuevo coach');
      return;
    }

    final newCoach = coaches.firstWhere((c) => c.id == selectedCoachId.value);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar cambio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Desea reasignar la clase?', style: GoogleFonts.poppins(color: darkGrey,),),
            const SizedBox(height: 8),
            Text('📅 Fecha: ${classDate.value}',style: GoogleFonts.poppins(color: darkGrey,),),
            Text('⏰ Hora: ${classTime.value.substring(0,5)} - ${endTime.value.substring(0,5)}',style: GoogleFonts.poppins(color: darkGrey,),),
            const SizedBox(height: 8),
            Text('Coach actual: ${oldCoachName.value}',style: GoogleFonts.poppins(color: darkGrey,),),
            Text('Nuevo coach: ${newCoach.user?.name ?? '—'} ${newCoach.user?.lastname ?? ''}',style: GoogleFonts.poppins(color: darkGrey,)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancelar', style: TextStyle(color: indigoAmina, fontSize: 16),)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: almostBlack),
            onPressed: () => Get.back(result: true),
            child: const Text('Confirmar', style: TextStyle(color: whiteLight, fontSize: 16),),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    loading.value = true;
    try {
      final ResponseApi res = await _reservationProvider.reassignCoach(
        oldCoachId: oldCoachId.value,
        newCoachId: selectedCoachId.value,
        date: classDate.value,
        startTime: classTime.value,
        endTime: endTime.value,
      );

      if (res.success == true) {
        Get.snackbar('Éxito', res.message ?? 'Coach reasignado correctamente');
        Get.back(result: true);
      } else {
        Get.snackbar('Error', res.message ?? 'No se pudo reasignar el coach');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al reasignar coach: $e');
    } finally {
      loading.value = false;
    }
  }
}
