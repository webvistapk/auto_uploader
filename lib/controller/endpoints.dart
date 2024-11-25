class ApiURLs {
  static const String baseUrl = "http://147.79.117.253:8001/api/";
  static const String baseUrl2 = "http://147.79.117.253:8001";
  static const String login_endpoint = "userprofile/users/login/";
  static const String follow_request_endpoint = "userprofile/users/follow/";
  static const String register_endpoint = "userprofile/users/register/";
  static const String follow_check_endpoint = "userprofile/users/follow/";
  static const String user_endpoint = "userprofile/users/";
  static const String check_email_verified =
      "userprofile/users/check_email_verified/";
  static const String renew_email_verified =
      "userprofile/users/renew_email_verified/";
  static const String update_email_verified =
      "userprofile/users/update_email_verified/";
  static const String get_follow_list = "userprofile/users/follow/get/";
  static const String accept_follow = "userprofile/users/follow/status/";
  static const String update_password = "userprofile/users/update_password/";
  static const String update_user_profile = "userprofile/users/update/";
  static const String create_new_post = "posts/new/";
  static const String fetch_peoples_endpoint =
      "userprofile/users/follow/getall/";
  static const String get_post = "posts/get/";
  static const String delete_post = "posts/delete/";
  static const String delete_reel = "posts/reel/delete/";
  static const String get_single_post = "posts/get/single/";
  static const String user_profile_image_endpoint =
      "userprofile/users/profile_image/save/";
  static const String create_new_reel_endpoint = "posts/reel/new/save/";
  static const String create_new_story_endpoint = "posts/story/new/save/";
  static const String get_reel_post = "posts/reel/get/";
  static const String get_user_status='posts/story/get/';
  static const String get_followers_status='posts/story/get/following/';
  static const String get_follower_posts="posts/get/following/";
  //static const String delete_reel="posts/reel/delete/";
  static const String get_follower_reel_post = "posts/reel/get/following/";
  static const String new_like="posts/like/new/";
  static const String post_comment_fetch="posts/comment/get/post/";
  static const String post_comment_add="posts/comment/new/post/";
  static const String delete_post_comment="posts/comment/delete/";

  static const String reel_comment_fetch="posts/comment/get/reel/";
  static const String reel_comment_add="posts/comment/new/reel/";
  //static const String delete_post_comment="posts/comment/delete/";
}
