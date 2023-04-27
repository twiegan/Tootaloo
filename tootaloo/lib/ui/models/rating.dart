class Rating {
  final id;
  final String building;
  final String by;
  final String room;
  final String review;
  final num overallRating;
  final num internet;
  final num cleanliness;
  final num vibe;
  final num privacy;
  final int upvotes;
  final int downvotes;
  final int reports;
  bool owned;

  Rating(
      {required this.id,
      required this.building,
      required this.by,
      required this.room,
      required this.review,
      required this.overallRating,
      required this.internet,
      required this.cleanliness,
      required this.vibe,
      required this.privacy,
      required this.upvotes,
      required this.downvotes,
      required this.reports,
      this.owned = false});
}
