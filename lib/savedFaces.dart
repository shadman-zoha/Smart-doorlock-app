import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'FaceDetector.dart';
import 'package:my_face_detection/home.dart';
import 'package:http/http.dart' as http;
import 'package:full_screen_image/full_screen_image.dart';
import 'package:my_face_detection/IPAddress.dart';


class savedFaces extends StatefulWidget {
  const savedFaces({Key? key}) : super(key: key);

  @override
  _savedFacesState createState() => _savedFacesState();
}

class _savedFacesState extends State<savedFaces> {

  List ImageList = [];

  getAllImage() async{
    var response = await http.get(Uri.parse(Globals.ipAddress+"/SmartDoorLockApp/savedFaces.php"));
    if(response.statusCode == 200){
      setState(() {
        ImageList=json.decode(response.body);
      });
      return ImageList;
    }
  }


  deleteImage(id,photos) async{

    var map= Map<String, dynamic>();
    map['id']=id;
    map['photos']=photos;
    final response = await http.post(Uri.parse(Globals.ipAddress+"/SmartDoorLockApp/deleteImage.php"), body: map);

      if(response.statusCode == 200){
        return response.body;
      }else{
        return "error";
      }

  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Saved Faces',
          style:GoogleFonts.lobster(
            fontSize: 25,

          ),
        ) ,

        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemCount: ImageList.length,
        itemBuilder: (context,index){
          // return ListTile(
          //   leading: Text(ImageList[index]['id']),
          //   title: Text(ImageList[index]['names']) ,
          // );
          return Padding(
            padding: EdgeInsets.only(top: 8.0, left: 16.0,right: 16.0),
            child: Card(
              elevation: 8.0,
              child: ListTile(
                // leading: Text(ImageList[index]['id']),
                leading: FullScreenWidget(
                  child: Container(
                    width: 100,height: 100,
                    child: Image.network(Globals.ipAddress+"/SmartDoorLockApp/uploads/${ImageList[index]['photos']}"),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      ImageList[index]['names'].toUpperCase(),
                      style: GoogleFonts.breeSerif(),

                    ) ,
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: ()
                      {

                        // deleteImage( context,ImageList[index]['id']);
                        deleteFace(context,ImageList[index]['id'],ImageList[index]['photos']);

                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ) ,
    );
  }

  void deleteFace(BuildContext context, id,photos) {

    var map= Map<String, dynamic>();
    map['id']=id;
    map['photos']=photos;

    print("delete Face");
    var alert = new AlertDialog(
      title: new Text(
          "Delete Face",
        style: GoogleFonts.alfaSlabOne(
          color: Colors.red,
        ),
      ),
      content: new Row(
        children: <Widget>[
          new Expanded(
            child: new Text(
                "Are you sure, you want to delete this image?",
              style: GoogleFonts.breeSerif(),
            ),

          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            child: Text("Delete"),
            color: Colors.red[400],
            onPressed: () {
              deleteImage( id,photos);
              getAllImage();
              Navigator.pop(context);
            }),
        new FlatButton(
          child: Text("Cancel"),
          color: Colors.green[400],
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }
}
