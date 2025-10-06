import 'package:get/get.dart';

/// Controlador global de eventos relacionados con coaches.
class CoachEvents extends GetxController {
  static CoachEvents get to => Get.find<CoachEvents>();

  /// Variable reactiva que emite cada vez que hay un cambio en los coaches.
  final coachUpdated = false.obs;

  /// Stream que pueden escuchar otros controladores.
  Stream<bool> get onCoachUpdated => coachUpdated.stream;

  /// Notifica que los coaches se actualizaron.
  void notifyCoachesUpdated() {
    coachUpdated.value = !coachUpdated.value; // alterna el valor para forzar el cambio
  }
}
