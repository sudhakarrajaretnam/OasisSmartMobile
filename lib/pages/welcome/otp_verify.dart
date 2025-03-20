import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oassis_mart/helper/message_box.dart';
//import 'package:loader_overlay/loader_overlay.dart';
//import 'package:oassis_mart/helper/message_box.dart';
import 'package:oassis_mart/pages/welcome/notifier_firebase_auth.dart';
import 'package:oassis_mart/pages/welcome/notifier_otp.dart';
import 'package:oassis_mart/pages/welcome/welcome_screen.dart';
import 'package:oassis_mart/util/global_variables.dart';

class OtpVerify extends ConsumerStatefulWidget {
  final String mobile;
  const OtpVerify({super.key, required this.mobile});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OtpVerify();
}

// class _OtpVerify extends ConsumerState<OtpVerify> {
//   String otp = '';
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(resendOtpTimerProvider.notifier).startCountdown(resendOtpTime); // 30-second timer
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final phoneAuthNotifier = ref.read(phoneAuthProvider.notifier);
//     final otpstatus = ref.watch(otpStatusProvider);
//     final remainingTime = ref.watch(resendOtpTimerProvider);
//     final resendOtpTimer = ref.read(resendOtpTimerProvider.notifier);

//     return LoaderOverlay(
//       child: Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//           ),
//           body: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Enter your 6-digit code",
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black),
//                 ),
//                 const SizedBox(height: 25),
//                 const Text(
//                   'Code',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 OtpTextField(
//                   numberOfFields: 6,
//                   borderColor: Colors.transparent,
//                   focusedBorderColor: Colors.green,
//                   showFieldAsBox: false,
//                   fieldWidth: 40,
//                   onSubmit: (String verificationCode) {
//                     otp = verificationCode;
//                     ref.read(otpStatusProvider).setShowVerifyButton(true);
//                   },
//                   onCodeChanged: (value) {
//                     if (value.length < 6 && otpstatus.getShowVerifyButton) {
//                       ref.read(otpStatusProvider).setShowVerifyButton(false);
//                     }
//                   },
//                   margin: const EdgeInsets.symmetric(horizontal: 5),
//                   decoration: const InputDecoration(
//                     contentPadding: EdgeInsets.only(bottom: 10),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: Colors.grey),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: Colors.black),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 if (resendOtpTimer.isEnabled) ...[
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: GestureDetector(
//                       onTap: () async {
//                         context.loaderOverlay.show();
//                         await phoneAuthNotifier.resendOtp();
//                         if (context.mounted) {
//                           context.loaderOverlay.hide();
//                         }
//                         ref.read(resendOtpTimerProvider.notifier).startCountdown(resendOtpTime);
//                       },
//                       child: const Text(
//                         'Resend OTP',
//                         style: TextStyle(
//                           fontSize: 20,
//                           color: Colors.green,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ] else ...[
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: Text(
//                       "Resend OTP in $remainingTime sec",
//                       style: const TextStyle(
//                         fontSize: 20,
//                         color: Colors.grey,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//                 const SizedBox(height: 20),
//                 if (otpstatus.showVerifyButton) ...[
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         context.loaderOverlay.show();
//                         String status = await phoneAuthNotifier.verifyOtp(otp);
//                         if (context.mounted) {
//                           context.loaderOverlay.hide();
//                         }
//                         if (status == "success") {
//                           if (context.mounted) {
//                             Navigator.pushAndRemoveUntil(
//                               context,
//                               MaterialPageRoute(builder: (context) => const WelcomeScreen()),
//                               (route) => false, // Remove all routes
//                             );
//                           }
//                         } else {
//                           if (context.mounted) showErrorDialog(context, "OTP Failed", status);
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                       ),
//                       child: const Text(
//                         'Verify',
//                         style: TextStyle(fontSize: 18),
//                       ),
//                     ),
//                   ),
//                 ]
//               ],
//             ),
//           )),
//     );
//   }
// }

class _OtpVerify extends ConsumerState<OtpVerify> {
  String otp = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resendOtpTimerProvider.notifier).startCountdown(resendOtpTime); // 30-second timer
      //ref.read(otpProvider.notifier).startCountdown(resendOtpTime);
    });
  }

  static void showSnackBar({required BuildContext context, required String message, int duration = 2, bgcolor = "black"}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 30.0,
        left: MediaQuery.of(context).size.width * 0.05,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: bgcolor == "green"
                  ? Colors.green.withValues(alpha: 10)
                  : bgcolor == "red"
                      ? Colors.red.withValues(alpha: 80)
                      : Colors.black.withValues(alpha: 100),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: duration), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    //final phoneAuthNotifier = ref.read(phoneAuthProvider.notifier);
    //final otpstatus = ref.watch(otpStatusProvider);
    final remainingTime = ref.watch(resendOtpTimerProvider);
    final resendOtpTimer = ref.read(resendOtpTimerProvider.notifier);
    //final resendOtpTimer = ref.read(resendOtpTimerProvider.notifier);

    final otpState = ref.watch(otpProvider);
    final otpNotifier = ref.read(otpProvider.notifier);
    final showVerify = ref.watch(isShowVerify);

    ref.listen<OtpState>(
      otpProvider,
      (previous, next) {
        if (next.screen == 1 && next.isVerified) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (route) => false, // Remove all routes
          );
        } else if (next.screen == 1 && next.isResent) {
          showSnackBar(context: context, message: 'OTP Resent successfully', duration: 2, bgcolor: "green");
        } else if (next.screen == 1 && next.errorMessage != null) {
          if (next.errorMessage == "Invalid OTP") {
            showErrorDialog(context, "OTP Failed", "Invalid OTP");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${next.errorMessage}',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(isShowVerify.notifier).state = false;
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: otpState.isLoading ? 0.5 : 1.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter your 6-digit code",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Code',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OtpTextField(
                    numberOfFields: 6,
                    borderColor: Colors.transparent,
                    focusedBorderColor: Colors.green,
                    showFieldAsBox: false,
                    fieldWidth: 40,
                    onSubmit: (String verificationCode) {
                      otp = verificationCode;
                      //ref.read(otpStatusProvider).setShowVerifyButton(true);
                      ref.read(isShowVerify.notifier).state = true;
                    },
                    onCodeChanged: (value) {
                      // if (value.length < 6 && otpstatus.getShowVerifyButton) {
                      //   ref.read(otpStatusProvider).setShowVerifyButton(false);
                      // }
                      if (value.length < 6 && showVerify) {
                        ref.read(isShowVerify.notifier).state = false;
                      }
                    },
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 10),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (resendOtpTimer.isEnabled) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () async {
                          // context.loaderOverlay.show();
                          // await phoneAuthNotifier.resendOtp();
                          // if (context.mounted) {
                          //   context.loaderOverlay.hide();
                          // }
                          // ref.read(resendOtpTimerProvider.notifier).startCountdown(resendOtpTime);
                          //otpNotifier.verifyOtp(widget.mobile, otp);
                          ref.read(resendOtpTimerProvider.notifier).startCountdown(resendOtpTime);
                          otpNotifier.resendOtp(widget.mobile);
                        },
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Resend OTP in $remainingTime sec",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (showVerify) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          otpNotifier.verifyOtp(widget.mobile, otp);
                          // context.loaderOverlay.show();
                          // String status = await phoneAuthNotifier.verifyOtp(otp);
                          // if (context.mounted) {
                          //   context.loaderOverlay.hide();
                          // }
                          // if (status == "success") {
                          //   if (context.mounted) {
                          //     Navigator.pushAndRemoveUntil(
                          //       context,
                          //       MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                          //       (route) => false, // Remove all routes
                          //     );
                          //   }
                          // } else {
                          //   if (context.mounted) showErrorDialog(context, "OTP Failed", status);
                          // }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        ),
                        child: const Text(
                          'Verify',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
