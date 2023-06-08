import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    loadController();
  }

  void loadController() async {
    final String assetFile =
        await rootBundle.loadString('assets/html/index.html');

    setState(() {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
          ),
        )
        // ..loadRequest(htmlToURI('https://flutter.dev'));
        //   ..loadHtmlString(assetFile);
        ..loadFlutterAsset("assets/html/index.html");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Web View Screen"),
      ),
      body: WebViewWidget(controller: controller),
      // body: const InAppWebView(initialFile: "assets/html/index.html"),
    );
  }
}
