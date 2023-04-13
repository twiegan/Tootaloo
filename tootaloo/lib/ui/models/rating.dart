class Rating {
  final String building;
  final String room;
  final double overall_rating;
  final double cleanliness;
  final double internet;
  final double vibe;
  final String review;
  final String by;

  Rating(
      {required this.building,
      required this.room,
      required this.overall_rating,
      required this.cleanliness,
      required this.internet,
      required this.vibe,
      required this.review,
      required this.by});
}
