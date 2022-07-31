import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed ;
   RoundButton({required this.title,required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,

      child: MaterialButton(
        height: 58,
        minWidth: double.infinity,
        color: Colors.deepOrange,
        onPressed: onPressed,
        child: Text(title,style: TextStyle(color: Colors.white,fontSize: 20),),

      ),
    );
  }
}
