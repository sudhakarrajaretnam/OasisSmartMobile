import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
//import 'package:oassis_mart/pages/buy/notifier_cart.dart';
import 'package:oassis_mart/util/global_variables.dart';

class CartViewListItem extends ConsumerWidget {
  final String itemCode;
  final String itemName;
  final String imagePath;
  final int price;
  final int quantity;
  final String displayQuantity;
  final String status;

  const CartViewListItem({
    super.key,
    required this.itemCode,
    required this.itemName,
    required this.imagePath,
    required this.price,
    required this.quantity,
    required this.displayQuantity,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final cart = ref.watch(cartProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
      child: SizedBox(
        height: 100, // Add fixed height to the Row
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children to fill parent height
          children: [
            // Item Image
            Expanded(
              flex: 25,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                // child: Image.network(
                //   imagePath,
                //   fit: BoxFit.contain,
                //   errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
                // ),
                child: CachedNetworkImage(
                  imageUrl: imagePath,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 32, // Width of the circular indicator
                      height: 32, // Height of the circular indicator
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0, // Thickness of the progress indicator
                      ),
                    ),
                  ), // Placeholder while loading
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image), // Fallback for errors
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Item Details and Quantity Controls
            Expanded(
              flex: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space items vertically
                children: [
                  // Item Name and Weight
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "$displayQuantity, $currency $price",
                        style: const TextStyle(color: Color.fromARGB(255, 87, 87, 87), fontSize: 14),
                      ),
                    ],
                  ),
                  // Quantity Controls
                  Row(
                    children: [
                      // Decrement Button
                      Material(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.grey.shade300), // Border color
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            // ref.read(cartProvider.notifier).updateQuantity(
                            //       itemId,
                            //       quantity - 1,
                            //     );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.remove, color: Colors.green),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Quantity Text
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            "$quantity",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Increment Button
                      Material(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.grey.shade300), // Border color
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            //ref.read(cartProvider.notifier).updateQuantity(itemId, quantity + 1);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.add, color: Colors.green),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Price and Close Button
            Expanded(
              flex: 25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space items vertically
                children: [
                  // Close Button
                  Align(
                    alignment: Alignment.topRight,
                    child: Material(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        //side: BorderSide(color: Colors.grey.shade300), // Border color
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          //ref.read(cartProvider.notifier).removeItem(itemId);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.close, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  // Price Text
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "$currency${(price * quantity).toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
