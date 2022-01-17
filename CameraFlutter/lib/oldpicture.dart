import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class OldPicture extends StatefulWidget {
  OldPicture({Key key}) : super(key: key);

  @override
  _OldPictureState createState() => _OldPictureState();
}

class _OldPictureState extends State<OldPicture> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  List<UriData> veriler = [];

  Future<List<UriData>> verilerigetir() async {
    await database.reference().once().then((DataSnapshot snapshot) {
      try {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
          UriData data = Uri.parse(values).data;
            veriler.add(data);
        });
        return veriler;
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<UriData>>(
        future: verilerigetir(),
        builder: (context, snapshot) {
   
            return ListView.builder(
                itemCount: veriler.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Image.memory(veriler[index].contentAsBytes()),
                  );
                });
          
         
        },
      ),
    );
  }
}
