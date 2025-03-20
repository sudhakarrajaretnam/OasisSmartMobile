import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oassis_mart/pages/services/notifier_service.dart';
import 'package:oassis_mart/util/global_variables.dart';

class ServiceItemTile extends ConsumerWidget {
  final ServiceItem cartItem;
  final dynamic item;
  const ServiceItemTile({super.key, required this.cartItem, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFF8F8F8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 5, right: 8),
              child: Center(
                child: Text(
                  item['serviceName'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, height: 1.2),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () {
                ref.read(serviceDialogProvider.notifier).openEntryDialog(cartItem);
              },
              //behavior: HitTestBehavior.opaque,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CachedNetworkImage(
                    imageUrl: item['imagePath'] as String,
                    placeholder: (context, url) => const Center(
                      child: SizedBox(
                        width: 24, // Width of the circular indicator
                        height: 24, // Height of the circular indicator
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0, // Thickness of the progress indicator
                        ),
                      ),
                    ), // Placeholder while loading
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image), // Fallback for errors
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            const Text(
                              "Person",
                              style: TextStyle(fontWeight: FontWeight.w400, height: 1.2),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${item['noOfPersons']}",
                              style: const TextStyle(fontWeight: FontWeight.bold, height: 1.2),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const Text(
                              "Price",
                              style: TextStyle(fontWeight: FontWeight.w400, height: 1.2),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "$currency${item['price']}",
                              style: const TextStyle(fontWeight: FontWeight.bold, height: 1.2),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    //mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12), right: Radius.circular(12)),
                          onTap: () {
                            ref.read(serviceDialogProvider.notifier).openEntryDialog(cartItem);
                          },
                          child: Ink(
                            padding: const EdgeInsets.only(top: 6, bottom: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE9F6E1), // Green color for the button
                              //color: Color.fromARGB(255, 253, 213, 213), // Green color for the button
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(12), right: Radius.circular(12)),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    cartItem.quantity == 0 ? "Add" : "Added",
                                    //textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                                  ),
                                ),
                                cartItem.quantity == 0
                                    ? const SizedBox()
                                    : Positioned(
                                        right: 10,
                                        top: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.green[500],
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.check, color: Colors.white, size: 14),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
