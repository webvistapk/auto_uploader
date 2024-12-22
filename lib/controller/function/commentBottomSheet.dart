import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile/screens/profile/widgets/comment_Widget.dart';

void showComments(String postId,bool isReelScreen,context,String commentID,{String? replyID}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
      
        return CommentWidget(
          commentIdToHighlight: commentID,
          postId: postId,
          isReelScreen: isReelScreen,
          replyIdToHighlight: replyID,
          
        );
      },
    );
  }