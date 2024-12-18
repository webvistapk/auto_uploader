import 'package:flutter/material.dart';
import 'package:mobile/controller/services/post/comment_provider.dart';
import 'package:provider/provider.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

@override
  void initState() {
    // TODO: implement initState
    super.initState();

    Provider.of<CommentProvider>(context,listen: false).fetchComments("21", false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CommentProvider>(

        builder: (context,commentProvider,child) {
          if (commentProvider.isCommentLoading ) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final comments = commentProvider.comments;
        
        if (comments.isEmpty) {
          return const Center(
            child: Text("No comments available."),
          );
        }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: comments.length, // Should be 10
            itemBuilder: (context, index) {
              final comment = comments[index];
              return ListTile(
          title: Text(comment.commentText ?? 'No comment'),
              );
            },
          );
        }
      ),
    );
  }
}