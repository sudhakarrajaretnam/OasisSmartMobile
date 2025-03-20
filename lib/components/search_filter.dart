import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchFilter<T> extends ConsumerWidget {
  final Future<List<T>> Function(String) suggestionsCallback;
  final Widget Function(BuildContext, T) itemBuilder;
  //final String resultType;
  final void Function(T) onSuggestionSelected;
  final TextEditingController? controller;
  final String hintText;
  final FocusNode? focusNode;

  const SearchFilter({
    super.key,
    required this.itemBuilder,
    required this.suggestionsCallback,
    required this.onSuggestionSelected,
    this.controller,
    this.focusNode,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TypeAheadField<T>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        autofocus: false,
        focusNode: focusNode,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              controller?.clear();
            },
          ),
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      suggestionsCallback: suggestionsCallback,
      itemBuilder: itemBuilder,
      onSuggestionSelected: onSuggestionSelected,
      noItemsFoundBuilder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              'No items found!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try searching for something else.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      loadingBuilder: (context) {
        // Show a loading spinner while fetching data
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
