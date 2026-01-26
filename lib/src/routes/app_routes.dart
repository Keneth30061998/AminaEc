import 'package:amina_ec/src/pages/Admin/Coach/Register/admin_coach_register_image_page.dart';
import 'package:amina_ec/src/pages/Admin/Coach/Register/admin_coach_register_page.dart';
import 'package:amina_ec/src/pages/Admin/Coach/Register/admin_coach_register_schedule_page.dart';
import 'package:amina_ec/src/pages/Admin/Coach/Update/Schedule/admin_coach_update_schedule_page.dart';
import 'package:amina_ec/src/pages/Admin/Coach/Update/admin_coach_update_page.dart';
// --- Admin: Home, Coach y Planes ---
import 'package:amina_ec/src/pages/Admin/Home/admin_home_page.dart';
import 'package:amina_ec/src/pages/Admin/Reports/PlanUsage/admin_reports_plan_usage_page.dart';
import 'package:amina_ec/src/pages/Admin/Services/Sponsor/List/admin_sponsor_list_page.dart';
import 'package:amina_ec/src/pages/Admin/Services/Sponsor/Register/admin_sponsor_register_page.dart';
import 'package:amina_ec/src/pages/Admin/Services/Sponsor/Update/admin_sponsor_update_page.dart';

// --- Coach ---
import 'package:amina_ec/src/pages/Coach/Home/coach_home_page.dart';
import 'package:amina_ec/src/pages/Login/login_page.dart';
// --- Roles y Firma ---
import 'package:amina_ec/src/pages/Roles/roles_page.dart';
import 'package:amina_ec/src/pages/Signature/signature_page.dart';
// ===========================
//  Importación de páginas
// ===========================

// --- Splash y Login ---
import 'package:amina_ec/src/pages/Splash/splash_page.dart';
import 'package:amina_ec/src/pages/user/Coach/Reserve/user_coach_reserve_page.dart';
// --- Usuario ---
import 'package:amina_ec/src/pages/user/Home/user_home_page.dart';
import 'package:amina_ec/src/pages/user/Plan/Buy/AddCard/user_plan_buy_addCard_webview_page.dart';
import 'package:amina_ec/src/pages/user/Plan/Buy/Resume/user_plan_buy_resume_page.dart';
import 'package:amina_ec/src/pages/user/Plan/List/user_plan_list_page.dart';
import 'package:amina_ec/src/pages/user/Profile/Update/user_profile_update_page.dart';
// --- Registro de usuarios ---
import 'package:amina_ec/src/pages/user/Register/register_page.dart';
import 'package:amina_ec/src/pages/user/Register/register_page_image.dart';
import 'package:get/get.dart';

import '../pages/Admin/Reports/UserPlans/admin_user_plans_page.dart';
import '../pages/Admin/Services/Plan/Update/admin_plan_update_page.dart';

// ===========================
//  Definición de rutas GetX
// ===========================

final List<GetPage> appRoutes = [
  // --- General ---
  GetPage(name: '/splash', page: () => SplashPage()),
  GetPage(name: '/login', page: () => LoginPage()),

  // --- Registro y roles ---
  GetPage(name: '/register', page: () => RegisterPage()),
  GetPage(name: '/register-image', page: () => RegisterPageImage()),
  GetPage(name: '/roles', page: () => RolesPage()),
  GetPage(name: '/signature', page: () => SignaturePage()),

  // --- Usuario ---
  GetPage(name: '/user/home', page: () => UserHomePage()),
  GetPage(name: '/user/profile/update', page: () => UserProfileUpdatePage()),
  GetPage(name: '/user/plan/buy/addCard', page: () => AddCardWebViewPage()),
  GetPage(name: '/user/plan/buy/resume', page: () => UserPlanBuyResumePage()),
  GetPage(name: '/user/coach/reserve', page: () => UserCoachReservePage()),
  GetPage(name: '/user/plan', page: () => UserPlanListPage()),

  // --- Coach ---
  GetPage(name: '/coach/home', page: () => CoachHomePage()),

  // --- Admin ---
  GetPage(name: '/admin/home', page: () => AdminHomePage()),

  // --- Admin > Coach ---
  GetPage(name: '/admin/coach/register', page: () => AdminCoachRegisterPage()),
  GetPage(
    name: '/admin/coach/register-image',
    page: () => AdminCoachRegisterImagePage(),
  ),
  GetPage(
    name: '/admin/coach/register-schedule',
    page: () => AdminCoachRegisterSchedulePage(),
  ),
  GetPage(name: '/admin/coach/update', page: () => AdminCoachUpdatePage()),
  GetPage(
    name: '/admin/coach/update/schedule',
    page: () => AdminCoachUpdateSchedulePage(),
  ),

  // --- Admin > Sponsors ---
  GetPage(name: '/admin/sponsors/create', page: () => AdminSponsorRegisterPage()),
  GetPage(name: '/admin/sponsors/update', page: () => AdminSponsorUpdatePage()),
  // --- Admin > Planes ---
  GetPage(name: '/admin/plans/update', page: () => AdminPlanUpdatePage()),

  // --- Admin > user - plan
  GetPage(name: '/admin/users/plans', page: () => AdminUserPlansPage()),
  GetPage(name: '/admin/users/history', page: () => AdminUserHistoryPage()),

];
