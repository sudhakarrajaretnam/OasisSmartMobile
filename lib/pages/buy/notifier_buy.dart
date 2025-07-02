import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:oasis_smart_services/util/global_variables.dart';

class BuyNotifier extends ChangeNotifier {
  bool _showSearch = false;

  bool get showSearch => _showSearch;

  void setShowSearch(bool value) {
    _showSearch = value;
    notifyListeners();
  }
}

final buyNotifierProvider = ChangeNotifierProvider<BuyNotifier>((ref) {
  return BuyNotifier();
});

class GroceryApiService {
  final String baseUrl;

  GroceryApiService(this.baseUrl);

  Future<List<dynamic>> searchCategory(String query) async {
    //print('$baseUrl/buy/categories?search=$query');
    final url = Uri.parse('$baseUrl/grocery/categories?search=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<dynamic>> searchProduct(String categoryId, String query) async {
    //print('$baseUrl/grocery/items/$categoryId?search=$query');
    final url = Uri.parse('$baseUrl/grocery/items/$categoryId?search=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }
}

final groceryApiProvider = Provider<GroceryApiService>((ref) {
  return GroceryApiService(apiUrl);
});

final groceryCategoryProvider = FutureProvider.autoDispose.family<List<dynamic>, String>((ref, query) async {
  final groceryApi = ref.read(groceryApiProvider);
  return groceryApi.searchCategory(query);
});

class GroceryItemsParams {
  final String categoryId;
  final String query;

  const GroceryItemsParams({required this.categoryId, required this.query});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroceryItemsParams && runtimeType == other.runtimeType && categoryId == other.categoryId && query == other.query;

  @override
  int get hashCode => categoryId.hashCode ^ query.hashCode;
}

// final groceryItemsProvider = FutureProvider.family<List<dynamic>, Map<String, String>>((ref, params) async {
//   final groceryApi = ref.read(groceryApiProvider);
//   return groceryApi.searchProduct(params['categoryId']!, params['query']!);
// });

final groceryItemsProvider = FutureProvider.autoDispose.family<List<dynamic>, GroceryItemsParams>((ref, params) async {
  final groceryApi = ref.read(groceryApiProvider);
  return groceryApi.searchProduct(params.categoryId, params.query);
});
