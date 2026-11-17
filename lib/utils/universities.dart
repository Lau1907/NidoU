import 'package:latlong2/latlong.dart';

const Map<String, LatLng> universities = {
  'UTNG - Universidad Tecnológica del Norte de Guanajuato': LatLng(21.1669, -100.9317),
  'UDHI - Universidad Dolores Hidalgo': LatLng(21.1578, -100.9332),
  'Universidad Patria (Dolores Hidalgo)': LatLng(21.1545, -100.9318),
  'Universidad de León (Plantel Dolores Hidalgo)': LatLng(21.1562, -100.9355),
  'UPN - Universidad Pedagógica Nacional (Unidad 111)': LatLng(21.1530, -100.9380),
  'UICEG - Instituto Universitario del Centro de México': LatLng(21.1588, -100.9305),
  'CEDHI - Centro de Estudios Dolores Hidalgo': LatLng(21.1550, -100.9348),
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
