import 'package:flutter/material.dart';

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
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
