import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

class UserProductScreen extends StatelessWidget {
  static const routName = '/user-product-sccreen';
  const UserProductScreen({Key? key}) : super(key: key);
  Future<void> _refreshProduct(BuildContext context) async {
    try {
      await Provider.of<Products>(context, listen: false)
          .fetchAndSetProducts(true);
    } catch (error) {
      print('fetch error in ovrview $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    //final productData = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Product'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProduct(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProduct(context),
                    child: Consumer<Products>(
                      builder: (context, productData, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: productData.items.length,
                          itemBuilder: (_, index) {
                            return Column(
                              children: [
                                UserProductItem(
                                  id: productData.items[index].id,
                                  title: productData.items[index].title,
                                  imageUrl: productData.items[index].imageUrl,
                                ),
                                const Divider()
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
