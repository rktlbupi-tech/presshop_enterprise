import 'package:flutter/material.dart';
import 'package:location/location.dart';

class CameraLocationService {
  final Location _location = Location();

  Future<LocationData?> getCurrentLocation(
    BuildContext context, {
    bool shouldShowSettingPopup = true,
  }) async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return null;
      }

      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) return null;
      }

      return await _location.getLocation();
    } catch (e) {
      return null;
    }
  }
}
