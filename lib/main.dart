// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MainApp());
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(400, 600);
    win.size = initialSize;
    win.minSize = initialSize;
    win.maxSize = initialSize;
    win.alignment = Alignment.center; //将窗口显示到中间
    win.show();
  });
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainApp();
}

class _MainApp extends State<MainApp> {
  var curIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      home: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: curIndex,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "主页"),
              BottomNavigationBarItem(icon: Icon(Icons.info), label: "关于"),
            ],
            onTap: (int index) {
              setState(() {
                curIndex = index;
              });
            },
          ),
          body: IndexedStack(
            index: curIndex,
            children: <Widget>[HomePage(), InfoPage()],
          )),
    );
  }
}

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WindowTitleBarBox(
            child: MoveWindow(
                child:
                    Container(color: const Color.fromRGBO(250, 250, 250, 1)))),
        Text(
          "关于本软件",
          style: TextStyle(fontSize: 15),
        ),
        SizedBox(
          height: 120,
        ),
        Text(
          "CuteHttpFileServer",
          style: TextStyle(fontSize: 30),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "GUI version",
          style: TextStyle(fontSize: 15),
        ),
        SizedBox(
          height: 50,
        ),
        Text("Version: 0.0.1 Alpha"),
        SizedBox(
          height: 50,
        ),
        Text("本程序基于: "),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () async {
                  Uri url = Uri.parse('http://iscute.cn/chfs');
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                child: Text("chfs")),
            SizedBox(
              width: 10,
            ),
            TextButton(
                onPressed: () async {
                  Uri url = Uri.parse('https://flutter.cn/');
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                child: Text("Flutter")),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        IconButton(
          onPressed: () async {
            Uri url = Uri.parse(
                'https://gitee.com/Ryan-zhou/cute-http-file-server-gui');
            if (!await launchUrl(url)) {
              throw Exception('Could not launch $url');
            }
          },
          icon: Icon(Icons.code),
          color: Colors.blue,
        )
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.blue,
          child: const Icon(Icons.keyboard_arrow_right),
        ),
        body: Column(
          children: [
            WindowTitleBarBox(
              child: MoveWindow(
                child:
                  Container(
                    color: const Color.fromRGBO(250, 250, 250, 1)
                  )
              )
            ),
            Text(
              "CuteHttpFileServer GUI",
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
