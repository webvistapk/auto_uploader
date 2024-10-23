import 'package:flutter/cupertino.dart';
import 'package:mobile/controller/services/provider_manager.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';

class TagsProvider extends ChangeNotifier {
  bool isLoading = false;

  getTagUsersList(UserProfile userProfile) async {
    isLoading = true;
    notifyListeners();
    final token = await Prefrences.getAuthToken();
    try {
      final response = await ProviderManager.fetchFollowersAndFollowings(
          token, userProfile.id);

      isLoading = false;
      notifyListeners();
      if (response.isEmpty) {
        return [];
      } else {
        return response;
      }
    } catch (e) {}
  }
}
