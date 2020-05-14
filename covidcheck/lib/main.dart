import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> list = [];
  
  void _incrementCounter() {
    bool tracked = false;
    FlutterBarcodeScanner.getBarcodeStreamReceiver("#ff6666", "Cancel", false, ScanMode.BARCODE)
      .listen((data) {
        if (tracked) return;

        tracked = true;
        http.put("http://117.20.192.157:11111/api", headers: { 'Content-type': 'application/json' }, body: jsonEncode({ 'process': 'check', 'id': data }))
          .then((res) {
            setState(() {
              var resData = jsonDecode(res.body);
              print(resData);
              if (!resData['success']) {
                list.insert(0, ListTile(title: Text("$data - no data")));
              } else {
                list.insert(0, ListTile(title: Text(
                  "$data - "
                    + resData['data']['grade'].toString() + "학년 "
                    + resData['data']['class'].toString() + "반 "
                    + resData['data']['number'].toString() + "번 "
                    + resData['data']['name']
                )));
              }
            });
          });
      });
  }

  ListView buildList () {
    return ListView(children: [...list]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: buildList()
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add)
      ),
    );
  }
}
