import 'package:amina_ec/src/pages/user/Start/reschedule_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amina_ec/src/models/app_banner.dart';
import 'package:amina_ec/src/providers/app_banner_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/Socket/socket_service.dart';
import '../../../models/coach.dart';
import '../../../models/scheduled_class.dart';
import '../../../models/user.dart';
import '../../../models/user_plan.dart';
import '../../../providers/class_reservation_provider.dart';
import '../../../providers/coachs_provider.dart';
import '../../../providers/scheduled_class_provider.dart';
import '../../../providers/user_plan_provider.dart';
import '../../../providers/users_provider.dart';
import '../../../utils/color.dart';
import 'package:amina_ec/src/services/calendar_sync_service.dart';

class UserStartController extends GetxController with WidgetsBindingObserver {
  User user = User.fromJson(GetStorage().read('user') ?? {});

  final CoachProvider coachProvider = CoachProvider();
  final UserPlanProvider userPlanProvider = UserPlanProvider();
  final AppBannerProvider appBannerProvider = AppBannerProvider();
  final ScheduledClassProvider scheduledClassProvider =
  ScheduledClassProvider();
  final ClassReservationProvider classResProv = ClassReservationProvider();

  final RxList<UserPlan> acquiredPlans = <UserPlan>[].obs;
  var coaches = <Coach>[].obs;
  final RxInt totalRides = 0.obs;
  final RxList<ScheduledClass> scheduledClasses = <ScheduledClass>[].obs;
  final RxInt attendedClasses = 0.obs;
  final RxInt completedRides = 0.obs;
  final RxList<AppBanner> activeBanners = <AppBanner>[].obs;
  final RxBool isBannerLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    /*
   * Primero se reconstruye el socket con el token actual.
   * Después se registran los listeners sobre la nueva instancia.
   */
    SocketService().updateUserSession(user);

    _setupSocketListeners();

    getCoaches();
    getTotalRides();
    getScheduledClasses();
    getAcquiredPlans();
    getCompletedRides();
    getAppBanner();
  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    if (state == AppLifecycleState.resumed) {
      getAppBanner();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);

    SocketService().off('app-banner:changed');

    super.onClose();
  }

  void _setupSocketListeners() {
    SocketService().on(
      'coach:new',
          (_) => getCoaches(),
    );

    SocketService().on(
      'coach:delete',
          (_) => getCoaches(),
    );

    SocketService().on(
      'coach:update',
          (_) => getCoaches(),
    );

    SocketService().on(
      'rides:updated',
          (_) => refreshTotalRides(),
    );

    SocketService().on(
      'class:coach:reserved',
          (payload) {
        if (payload['user_id'].toString() == user.id.toString()) {
          getScheduledClasses();
        }
      },
    );

    SocketService().on(
      'class:reserved',
          (_) => getScheduledClasses(),
    );

    SocketService().on(
      'class:coach:rescheduled',
          (payload) {
        if (payload['user_id'].toString() == user.id.toString()) {
          getScheduledClasses();
        }
      },
    );

    /*
   * Este evento es exclusivo del banner.
   * Se elimina primero para evitar listeners duplicados.
   */
    SocketService().off('app-banner:changed');

    SocketService().on(
      'app-banner:changed',
      _handleBannerSocketEvent,
    );
  }

  void getCompletedRides() async {
    if (user.session_token == null || user.session_token!.isEmpty) return;

    try {
      final count = await UserProvider().getCompletedRides(user.session_token!);
      completedRides.value = count;
    } catch (_) {
      completedRides.value = 0;
    }
  }

  void getAttendedClasses() async {
    if (user.session_token == null || user.session_token!.isEmpty) return;
    try {
      int count = await UserProvider()
          .getAttendedClasses(user.session_token!, userId: user.id);
      attendedClasses.value = count;
    } catch (_) {}
  }

  void getAcquiredPlans() async {
    if (user.session_token != null) {
      final result =
      await userPlanProvider.getAllPlansWithRides(user.session_token!);
      acquiredPlans.value = result;
    }
  }

  void getCoaches() async {
    List<Coach> result = await coachProvider.getAll();
    coaches.value = result;
  }

  void getTotalRides() async {
    if (user.session_token != null) {
      int rides =
      await userPlanProvider.getTotalActiveRides(user.session_token!);
      totalRides.value = rides;
    }
  }

  void refreshTotalRides() {
    getTotalRides();
    getAcquiredPlans();
  }

  void getScheduledClasses() async {
    List<ScheduledClass> result = await scheduledClassProvider.getByUser();
    scheduledClasses.value = result;
  }

  void onPressReschedule(ScheduledClass c, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => RescheduleSheet(
        reservation: c,
        coaches: coaches,
        onSuccess: () {
          getScheduledClasses();
        },
      ),
    );
  }

  void onPressCancel(ScheduledClass c, BuildContext context) async {
    try {
      // Convertir classDate + classTime a DateTime local
      final dateString = c.classDate.split('T').first;
      final timeString = c.classTime.substring(0, 5); // HH:mm
      final partsDate = dateString.split('-').map(int.parse).toList();
      final partsTime = timeString.split(':').map(int.parse).toList();

      final classDateTime = DateTime(
        partsDate[0],
        partsDate[1],
        partsDate[2],
        partsTime[0],
        partsTime[1],
      );

      final now = DateTime.now();
      final hoursDiff = classDateTime.difference(now).inHours;

      if (hoursDiff < 12) {
        Get.snackbar(
          'No es posible cancelar',
          'Solo puedes cancelar con al menos 12 horas de anticipación.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      final shouldCancel = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Cancelar clase',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          content: Text(
            '¿Estás seguro de cancelar tu clase?\nTu ride será devuelto.',
            style: GoogleFonts.roboto(color: darkGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                'Volver',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: indigoAmina,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: almostBlack),
              onPressed: () => Get.back(result: true),
              child: Text(
                'Cancelar clase',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: whiteLight,
                ),
              ),
            ),
          ],
        ),
      );

      if (shouldCancel != true) return;

      final res = await classResProv.cancelClass(c.id);

      if (res != null && (res.success == true)) {
        // ✅ PARTE B: borrar evento del calendario NATIVO del dispositivo
        try {
          await CalendarSyncService.instance.deleteEvent(
            reservationId: c.id.toString(),
          );
        } catch (_) {
          // no bloqueante
        }

        scheduledClasses.removeWhere((sc) => sc.id == c.id);
        refreshTotalRides();

        Get.snackbar(
          'Clase cancelada',
          'Tu ride ha sido devuelto.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final msg = (res != null && res.message != null)
            ? res.message!
            : 'No se pudo cancelar la clase.';
        Get.snackbar(
          'Error',
          msg,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un error al cancelar la clase: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void showUserPlansInfo() async {
    final token = user.session_token!;
    final plans = await userPlanProvider.getUserPlansSummary(user.id!, token);

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
                      "${plan['is_course'].toString() == '1' ? 'Curso' : 'Regular'} · ${plan['plan_name'] ?? 'Plan sin nombre'}",
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

  void _handleBannerSocketEvent(
      dynamic rawData,
      ) {
    try {
      if (rawData == null) {
        activeBanners.clear();

        return;
      }

      dynamic rawList = rawData;

      /**
       * Compatibilidad:
       *
       * {
       *   data: [...]
       * }
       */
      if (rawData is Map && rawData['data'] is List) {
        rawList = rawData['data'];
      }

      if (rawList is! List) {
        getAppBanner();

        return;
      }

      final banners = rawList
          .map(
            (item) => AppBanner.fromJson(
          Map<String, dynamic>.from(
            item,
          ),
        ),
      )
          .where(
            (banner) => banner.isActive && banner.hasImage,
      )
          .toList();

      banners.sort(
            (a, b) => a.position.compareTo(
          b.position,
        ),
      );

      activeBanners.assignAll(
        banners,
      );
    } catch (error) {
      debugPrint(
        '❌ Error procesando socket del banner: $error',
      );

      getAppBanner();
    }
  }

  Future<void> getAppBanner() async {
    isBannerLoading.value = true;

    try {
      final banners = await appBannerProvider.getActive();

      activeBanners.assignAll(
        banners,
      );
    } catch (error) {
      debugPrint(
        '❌ Error obteniendo app banner: $error',
      );
    } finally {
      isBannerLoading.value = false;
    }
  }

  Future<void> openBannerLink(AppBanner banner) async {
    final rawUrl = banner.linkUrl?.trim() ?? '';

    if (rawUrl.isEmpty) return;

    final uri = Uri.tryParse(rawUrl);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      Get.snackbar(
        'Enlace no válido',
        'No se pudo abrir el enlace del banner.',
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          'No se pudo abrir',
          'El navegador no pudo abrir este enlace.',
          backgroundColor: Colors.white,
          colorText: Colors.redAccent,
        );
      }
    } catch (error) {
      Get.snackbar(
        'No se pudo abrir',
        'Ocurrió un error al abrir el enlace.',
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );
    }
  }
}

