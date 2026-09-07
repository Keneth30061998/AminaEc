import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Shared/admin_ui.dart';
import '../Coach/List/admin_coach_list_page.dart';
import '../Services/Plan/Register/admin_plan_register_page.dart';
import '../Services/Sponsor/List/admin_sponsor_list_page.dart';
import '../../../widgets/app_banner_manager_sheet.dart';
import 'admin_notification_page.dart';

class AdminManagementPage extends StatelessWidget {
  const AdminManagementPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const AdminHeader(title: 'Gestión', subtitle: 'Administración'),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          AdminGroup(label: 'Equipo', children: [
            AdminActionTile(
                icon: Icons.directions_bike_outlined,
                title: 'Coaches',
                onTap: () => Get.to(
                    () => AdminStyled(child: AdminCoachListPage()),
                    routeName: '/admin/management/coaches')),
          ]),
          const SizedBox(height: 28),
          AdminGroup(label: 'Servicios', children: [
            AdminActionTile(
                icon: Icons.credit_card_outlined,
                title: 'Planes',
                onTap: () => Get.to(
                    () => AdminStyled(child: AdminPlanRegisterPage()),
                    routeName: '/admin/management/plans')),
            AdminActionTile(
                icon: Icons.card_giftcard_outlined,
                title: 'Beneficios',
                onTap: () => Get.to(
                    () => AdminStyled(child: AdminSponsorListPage()),
                    routeName: '/admin/management/benefits')),
          ]),
          const SizedBox(height: 28),
          AdminGroup(label: 'Comunicación', children: [
            AdminActionTile(
                icon: Icons.campaign_outlined,
                title: 'Banners',
                onTap: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AppBannerManagerSheet())),
            AdminActionTile(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                onTap: () => Get.to(
                    () => const AdminStyled(child: AdminNotificationPage()))),
          ]),
        ]),
      );
}
