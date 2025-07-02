import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oasis_smart_services/pages/welcome/notifier_otp.dart';
import 'package:oasis_smart_services/util/global_variables.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String itemId;
  final String itemCode;
  final String itemName;
  final String imageUrl;
  final double price;
  final String displayQuantity;
  final String description;
  final int quantity;

  CartItem({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.displayQuantity,
    required this.description,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      itemId: itemId,
      itemCode: itemCode,
      itemName: itemName,
      price: price,
      quantity: quantity ?? this.quantity,
      displayQuantity: displayQuantity,
      description: description,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buyItem': itemId,
      'itemCode': itemCode,
      'price': price,
      'quantity': quantity,
    };
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  late Ref ref;
  // ServiceNotifier(this.ref) : super([]) {
  //   ref = ref;
  // }
  CartNotifier(this.ref) : super([]) {
    ref = ref;
  }
  int _orderId = 0;
  String _recId = "";
  String _createdAt = "";
  int get orderId => _orderId;
  String get createdAt => _createdAt;
  String get recId => _recId;

  void addItem(String itemId, String itemCode, String itemName, double price, String imageUrl, String displayQuantity, String description) {
    final existingItem = state.firstWhere(
      (item) => item.itemId == itemId,
      orElse: () => CartItem(
          itemId: itemId,
          itemCode: itemCode,
          itemName: itemName,
          price: price,
          quantity: 0,
          imageUrl: imageUrl,
          displayQuantity: displayQuantity,
          description: description),
    );

    if (existingItem.quantity == 0) {
      state = [...state, existingItem.copyWith(quantity: 1)];
    } else {
      updateQuantity(itemId, existingItem.quantity + 1);
    }
  }

  void addOrUpdateItem(CartItem cartItem, int quantity) {
    final existingItem = state.firstWhere(
      (item) => item.itemId == cartItem.itemId,
      orElse: () => CartItem(
          itemId: cartItem.itemId,
          itemCode: cartItem.itemCode,
          itemName: cartItem.itemName,
          price: cartItem.price,
          quantity: -1,
          imageUrl: cartItem.imageUrl,
          displayQuantity: cartItem.displayQuantity,
          description: cartItem.description),
    );

    if (existingItem.quantity == -1) {
      state = [...state, existingItem.copyWith(quantity: quantity)];
    } else {
      updateQuantity(cartItem.itemId, quantity);
    }
  }

  void updateQuantity(String itemId, int quantity) {
    state = state.map((item) {
      if (item.itemId == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    // Remove the item if the quantity is 0
    state = state.where((item) => item.quantity > 0).toList();
  }

  void removeItem(String itemId) {
    state = state.where((item) => item.itemId != itemId).toList();
  }

  void clearCart() {
    state = [];
  }

  Future<void> submitCart(String fullName, String address, String pincode, bool isNew) async {
    final url = Uri.parse('$apiUrl/grocery/purchaseRequest');
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
        _createdAt = data['createdAt'];
        state = [];
      } else {
        print('Failed to submit cart: ${response.body}');
      }
    } catch (error) {
      print('Error submitting cart: $error');
    }
  }
}

final cartProvider = StateNotifierProvider.autoDispose<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier(ref);
});
final isPreviewFooterRender = StateProvider<bool>((ref) => false);
//final isFooterRender = StateProvider<bool>((ref) => false);
final isLoadingProvider = StateProvider<bool>((ref) => false);
