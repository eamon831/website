import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:isolate';
import 'package:intl/intl.dart';
import 'dart:ui'; // You need to import these 2 libraries besides another libraries to work with this code

final ReceivePort _port = ReceivePort();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // InAppWebViewController webView;
  final GlobalKey webViewKey = GlobalKey();
  //Declare Globaly
  String? directory;
  List file = [];
  CookieManager cookieManager = CookieManager.instance();
  final expiresDate = DateTime.now().add(Duration(days: 3)).millisecondsSinceEpoch;
  final url = Uri.parse("https://flutter.dev/");


  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,

    ),
  );
  late ContextMenu contextMenu;

  @override
  void initState() {

    super.initState();
     config();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              androidId: 1,
              iosId: "1",
              title: "Special",
              action: () async {
                final snackBar = SnackBar(
                  content: Text("Special clicked!"),
                  duration: Duration(seconds: 1),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              })
        ],
        onCreateContextMenu: (hitTestResult) async {
          toast("hello");
          String selectedText =
              await webViewController?.getSelectedText() ?? "";
          final snackBar = SnackBar(
            content: Text(
                "Selected text: '$selectedText', of type: ${hitTestResult.type.toString()}"),
            duration: Duration(seconds: 1),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        onContextMenuActionItemClicked: (menuItem) {
          var id = (Platform.isAndroid) ? menuItem.androidId : menuItem.iosId;

          final snackBar = SnackBar(
            content: Text(
                "Menu item with ID $id and title '${menuItem.title}' clicked!"),
            duration: Duration(seconds: 1),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
  }



  @override
  void dispose() {
    super.dispose();
  }
  var dio = Dio();
   int x=100;

  @override
  Widget build(BuildContext context) {
    return  Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: InAppWebView(
                  onDownloadStartRequest: (controller, url) async {
                    print("onDownloadStart ${url.url}");
                    var tempDir = await getApplicationDocumentsDirectory();
                    String time=DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now());
                    String fullPath = tempDir.path + "/$time - ${url.suggestedFilename}";
                    print('full path ${fullPath}');
                    download2(dio, url.url.toString(), fullPath);

                  },
                  initialUrlRequest: URLRequest(url: Uri.parse("https://jetnotices.rexlink.com.au/Login.aspx?ReturnUrl=%2f"),),

                  contextMenu: contextMenu,
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        useOnDownloadStart: true
                    ),
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    webViewController = controller;
                  },


                ),
              ),
            ],
          ),
        );

  }
  void _download(String url) async {
    final status = await Permission.storage.request();

    if(status.isGranted) {
      final externalDir = await getExternalStorageDirectory();

      final id = await FlutterDownloader.enqueue(
        url: url,
        savedDir: externalDir!.path,
        showNotification: true,
        openFileFromNotification: true,
      );
    } else {
      print('Permission Denied');
    }
  }
  Future download2(Dio dio, String url, String savePath) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      toast("Downloading");
      try {
        Response response = await dio.get(
          url,
          onReceiveProgress: showDownloadProgress,
          //Received data with List<int>
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) {
                return status! < 500;
              }),
        );
        print(response.headers);
        File file = File(savePath);
        var raf = file.openSync(mode: FileMode.write);
        // response.data is List<int> type
        raf.writeFromSync(response.data);
        await raf.close();
        toast("Download Complete");
      } catch (e) {
        toast("Something Went Wrong");
        print(e);
      }
    }
    else{
      toast("We Need Permission");

    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  Future<void> config() async {
    await cookieManager.setCookie(
      url: url,
      name: "myCookie",
      value: "myValue",
      expiresDate: expiresDate,
      isSecure: true,
    );
  }

}