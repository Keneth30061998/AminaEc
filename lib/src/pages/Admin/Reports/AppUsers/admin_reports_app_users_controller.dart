import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/providers/user_plan_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../providers/admin_users_provider.dart';

class AdminReportsAppUsersController extends GetxController {
  final AdminUsersProvider _provider = AdminUsersProvider();

  var users = <User>[].obs; // Lista completa
  var filteredUsers = <User>[].obs; // Lista filtrada
  var loading = false.obs;

  var searchQuery = ''.obs; // Texto de búsqueda
  final searchController = TextEditingController();

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  @override
  void onInit() {
    super.onInit();
    getUsers();
  }

  Future<void> getUsers() async {
    loading.value = true;
    users.value = await _provider.getAllUsers(userSession.session_token!);
    filteredUsers.value = users; // Inicialmente, todos
    loading.value = false;
  }

  // 🔍 Filtrar usuarios por nombre
  void filterUsers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredUsers.value = users;
    } else {
      filteredUsers.value = users
          .where(
              (u) => (u.name ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> extendPlan(User user, int days) async {
    ResponseApi res = await _provider.extendPlan(
      user.id!,
      days,
      userSession.session_token!,
    );
    Get.snackbar('Extender plan', res.message ?? 'Error');
    await getUsers();
  }

  Future<void> returnRides(User user, int rides) async {
    ResponseApi res = await _provider.returnRides(
      user.id!,
      rides,
      userSession.session_token!,
    );
    Get.snackbar('Devolver rides', res.message ?? 'Error');
    await getUsers();
  }

  // 🧮 Diálogo para extender plan
  void showExtendDialog(User user) {
    int days = 1;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Extender plan',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selecciona los días a añadir:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: darkGrey),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: days > 1 ? () => setState(() => days--) : null,
                    ),
                    Text(
                      '$days días',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: almostBlack,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => days++),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: Get.back,
                child: Text('Cancelar', style: TextStyle(color: indigoAmina)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Get.back();
                  await extendPlan(user, days);
                },
                child: Text('Confirmar', style: TextStyle(color: whiteLight)),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🚴 Diálogo para añadir rides
  void showRidesDialog(User user) {
    int rides = 1;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[100],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Añadir Rides',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selecciona la cantidad de rides a añadir:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: darkGrey),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                          rides > 1 ? () => setState(() => rides--) : null,
                    ),
                    Text(
                      '$rides rides',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: almostBlack,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => rides++),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: Get.back,
                child: Text('Cancelar', style: TextStyle(color: indigoAmina)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Get.back();
                  await returnRides(user, rides);
                },
                child: Text('Confirmar', style: TextStyle(color: whiteLight)),
              ),
            ],
          );
        },
      ),
    );
  }

  void showUserPlansInfo(User user) async {
    final token = userSession.session_token!;
    final plans = await _provider.getUserPlansSummary(user.id!, token);

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          "Planes de ${user.name}",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: almostBlack,
          ),
        ),
        content: SizedBox(
          width: Get.width * 0.8,
          child: plans.isEmpty
              ? Center(
                  child: Text(
                    "Este usuario no tiene planes activos.",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: plans.map((plan) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      width: Get.width * 0.8,
                      decoration: BoxDecoration(
                        color: colorBackgroundBox,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan["plan_name"] ?? "Plan sin nombre",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: indigoAmina,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Rides restantes: ${plan["remaining_rides"]}",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: almostBlack,
                            ),
                          ),
                          Text(
                            "Inicio: ${plan["start_date"]?.split('T').first.split('-').reversed.join('/') ?? 'No definida'} ",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: almostBlack,
                            ),
                          ),
                          Text(
                            "Fin: ${plan["end_date"]?.split('T').first.split('-').reversed.join('/') ?? 'No definida'} ",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: almostBlack,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text("Cerrar",
                style: TextStyle(
                  color: indigoAmina,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                )),
          ),
        ],
      ),
    );
  }
}
