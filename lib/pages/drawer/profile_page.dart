import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oasis_smart_services/helper/message_box.dart';
import 'package:oasis_smart_services/helper/otp_verifier.dart';
import 'package:oasis_smart_services/pages/buy/notifier_address.dart';
import 'package:oasis_smart_services/pages/buy/notifier_cart.dart';
import 'package:oasis_smart_services/pages/services/notifier_service.dart';
import 'package:oasis_smart_services/pages/welcome/notifier_otp.dart';
//import 'package:oasis_smart_services/pages/services/order/order_success.dart';
import 'package:oasis_smart_services/util/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController =
      TextEditingController(text: mobileNumber);
  final TextEditingController addressController = TextEditingController();
  //final TextEditingController pinController = TextEditingController();

  final FocusNode focusNode = FocusNode();
  //final TextEditingController otpController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () async {
        await fetchAddressAsync();
      });
      //await fetchAddressAsync();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    //pinController.dispose();
    focusNode.dispose();
    //otpController.dispose();
    super.dispose();
  }

  Future<void> fetchAddressAsync() async {
    try {
      await ref.read(addressProvider.notifier).fetchAddress();
      final addressState = ref.read(addressProvider);
      nameController.text = addressState.fullName ?? '';
      addressController.text = addressState.address ?? '';
      //pinController.text = addressState.pincode ?? '';
      final country = ref.read(countryProvider);
      final mobile = ref.read(mobileNoProvider);
      if (country.isNotEmpty) {
        final ext = country == "Oman" ? '+968' : country == 'India' ? '+91' : '';
        mobileController.text = mobile.isNotEmpty ? mobile.replaceAll(ext, '') : '';
      } else {
        mobileController.text = '';
      }
    } catch (e) {
      // Handle errors if needed
      debugPrint("Error fetching address: $e");
    }
  }

  void _submitServiceForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final selCountry = ref.read(countryProvider);
      //final otpdone = await showOtpProcess(context,nameController.text, '${selCountry == 'Oman' ? '+968' : '+91'}${mobileController.text}', ref.read(countryProvider.notifier).state, addressController.text, pinController.text, ref);
      final otpdone = await showOtpProcess(context,nameController.text, '${selCountry == 'Oman' ? '+968' : '+91'}${mobileController.text}', ref.read(countryProvider.notifier).state, addressController.text, '', ref);
      if (otpdone == "stop") {
        return;
      } else if (otpdone == "alldone") {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Your profile has been updated successfully',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }
      ref.read(isLoadingProvider.notifier).state = true;
      try {
        //await ref.read(serviceNotifierProvider.notifier).addAddress(
        //    nameController.text, addressController.text, pinController.text);
        await ref.read(serviceNotifierProvider.notifier).addAddress(
            nameController.text, addressController.text, '');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Your profile has been updated successfully',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (error) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                'Error: $error',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red),
        );
      } finally {
        // Hide loading indicator
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final addressState = ref.watch(addressProvider);
    final countryVal = ref.watch(countryProvider);
    final userIdVal = ref.watch(userIdProvider);
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Ensures the content resizes when the keyboard opens
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: (addressState.isLoading || isLoading) ? 0.5 : 1.0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0,30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Delivery Address',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.read(addressProvider.notifier).resetAddress();
                              nameController.clear();
                              addressController.clear();
                              //pinController.clear();
                            },
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.only(left: 8, right: 16),
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(
                              Icons.add,
                              size: 20,
                              color: Colors.white,
                            ),
                            label: const Text('New'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      buildTextField(
                        label: 'Name',
                        controller: nameController,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Select country",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: userIdVal.isEmpty ? Colors.grey[50] : Colors.grey[300],
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(12.0),
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
                        onChanged: userIdVal.isEmpty ? (String? newValue) {
                          ref.read(countryProvider.notifier).state = newValue!;
                          Future.delayed(const Duration(milliseconds: 100), () {
                            mobileController.clear();
                            focusNode.requestFocus();
                          });
                        } : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Your mobile number",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        focusNode: focusNode,
                        controller: mobileController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Mobile no is required';
                          }
                          return null;
                        },
                        style: const TextStyle(fontSize: 20),
                        readOnly: userIdVal.isNotEmpty,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: userIdVal.isEmpty ? Colors.grey[50] : Colors.grey[300],
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red, width: 1.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          hintText: "Enter your number",
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                countryVal == 'Oman'
                                    ? Image.asset('assets/images/om.png',
                                        height: 40, width: 40)
                                    : Image.asset('assets/images/in.png',
                                        height: 40, width: 40),
                                const SizedBox(width: 8),
                                Text(
                                  countryVal == 'Oman' ? "+968" : "+91",
                                  //"+91",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 20),
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
                      // const SizedBox(height: 16),
                      // buildTextField(
                      //   label: 'Mobile',
                      //   controller: mobileController,
                      //   keyboardType: TextInputType.phone,
                      // ),
                      const SizedBox(height: 16),
                      buildTextField(
                        label: 'Address',
                        controller: addressController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                      ),
                      // const SizedBox(height: 16),
                      // buildTextField(
                      //   label: 'Pin',
                      //   controller: pinController,
                      //   keyboardType: TextInputType.number,
                      // ),
                      // const SizedBox(height: 16),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       "Services: ($totalItems)",
                      //       style: const TextStyle(fontSize: 18),
                      //     ),
                      //     Text(
                      //       "Amount: $currency${totalAmount.toStringAsFixed(2)}",
                      //       style: const TextStyle(fontSize: 18),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _submitServiceForm(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Save Profile',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (userIdVal.isNotEmpty) {
                              _showAccountDeleteionDialog(context);
                            } else {
                              showErrorDialog(
                                context,
                                "No User Account",
                                "Your account has not been created yet. Please complete your registration.",
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Delete Account',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (addressState.isLoading || isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
  void _showAccountDeleteionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm?"),
          content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                Consumer(builder: (context, ref, child) {
                  final otpStatus = ref.watch(otpProvider);
                  return ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      await ref
                          .read(otpProvider.notifier)
                          .accountDeletion(userId);
                      
                      if (context.mounted) {
                        _deleteAccount(context);
                      }
                    },
                    child: otpStatus.isLoading
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text("Deleting"),
                            ],
                          )
                        : const Text('Delete'),
                  );
                })
              ],
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ref.read(userIdProvider.notifier).state = '';
    ref.read(countryProvider.notifier).state = 'Oman';
    ref.read(nameProvider.notifier).state = '';
    ref.read(mobileNoProvider.notifier).state = '';
    userId = "";
    userCountry = "Oman";
    userName = "";
    mobileNumber = "";
    if (context.mounted) {
      Navigator.pop(context);
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    }
  }


  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: label == 'Mobile',
          decoration: InputDecoration(
            filled: true,
            fillColor: label == 'Mobile' ? Colors.grey[300] : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: primaryColor, width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
