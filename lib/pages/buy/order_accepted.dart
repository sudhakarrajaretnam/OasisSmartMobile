import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:oasis_smart_services/pages/buy/notifier_cart.dart';
import 'package:oasis_smart_services/pages/drawer/dialogs/view_cartinfo.dart';
import 'package:oasis_smart_services/util/global_variables.dart';

class OrderAcceptedPage extends StatelessWidget {
  final String recId;
  final int orderCode;
  final String createdAt;

  const OrderAcceptedPage({super.key, required this.recId, required this.orderCode, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset(
                      'assets/tick_animation.json', // Path to your Lottie file
                      width: 500, // Increase size
                      repeat: true, // Play only once
                      onLoaded: (composition) {},
                    ),
                  ],
                ),
                //const SizedBox(height: 32),
                const Text(
                  'Your Order has been\naccepted',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your items has been placed and is on\nits way to being processed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.2,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    text: 'Order Code: ',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey[700],
                    ),
                    children: [
                      TextSpan(
                        text: orderCode.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showFullScreenBottomSheet(context, recId, DateTime.now().toString());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Track Order',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Back to Home Button
                Consumer(builder: (context, ref, child) {
                  return TextButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).clearCart();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/buyhome', // Target route
                        (Route<dynamic> route) => false, // Remove all previous routes
                      );
                    },
                    child: const Text(
                      'Back to home',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenBottomSheet(BuildContext context, String recId, String createdAt) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
            appBar: AppBar(
              title: Text(DateFormat('EEE MMM d, y hh:mm a').format(DateTime.parse(createdAt))),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: ViewCartInfo(requestId: recId));
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
    );
  }
}
