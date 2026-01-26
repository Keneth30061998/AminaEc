import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/pages/Admin/Reports/AppUsers/admin_reports_app_users_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminReportsAppUsersPage extends StatelessWidget {
  final AdminReportsAppUsersController con = Get.put(AdminReportsAppUsersController());

  AdminReportsAppUsersPage({super.key});

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
        actions: [
          _AppBarIcon(
            icon: Icons.picture_as_pdf,
            tooltip: 'Exportar PDF',
            onTap: () => con.exportPDF(context),
          ),
          const SizedBox(width: 6),
          _AppBarIcon(
            icon: Icons.grid_on,
            tooltip: 'Exportar Excel',
            onTap: () => con.exportExcel(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER + SEARCH
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _SearchPill(
                    controller: con.searchController,
                    onChanged: con.filterUsers,
                  ),
                ],
              ),
            ),

            // LIST
            Expanded(
              child: Obx(() {
                if (con.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = con.filteredUsers;
                if (list.isEmpty) {
                  return RefreshIndicator(
                    color: almostBlack,
                    onRefresh: con.getUsers,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: const [
                        SizedBox(height: 110),
                        _EmptyState(),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: almostBlack,
                  onRefresh: con.getUsers,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 18),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final user = list[i];
                      return _UserCard(
                        user: user,
                        onTap: () => Get.toNamed('/admin/users/plans', arguments: user),
                        onActions: () => _showUserActions(context, user),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserActions(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHeader(user: user),
              const SizedBox(height: 10),

              _ActionTile(
                icon: Icons.info_outline,
                title: 'Información de planes',
                subtitle: 'Ver planes activos y detalles',
                onTap: () {
                  Get.back();
                  con.showUserPlansInfo(user);
                },
              ),
              _ActionTile(
                icon: Icons.calendar_month_outlined,
                title: 'Extender días',
                subtitle: 'Añadir días al plan activo',
                onTap: () {
                  Get.back();
                  con.showExtendDialog(user);
                },
              ),
              _ActionTile(
                icon: Icons.add_circle_outline,
                title: 'Agregar rides',
                subtitle: 'Devolver rides al usuario',
                onTap: () {
                  Get.back();
                  con.showRidesDialog(user);
                },
              ),
              _ActionTile(
                icon: Icons.timeline_outlined,
                title: 'Histórico',
                subtitle: 'Ver eventos del usuario (planes/clases/asistencia)',
                onTap: () {
                  Get.back();
                  Get.toNamed('/admin/users/history', arguments: user);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _AppBarIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xfff3f4f6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text(value,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: almostBlack,
                      fontWeight: FontWeight.w800,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchPill({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          hintText: 'Buscar por nombre...',
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  final VoidCallback onActions;

  const _UserCard({
    required this.user,
    required this.onTap,
    required this.onActions,
  });

  @override
  Widget build(BuildContext context) {
    final birth = _fmtBirth(user.birthDate);

    return Material(
      color: colorBackgroundBox,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black12),
            //boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xfff3f4f6),
                backgroundImage: (user.photo_url != null && user.photo_url!.isNotEmpty)
                    ? NetworkImage(user.photo_url!)
                    : null,
                child: (user.photo_url == null || user.photo_url!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.black54)
                    : null,
              ),
              const SizedBox(width: 12),

              // INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.name ?? ''} ${user.lastname ?? ''}'.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: almostBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(icon: Icons.badge_outlined, label: 'CI: ${user.ci ?? '-'}'),
                        _MetaChip(
                          icon: Icons.directions_bike_outlined,
                          label: 'Rides: ${user.totalRides ?? 0}',
                        ),
                        if (birth.isNotEmpty)
                          _MetaChip(icon: Icons.cake_outlined, label: birth),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ACTIONS
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onActions,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xfff3f4f6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.more_horiz, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtBirth(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      return 'Nacimiento: ${DateFormat('dd/MM/yyyy').format(dt)}';
    } catch (_) {
      // fallback si viene con formato raro
      final raw = iso.split('T').first;
      final parts = raw.split('-');
      if (parts.length == 3) return 'Nacimiento: ${parts.reversed.join('/')}';
      return '';
    }
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xfff3f4f6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.black87, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final User user;
  const _SheetHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfff9f9f9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xfff3f4f6),
            backgroundImage: (user.photo_url != null && user.photo_url!.isNotEmpty)
                ? NetworkImage(user.photo_url!)
                : null,
            child: (user.photo_url == null || user.photo_url!.isEmpty)
                ? const Icon(Icons.person, color: Colors.black54)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.name ?? ''} ${user.lastname ?? ''}'.trim(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: almostBlack),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email ?? '',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xfff3f4f6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black54),
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: const Icon(Icons.person_off_outlined, size: 34, color: Colors.black54),
        ),
        const SizedBox(height: 14),
        Text(
          'No hay usuarios registrados',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Desliza hacia abajo para actualizar.',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
