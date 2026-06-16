import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../presentation/widgets/app_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/di/injection.dart';
import '../../../../core/network/api_client.dart';


class WebViewForFormScreen extends StatefulWidget {
  final String? formId;
  final String? formName;
  final String? customUrl;
  const WebViewForFormScreen({
    super.key,
    this.formId,
    this.formName,
    this.customUrl,
  });

  @override
  State<WebViewForFormScreen> createState() => _WebViewForFormScreenState();
}

class _WebViewForFormScreenState extends State<WebViewForFormScreen> {
  bool _isLoading = true;
  String? _webViewUrl;
  String? _errorMessage;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _fetchFormTokenAndLoadUrl();
  }

  WebViewController _createWebViewController(String url) {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'FormChannel',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint("FormChannel received message: ${message.message}");
          if (mounted) {
            Navigator.pop(context);
          }
        },
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint("FlutterChannel received message: ${message.message}");
          if (mounted) {
            Navigator.pop(context);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint("WebView progress: $progress");
          },
          onPageStarted: (String url) {
            debugPrint("WebView started loading: $url");
            final lowerUrl = url.toLowerCase();
            if (lowerUrl.contains('/success') ||
                lowerUrl.contains('/submitted') ||
                lowerUrl.contains('status=success') ||
                lowerUrl.contains('/thank-you') ||
                lowerUrl.contains('/form-success')) {
              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          onPageFinished: (String url) {
            debugPrint("WebView finished loading: $url");
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView error: $error");
          },
          onNavigationRequest: (NavigationRequest request) {
            final lowerUrl = request.url.toLowerCase();
            if (lowerUrl.contains('/success') ||
                lowerUrl.contains('/submitted') ||
                lowerUrl.contains('status=success') ||
                lowerUrl.contains('/thank-you') ||
                lowerUrl.contains('/form-success')) {
              if (mounted) {
                Navigator.pop(context);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  Future<void> _fetchFormTokenAndLoadUrl() async {
    try {
      final token = getIt<SharedPreferences>().getString('auth_token') ?? "";

      if (widget.customUrl != null) {
        final url = widget.customUrl!;
        setState(() {
          _webViewUrl = url;
          _webViewController = _createWebViewController(url);
          _isLoading = false;
        });
        return;
      }

      if (widget.formId != null) {
        final url = "https://presshop.dev/f/${widget.formId}?token=$token";
        setState(() {
          _webViewUrl = url;
          _webViewController = _createWebViewController(url);
          _isLoading = false;
        });
        return;
      }

      final apiClient = getIt<ApiClient>();
      final response = await apiClient.post('enterprise/forms/app-token');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null && data['success'] == true && data['url'] != null) {
          final url = data['url'];
          setState(() {
            _webViewUrl = url;
            _webViewController = _createWebViewController(url);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data?['message'] ?? "Failed to retrieve form URL.";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Server returned error: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_webViewController != null &&
            await _webViewController!.canGoBack()) {
          _webViewController!.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppAppBar(
          title: widget.formName ?? 'Forms',
          elevation: 0.5,
          centerTitle: false,
          titleSpacing: 0,
          showBack: true,
          onBackTap: () async {
            if (_webViewController != null &&
                await _webViewController!.canGoBack()) {
              _webViewController!.goBack();
            } else {
              if (mounted) Navigator.pop(context);
            }
          },
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : WebViewWidget(controller: _webViewController!),
      ),
    );
  }
}
