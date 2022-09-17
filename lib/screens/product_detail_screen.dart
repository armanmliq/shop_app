import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // final double price;

  // ProductDetailScreen(this.title, this.price);
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId =
        ModalRoute.of(context)?.settings.arguments as String; // is the id!
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Center(
                  child: Column(
                    children: [
                      Text(
                        loadedProduct.price == 0
                            ? 'free'
                            : '\$${loadedProduct.price}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        child: Text(
                          loadedProduct.description,
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(
                        height: 800,
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
