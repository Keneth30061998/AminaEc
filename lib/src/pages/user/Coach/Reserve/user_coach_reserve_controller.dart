import 'package:get/get.dart';

class UserCoachReserveController extends GetxController {
  // El set observable para almacenar el equipo seleccionado (sólo un elemento a la vez)
  var selectedEquipos = <int>{}.obs;

  // Alterna la selección:
  // - Si ya está seleccionado, lo deselecciona.
  // - Si no, limpia la selección previa y selecciona el nuevo equipo.
  void toggleEquipo(int equipo) {
    if (selectedEquipos.contains(equipo)) {
      selectedEquipos.remove(equipo);
    } else {
      selectedEquipos.clear();
      selectedEquipos.add(equipo);
    }
  }
}
