import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminStartPage extends StatefulWidget {
  const AdminStartPage({super.key});

  @override
  State<AdminStartPage> createState() => _AdminStartPageState();
}

class _AdminStartPageState extends State<AdminStartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkGrey,
        foregroundColor: limeGreen,
        title: _appBarTitle(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _textGreeting(),
            _textCountUsers(),
            _textCountCoachs(),
          ],
        ),
      ),
    );
  }

  Widget _appBarTitle() {
    return Text(
      'Administrador',
      style: GoogleFonts.montserrat(
        fontSize: 26,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _textCountUsers() {
    return Container(
      padding: EdgeInsets.only(left: 20),
      width: double.infinity,
      child: Text(
        'Usuarios Registrados: 0',
        style: GoogleFonts.robotoCondensed(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white30,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _textCountCoachs() {
    return Container(
      padding: EdgeInsets.only(left: 20),
      width: double.infinity,
      child: Text(
        'Coachs Registrados: 0',
        style: GoogleFonts.robotoCondensed(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white30,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _textGreeting() {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 30, bottom: 40),
      width: double.infinity,
      //color: Colors.black12,
      child: Text(
        'Hola, Keneth',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}
