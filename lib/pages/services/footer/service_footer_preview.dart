import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oassis_mart/pages/buy/delivery_address.dart';
import 'package:oassis_mart/pages/services/notifier_service.dart';
import 'package:oassis_mart/util/global_variables.dart';

class ServicePreviewFooter extends ConsumerStatefulWidget {
  const ServicePreviewFooter({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ServicePreviewFooter();
}

class _ServicePreviewFooter extends ConsumerState<ServicePreviewFooter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        ref.read(isPreviewFooterRender.notifier).state = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(serviceNotifierProvider);
    final totalItems = cart.fold<int>(0, (sum, item) => sum + item.quantity);
    final totalPrice = cart.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity));
    final isRenderState = ref.watch(isPreviewFooterRender);
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      offset: isRenderState && totalItems > 0 ? Offset.zero : const Offset(0, 1),
      child: Container(
        //padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        margin: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0), // Adjusted for tighter spacing
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), //
        decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$totalItems Service${totalItems > 1 ? 's' : ''} | ₹${totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
            ),
            Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddressPage(
                              categoryType: CategoryType.service,
                            )), // Navigate to CartPage
                  );
                },
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Row(
                    children: [
                      Text(
                        "ORDER",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
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
