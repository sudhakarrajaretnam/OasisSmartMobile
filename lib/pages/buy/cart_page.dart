import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oassis_mart/pages/buy/cart_listitem.dart';
import 'package:oassis_mart/pages/buy/empty_cart.dart';
import 'package:oassis_mart/pages/buy/footer/cart_preview_footer.dart';
import 'package:oassis_mart/pages/buy/notifier_cart.dart';
import 'package:oassis_mart/util/global_variables.dart';
//import 'package:oassis_mart/util/global_variables.dart';

class CartPage extends ConsumerWidget {
  //final String fromPage;
  //const CartPage({super.key, required this.fromPage});
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider); // Watch cart state
    final totalItems = cart.fold<int>(0, (sum, item) => sum + item.quantity);
    // final totalPrice = cart.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // Height of the border
          child: Container(
            color: const Color.fromARGB(255, 209, 209, 209), // Border color
            height: 1.0, // Thickness of the border
          ),
        ),
        leading: IconButton(
          //icon: Icon(fromPage == "cart" ? Icons.arrow_back : Icons.close, color: Colors.black),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            ref.read(isPreviewFooterRender.notifier).state = false;
            Navigator.pop(context);
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 8.0, right: 16),
            decoration: const BoxDecoration(
              color: lightBg,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/buyhome');
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: totalItems == 0
                    ? const EmptyCartPage()
                    : ListView.separated(
                        //padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 80.0),
                        itemCount: cart.length,
                        separatorBuilder: (_, __) => const Divider(
                          //height: 30,
                          color: Color.fromARGB(255, 209, 209, 209),
                        ),
                        itemBuilder: (context, index) {
                          final item = cart[index];
                          return CartListItem(
                            itemId: item.itemId,
                            imageUrl: item.imageUrl,
                            itemName: item.itemName,
                            quantity: item.quantity,
                            displayQuantity: item.displayQuantity,
                            price: item.price,
                          );
                        },
                      ),
              ),
            ],
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: CartPreviewFooter(),
          ),
        ],
      ),
    );
  }
}
