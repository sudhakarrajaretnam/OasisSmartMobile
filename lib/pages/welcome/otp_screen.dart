import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
//import 'package:loader_overlay/loader_overlay.dart';
//import 'package:oassis_mart/helper/message_box.dart';
//import 'package:oassis_mart/helper/message_box.dart';
//import 'package:oassis_mart/pages/welcome/notifier_firebase_auth.dart';
import 'package:oassis_mart/pages/welcome/notifier_otp.dart';
import 'package:oassis_mart/pages/welcome/otp_verify.dart';
import 'package:oassis_mart/util/global_variables.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OtpScreen();
}

class _OtpScreen extends ConsumerState<OtpScreen> {
  late FocusNode _focusNode;
  final TextEditingController _otpController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //ref.watch(phoneAuthProvider);
    ref.listen<OtpState>(otpProvider, (previous, next) {
      if (next.screen == 0 && next.isSuccess) {
        final countrycode = ref.read(countryProvider) == 'Oman' ? "+968" : "+91";
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerify(mobile: '$countrycode${_otpController.text}'),
          ),
        );
      } else if (next.screen == 0 && next.errorMessage != null) {
        // Show an error message as a SnackBar
        //print(next.errorMessage);
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
    });
    final otpState = ref.watch(otpProvider);
    final otpNotifier = ref.read(otpProvider.notifier);
    final countryVal = ref.watch(countryProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: otpState.isLoading ? 0.5 : 1.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Enter your mobile number",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                  const SizedBox(height: 30),
                  // const Text(
                  //   "Mobile Number",
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.w400,
                  //     color: Colors.black54,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  // const Text(
                  //   'Select your country:',
                  //   style: TextStyle(fontSize: 16),
                  // ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                    value: countryVal,
                    hint: const Text('Choose a country'),
                    isExpanded: true,
                    items: ['Oman', 'India'].map((String country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      ref.read(countryProvider.notifier).state = newValue!;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    keyboardType: TextInputType.number,
                    focusNode: _focusNode,
                    controller: _otpController,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                      hintText: "Enter your number",
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            countryVal == 'Oman'
                                ? Image.asset('assets/images/om.png', height: 40, width: 40)
                                : Image.asset('assets/images/in.png', height: 40, width: 40),
                            const SizedBox(width: 8),
                            Text(
                              countryVal == 'Oman' ? "+968" : "+91",
                              //"+91",
                              style: const TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 80, // Adjust width to fit icon and code
                        minHeight: 24,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        otpNotifier.sendOtp('${countryVal == 'Oman' ? "+968" : "+91"}${_otpController.text}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Text(
                        "Log In",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (otpState.isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
