import 'package:flutter/material.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import '../screens/order_screen.dart';
import '../screens/user_product_screen.dart';
import '../providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Hello '),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Shop'),
            onTap: () {
              Navigator.of(context).push(
                PageTransition(
                  child: ProductsOverviewScreen(),
                  type: PageTransitionType.leftToRight,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Orders'),
            onTap: () {
              Navigator.of(context).push(
                PageTransition(
                  child: OrderScreen(),
                  type: PageTransitionType.leftToRight,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Manage Products'),
            onTap: () {
              Navigator.of(context).push(
                PageTransition(
                  child: const UserProductScreen(),
                  type: PageTransitionType.leftToRight,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pushNamed(AuthScreen.routeName);
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
