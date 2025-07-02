//import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oasis_smart_services/components/notifier_search.dart';
import 'package:oasis_smart_services/components/search_filter.dart';
import 'package:oasis_smart_services/pages/services/dialog_servicepreview.dart';
import 'package:oasis_smart_services/pages/services/footer/service_footer.dart';
import 'package:oasis_smart_services/pages/services/notifier_service.dart';
import 'package:oasis_smart_services/pages/services/service_item_card.dart';
import 'package:oasis_smart_services/util/global_variables.dart';
import 'package:oasis_smart_services/util/no_record.dart';

final showSearchNotifier = StateProvider.autoDispose<bool>((ref) => false);

class ShowServiceitems extends ConsumerStatefulWidget {
  final String serviceName;
  final String serviceId;
  const ShowServiceitems({super.key, required this.serviceName, required this.serviceId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShowServiceitemsState();
}

class _ShowServiceitemsState extends ConsumerState<ShowServiceitems> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final searchTextProvider = StateProvider<String>((ref) => '');
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(serviceItemsProvider(widget.serviceId));
    final cart = ref.watch(serviceNotifierProvider);
    ref.listen<ServiceDialogNotifier>(serviceDialogProvider, (previous, next) {
      if (next.isEntryDialog == true) {
        Future.delayed(const Duration(milliseconds: 50), () async {
          if (context.mounted) {
            await showServicePreviewDialog(context, ref.read(serviceDialogProvider.notifier).item!, ref);
            ref.read(serviceDialogProvider.notifier).closeEntryDialog();
          }
        });
      }
    });
    return Scaffold(
      appBar: AppBar(
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
          widget.serviceName,
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
      //               childAspectRatio: 0.60, // Adjust the height of each card
      //             ),
      //             itemCount: items.length,
      //             itemBuilder: (context, index) {
      //               final item = items[index];
      //               final cartItem = cart.firstWhere(
      //                 (cartItem) => cartItem.serviceId == item['_id'],
      //                 orElse: () => ServiceItem(
      //                   serviceId: item['_id'],
      //                   serviceName: item['serviceName'],
      //                   price: item['price'].toDouble(),
      //                   quantity: 0,
      //                   noOfPersons: item['noOfPersons'] as int,
      //                   workingHours: item['workingHours'] as int,
      //                   description: item['description'] as String,
      //                   imageUrl: item['imagePath'] as String,
      //                   selectDate: null,
      //                   selectTime: null,
      //                 ),
      //               );
      //               return ServiceItemTile(cartItem: cartItem, item: item);
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
      //       child: ServiceFooter(),
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
                          final response = await ref.read(searchServiceProvider(SearchItemsParams(resultType: "items", query: query)).future);
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
                              final serviceId = suggestion['_id'] as String;
                              final serviceItme = ref.read(serviceNotifierProvider).firstWhere(
                                    (oritem) => oritem.serviceId == serviceId,
                                    orElse: () => ServiceItem(
                                      serviceId: serviceId,
                                      serviceName: suggestion['title'] as String,
                                      price: double.parse(suggestion['price'] as String),
                                      noOfPersons: int.parse(suggestion['noOfPersons'] as String),
                                      workingHours: int.parse(suggestion['workingHours'] as String),
                                      imageUrl: suggestion['imagePath'] as String,
                                      description: suggestion['description'] as String,
                                      quantity: 1,
                                      comment: '',
                                    ),
                                  );
                              _searchController.clear();
                              _focusNode.unfocus();
                              ref.read(showSearchNotifier.notifier).state = false;
                              ref.read(serviceDialogProvider.notifier).setServiceItem(serviceItme);
                              await showServicePreviewDialog(context, ref.read(serviceDialogProvider.notifier).item!, ref);
                              ref.read(serviceDialogProvider.notifier).closeEntryDialog();
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
                      childAspectRatio: 0.7, // Adjust the height of each card
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final cartItem = cart.firstWhere(
                        (cartItem) => cartItem.serviceId == item['_id'],
                        orElse: () => ServiceItem(
                          serviceId: item['_id'],
                          serviceName: item['serviceName'],
                          price: item['price'].toDouble(),
                          quantity: 0,
                          noOfPersons: item['noOfPersons'] as int,
                          workingHours: item['workingHours'] as int,
                          description: item['description'] as String,
                          imageUrl: item['imagePath'] as String,
                          selectDate: null,
                          selectTime: null,
                        ),
                      );
                      return ServiceItemTile(cartItem: cartItem, item: item);
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
            child: ServiceFooter(),
          ),
        ],
      ),
    );
  }
}
