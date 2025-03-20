import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oassis_mart/util/global_variables.dart';
import 'package:http/http.dart' as http;

class CartDisplayItem {
  final String itemCode;
  final String itemName;
  final String imagePath;
  final int price;
  final int quantity;
  final String displayQuantity;

  CartDisplayItem(
      {required this.itemCode,
      required this.itemName,
      required this.imagePath,
      required this.price,
      required this.quantity,
      required this.displayQuantity});

  CartDisplayItem copyWith() {
    return CartDisplayItem(
      itemCode: itemCode,
      itemName: itemName,
      price: price,
      quantity: quantity,
      imagePath: imagePath,
      displayQuantity: displayQuantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'itemName': itemName,
      'price': price,
      'quantity': quantity,
      'imagePath': imagePath,
      'displayQuantity': displayQuantity,
    };
  }
}

class CartDataList {
  final String status;
  final String createdAt;
  final int totalPrice;
  final List<CartDisplayItem> items;

  CartDataList({required this.status, required this.items, required this.createdAt, required this.totalPrice});

  CartDataList copyWith() {
    return CartDataList(
      status: status,
      items: items,
      createdAt: createdAt,
      totalPrice: totalPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'createdAt': createdAt,
      'items': items,
      'totalPrice': totalPrice,
    };
  }
}

class CartViewNotifier extends StateNotifier<List<CartDataList>> {
  CartViewNotifier() : super([]);
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void clear() {
    state = [];
  }

  Future<void> getDetails(String requestId) async {
    _isLoading = true;
    state = [...state];
    final url = Uri.parse('$apiUrl/grocery/orderDetails/$requestId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        //print(response.body);
        final data = json.decode(response.body);
        final List<CartDataList> cartDataList = [];
        final List<CartDisplayItem> items = [];
        //for (var item in data) {
        for (var cartItem in data['items']) {
          final buyItems = cartItem['buyItem'];
          items.add(CartDisplayItem(
            itemCode: buyItems['itemCode'],
            itemName: buyItems['itemName'],
            price: cartItem['price'],
            quantity: buyItems['quantity'],
            displayQuantity: "${buyItems['quantity']} ${buyItems['unit']}",
            imagePath: buyItems['imagePath'],
          ));
        }
        //}
        cartDataList.add(CartDataList(
          status: data['status'],
          items: items,
          totalPrice: data['totalPrice'],
          createdAt: data['createdAt'],
        ));
        state = cartDataList;
        //print("Cart Data: $state");
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      state = [...state];
    }
  }
}

final cartViewProvider = StateNotifierProvider.autoDispose<CartViewNotifier, List<CartDataList>>((ref) {
  return CartViewNotifier();
});

final isViewFooterRender = StateProvider.autoDispose<bool>((ref) => false);
