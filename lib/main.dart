import "package:flutter/material.dart";

import 'dart:convert';
import 'dart:core';

import 'package:flutter_webrtc/webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'call.dart';
import './utils/dimensions.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Initial(),
      theme: ThemeData(
          appBarTheme: AppBarTheme(color: Colors.purple),
          bottomAppBarTheme: BottomAppBarTheme(color: Colors.purple)),
    );
  }
}

class Initial extends StatefulWidget {
  State createState() => InitialState();
}

class InitialState extends State<Initial> {
  SharedPreferences prefs;

  Future<void> getPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    this.prefs = prefs;
  }

  @override
  void initState() {
    getPrefs().then((_) {
      if (!prefs.containsKey("username")) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
          return Login(prefs);
        }), (route) => false);
      } else {
        String uname = prefs.getString("username");
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
          return MakeCall(uname);
        }), (route) => false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

