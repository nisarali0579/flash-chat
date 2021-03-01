import 'package:flutter/material.dart';


class Rounded_Button extends StatelessWidget {

  Rounded_Button({this.color,this.onPressed,this.tittle});
  final Color color;
  final String tittle;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            tittle,style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
