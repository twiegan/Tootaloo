class User {
  final String username;
  final List<dynamic> posts_ids;
  final List<dynamic> following_ids;

  User(
      {required this.username,
      required this.posts_ids,
      required this.following_ids});
}
