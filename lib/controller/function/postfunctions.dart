import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/screens/profile/widgets/emojiBottomSheet.dart';
import 'package:mobile/screens/profile/widgets/messageBottomSheet.dart';
import 'package:provider/provider.dart';

void CreateChat(String PostUserID,PostID, BuildContext context, {bool isEmoji=false}) async {
  final response = await Provider.of<PostProvider>(context, listen: false)
      .createChat(PostUserID, context);
  if (response?.statusCode == 201) {
    final responseData = jsonDecode(response!.body);

    // Extract chat ID
    final chatId = responseData['chat']['id'].toString();
    if(isEmoji){
       showEmojiBottomSheet(context,PostID, chatId);
    }
    else{
    showMessageBottomSheet(context, chatId, PostID);
    }
  } else {
    ToastNotifier.showErrorToast(context, "Unable to chat");
  }
}