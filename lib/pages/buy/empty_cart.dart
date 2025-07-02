//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyCartPage extends StatelessWidget {
  const EmptyCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Center(
              child: Lottie.asset(
                'assets/animation-nocart.json',
                width: 200,
                repeat: false,
              ),
            ),
            Positioned(
              top: 210,
              width: MediaQuery.of(context).size.width,
              child: const Center(
                child: Text(
                  "Empty Cart",
                  style: TextStyle(color: Colors.black54, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
