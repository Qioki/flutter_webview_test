import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final TextEditingController _urlController = TextEditingController();
  late WebViewController _webViewController;
  bool _isLoading = false;

  @override
  void initState() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _urlController.text = url;
              _isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _urlController.text = url;
              _isLoading = false;
            });
          },
        ),
      );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              FutureBuilder(
                  future: _canGoBack(),
                  builder: (context, snap) {
                    var isEnable = snap.data ?? false;
                    return IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: isEnable ? _goBack : null,
                    );
                  }),
              FutureBuilder(
                  future: _canGoForward(),
                  builder: (context, snap) {
                    var isEnable = snap.data ?? false;
                    return IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: isEnable ? _goForward : null,
                    );
                  }),
              IconButton(
                icon: Icon(_isLoading ? Icons.close : Icons.refresh),
                onPressed: () {
                  _isLoading ? _stopLoading() : _reload();
                },
              ),
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      fillColor: Colors.white10,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    onSubmitted: (value) {
                      print('submitted $value');
                      _loadUrl(value.trim());
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        body: WebViewWidget(
          controller: _webViewController,
        ));
  }

  void _loadUrl(String url) {
    _webViewController.loadRequest(Uri.parse(url));
  }

  void _reload() {
    _webViewController.reload();
  }

  void _stopLoading() {
    _webViewController.runJavaScript('window.stop();');
  }

  Future<bool> _canGoBack() async {
    return await _webViewController.canGoBack();
  }

  void _goBack() {
    _webViewController.goBack();
  }

  Future<bool> _canGoForward() async {
    return await _webViewController.canGoForward();
  }

  void _goForward() {
    _webViewController.goForward();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
