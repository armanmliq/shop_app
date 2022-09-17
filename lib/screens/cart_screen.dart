import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/order_screen.dart';
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart' as ci;
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Spacer(),
                  Chip(
                      label: Text(
                        '\$${cart.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6!
                              .color,
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor),
                  buttonOrder(cart: cart),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (ctx, i) => ci.CartItem(
                title: cart.items.values.toList()[i].title,
                quantity: cart.items.values.toList()[i].quantity,
                price: cart.items.values.toList()[i].price,
                id: cart.items.values.toList()[i].id,
                productId: cart.items.keys.toList()[i],
              ),
              itemCount: cart.items.length,
            ),
          ),
        ],
      ),
    );
  }
}

class buttonOrder extends StatefulWidget {
  const buttonOrder({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<buttonOrder> createState() => _buttonOrderState();
}

class _buttonOrderState extends State<buttonOrder> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: ((widget.cart.totalAmount <= 0) || (_isLoading))
            ? () {
                print(widget.cart.totalAmount);
              }
            : () async {
                setState(() {
                  _isLoading = true;
                });
                await Provider.of<Orders>(context, listen: false).addOrder(
                    widget.cart.items.values.toList(), widget.cart.totalAmount);
                setState(() {
                  _isLoading = false;
                });
                widget.cart.clear();
                Navigator.of(context).pushNamed(OrderScreen.routeName);
              },
        child: !_isLoading
            ? Text(
                'Order Now',
                style: TextStyle(
                    color: Theme.of(
                  context,
                ).primaryColor),
              )
            : CircularProgressIndicator());
  }
}
