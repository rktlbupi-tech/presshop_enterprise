import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../presentation/widgets/employee_app_bar.dart';

class EvidenceScreen extends StatefulWidget {
  final bool hideLeading;
  const EvidenceScreen({super.key, this.hideLeading = true});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  // Using same dummy logic, but UI exactly like EmployeeAllContentPage
  final List<_DummyFeed> feedList = [
    _DummyFeed(
      title: 'City centre incident',
      description:
          'Filmed the ongoing protest at the city centre with multiple angles.',
      capturedAt: '2023-10-15T10:30:00Z',
      location: '123 City Centre, London',
      imageUrl: 'https://picsum.photos/400/300?random=1',
      mediaCount: 3,
    ),
    _DummyFeed(
      title: 'Road closure footage',
      description: '',
      capturedAt: '2023-10-14T14:45:00Z',
      location: 'M4 Highway, near Exit 12',
      imageUrl: 'https://picsum.photos/400/300?random=2',
      mediaCount: 1,
    ),
    _DummyFeed(
      title: 'Market interview',
      description: 'Interviewed local vendors about the new regulations.',
      capturedAt: '2023-10-13T09:15:00Z',
      location: 'Borough Market, London',
      imageUrl: 'https://picsum.photos/400/300?random=3',
      mediaCount: 5,
    ),
    _DummyFeed(
      title: 'Weather damage clip',
      description: 'Severe flooding near the residential area.',
      capturedAt: '2023-10-12T16:20:00Z',
      location: 'Riverside Walk, London',
      imageUrl: '', // test placeholder
      mediaCount: 2,
    ),
  ];

  String _selectedSort = "Newest First";

  final List<_FeedFilterModel> _priorityFilters = [
    _FeedFilterModel(name: "High Priority", icon: "ic_exclusive.png"),
    _FeedFilterModel(name: "Medium Priority", icon: "ic_live_content.png"),
    _FeedFilterModel(name: "Low Priority", icon: "ic_share.png"),
  ];

  final List<_FeedFilterModel> _statusFilters = [
    _FeedFilterModel(name: "Assigned", icon: "ic_pending.png"),
    _FeedFilterModel(name: "Ongoing", icon: "ic_clock.png"),
    _FeedFilterModel(name: "Completed", icon: "ic_sold.png"),
  ];

  final _FeedFilterModel _dateFilter = _FeedFilterModel(
    name: "Custom Date Range",
    icon: "ic_yearly_calendar.png",
  );

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sort & Filter",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setBottomSheetState(() {
                              _selectedSort = "Newest First";
                              for (var item in _priorityFilters) {
                                item.isSelected = false;
                              }
                              for (var item in _statusFilters) {
                                item.isSelected = false;
                              }
                              _dateFilter.isSelected = false;
                              _dateFilter.fromDate = null;
                              _dateFilter.toDate = null;
                            });
                          },
                          child: Text(
                            "Clear All",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFE2E8F0)),
                    SizedBox(height: 12.h),
                    Text(
                      "Sort By",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _buildSortChip(
                          context,
                          setBottomSheetState,
                          "Newest First",
                        ),
                        SizedBox(width: 12.w),
                        _buildSortChip(
                          context,
                          setBottomSheetState,
                          "Oldest First",
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Custom Date Range",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setBottomSheetState(() {
                                  _dateFilter.fromDate = picked
                                      .toIso8601String();
                                  _dateFilter.isSelected = true;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10.h,
                                horizontal: 12.w,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _dateFilter.fromDate != null
                                        ? DateFormat('dd MMM yyyy').format(
                                            DateTime.parse(
                                              _dateFilter.fromDate!,
                                            ),
                                          )
                                        : "From Date",
                                    style: TextStyle(
                                      color: _dateFilter.fromDate != null
                                          ? Colors.black87
                                          : Colors.grey[500],
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_month,
                                    size: 16.sp,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              if (_dateFilter.fromDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select a From Date first',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.parse(
                                  _dateFilter.fromDate!,
                                ),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setBottomSheetState(() {
                                  _dateFilter.toDate = picked.toIso8601String();
                                  _dateFilter.isSelected = true;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10.h,
                                horizontal: 12.w,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _dateFilter.toDate != null
                                        ? DateFormat('dd MMM yyyy').format(
                                            DateTime.parse(_dateFilter.toDate!),
                                          )
                                        : "To Date",
                                    style: TextStyle(
                                      color: _dateFilter.toDate != null
                                          ? Colors.black87
                                          : Colors.grey[500],
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_month,
                                    size: 16.sp,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              side: BorderSide(color: Colors.grey[400]!),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Apply Filters",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(
    BuildContext context,
    StateSetter setBottomSheetState,
    String label,
  ) {
    final bool isSelected = _selectedSort == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12.sp,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 1,
        ),
      ),
      showCheckmark: false,
      onSelected: (bool selected) {
        if (selected) {
          setBottomSheetState(() {
            _selectedSort = label;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.hideLeading
          ? EmployeeAppBar(onFilterTap: _showFilterBottomSheet)
          : AppBar(
              title: const Text('Content & evidence'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),
            Expanded(
              child: feedList.isNotEmpty
                  ? RefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          mainAxisSpacing: 16.w,
                          crossAxisSpacing: 16.w,
                        ),
                        itemCount: feedList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => _EvidenceDetailsScreen(
                                    item: feedList[index],
                                  ),
                                ),
                              );
                            },
                            child: _feedCard(feedList[index]),
                          );
                        },
                      ),
                    )
                  : const Center(child: Text("No Content Found")),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feedCard(_DummyFeed item) {
    return Container(
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 2,
            blurRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _feedThumbnail(item),
          SizedBox(height: 8.h),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (item.description.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
          const Spacer(),
          if (item.capturedAt.isNotEmpty)
            Row(
              children: [
                Image.asset(
                  "assets/icons/ic_clock.png",
                  height: 11.w,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 4.w),
                Text(
                  _formatTime(item.capturedAt),
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(width: 8.w),
                Image.asset(
                  "assets/icons/ic_yearly_calendar.png",
                  height: 11.w,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 4.w),
                Text(
                  _formatDate(item.capturedAt),
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          SizedBox(height: 4.h),
          if (item.location.isNotEmpty)
            Row(
              children: [
                Image.asset(
                  "assets/icons/ic_location.png",
                  height: 12.w,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    item.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _feedThumbnail(_DummyFeed item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Stack(
        children: [
          item.imageUrl.isNotEmpty
              ? Image.network(
                  item.imageUrl,
                  height: 110.w,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(),
                )
              : _imagePlaceholder(),
          if (item.imageUrl.isNotEmpty)
            Image.asset(
              "assets/images/watermark1.png",
              height: 110.w,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Positioned(
            right: 8.w,
            top: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text(
                  "${item.mediaCount}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 110.w,
      width: double.infinity,
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.image_outlined, size: 40.w, color: Colors.grey),
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final parsed = DateTime.parse(iso);
      return DateFormat('hh:mm a').format(parsed.toLocal());
    } catch (_) {
      return '';
    }
  }

  String _formatDate(String iso) {
    try {
      final parsed = DateTime.parse(iso);
      return DateFormat('dd MMM yyyy').format(parsed.toLocal());
    } catch (_) {
      return '';
    }
  }
}

// ---------------------------------------------------------
// DUMMY MODELS
// ---------------------------------------------------------

class _DummyFeed {
  final String title;
  final String description;
  final String capturedAt;
  final String location;
  final String imageUrl;
  final int mediaCount;

  _DummyFeed({
    required this.title,
    required this.description,
    required this.capturedAt,
    required this.location,
    required this.imageUrl,
    required this.mediaCount,
  });
}

class _FeedFilterModel {
  String name;
  String icon;
  bool isSelected;
  String? fromDate;
  String? toDate;

  _FeedFilterModel({
    required this.name,
    required this.icon,
    this.isSelected = false,
    this.fromDate,
    this.toDate,
  });
}

// ---------------------------------------------------------
// DUMMY DETAILS SCREEN
// ---------------------------------------------------------

class _EvidenceDetailsScreen extends StatelessWidget {
  final _DummyFeed item;

  const _EvidenceDetailsScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Content Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageSlideshow(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (item.capturedAt.isNotEmpty)
                      Row(
                        children: [
                          SizedBox(
                            width: 20.w,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                "assets/icons/ic_clock.png",
                                height: 16.w,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _fmt('hh:mm a', item.capturedAt),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          SizedBox(
                            width: 20.w,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                "assets/icons/ic_yearly_calendar.png",
                                height: 16.w,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _fmt('dd MMM yyyy', item.capturedAt),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 8.h),
                    if (item.location.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20.w,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                "assets/icons/ic_location.png",
                                height: 18.w,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              item.location,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 12.h),
                    const Divider(color: Color(0xFFE0E0E0)),
                    SizedBox(height: 8.h),
                    if (item.description.isNotEmpty)
                      Text(
                        item.description,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black,
                          height: 1.5,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    SizedBox(height: 16.h),
                    const Divider(color: Color(0xFFE0E0E0)),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Manage Task",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Tap Manage Tasks to upload photos, videos, scans, audio recordings, and evidence directly from the field. Chat with your office, track live updates, and stay connected to every assignment in real time.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSlideshow() {
    return Column(
      children: [
        SizedBox(
          height: 200.w,
          child: PageView.builder(
            itemCount: 1,
            itemBuilder: (_, i) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Stack(
                    children: [
                      item.imageUrl.isNotEmpty
                          ? Image.network(
                              item.imageUrl,
                              width: double.infinity,
                              height: 200.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: Colors.grey[300]),
                            )
                          : Container(color: Colors.grey[300]),
                      if (item.imageUrl.isNotEmpty)
                        Image.asset(
                          "assets/images/watermark1.png",
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      Positioned(
                        right: 8.w,
                        top: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "${item.mediaCount}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _fmt(String format, String iso) {
    try {
      final parsed = DateTime.parse(iso);
      return DateFormat(format).format(parsed.toLocal());
    } catch (_) {
      return '';
    }
  }
}
