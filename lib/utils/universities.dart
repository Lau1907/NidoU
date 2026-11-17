import 'package:latlong2/latlong.dart';

class University {
  final String name;
  final LatLng location;
  final String city;

  const University({
    required this.name,
    required this.location,
    required this.city,
  });
}

const Map<String, LatLng> universities = {
  'UTNG - Universidad Tecnológica del Norte de Guanajuato': LatLng(21.1669, -100.9317),
  'UG - Universidad de Guanajuato (Campus Dolores Hidalgo)': LatLng(21.1583, -100.9344),
  'ENUF - Escuela Normal Oficial de Dolores Hidalgo': LatLng(21.1538, -100.9369),
  'UPP / Universidad Patria (Plantel Dolores Hidalgo)': LatLng(21.1552, -100.9325),
  'UCEM - Universidad del Centro de México (Dolores Hidalgo)': LatLng(21.1567, -100.9312),
  'CBTis No. 75 - Dolores Hidalgo': LatLng(21.1615, -100.9365),
  'CECyTE Guanajuato - Plantel Dolores Hidalgo': LatLng(21.1489, -100.9412),
};

const String defaultUniversity = 'UTNG - Universidad Tecnológica del Norte de Guanajuato';

/// Calculates walking minutes between two coordinates.
///
/// Uses straight-line distance with a 1.25 urban street factor
/// and an average walking speed of 80 meters/minute.
int calculateWalkingMinutes(LatLng origin, LatLng universityCoords) {
  final distanceMeters = const Distance().as(LengthUnit.Meter, origin, universityCoords);
  final walkingMinutes = (distanceMeters * 1.25 / 80.0).round();
  return walkingMinutes.clamp(1, 180);
}
