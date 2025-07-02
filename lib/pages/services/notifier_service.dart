import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:oasis_smart_services/pages/welcome/notifier_otp.dart';

import 'package:oasis_smart_services/util/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceDialogNotifier extends ChangeNotifier {
  bool _isEntryDialog = false;
  ServiceItem? _item;

  void setServiceItem(ServiceItem item) {
    _item = item;
  }

  void openEntryDialog(ServiceItem item) {
    if (!_isEntryDialog) {
      _isEntryDialog = true;
      _item = item;
      notifyListeners();
    }
  }

  void closeEntryDialog() {
    _isEntryDialog = false;
    _item = null;
    notifyListeners();
  }

  bool get isEntryDialog => _isEntryDialog;
  ServiceItem? get item => _item;
}

final serviceDialogProvider = ChangeNotifierProvider.autoDispose((ref) => ServiceDialogNotifier());

class ServiceItem {
  final String serviceId;
  final String serviceName;
  final String imageUrl;
  final double price;
  final int? noOfPersons;
  final int? workingHours;
  final String description;
  final int quantity;
  final String? comment;
  final DateTime? selectDate;
  final TimeOfDay? selectTime;

  ServiceItem({
    required this.serviceId,
    required this.serviceName,
    required this.imageUrl,
    required this.price,
    required this.noOfPersons,
    required this.workingHours,
    required this.description,
    required this.quantity,
    this.comment,
    this.selectDate,
    this.selectTime,
  });

  ServiceItem copyWith({int? quantity, DateTime? selectDate, TimeOfDay? selectTime, String? comment}) {
    return ServiceItem(
      serviceId: serviceId,
      serviceName: serviceName,
      price: price,
      //noOfPersons: noOfPersons,
      noOfPersons: 0,
      workingHours: 0,
      quantity: quantity ?? this.quantity,
      description: description,
      imageUrl: imageUrl,
      comment: comment ?? this.comment,
      selectDate: selectDate ?? this.selectDate,
      selectTime: selectTime ?? this.selectTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'price': price,
      'quantity': quantity,
      'comment': comment,
      'selectDate': selectDate?.toIso8601String(),
      'selectTime': selectTime?.formatTime(),
    };
  }
}

class ServiceNotifier extends StateNotifier<List<ServiceItem>> {
  late Ref ref;
  ServiceNotifier(this.ref) : super([]) {
    ref = ref;
  }
  List<dynamic> _orderId = [];
  List<dynamic> _recId = [];
  String _createdAt = "";
  List<dynamic> _serviceName = [];

  List<dynamic> get orderId => _orderId;
  String get createdAt => _createdAt;
  List<dynamic> get recId => _recId;
  List<dynamic> get serviceName => _serviceName;

  void addItem(ServiceItem item, int quantity, DateTime? selectDate, TimeOfDay? selectTime, String? comment) {
    final existingItem = state.firstWhere(
      (oritem) => oritem.serviceId == item.serviceId,
      orElse: () => ServiceItem(
        serviceId: item.serviceId,
        serviceName: item.serviceName,
        price: item.price,
        noOfPersons: 0,
        workingHours: 0,
        imageUrl: item.imageUrl,
        description: item.description,
        quantity: -1,
        comment: item.comment,
        selectDate: item.selectDate,
        selectTime: item.selectTime,
      ),
    );
    if (existingItem.quantity == -1 && quantity == 0) {
      return;
    } else if (existingItem.quantity != -1 && quantity == 0) {
      state = state.where((ori) => ori.serviceId != item.serviceId).toList();
    } else if (existingItem.quantity == -1) {
      state = [...state, existingItem.copyWith(quantity: quantity, selectDate: selectDate, selectTime: selectTime, comment: comment)];
    } else {
      state = state.map((oritem) {
        if (oritem.serviceId == item.serviceId) {
          return item.copyWith(quantity: quantity, selectDate: selectDate, selectTime: selectTime, comment: comment);
        } else {
          return oritem;
        }
      }).toList();
    }
  }

  Future<void> submitServiceCart(String fullName, String address, String pincode, bool isNew) async {
    final url = Uri.parse('$apiUrl/service/purchaseRequest');
    final cartItems = state.map((item) => item.toJson()).toList();
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'cartItems': cartItems, 'fullName': fullName, 'address': address, 'pincode': pincode, 'isNew': isNew}),
      );
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getString('userName') != fullName) {
          ref.read(nameProvider.notifier).state = fullName;
          userName = fullName;
          prefs.setString('userName', fullName);
        }
        final data = json.decode(response.body);
        _recId = data['recId'];
        _orderId = data['orderId'];
        _serviceName = data['serviceName'];
        _createdAt = data['createdAt'];
        state = [];
      } else {
        print('Failed to submit cart: ${response.body}');
      }
    } catch (error) {
      print('Error submitting cart: $error');
    }
  }

  Future<void> addAddress(String fullName, String address, String pincode) async {
    final url = Uri.parse('$apiUrl/service/addaddress');
    //print({'userId': userId, 'fullName': fullName, 'address': address, 'pincode': pincode, 'coutry': ref.read(countryProvider), 'mobile': mobileNumber});
    try {
      final response = await http.put(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': userId, 'fullName': fullName, 'address': address, 'pincode': pincode, 'coutry': userCountry, 'mobile': mobileNumber}));
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getString('userName') != fullName) {
          ref.read(nameProvider.notifier).state = fullName;
          userName = fullName;
          prefs.setString('userName', fullName);
        }
      } else {
        print('Failed to submit address: ${response.body}');
      }
    } catch (error) {
      print('Error submitting address: $error');
    }
  }

  void updateQuantity(String serviceId, int quantity) {
    state = state.map((item) {
      if (item.serviceId == serviceId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
    state = state.where((item) => item.quantity > 0).toList();
  }

  void removeItem(String serviceId) {
    state = state.where((item) => item.serviceId != serviceId).toList();
  }

  bool isItemInCart(String serviceId) {
    return state.any((item) => item.serviceId == serviceId);
  }

  void clearCart() {
    state = [];
  }
}

final serviceNotifierProvider = StateNotifierProvider.autoDispose<ServiceNotifier, List<ServiceItem>>((ref) => ServiceNotifier(ref));

class ServiceCategory {
  final String baseUrl;

  ServiceCategory(this.baseUrl);

  Future<List<dynamic>> searchCategory(String query) async {
    //print('$baseUrl/service/getServices?search=$query');
    final url = Uri.parse('$baseUrl/service/getServices?search=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<dynamic>> searchService(String serviceId) async {
    //print('$baseUrl/grocery/items/$categoryId?search=$query');
    final url = Uri.parse('$baseUrl/service/items/$serviceId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }
}

final serviceApiProvider = Provider<ServiceCategory>((ref) {
  return ServiceCategory(apiUrl);
});

final serviceCategoryProvider = FutureProvider.autoDispose.family<List<dynamic>, String>((ref, query) async {
  final serviceCategory = ref.read(serviceApiProvider);
  return serviceCategory.searchCategory(query);
});

final serviceItemsProvider = FutureProvider.autoDispose.family<List<dynamic>, String>((ref, serviceId) async {
  final serviceCategory = ref.read(serviceApiProvider);
  return serviceCategory.searchService(serviceId);
});

final isPreviewFooterRender = StateProvider<bool>((ref) => false);

class ServiceViewService {
  Future<Map<String, dynamic>> fetchCartDetails(String cartId) async {
    final response = await http.get(Uri.parse('$apiUrl/service/orderDetails/$cartId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load cart details');
    }
  }
}

class ServiceViewNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ServiceViewService serviceViewService;
  ServiceViewNotifier(this.serviceViewService) : super(const AsyncValue.loading());

  Future<void> fetchCartDetails(String cartId) async {
    state = const AsyncValue.loading();
    try {
      final cartDetails = await serviceViewService.fetchCartDetails(cartId);
      state = AsyncValue.data(cartDetails);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  void reset() {
    state = const AsyncValue.loading();
  }
}

final viewServiceProvider = StateNotifierProvider.autoDispose<ServiceViewNotifier, AsyncValue<Map<String, dynamic>>>(
  (ref) => ServiceViewNotifier(ServiceViewService()),
);

// class ServiceSearchNotifier extends ChangeNotifier {
//   bool _showSearch = false;

//   bool get showSearch => _showSearch;

//   void setShowSearch(bool value) {
//     _showSearch = value;
//     notifyListeners();
//   }
// }

// final serviceSearchProvider = ChangeNotifierProvider<ServiceSearchNotifier>((ref) {
//   return ServiceSearchNotifier();
// });
