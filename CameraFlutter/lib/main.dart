import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:advanced_splashscreen/advanced_splashscreen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gesture_zoom_box/gesture_zoom_box.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'blinkingTimer.dart';
import 'videoUtil.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        title: "Dash Cam App",
        home: AdvancedSplashScreen(
          child: WifiCheck(),
          seconds: 3,
          colorList: [Color(0xff0088e2), Color(0xff0075cd), Color(0xff0063b8)],
          appTitle: "Dash Cam",
          appIcon: "images/dashcam_white.png",
        ));
  }
}

class WifiCheck extends StatefulWidget {
  @override
  _WifiCheckState createState() => _WifiCheckState();
}

class _WifiCheckState extends State<WifiCheck> {
  final String targetSSID = "TAKUHAN2";
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  bool isTargetSSID;

  @override
  void initState() {
    super.initState();
    isTargetSSID = false;

    initConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          LoadingFlipping.square(
            borderColor: Colors.cyan,
            size: 100,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  _connectionStatus.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 26.0),
                ),
                SizedBox(
                  height: 20,
                ),
                RaisedButton(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      side: BorderSide(color: Colors.red)),
                  onPressed:
                      isTargetSSID ? _ConnectWebSocket : initConnectivity,
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text(
                    isTargetSSID ? "Connect" : "Recheck WIFI",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 30),
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  _ConnectWebSocket() {
    Future.delayed(Duration(milliseconds: 100)).then((_) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Home(
                    channel:
                        IOWebSocketChannel.connect('ws://192.168.4.1:8888'),
                  )));
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;
        try {
          var status = await Permission.location.status;
          if (status.isUndetermined || status.isDenied || status.isRestricted) {
            if (await Permission.location.request().isGranted) {
              // Either the permission was already granted before or the user just granted it.
            }
          }
          wifiName = await _connectivity.getWifiName();
          print(wifiName);
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Wifi Name yokkk";
        }

        try {
          wifiBSSID = await _connectivity.getWifiBSSID();
          print("wifi BSSID: " + wifiBSSID);
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n'
              'Wifi BSSID: $wifiBSSID\n'
              'Wifi IP: $wifiIP\n';

          isTargetSSID = targetSSID == wifiName;
        });
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }
}

class Home extends StatefulWidget {
  final WebSocketChannel channel;

  Home({Key key, @required this.channel}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final double videoWidth = 640;
  final double videoHeight = 480;

  double newVideoSizeWidth = 640;
  double newVideoSizeHeight = 480;

  bool isLandscape;
  String _timeString;

  var _globalKey = new GlobalKey();

  Timer _timer;
  bool isRecording;

  int frameNum;
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    isLandscape = false;
    isRecording = false;

    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());

    frameNum = 0;
    VideoUtil.workPath = 'images';
    VideoUtil.getAppTempDirectory();

  }

  @override
  void dispose() {
    widget.channel.sink.close();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        var screenWidth = MediaQuery.of(context).size.width;
        var screenHeight = MediaQuery.of(context).size.height;

        if (orientation == Orientation.portrait) {
          //screenWidth < screenHeight

          isLandscape = false;
          newVideoSizeWidth = screenWidth;
          newVideoSizeHeight = videoHeight * newVideoSizeWidth / videoWidth;
        } else {
          isLandscape = true;
          newVideoSizeHeight = screenHeight;
          newVideoSizeWidth = videoWidth * newVideoSizeHeight / videoHeight;
        }

        return Container(
          color: Colors.black,
          child: StreamBuilder(
            stream: widget.channel.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Future.delayed(Duration(milliseconds: 100)).then((_) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => WifiCheck()));
                });
              }

              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              } else {
                if (isRecording) {
                  VideoUtil.saveImageFileToDirectory(
                      snapshot.data, 'image_$frameNum.jpg');
                  frameNum++;
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: isLandscape ? 0 : 30,
                        ),
                        Stack(
                          children: <Widget>[
                            RepaintBoundary(
                              key: _globalKey,
                              child: GestureZoomBox(
                                maxScale: 5.0,
                                doubleTapScale: 2.0,
                                duration: Duration(milliseconds: 200),
                                child: Image.memory(
                                  snapshot.data,
                                  gaplessPlayback: true,
                                  width: newVideoSizeWidth,
                                  height: newVideoSizeHeight,
                                ),
                              ),
                            ),
                            Positioned.fill(
                                child: Align(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 46,
                                  ),
                                  isRecording ? BlinkingTimer() : Container(),
                                ],
                              ),
                              alignment: Alignment.topCenter,
                            )),
                            Positioned.fill(
                                child: Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                _timeString,
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w300),
                              ),
                            ))
                          ],
                        ),
                        
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        );
      }),
    );
  }

  takeScreenShot() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext.findRenderObject();
    var image = await boundary.toImage();
    var byteData = await image.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd HH:mm:ss').format(dateTime);
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    Future.delayed(
        Duration.zero,
        () => setState(() {
              _timeString = _formatDateTime(now);
            }));
  }
}
