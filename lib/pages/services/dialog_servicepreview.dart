import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:oassis_mart/pages/services/notifier_service.dart';
import 'package:oassis_mart/util/global_variables.dart';

final serviceItemQuantity = StateProvider.autoDispose<int>((ref) => 0);
final selectDateProvider = StateProvider.autoDispose<DateTime>((ref) => DateTime.now());
final selectTimeProvider = StateProvider.autoDispose<TimeOfDay>((ref) => TimeOfDay.now());

final showControlProvider = StateProvider.autoDispose<bool>((ref) => false);

Future<void> showServicePreviewDialog(
  BuildContext context,
  ServiceItem cartItem,
  WidgetRef ref,
) {
  bool isShow = false;
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Dialog',
    barrierDismissible: true,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation1, animation2) {
      return FullScreenDialog(
        cartItem: cartItem,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (isShow) {
            return;
          }
          isShow = true;
          Future.delayed(const Duration(milliseconds: 10), () async {
            ref.read(serviceItemQuantity.notifier).state = cartItem.quantity != 0 ? cartItem.quantity : 1;
            if (cartItem.selectDate != null) {
              ref.read(selectDateProvider.notifier).state = cartItem.selectDate!;
            }
            if (cartItem.selectTime != null) {
              ref.read(selectTimeProvider.notifier).state = cartItem.selectTime!;
            }
            ref.read(showControlProvider.notifier).state = true;
          });
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

class FullScreenDialog extends ConsumerStatefulWidget {
  final ServiceItem cartItem;
  const FullScreenDialog({super.key, required this.cartItem});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FullScreenDialog();
}

class _FullScreenDialog extends ConsumerState<FullScreenDialog> {
  final TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _messageController.text = widget.cartItem.comment ?? '';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isShow = ref.watch(showControlProvider);
    final quantity = ref.watch(serviceItemQuantity);
    final isInCart = ref.read(serviceNotifierProvider.notifier).isItemInCart(widget.cartItem.serviceId);
    final setDate = ref.watch(selectDateProvider);
    final setTime = ref.watch(selectTimeProvider);
    //ref.read(itemQuantity.notifier).state = 1;
    return Scaffold(
      //backgroundColor: Colors.transparent,

      appBar: AppBar(
        //backgroundColor: Colors.red,
        title: const Text('Enter Details'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: !isShow
          ? Container()
          : Align(
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
                                  imageUrl: widget.cartItem.imageUrl,
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
                                    widget.cartItem.serviceName,
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
                                        "${widget.cartItem.noOfPersons} Person${widget.cartItem.noOfPersons == 1 ? '' : 's'}",
                                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "$currency ${widget.cartItem.price}",
                                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              isInCart
                                  ? Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(30), right: Radius.circular(30)),
                                        onTap: () {
                                          ref.read(serviceNotifierProvider.notifier).removeItem(widget.cartItem.serviceId);
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.red, width: 1),
                                            borderRadius: BorderRadius.circular(30), // Fully rounded corners
                                          ),
                                          child: const Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                CupertinoIcons.trash,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                'Delete cart',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  //fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
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
                                      onTap: () {
                                        if (quantity > 1) {
                                          ref.read(serviceItemQuantity.notifier).state -= 1;
                                        }
                                      },
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
                                        "$quantity",
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
                                      onTap: () {
                                        ref.read(serviceItemQuantity.notifier).state += 1;
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(Icons.add, color: Colors.green),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$currency ${(widget.cartItem.price * quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Select Date',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () async {
                                        final DateTime? pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2101),
                                        );
                                        if (pickedDate != null) {
                                          ref.read(selectDateProvider.notifier).state = pickedDate;
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.shade300, // Border color
                                            width: 1.0, // Border width
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 20),
                                            const SizedBox(width: 10),
                                            Text(
                                              DateFormat('dd MMM yyyy').format(setDate),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Select Time',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () async {
                                        final TimeOfDay? pickedTime = await showTimePicker(
                                          context: context,
                                          initialTime: setTime,
                                          builder: (context, child) {
                                            return MediaQuery(
                                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (pickedTime != null) {
                                          int roundedMinute = (pickedTime.minute / 15).round() * 15;
                                          if (roundedMinute == 60) {
                                            roundedMinute = 0;
                                            final newHour = (pickedTime.hour + 1) % 24; // Wrap around to 0 after 23
                                            ref.read(selectTimeProvider.notifier).state = TimeOfDay(hour: newHour, minute: roundedMinute);
                                          } else {
                                            ref.read(selectTimeProvider.notifier).state = TimeOfDay(hour: pickedTime.hour, minute: roundedMinute);
                                          }
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.shade300, // Border color
                                            width: 1.0, // Border width
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 20),
                                            const SizedBox(width: 10),
                                            Text(
                                              ref.watch(selectTimeProvider).format(context),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                decoration: TextDecoration.none,
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
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Comments',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                maxLines: 3, // Set number of lines for textarea
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type your message here...',
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300, // Default border color
                                      width: 1.5,
                                    ),
                                  ),

                                  // Border when the TextField is focused
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300, // Border color when focused
                                      width: 1.5,
                                    ),
                                  ),

                                  // Border when there's an error
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.red, // Border color when there's an error
                                      width: 1.5,
                                    ),
                                  ),

                                  filled: true,
                                  fillColor: Colors.grey.shade200, // Light background color
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        bottom: 16,
                        left: 30,
                        right: 30,
                        top: 16,
                      ),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(serviceNotifierProvider.notifier).addItem(
                                widget.cartItem,
                                quantity,
                                ref.read(selectDateProvider.notifier).state,
                                ref.read(selectTimeProvider.notifier).state,
                                _messageController.text,
                              );
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          isInCart ? 'UPDATE TO CART' : 'ADD TO CART',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
