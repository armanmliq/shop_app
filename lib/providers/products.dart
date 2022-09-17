import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/httpException.dart';
import './product.dart';

class Products with ChangeNotifier {
  bool toBoolean(String str, [bool strict = false]) {
    if (strict == true) {
      return str == '1' || str == 'true';
    }
    return str != '0' && str != 'false' && str != '';
  }

  late List<Product> _items = [];
  List<Product> get items {
    return [..._items];
  }

  final String? authToken;
  final String? userId;
  Products(this.authToken, this.userId, this._items);

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  void setFavorite(bool _fav, String id) {
    final indexProd = _items.indexWhere((element) => element.id == id);
    _items[indexProd].isFavorite = _fav;
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    String? filterString;
    filterString = filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://shop-app-1891b-default-rtdb.firebaseio.com/products.json?auth=$authToken$filterString';
    log(url);
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      print(
          'url $url ==== fetchAndSetProducts ====  get statusCode: ${response.statusCode}');
      final urlIsFavorite =
          'https://shop-app-1891b-default-rtdb.firebaseio.com/userFavorite/$userId.json?auth=$authToken';
      final responseFavorite = await http.get(Uri.parse(urlIsFavorite));
      final favoriteData = json.decode(responseFavorite.body);
      print('fetch favorite res: ${responseFavorite.body}');
      final List<Product> loadedProduct = [];
      extractedData.forEach((prodId, prodData) {
        loadedProduct.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
          ),
        );
      });
      _items = loadedProduct;
      notifyListeners();
      log('response ${json.decode(response.body)["-N-qn8waoZrXTXRNfIij"]}');
    } catch (err) {
      print('error patch $err');
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shop-app-1891b-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      print('============ addProduct =============');
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'id': DateTime.now().toString(),
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print('======================= $error =========================');
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://shop-app-1891b-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      try {
        final response = await http.patch(
          Uri.parse(url),
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }),
        );
        print("========== response code: =========== ${response.statusCode}");
      } catch (err) {
        print('========== update product ========= $err');
      }
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shop-app-1891b-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex =
        _items.indexWhere((element) => id == element.id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    print('delete prodResponse:  ${response.statusCode}');
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw httpException('Couldnt delete product');
    }
    existingProduct = null;
  }

  Future<void> updateFavorite(bool _fav, String id) async {
    log('======== updateFavorite fav:${_fav}  id:${id}=========');

    final url =
        'https://shop-app-1891b-default-rtdb.firebaseio.com/userFavorite/$userId/$id.json?auth=$authToken';
    print(url);
    final response = await http.put(
      Uri.parse(url),
      body: json.encode(_fav),
    );
    print(response.body);
    if (response.statusCode >= 400) {
      setFavorite(!_fav, id);
      notifyListeners();
      throw httpException('couldnt change favorite');
    }
    print(response.statusCode);
  }
}
