import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oassis_mart/pages/buy/items_page.dart';
import 'package:oassis_mart/pages/buy/notifier_buy.dart';
import 'package:oassis_mart/pages/services/notifier_service.dart';
import 'package:oassis_mart/pages/services/show_available_services.dart';
import 'package:oassis_mart/util/global_variables.dart';
import 'package:oassis_mart/util/no_record.dart';

class AllCategory extends ConsumerStatefulWidget {
  final String searchText;
  final CategoryType categoryType;
  const AllCategory({super.key, required this.searchText, required this.categoryType});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AllCategory();
}

class _AllCategory extends ConsumerState<AllCategory> {
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
    final categories = widget.categoryType == CategoryType.grocery
        ? ref.watch(groceryCategoryProvider(widget.searchText))
        : ref.watch(serviceCategoryProvider(widget.searchText));
    // if (categories.isEmpty) {
    //   return const Center(
    //     child: Text('No data found'),
    //   );
    // }
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              //ref.watch(groceryCategoryProvider('')).when(
              categories.when(
                data: (returnValue) {
                  if (returnValue.isEmpty) {
                    return noRecordWidget(context);
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 tiles in a row
                      crossAxisSpacing: 16, // Space between tiles horizontally
                      mainAxisSpacing: 16, // Space between tiles vertically
                      childAspectRatio: 0.8, // Adjusted to allow more space for text
                    ),
                    itemCount: returnValue.length,
                    itemBuilder: (context, index) {
                      final category = returnValue[index];
                      return _buildCategoryTile(category['title'], category["_id"], category['imagePath'], widget.categoryType);
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
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(String title, String categoryId, String imageUrl, CategoryType categoryType) {
    return GestureDetector(
      onTap: () {
        if (categoryType == CategoryType.grocery) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemsPage(
                categoryName: title,
                categiryId: categoryId,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowServiceitems(
                serviceName: title,
                serviceId: categoryId,
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        padding: const EdgeInsets.all(8), // Padding inside the tile
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(categoryType == CategoryType.grocery ? 0 : 10.0),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
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
            const SizedBox(height: 8), // Space between image and text
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16, // Text size to fit inside the box
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.2, // Line height
              ),
              maxLines: 2, // Ensure text does not exceed 2 lines
              overflow: TextOverflow.ellipsis, // Add "..." if text is too long
            ),
          ],
        ),
      ),
    );
  }
}
