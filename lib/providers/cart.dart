import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/httpException.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.title,
    required this.quantity,
    required this.price,
    required this.id,
  });
}

class Cart with ChangeNotifier {
  final String? authToken;
  String? _idQty;
  List<String> idCartList = [];

  Map<String, CartItem> _items = {};

  Cart(this.authToken, this._items);

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

//get quantity from the id
  int get getQuantityById {
    int quantity = 0;
    _items.forEach((key, value) {
      if (key == _idQty) {
        quantity = value.quantity;
      }
    });
    return quantity;
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          title: existingCartItem.title,
          quantity: existingCartItem.quantity + 1,
          price: existingCartItem.price,
          id: DateTime.now.toString(),
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          title: title,
          quantity: 1,
          price: price,
          id: DateTime.now().toString(),
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (_items.containsKey(productId)) {
      return;
    }

    if (_items[productId]!.quantity > 1) {
      _items.update(
          productId,
          (value) => CartItem(
              title: value.title,
              quantity: value.quantity - 1,
              price: value.price,
              id: value.id));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Future<void> addCartId(String id) async {
  //   final url =
  //       'https://shop-app-1891b-default-rtdb.firebaseio.com/carts/$id.json';
  //   try {
  //     print('======================= addCartId =========================');
  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: json.encode({
  //         'id': id,
  //         'title': title,
  //         'price': price,
  //         'quantity': 1,
  //       }),
  //     );

  //     //if fail
  //     if (response.statusCode >= 400) {
  //       throw HttpException('couldnt not add cart');
  //     }
  //     notifyListeners();
  //   } catch (error) {
  //     print('======================= $error =========================');
  //     throw error;
  //   }
  // }

  //update when id exist
  void _updateItem(String productId, double price, String title, int quantity) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          title: existingCartItem.title,
          quantity: existingCartItem.quantity + 1,
          price: existingCartItem.price,
          id: productId,
        ),
      );
    }
    notifyListeners();
  }

  void _addItem(String productId, double price, String title) {
    _items.putIfAbsent(
      productId,
      () => CartItem(
        title: title,
        quantity: 1,
        price: price,
        id: productId,
      ),
    );
  }

  //parsing data
  Future<void> parsingToMap(http.Response response) async {
    //load respon body as map
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    //make var to load the map
    final Map<String, CartItem> loadedCarts = {};
    print("==========parsingToMap===============$extractedData");

    //parsing each id and store data to loaded map
    extractedData.forEach((prodId, prodData) {
      loadedCarts[prodId] = CartItem(
        id: prodData['id'],
        title: prodData['title'],
        price: double.parse(prodData['price'].toString()),
        quantity: int.parse(prodData['quantity'].toString()),
      );
    });

    //remove an unnecesary items<example>
    loadedCarts.remove("\"id\"");
    _items = loadedCarts;
    print(_items.length);
    notifyListeners();
  }

  //when screen cart load, do this
  Future<void> fetchAndSetCart(
      String productId, double price, String title) async {
    final url =
        'https://shop-app-1891b-default-rtdb.firebaseio.com/carts.json?auth=$authToken';
    final response = await http.get(Uri.parse(url));
    parsingToMap(response);
  }
}
