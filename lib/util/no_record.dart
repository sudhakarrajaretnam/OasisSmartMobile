import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget noRecordWidget(BuildContext context, {String message = "No record found"}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Stack(
        children: [
          Center(
            child: Lottie.asset(
              'assets/animation_norecord.json',
              width: 200,
              repeat: false,
            ),
          ),
          Positioned(
            top: 150,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.black54, fontSize: 22),
              ),
            ),
          )
        ],
      ),
    ],
  );
}
