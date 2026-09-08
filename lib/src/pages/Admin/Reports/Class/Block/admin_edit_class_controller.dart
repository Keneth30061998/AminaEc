import 'package:amina_ec/src/models/class_reservation.dart';
import 'package:amina_ec/src/models/user.dart';
import 'package:amina_ec/src/providers/admin_users_provider.dart';
import 'package:amina_ec/src/providers/class_reservation_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AdminCoachBlockController extends GetxController {
  final ClassReservationProvider classReservationProvider =
  ClassReservationProvider();

  final AdminUsersProvider adminUsersProvider = AdminUsersProvider();

  final User userSession = User.fromJson(
    GetStorage().read('user') ?? {},
  );

  // ============================================================
  // DATOS DE LA CLASE RECIBIDOS POR Get.arguments
  // ============================================================

  String coachId = '';
  String coachName = '';
  String classDate = '';
  String classTime = '';

  // ============================================================
  // ESTADO DE BICICLETAS
  // ============================================================

  /// Bicicletas seleccionadas para bloqueo o desbloqueo.
  final RxList<int> selectedEquipos = <int>[].obs;

  /// Bicicletas con una reservación activa.
  final RxList<int> occupiedEquipos = <int>[].obs;

  /// Bicicletas bloqueadas por administración.
  final RxList<int> blockedEquipos = <int>[].obs;

  /// Relación bicicleta -> reservación activa.
  ///
  /// Permite conocer el reservation_id y los datos del usuario cuando
  /// el administrador presiona una bicicleta ocupada.
  final RxMap<int, ClassReservation> reservationByBike =
      <int, ClassReservation>{}.obs;

  // ============================================================
  // USUARIOS PARA ASIGNACIÓN
  // ============================================================

  final RxList<User> users = <User>[].obs;
  final RxList<User> filteredUsers = <User>[].obs;

  final TextEditingController userSearchController =
  TextEditingController();

  final RxString userSearchQuery = ''.obs;

  // ============================================================
  // ESTADOS DE CARGA
  // ============================================================

  final RxBool isLoading = false.obs;
  final RxBool isLoadingUsers = false.obs;
  final RxBool isProcessing = false.obs;

  late final Worker _searchWorker;

  @override
  void onInit() {
    super.onInit();

    _readArguments();

    _searchWorker = debounce<String>(
      userSearchQuery,
          (_) => _applyUserFilter(),
      time: const Duration(milliseconds: 250),
    );

    if (_hasValidClassArguments) {
      loadBikeStatus();
    } else {
      Future.microtask(() {
        Get.snackbar(
          'Datos incompletos',
          'No se pudo identificar el coach, la fecha o la hora de la clase.',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    }
  }

  @override
  void onClose() {
    _searchWorker.dispose();
    userSearchController.dispose();
    super.onClose();
  }

  // ============================================================
  // ARGUMENTOS DE NAVEGACIÓN
  // ============================================================

  /// Admite varios nombres de claves para no romper la navegación existente.
  ///
  /// Claves soportadas:
  /// - coach_id, coachId, id_coach
  /// - coach_name, coachName, instructor_name
  /// - class_date, classDate, date
  /// - class_time, classTime, start_time, time
  void _readArguments() {
    final dynamic rawArguments = Get.arguments;

    if (rawArguments is! Map) {
      return;
    }

    final arguments = Map<String, dynamic>.from(rawArguments);

    coachId = _readStringArgument(
      arguments,
      const ['coach_id', 'coachId', 'id_coach'],
    );

    coachName = _readStringArgument(
      arguments,
      const ['coach_name', 'coachName', 'instructor_name', 'instructor'],
    );

    classDate = _normalizeDate(
      _readStringArgument(
        arguments,
        const ['class_date', 'classDate', 'date'],
      ),
    );

    classTime = _normalizeTime(
      _readStringArgument(
        arguments,
        const ['class_time', 'classTime', 'start_time', 'time'],
      ),
    );
  }

  String _readStringArgument(
      Map<String, dynamic> arguments,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value = arguments[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }

  bool get _hasValidClassArguments =>
      coachId.isNotEmpty &&
          classDate.isNotEmpty &&
          classTime.isNotEmpty;

  // ============================================================
  // CARGAR ESTADO DE LAS BICICLETAS
  // ============================================================

  /// Consulta las reservaciones y bloqueos activos del horario.
  ///
  /// El backend devuelve datos personales completos únicamente porque
  /// la petición se realiza con el token del administrador.
  Future<void> loadBikeStatus({
    bool showError = true,
  }) async {
    if (!_hasValidClassArguments) {
      return;
    }

    try {
      isLoading.value = true;

      final reservations =
      await classReservationProvider.getReservationsForSlot(
        classDate: classDate,
        classTime: classTime,
      );

      final occupied = <int>[];
      final blocked = <int>[];
      final mappedReservations = <int, ClassReservation>{};

      for (final reservation in reservations) {
        final bicycle = reservation.bicycle;

        if (bicycle == null) {
          continue;
        }

        if (reservation.status == 'blocked') {
          blocked.add(bicycle);
          continue;
        }

        if (reservation.status == 'scheduled') {
          occupied.add(bicycle);
          mappedReservations[bicycle] = reservation;
        }
      }

      occupiedEquipos.assignAll(occupied);
      blockedEquipos.assignAll(blocked);
      reservationByBike.assignAll(mappedReservations);

      // Elimina selecciones que cambiaron de estado mientras se recargaba.
      selectedEquipos.removeWhere(
            (bicycle) => occupiedEquipos.contains(bicycle),
      );
    } catch (error) {
      if (showError) {
        Get.snackbar(
          'Error',
          'No se pudo actualizar el estado de las bicicletas: $error',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBikeStatus() =>
      loadBikeStatus();

  // ============================================================
  // INTERACCIÓN CON BICICLETAS
  // ============================================================

  /// Método central que debe llamarse al presionar una bicicleta.
  ///
  /// - Ocupada: muestra al usuario y la opción de remover.
  /// - Bloqueada: muestra la opción de seleccionarla para desbloquear.
  /// - Disponible: permite asignar un usuario o seleccionarla para bloqueo.
  void onBikePressed(int bicycle) {
    if (isProcessing.value) {
      return;
    }

    if (occupiedEquipos.contains(bicycle)) {
      _showOccupiedBikeOptions(bicycle);
      return;
    }

    if (blockedEquipos.contains(bicycle)) {
      _showBlockedBikeOptions(bicycle);
      return;
    }

    _showAvailableBikeOptions(bicycle);
  }

  /// Conserva compatibilidad con la interfaz anterior.
  ///
  /// Ya no debe utilizarse para bicicletas ocupadas.
  void toggleSeat(int bicycle) {
    if (occupiedEquipos.contains(bicycle)) {
      return;
    }

    if (selectedEquipos.contains(bicycle)) {
      selectedEquipos.remove(bicycle);
    } else {
      selectedEquipos.add(bicycle);
    }
  }

  void _showOccupiedBikeOptions(int bicycle) {
    final reservation = reservationByBike[bicycle];

    if (reservation == null) {
      Get.snackbar(
        'Información no disponible',
        'Actualizando el estado de la bicicleta.',
        snackPosition: SnackPosition.BOTTOM,
      );

      loadBikeStatus();
      return;
    }

    final userName = reservation.userName?.trim().isNotEmpty == true
        ? reservation.userName!.trim()
        : 'Usuario';

    final email = reservation.userEmail?.trim() ?? '';
    final photoUrl = reservation.userPhotoUrl?.trim() ?? '';

    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              const SizedBox(height: 18),
              Text(
                'Bicicleta $bicycle',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: almostBlack
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Esta bicicleta tiene una reservación activa.',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage:
                  photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? Text(
                    _initials(userName),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
                title: Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: email.isNotEmpty ? Text(email) : null,
              ),
              const SizedBox(height: 12),
              Obx(
                    () => SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isProcessing.value
                        ? null
                        : () {
                      Get.back<void>();
                      Future.delayed(
                        const Duration(milliseconds: 120),
                            () => _showReturnRideDialog(reservation),
                      );
                    },
                    icon: const Icon(
                      Icons.person_remove_outlined,
                    ),
                    label: const Text(
                      'Remover de la clase',
                    ),
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: almostBlack
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAvailableBikeOptions(int bicycle) {
    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              const SizedBox(height: 18),
              Text(
                'Bicicleta $bicycle disponible',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: almostBlack
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Puedes asignar un usuario o seleccionar la bicicleta para bloquearla.',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Get.back<void>();

                    Future.delayed(
                      const Duration(milliseconds: 120),
                          () => showUserPicker(bicycle),
                    );
                  },
                  icon: const Icon(
                    Icons.person_add_alt_1_outlined,
                  ),
                  label: const Text(
                    'Asignar usuario',
                  ),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: almostBlack
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    toggleSeat(bicycle);
                    Get.back<void>();
                  },
                  icon: Icon(
                    selectedEquipos.contains(bicycle)
                        ? Icons.remove_circle_outline
                        : Icons.block_outlined,
                    color: almostBlack,
                  ),
                  label: Text(
                    selectedEquipos.contains(bicycle)
                        ? 'Quitar de la selección'
                        : 'Seleccionar para bloqueo',
                    style: TextStyle(color: almostBlack),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showBlockedBikeOptions(int bicycle) {
    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              const SizedBox(height: 18),
              Text(
                'Bicicleta $bicycle bloqueada',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: almostBlack
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecciona la bicicleta y utiliza el botón de desbloqueo.',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    toggleSeat(bicycle);
                    Get.back<void>();
                  },
                  icon: Icon(
                    selectedEquipos.contains(bicycle)
                        ? Icons.remove_circle_outline
                        : Icons.lock_open_outlined,
                    color: Colors.redAccent,
                  ),
                  label: Text(
                    selectedEquipos.contains(bicycle)
                        ? 'Quitar de la selección'
                        : 'Seleccionar para desbloquear',
                    style: TextStyle(
                        color: Colors.redAccent
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    overlayColor: Colors.redAccent,
                    surfaceTintColor: Colors.redAccent,
                    foregroundColor: Colors.redAccent,
                    shadowColor: Colors.redAccent,
                    side: const BorderSide(
                      color: Colors.redAccent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _sheetHandle() {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  // ============================================================
  // CARGAR Y FILTRAR USUARIOS
  // ============================================================

  Future<void> loadUsers({
    bool force = false,
  }) async {
    if (users.isNotEmpty && !force) {
      _applyUserFilter();
      return;
    }

    final token = userSession.session_token;

    if (token == null || token.trim().isEmpty) {
      Get.snackbar(
        'Sesión inválida',
        'Inicia sesión nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoadingUsers.value = true;

      final result = await adminUsersProvider.getAllUsers(token);

      users.assignAll(result);
      _applyUserFilter();
    } catch (error) {
      Get.snackbar(
        'Error',
        'No se pudo cargar la lista de usuarios: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingUsers.value = false;
    }
  }

  void onUserSearchChanged(String query) {
    userSearchQuery.value = query;
  }

  void clearUserSearch() {
    userSearchController.clear();
    userSearchQuery.value = '';
  }

  void _applyUserFilter() {
    final query = userSearchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredUsers.assignAll(users);
      return;
    }

    filteredUsers.assignAll(
      users.where((user) {
        final name = (user.name ?? '').toLowerCase();
        final lastname = (user.lastname ?? '').toLowerCase();
        final fullName = '$name $lastname';
        final email = (user.email ?? '').toLowerCase();
        final ci = (user.ci ?? '').toLowerCase();

        return name.contains(query) ||
            lastname.contains(query) ||
            fullName.contains(query) ||
            email.contains(query) ||
            ci.contains(query);
      }),
    );
  }

  /// Abre el buscador de usuarios para asignar la bicicleta indicada.
  Future<void> showUserPicker(int bicycle) async {
    clearUserSearch();
    await loadUsers();

    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          height: Get.height * 0.82,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              _sheetHandle(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Asignar bicicleta $bicycle',
                      style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: almostBlack
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back<void>(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: userSearchController,
                onChanged: onUserSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, correo o cédula',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: clearUserSearch,
                    icon: const Icon(Icons.clear),
                  ),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (isLoadingUsers.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (filteredUsers.isEmpty) {
                    return const Center(
                      child: Text(
                        'No se encontraron usuarios.',
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => loadUsers(force: true),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredUsers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final user = filteredUsers[index];
                        final fullName = _userFullName(user);
                        final photoUrl = user.photo_url?.trim() ?? '';
                        final rides = user.totalRides ?? 0;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            backgroundImage: photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : null,
                            child: photoUrl.isEmpty
                                ? Text(_initials(fullName))
                                : null,
                          ),
                          title: Text(
                            fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            [
                              if ((user.email ?? '').isNotEmpty) user.email!,
                              'Rides: $rides',
                            ].join('\n'),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                          ),
                          onTap: isProcessing.value
                              ? null
                              : () => _confirmAssignUser(
                            user: user,
                            bicycle: bicycle,
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  void _confirmAssignUser({
    required User user,
    required int bicycle,
  }) {
    final fullName = _userFullName(user);

    Get.dialog<void>(
      AlertDialog(
        title: const Text('Confirmar asignación'),
        content: Text(
          '¿Deseas asignar a $fullName en la bicicleta $bicycle?\n\n'
              'Esta acción consumirá un ride del plan del usuario.',
          style: TextStyle(
              color: almostBlack
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Get.back<void>();

              Future.delayed(
                const Duration(milliseconds: 100),
                    () => assignUser(
                  selectedUser: user,
                  bicycle: bicycle,
                ),
              );
            },
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ASIGNAR USUARIO
  // ============================================================

  Future<void> assignUser({
    required User selectedUser,
    required int bicycle,
  }) async {
    final targetUserId = selectedUser.id?.trim();

    if (targetUserId == null || targetUserId.isEmpty) {
      Get.snackbar(
        'Usuario inválido',
        'El usuario seleccionado no tiene un identificador válido.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isProcessing.value) {
      return;
    }

    try {
      isProcessing.value = true;

      final access = await classReservationProvider.courseAccess(
          coachId: coachId, classDate: classDate, classTime: classTime, targetUserId: targetUserId);
      if (access.success != true || access.data is! Map ||
          (int.tryParse('${access.data['compatible_rides']}') ?? 0) <= 0) {
        Get.snackbar('Plan incompatible', access.data is Map
            ? '${access.data['message']}' : (access.message ?? 'No se pudo verificar el acceso.'));
        return;
      }
      final response = await classReservationProvider.scheduleClass(
        coachId: coachId,
        bicycle: bicycle,
        classDate: classDate,
        classTime: classTime,
        targetUserId: targetUserId,
      );

      if (response.success != true) {
        Get.snackbar(
          'No se pudo asignar',
          response.message ?? 'Ocurrió un error al crear la reservación.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (Get.isBottomSheetOpen == true) {
        Get.back<void>();
      }

      await loadBikeStatus(showError: false);

      Get.snackbar(
        'Reservación creada',
        '${_userFullName(selectedUser)} fue asignado a la bicicleta $bicycle.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // ============================================================
  // REMOVER USUARIO
  // ============================================================

  void _showReturnRideDialog(
      ClassReservation reservation,
      ) {
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Remover usuario', style: TextStyle(
            color: almostBlack
        ),),
        content: Text(
          '¿Deseas devolver el ride al plan de '
              '${reservation.userName ?? 'este usuario'}?',
          style: TextStyle(
              color: almostBlack
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back<void>();

              Future.delayed(
                const Duration(milliseconds: 100),
                    () => removeUser(
                  reservation: reservation,
                  returnRide: false,
                ),
              );
            },
            child: const Text('No devolver'),
          ),
          FilledButton(
            onPressed: () {
              Get.back<void>();

              Future.delayed(
                const Duration(milliseconds: 100),
                    () => removeUser(
                  reservation: reservation,
                  returnRide: true,
                ),
              );
            },
            child: const Text('Devolver ride'),
          ),
        ],
      ),
    );
  }

  Future<void> removeUser({
    required ClassReservation reservation,
    required bool returnRide,
  }) async {
    final reservationId = reservation.id?.trim();

    if (reservationId == null || reservationId.isEmpty) {
      Get.snackbar(
        'Reserva inválida',
        'No se pudo identificar la reservación.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isProcessing.value) {
      return;
    }

    try {
      isProcessing.value = true;

      final response = await classReservationProvider.cancelClass(
        reservationId,
        returnRide: returnRide,
      );

      if (response.success != true) {
        Get.snackbar(
          'No se pudo remover',
          response.message ?? 'Ocurrió un error al eliminar la reservación.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await loadBikeStatus(showError: false);

      Get.snackbar(
        'Usuario removido',
        returnRide
            ? 'La reservación fue eliminada y el ride fue devuelto.'
            : 'La reservación fue eliminada sin devolver el ride.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // ============================================================
  // BLOQUEAR SELECCIÓN
  // ============================================================

  Future<void> applyBlock() async {
    if (isProcessing.value) {
      return;
    }

    final bicyclesToBlock = selectedEquipos
        .where(
          (bicycle) =>
      !occupiedEquipos.contains(bicycle) &&
          !blockedEquipos.contains(bicycle),
    )
        .toList();

    if (bicyclesToBlock.isEmpty) {
      Get.snackbar(
        'Sin selección',
        'Selecciona una o más bicicletas disponibles.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    var successCount = 0;
    final errors = <String>[];

    try {
      isProcessing.value = true;

      for (final bicycle in bicyclesToBlock) {
        final response = await classReservationProvider.blockBike(
          coachId: coachId,
          bicycle: bicycle,
          classDate: classDate,
          classTime: classTime,
        );

        if (response.success == true) {
          successCount++;
        } else {
          errors.add(
            'Bicicleta $bicycle: '
                '${response.message ?? 'no se pudo bloquear'}',
          );
        }
      }

      selectedEquipos.clear();
      await loadBikeStatus(showError: false);

      if (errors.isEmpty) {
        Get.snackbar(
          'Bicicletas bloqueadas',
          'Se bloquearon $successCount bicicleta(s).',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Proceso completado con novedades',
          'Bloqueadas: $successCount.\n${errors.join('\n')}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    } finally {
      isProcessing.value = false;
    }
  }

  // ============================================================
  // DESBLOQUEAR SELECCIÓN
  // ============================================================

  Future<void> applyUnblock() async {
    if (isProcessing.value) {
      return;
    }

    final bicyclesToUnblock = selectedEquipos
        .where(blockedEquipos.contains)
        .toList();

    if (bicyclesToUnblock.isEmpty) {
      Get.snackbar(
        'Sin selección',
        'Selecciona una o más bicicletas bloqueadas.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    var successCount = 0;
    final errors = <String>[];

    try {
      isProcessing.value = true;

      for (final bicycle in bicyclesToUnblock) {
        final response = await classReservationProvider.unblockBike(
          coachId: coachId,
          bicycle: bicycle,
          classDate: classDate,
          classTime: classTime,
        );

        if (response.success == true) {
          successCount++;
        } else {
          errors.add(
            'Bicicleta $bicycle: '
                '${response.message ?? 'no se pudo desbloquear'}',
          );
        }
      }

      selectedEquipos.clear();
      await loadBikeStatus(showError: false);

      if (errors.isEmpty) {
        Get.snackbar(
          'Bicicletas desbloqueadas',
          'Se desbloquearon $successCount bicicleta(s).',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Proceso completado con novedades',
          'Desbloqueadas: $successCount.\n${errors.join('\n')}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    } finally {
      isProcessing.value = false;
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _userFullName(User user) {
    final fullName = [
      user.name?.trim() ?? '',
      user.lastname?.trim() ?? '',
    ].where((value) => value.isNotEmpty).join(' ');

    return fullName.isEmpty ? 'Usuario' : fullName;
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
        '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String _normalizeDate(String value) {
    if (value.isEmpty) {
      return '';
    }

    return value.split('T').first.split(' ').first;
  }

  String _normalizeTime(String value) {
    if (value.isEmpty) {
      return '';
    }

    final cleanValue = value.split('.').first;
    final parts = cleanValue.split(':');

    if (parts.length == 2) {
      return '${parts[0].padLeft(2, '0')}:'
          '${parts[1].padLeft(2, '0')}:00';
    }

    return cleanValue;
  }
}

