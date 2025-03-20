import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oassis_mart/util/global_variables.dart';
import 'package:http/http.dart' as http;

class AddressState {
  final bool isNew;
  final String? address;
  final String? fullName;
  final String? pincode;
  final bool isLoading;

  AddressState({
    required this.isNew,
    this.address,
    this.fullName,
    this.pincode,
    this.isLoading = false,
  });
  AddressState copyWith({
    bool? isNew,
    String? address,
    String? fullName,
    String? pincode,
    bool? isLoading,
  }) {
    return AddressState(
      isNew: isNew ?? this.isNew,
      address: address ?? this.address,
      fullName: fullName ?? this.fullName,
      pincode: pincode ?? this.pincode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AddressNotifier extends StateNotifier<AddressState> {
  AddressNotifier() : super(AddressState(isNew: true, isLoading: true));
  Future<void> fetchAddress() async {
    state = state.copyWith(isLoading: true);
    try {
      final url = Uri.parse('$apiUrl/customer/getaddress/$userId');
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (data["address"].isNotEmpty) {
        state = state.copyWith(
          isNew: false,
          address: data["address"],
          fullName: data["fullName"],
          pincode: data["zip"],
          isLoading: false,
        );
      } else {
        state = state.copyWith(isNew: true, fullName: '', address: '', pincode: '', isLoading: false);
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void resetAddress() {
    state = state.copyWith(isNew: true, fullName: '', address: '', pincode: '', isLoading: false);
  }

  //AddressState get getAddress => state;

  void setAddress(String address, String fullName, String pincode) {
    state = state.copyWith(isNew: false, address: address, fullName: fullName, pincode: pincode);
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>(
  (ref) => AddressNotifier(),
);
