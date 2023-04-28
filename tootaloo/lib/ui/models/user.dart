class User {
  final dynamic id;
  final String username;
  final List<dynamic> posts_ids;
  final List<dynamic> following_ids;
  final String preference;
  final List<dynamic> favorite_restrooms_ids;
  num reports;
  num followers;

  User(
      {required this.id,
      required this.username,
      required this.posts_ids,
      required this.following_ids,
      required this.preference,
      required this.favorite_restrooms_ids,
      this.reports = 0,
      this.followers = 0});
}
