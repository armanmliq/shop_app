import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/order_screen.dart';
import './screens/user_product_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) =>
              Products('', '', []), //now it has contructor property
          update: (ctx, auth, previousProducts) => Products(
            auth.token,
            auth.UserId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Cart>(
          create: (ctx) => Cart('', {}), //now it has contructor property
          update: (ctx, auth, previousCart) => Cart(
            auth.token,
            previousCart == null ? {} : previousCart.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders('', '', []), //now it has contructor property
          update: (ctx, auth, previousCart) => Orders(
            auth.token,
            auth.UserId,
            previousCart == null ? [] : previousCart.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            fontFamily: 'Lato',
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                .copyWith(secondary: Colors.deepOrange),
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? const Center(child: CircularProgressIndicator())
                          : snapshot.data == false
                              ? AuthScreen()
                              : ProductsOverviewScreen(),
                ),
          routes: {
            ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrderScreen.routeName: (ctx) => OrderScreen(),
            UserProductScreen.routName: (ctx) => const UserProductScreen(),
            EditProductScreen.routeName: (ctx) => const EditProductScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
