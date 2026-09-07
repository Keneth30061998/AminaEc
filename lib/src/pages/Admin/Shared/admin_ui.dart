import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Profile/Info/admin_profile_info_page.dart';

class AdminUi {
  static const ink = Color(0xFF1D1C21);
  static const muted = Color(0xFF727787);
  static const surface = Color(0xFFEFF3F4);
  static const border = Color(0xFFDFE4EA);
  static const indigo = Color(0xFF4D55F5);

  static ThemeData theme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: ink,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: ink,
      ),
      dividerColor: border,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        titleTextStyle: GoogleFonts.montserrat(
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
        backgroundColor: ink,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      )),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: border)),
      ),
    );
  }
}

class AdminStyled extends StatelessWidget {
  final Widget child;
  const AdminStyled({super.key, required this.child});
  @override
  Widget build(BuildContext context) =>
      Theme(data: AdminUi.theme(context), child: child);
}

class AdminHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  const AdminHeader(
      {super.key, required this.title, this.subtitle, this.actions = const []});
  @override
  Size get preferredSize => const Size.fromHeight(84);
  @override
  Widget build(BuildContext context) => AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 84,
        titleSpacing: 20,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AdminUi.ink)),
          if (subtitle != null)
            Text(subtitle!,
                style: GoogleFonts.poppins(fontSize: 13, color: AdminUi.muted)),
        ]),
        actions: [
          ...actions,
          const AdminProfileButton(),
          const SizedBox(width: 12)
        ],
      );
}

class AdminProfileButton extends StatelessWidget {
  const AdminProfileButton({super.key});
  @override
  Widget build(BuildContext context) {
    final raw = GetStorage().read('user');
    final data = raw is Map ? raw : <String, dynamic>{};
    final name = '${data['name'] ?? ''} ${data['lastname'] ?? ''}'.trim();
    final initials = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p.characters.first)
        .join()
        .toUpperCase();
    return IconButton(
      tooltip: 'Abrir perfil del administrador',
      onPressed: () => Get.to(() => AdminStyled(child: AdminProfileInfoPage())),
      icon: CircleAvatar(
          backgroundColor: AdminUi.surface,
          radius: 22,
          child: Text(initials.isEmpty ? 'AD' : initials,
              style: const TextStyle(
                  color: AdminUi.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700))),
    );
  }
}

class AdminActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const AdminActionTile(
      {super.key,
      required this.icon,
      required this.title,
      this.subtitle,
      required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        leading: Icon(icon, color: AdminUi.ink, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: const TextStyle(color: AdminUi.muted)),
        trailing: const Icon(Icons.chevron_right, color: AdminUi.ink),
        onTap: onTap,
      );
}

class AdminGroup extends StatelessWidget {
  final String? label;
  final List<Widget> children;
  const AdminGroup({super.key, this.label, required this.children});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4),
                child: Text(label!.toUpperCase(),
                    style: const TextStyle(
                        color: AdminUi.muted,
                        fontWeight: FontWeight.w700,
                        fontSize: 13))),
          Material(
            color: AdminUi.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: AdminUi.border)),
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 18, endIndent: 18),
                children[i],
              ]
            ]),
          ),
        ],
      );
}
