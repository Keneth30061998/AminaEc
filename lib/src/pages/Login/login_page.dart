import 'package:amina_ec/src/pages/Login/login_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

LoginController con = Get.put(LoginController());

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteLight,
      body: Stack(
        children: [
          _backFontColor(context),
          _titleLogin(context),
          _boxForm(context),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: _textDontHaveAccount(),
      ),
    );
  }

  Widget _backFontColor(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      decoration: BoxDecoration(
        color: limeGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
    );
  }
}

Widget _titleLogin(BuildContext context) {
  return Container(
    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.22),
    width: double.infinity,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hola! ',
          style: TextStyle(
            color: almostBlack,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        Text(
          'Bienvenido de nuevo',
          style: TextStyle(
            color: almostBlack,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ],
    ),
  );
}

Widget _boxForm(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.40,
    //width: MediaQuery.of(context).size.width * 0.8,
    margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.32, left: 35, right: 35),
    padding: EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: color_background_box,
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Colors.black54,
          blurRadius: 10,
          offset: Offset(0, 0.75),
        ),
      ],
      borderRadius: BorderRadius.all(
        Radius.circular(30),
      ),
    ),
    child: SingleChildScrollView(
      child: Column(
        children: [
          _titleBoxForm(),
          _textFieldEmail(),
          _textFieldPassword(),
          _buttonLogin(context),
        ],
      ),
    ),
  );
}

Widget _titleBoxForm() {
  return Container(
    margin: EdgeInsets.only(top: 15, bottom: 15),
    child: Text(
      'Ingresa tus credenciales',
      style: TextStyle(
          color: almostBlack, fontWeight: FontWeight.bold, fontSize: 20),
    ),
  );
}

Widget _textFieldEmail() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: TextField(
      controller: con.emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        floatingLabelStyle: TextStyle(color: darkGrey),
        labelText: "Email",
        hintText: "Email",
        prefixIcon: Icon(Icons.alternate_email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: darkGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: darkGrey),
        ),
      ),
    ),
  );
}

Widget _textFieldPassword() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: TextField(
      controller: con.passwordController,
      keyboardType: TextInputType.text,
      obscureText: true,
      decoration: InputDecoration(
        floatingLabelStyle: TextStyle(color: darkGrey),
        labelText: "Contraseña",
        hintText: "Contraseña",
        prefixIcon: Icon(Icons.password_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: darkGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: darkGrey),
        ),
      ),
    ),
  );
}

Widget _buttonLogin(BuildContext context) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 20),
    child: FloatingActionButton.extended(
      onPressed: () {
        return con.login(context);
      },
      backgroundColor: almostBlack,
      elevation: 2,
      label: const Text(
        'Login',
        style: TextStyle(
            color: whiteLight, fontWeight: FontWeight.bold, fontSize: 17),
      ),
    ),
  );
}

Widget _textDontHaveAccount() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        '¿No tienes una cuenta?',
        style: TextStyle(
            fontSize: 17, color: darkGrey, fontWeight: FontWeight.w600),
      ),
      const SizedBox(
        width: 10,
      ),
      GestureDetector(
        onTap: () {
          return con.goToRegisterPage();
        },
        child: const Text(
          'Registrate Aqui',
          style: TextStyle(
              color: indigoAmina, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      )
    ],
  );
}
