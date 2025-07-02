import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
//import 'package:lottie/lottie.dart';
import 'package:oasis_smart_services/pages/drawer/dialogs/view_cartinfo.dart';
import 'package:oasis_smart_services/pages/drawer/notifier_history.dart';
import 'package:oasis_smart_services/pages/services/order/order_track_detail.dart';
import 'package:oasis_smart_services/util/global_variables.dart';
import 'package:oasis_smart_services/util/no_record.dart';

final controlProvider = StateProvider.autoDispose<bool>((ref) => false);

class HistoryTabs extends ConsumerStatefulWidget {
  const HistoryTabs({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryTabs();
}

class _HistoryTabs extends ConsumerState<HistoryTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _orderScrollController = ScrollController();
  final ScrollController _requestScrollController = ScrollController();
  int initialTab = 0;
  bool isTabInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isTabInitialized) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      initialTab = arguments?['initialTab'] ?? 0;

      // Update the TabController only if the initialTab is different
      _tabController.index = initialTab;
      isTabInitialized = true; // Prevent further updates
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    // _tabController.addListener(() {
    //   if (!_tabController.indexIsChanging) return;
    //   if (_tabController.index == 0) {
    //     final orderNotifier = ref.read(orderHistoryProvider.notifier);
    //     //if (orderNotifier.isEmpty) {
    //     orderNotifier.fetchOrders(isRefresh: true);
    //     // }
    //   } else if (_tabController.index == 1) {
    //     final requestNotifier = ref.read(requestHistoryProvider.notifier);
    //     if (requestNotifier.isEmpty) {
    //       requestNotifier.fetchRequests(isRefresh: true);
    //     }
    //   }
    // });

    Future.microtask(() {
      if (initialTab == 0) {
        final orderNotifier = ref.read(orderHistoryProvider.notifier);
        orderNotifier.fetchOrders(isRefresh: true);
      } else {
        final requestNotifier = ref.read(requestHistoryProvider.notifier);
        requestNotifier.fetchRequests(isRefresh: true);
      }
      //ref.read(orderHistoryProvider.notifier).fetchOrders();
    });

    _orderScrollController.addListener(() {
      final orderNotifier = ref.read(orderHistoryProvider.notifier);
      if (_orderScrollController.position.pixels == _orderScrollController.position.maxScrollExtent && orderNotifier.hasMore) {
        orderNotifier.fetchOrders();
      }
    });

    _requestScrollController.addListener(() {
      final requestNotifier = ref.read(requestHistoryProvider.notifier);
      if (_requestScrollController.position.pixels == _requestScrollController.position.maxScrollExtent && requestNotifier.hasMore) {
        requestNotifier.fetchRequests();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orderScrollController.dispose();
    _requestScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        //backgroundColor: Colors.white30,
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Orders & Request'),
          bottom: TabBar(
            controller: _tabController,
            onTap: (index) {
              if (index == 0) {
                ref.read(orderHistoryProvider.notifier).fetchOrders(isRefresh: true);
              } else if (index == 1) {
                ref.read(requestHistoryProvider.notifier).fetchRequests(isRefresh: true);
              }
            },
            tabs: const [
              Tab(
                icon: Icon(Icons.shopping_cart),
                text: "Order History",
              ),
              Tab(
                icon: Icon(Icons.home_repair_service),
                text: "Request History",
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOrderTab(),
            _buildRequestTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTab() {
    return Consumer(
      builder: (context, ref, child) {
        final orders = ref.watch(orderHistoryProvider);
        final orderNotifier = ref.read(orderHistoryProvider.notifier);

        if (orders.isEmpty && orderNotifier.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!orderNotifier.isLoading && orders.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => orderNotifier.fetchOrders(isRefresh: true),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false, // Prevents scrolling
                  child: noRecordWidget(context, message: 'No order found'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => orderNotifier.fetchOrders(isRefresh: true),
              child: Column(
                children: [
                  //const SizedBox(height: 30),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_downward, size: 24, color: Colors.black),
                      SizedBox(height: 3),
                      Text(
                        "Pull down to refresh",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _orderScrollController,
                      //padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length + (orderNotifier.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == orders.length) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final order = orders[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 3),
                          decoration: BoxDecoration(
                            color: Colors.white, //Colors.grey[200],
                            border: Border.all(color: primaryColor, width: 1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            //crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 13,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Image.asset(
                                    'assets/images/shopping-bag.png',
                                    fit: BoxFit.contain, // Ensure the image fills the ClipRRect area
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 62,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        DateFormat('MMM d, y hh:mm a').format(DateTime.parse(order.createdAt)),
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 2),
                                          Text('Total Items: ${order.toalItems}',
                                              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                                          const SizedBox(height: 2),
                                          Text('Total: $currency ${order.totalPrice}',
                                              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Status: ${order.status}',
                                            style: TextStyle(
                                              color: order.status == 'completed'
                                                  ? primaryColor
                                                  : order.status == 'pending'
                                                      ? Colors.red
                                                      : order.status == 'approved'
                                                          ? Colors.green
                                                          : order.status == 'rejected'
                                                              ? Colors.red
                                                              : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 25,
                                child: SizedBox(
                                  height: 105,
                                  //color: Colors.green,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'OrderId\n${order.orderId}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _showFullScreenBottomSheet(context, order.recId, order.createdAt);
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                          //elevation: 5,
                                        ),
                                        child: const Text('Details'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequestTab() {
    return Consumer(
      builder: (context, ref, child) {
        final orders = ref.watch(requestHistoryProvider);
        final orderNotifier = ref.read(requestHistoryProvider.notifier);

        if (orders.isEmpty && orderNotifier.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!orderNotifier.isLoading && orders.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => orderNotifier.fetchRequests(isRefresh: true),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false, // Prevents scrolling
                  child: noRecordWidget(context, message: 'No order found'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => orderNotifier.fetchRequests(isRefresh: true),
              child: Column(
                children: [
                  //const SizedBox(height: 30),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_downward, size: 24, color: Colors.black),
                      SizedBox(height: 3),
                      Text(
                        "Pull down to refresh",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _orderScrollController,
                      //padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length + (orderNotifier.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == orders.length) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final order = orders[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 3),
                          decoration: BoxDecoration(
                            color: Colors.white, //Colors.grey[200],
                            border: Border.all(color: primaryColor, width: 1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            //crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 13,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: CachedNetworkImage(
                                    imageUrl: order.serviceDetails.imagePath,
                                    placeholder: (context, url) => const Center(
                                      child: SizedBox(
                                        width: 32, // Width of the circular indicator
                                        height: 32, // Height of the circular indicator
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
                              Expanded(
                                flex: 62,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        DateFormat('MMM d, y hh:mm a').format(order.createdAt),
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 2),
                                          Text(
                                            'Total Items: ${order.quantity}',
                                            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Date on: ${DateFormat('y-MM-dd').format(order.selectDate)}',
                                            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Time on: ${DateFormat('hh:mm a').format(DateTime.parse("1900-01-01 ${order.selectTime}"))}',
                                            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 2),
                                          Text('Total: $currency ${(order.quantity * order.price).toStringAsFixed(0)}',
                                              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Status: ${order.status.capitalize()}',
                                            style: TextStyle(
                                              color: order.status == 'pending'
                                                  ? Colors.red
                                                  : order.status == 'completed'
                                                      ? primaryColor
                                                      : order.status == 'assigned'
                                                          ? Colors.green
                                                          : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 25,
                                child: SizedBox(
                                  height: 105,
                                  //color: Colors.green,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'OrderId',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        order.orderId.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 20),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await _showFullScreenRequest(context, order.createdAt, ref, order.requestId);
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                          //elevation: 5,
                                        ),
                                        child: const Text('Details'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenBottomSheet(BuildContext context, String requestId, String createdAt) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
            appBar: AppBar(
              title: Text(DateFormat('EEE MMM d, y hh:mm a').format(DateTime.parse(createdAt))),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: ViewCartInfo(requestId: requestId));
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
    );
  }

  Future<void> _showFullScreenRequest(
    BuildContext context,
    DateTime createdAt,
    WidgetRef ref,
    String serviceId,
  ) {
    bool hasCompleted = false;
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
            appBar: AppBar(
              title: Text(DateFormat('EEE MMM d, y hh:mm a').format(createdAt)),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Consumer(
              builder: (context, ref, _) {
                final isShow = ref.watch(controlProvider);
                return !isShow ? Container() : TrackScreenDialog(serviceId: serviceId);
              },
            )
            //!isShow ? Container() : TrackScreenDialog(serviceId: serviceId),
            );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        animation.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            if (!hasCompleted) {
              hasCompleted = true;
              Future.delayed(const Duration(milliseconds: 50), () {
                ref.read(controlProvider.notifier).state = true;
              });
            }
          }
        });
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1), // Start from bottom
          end: Offset.zero, // End at top (full screen)
        ).animate(animation);

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  }
}
