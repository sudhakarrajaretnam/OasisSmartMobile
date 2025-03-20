import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oassis_mart/components/notifier_search.dart';
import 'package:oassis_mart/components/search_filter.dart';
import 'package:oassis_mart/helper/itemdetails_dialog.dart';
import 'package:oassis_mart/pages/buy/footer/cart_footer.dart';
import 'package:oassis_mart/pages/buy/notifier_buy.dart';
import 'package:oassis_mart/pages/buy/notifier_cart.dart';
import 'package:oassis_mart/util/global_variables.dart';
import 'package:oassis_mart/util/no_record.dart';

final showSearchNotifier = StateProvider.autoDispose<bool>((ref) => false);

class ItemsPage extends ConsumerStatefulWidget {
  final String categoryName;
  final String categiryId;
  const ItemsPage({super.key, required this.categoryName, required this.categiryId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ItemsPage();
}

class _ItemsPage extends ConsumerState<ItemsPage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final searchTextProvider = StateProvider<String>((ref) => '');
  final Map<int, int> itemQuantities = {};
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = widget.categoryName;
    final categoryId = widget.categiryId;
    //final allItems = ref.watch(groceryItemsProvider({'categoryId': categoryId, 'query': ''}));
    final allItems = ref.watch(
      groceryItemsProvider(GroceryItemsParams(categoryId: categoryId, query: '')),
    );
    final cart = ref.watch(cartProvider);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), // Slightly taller AppBar
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          centerTitle: true,
          title: Text(
            categoryName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: const BoxDecoration(
                color: lightBg,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                onPressed: () {
                  final searchFlag = ref.read(showSearchNotifier.notifier).state;
                  ref.read(showSearchNotifier.notifier).state = !searchFlag;
                  if (!searchFlag) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _focusNode.requestFocus();
                    });
                  } else {
                    _searchController.clear();
                    _focusNode.unfocus();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      // body: Stack(
      //   children: [
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: allItems.when(
      //         data: (items) {
      //           if (items.isEmpty) {
      //             return noRecordWidget(context);
      //           }
      //           return GridView.builder(
      //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //               crossAxisCount: 3, // Show 3 items in a row
      //               crossAxisSpacing: 8.0,
      //               mainAxisSpacing: 8.0,
      //               childAspectRatio: 0.68, // Adjust the height of each card
      //             ),
      //             itemCount: items.length,
      //             itemBuilder: (context, index) {
      //               final item = items[index];
      //               final cartItem = cart.firstWhere(
      //                 (cartItem) => cartItem.itemId == item['_id'],
      //                 orElse: () => CartItem(
      //                   itemId: item['_id'],
      //                   itemCode: item['itemCode'] as String,
      //                   itemName: item['itemName'],
      //                   price: item['discountPrice'].toDouble(),
      //                   quantity: 0,
      //                   displayQuantity: "${item['quantity']}${item['unit']}",
      //                   description: item['description'] as String,
      //                   imageUrl: item['imagePath'] as String,
      //                 ),
      //               );

      //               return Card(
      //                 elevation: 0,
      //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //                 color: const Color(0xFFF8F8F8),
      //                 child: Padding(
      //                   padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      //                   child: Column(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       Expanded(
      //                         child: InkWell(
      //                           onTap: () {
      //                             Future.delayed(
      //                               const Duration(milliseconds: 50),
      //                               () {
      //                                 if (context.mounted) {
      //                                   showFullScreenDialog(
      //                                     context,
      //                                     ref,
      //                                     item['itemName'],
      //                                     item['imagePath'] as String,
      //                                     item['description'] as String,
      //                                     "${item['quantity']}${item['unit']}",
      //                                     item['discountPrice'].toString(),
      //                                     item['_id'] as String,
      //                                     item['itemCode'] as String,
      //                                   );
      //                                 }
      //                               },
      //                             );
      //                           },
      //                           //behavior: HitTestBehavior.opaque,
      //                           child: Align(
      //                             alignment: Alignment.center,
      //                             child: CachedNetworkImage(
      //                               imageUrl: item['imagePath'] as String,
      //                               placeholder: (context, url) => const Center(
      //                                 child: SizedBox(
      //                                   width: 24, // Width of the circular indicator
      //                                   height: 24, // Height of the circular indicator
      //                                   child: CircularProgressIndicator(
      //                                     strokeWidth: 2.0, // Thickness of the progress indicator
      //                                   ),
      //                                 ),
      //                               ), // Placeholder while loading
      //                               errorWidget: (context, url, error) => const Icon(Icons.broken_image), // Fallback for errors
      //                               fit: BoxFit.contain,
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //                       //const SizedBox(height: 4),
      //                       Padding(
      //                         padding: const EdgeInsets.only(left: 6.0),
      //                         child: Column(
      //                           crossAxisAlignment: CrossAxisAlignment.start,
      //                           children: [
      //                             Text(
      //                               item['itemName'] as String,
      //                               style: const TextStyle(fontWeight: FontWeight.bold),
      //                               textAlign: TextAlign.center,
      //                             ),
      //                             // const SizedBox(height: 4),
      //                             Text(
      //                               "${item['quantity']} ${item['unit']}",
      //                               style: const TextStyle(color: Colors.grey, fontSize: 12),
      //                               //textAlign: TextAlign.start,
      //                             ),
      //                           ],
      //                         ),
      //                       ),

      //                       //const SizedBox(height: 4),
      //                       Padding(
      //                         padding: const EdgeInsets.only(left: 6.0),
      //                         child: Row(
      //                           mainAxisAlignment: MainAxisAlignment.start,
      //                           crossAxisAlignment: CrossAxisAlignment.end,
      //                           children: [
      //                             Column(
      //                               children: [
      //                                 Text(
      //                                   "₹${item['discountPrice']}",
      //                                   style: const TextStyle(fontWeight: FontWeight.bold),
      //                                 ),
      //                                 //const SizedBox(width: 4),
      //                                 Text(
      //                                   "₹${item['price']}",
      //                                   style: const TextStyle(
      //                                     color: Colors.grey,
      //                                     decoration: TextDecoration.lineThrough,
      //                                     fontSize: 12,
      //                                   ),
      //                                 ),
      //                               ],
      //                             ),
      //                             const SizedBox(width: 8),
      //                             cartItem.quantity == 0
      //                                 ? Expanded(
      //                                     child: Material(
      //                                       color: Colors.transparent,
      //                                       child: InkWell(
      //                                         borderRadius: const BorderRadius.horizontal(left: Radius.circular(5), right: Radius.circular(5)),
      //                                         onTap: () {
      //                                           ref.read(cartProvider.notifier).addItem(
      //                                                 item['_id'],
      //                                                 item['itemCode'] as String,
      //                                                 item['itemName'],
      //                                                 item['discountPrice'].toDouble(),
      //                                                 item['imagePath'] as String,
      //                                                 "${item['quantity']} ${item['unit']}",
      //                                                 item['description'] as String,
      //                                               );
      //                                         },
      //                                         child: Ink(
      //                                           padding: const EdgeInsets.only(top: 4, bottom: 4),
      //                                           decoration: const BoxDecoration(
      //                                             color: Color(0xFFE9F6E1), // Green color for the button
      //                                             borderRadius: BorderRadius.horizontal(left: Radius.circular(5), right: Radius.circular(5)),
      //                                           ),
      //                                           child: Text(
      //                                             "Add",
      //                                             textAlign: TextAlign.center,
      //                                             style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
      //                                           ),
      //                                         ),
      //                                       ),
      //                                     ),
      //                                   )
      //                                 : Expanded(
      //                                     child: Container(
      //                                       padding: const EdgeInsets.only(top: 4, bottom: 4),
      //                                       decoration: BoxDecoration(
      //                                         color: const Color(0xFFE9F6E1),
      //                                         borderRadius: BorderRadius.circular(8),
      //                                       ),
      //                                       child: Row(
      //                                         mainAxisAlignment: MainAxisAlignment.center,
      //                                         children: [
      //                                           Material(
      //                                             color: Colors.transparent,
      //                                             child: InkWell(
      //                                               onTap: () {
      //                                                 ref.read(cartProvider.notifier).updateQuantity(
      //                                                       item['_id'],
      //                                                       cartItem.quantity - 1,
      //                                                     );
      //                                               },
      //                                               child: Ink(
      //                                                 child: const Icon(Icons.remove, color: Colors.green),
      //                                               ),
      //                                             ),
      //                                           ),
      //                                           Text(
      //                                             "${cartItem.quantity}",
      //                                             style: const TextStyle(fontWeight: FontWeight.bold),
      //                                           ),
      //                                           Material(
      //                                             color: Colors.transparent,
      //                                             child: InkWell(
      //                                               onTap: () {
      //                                                 // setState(() {
      //                                                 //   itemQuantities[index] = itemQuantities[index]! + 1;
      //                                                 // });
      //                                                 ref.read(cartProvider.notifier).updateQuantity(
      //                                                       item['_id'],
      //                                                       cartItem.quantity + 1,
      //                                                     );
      //                                               },
      //                                               child: Ink(
      //                                                 //padding: const EdgeInsets.only(top: 4, bottom: 4),
      //                                                 child: const Icon(Icons.add, color: Colors.green),
      //                                               ),
      //                                             ),
      //                                           ),
      //                                         ],
      //                                       ),
      //                                     ),
      //                                   ),
      //                           ],
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //               );
      //             },
      //           );
      //         },
      //         loading: () => Container(
      //           height: MediaQuery.of(context).size.height, // Full screen height
      //           alignment: Alignment.center, // Center the loader
      //           child: const CircularProgressIndicator(),
      //         ),
      //         error: (error, stackTrace) => Center(
      //           child: Text('Error: ${error.toString()}'), // Show error message if API fails
      //         ),
      //       ),
      //     ),
      //     const Align(
      //       alignment: Alignment.bottomCenter,
      //       child: CartFooter(),
      //     ),
      //   ],
      // ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer(
            builder: (context, ref, child) {
              final isShowSearch = ref.watch(showSearchNotifier);
              return isShowSearch
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                      child: SearchFilter<Map<String, String>>(
                        hintText: "Search services",
                        controller: _searchController,
                        focusNode: _focusNode,
                        suggestionsCallback: (query) async {
                          if (query.isEmpty) {
                            return [];
                          }
                          final response = await ref.read(searchProvider(SearchItemsParams(resultType: "items", query: query)).future);
                          return response;
                        },
                        itemBuilder: (context, Map<String, String> suggestion) {
                          return ListTile(
                            leading: CachedNetworkImage(
                              imageUrl: suggestion['imagePath'] ?? '',
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                  width: 18, // Width of the circular indicator
                                  height: 18, // Height of the circular indicator
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0, // Thickness of the progress indicator
                                  ),
                                ),
                              ), // Placeholder while loading
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image), // Fallback for errors
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                            title: Text(suggestion['title'] ?? 'No title'),
                          );
                        },
                        onSuggestionSelected: (Map<String, String> suggestion) {
                          Future.delayed(const Duration(milliseconds: 50), () async {
                            if (context.mounted) {
                              _searchController.clear();
                              _focusNode.unfocus();
                              ref.read(showSearchNotifier.notifier).state = false;
                              showFullScreenDialog(
                                context,
                                ref,
                                suggestion['title']!,
                                suggestion['imagePath']!,
                                suggestion['description'] as String,
                                "${suggestion['displayQuantity']}",
                                suggestion['discountPrice'].toString(),
                                suggestion['_id'] as String,
                                suggestion['itemCode'] as String,
                              );
                            }
                          });
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(content: Text('You selected: ${suggestion['title']}')),
                          // );
                        },
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: allItems.when(
                data: (items) {
                  if (items.isEmpty) {
                    return noRecordWidget(context);
                  }
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Show 3 items in a row
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.68, // Adjust the height of each card
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final cartItem = cart.firstWhere(
                        (cartItem) => cartItem.itemId == item['_id'],
                        orElse: () => CartItem(
                          itemId: item['_id'],
                          itemCode: item['itemCode'] as String,
                          itemName: item['itemName'],
                          price: item['discountPrice'].toDouble(),
                          quantity: 0,
                          displayQuantity: "${item['quantity']}${item['unit']}",
                          description: item['description'] as String,
                          imageUrl: item['imagePath'] as String,
                        ),
                      );

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        color: const Color(0xFFF8F8F8),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Future.delayed(
                                      const Duration(milliseconds: 50),
                                      () {
                                        if (context.mounted) {
                                          showFullScreenDialog(
                                            context,
                                            ref,
                                            item['itemName'],
                                            item['imagePath'] as String,
                                            item['description'] as String,
                                            "${item['quantity']}${item['unit']}",
                                            item['discountPrice'].toString(),
                                            item['_id'] as String,
                                            item['itemCode'] as String,
                                          );
                                        }
                                      },
                                    );
                                  },
                                  //behavior: HitTestBehavior.opaque,
                                  child: Align(
                                    alignment: Alignment.center,
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
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              //const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['itemName'] as String,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    // const SizedBox(height: 4),
                                    Text(
                                      "${item['quantity']} ${item['unit']}",
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      //textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                              ),

                              //const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "₹${item['discountPrice']}",
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        //const SizedBox(width: 4),
                                        Text(
                                          "₹${item['price']}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            decoration: TextDecoration.lineThrough,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    cartItem.quantity == 0
                                        ? Expanded(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(5), right: Radius.circular(5)),
                                                onTap: () {
                                                  ref.read(cartProvider.notifier).addItem(
                                                        item['_id'],
                                                        item['itemCode'] as String,
                                                        item['itemName'],
                                                        item['discountPrice'].toDouble(),
                                                        item['imagePath'] as String,
                                                        "${item['quantity']} ${item['unit']}",
                                                        item['description'] as String,
                                                      );
                                                },
                                                child: Ink(
                                                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFFE9F6E1), // Green color for the button
                                                    borderRadius: BorderRadius.horizontal(left: Radius.circular(5), right: Radius.circular(5)),
                                                  ),
                                                  child: Text(
                                                    "Add",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.only(top: 4, bottom: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE9F6E1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () {
                                                        ref.read(cartProvider.notifier).updateQuantity(
                                                              item['_id'],
                                                              cartItem.quantity - 1,
                                                            );
                                                      },
                                                      child: Ink(
                                                        child: const Icon(Icons.remove, color: Colors.green),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "${cartItem.quantity}",
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () {
                                                        // setState(() {
                                                        //   itemQuantities[index] = itemQuantities[index]! + 1;
                                                        // });
                                                        ref.read(cartProvider.notifier).updateQuantity(
                                                              item['_id'],
                                                              cartItem.quantity + 1,
                                                            );
                                                      },
                                                      child: Ink(
                                                        //padding: const EdgeInsets.only(top: 4, bottom: 4),
                                                        child: const Icon(Icons.add, color: Colors.green),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => Container(
                  height: MediaQuery.of(context).size.height, // Full screen height
                  alignment: Alignment.center, // Center the loader
                  child: const CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Center(
                  child: Text('Error: ${error.toString()}'), // Show error message if API fails
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: CartFooter(),
          ),
        ],
      ),
    );
  }
}
