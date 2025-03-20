import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oassis_mart/pages/buy/cart_page.dart';
import 'package:oassis_mart/pages/buy/notifier_cart.dart';
import 'package:oassis_mart/util/global_variables.dart';

final isFooterRender = StateProvider.autoDispose<bool>((ref) => true);

class CartFooter extends ConsumerStatefulWidget {
  const CartFooter({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CartFooter();
}

class _CartFooter extends ConsumerState<CartFooter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        ref.read(isFooterRender.notifier).state = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final totalItems = cart.fold<int>(0, (sum, item) => sum + item.quantity);
    final totalPrice = cart.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity));
    final isRenderState = ref.watch(isFooterRender);
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      offset: isRenderState
          ? const Offset(0, 1)
          : totalItems > 0
              ? Offset.zero
              : const Offset(0, 1),
      //offset: totalItems > 0 ? Offset.zero : const Offset(0, 1),
      child: Container(
        //padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        margin: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0), // Adjusted for tighter spacing
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), //
        decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$totalItems item${totalItems > 1 ? 's' : ''} | ₹${totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
            ),
            Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () {
                  ref.read(isFooterRender.notifier).state = true;
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartPage()), // Navigate to CartPage
                      ).then((_) {
                        Future.delayed(const Duration(milliseconds: 200), () {
                          ref.read(isFooterRender.notifier).state = false;
                        });
                      });
                    }
                  });
                },
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Row(
                    children: [
                      Text(
                        "VIEW CART",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
