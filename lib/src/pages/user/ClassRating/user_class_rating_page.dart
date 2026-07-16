import 'package:amina_ec/globals.dart';
import 'package:amina_ec/src/models/class_rating.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:amina_ec/src/providers/class_rating_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/color.dart';

class UserClassRatingPage extends StatefulWidget {
  const UserClassRatingPage({super.key});

  @override
  State<UserClassRatingPage> createState() => _UserClassRatingPageState();
}

class _UserClassRatingPageState extends State<UserClassRatingPage> {
  final ClassRatingProvider _provider = ClassRatingProvider();
  final TextEditingController _commentController = TextEditingController();

  int _rating = 0;
  bool _isLoading = false;
  bool _isChecking = true;
  String? attendanceId;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};
    attendanceId = args['attendanceId']?.toString();

    print("📥 Argumentos recibidos en UserClassRatingPage: $args");
    print("📌 attendanceId recibido: $attendanceId");
    print("👤 userSession.id: ${userSession.id}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validatePendingAttendance();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _validatePendingAttendance() async {
    if (attendanceId == null || attendanceId!.isEmpty) {
      if (!mounted) return;

      Get.offAllNamed('/user/home');

      Get.snackbar(
        'Aviso',
        'No se encontró una clase pendiente de calificación.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    final ResponseApi response =
    await _provider.checkAttendanceRatingStatus(
      userId: userSession.id.toString(),
      attendanceId: attendanceId!,
    );

    if (!mounted) return;

    if (response.success != true) {
      setState(() {
        _isChecking = false;
      });

      Get.snackbar(
        'Error',
        response.message ?? 'No fue posible verificar la clase pendiente',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    final Map<String, dynamic> data =
    response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : {};

    final bool isPending = data['isPending'] == true;

    if (!isPending) {
      Get.offAllNamed('/user/home');
      return;
    }

    setState(() {
      _isChecking = false;
    });
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      Get.snackbar(
        'Atención',
        'Debes seleccionar una calificación',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (attendanceId == null || attendanceId!.isEmpty) {
      Get.snackbar(
        'Error',
        'No se pudo identificar la clase pendiente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final classRating = ClassRating(
      userId: userSession.id.toString(),
      attendanceId: attendanceId,
      rating: _rating,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    final ResponseApi response =
    await _provider.submitRating(classRating);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response.success == true) {
      Get.snackbar(
        'Éxito',
        response.message ?? 'Valoración enviada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed('/user/home');
    } else {
      Get.snackbar(
        'Error',
        response.message ?? 'No fue posible enviar la valoración',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _skipRating() async {
    if (attendanceId == null || attendanceId!.isEmpty) {
      Get.snackbar(
        'Error',
        'No se pudo identificar la clase pendiente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final ResponseApi response = await _provider.skipRating(
      userId: userSession.id.toString(),
      attendanceId: attendanceId!,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response.success == true) {
      Get.snackbar(
        'Listo',
        response.message ?? 'Valoración omitida correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed('/user/home');
    } else {
      Get.snackbar(
        'Error',
        response.message ?? 'No fue posible omitir la valoración',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: whiteLight,
          title: Text(
            'Califica tu clase',
            style: GoogleFonts.poppins(
              color: almostBlack,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 1,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteLight,
        title: Text(
          'Califica tu clase',
          style: GoogleFonts.poppins(
            color: almostBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.black87,
                ),

                const SizedBox(height: 20),

                Text(
                  '¿Cómo estuvo tu clase?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: almostBlack,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Tu opinión nos ayuda a mejorar tu experiencia en Amina.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: whiteGrey,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '* Tu valoración será tratada de forma confidencial',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: whiteGrey,
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                  List.generate(5, (index) => _buildStar(index + 1)),
                ),

                const SizedBox(height: 10),

                Text(
                  _getRatingText(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: almostBlack,
                  ),
                ),

                const SizedBox(height: 35),

                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    hintText: 'Deja un comentario (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: whiteLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                      const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      color: whiteLight,
                      strokeWidth: 2,
                    )
                        : Text(
                      'Enviar valoración',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: _isLoading ? null : _skipRating,
                  child: Text(
                    'Omitir',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStar(int index) {
    final bool isSelected = _rating >= index;

    return IconButton(
      onPressed: _isLoading
          ? null
          : () {
        setState(() {
          _rating = index;
        });
      },
      icon: Icon(
        isSelected ? Icons.star : Icons.star_border,
        color: isSelected ? Colors.amber : Colors.grey,
        size: 45,
      ),
    );
  }

  String _getRatingText() {
    switch (_rating) {
      case 1:
        return 'Muy mala';
      case 2:
        return 'Mala';
      case 3:
        return 'Regular';
      case 4:
        return 'Buena';
      case 5:
        return 'Excelente';
      default:
        return 'Selecciona una valoración';
    }
  }
}