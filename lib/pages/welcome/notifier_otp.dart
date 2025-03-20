import 'dart:async';
import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:oassis_mart/util/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State class to manage OTP request status
class OtpState {
  final bool isLoading;
  final bool isSuccess;
  final bool isResent;
  final String? errorMessage;
  final bool isVerified;
  final int countdown;
  final int screen;

  OtpState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isResent = false,
    this.errorMessage,
    this.isVerified = false,
    this.countdown = 0,
    this.screen = -1,
  });

  OtpState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isResent,
    String? errorMessage,
    bool? isVerified,
    int? screen,
    int? countdown,
  }) {
    return OtpState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isResent: isResent ?? this.isResent,
      errorMessage: errorMessage,
      isVerified: isVerified ?? this.isVerified,
      screen: screen ?? this.screen,
      countdown: countdown ?? this.countdown,
    );
  }
}

// Notifier class to handle OTP logic
class OtpNotifier extends StateNotifier<OtpState> {
  Timer? _timer;
  OtpNotifier() : super(OtpState());

  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, screen: 0, isSuccess: false, errorMessage: null);
    //print('$apiUrl/customer/sendOTP');
    final url = Uri.parse('$apiUrl/customer/sendOTP');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to send OTP';
        state = state.copyWith(isLoading: false, errorMessage: error);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    state = state.copyWith(isLoading: true, screen: 1, isSuccess: false, isVerified: false, errorMessage: null);
    final url = Uri.parse('$apiUrl/customer/verifyOTP');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
      );
      print(response.body);
      if (response.statusCode == 200) {
        mobileNumber = phoneNumber;
        userId = jsonDecode(response.body)["userId"];
        userName = jsonDecode(response.body)["fullName"];
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("userId", userId);
        prefs.setString("userName", userName);
        prefs.setString("mobileNumber", mobileNumber);
        state = state.copyWith(isLoading: false, isVerified: true);
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Invalid OTP';
        state = state.copyWith(isLoading: false, errorMessage: error);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> resendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, isSuccess: false, screen: 1, isResent: false, errorMessage: null);
    final url = Uri.parse('$apiUrl/customer/sendOTP');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
        //startCountdown(30); // Start the 30-second countdown
        state = state.copyWith(isLoading: false, isResent: true);
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to resend OTP';
        state = state.copyWith(isLoading: false, errorMessage: error);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void startCountdown(int seconds) {
    state = state.copyWith(countdown: seconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdown <= 1) {
        timer.cancel();
        state = state.copyWith(countdown: 0);
      } else {
        state = state.copyWith(countdown: state.countdown - 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Provider for OTP Notifier
final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>((ref) => OtpNotifier());
final isShowVerify = StateProvider<bool>((ref) => false);

final countryProvider = StateProvider<String>((ref) => 'Oman');
