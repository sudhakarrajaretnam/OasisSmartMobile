import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oasis_smart_services/pages/buy/notifier_cart.dart';
import 'package:oasis_smart_services/util/global_variables.dart';

final itemQuantity = StateProvider<int>((ref) => 0);

void showFullScreenDialog(BuildContext context, WidgetRef ref, String title, String imagePath, String description, String displayQuantity,
    String discountPrice, String id, String itemcode) {
  final cart = ref.watch(cartProvider);
  final cartItem = cart.firstWhere(
    (cartItem) => cartItem.itemId == id,
    orElse: () => CartItem(
      itemId: id,
      itemCode: itemcode,
      itemName: title,
      price: double.parse(discountPrice),
      quantity: 1,
      displayQuantity: displayQuantity,
      description: description,
      imageUrl: imagePath,
    ),
  );

  // Initialize the itemQuantity state for the dialog
  ref.read(itemQuantity.notifier).state = cartItem.quantity;

  showGeneralDialog(
    context: context,
    barrierLabel: 'Dialog',
    barrierDismissible: true,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation1, animation2) {
      return Consumer(
        builder: (context, ref, child) {
          final quantity = ref.watch(itemQuantity);

          return Material(
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Close button
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 250,
                                child: PageView(
                                  children: [
                                    CachedNetworkImage(
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
                                      fit: BoxFit.cover,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                cartItem.itemName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${cartItem.displayQuantity} $currency${cartItem.price.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          side: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(15),
                                          onTap: () {
                                            if (quantity > 1) {
                                              ref.read(itemQuantity.notifier).state -= 1;
                                            }
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.remove, color: Colors.green),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 60,
                                        child: Center(
                                          child: Text(
                                            "$quantity",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              decoration: TextDecoration.none,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          side: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(15),
                                          onTap: () {
                                            ref.read(itemQuantity.notifier).state += 1;
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.add, color: Colors.green),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$currency${(cartItem.price * quantity).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Divider(color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              const Text(
                                'Product Detail',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: TextDecoration.none,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                cartItem.description,
                                style: const TextStyle(fontSize: 14, color: Colors.black54, decoration: TextDecoration.none),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 16, left: 30, right: 30),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).addOrUpdateItem(cartItem, ref.read(itemQuantity.notifier).state);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'ADD TO CART',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}
