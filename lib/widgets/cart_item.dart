import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final double price;
  final int quantity;
  final String title;
  final String productId;

  CartItem({
    required this.id,
    required this.price,
    required this.quantity,
    required this.title,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Are You Sure'),
                  content:
                      const Text('Dou you want to remove item from the cart?'),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('No')),
                    FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Yes'))
                  ],
                ));
      },
      onDismissed: (direction) {
        Provider.of<Cart>(
          context,
          listen: false,
        ).removeItem(productId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: FittedBox(
                child: Text('\$${price}'),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${(price * quantity)}'),
            trailing: Text('${quantity}x'),
          ),
        ),
      ),
    );
  }
}
