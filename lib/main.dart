// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables, depend_on_referenced_packages, unused_local_variable, avoid_unnecessary_containers, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:process_run/shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(400, 650);
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
              BottomNavigationBarItem(icon: Icon(Icons.settings), label:"配置"),
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
            children: [
              HomePage(),
              SettingPage(), 
              InfoPage()
            ],
          )),
    );
  } 
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WindowTitleBarBox(
          child: MoveWindow(
            child: Container(
              color: const Color.fromRGBO(250, 250, 250, 1)
            )
          )
        ),
        // Text(sharedPreferences?.getBool("isRun")==true ? '正在运行':'不在运行'),
        TextButton(onPressed: (){
          _HomePageState._clearData();
          print("OKOK");
        }, child: Text("清除"))
      ],
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
              Container(color: const Color.fromRGBO(250, 250, 250, 1)
            )
          )
        ),
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
        Text("Version: 1.0.1 Beta"),
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
  TextEditingController inputPort = TextEditingController();
  String? selectedDirectory = "";
  String? selectedProgram = "";
  TextEditingController inputPath = TextEditingController();
  TextEditingController inputUser = TextEditingController();
  TextEditingController inputPass = TextEditingController();
  TextEditingController inputProgram = TextEditingController();
  int shareMethod = 1;
  bool isRun = false;
  var shell = Shell();

  @override
  void initState() {
    super.initState();
    inputPort.text = "81";
    inputPath.text = "没有选择分享路径";
    inputProgram.text="没有选择程序路径";
    _haveData();
  }
  
  static void _clearData()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
		prefs.clear();
  }

  void _haveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
		String sharePath=prefs.getString("sharePath") ?? "";
		String programPath=prefs.getString("programPath") ?? "";
		if(sharePath!=''){
      inputPath.text=sharePath;
		}
    if(programPath!=''){
      inputProgram.text=programPath;
    }
  }

  void _setData(String sharePath, String programPath) async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		await prefs.setString('sharePath', sharePath);
		await prefs.setString('programPath', programPath);
	}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // 下面是命令的执行
            if(isRun==false){
              if(inputPath.text=="没有选择分享路径" || inputPath.text=="null"){
                return showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('无法继续'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: const <Widget>[
                            Text('你没有选取目录')
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('知道了'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }else if(inputProgram.text=="没有选择程序路径" || inputProgram.text=="null"){
                return showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('无法继续'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: const <Widget>[
                            Text('你没有选取程序')
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('知道了'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }else if(inputPort.text=="" || int.tryParse(inputPort.text)==null){
                return showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('无法继续'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: const <Widget>[
                            Text('端口号为空或者不合法')
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('知道了'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }else if(shareMethod!=1 && (inputUser.text=="" || inputPass.text=="")){
                return showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('无法继续'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: const <Widget>[
                            Text('你没有输入指定用户信息')
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('知道了'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
              // 下面执行命令
              String command="";
              if(shareMethod==1){
                command="${inputProgram.text} --port=${inputPort.text} --path=\"${inputPath.text}\"";
              }else if(shareMethod==2){
                command="${inputProgram.text} --port=${inputPort.text} --path=\"${inputPath.text}\" --rule=\"::r|${inputUser.text}:${inputPass.text}:rwd\"";
              }else{
                command="${inputProgram.text} --port=${inputPort.text} --path=\"${inputPath.text}\" --rule=\"::|${inputUser.text}:${inputPass.text}:rwd\"";
              }
              setState(() {
                isRun=true;
              });
              try {
                await shell.run(command);
              } on ShellException catch (_) {
                // We might get a shell exception
              }

              _setData(inputPath.text,inputProgram.text);
            }else{
              shell.kill();
              setState(() {
                isRun=false;
              });
              
            }
          },
          backgroundColor: Colors.blue,
          child: isRun==false?Icon(Icons.keyboard_arrow_right):Icon(Icons.square),
        ),
        body: Column(
          children: [
            WindowTitleBarBox(
              child: MoveWindow(
                child: Container(
                  color: const Color.fromRGBO(250, 250, 250, 1)
                )
              )
            ),
            Text(
              "CuteHttpFileServer GUI",
              style: TextStyle(fontSize: 15),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 50, 50, 0),
              child: Column(
                children: [
                  TextField(
                    controller: inputPort,
                    decoration: InputDecoration(
                      labelText: '端口',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: inputPath,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "分享路径"
                          ),
                        ),
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          String? tmp =
                              await FilePicker.platform.getDirectoryPath();
                          setState(() {
                            selectedDirectory = tmp;
                            inputPath.text = tmp.toString();
                          });
                        },
                        child: Text("选取目录")
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: inputProgram,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "程序路径"
                          ),
                        ),
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          FilePickerResult? tmp = await FilePicker.platform.pickFiles();
                          // print(tmp?.files.single.path);
                          setState(() {
                            selectedProgram = tmp?.files.single.path;
                            inputProgram.text = (tmp?.files.single.path).toString();
                          });
                        },
                        child: Text("选取程序")
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 1,
                        groupValue: shareMethod,
                        onChanged: (v) {
                          setState(() {
                            shareMethod = v!;
                          });
                        }),
                      TextButton(
                        onPressed: (){
                          setState(() {
                            shareMethod=1;
                          });
                        },
                        child: Text("所有设备:读/写")
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 2,
                        groupValue: shareMethod,
                        onChanged: (v) {
                          setState(() {
                            shareMethod = v!;
                          });
                        }),
                      TextButton(
                        onPressed: (){
                          setState(() {
                            shareMethod=2;
                          });
                        },
                        child: Text("所有设备:读取,指定用户:读/写"),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 3,
                        groupValue: shareMethod,
                        onChanged: (v) {
                          setState(() {
                            shareMethod = v!;
                          });
                        }
                      ),
                      // Text("指定用户:读/写")
                      TextButton(
                        onPressed: (){
                          setState(() {
                            shareMethod=3;
                          });
                        },
                        child: Text("指定用户:读/写")
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    enabled: shareMethod==1?false:true,
                    controller: inputUser,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "用户名"
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    enabled: shareMethod==1?false:true,
                    controller: inputPass,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "密码"
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
