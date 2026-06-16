import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../../config/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../presentation/widgets/app_app_bar.dart';
import '../../../../presentation/widgets/sliding_tabs.dart';
import 'web_view_form_screen.dart';

class SubmitFormsScreen extends StatefulWidget {
  const SubmitFormsScreen({super.key});

  @override
  State<SubmitFormsScreen> createState() => _SubmitFormsScreenState();
}

class _SubmitFormsScreenState extends State<SubmitFormsScreen> {
  final ApiClient _apiClient = getIt<ApiClient>();
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();

  // Available forms state
  List<dynamic> _allForms = [];
  List<dynamic> _filteredForms = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Submissions state
  List<dynamic> _submissions = [];
  List<dynamic> _filteredSubmissions = [];
  bool _isSubmissionsLoading = false;
  String? _submissionsError;

  // Tabs navigation
  bool _showSubmissionsTab = false;

  String _searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchAvailableForms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchAvailableForms({String? query}) async {
    final q = query ?? _searchQuery;
    if (_allForms.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final response = await _apiClient.get(
        'enterprise/forms/available',
        queryParameters: q.isNotEmpty ? {'q': q} : null,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          setState(() {
            _allForms = data['items'] ?? [];
            _errorMessage = null;
            _isLoading = false;
          });
          _applyFilters();
        } else {
          setState(() {
            _errorMessage = data?['message'] ?? "Failed to fetch forms.";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Server returned status code: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error occurred: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSubmissions({String? query}) async {
    final q = query ?? _searchQuery;
    if (_submissions.isEmpty) {
      setState(() {
        _isSubmissionsLoading = true;
      });
    }
    try {
      final response = await _apiClient.get(
        'enterprise/forms/submissions/mine',
        queryParameters: q.isNotEmpty ? {'q': q} : null,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          setState(() {
            _submissions = data['items'] ?? [];
            _submissionsError = null;
            _isSubmissionsLoading = false;
          });
          _applyFilters();
        } else {
          setState(() {
            _submissionsError =
                data?['message'] ?? "Failed to fetch submissions.";
            _isSubmissionsLoading = false;
          });
        }
      } else {
        setState(() {
          _submissionsError =
              "Server returned status code: ${response.statusCode}";
          _isSubmissionsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _submissionsError = "Error occurred: $e";
        _isSubmissionsLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      final query = _searchQuery.toLowerCase();

      if (_showSubmissionsTab) {
        _filteredSubmissions = _submissions.where((sub) {
          final formId = sub['formId'];
          final formName = _getFormNameById(formId).toLowerCase();
          final code = (sub['submissionCode'] ?? '').toString().toLowerCase();
          final status = (sub['status'] ?? '').toString().toLowerCase();

          if (query.isNotEmpty) {
            final matchesSearch = formName.contains(query) ||
                code.contains(query) ||
                status.contains(query);
            if (!matchesSearch) return false;
          }
          return true;
        }).toList();
      } else {
        _filteredForms = _allForms.where((form) {
          final name = (form['name'] ?? '').toString().toLowerCase();
          final description =
              (form['description'] ?? '').toString().toLowerCase();
          final tags = (form['tags'] as List? ?? [])
              .map((t) => t.toString().toLowerCase())
              .toList();

          if (query.isNotEmpty) {
            final matchesSearch = name.contains(query) ||
                description.contains(query) ||
                tags.any((tag) => tag.contains(query));
            if (!matchesSearch) return false;
          }
          return true;
        }).toList();
      }
    });
  }

  dynamic _getFormById(String formId) {
    for (final form in _allForms) {
      if (form['id'] == formId) {
        return form;
      }
    }
    return null;
  }

  String _getFormNameById(String formId) {
    for (final form in _allForms) {
      if (form['id'] == formId) {
        return form['name'] ?? 'Form';
      }
    }
    return 'Form';
  }

  Color _getCardIconColor(int index) => AppColors.primary;

  Color _getCardBgColor(int index) => AppColors.primary.withValues(alpha: 0.08);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppAppBar(
        title: "Submit Forms",
        elevation: 0.5,
        centerTitle: false,
        titleSpacing: 0,
        showBack: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Persistent Search Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              size.width * 0.03,
              size.width * 0.03,
              size.width * 0.03,
              0,
            ),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _showSubmissionsTab
                    ? "Search submitted forms..."
                    : "Search available forms...",
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
                _applyFilters();

                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  if (_showSubmissionsTab) {
                    _fetchSubmissions(query: val);
                  } else {
                    _fetchAvailableForms(query: val);
                  }
                });
              },
            ),
          ),

          // Top Segmented Tab Selector
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(size.width * 0.03),
            child: SlidingTabs(
              selectedIndex: _showSubmissionsTab ? 1 : 0,
              onTabChanged: (index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              tabs: const ["Available", "Submitted"],
            ),
          ),

          // Sliding View
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _showSubmissionsTab = (index == 1);
                });
                if (index == 1 && _submissions.isEmpty) {
                  _fetchSubmissions();
                } else {
                  _applyFilters();
                }
              },
              children: [
                _buildAvailableFormsList(size),
                _buildSubmissionsList(size),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableFormsList(Size size) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchAvailableForms,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchAvailableForms(),
      child: _filteredForms.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: size.height * 0.5,
                child: const Center(
                  child: Text(
                    "No forms available",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              padding: EdgeInsets.fromLTRB(
                size.width * 0.04,
                size.width * 0.03,
                size.width * 0.04,
                size.width * 0.03,
              ),
              itemCount: _filteredForms.length,
              itemBuilder: (context, index) {
                final form = _filteredForms[index];
                final formId = form['id'];
                final formName = form['name'] ?? '';
                final formCode = (form['form_code'] ?? '').toString();
                final thumbnailUrl = form['thumbnailUrl'] ?? '';

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: 8.0,
                    top: index == 0 ? 8.0 : 0.0,
                  ),
                  child: _buildFormCard(
                    size: size,
                    formId: formId,
                    formName: formName,
                    formCode: formCode,
                    thumbnailUrl: thumbnailUrl,
                    index: index,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSubmissionsList(Size size) {
    if (_isSubmissionsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_submissionsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _submissionsError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchSubmissions,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchSubmissions(),
      child: _filteredSubmissions.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: size.height * 0.5,
                child: const Center(
                  child: Text(
                    "No submissions found",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                size.width * 0.04,
                size.width * 0.03,
                size.width * 0.04,
                size.width * 0.03,
              ),
              itemCount: _filteredSubmissions.length,
              itemBuilder: (context, index) {
                final sub = _filteredSubmissions[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: 8.0,
                    top: index == 0 ? 8.0 : 0.0,
                  ),
                  child: _buildSubmissionCard(size, sub, index),
                );
              },
            ),
    );
  }

  Widget _buildSubmissionCard(Size size, dynamic submission, int index) {
    final formId = submission['formId'] ?? '';
    final formName = _getFormNameById(formId);
    final code = submission['submissionCode'] ?? '';
    final dateStr = submission['createdAt'] ?? '';
    String formattedDate = '';
    try {
      if (dateStr.isNotEmpty) {
        final date = DateTime.parse(dateStr);
        formattedDate = DateFormat('MMM d, yyyy').format(date);
      }
    } catch (_) {}

    final form = _getFormById(formId);
    final thumbnailUrl = form != null ? (form['thumbnailUrl'] ?? '') : '';
    final cardBg = _getCardBgColor(index);
    final cardIconColor = _getCardIconColor(index);

    return InkWell(
      onTap: () => _onSubmissionTap(submission, formName),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEFF1F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: PDF Thumbnail Container
            Container(
              width: 44,
              height: 58,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: cardIconColor.withValues(alpha: 0.3), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: (thumbnailUrl.isNotEmpty)
                    ? Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: cardIconColor,
                            size: 20,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: cardIconColor,
                          size: 20,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Middle: Title & Description (Code + Date)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formName,
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AirbnbCereal',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    code,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontFamily: 'AirbnbCereal',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (formattedDate.isNotEmpty) const SizedBox(height: 4),
                  if (formattedDate.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.calendar,
                          size: 10,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 10,
                            fontFamily: 'AirbnbCereal',
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right: Share Icon button
            Builder(
              builder: (buttonContext) {
                return IconButton(
                  icon: const Icon(
                    LucideIcons.share_2,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  onPressed: () =>
                      _shareSubmission(buttonContext, submission, formName),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmissionTap(dynamic submission, String formName) {
    final formId = submission['formId'] ?? '';
    final submissionId = submission['id'] ?? '';
    final token = getIt<SharedPreferences>().getString('auth_token') ?? '';

    final viewUrl =
        "https://presshop.dev/f/$formId/view/$submissionId?token=$token";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewForFormScreen(
          formId: formId,
          formName: formName,
          customUrl: viewUrl,
        ),
      ),
    );
  }

  void _shareSubmission(
      BuildContext buttonContext, dynamic submission, String formName) {
    final formId = submission['formId'] ?? '';
    final submissionId = submission['id'] ?? '';
    final token = getIt<SharedPreferences>().getString('auth_token') ?? '';

    final viewUrl =
        "https://presshop.dev/f/$formId/view/$submissionId?token=$token";

    Rect? shareOrigin;
    final box = buttonContext.findRenderObject() as RenderBox?;
    if (box != null) {
      shareOrigin = box.localToGlobal(Offset.zero) & box.size;
    }
    if (shareOrigin == null ||
        shareOrigin.width == 0 ||
        shareOrigin.height == 0) {
      shareOrigin = const Rect.fromLTWH(0, 0, 100, 100);
    }

    Share.share(
      "Check out my submission for $formName:\n$viewUrl",
      sharePositionOrigin: shareOrigin,
    );
  }

  Widget _buildFormCard({
    required Size size,
    required String formId,
    required String formName,
    required String formCode,
    required String thumbnailUrl,
    required int index,
  }) {
    final cardBg = _getCardBgColor(index);
    final cardIconColor = _getCardIconColor(index);

    return InkWell(
      onTap: () => _openForm(formId, formName),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEFF1F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: PDF Thumbnail Container
            Container(
              width: 44,
              height: 58,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: cardIconColor.withValues(alpha: 0.3), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: (thumbnailUrl.isNotEmpty)
                    ? Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: cardIconColor,
                            size: 20,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: cardIconColor,
                          size: 20,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Middle: Title & Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formName,
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AirbnbCereal',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formCode.isNotEmpty ? formCode : "Honda/123/2026",
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontFamily: 'AirbnbCereal',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right: Chevron
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9CA3AF),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openForm(String formId, String formName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewForFormScreen(
          formId: formId,
          formName: formName,
        ),
      ),
    );
  }
}
