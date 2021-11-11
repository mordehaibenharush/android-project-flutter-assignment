import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class GrabbingWidget extends StatelessWidget {
  final User? user;
  final Function onTapFunc;

  GrabbingWidget({required this.user, required this.onTapFunc});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 8,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text("Welcome back ${user?.email}", style: TextStyle(color: Colors.deepPurple, fontSize: 16,),),
          ),),
          Expanded(
            flex: 1,
            child: IconButton(
            icon: const Icon(Icons.keyboard_arrow_up, color: Colors.deepPurple, size: 30),
            onPressed: onTapFunc(),
            tooltip: 'Profile display',
          ),),
        ],
      ),
    );
  }
}
