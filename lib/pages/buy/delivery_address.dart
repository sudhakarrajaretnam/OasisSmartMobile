import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oasis_smart_services/helper/otp_verifier.dart';
import 'package:oasis_smart_services/pages/buy/notifier_address.dart';
import 'package:oasis_smart_services/pages/buy/notifier_cart.dart';
import 'package:oasis_smart_services/pages/buy/order_accepted.dart';
import 'package:oasis_smart_services/pages/services/notifier_service.dart';
import 'package:oasis_smart_services/pages/services/order/order_success.dart';
import 'package:oasis_smart_services/pages/welcome/notifier_otp.dart';
import 'package:oasis_smart_services/util/global_variables.dart';

class AddressPage extends ConsumerStatefulWidget {
  final CategoryType categoryType;
  const AddressPage({super.key, required this.categoryType});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddressPageState();
}

class _AddressPageState extends ConsumerState<AddressPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController(text: mobileNumber);
  final TextEditingController addressController = TextEditingController();
  //final TextEditingController pinController = TextEditingController();
  final FocusNode focusNode = FocusNode();
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

  void _submitGroceryForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final selCountry = ref.read(countryProvider);
      //final otpdone = await showOtpProcess(context,nameController.text, '${selCountry == 'Oman' ? '+968' : '+91'}${mobileController.text}', ref.read(countryProvider.notifier).state, addressController.text, pinController.text, ref);
      final otpdone = await showOtpProcess(context,nameController.text, '${selCountry == 'Oman' ? '+968' : '+91'}${mobileController.text}', ref.read(countryProvider.notifier).state, addressController.text, '', ref);
      if (otpdone == "stop") {
        return;
      }
      ref.read(isLoadingProvider.notifier).state = true;
      try {
        final address = ref.read(addressProvider);
        //await ref.read(cartProvider.notifier).submitCart(nameController.text, addressController.text, pinController.text, address.isNew);
        await ref.read(cartProvider.notifier).submitCart(nameController.text, addressController.text, '', address.isNew);
        final cardNoti = ref.read(cartProvider.notifier);
        //print(cardNoti.orderId);
        Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => OrderAcceptedPage(
              recId: cardNoti.recId,
              orderCode: cardNoti.orderId,
              createdAt: cardNoti.createdAt,
            ),
          ),
          (route) => false, // Remove all routes
        );
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

  void _submitServiceForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final selCountry = ref.read(countryProvider);
      //final otpdone = await showOtpProcess(context,nameController.text, '${selCountry == 'Oman' ? '+968' : '+91'}${mobileController.text}', ref.read(countryProvider.notifier).state, addressController.text, pinController.text, ref);
      final otpdone = await showOtpProcess(context,nameController.text, '${selCountry == 'Oman' ? '+968' : '+91'}${mobileController.text}', ref.read(countryProvider.notifier).state, addressController.text, '', ref);
      if (otpdone == "stop") {
        return;
      } 
      ref.read(isLoadingProvider.notifier).state = true;
      try {
        final address = ref.read(addressProvider);
        await ref
            .read(serviceNotifierProvider.notifier)
            .submitServiceCart(nameController.text, addressController.text, '', address.isNew);
            //.submitServiceCart(nameController.text, addressController.text, pinController.text, address.isNew);
        final cardNoti = ref.read(serviceNotifierProvider.notifier);
        Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessPage(
              recId: cardNoti.recId,
              orderCode: cardNoti.orderId,
              serviceName: cardNoti.serviceName,
              createdAt: cardNoti.createdAt,
            ),
          ),
          (route) => false, // Remove all routes
        );
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
    int totalItems = 0;
    int itemNewCount = 0;
    double totalAmount = 0.0;
    if (widget.categoryType == CategoryType.grocery) {
      totalItems = ref.read(cartProvider).fold<int>(0, (sum, item) => sum + item.quantity);
      itemNewCount = ref.read(cartProvider).length;
      totalAmount = ref.read(cartProvider).fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity));
    } else if (widget.categoryType == CategoryType.service) {
      totalItems = ref.read(serviceNotifierProvider).fold<int>(0, (sum, item) => sum + item.quantity);
      totalAmount = ref.read(serviceNotifierProvider).fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity));
    }

    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures the content resizes when the keyboard opens
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Address',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 8.0, right: 16),
            decoration: const BoxDecoration(
              color: lightBg,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
              onPressed: () {
                if (widget.categoryType == CategoryType.grocery) {
                  Navigator.of(context).pushReplacementNamed('/buyhome');
                } else if (widget.categoryType == CategoryType.service) {
                  Navigator.of(context).pushReplacementNamed('/services');
                }
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: (addressState.isLoading || isLoading) ? 0.5 : 1.0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
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
                              padding: const EdgeInsets.only(left: 8, right: 16),
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.categoryType == CategoryType.grocery ? "Items: ($itemNewCount)" : "Services: ($totalItems)",
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            "Amount: $currency${totalAmount.toStringAsFixed(0)}",
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (widget.categoryType == CategoryType.grocery) {
                              _submitGroceryForm(context);
                            } else {
                              _submitServiceForm(context);
                            } 
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
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
