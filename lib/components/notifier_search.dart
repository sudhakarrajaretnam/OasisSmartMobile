import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:oassis_mart/util/global_variables.dart';

class SearchItemsParams {
  final String resultType;
  final String query;

  const SearchItemsParams({required this.resultType, required this.query});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchItemsParams && runtimeType == other.runtimeType && resultType == other.resultType && query == other.query;

  @override
  int get hashCode => resultType.hashCode ^ query.hashCode;
}

final searchProvider = FutureProvider.family<List<Map<String, String>>, SearchItemsParams>((ref, params) async {
  if (params.query.isEmpty) return [];
  final response = await http.get(Uri.parse("$apiUrl/grocery/searchItems/${params.resultType}?search=${params.query}"));
  //print(response.body);
  if (response.statusCode == 200) {
    final List results = json.decode(response.body);
    return results
        .map((item) => {
              'title': item['title'] as String,
              'imagePath': item['imagePath'] as String,
              'itemCode': item['itemCode'] as String,
              '_id': item['_id'] as String,
              'discountPrice': "${item['discountPrice']}",
              'description': item['description'] as String,
              'displayQuantity': "${item['quantity']} ${item['unit']}",
              'type': item['type'] as String,
            })
        .toList();
  } else {
    throw Exception('Failed to fetch results');
  }
});

final searchServiceProvider = FutureProvider.family<List<Map<String, String>>, SearchItemsParams>((ref, params) async {
  if (params.query.isEmpty) return [];
  final response = await http.get(Uri.parse("$apiUrl/service/searchItems/${params.resultType}?search=${params.query}"));
  //print(response.body);
  if (response.statusCode == 200) {
    final List results = json.decode(response.body);
    return results
        .map((item) => {
              'title': item['title'] as String,
              'imagePath': item['imagePath'] as String,
              '_id': item['_id'] as String,
              'price': "${item['price']}",
              'description': item['description'] as String,
              'noOfPersons': "${item['noOfPersons']}",
              'workingHours': "${item['workingHours']}",
              'type': item['type'] as String,
            })
        .toList();
  } else {
    throw Exception('Failed to fetch results');
  }
});
