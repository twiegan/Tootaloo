class Restroom {
  final String id;
  final String building;
  final String room;
  final int floor;
  final double rating;
  final double cleanliness;
  final double internet;
  final double vibe;
  List<dynamic> ratings_ids;

  Restroom(
      {required this.id,
      required this.building,
      required this.room,
      required this.floor,
      required this.rating,
      required this.cleanliness,
      required this.internet,
      required this.vibe,
      required this.ratings_ids});
}
