import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oasis_smart_services/pages/buy/empty_cart.dart';
import 'package:oasis_smart_services/pages/services/cart/service_cart_items.dart';
import 'package:oasis_smart_services/pages/services/footer/service_footer_preview.dart';
import 'package:oasis_smart_services/pages/services/notifier_service.dart';
import 'package:oasis_smart_services/util/global_variables.dart';

class ServiceCartPage extends ConsumerWidget {
  const ServiceCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(serviceNotifierProvider); // Watch cart state
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
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/services', // Target route
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
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
                          return ServiceListItem(cartItem: cart[index]);
                        },
                      ),
              ),
            ],
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: ServicePreviewFooter(),
          ),
        ],
      ),
    );
  }
}
