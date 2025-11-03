import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../utils/color.dart';
import '../../../../utils/iconos.dart';
import 'admin_coach_register_controller.dart';

// --- Input Formatters Globales ---
final noEmojisNoSpacesFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[A-Za-z0-9@._\-]+'),
);

final onlyLettersNoSpacesFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÑñ]+'),
);

final onlyNumbersFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));

class AdminCoachRegisterPage extends StatelessWidget {
  final AdminCoachRegisterController con =
  Get.put(AdminCoachRegisterController());

  AdminCoachRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteLight,
        shadowColor: whiteLight,
        surfaceTintColor: whiteLight,
        forceMaterialTransparency: true,
      ),
      backgroundColor: whiteLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _header()
                    .animate()
                    .fade(duration: 500.ms)
                    .slideY(begin: 0.3)
                    .then(delay: 150.ms),

                const SizedBox(height: 20),

                _textField(
                  "Correo Electrónico",
                  con.emailController,
                  iconEmail,
                  TextInputType.emailAddress,
                  inputFormatters: [noEmojisNoSpacesFormatter],
                ).animate(delay: 200.ms).fade().slideY(begin: 0.3),

                _textField(
                  "Nombre",
                  con.nameController,
                  iconProfile,
                  TextInputType.name,
                  inputFormatters: [onlyLettersNoSpacesFormatter],
                ).animate(delay: 350.ms).fade().slideY(begin: 0.3),

                _textField(
                  "Apellido",
                  con.lastnameController,
                  iconProfileInvert,
                  TextInputType.name,
                  inputFormatters: [onlyLettersNoSpacesFormatter],
                ).animate(delay: 500.ms).fade().slideY(begin: 0.3),

                _textField(
                  "Cédula",
                  con.ciController,
                  iconCi,
                  TextInputType.number,
                  inputFormatters: [onlyNumbersFormatter],
                ).animate(delay: 650.ms).fade().slideY(begin: 0.3),

                _textField(
                  "Teléfono",
                  con.phoneController,
                  iconPhone,
                  TextInputType.phone,
                  inputFormatters: [onlyNumbersFormatter],
                ).animate(delay: 800.ms).fade().slideY(begin: 0.3),

                _passwordField(
                  "Contraseña",
                  con.passwordController,
                  iconPassword,
                  con.obscurePassword,
                  inputFormatters: [noEmojisNoSpacesFormatter],
                ).animate(delay: 950.ms).fade().slideY(begin: 0.3),

                _passwordField(
                  "Confirmar Contraseña",
                  con.confirmPasswordController,
                  iconConfirmPassword,
                  con.obscureConfirmPassword,
                  inputFormatters: [noEmojisNoSpacesFormatter],
                ).animate(delay: 1100.ms).fade().slideY(begin: 0.3),

                const SizedBox(height: 8),

                _selectBirthDateField()
                    .animate(delay: 1150.ms)
                    .fade()
                    .slideY(begin: 0.3),

                const SizedBox(height: 15),

                _buttonRegister(context)
                    .animate(delay: 1250.ms)
                    .fade()
                    .slideY(begin: 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Registro de Coach',
          style: GoogleFonts.poppins(
            color: almostBlack,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ingresa la información del coach',
          style: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _textField(String label, TextEditingController controller,
      IconData icon, TextInputType inputType,
      {required List<TextInputFormatter> inputFormatters}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black),
          labelStyle: GoogleFonts.poppins(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController controller,
      IconData icon, RxBool toggleValue,
      {required List<TextInputFormatter> inputFormatters}) {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: toggleValue.value,
        keyboardType: TextInputType.visiblePassword,
        inputFormatters: inputFormatters,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black),
          suffixIcon: IconButton(
            icon: Icon(
              toggleValue.value ? iconCloseEye : iconOpenEye,
              color: Colors.black54,
            ),
            onPressed: () => toggleValue.value = !toggleValue.value,
          ),
          labelStyle: GoogleFonts.poppins(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black),
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    ));
  }

  Widget _selectBirthDateField() {
    return Obx(() {
      final selectedDate = con.birthDate.value;
      final formattedDate =
      selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate) : '';
      return GestureDetector(
        onTap: () => _showDatePicker(),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(iconBirthDate),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  formattedDate.isNotEmpty
                      ? formattedDate
                      : 'Selecciona tu fecha de nacimiento',
                  style: GoogleFonts.poppins(
                      color: formattedDate.isNotEmpty
                          ? Colors.black87
                          : Colors.black45,
                      fontSize: 16),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.black38, size: 22),
            ],
          ),
        ),
      );
    });
  }

  void _showDatePicker() {
    final DateTime now = DateTime.now();
    final DateTime initialDate = con.birthDate.value ?? DateTime(2000);

    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        DateTime tempDate = initialDate;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2))),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  maximumDate: now,
                  minimumDate: DateTime(1950),
                  onDateTimeChanged: (date) => tempDate = date,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  con.setBirthDate(tempDate);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12)),
                child: const Text("Confirmar"),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buttonRegister(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: FloatingActionButton.extended(
        onPressed: () => con.goToRegisterAdminCoachImage(),
        label: const Text(
          'Siguiente',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        icon: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
        ),
        backgroundColor: almostBlack,
      ),
    );
  }
}
