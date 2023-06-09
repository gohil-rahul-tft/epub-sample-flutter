import 'package:epub_sample/helpers/epub_helper.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<String> hrefs;
  final List<String> books = [
    "alice.epub",
    "accessible.epub",
    "urdu_sample.epub"
  ];

  bool isBookLoaded = false;
  int currentIndex = 0;
  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    );

  @override
  void initState() {
    super.initState();
  }

  void changeFile(String filePath) async {
    setState(() {
      controller
          // ..loadRequest(htmlToURI('https://flutter.dev'));
          //   ..loadHtmlString(assetFile);
          // .loadFlutterAsset("assets/html/index.html");
          .loadFile(Uri.file(filePath).toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
      ),
      floatingActionButton: isBookLoaded
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      isBookLoaded = false;
                    });
                  },
                  child: const Icon(Icons.cancel),
                ),
                const SizedBox(width: 16),

                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (currentIndex > 0) {
                        currentIndex--;
                      } else {
                        currentIndex = hrefs.length - 1;
                      }

                      changeFile(hrefs[currentIndex]);
                    });
                  },
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (currentIndex < hrefs.length - 1) {
                        currentIndex++;
                      } else {
                        currentIndex = 0;
                      }
                      changeFile(hrefs[currentIndex]);
                    });
                  },
                  child: const Icon(Icons.arrow_forward),
                ),

              ],
            )
          : Container(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isBookLoaded)

              Expanded(
                child: ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(books[index]),
                      onTap: () async {
                        EpubHelper helper = EpubHelper();
                        hrefs = await helper.parseEPUB(bookName: books[index]);
                        setState(() {
                          isBookLoaded = true;
                          changeFile(hrefs[currentIndex]);
                        });
                      },
                    );
                  },
                ),
              ),
            if (isBookLoaded) ...[
              Container(
                child: Text(
                  'Current Href: ${hrefs[currentIndex]}',
                  style: TextStyle(fontSize: 18),
                ),
              ),

              Expanded(child: WebViewWidget(controller: controller)),
              // Display additional content based on the current href
            ],
          ],
        ),
      ),
    );
  }
}
