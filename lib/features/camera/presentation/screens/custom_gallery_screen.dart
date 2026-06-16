import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/camera_data.dart';
import '../../utils/camera_constants.dart';

class CustomGalleryScreen extends StatefulWidget {
  final bool picAgain;
  const CustomGalleryScreen({super.key, this.picAgain = false});

  @override
  State<CustomGalleryScreen> createState() => _CustomGalleryScreenState();
}

class _CustomGalleryScreenState extends State<CustomGalleryScreen> {
  List<AssetEntity> _assets = [];
  final Set<int> _selected = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: true,
    );
    if (albums.isNotEmpty) {
      final assets = await albums.first.getAssetListPaged(page: 0, size: 60);
      if (mounted) setState(() { _assets = assets; _loading = false; });
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirm() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(currentLat)?.toString() ?? '0';
    final lon = prefs.getDouble(currentLon)?.toString() ?? '0';
    final address = prefs.getString(currentAddress) ?? '';
    final country = prefs.getString(currentCountry) ?? '';
    final city = prefs.getString(currentCity) ?? '';
    final state = prefs.getString(currentState) ?? '';
    final now = DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now());

    final List<CameraData> result = [];
    for (final idx in _selected) {
      final asset = _assets[idx];
      final file = await asset.file;
      if (file == null) continue;
      final mimeStr = lookupMimeType(file.path) ?? '';
      String mimeType = 'image';
      if (mimeStr.startsWith('video/')) mimeType = 'video';
      else if (mimeStr.startsWith('audio/')) mimeType = 'audio';
      result.add(CameraData(
        path: file.path,
        mimeType: mimeType,
        videoImagePath: '',
        latitude: lat,
        longitude: lon,
        dateTime: now,
        location: address,
        country: country,
        city: city,
        state: state,
        fromGallary: true,
      ));
    }
    if (mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Gallery',
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * numD045,
            fontWeight: FontWeight.w600,
            fontFamily: 'AirbnbCereal',
          ),
        ),
        actions: [
          if (_selected.isNotEmpty)
            TextButton(
              onPressed: _confirm,
              child: Text(
                'Done (${_selected.length})',
                style: const TextStyle(
                  color: colorEmployeeGreen1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: colorEmployeeGreen1))
          : _assets.isEmpty
              ? Center(
                  child: Text(
                    'No media found',
                    style: TextStyle(color: Colors.white70, fontSize: size.width * numD04),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(2),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: _assets.length,
                  itemBuilder: (context, index) {
                    final asset = _assets[index];
                    final isSelected = _selected.contains(index);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(index);
                          } else {
                            if (_selected.length < 10) { _selected.add(index); }
                          }
                        });
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          FutureBuilder<Uint8List?>(
                            future: asset.thumbnailDataWithSize(
                                const ThumbnailSize(200, 200)),
                            builder: (context, snap) {
                              if (snap.hasData) {
                                return Image.memory(snap.data!,
                                    fit: BoxFit.cover);
                              }
                              return Container(color: Colors.grey[900]);
                            },
                          ),
                          if (asset.type == AssetType.video)
                            const Positioned(
                              right: 4,
                              bottom: 4,
                              child: Icon(Icons.videocam,
                                  color: Colors.white, size: 18),
                            ),
                          if (isSelected)
                            Container(
                              color: colorEmployeeGreen1.withValues(alpha: 0.4),
                              child: const Center(
                                child: Icon(Icons.check_circle,
                                    color: Colors.white, size: 28),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
