import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oasis_smart_services/util/global_variables.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatelessWidget {
  final List<String> items = [
    "Oasis Smart",
    "Eliastech",
    "Central India",
    "Cloudapp Azure",
  ];
  ContactUs({super.key});

  void _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(phoneUri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error: Unable to make phone call',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void sendEmail(sendTo, BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: sendTo,
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Hello Oasis Smart',
        'body': '',
      }),
    );
    try {
      await launchUrl(emailUri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error: Unable to launch email client',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Contact Us'),
        ),
        body: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text("Address", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey[600])),
                ),
                const SizedBox(height: 5),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor, width: 1),
                      // Rounded corners
                      // boxShadow: const [
                      //   BoxShadow(
                      //     color: Colors.black12,
                      //     blurRadius: 2,
                      //     offset: Offset(0, 2), // subtle shadow
                      //   ),
                      // ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 10, right: 20, top: 20, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.placemark,
                                color: primaryColor,
                                size: 30,
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Oasis Smarts Services & Trading,'),
                                  Text('Way 3508,'),
                                  Text('MBD Area,Ruwi,'),
                                  Text('Opposite to MBD Spar,'),
                                  Text('Muscat, Sultanate of Oman')
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text("Call Us", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey[600])),
                ),
                const SizedBox(height: 5),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor, width: 1), // Rounded corners
                      // boxShadow: const [
                      //   BoxShadow(
                      //     color: Colors.black12,
                      //     blurRadius: 2,
                      //     offset: Offset(0, 2), // subtle shadow
                      //   ),
                      // ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(CupertinoIcons.device_phone_portrait, color: primaryColor),
                              const SizedBox(width: 10),
                              const Text('+968  9985 1216'),
                              const Spacer(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: const CircleBorder(), // Circular shape
                                  padding: const EdgeInsets.all(10), // Padding for the button
                                ),
                                child: const Icon(Icons.call, color: Colors.white),
                                onPressed: () => _makePhoneCall('+96899851216', context),
                              ),
                            ],
                          ),
                          Divider(
                            color: Colors.grey[400],
                            height: 20,
                          ),
                          Row(
                            children: [
                              const Icon(CupertinoIcons.device_phone_portrait, color: primaryColor),
                              const SizedBox(width: 10),
                              const Text('+968 9985 1214'),
                              const Spacer(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: const CircleBorder(), // Circular shape
                                  padding: const EdgeInsets.all(10), // Padding for the button
                                ),
                                child: const Icon(Icons.call, color: Colors.white),
                                onPressed: () => _makePhoneCall('+96899851214', context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text("Email", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey[600])),
                ),
                const SizedBox(height: 5),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor, width: 1), // Rounded corners
                      // boxShadow: const [
                      //   BoxShadow(
                      //     color: Colors.black12,
                      //     blurRadius: 2,
                      //     offset: Offset(0, 2), // subtle shadow
                      //   ),
                      // ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(CupertinoIcons.envelope, color: primaryColor),
                              const SizedBox(width: 10),
                              const Text('info@oasissmarts.com'),
                              const Spacer(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: const CircleBorder(), // Circular shape
                                  padding: const EdgeInsets.all(10), // Padding for the button
                                ),
                                child: const Icon(Icons.mail, color: Colors.white),
                                onPressed: () => sendEmail('info@oasissmarts.com', context),
                              ),
                            ],
                          ),
                          Divider(
                            color: Colors.grey[400],
                            height: 20,
                          ),
                          Row(
                            children: [
                              const Icon(CupertinoIcons.envelope, color: primaryColor),
                              const SizedBox(width: 10),
                              const Text('cs@oasissmarts.com'),
                              const Spacer(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: const CircleBorder(), // Circular shape
                                  padding: const EdgeInsets.all(10), // Padding for the button
                                ),
                                child: const Icon(Icons.mail, color: Colors.white),
                                onPressed: () => sendEmail('cs@oasissmarts.com', context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
