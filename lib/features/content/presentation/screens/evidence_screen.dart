import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../presentation/widgets/company_logo_widget.dart';
import '../../../../presentation/widgets/employee_app_bar.dart';
import '../../../../config/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../data/models/enterprise_feed_model.dart';
import '../../../tasks/data/models/employee_task_model.dart';
import '../../../tasks/presentation/screens/task_chat_screen.dart';

class EvidenceScreen extends StatefulWidget {
  final bool hideLeading;
  const EvidenceScreen({super.key, this.hideLeading = true});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  final ScrollController _scrollController = ScrollController();
  List<EnterpriseFeedItem> _feedList = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  static const int _limit = 20;

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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadFeed(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadFeed();
      }
    }
  }

  Future<void> _loadFeed({bool refresh = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      if (refresh) {
        _page = 1;
        _hasMore = true;
      }
    });

    try {
      final apiClient = getIt<ApiClient>();
      
      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'page': _page,
        'limit': _limit,
        'sortBy': 'createdAt',
        'sortOrder': _selectedSort == "Newest First" ? 'desc' : 'asc',
      };

      // Priority Filter
      final selectedPriorities = _priorityFilters
          .where((f) => f.isSelected)
          .map((f) => f.name.toLowerCase().replaceAll(' priority', ''))
          .toList();
      if (selectedPriorities.isNotEmpty) {
        queryParams['priority'] = selectedPriorities.join(',');
      }

      // Status Filter
      final selectedStatuses = _statusFilters
          .where((f) => f.isSelected)
          .map((f) => f.name.toLowerCase())
          .toList();
      if (selectedStatuses.isNotEmpty) {
        queryParams['status'] = selectedStatuses.join(',');
      }

      // Date Range Filter
      if (_dateFilter.fromDate != null) {
        queryParams['startDate'] = _dateFilter.fromDate;
      }
      if (_dateFilter.toDate != null) {
        queryParams['endDate'] = _dateFilter.toDate;
      }

      final response = await apiClient.get(
        ApiEndpoints.feed,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final feedResponse = EnterpriseFeedResponse.fromJson(response.data);
        setState(() {
          if (refresh) {
            _feedList = feedResponse.data;
          } else {
            _feedList.addAll(feedResponse.data);
          }
          _page++;
          if (feedResponse.data.length < _limit) {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading feed: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                              _loadFeed(refresh: true);
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
              actions: const [CompanyLogoAction()],
            ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),
            Expanded(
              child: _feedList.isEmpty && _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _feedList.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: () => _loadFeed(refresh: true),
                          child: GridView.builder(
                            controller: _scrollController,
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
                            itemCount: _feedList.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => _EvidenceDetailsScreen(
                                        item: _feedList[index],
                                      ),
                                    ),
                                  );
                                },
                                child: _feedCard(_feedList[index]),
                              );
                            },
                          ),
                        )
                      : const Center(child: Text("No Content Found")),
            ),
            if (_isLoading && _feedList.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(8.r),
                child: const CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _feedCard(EnterpriseFeedItem item) {
    final firstContent = item.content.isNotEmpty ? item.content.first : null;
    final imageUrl = firstContent?.previewUrl ?? '';
    final location = (firstContent?.captureAddressLine1 != null &&
            firstContent!.captureAddressLine1.isNotEmpty)
        ? firstContent.captureAddressLine1
        : 'Location Not Captured';
    final capturedAt = (firstContent?.capturedAt != null &&
            firstContent!.capturedAt.isNotEmpty)
        ? firstContent.capturedAt
        : (firstContent?.createdAt ?? item.task.createdAt);
    final description = item.task.description.isNotEmpty
        ? item.task.description
        : (firstContent?.description ?? '');

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
          _feedThumbnail(imageUrl, item.content),
          SizedBox(height: 8.h),
          Text(
            item.task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (description.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              description,
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
          if (capturedAt.isNotEmpty)
            Row(
              children: [
                Image.asset(
                  "assets/icons/ic_clock.png",
                  height: 11.w,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 4.w),
                Text(
                  _formatTime(capturedAt),
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
                  _formatDate(capturedAt),
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          SizedBox(height: 4.h),
          if (location.isNotEmpty)
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
                    location,
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

  Widget _feedThumbnail(String imageUrl, List<EnterpriseFeedContent> contentList) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Stack(
        children: [
          imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  height: 110.w,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(
                      contentList.isNotEmpty ? contentList.first.evidenceType : "image"),
                )
              : _imagePlaceholder(
                  contentList.isNotEmpty ? contentList.first.evidenceType : "image"),
          if (imageUrl.isNotEmpty)
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
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text(
                  "${contentList.length}",
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

  Widget _imagePlaceholder(String type) {
    return Container(
      height: 110.w,
      width: double.infinity,
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          type.toLowerCase() == 'video' ? Icons.videocam_outlined : Icons.image_outlined,
          size: 40.w,
          color: Colors.grey,
        ),
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

class _EvidenceDetailsScreen extends StatelessWidget {
  final EnterpriseFeedItem item;

  const _EvidenceDetailsScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final firstContent = item.content.isNotEmpty ? item.content.first : null;
    final location = (firstContent?.captureAddressLine1 != null &&
            firstContent!.captureAddressLine1.isNotEmpty)
        ? firstContent.captureAddressLine1
        : 'Location Not Captured';
    final capturedAt = (firstContent?.capturedAt != null &&
            firstContent!.capturedAt.isNotEmpty)
        ? firstContent.capturedAt
        : (firstContent?.createdAt ?? item.task.createdAt);
    final description = item.task.description.isNotEmpty
        ? item.task.description
        : (firstContent?.description ?? '');

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
        actions: const [CompanyLogoAction()],
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
                      item.task.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (capturedAt.isNotEmpty)
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
                            _fmt('hh:mm a', capturedAt),
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
                            _fmt('dd MMM yyyy', capturedAt),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 8.h),
                    if (location.isNotEmpty)
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
                              location,
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
                    if (description.isNotEmpty)
                      Text(
                        description,
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
                      onPressed: () async {
                        // show loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                        try {
                          final response = await getIt<ApiClient>().get(
                            'enterprise/tasks/${item.task.id}',
                          );
                          if (context.mounted) {
                            Navigator.pop(context); // dismiss loading
                          }
                          if (response.statusCode == 200 && response.data != null) {
                            final raw = response.data;
                            final data = (raw['data'] is Map<String, dynamic>)
                                ? raw['data'] as Map<String, dynamic>
                                : raw as Map<String, dynamic>;
                            final task = EmployeeTaskModel.fromJson(data);
                            
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TaskChatScreen(
                                    taskDetail: task,
                                    roomId: task.id,
                                  ),
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to load task details')),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(context); // dismiss loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
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
    if (item.content.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          height: 200.w,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: const Center(
            child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
          ),
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 200.w,
          child: PageView.builder(
            itemCount: item.content.length,
            itemBuilder: (_, i) {
              final contentItem = item.content[i];
              final imageUrl = contentItem.previewUrl;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Stack(
                    children: [
                      imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: 200.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: Colors.grey[300]),
                            )
                          : Container(color: Colors.grey[300]),
                      if (imageUrl.isNotEmpty)
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
                                contentItem.evidenceType.toLowerCase() == 'video'
                                    ? Icons.videocam
                                    : Icons.image,
                                color: Colors.white,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "${i + 1}/${item.content.length}",
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
