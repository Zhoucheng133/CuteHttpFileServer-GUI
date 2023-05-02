// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

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
              // curIndex = index;
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
        Text("info Page")
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
  var helloworld = "";

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    if (now.hour < 11) {
      // helloworld = "早上好";
      setState(() {''
        helloworld = "早上好";
      });
    } else if (now.hour < 14) {
      helloworld = "中午好";
    } else if (now.hour < 18) {
      helloworld = "下午好";
    } else {
      helloworld = "晚上好";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WindowTitleBarBox(
            child: MoveWindow(
                child:
                    Container(color: const Color.fromRGBO(250, 250, 250, 1)))),
        SizedBox(
          height: 40,
        ),
        Text("哈喽，$helloworld呀！"),
        SizedBox(height: 40),
        Text(
          "CuteHttpFileServer",
          style: TextStyle(fontSize: 30),
        ),
        SizedBox(
          height: 10,
        ),
        Text("GUI for Mac")
      ],
    );
  }
}
