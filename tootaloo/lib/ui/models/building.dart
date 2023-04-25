import 'package:location/location.dart';

class Building {
  final String id;
  final String name;
  final int restroomCount;
  final double latitude;
  final double longitude;
  final List<dynamic> floors;
  final int maleCount;
  final int femaleCount;
  final int unisexCount;

  Building({
    required this.id,
    required this.name,
    required this.restroomCount,
    required this.latitude,
    required this.longitude,
    required this.floors,
    required this.maleCount,
    required this.femaleCount,
    required this.unisexCount,
  });

  double manhattanDistance(LocationData locationData) {
    return (locationData.latitude! - latitude).abs() +
        (locationData.longitude! - longitude).abs();
  }
}
