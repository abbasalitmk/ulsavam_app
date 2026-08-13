import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static const List<String> keralaDistricts = [
    'Thiruvananthapuram',
    'Kollam',
    'Pathanamthitta',
    'Alappuzha',
    'Kottayam',
    'Idukki',
    'Ernakulam',
    'Thrissur',
    'Palakkad',
    'Malappuram',
    'Kozhikode',
    'Wayanad',
    'Kannur',
    'Kasaragod'
  ];

  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
  }

  Future<String?> detectDistrictName() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return null;

      List<Placemark> placemarks = await Geocoding()
          .placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final subAdmin = placemark.subAdministrativeArea ?? '';
        final admin = placemark.locality ?? '';

        for (final district in keralaDistricts) {
          if (subAdmin.toLowerCase().contains(district.toLowerCase()) ||
              admin.toLowerCase().contains(district.toLowerCase())) {
            return district;
          }
        }
      }
    } catch (_) {}
    return 'Kozhikode'; // Fallback default district for Kerala demo
  }
}
