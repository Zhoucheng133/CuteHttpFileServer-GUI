// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables, depend_on_referenced_packages, unused_local_variable, avoid_unnecessary_containers, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:process_run/shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(400, 650);
    win.size = initialSize;
    win.minSize = initialSize;
    win.maxSize = initialSize;
    win.alignment = Alignment.center; //将窗口显示到中间
    win.show();
  });

  runApp(const MainApp());
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
        )
      ),
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
  void initState(){
    super.initState();
    _haveData();
    _getIP();
  }

  void _setSave(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
		await prefs.setBool('saveHistory', value);
  }

  void _haveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
		bool saveH=prefs.getBool("saveHistory") ?? true;
    if(saveH==false){
      saveHistory=false;
    }
  }

  void _getIP() async {
    List data=['/','/'];

    bool findIPv6=false;
    bool findIPv4=false;

    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if(addr.type.name=="IPv6" && findIPv6==false){
          data[1]=(addr.address);
          findIPv6=true;
        }else if(addr.type.name=="IPv4" && findIPv4==false){
          data[0]=(addr.address);
          findIPv6=true;
        }
      }
    }
    ip=data;
  }

  bool saveHistory=true;
  List ip=['/','/'];

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
        Text(
          "设置",
          style: TextStyle(fontSize: 15),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 50, 50, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "保存先前的记录",
                    style: TextStyle(
                      fontSize: 18
                    ),
                  ),
                  Spacer(),
                  Switch(
                    value: saveHistory, 
                    onChanged: (bool v){
                      setState(() {
                        saveHistory=v;
                        if(v==false){
                          _HomePageState._clearData();
                        }
                        _setSave(v);
                      });
                    }
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    "下面是你的ip信息:",
                    style: TextStyle(
                      fontSize: 18
                    ),
                  ),
                  Spacer()
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text("IPv4地址:"),
                  Spacer()
                ],
              ),
              Row(
                children: [
                  Text(ip[0]),
                  Spacer()
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text("IPv6地址:"),
                  Spacer()
                ],
              ),
              Row(
                children: [
                  Text(ip[1]),
                  Spacer()
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: ()async{
                        if(ip[0]!='/') {
                          Clipboard.setData(ClipboardData(text: ip[0]+":"+_HomePageState.inputPort.text));
                        }else{
                          return showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('无法继续'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: const <Widget>[
                                      Text('当前没有IPv4地址')
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
                      },
                      child: Text("复制IPv4地址")
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: ()async{
                        if(ip[1]!='/'){
                          Clipboard.setData(ClipboardData(text: "[${ip[1]}]:${_HomePageState.inputPort.text}"));
                        }else{
                          return showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('无法继续'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: const <Widget>[
                                      Text('当前没有IPv6地址')
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
                      },
                      child: Text("复制IPv6地址")
                    )
                  ],
                ),
              ),
              TextButton(
                onPressed: ()async{
                  if(_HomePageState.isRun==false){
                    return showDialog<void>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('无法继续'),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: const <Widget>[
                                Text('没有在运行')
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
                  }else{
                    Uri url = Uri.parse("http://${ip[0]}:${_HomePageState.inputPort.text}");
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  }
                },
                child: Text("打开本地的链接")
              )
            ]
          ),
        )
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
        Text("Version: 1.1.1"),
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
            Uri url = Uri.parse('https://gitee.com/Ryan-zhou/cute-http-file-server-gui');
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

class _HomePageState extends State<HomePage> with WindowListener {

  void _init() async {
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      if(isRun==true){
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('无法退出'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text("没有停止程序运行，需要先停止程序")
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('好的'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }else{
        await windowManager.destroy();
      }
    }
  }

  static TextEditingController inputPort = TextEditingController();
  String? selectedDirectory = "";
  String? selectedProgram = "";
  TextEditingController inputPath = TextEditingController();
  TextEditingController inputUser = TextEditingController();
  TextEditingController inputPass = TextEditingController();
  TextEditingController inputProgram = TextEditingController();
  int shareMethod = 1;
  static bool isRun = false;
  var shell = Shell();

  @override
  void initState() {
    super.initState();

    inputPort.text = "81";
    inputPath.text = "没有选择分享路径";
    inputProgram.text="没有选择程序路径";
    _haveData();

    windowManager.addListener(this);
    _init();
    super.initState();
  }
  
  static void _clearData()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
		prefs.clear();
  }

  void _haveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
		String sharePath=prefs.getString("sharePath") ?? "";
		String programPath=prefs.getString("programPath") ?? "";
    String userName=prefs.getString("userName") ?? "";
    String userPass=prefs.getString("userPass") ?? "";
		if(sharePath!=''){
      inputPath.text=sharePath;
		}
    if(programPath!=''){
      inputProgram.text=programPath;
    }
    if(userName!=''){
      inputUser.text=userName;
    }
    if(userPass!=''){
      inputPass.text=userPass;
    }
  }

  void _setData(String sharePath, String programPath, String userName, String userPass) async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		await prefs.setString('sharePath', sharePath);
		await prefs.setString('programPath', programPath);
    await prefs.setString('userName', userName);
    await prefs.setString('userPass', userPass);
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
              } on ShellException catch (_) {}

              _setData(inputPath.text,inputProgram.text,inputUser.text,inputPass.text);
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
                          String? tmp = await FilePicker.platform.getDirectoryPath();
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
