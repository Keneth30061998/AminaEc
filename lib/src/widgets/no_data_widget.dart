import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoDataWidget extends StatelessWidget {
  String text = '';
  NoDataWidget({this.text = ''});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/img/no_files.png',
            height: 130,
            width: 130,
          ),
          Text(
            text,
            style: GoogleFonts.robotoCondensed(color: whiteGrey),
          ),
        ],
      ),
    );
  }
}
