import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import './cart.dart';
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  late String? authToken;
  String? userId;
  List<OrderItem> _orders = [];
  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://shop-app-1891b-default-rtdb.firebaseio.com/orders.json?auth=$authToken';
    print('============ addOrder =============== ');
    final timestamp = DateTime.now();
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'amount': total,
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
            'creatorId': userId,
            'dateTime': timestamp.toIso8601String()
          }));
      if (response.statusCode == 200) {
        _orders.insert(
          0,
          OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: timestamp,
          ),
        );
      }
      if (response.statusCode >= 400) {}
    } catch (err) {
      print(err);
    }
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    String? filterString = '&orderBy="creatorId"&equalTo="$userId"';

    final url = Uri.parse(
        'https://shop-app-1891b-default-rtdb.firebaseio.com/orders.json?auth=$authToken$filterString');
    print('==auth url== $url');
    final List<OrderItem> loadedOrder = [];
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      print(
          '======================= fetchAndSetOrders ==============  get statusCode: ${response.statusCode}');
      print('======================= BODY ==============  : ${response.body}');

      extractedData.forEach((orderId, orderData) {
        print('======= $orderId');
        loadedOrder.add(OrderItem(
            id: orderId,
            amount: orderData['amount'],
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    title: item['title'],
                    quantity: int.parse(item['quantity'].toString()),
                    price: item['price'],
                    id: item['id'],
                  ),
                )
                .toList(),
            dateTime: DateTime.parse(orderData['dateTime'])));
      });
      _orders = loadedOrder.reversed.toList();
      print(_orders.length);
      notifyListeners();
    } catch (err) {
      print('error order $err');
    }
  }
}
