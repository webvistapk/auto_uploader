import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:mobile/screens/profile/widgets/comment_Widget.dart';

void showComments(String postId,bool isReelScreen,context,String commentID,{String? replyID, int? scrollOffset, bool isSinglePost=false,int commentCount=0}) {
  
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      builder: (BuildContext context) {
        return CommentWidget(
          commentIdToHighlight: commentID,
          postId: postId,
          isReelScreen: isReelScreen,
          replyIdToHighlight: replyID,
          scrollOffset:scrollOffset,
          isSinglePost:isSinglePost,
          commentCount:commentCount
        );
      },
    );
  }