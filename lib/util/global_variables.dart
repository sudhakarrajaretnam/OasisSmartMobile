import 'package:flutter/material.dart';

const nameTitle = "Oassis";
//const primaryColor = Color(0xFF4CAF50);
const primaryColor = Color(0xFF4966B5);
const bodyBackground = Color(0xFFA0BFC9);
const lightBg = Color(0xFFAFC3F9);
const int resendOtpTime = 10;
late String mobileNumber;
late String userId;
late String userName;
const currency = '₹';
// '﷼'
const historyDataLimit = 20;
//const String apiUrl = 'http://10.0.2.2:7000/mobile';
//const String apiUrl = 'http://eliastech.centralindia.cloudapp.azure.com:7501/mobile';
const String apiUrl = 'https://oasissmarts.eliastech.i/mobile';

enum CategoryType {
  grocery,
  service,
}

extension TimeOfDayExtension on TimeOfDay {
  String formatTime() {
    final formattedHour = hour.toString().padLeft(2, '0');
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute';
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
