import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oassis_mart/components/notifier_search.dart';
import 'package:oassis_mart/components/search_filter.dart';
import 'package:oassis_mart/helper/itemdetails_dialog.dart';
import 'package:oassis_mart/pages/buy/allcategory.dart';
import 'package:oassis_mart/pages/buy/cart_page.dart';
import 'package:oassis_mart/pages/buy/items_page.dart';
import 'package:oassis_mart/pages/buy/notifier_buy.dart';
import 'package:oassis_mart/pages/buy/notifier_cart.dart';
import 'package:oassis_mart/util/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyHome extends ConsumerStatefulWidget {
  const BuyHome({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BuyHome();
}

class _BuyHome extends ConsumerState<BuyHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final searchTextProvider = StateProvider<String>((ref) => '');

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider); // Watch cart state
    final totalItems = cart.fold<int>(0, (sum, item) => sum + item.quantity);
    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      endDrawerEnableOpenDragGesture: true,
      drawer: Drawer(
        child: Container(
          color: primaryColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: primaryColor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hi, $userName", // Default title fallback
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.home_repair_service, 'Service', () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/services',
                      (Route<dynamic> route) => false,
                    );
                  }
                });
              }),
              _buildDrawerItem(Icons.person, 'Profile', () {}),
              _buildDrawerItem(Icons.shopping_bag, 'Orders', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/myorders', arguments: {'initialTab': 0});
              }),
              _buildDrawerItem(Icons.contact_mail, 'Contact Us', () {}),
              _buildDrawerItem(Icons.logout, 'Logout', () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (context.mounted) _showLogoutConfirmationDialog(context);
                });
              }),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          "$nameTitle Mart",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Stack(children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                child: Ink(
                  decoration: BoxDecoration(
                    color: lightBg,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            totalItems == 0
                ? const SizedBox.shrink()
                : Positioned(
                    top: -5,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        totalItems.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
          ]),
          Container(
            margin: const EdgeInsets.only(left: 8.0, right: 16),
            decoration: const BoxDecoration(
              color: lightBg,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                final searchFlag = ref.read(buyNotifierProvider).showSearch;
                ref.read(buyNotifierProvider).setShowSearch(!searchFlag);
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer(
            builder: (context, ref, child) {
              final buyNotifier = ref.watch(buyNotifierProvider);
              return buyNotifier.showSearch
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                      child: SearchFilter<Map<String, String>>(
                        hintText: "Search product",
                        controller: _searchController,
                        focusNode: _focusNode,
                        suggestionsCallback: (query) async {
                          if (query.isEmpty) {
                            return [];
                          }
                          final response = await ref.read(searchProvider(SearchItemsParams(resultType: "both", query: query)).future);
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
                          if (suggestion['type'] == 'group') {
                            Future.delayed(const Duration(milliseconds: 200), () {
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemsPage(
                                      categoryName: suggestion['title'] as String,
                                      categiryId: suggestion['_id'] as String,
                                    ),
                                  ),
                                );
                              }
                              _searchController.clear();
                              _focusNode.unfocus();
                              ref.read(buyNotifierProvider).setShowSearch(false);
                            });
                          } else {
                            _searchController.clear();
                            _focusNode.unfocus();
                            ref.read(buyNotifierProvider).setShowSearch(false);

                            //ref.read(showSearchNotifier.notifier).state = false;
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
                        },
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
            child: Consumer(builder: (context, ref, child) {
              return const Text(
                "All Categories",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.left,
              );
            }),
          ),
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, child) {
              final searchText = ref.watch(searchTextProvider); // Watch the search text
              return AllCategory(
                searchText: searchText,
                categoryType: CategoryType.grocery,
              ); // Pass it to AllCategory
            },
          ),
          //const AllCategory()
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logoutUser(context);
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void _logoutUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/otp', (route) => false);
    }
  }
}
