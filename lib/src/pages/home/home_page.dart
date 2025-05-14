import 'package:amina_ec/src/pages/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

HomeController con = Get.put(HomeController());

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: IconButton.filled(
          onPressed: () {
            return con.signOut();
          },
          icon: Icon(Icons.exit_to_app),
        ),
      ),
    );
  }
}
