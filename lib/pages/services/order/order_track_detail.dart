import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
//import 'package:intl/intl.dart';
import 'package:oassis_mart/pages/services/notifier_service.dart';
import 'package:oassis_mart/util/global_variables.dart';

// final serviceItemQuantity = StateProvider.autoDispose<int>((ref) => 0);
// final selectDateProvider = StateProvider.autoDispose<DateTime>((ref) => DateTime.now());
// final selectTimeProvider = StateProvider.autoDispose<TimeOfDay>((ref) => TimeOfDay.now());

//final showControlProvider = StateProvider.autoDispose<bool>((ref) => false);

class TrackScreenDialog extends ConsumerStatefulWidget {
  final String serviceId;
  const TrackScreenDialog({super.key, required this.serviceId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TrackScreenDialog();
}

class _TrackScreenDialog extends ConsumerState<TrackScreenDialog> {
  final TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(viewServiceProvider.notifier).fetchCartDetails(widget.serviceId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final isShow = ref.watch(showControlProvider);
    // final quantity = ref.watch(serviceItemQuantity);
    // final isInCart = ref.read(serviceNotifierProvider.notifier).isItemInCart(widget.cartItem.serviceId);
    // final setDate = ref.watch(selectDateProvider);
    // final setTime = ref.watch(selectTimeProvider);
    //ref.read(itemQuantity.notifier).state = 1;
    final cartState = ref.watch(viewServiceProvider);

    return Scaffold(
        //backgroundColor: Colors.transparent,

        // appBar: AppBar(
        //   //backgroundColor: Colors.red,
        //   title: const Text('Enter Details'),
        //   leading: IconButton(
        //     icon: const Icon(Icons.close),
        //     onPressed: () {
        //       Navigator.of(context).pop();
        //     },
        //   ),
        // ),
        body: cartState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (cartItem) {
        final status = cartItem['status'].toString();
        final statusIcon = status == 'pending'
            ? CupertinoIcons.timer
            : status == 'assigned'
                ? CupertinoIcons.checkmark
                : status == 'completed'
                    ? CupertinoIcons.checkmark_seal
                    : status == 'rejected'
                        ? CupertinoIcons.multiply_circle
                        : CupertinoIcons.xmark;
        final btnColor = status == 'pending'
            ? Colors.red
            : status == 'assigned'
                ? Colors.green
                : status == 'completed'
                    ? primaryColor
                    : status == 'assigned'
                        ? Colors.red
                        : Colors.red;
        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200,
                      //margin: const EdgeInsets.only(left: 16, right: 16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(20)),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.grey,
                        //     offset: Offset(0.0, 1.0), //(x,y)
                        //     blurRadius: 6.0,
                        //   ),
                        // ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: SizedBox(
                        height: 150,
                        child: PageView(
                          children: [
                            CachedNetworkImage(
                              imageUrl: cartItem['imageUrl'],
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
                          ],
                        ),
                      ),
                    ),
                    // Positioned(
                    //   //alignment: Alignment.topRight,
                    //   top: 2,
                    //   right: 0,
                    //   child: IconButton(
                    //     icon: const Icon(Icons.close),
                    //     onPressed: () {
                    //       Navigator.of(context).pop();
                    //     },
                    //   ),
                    // ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartItem['serviceName'],
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                  color: Colors.black87,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${cartItem['noOfPersons']} Person${cartItem['noOfPersons'] == 1 ? '' : 's'}",
                                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "$currency ${cartItem['price']}",
                                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          //Container(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: btnColor, width: 1),
                              borderRadius: BorderRadius.circular(30), // Fully rounded corners
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  //CupertinoIcons.timer,
                                  statusIcon,
                                  size: 20,
                                  color: btnColor,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  status.capitalize(),
                                  style: TextStyle(
                                    color: btnColor,
                                    //fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Material(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () {},
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.remove, color: Colors.green),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Center(
                                  child: Text(
                                    //"${ref.watch(itemQuantity)}",
                                    "${cartItem['quantity']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      decoration: TextDecoration.none,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () {},
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.add, color: Colors.green),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$currency ${(cartItem['price'] * cartItem['quantity']).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      (cartItem["staffName"] != null && cartItem["staffName"].isNotEmpty)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Assigned Staff',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                          overflow: TextOverflow.ellipsis,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.shade300, // Border color
                                            width: 1.0, // Border width
                                          ),
                                        ),
                                        child: Text(
                                          cartItem['staffName'],
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            overflow: TextOverflow.ellipsis,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 25),
                                Expanded(
                                  flex: 3,
                                  child: (cartItem["staffName"] != null && cartItem["staffName"].isNotEmpty)
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Phone',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                                overflow: TextOverflow.ellipsis,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.grey.shade300, // Border color
                                                  width: 1.0, // Border width
                                                ),
                                              ),
                                              child: Text(
                                                //cartItem['staffName'],
                                                cartItem['staffMobile'],
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                  overflow: TextOverflow.ellipsis,
                                                  decoration: TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                )
                              ],
                            )
                          : Container(),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Selected Date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                //Text(cartItem['selectDate'])
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300, // Border color
                                      width: 1.0, // Border width
                                    ),
                                  ),
                                  child: Text(
                                    DateFormat('dd MMM yyyy').format(DateTime.parse(cartItem['selectDate'])),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Selected Time',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    // decoration: TextDecoration.none,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300, // Border color
                                      width: 1.0, // Border width
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                                    child: Text(
                                      cartItem['selectTime'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your notes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            maxLines: 3, // Set number of lines for textarea
                            controller: TextEditingController(text: cartItem['notes']),
                            readOnly: true,
                            decoration: InputDecoration(
                              //hintText: 'Type your message here...',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300, // Default border color
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Comments',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            maxLines: 3, // Set number of lines for textarea
                            controller: TextEditingController(text: cartItem['comments']),
                            readOnly: true,
                            decoration: InputDecoration(
                              //hintText: 'Type your message here...',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300, // Default border color
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.only(
                //     bottom: 16,
                //     left: 30,
                //     right: 30,
                //     top: 16,
                //   ),
                //   width: double.infinity,
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.of(context).pop();
                //     },
                //     style: ElevatedButton.styleFrom(
                //       padding: const EdgeInsets.symmetric(vertical: 18),
                //       backgroundColor: primaryColor,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(18),
                //       ),
                //     ),
                //     child: const Text(
                //       'ADD TO CART',
                //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
      error: (err, _) => Center(
        child: Text('Error loading cart: $err'),
      ),
    ));
  }
}
