import 'dart:async';
import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:oasis_smart_services/util/global_variables.dart';
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
  final String status;

  OtpState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isResent = false,
    this.errorMessage,
    this.isVerified = false,
    this.countdown = 0,
    this.screen = -1,
    this.status = '',
  });

  OtpState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isResent,
    String? errorMessage,
    bool? isVerified,
    int? screen,
    int? countdown,
    String? status,
  }) {
    return OtpState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isResent: isResent ?? this.isResent,
      errorMessage: errorMessage,
      isVerified: isVerified ?? this.isVerified,
      screen: screen ?? this.screen,
      countdown: countdown ?? this.countdown,
      status: status ?? this.status
    );
  }
}

// Notifier class to handle OTP logic
class OtpNotifier extends StateNotifier<OtpState> {
  Timer? _timer;
  OtpNotifier() : super(OtpState());

  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, screen: 0, isSuccess: false, errorMessage: null, isResent: false, status: 'sendotp');
    //print('$apiUrl/customer/sendOTP');
    final url = Uri.parse('$apiUrl/customer/sendOTP');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false, isSuccess: true, status: '');
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to send OTP';
        state = state.copyWith(isLoading: false, errorMessage: error, status: '');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString(), status: '');
    }
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    state = state.copyWith(isLoading: true, screen: 1, isSuccess: false, isVerified: false, isResent: false, errorMessage: null, status: 'verifyotp');
    final url = Uri.parse('$apiUrl/customer/verifyOTP');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
      );
      //print(response.body);
      if (response.statusCode == 200) {
        mobileNumber = phoneNumber;
        userId = jsonDecode(response.body)["userId"];
        userName = jsonDecode(response.body)["fullName"];
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("userId", userId);
        prefs.setString("userName", userName);
        prefs.setString("mobileNumber", mobileNumber);
        state = state.copyWith(isLoading: false, isVerified: true, status: '');
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Invalid OTP';
        state = state.copyWith(isLoading: false, errorMessage: error, status: '');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString(), status: '');
    }
  }

  Future<void> verifyOtpCreateAccount(String country, String phoneNumber, String fullName, String address, String zip, bool verifyOtp, String otp, WidgetRef ref) async {
    state = state.copyWith(isLoading: true, screen: 1, isSuccess: false, isVerified: false, errorMessage: null, isResent: false, status: 'otpandaccount');
    final url = Uri.parse('$apiUrl/customer/verifyOTPandAccount');
    //print({'country': country, 'phoneNumber': phoneNumber, 'otp': otp, 'fullName': fullName, 'address': address, 'zip': zip, 'verifyOtp': verifyOtp});
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'country': country, 'phoneNumber': phoneNumber, 'otp': otp, 'fullName': fullName, 'address': address, 'zip': zip, 'verifyOtp': verifyOtp}),
      );
      if (response.statusCode == 200) {
        mobileNumber = phoneNumber;
        userId = jsonDecode(response.body)["userId"];
        userName = jsonDecode(response.body)["fullName"];
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("userId", userId);
        prefs.setString("userName", userName);
        prefs.setString("mobileNumber", mobileNumber);
        prefs.setString("userCountry", country);
        userCountry = country;
        ref.read(userIdProvider.notifier).state = userId;
        ref.read(nameProvider.notifier).state = userName;
        ref.read(mobileNoProvider.notifier).state = mobileNumber;
        ref.read(countryProvider.notifier).state = country;
        //ref.read(nameProvider.notifier).state = userName;
        state = state.copyWith(isLoading: false, isVerified: true, status: '');
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Invalid OTP';
        state = state.copyWith(isLoading: false, errorMessage: error, status: '');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString(), status: '');
    }
  }

  Future<void> accountDeletion(String userId) async {
    state = state.copyWith(isLoading: true, isSuccess: false, screen: 1, isResent: false, errorMessage: null, status: 'deletion');
    final url = Uri.parse('$apiUrl/customer/deleteAccount/$userId');
    try {
      await http.get(url);
      state = state.copyWith(isLoading: false, errorMessage: '', status: '');
    }catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString(), status: '');
      print('Error in account deletion: ${e.toString()}');
    }
  }

  Future<void> resendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, isSuccess: false, screen: 1, isResent: false, errorMessage: null, status: 'resendotp', isVerified: false);
    final url = Uri.parse('$apiUrl/customer/sendOTP');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
        //startCountdown(30); // Start the 30-second countdown
        state = state.copyWith(isLoading: false, isResent: true, status: '');
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to resend OTP';
        state = state.copyWith(isLoading: false, errorMessage: error, status: '');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString(), status: '');
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
final isShowVerify = StateProvider.autoDispose<bool>((ref) => false);

final countryProvider = StateProvider<String>((ref) => userCountry.isEmpty ? "Oman" : userCountry);
final nameProvider = StateProvider<String>((ref) => userName);
final userIdProvider = StateProvider<String>((ref) => userId);
final mobileNoProvider = StateProvider<String>((ref) => mobileNumber);