import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oassis_mart/util/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

class PhoneAuthNotifier extends StateNotifier<bool> {
  final FirebaseAuth _firebaseAuth;
  final Ref ref;
  String? verificationId;
  String? phoneNumber;
  int? resendToken;
  int screen = 0;
  int otpStatus = 0;
  PhoneAuthNotifier(this._firebaseAuth, this.ref) : super(false);
  int getOtpStatus() {
    return otpStatus;
  }

  int getScreen() {
    return screen;
  }

  Future<void> sendOtp(String phoneNumber) async {
    screen = 0;
    otpStatus = 0;
    this.phoneNumber = phoneNumber;
    try {
      state = true;
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: resendOtpTime),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
          state = false;
        },
        verificationFailed: (FirebaseAuthException e) {
          otpStatus = 1;
          state = false;
          //throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          this.resendToken = resendToken;
          state = false;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
    } catch (e) {
      state = false;
      print(e.toString());
    }
  }

  Future<String> updateUser(String mobile) async {
    try {
      final url = Uri.parse('$apiUrl/customer/updateUser/$mobile');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)["userId"];
      } else {
        throw Exception("Error updating user");
      }
    } catch (e) {
      throw Exception("Error updating user");
    }
  }

  Future<String> verifyOtp(String otp) async {
    if (verificationId == null) throw Exception("Verification ID not available");
    final otpnotifer = ref.read(otpStatusProvider);
    try {
      otpnotifer.setOtpVerifying(true);
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: otp);
      await _firebaseAuth.signInWithCredential(credential);
      otpnotifer.setOtpVerifying(false);
      mobileNumber = phoneNumber!;
      userId = await updateUser(mobileNumber);
      //userId = _firebaseAuth.currentUser!.uid;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("userId", userId);
      prefs.setString("mobileNumber", mobileNumber);
      return "success";
    } catch (e) {
      otpnotifer.setOtpVerifying(false);
      String status = "";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-verification-code':
            status = "The OTP entered is incorrect. Please try again.";
            break;
          case 'session-expired':
            status = "The verification session has expired. Please request a new OTP.";
            break;
          default:
            status = "An unknown error occurred. Please try again.";
        }
      } else {
        status = "An unknown error occurred. Please try again.";
      }
      return status;
    }
  }

  Future<String> resendOtp() async {
    if (resendToken == null) {
      throw Exception("Cannot resend OTP. Resend token not available.");
    }
    screen = 1;
    try {
      state = true; // Loading state
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: resendOtpTime),
        forceResendingToken: resendToken, // Use the saved resendToken
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
          state = false; // Authentication successful
        },
        verificationFailed: (FirebaseAuthException e) {
          state = false; // Reset loading
          throw e; // Handle errors appropriately in UI
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          this.resendToken = resendToken; // Update resend token
          state = false; // Code resent successfully
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
    } catch (e) {
      state = false; // Reset state on error
      print("Error resending OTP: $e");
    } finally {
      screen = 0;
    }
    return "success";
  }

  void resetVerificationState() {
    // Reset all state variables to start fresh
    verificationId = null;
    resendToken = null;
    state = false;
  }
}

final phoneAuthProvider = StateNotifierProvider<PhoneAuthNotifier, bool>((ref) {
  return PhoneAuthNotifier(ref.watch(firebaseAuthProvider), ref);
});

class OtpStatusNotifier extends ChangeNotifier {
  bool showVerifyButton = false;
  bool otpVerifying = false;
  bool get getShowVerifyButton => showVerifyButton;
  void setShowVerifyButton(bool value) {
    showVerifyButton = value;
    notifyListeners();
  }

  bool get getOtpVerifying => otpVerifying;
  void setOtpVerifying(bool value) {
    otpVerifying = value;
    notifyListeners();
  }
}

final otpStatusProvider = ChangeNotifierProvider((ref) => OtpStatusNotifier());
final otpVerifyingSelector = Provider<bool>((ref) {
  return ref.watch(otpStatusProvider).getOtpVerifying;
});

class ResendOtpTimerNotifier extends StateNotifier<int> {
  ResendOtpTimerNotifier() : super(0);
  Timer? _timer;
  void startCountdown(int seconds) {
    state = seconds;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 0) {
        state = state - 1;
      } else {
        timer.cancel();
      }
    });
  }

  bool get isEnabled => state == 0; // Button enabled when countdown reaches 0

  void resetTimer() {
    _timer?.cancel(); // Cancel timer
    state = 0; // Reset countdown to 0
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final resendOtpTimerProvider = StateNotifierProvider<ResendOtpTimerNotifier, int>((ref) {
  return ResendOtpTimerNotifier();
});
