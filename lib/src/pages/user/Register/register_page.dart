import 'package:amina_ec/src/pages/user/Register/register_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../utils/color.dart';
import '../../../utils/iconos.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterController con = Get.put(RegisterController());
  int stepIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteLight,
        surfaceTintColor: whiteLight,
        elevation: 0,
      ),
      backgroundColor: whiteLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _header(),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: _getStepWidget(),
                ),
                const SizedBox(height: 30),
                _navigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Registro de Usuario',
          style: GoogleFonts.poppins(
            color: almostBlack,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Completa tu información personal',
          style: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // STEP WIDGETS
  Widget _getStepWidget() {
    switch (stepIndex) {
      case 0:
        return Column(
          key: const ValueKey(0),
          children: [
            _textField("Nombre", con.nameController, iconProfile, TextInputType.name),
            _textField("Apellido", con.lastnameController, iconProfileInvert, TextInputType.name),
            _selectBirthDateField(),
          ],
        );
      case 1:
        return Column(
          key: const ValueKey(1),
          children: [
            _textField("Correo Electrónico", con.emailController, iconEmail, TextInputType.emailAddress),
            _textField("Teléfono", con.phoneController, iconPhone, TextInputType.phone),
            _textField("Cédula", con.ciController, iconCi, TextInputType.number),
          ],
        );
      case 2:
        return Column(
          key: const ValueKey(2),
          children: [
            _passwordField("Contraseña", con.passwordController, iconPassword, con.obscurePassword),
            _passwordField("Confirmar Contraseña", con.confirmPasswordController, iconConfirmPassword, con.obscureConfirmPassword),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // BOTONES DE NAVEGACIÓN
  Widget _navigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (stepIndex > 0)
          ElevatedButton(
            onPressed: () {
              setState(() {
                stepIndex--;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Atrás"),
          ),
        ElevatedButton(
          onPressed: () async {
            if (!_validateStep()) return;

            if (stepIndex < 2) {
              setState(() {
                stepIndex++;
              });
            } else {
              // Ultimo paso → avanzar a la firma o registro
              con.goToRegisterImage();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: almostBlack,
            foregroundColor: whiteLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(stepIndex < 2 ? "Siguiente" : "Continuar"),
        ),
      ],
    );
  }

  bool _validateStep() {
    switch (stepIndex) {
      case 0:
        return con.isValidStep1();
      case 1:
        return con.isValidStep2();
      case 2:
        return con.isValidStep3();
      default:
        return true;
    }
  }

  // WIDGETS
  Widget _textField(String label, TextEditingController controller, IconData icon, TextInputType inputType) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black),
          labelStyle: GoogleFonts.poppins(color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController controller, IconData icon, RxBool toggleValue) {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: toggleValue.value,
        keyboardType: TextInputType.visiblePassword,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black),
          suffixIcon: IconButton(
            icon: Icon(toggleValue.value ? iconCloseEye : iconOpenEye, color: Colors.black54),
            onPressed: () => toggleValue.value = !toggleValue.value,
          ),
          labelStyle: GoogleFonts.poppins(color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.black)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    ));
  }

  Widget _selectBirthDateField() {
    return Obx(() {
      final selectedDate = con.birthDate.value;
      final formattedDate = selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate) : '';

      return GestureDetector(
        onTap: () => _showMinimalDatePicker(),
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
                  formattedDate.isNotEmpty ? formattedDate : 'Selecciona tu fecha de nacimiento',
                  style: GoogleFonts.poppins(color: formattedDate.isNotEmpty ? Colors.black87 : Colors.black45, fontSize: 16),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black38, size: 22),
            ],
          ),
        ),
      );
    });
  }

  void _showMinimalDatePicker() {
    final DateTime now = DateTime.now();
    final DateTime initialDate = con.birthDate.value ?? DateTime(2000);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        DateTime tempDate = initialDate;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                child: const Text("Confirmar"),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
