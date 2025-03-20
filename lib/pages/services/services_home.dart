import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oassis_mart/components/search_filter.dart';
import 'package:oassis_mart/components/notifier_search.dart';
import 'package:oassis_mart/pages/buy/allcategory.dart';
import 'package:oassis_mart/pages/services/cart/service_cart.dart';
import 'package:oassis_mart/pages/services/dialog_servicepreview.dart';
import 'package:oassis_mart/pages/services/notifier_service.dart';
import 'package:oassis_mart/pages/services/show_available_services.dart';
import 'package:oassis_mart/util/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

final showSearchNotifier = StateProvider.autoDispose<bool>((ref) => false);

class ServicesHome extends ConsumerStatefulWidget {
  const ServicesHome({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ServicesHome();
}

class _ServicesHome extends ConsumerState<ServicesHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final searchTextProvider = StateProvider<String>((ref) => '');

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(serviceNotifierProvider); // Watch cart state
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                    //Text("Suman"),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.shopping_basket, 'Buy', () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/buyhome',
                      (Route<dynamic> route) => false,
                    );
                  }
                });
              }),
              _buildDrawerItem(Icons.person, 'Profile', () {}),
              _buildDrawerItem(Icons.shopping_bag, 'Orders', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/myorders', arguments: {'initialTab': 1});
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
          "$nameTitle Services",
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
                          builder: (context) => const ServiceCartPage(),
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
                          final response = await ref.read(searchServiceProvider(SearchItemsParams(resultType: "both", query: query)).future);
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
                                    builder: (context) => ShowServiceitems(
                                      serviceName: suggestion['title'] as String,
                                      serviceId: suggestion['_id'] as String,
                                    ),
                                  ),
                                );
                                _searchController.clear();
                                _focusNode.unfocus();
                                ref.read(showSearchNotifier.notifier).state = false;
                              }
                            });
                          } else {
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
                          }
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(content: Text('You selected: ${suggestion['title']}')),
                          // );
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
                categoryType: CategoryType.service,
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
