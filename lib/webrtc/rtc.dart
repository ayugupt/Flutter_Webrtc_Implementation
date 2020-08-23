import 'package:flutter/material.dart';

import 'package:flutter_webrtc/webrtc.dart';

import '../signallingSys/wsConnection.dart';

class RTC {
  RTCPeerConnection peerConnection;
  RTCSessionDescription sessionDescription;

  List<MediaStream> remoteStreams;

  Future<void> createPeerCon(stream) async {
    peerConnection = await createPeerConnection({
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ]
    }, {});

    await peerConnection.addStream(stream);
  }

  Future<void> offerCreate() async {
    sessionDescription = await peerConnection.createOffer({
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    });
  }

  Future<void> answerCreate() async {
    sessionDescription = await peerConnection.createAnswer({
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    });
  }

  Future<MediaStream> getLocalStreams(Map<String, dynamic> constraints) async {
    MediaStream streams = await navigator.getUserMedia(constraints);
    return streams;
  }
}
