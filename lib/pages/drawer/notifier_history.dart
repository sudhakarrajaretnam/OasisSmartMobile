import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:oassis_mart/util/global_variables.dart';

class Order {
  final int orderId;
  final String recId;
  final int totalPrice;
  final int toalItems;
  final String createdAt;
  final String status;
  Order({
    required this.orderId,
    required this.recId,
    required this.totalPrice,
    required this.toalItems,
    required this.createdAt,
    required this.status,
  });
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      recId: json['_id'],
      totalPrice: json['totalPrice'],
      toalItems: json['toalItems'],
      createdAt: json['createdAt'],
      status: json['status'],
    );
  }
}

class OrderNotifier extends StateNotifier<List<Order>> {
  OrderNotifier() : super([]);
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isEmpty => state.isEmpty;

  Future<void> fetchOrders({bool isRefresh = false}) async {
    //print("$hasMore $isRefresh");
    if (_isLoading || (!_hasMore && !isRefresh)) return;
    _isLoading = true;
    state = [...state]; // Notify listeners
    if (isRefresh) {
      _page = 1;
      _hasMore = true;
      state = [];
    }

    try {
      final url = Uri.parse('$apiUrl/grocery/orderHistory/$userId?page=$_page&limit=$historyDataLimit');
      //print('$apiUrl/mobile/grocery/orderHistory/$userId?page=$_page&limit=$historyDataLimit');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        final List<Order> fetchedOrders = data.map((json) => Order.fromJson(json)).toList();
        if (fetchedOrders.length < historyDataLimit) {
          _hasMore = false;
        } else {
          _page++;
        }
        state = [...state, ...fetchedOrders];
      }
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      state = [...state];
    }
  }
}

class ServiceDetails {
  final String serviceId;
  final String serviceName;
  final String imagePath;
  final int noOfPersons;

  ServiceDetails({
    required this.serviceId,
    required this.serviceName,
    required this.imagePath,
    required this.noOfPersons,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    return ServiceDetails(
      serviceId: json['_id'],
      serviceName: json['serviceName'],
      imagePath: json['imagePath'],
      noOfPersons: json['noOfPersons'] as int, // Ensure it's a double
    );
  }
}

class Request {
  final String requestId;
  final double price;
  final int quantity;
  final DateTime selectDate;
  final String selectTime;
  final String status;
  final int orderId;
  final DateTime createdAt;
  final ServiceDetails serviceDetails;

  Request({
    required this.requestId,
    required this.price,
    required this.quantity,
    required this.selectDate,
    required this.selectTime,
    required this.status,
    required this.orderId,
    required this.createdAt,
    required this.serviceDetails,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      requestId: json['_id'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      selectDate: DateTime.parse(json['selectDate']),
      selectTime: json['selectTime'],
      status: json['status'],
      orderId: json['orderId'],
      createdAt: DateTime.parse(json['createdAt']),
      serviceDetails: ServiceDetails.fromJson(json['serviceDetails']),
    );
  }
}

class RequestNotifier extends StateNotifier<List<Request>> {
  RequestNotifier() : super([]);

  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isEmpty => state.isEmpty;

  Future<void> fetchRequests({bool isRefresh = false}) async {
    if (_isLoading || (!_hasMore && !isRefresh)) return;
    _isLoading = true;
    state = [...state];
    if (isRefresh) {
      _page = 1;
      _hasMore = true;
      state = [];
    }

    try {
      //print('$apiUrl/grocery/serviceHistory/$userId?page=$_page&limit=$historyDataLimit');
      final url = Uri.parse('$apiUrl/grocery/serviceHistory/$userId?page=$_page&limit=$historyDataLimit');
      final response = await http.get(url);
      //print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        final List<Request> fetchedRequests = data.map((json) => Request.fromJson(json)).toList();

        if (fetchedRequests.length < historyDataLimit) {
          _hasMore = false;
        } else {
          _page++;
        }

        state = [...state, ...fetchedRequests];
      }
    } catch (e) {
      print('Error fetching requests: $e');
    } finally {
      _isLoading = false;
      state = [...state];
    }
  }
}

final orderHistoryProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) => OrderNotifier());

final requestHistoryProvider = StateNotifierProvider<RequestNotifier, List<Request>>((ref) => RequestNotifier());
