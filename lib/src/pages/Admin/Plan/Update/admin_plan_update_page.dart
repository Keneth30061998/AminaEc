import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'admin_plan_update_controller.dart';

class AdminPlanUpdatePage extends StatelessWidget {
  final AdminPlanUpdateController con = Get.put(AdminPlanUpdateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Plan')),
      body: GetBuilder<AdminPlanUpdateController>(
        builder: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: con.pickImage,
                child: con.imageFile != null
                    ? Image.file(con.imageFile!, height: 150)
                    : con.plan.image != null
                        ? Image.network(con.plan.image!, height: 150)
                        : Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50),
                          ),
              ),
              const SizedBox(height: 16),
              TextField(
                  controller: con.nameController,
                  decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(
                  controller: con.descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción')),
              TextField(
                  controller: con.priceController,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: con.ridesController,
                  decoration: const InputDecoration(labelText: 'Viajes'),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: con.durationController,
                  decoration:
                      const InputDecoration(labelText: 'Duración (días)'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: con.updatePlan,
                child: const Text('Actualizar Plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
