import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oassis_mart/pages/drawer/dialogs/notifier_viewdetails.dart';
import 'package:oassis_mart/util/global_variables.dart';

class ViewFooter extends ConsumerStatefulWidget {
  const ViewFooter({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewFooter();
}

class _ViewFooter extends ConsumerState<ViewFooter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        ref.read(isViewFooterRender.notifier).state = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRenderState = ref.watch(isViewFooterRender);
    final cart = ref.watch(cartViewProvider);
    final totalItems = cart[0].items.length;
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      offset: isRenderState ? Offset.zero : const Offset(0, 1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        margin: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0), // Adjusted for tighter spacing
        //padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), //
        decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$totalItems item${totalItems > 1 ? 's' : ''} | ₹${cart[0].totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: const Row(
                children: [
                  Icon(
                    CupertinoIcons.ellipsis_circle,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Pending",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
