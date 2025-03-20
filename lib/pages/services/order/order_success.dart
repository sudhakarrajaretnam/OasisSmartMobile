import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
//import 'package:oassis_mart/pages/drawer/dialogs/view_cartinfo.dart';
import 'package:oassis_mart/pages/services/notifier_service.dart';
import 'package:oassis_mart/pages/services/order/order_track_detail.dart';
import 'package:oassis_mart/util/global_variables.dart';

final controlProvider = StateProvider.autoDispose<bool>((ref) => false);

class OrderSuccessPage extends ConsumerWidget {
  final List<dynamic> serviceName;
  final List<dynamic> recId;
  final List<dynamic> orderCode;
  final String createdAt;

  const OrderSuccessPage({super.key, required this.serviceName, required this.recId, required this.orderCode, required this.createdAt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Lottie.asset(
                        'assets/tick_animation.json', // Path to your Lottie file
                        width: 300, // Increase size
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
                    'Your service request has been placed and is on its way to being processed. you can track your order with the order code below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.2,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: orderCode.asMap().entries.map((entry) {
                      int index = entry.key;
                      int value = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: '${serviceName[index]}: ',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.grey[700],
                                ),
                                children: [
                                  TextSpan(
                                    text: value.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await _showFullScreenBottomSheet(context, createdAt, ref, recId[index]);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Track',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        //_showFullScreenBottomSheet(context, recId, DateTime.now().toString());
                        ref.read(serviceNotifierProvider.notifier).clearCart();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/services', // Target route
                          (Route<dynamic> route) => false, // Remove all previous routes
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Back to home',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 16),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       //_showFullScreenBottomSheet(context, recId, DateTime.now().toString());
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: primaryColor,
                  //       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(16),
                  //       ),
                  //     ),
                  //     child: const Text(
                  //       'Track Order',
                  //       style: TextStyle(fontSize: 22, color: Colors.white),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 16),

                  // Back to Home Button
                  // Consumer(builder: (context, ref, child) {
                  //   return TextButton(
                  //     onPressed: () {
                  //       ref.read(serviceNotifierProvider.notifier).clearCart();
                  //       Navigator.pushNamedAndRemoveUntil(
                  //         context,
                  //         '/services', // Target route
                  //         (Route<dynamic> route) => false, // Remove all previous routes
                  //       );
                  //     },
                  //     child: const Text(
                  //       'Back to home',
                  //       style: TextStyle(
                  //         fontSize: 16,
                  //         color: Colors.black,
                  //       ),
                  //     ),
                  //   );
                  // }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showFullScreenBottomSheet(BuildContext context, String createdAt, WidgetRef ref, String serviceId) {
    bool hasCompleted = false;
    return showGeneralDialog(
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
            body: Consumer(
              builder: (context, ref, _) {
                final isShow = ref.watch(controlProvider);
                return !isShow ? Container() : TrackScreenDialog(serviceId: serviceId);
              },
            )
            //!isShow ? Container() : TrackScreenDialog(serviceId: serviceId),
            );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            if (!hasCompleted) {
              hasCompleted = true;
              Future.delayed(const Duration(milliseconds: 50), () {
                ref.read(controlProvider.notifier).state = true;
                print("11here");
              });
            }
            // Future.delayed(const Duration(milliseconds: 10), () async {
            //   print("1here");
            //   //ref.read(controlProvider.notifier).state = true;
            // });
          }
        });
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1), // Start from bottom
          end: Offset.zero, // End at top (full screen)
        ).animate(animation);

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  }
}
