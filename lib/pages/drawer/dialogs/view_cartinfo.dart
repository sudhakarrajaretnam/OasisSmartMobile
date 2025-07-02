import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oasis_smart_services/pages/drawer/dialogs/cart_listitem.dart';
import 'package:oasis_smart_services/pages/drawer/dialogs/notifier_viewdetails.dart';
import 'package:oasis_smart_services/pages/drawer/dialogs/view_footer.dart';

class ViewCartInfo extends ConsumerStatefulWidget {
  final String requestId;
  const ViewCartInfo({super.key, required this.requestId});

  @override
  ConsumerState<ViewCartInfo> createState() => _ViewCartInfo();
}

class _ViewCartInfo extends ConsumerState<ViewCartInfo> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 350)); // Wait for animation
      _fetchData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchData() async {
    ref.read(cartViewProvider.notifier).getDetails(widget.requestId);
  }

  @override
  Widget build(BuildContext context) {
    final cartInfo = ref.watch(cartViewProvider);
    final cartViewNotifer = ref.watch(cartViewProvider.notifier);
    return Scaffold(
      body: cartViewNotifer.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : cartInfo.isEmpty
              ? Center(
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(
                      "No items found",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            //padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 90),
                            itemCount: cartInfo[0].items.length,
                            separatorBuilder: (_, __) => const Divider(
                              //height: 30,
                              color: Color.fromARGB(255, 209, 209, 209),
                            ),
                            itemBuilder: (context, index) {
                              final item = cartInfo[0].items[index];
                              return CartViewListItem(
                                itemCode: item.itemCode,
                                imagePath: item.imagePath,
                                itemName: item.itemName,
                                quantity: item.quantity,
                                price: item.price,
                                displayQuantity: item.displayQuantity,
                                status: cartInfo[0].status,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ViewFooter(status: cartInfo[0].status),
                    ),
                  ],
                ),
    );
  }
}
