import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_face_detection/FacePainter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:my_face_detection/IPAddress.dart';


class FaceDetector extends StatefulWidget {
  const FaceDetector({Key? key}) : super(key: key);

  @override
  _FaceDetectorState createState() => _FaceDetectorState();
}

class _FaceDetectorState extends State<FaceDetector> {
    File? _imageFile =null ;
    List<Face>? _faces=null;
    bool isLoading =false;
    ui.Image? _image=null;
    TextEditingController nameController = new TextEditingController();
    



//,maxHeight: 380,maxWidth: 540,imageQuality: 50
  Future getImage(bool camera) async{
    File image;
    final _picker = ImagePicker();
    var pickedFile;
    if(camera){
      pickedFile= await _picker.getImage(source: ImageSource.camera);
      image= File(pickedFile.path);
    }else{
      pickedFile= await _picker.getImage(source: ImageSource.gallery);
      image= File(pickedFile.path);
    }


    setState(() {
      _imageFile=image;
      isLoading = true;
    });
    // String imgString = Utility.base64String(imgFile.readAsBytesSync());

    detectFaces(_imageFile!);

  }
  detectFaces(File imageFile) async{
    final image= FirebaseVisionImage.fromFile(imageFile);
    final faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> faces= await faceDetector.processImage(image);

    if(mounted){
      setState(() {
        _imageFile=imageFile;
        _faces=faces;
        _loadImage(imageFile);
      });
    }
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    print("hellooooo $data");
    await decodeImageFromList(data).then((value) =>
    setState((){
      _image=value;
      print("ZZZZZZZoooooooooo $_image");
      isLoading= false;
      // uploadImage();
      // _addLabel();
      if(_faces!.length==0){
        _notFound();
      }
      else if(_faces!.length==1){
        _addLabel();
      }
      else if(_faces!.length>1){
        _manyFace();

      }
    }));
  }

  Future uploadImage() async{
    
    final uri =Uri.parse(Globals.ipAddress+"/SmartDoorLockApp/SmartDoorLockApp.php");
    var request = http.MultipartRequest('POST',uri);
    request.fields['name']=nameController.text;
    var pic = await http.MultipartFile.fromPath("image", _imageFile!.path);
    request.files.add(pic);
    var response = await request.send();

    if(response.statusCode == 200){
      print("image uploaded");
      _savedComplete();
    }else{
      print("Failed");
    }

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(

      appBar: AppBar(
        title: Text(
            "Face Detector",
          style:GoogleFonts.lobster(
            fontSize: 25,

          ),
        ),
        backgroundColor: Colors.red,

      ),
      body: isLoading
      ?Center(
        child: Container(
          width: MediaQuery.of(context).size.width/1.1,
          height: MediaQuery.of(context).size.height/2,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(20)
          ),
          child: Center(child: CircularProgressIndicator(),),
        ),
      )
          :(_imageFile== null)
    ?Center(
        child: Container(
          width: MediaQuery.of(context).size.width/1.1,
          height: MediaQuery.of(context).size.height/2,
          decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(20)
          ),
          child: Center(
            child: Text(
                "No Image Selected",
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                color: Colors.black,
              ),
            ),),
        ),
    )
          :Center(
        child: Container(
          margin: EdgeInsets.only(left: 10,right: 10),
          child: FittedBox(
            child: SizedBox(
              width: _image!.width.toDouble(),
              height: _image!.height.toDouble(),
              child: CustomPaint(
                painter: FacePainter(_image!, _faces!) ,
              ),
            ),
          ),
        ),

      ),


      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _imageFile !=null;
                });
              },
              backgroundColor: Colors.red,
              child: Icon(Icons.refresh),

            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: (){
                getImage(true);
              },
              backgroundColor: Colors.red,
              child: Icon(Icons.camera_alt),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: (){
                getImage(false);
              },
              backgroundColor: Colors.red,
              child: Icon(Icons.image)
              ,
            ),
          ),
        ],
      ),
    );
  }
  //nnneewww ccooodee
  String? get _errorText {

    final text = nameController.value.text;

    if (text.isEmpty) {
      return 'Can\'t be empty';
    }

    return text;
  }
  //ennnnnndddd

void _addLabel() {


    print("Adding new face");
    var alert = new AlertDialog(
      title: new Text(
          "Add Face",
        style: GoogleFonts.alfaSlabOne(
          color: Colors.green,
        ),
      ),

      content: new Row(
        children: <Widget>[
          new Expanded(
            //From add
            child: new TextField(
              controller:  nameController,
              autofocus: true,
              decoration: new InputDecoration(
                  labelText: "Name", icon: new Icon(Icons.face),
                //new
                errorText: _errorText,
                //end
              ),



            ),
          )
        ],
      ),
      actions: <Widget>[
        new ElevatedButton(
            child: Text("Save"),
            // color: Colors.green,
            onPressed: () {
              //newcode
              if(nameController.value.text.isNotEmpty){

                uploadImage();
                Navigator.pop(context);
              }

              //end
              // uploadImage();
              // Navigator.pop(context);
            }),
        new FlatButton(
          child: Text("Cancel"),
          color: Colors.red,
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

    void _notFound() {

      print("Face Not Found");
      var alert = new AlertDialog(
        title: new Text(
            "Face Not Found",
          style: GoogleFonts.alfaSlabOne(
            color: Colors.red,
          ),
        ),

        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new Text(
                "Face Not Found, Please take an image properly!",
                style: GoogleFonts.breeSerif(),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: Text("OK"),
              color: Colors.red,
              onPressed: () {
                Navigator.pop(context);
              }),

        ],
      );
      showDialog(
          context: context,
          builder: (context) {
            return alert;
          });
    }

    void _savedComplete() {
    
      print("Sucessfully Saved");
      var alert = new AlertDialog(
        title: new Text(
            "Imaged Saved",
          style: GoogleFonts.alfaSlabOne(
            color: Colors.green,
          ),
        ),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new Text(
                  "Your Image Successfully Saved!!",
                style: GoogleFonts.breeSerif(),
              ),
            ),
            Icon(Icons.done,color: Colors.green,size: 20,)
          ],
        ),

        actions: <Widget>[
          new FlatButton(
              child: Text("OK"),
              color: Colors.green,
              onPressed: () {
                Navigator.pop(context);
              }),

        ],
      );
      showDialog(
          context: context,
          builder: (context) {
            return alert;
          });
    }

    void _manyFace() {

      print("Many Faces Found");
      var alert = new AlertDialog(
        title: new Text(
            "Many Faces Found",
          style: GoogleFonts.alfaSlabOne(
            color: Colors.red,
          ),
        ),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new Text(
                  "There is too many faces. Please chosse a single face!",
                style: GoogleFonts.breeSerif(),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: Text("OK"),
              color: Colors.red,
              onPressed: () {
                Navigator.pop(context);
              }),

        ],
      );
      showDialog(
          context: context,
          builder: (context) {
            return alert;
          });
    }

}
