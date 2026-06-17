import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../presentation/widgets/app_app_bar.dart';

import '../../../../core/constants/app_colors.dart';


class TrackMileageScreen extends StatefulWidget {
  const TrackMileageScreen({super.key});

  @override
  State<TrackMileageScreen> createState() => _TrackMileageScreenState();
}

class _TrackMileageScreenState extends State<TrackMileageScreen> {
  // Date controls
  DateTime _currentDate = DateTime(2026, 5, 8);
  String _timeRangeFilter = 'Daily'; // Daily, Weekly, Monthly, Yearly, Custom

  // Mileage Tab State
  int _selectedTripIndex = 0;
  GoogleMapController? _mapController;

  // Mock Trips List
  final List<Map<String, dynamic>> _trips = [
    {
      'startTime': '08:12 AM',
      'startLoc': 'North Circular Rd, London, UK',
      'endTime': '08:47 AM',
      'endLoc': 'Holloway Rd, London, UK',
      'distance': '24.6 miles',
      'duration': '35m',
      'coords': [
        const LatLng(51.5612, -0.1654),
        const LatLng(51.5590, -0.1420),
        const LatLng(51.5562, -0.1189),
      ],
    },
    {
      'startTime': '09:05 AM',
      'startLoc': 'Holloway Rd, London, UK',
      'endTime': '09:42 AM',
      'endLoc': 'Kings Cross Rd, London, UK',
      'distance': '18.3 miles',
      'duration': '37m',
      'coords': [
        const LatLng(51.5562, -0.1189),
        const LatLng(51.5420, -0.1190),
        const LatLng(51.5306, -0.1162),
      ],
    },
    {
      'startTime': '09:58 AM',
      'startLoc': 'Kings Cross Rd, London, UK',
      'endTime': '10:28 AM',
      'endLoc': 'Camden High St, London, UK',
      'distance': '16.7 miles',
      'duration': '35m',
      'coords': [
        const LatLng(51.5306, -0.1162),
        const LatLng(51.5350, -0.1380),
        const LatLng(51.5390, -0.1425),
      ],
    },
    {
      'startTime': '10:40 AM',
      'startLoc': 'Camden High St, London, UK',
      'endTime': '10:59 AM',
      'endLoc': 'Victoria Street, London, UK',
      'distance': '26.0 miles',
      'duration': '19m',
      'coords': [
        const LatLng(51.5390, -0.1425),
        const LatLng(51.5120, -0.1410),
        const LatLng(51.4965, -0.1430),
      ],
    },
  ];

  void _changeDay(bool next) {
    setState(() {
      _currentDate = next
          ? _currentDate.add(const Duration(days: 1))
          : _currentDate.subtract(const Duration(days: 1));
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2026),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _currentDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppAppBar(
        title: "Track Mileage",
        elevation: 0.5,
        centerTitle: false,
        titleSpacing: 0,
        showBack: true,
      ),
      body: SafeArea(
        child: _buildMileageContent(size),
      ),
    );
  }

  Widget _buildMileageContent(Size size) {
    final trip = _trips[_selectedTripIndex];
    final coords = List<LatLng>.from(trip['coords']);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Horizontal Filter Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Daily', 'Weekly', 'Monthly', 'Yearly', 'Custom']
                .map((filter) {
              final isSelected = _timeRangeFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 4),
                child: ChoiceChip(
                  label: Text(
                    filter,
                    style: TextStyle(
                      fontFamily: 'AirbnbCereal',
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFF6B7280),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFFEFF6FF),
                  backgroundColor: Colors.white,
                  checkmarkColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                        color: isSelected
                            ? const Color(0xFFDBEAFE)
                            : Colors.grey.shade200),
                  ),
                  onSelected: (val) {
                    setState(() => _timeRangeFilter = filter);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Date selector row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeDay(false),
              ),
              GestureDetector(
                onTap: _pickDate,
                child: Row(
                  children: [
                    const Icon(LucideIcons.calendar,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM yyyy, EEEE').format(_currentDate),
                      style: const TextStyle(
                        fontFamily: 'AirbnbCereal',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeDay(true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Stats metrics row
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatItem("Total Distance", "85.6 miles",
                  "▲ 12.4 miles vs yesterday", LucideIcons.milestone, Colors.blue),
              const SizedBox(width: 16),
              _buildStatItem("Total Trips", "4", "▲ 1 vs yesterday",
                  LucideIcons.gauge, Colors.green),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatItem("Total Duration", "02h 48m", "▲ 20m vs yesterday",
                  LucideIcons.timer, Colors.purple),
              const SizedBox(width: 16),
              _buildStatItem("Est. Fuel Cost", "£8.45", "▲ £1.12 vs yesterday",
                  LucideIcons.fuel, Colors.orange),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Google Map displaying Selected Trip path
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade200),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: coords.first, zoom: 11.5),
                onMapCreated: (ctrl) => _mapController = ctrl,
                markers: {
                  Marker(
                    markerId: const MarkerId('start'),
                    position: coords.first,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                  ),
                  Marker(
                    markerId: const MarkerId('end'),
                    position: coords.last,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: coords,
                    color: AppColors.primary,
                    width: 4,
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
              // Card Overlay Start/End locations
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const CircleAvatar(
                          radius: 3, backgroundColor: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        "Start: ${trip['startTime']}",
                        style: const TextStyle(
                          fontFamily: 'AirbnbCereal',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const CircleAvatar(
                          radius: 3, backgroundColor: Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        "End: ${trip['endTime']}",
                        style: const TextStyle(
                          fontFamily: 'AirbnbCereal',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Trips list header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Trips",
              style: TextStyle(
                fontFamily: 'AirbnbCereal',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              "${_trips.length} Trips",
              style: const TextStyle(
                fontFamily: 'AirbnbCereal',
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Trip list items
        ...List.generate(_trips.length, (index) {
          final item = _trips[index];
          final isSelected = _selectedTripIndex == index;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.grey.shade100),
            ),
            child: InkWell(
              onTap: () {
                setState(() => _selectedTripIndex = index);
                if (_mapController != null) {
                  _mapController!.animateCamera(CameraUpdate.newLatLng(
                      List<LatLng>.from(item['coords']).first));
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(
                          fontFamily: 'AirbnbCereal',
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6B7280),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                  radius: 3, backgroundColor: Colors.green),
                              const SizedBox(width: 6),
                              Text(
                                item['startTime'],
                                style: const TextStyle(
                                  fontFamily: 'AirbnbCereal',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const CircleAvatar(
                                  radius: 3, backgroundColor: Colors.red),
                              const SizedBox(width: 6),
                              Text(
                                item['endTime'],
                                style: const TextStyle(
                                  fontFamily: 'AirbnbCereal',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${item['startLoc'].toString().split(',')[0]} to ${item['endLoc'].toString().split(',')[0]}",
                            style: const TextStyle(
                              fontFamily: 'AirbnbCereal',
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['distance'],
                          style: const TextStyle(
                            fontFamily: 'AirbnbCereal',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['duration'],
                          style: const TextStyle(
                            fontFamily: 'AirbnbCereal',
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),

        // Disclaimer Note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.shield_check,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Mileage is calculated using GPS data. Ensure location is turned on during trips for accurate tracking.",
                  style: TextStyle(
                    fontFamily: 'AirbnbCereal',
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, String subText, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'AirbnbCereal',
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'AirbnbCereal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subText,
              style: const TextStyle(
                fontFamily: 'AirbnbCereal',
                fontSize: 11,
                color: Color(0xFF10B981),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
