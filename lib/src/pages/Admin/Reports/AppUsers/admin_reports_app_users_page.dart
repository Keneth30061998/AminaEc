import 'package:amina_ec/src/pages/Admin/Reports/AppUsers/admin_reports_app_users_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminReportsAppUsersPage extends StatelessWidget {
  final AdminReportsAppUsersController con =
  Get.put(AdminReportsAppUsersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        title: const Text('Usuarios registrados'),
        centerTitle: true,
        backgroundColor: whiteLight,
        surfaceTintColor: whiteLight,
        forceMaterialTransparency: true,
      ),
      body: Column(
        children: [
          // 🔍 Campo de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: TextField(
              controller: con.searchController,
              onChanged: con.filterUsers,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar por nombre...',
                hintStyle: GoogleFonts.poppins(fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🧾 Contenido principal (lista o mensajes)
          Expanded(
            child: Obx(() {
              if (con.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (con.filteredUsers.isEmpty) {
                return RefreshIndicator(
                  color: almostBlack,
                  backgroundColor: almostBlack,
                  onRefresh: con.getUsers,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 150),
                      Center(
                        child: Text(
                          'No hay usuarios registrados',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: con.getUsers,
                color: almostBlack,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: con.filteredUsers.length,
                  itemBuilder: (_, i) {
                    final user = con.filteredUsers[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 1,
                      shadowColor: Colors.black12,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: user.photo_url != null && user.photo_url!.isNotEmpty
                                  ? NetworkImage(user.photo_url!)
                                  : const AssetImage('assets/img/user_placeholder.png')
                              as ImageProvider,
                              backgroundColor: whiteLight,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: almostBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.badge_outlined,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        'CI: ${user.ci ?? ''}',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13, color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Nacimiento: ${user.birthDate?.split('T').first.split('-').reversed.join('/') ?? ''}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.directions_bike_outlined,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Rides: ${user.totalRides ?? 0}',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13, color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  tooltip: 'Información de planes',
                                  onPressed: () => con.showUserPlansInfo(user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.calendar_month_outlined),
                                  tooltip: 'Extender días',
                                  onPressed: () => con.showExtendDialog(user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  tooltip: 'Agregar rides',
                                  onPressed: () => con.showRidesDialog(user),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
