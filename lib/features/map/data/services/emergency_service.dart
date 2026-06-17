import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:presshop_enterprise/features/map/core/map_constants.dart';

/// Represents a single nearby emergency station (police / hospital / fire).
class EmergencyStation {
  final String name;
  final String address;
  final String phoneNumber;
  final double distance;
  final double lat;
  final double lng;

  /// Human-readable distance, computed against the user's current location.
  String? distanceStr;

  EmergencyStation({
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.distance,
    required this.lat,
    required this.lng,
  });

  factory EmergencyStation.fromJson(Map<String, dynamic> json) {
    return EmergencyStation(
      name: json['name'] ?? 'Unknown',
      address: json['vicinity'] ?? 'Address not available',
      phoneNumber: json['formatted_phone_number'] ?? '',
      lat: (json['geometry']?['location']?['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['geometry']?['location']?['lng'] as num?)?.toDouble() ?? 0.0,
      distance: 0.0, // Calculated later via Geolocator.distanceBetween
    );
  }
}

/// Fetches nearby emergency stations using the Google Places API
/// (nearbysearch + place details). Mirrors the legacy app behaviour.
class EmergencyService {
  final String _apiKey = googleMapAPiKey;

  /// Searches for [type] (police / hospital / fire_station) within a 5km radius
  /// of [lat]/[lng], then enriches the top results with phone numbers via the
  /// place-details endpoint, and finally sorts the list by distance.
  Future<List<EmergencyStation>> fetchNearbyStations({
    required double lat,
    required double lng,
    required String type,
  }) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng&radius=5000&type=$type&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('Places API Request ($type): $url');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'REQUEST_DENIED') {
          debugPrint('Places API Error: ${data['error_message']}');
          return [];
        }

        final List results = data['results'] ?? [];

        // Fetch place details (for phone numbers) in parallel for top results.
        final futures = results.take(5).map((result) async {
          final placeId = result['place_id'];
          final detail = await _fetchPlaceDetails(placeId);
          return detail ?? EmergencyStation.fromJson(result);
        });

        final stations = await Future.wait(futures);

        // Compute distance from the user and sort nearest-first.
        for (final s in stations) {
          if (s.lat != 0.0 && s.lng != 0.0) {
            final d = Geolocator.distanceBetween(lat, lng, s.lat, s.lng);
            s.distanceStr = '${(d / 1000).toStringAsFixed(1)} km';
          }
        }
        stations.sort((a, b) {
          final da = (a.lat != 0.0 && a.lng != 0.0)
              ? Geolocator.distanceBetween(lat, lng, a.lat, a.lng)
              : double.infinity;
          final db = (b.lat != 0.0 && b.lng != 0.0)
              ? Geolocator.distanceBetween(lat, lng, b.lat, b.lng)
              : double.infinity;
          return da.compareTo(db);
        });

        return stations;
      }
    } catch (e) {
      debugPrint('Error fetching emergency stations: $e');
    }
    return [];
  }

  Future<EmergencyStation?> _fetchPlaceDetails(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=name,vicinity,formatted_phone_number,geometry'
        '&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          return EmergencyStation.fromJson(data['result']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
    }
    return null;
  }
}
