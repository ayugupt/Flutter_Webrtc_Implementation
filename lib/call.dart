import 'dart:async';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_webrtc/webrtc.dart';

import './utils/dimensions.dart';
import './signallingSys/wsConnection.dart';
import './webrtc/rtc.dart';

class MakeCall extends StatefulWidget {
  final String username;
  MakeCall(this.username);

  State createState() => MakeCallState();
}

class MakeCallState extends State<MakeCall> {
  Signalling signalling = new Signalling();
  RTC rtc = new RTC();

  bool loggedIn = false;
  BuildContext cont;

  StreamSubscription signalSub;

  Map<String, dynamic> constraints(width, height) {
    return {
      'audio': false,
      'video': {
        'mandatory': {
          'minWidth': '$width',
          'minHeight': '$height',
          'minFrameRate': '20',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };
  }

  RTCVideoRenderer renderer = new RTCVideoRenderer();
  bool test = false;

  @override
  void initState() {
    renderer.initialize();
    signalling.connect("192.168.0.103", "8080");
    signalling.send({"type": "login", "name": "${widget.username}"});

    rtc.getLocalStreams(constraints(720, 640)).then((s) {
      rtc.createPeerCon(s).then((_) {
        rtc.peerConnection.onIceConnectionState = (state) {
          if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
            var remoteStreams = rtc.peerConnection.getRemoteStreams();
            renderer.srcObject = remoteStreams[0];
            test = true;
            setState(() {});
          }
        };
      });
    });

    signalSub = signalling.receive().listen((data) async {
      var d = jsonDecode(data);
      switch (d["type"]) {
        case "login":
          if (d["success"] == true) {
            print("loggedIn");
            setState(() {
              loggedIn = true;
            });
          }
          break;
        case "offer":
          rtc.peerConnection.onIceCandidate = (candidate) {
            signalling.send({
              "type": "candidate",
              "candidate": "${candidate.candidate}",
              "sdpMid": "${candidate.sdpMid}",
              "sdpIndex": "${candidate.sdpMlineIndex}",
              "name": "${d["name"]}"
            });
          };
          await rtc.peerConnection.setRemoteDescription(
              new RTCSessionDescription(d["offer"], d["type"]));
          await rtc.answerCreate();
          await rtc.peerConnection.setLocalDescription(rtc.sessionDescription);
          signalling.send({
            "type": "answer",
            "answer": "${rtc.sessionDescription.sdp}",
            "descType": "${rtc.sessionDescription.type}",
            "name": "${d["name"]}",
            "constraints": {
              "height": "${height * pixRatio}",
              "width": "${width * pixRatio}"
            }
          });

          break;
        case "answer":
          await rtc.peerConnection.setRemoteDescription(
              new RTCSessionDescription(d["answer"], d["descType"]));
          break;
        case "candidate":
          await rtc.peerConnection.addCandidate(new RTCIceCandidate(
              d["candidate"], d["sdpMid"], int.parse(d["sdpIndex"])));
          break;
      }
    });
    super.initState();
  }

  InputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.purple, width: 3));

  final controller = new TextEditingController();

  double phoneRingDiameter = 60;

  var pixRatio;

  @override
  Widget build(BuildContext context) {
    cont = context;
    pixRatio = MediaQuery.of(context).devicePixelRatio;
    if (height == null || width == null) {
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    }
    return Scaffold(
      body: !test
          ? Center(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(),
                  ),
                  Text("Enter the username to which you want to connect to"),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Container(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                          enabledBorder: border,
                          focusedBorder: border,
                          disabledBorder: border),
                    ),
                    width: width * 0.6,
                  ),
                  SizedBox(
                    height: height * 0.1,
                  ),
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          child: Container(
                            color: Colors.purple,
                          ),
                          padding: EdgeInsets.only(top: phoneRingDiameter / 2),
                        ),
                        Align(
                          child: Stack(children: <Widget>[
                            Container(
                                child: ClipPath(
                                  clipper: HalfCut(),
                                  child: Container(
                                    width: phoneRingDiameter,
                                    height: phoneRingDiameter,
                                    color: Colors.purple,
                                  ),
                                ),
                                width: phoneRingDiameter,
                                height: phoneRingDiameter,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.black, width: 1))),
                            GestureDetector(
                              onTap: () async {
                                if (controller.text.length != 0) {
                                  rtc.peerConnection.onIceCandidate =
                                      (candidate) {
                                    signalling.send({
                                      "type": "candidate",
                                      "candidate": "${candidate.candidate}",
                                      "sdpMid": "${candidate.sdpMid}",
                                      "sdpIndex": "${candidate.sdpMlineIndex}",
                                      "name": "${controller.text}"
                                    });
                                  };
                                  await rtc.offerCreate();
                                  await rtc.peerConnection.setLocalDescription(
                                      rtc.sessionDescription);
                                  signalling.send({
                                    "type": "offer",
                                    "offer": "${rtc.sessionDescription.sdp}",
                                    "descType":
                                        "${rtc.sessionDescription.type}",
                                    "name": "${controller.text}",
                                    "constraints": {
                                      "height": "${height * pixRatio}",
                                      "width": "${width * pixRatio}"
                                    }
                                  });
                                }
                              },
                              child: Container(
                                width: phoneRingDiameter,
                                height: phoneRingDiameter,
                                child: Icon(
                                  Icons.call,
                                  color: Colors.black,
                                ),
                                color: Colors.white.withAlpha(0),
                              ),
                            )
                          ]),
                          alignment: Alignment.topCenter,
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          : Container(
              width: width,
              height: height,
              child: RTCVideoView(renderer),
            ),
    );
  }
}

class HalfCut extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.addArc(
        Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: size.width,
            height: size.height),
        0,
        -22 / 7);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(oldClipper) {
    return false;
  }
}
