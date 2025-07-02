import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oasis_smart_services/helper/message_box.dart';
import 'package:oasis_smart_services/pages/welcome/notifier_firebase_auth.dart';
import 'package:oasis_smart_services/pages/welcome/notifier_otp.dart';
import 'package:oasis_smart_services/util/global_variables.dart';

void showSnackBar(
    {required BuildContext context,
    required String message,
    int duration = 2,
    bgcolor = "black"}) {
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
                ? Colors.green
                : bgcolor == "red"
                    ? Colors.red
                    : Colors.black,
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

Future<String> showOtpProcess(
    BuildContext context,
    String fullName,
    String mobileNo,
    String country,
    String address,
    String zip,
    WidgetRef ref) async {
  if (ref.watch(userIdProvider).isNotEmpty) {
    return Future.value("bypass");
  } else {
    //bool isClosed = false;
    Future.delayed(const Duration(milliseconds: 200), () {
      ref.read(otpProvider.notifier).sendOtp(mobileNo);
    });
    String status = '';
    String otp = '';
    ref.read(resendOtpTimerProvider.notifier).startCountdown(resendOtpTime);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Consumer(builder: (context, ref, child) {
          final remainingTime = ref.watch(resendOtpTimerProvider);
          final resendOtpTimer = ref.read(resendOtpTimerProvider.notifier);
          final otpState = ref.watch(otpProvider);
          final otpNotifier = ref.read(otpProvider.notifier);
          final showVerify = ref.watch(isShowVerify);
          ref.listen<OtpState>(
            otpProvider,
            (previous, next) {
              if (next.screen == 1 && next.isVerified) {
                //isClosed = true;
                status = "alldone";
                Navigator.of(context).pop();
              } else if (next.screen == 1 && next.isResent) {
                showSnackBar(
                    context: context,
                    message: 'OTP Resent successfully',
                    duration: 2,
                    bgcolor: "green");
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
          return AlertDialog(
            title: const Text('Enter 6-digit code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please enter the OTP sent to your mobile number.'),
                const SizedBox(height: 16),
                OtpTextField(
                  numberOfFields: 6,
                  clearText: true,
                  autoFocus: true,
                  borderColor: Colors.transparent,
                  focusedBorderColor: Colors.green,
                  showFieldAsBox: false,
                  fieldWidth: 30,
                  onSubmit: (String verificationCode) {
                    otp = verificationCode;
                    ref.read(isShowVerify.notifier).state = true;
                  },
                  onCodeChanged: (value) {
                    otp = value;
                    if (showVerify) {
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
                        ref.read(resendOtpTimerProvider.notifier).startCountdown(resendOtpTime);
                        ref.read(isShowVerify.notifier).state = true;
                        await otpNotifier.resendOtp(mobileNo);
                        ref.read(isShowVerify.notifier).state = false;
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
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      status = "stop";
                    },
                    child: const Text('Cancel'),
                  ),
                  if (showVerify) ...[
                    ElevatedButton(
                      onPressed: () {
                        ref.read(otpProvider.notifier).verifyOtpCreateAccount(
                            country,
                            mobileNo,
                            fullName,
                            address,
                            zip,
                            true,
                            otp,
                            ref);
                      },
                      child: otpState.isLoading
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(otpState.status == 'otpandaccount'
                                    ? "Verifying"
                                    : 'Resending'),
                              ],
                            )
                          : const Text('Verify'),
                    ),
                  ],
                ],
              ),
            ],
          );
        });
      },
    );
    return Future.value(status);
  }
}
