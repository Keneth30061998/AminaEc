import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'admin_coach_update_controller.dart';

class AdminCoachUpdatePage extends StatelessWidget {
  final AdminCoachUpdateController con = Get.put(AdminCoachUpdateController());

  AdminCoachUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteLight,
        foregroundColor: almostBlack,
        title: const Text('Editar Datos del Coach'),
      ),
      backgroundColor: whiteLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _photoSection(context),
              _formBox(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoSection(BuildContext context) {
    return Container(
      height: 110,
      width: 110,
      margin: const EdgeInsets.only(top: 40),
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          _currentPhoto(),
          IconButton.filled(
            onPressed: () => con.showAlertDialog(context),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  Widget _currentPhoto() {
    return GetBuilder<AdminCoachUpdateController>(
      builder: (_) => CircleAvatar(
        radius: 55,
        backgroundColor: darkGrey,
        backgroundImage: con.imageFile != null
            ? FileImage(con.imageFile!)
            : (con.coach.user?.photo_url != null
                    ? NetworkImage(con.coach.user!.photo_url!)
                    : const AssetImage('assets/img/user_photo1.png'))
                as ImageProvider,
      ),
    );
  }

  Widget _formBox(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(25),
      padding: const EdgeInsets.all(35),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        children: [
          _textField('Nombre', con.nameController, Icons.person),
          _textField('Apellido', con.lastnameController, Icons.person_outline),
          _textField('Cédula', con.ciController, Icons.assignment_ind),
          _textField('Teléfono', con.phoneController, Icons.phone_android),
          _textField('Hobby', con.hobbyController, Icons.gamepad),
          _textField(
              'Descripción', con.descriptionController, Icons.description,
              maxLines: 2),
          _textField('Presentación', con.presentationController, Icons.subject,
              maxLines: 3),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => con.updateCoach(context),
            icon: const Icon(
              Icons.save,
              color: whiteLight,
            ),
            label: const Text('Guardar Cambios'),
            style: ElevatedButton.styleFrom(
              foregroundColor: whiteLight,
              backgroundColor: almostBlack,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(
      String label, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
