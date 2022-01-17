import 'package:connectivity/connectivity.dart';
import 'package:dashcam_flutter/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/io.dart';


class WifiCheck extends StatefulWidget {
  @override
  _WifiCheckState createState() => _WifiCheckState();
}

class _WifiCheckState extends State<WifiCheck> {
  final String targetSSID = "Kablonet Netmaster-6DEE-G";
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
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
          Navigator.pop(context);
        },),
      ),
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
                        IOWebSocketChannel.connect('ws://192.168.0.14:8888'),
                  )));
    });
  }
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
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
          if (status.isPermanentlyDenied || status.isDenied || status.isRestricted) {
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

