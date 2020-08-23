# Flutter_Webrtc_Implementation
This Flutter project allows two users to video call using webRTC, through the flutter_webrtc package.

WebRTC leverages a bunch of APIs which work together to allow real time, peer-to-peer communication between multiple users. These include APIs which get local video and audio streams from the device, APIs which set up peer-to-peer connection using ICE protocol which, in turn, uses STUN and its extension TURN protocols. 

One more thing one needs to set up a webRTC connection is a signalling server which is used to exchange information and ICE candidates between users who want to connect. This is not provided through webRTC in order to provide developers the freedom to make their own signalling server using whatever method they like.

For this, I have used node.js to make a local websocket server in order to communicate between users who are connected to the same LAN as the server.
Here is the server code along with instructions to set up --> 

