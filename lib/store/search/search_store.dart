import 'package:flutter/material.dart';

class SearchStore {
  static final ValueNotifier<String?> searchQuery =
      ValueNotifier<String?>(null);

  // Method to update the search query
  static void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}
