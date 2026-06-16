import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/di/injection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../presentation/widgets/company_logo_widget.dart';
import '../../data/models/employee_task_model.dart';
import 'task_chat_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late final ApiClient _apiClient;
  EmployeeTaskModel? _task;
  bool _isLoading = true;
  String? _errorMessage;

  Position? _userPosition;
  double? _taskLatitude;
  double? _taskLongitude;

  String _distance = '';
  String _walkingEstTime = '';
  String _drivingEstTime = '';

  Timer? _countdownTimer;
  String _timeRemaining = 'No deadline';
  bool _isTimeOver = false;
  bool _isExtraTime = false;

  final Completer<GoogleMapController> _mapCompleter = Completer();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _showMap = false;
  late Key _mapKey;

  bool _isNavigating = false;

  static const CameraPosition _defaultCamera = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _apiClient = getIt<ApiClient>();
    _mapKey = ValueKey('task_map_${DateTime.now().millisecondsSinceEpoch}');
    Future.delayed(Duration(milliseconds: Platform.isIOS ? 1200 : 300), () {
      if (mounted) setState(() => _showMap = true);
    });
    _loadTaskDetails();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _mapController = null; // don't call .dispose() — the GoogleMap widget handles its own cleanup
    super.dispose();
  }

  Future<void> _loadTaskDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      try {
        final perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.always ||
            perm == LocationPermission.whileInUse) {
          _userPosition = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
            ),
          );
        }
      } catch (_) {}

      final response = await _apiClient.get(
        'enterprise/tasks/${widget.taskId}',
      );
      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data;
        final data = (raw['data'] is Map<String, dynamic>)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        _task = EmployeeTaskModel.fromJson(data);
        _extractCoordinates();
        if (mounted) _startTimer();
        if (mounted) _updateMapMarker();
        if (mounted) _fetchDistanceMatrix();
      } else {
        _errorMessage = 'Failed to load task details';
      }
    } catch (e) {
      _errorMessage = 'Failed to load task details';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _extractCoordinates() {
    final coords = _task?.taskDestination?.point.coordinates;
    if (coords != null && coords.length >= 2) {
      _longitude = coords[0];
      _latitude = coords[1];
    }
  }

  set _longitude(double v) => _taskLongitude = v;
  set _latitude(double v) => _taskLatitude = v;

  void _updateMapMarker() {
    if (_taskLatitude == null || _taskLongitude == null) return;
    final ll = LatLng(_taskLatitude!, _taskLongitude!);
    if (mounted) {
      setState(() {
        _markers = {Marker(markerId: const MarkerId('task'), position: ll)};
      });
    }
    if (_mapController != null) {
      try {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(ll, 14));
      } catch (_) {}
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    if (_task?.dueAt == null) {
      _timeRemaining = 'No deadline';
      return;
    }
    final due = DateTime.tryParse(_task!.dueAt!);
    if (due == null) {
      _timeRemaining = 'No deadline';
      return;
    }
    _updateCountdown(due);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _updateCountdown(due));
      } else {
        timer.cancel();
      }
    });
  }

  void _updateCountdown(DateTime due) {
    final diff = due.difference(DateTime.now());
    if (diff.isNegative) {
      final extra = due.add(const Duration(hours: 3));
      final extraDiff = extra.difference(DateTime.now());
      if (extraDiff.isNegative) {
        _isTimeOver = true;
        _isExtraTime = false;
        _timeRemaining = 'Time over';
        _countdownTimer?.cancel();
      } else {
        _isExtraTime = true;
        _isTimeOver = false;
        _timeRemaining = _formatDiff(extraDiff);
      }
      return;
    }
    _isTimeOver = false;
    _isExtraTime = false;
    _timeRemaining = _formatDiff(diff);
  }

  String _formatDiff(Duration diff) {
    if (diff.inDays > 0) {
      return '${diff.inDays}d:${diff.inHours % 24}h:${diff.inMinutes % 60}m';
    }
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(diff.inHours)}:${two(diff.inMinutes % 60)}:${two(diff.inSeconds % 60)}';
  }

  void _fetchDistanceMatrix() {
    if (_userPosition == null ||
        _taskLatitude == null ||
        _taskLongitude == null)
      return;
    final apiKey = Platform.isIOS ? _appleMapKey : _googleMapKey;
    final origin = '${_userPosition!.latitude},${_userPosition!.longitude}';
    final dest = '$_taskLatitude,$_taskLongitude';

    http
        .get(
          Uri.parse(
            'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$origin&destinations=$dest&mode=driving&key=$apiKey',
          ),
        )
        .then((resp) {
          if (resp.statusCode <= 201) {
            final d = jsonDecode(resp.body);
            if (d['status'] == 'OK' && (d['rows'] as List).isNotEmpty) {
              final el = (d['rows'][0]['elements'] as List);
              if (el.isNotEmpty && el[0]['status'] == 'OK') {
                _drivingEstTime = el[0]['duration']?['text'] ?? '';
                _distance = el[0]['distance']?['text'] ?? '';
                if (mounted) setState(() {});
              }
            }
          }
        })
        .catchError((_) {});

    http
        .get(
          Uri.parse(
            'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$origin&destinations=$dest&mode=walking&key=$apiKey',
          ),
        )
        .then((resp) {
          if (resp.statusCode <= 201) {
            final d = jsonDecode(resp.body);
            if (d['status'] == 'OK' && (d['rows'] as List).isNotEmpty) {
              final el = (d['rows'][0]['elements'] as List);
              if (el.isNotEmpty && el[0]['status'] == 'OK') {
                _walkingEstTime = el[0]['duration']?['text'] ?? '';
                if (_distance.isEmpty)
                  _distance = el[0]['distance']?['text'] ?? '';
                if (mounted) setState(() {});
              }
            }
          }
        })
        .catchError((_) {});
  }

  String get _appleMapKey => '';
  String get _googleMapKey => '';

  Future<void> _openMap({bool directions = false}) async {
    if (_taskLatitude == null || _taskLongitude == null) return;
    String googleUrl, appleUrl;
    if (directions && _userPosition != null) {
      googleUrl =
          'https://www.google.com/maps/dir/?api=1&origin=${_userPosition!.latitude},${_userPosition!.longitude}&destination=$_taskLatitude,$_taskLongitude&travelmode=driving&dir_action=navigate';
      appleUrl =
          'http://maps.apple.com/maps?saddr=${_userPosition!.latitude},${_userPosition!.longitude}&daddr=$_taskLatitude,$_taskLongitude';
    } else {
      googleUrl =
          'https://www.google.com/maps/search/?api=1&query=$_taskLatitude,$_taskLongitude';
      appleUrl = 'http://maps.apple.com/?q=$_taskLatitude,$_taskLongitude';
    }
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(
        Uri.parse(googleUrl),
        mode: LaunchMode.externalApplication,
      );
    } else if (await canLaunchUrl(Uri.parse(appleUrl))) {
      await launchUrl(
        Uri.parse(appleUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> _completeTask() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
    try {
      final resp = await _apiClient.patch(
        'enterprise/tasks/${widget.taskId}',
        data: {'status': 'completed'},
      );
      if (!mounted) return;
      Navigator.pop(context);
      if (resp.statusCode == 200) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to complete task. Please try again.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String _getUserAssignmentStatus() {
    if (_task == null) return '';
    return _task!.status.toLowerCase();
  }

  void _showSuccessDialog() {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        content: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size.width * 0.045),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(left: size.width * 0.04),
                child: Row(
                  children: [
                    Text(
                      'Task Completed Successfully',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: size.width * 0.04,
                        fontFamily: 'AirbnbCereal',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                        size: size.width * 0.06,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                child: const Divider(color: Colors.black, thickness: 0.5),
              ),
              SizedBox(height: size.width * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                child: Text(
                  'Your task has been marked as complete and logged successfully. Thank you.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * 0.035,
                    fontFamily: 'AirbnbCereal',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: size.width * 0.04),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.width * 0.04,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: size.width * 0.12,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.04,
                        fontFamily: 'AirbnbCereal',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _deadlineLabel() {
    if (_task?.dueAt == null) return 'No deadline set';
    final dt = DateTime.tryParse(_task!.dueAt!);
    if (dt == null) return 'No deadline set';
    final l = dt.toLocal();
    final h = l.hour > 12 ? l.hour - 12 : (l.hour == 0 ? 12 : l.hour);
    final m = l.minute.toString().padLeft(2, '0');
    final ampm = l.hour >= 12 ? 'pm' : 'am';
    return 'Deadline ${h.toString().padLeft(2, '0')}:$m $ampm';
  }

  String _buildPreferenceString() {
    final prefs = _task?.metadata['preferences'];
    if (prefs == null || prefs is! Map) return '';
    List<String> parts = [];
    String prefValue(dynamic v) => v is List ? v.join(', ') : '';
    if ((prefs['pictureStyle'] as List?)?.isNotEmpty == true) {
      parts.add('Capture in ${prefValue(prefs['pictureStyle'])} format');
    }
    if ((prefs['videoLength'] as List?)?.isNotEmpty == true) {
      parts.add('record a ${prefValue(prefs['videoLength'])} video');
    }
    if ((prefs['distance'] as List?)?.isNotEmpty == true) {
      parts.add(
        'keep a distance of approximately ${prefValue(prefs['distance'])}',
      );
    }
    if (parts.isEmpty) return '';
    if (parts[0].isNotEmpty)
      parts[0] = parts[0][0].toUpperCase() + parts[0].substring(1);
    if (parts.length == 1) return '${parts.first}.';
    if (parts.length == 2) return '${parts.first} and ${parts.last}.';
    return '${parts.sublist(0, parts.length - 1).join(', ')}, and ${parts.last}.';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(size),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: _buildAppBar(size),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: $_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: 'AirbnbCereal',
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: _loadTaskDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final task = _task!;
    final isCompleted = _getUserAssignmentStatus() == 'completed';
    final companyName =
        (task.creatorSummary != null &&
            task.creatorSummary!.fullName.isNotEmpty)
        ? task.creatorSummary!.fullName
        : task.industry.toUpperCase();
    final profileImage = task.creatorSummary?.profileImage ?? '';
    final address =
        (task.taskDestination != null && task.taskDestination!.label.isNotEmpty)
        ? task.taskDestination!.label
        : (task.taskDestination?.address.line1 ?? 'Location unknown');
    final prefStr = _buildPreferenceString();

    return Scaffold(
      appBar: _buildAppBar(size),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(size.width * 0.028),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header: creator + status ──────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.01,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (profileImage.isNotEmpty) ...[
                              Container(
                                width: size.width * 0.08,
                                height: size.width * 0.08,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    profileImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, e, s) => const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: size.width * 0.02),
                            ],
                            Text(
                              companyName,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * 0.036,
                                fontFamily: 'AirbnbCereal',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          (_isTimeOver && task.status.toLowerCase() == 'open')
                              ? 'EXPIRED'
                              : task.status.toUpperCase(),
                          style: TextStyle(
                            color:
                                task.status.toLowerCase() == 'rejected' ||
                                    (_isTimeOver &&
                                        task.status.toLowerCase() == 'open')
                                ? Colors.black
                                : AppColors.primary,
                            fontSize: size.width * 0.036,
                            fontFamily: 'AirbnbCereal',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.width * 0.02),

                  // ── Map + Timer row ───────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: size.width * 0.35,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(
                                size.width * 0.042,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                size.width * 0.04,
                              ),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  if (_showMap)
                                    GoogleMap(
                                      key: _mapKey,
                                      scrollGesturesEnabled: false,
                                      mapType: MapType.normal,
                                      initialCameraPosition:
                                          _taskLatitude != null
                                          ? CameraPosition(
                                              target: LatLng(
                                                _taskLatitude!,
                                                _taskLongitude!,
                                              ),
                                              zoom: 14,
                                            )
                                          : _defaultCamera,
                                      markers: _markers,
                                      onMapCreated: (ctrl) {
                                        _mapController = ctrl;
                                        if (!_mapCompleter.isCompleted)
                                          _mapCompleter.complete(ctrl);
                                      },
                                      compassEnabled: false,
                                      mapToolbarEnabled: false,
                                      zoomControlsEnabled: false,
                                      zoomGesturesEnabled: false,
                                    )
                                  else
                                    Container(
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  InkWell(
                                    onTap: () => _openMap(),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.06,
                                        vertical: size.width * 0.018,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(
                                            size.width * 0.01,
                                          ),
                                          bottomRight: Radius.circular(
                                            size.width * 0.02,
                                          ),
                                        ),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Click the Map & GO',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * 0.04,
                                            fontFamily: 'AirbnbCereal',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              height: size.width * 0.35,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAEAEA),
                                borderRadius: BorderRadius.circular(
                                  size.width * 0.04,
                                ),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: size.width * 0.03),
                                  Text(
                                    _isExtraTime
                                        ? 'Extra time added'
                                        : _isTimeOver
                                        ? 'Time over'
                                        : task.dueAt != null
                                        ? 'Time remaining'
                                        : 'No deadline',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: size.width * 0.035,
                                      fontFamily: 'AirbnbCereal',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: FittedBox(
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                            size.width * 0.04,
                                          ),
                                          child: Text(
                                            _timeRemaining,
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: size.width * 0.075,
                                              fontFamily: 'AirbnbCereal',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.07,
                                vertical: size.width * 0.018,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(
                                    size.width * 0.04,
                                  ),
                                  bottomRight: Radius.circular(
                                    size.width * 0.04,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _deadlineLabel(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width * 0.04,
                                      fontFamily: 'AirbnbCereal',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.width * 0.04),

                  // ── Time / date / location / distance ─────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: size.width * 0.045,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: size.width * 0.018),
                                Text(
                                  _formatDate(task.createdAt, 'hh:mm a'),
                                  style: TextStyle(
                                    fontSize: size.width * 0.03,
                                    color: Colors.grey,
                                    fontFamily: 'AirbnbCereal',
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02),
                                Icon(
                                  Icons.calendar_today,
                                  size: size.width * 0.04,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: size.width * 0.018),
                                Text(
                                  _formatDate(task.createdAt, 'dd MMM yyyy'),
                                  style: TextStyle(
                                    fontSize: size.width * 0.03,
                                    color: Colors.grey,
                                    fontFamily: 'AirbnbCereal',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.width * 0.025),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: size.width * 0.045,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: size.width * 0.02),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(text: address),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Address copied to clipboard',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      address,
                                      style: TextStyle(
                                        fontSize: size.width * 0.028,
                                        color: Colors.grey,
                                        fontFamily: 'AirbnbCereal',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.width * 0.025),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: size.width * 0.045,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: size.width * 0.02),
                                Text(
                                  _distance.isNotEmpty ? _distance : '---',
                                  style: TextStyle(
                                    fontSize: size.width * 0.028,
                                    color: Colors.grey,
                                    fontFamily: 'AirbnbCereal',
                                  ),
                                ),
                                SizedBox(width: size.width * 0.018),
                                Container(
                                  width: 1,
                                  height: size.width * 0.04,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: size.width * 0.02),
                                Icon(
                                  Icons.directions_walk_rounded,
                                  size: size.width * 0.045,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: size.width * 0.01),
                                Text(
                                  _walkingEstTime.isNotEmpty
                                      ? _walkingEstTime
                                      : '---',
                                  style: TextStyle(
                                    fontSize: size.width * 0.028,
                                    color: Colors.grey,
                                    fontFamily: 'AirbnbCereal',
                                  ),
                                ),
                                SizedBox(width: size.width * 0.01),
                                Container(
                                  width: 1,
                                  height: size.width * 0.04,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: size.width * 0.02),
                                Icon(
                                  Icons.directions_car,
                                  size: size.width * 0.045,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: size.width * 0.01),
                                Text(
                                  _drivingEstTime.isNotEmpty
                                      ? _drivingEstTime
                                      : '---',
                                  style: TextStyle(
                                    fontSize: size.width * 0.028,
                                    color: Colors.grey,
                                    fontFamily: 'AirbnbCereal',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.width * 0.02),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                  SizedBox(height: size.width * 0.018),

                  // ── Task title ────────────────────────────────────────
                  Text(
                    'TASK',
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      color: Colors.black,
                      fontFamily: 'AirbnbCereal',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: size.width * 0.018),
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      color: Colors.black,
                      fontFamily: 'AirbnbCereal',
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: size.width * 0.06),

                  // ── Description ───────────────────────────────────────
                  Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      color: Colors.black,
                      fontFamily: 'AirbnbCereal',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: size.width * 0.018),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: size.width * 0.03,
                      color: Colors.black,
                      fontFamily: 'AirbnbCereal',
                      height: 2,
                    ),
                  ),

                  if (prefStr.isNotEmpty) ...[
                    SizedBox(height: size.width * 0.03),
                    Text(
                      prefStr,
                      style: TextStyle(
                        fontSize: size.width * 0.03,
                        color: Colors.black,
                        fontFamily: 'AirbnbCereal',
                        height: 1.8,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: size.width * 0.025),
                  ],

                  const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                  SizedBox(height: size.width * 0.035),

                  // ── Buttons ───────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: size.width * 0.14,
                          child: ElevatedButton(
                            onPressed: isCompleted ? null : _completeTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCompleted
                                  ? Colors.grey.shade400
                                  : Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  size.width * 0.03,
                                ),
                              ),
                            ),
                            child: Text(
                              isCompleted
                                  ? 'Completed'
                                  : 'Tap to Complete Task',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.038,
                                fontFamily: 'AirbnbCereal',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: SizedBox(
                          height: size.width * 0.14,
                          child: ElevatedButton(
                            onPressed: _isNavigating
                                ? null
                                : () {
                                    if (_isNavigating) return;
                                    setState(() => _isNavigating = true);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TaskChatScreen(
                                          taskDetail: _task,
                                          roomId: widget.taskId,
                                        ),
                                      ),
                                    ).then((_) {
                                      _isNavigating = false;
                                      if (mounted) {
                                        setState(() {});
                                        _loadTaskDetails();
                                      }
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  size.width * 0.03,
                                ),
                              ),
                            ),
                            child: Text(
                              'Manage Task',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.038,
                                fontFamily: 'AirbnbCereal',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),

                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: size.width * 0.03,
                        color: Colors.black,
                        fontFamily: 'AirbnbCereal',
                        fontWeight: FontWeight.w400,
                      ),
                      children: const [
                        TextSpan(
                          text:
                              'Tap Manage Tasks to upload photos, videos, scans, and audio recordings directly from the field. Chat with your office, track updates, and stay on top of every assignment in real time.',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.08),
                ],
              ),
            ),
          ),
          if (_isNavigating)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(Size size) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Image.asset('assets/icons/ic_arrow_left.png', color: Colors.black, width: 24, height: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Task Details',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: size.width * 0.045,
          fontFamily: 'AirbnbCereal',
        ),
      ),
      titleSpacing: 0,
      centerTitle: false,
      actions: const [CompanyLogoAction()],
    );
  }

  String _formatDate(String rawDate, String format) {
    final dt = DateTime.tryParse(rawDate);
    if (dt == null) return '';
    final l = dt.toLocal();
    if (format == 'hh:mm a') {
      final h = l.hour > 12 ? l.hour - 12 : (l.hour == 0 ? 12 : l.hour);
      final m = l.minute.toString().padLeft(2, '0');
      final ampm = l.hour >= 12 ? 'PM' : 'AM';
      return '${h.toString().padLeft(2, '0')}:$m $ampm';
    }
    if (format == 'dd MMM yyyy') {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${l.day.toString().padLeft(2, '0')} ${months[l.month - 1]} ${l.year}';
    }
    return rawDate;
  }
}
