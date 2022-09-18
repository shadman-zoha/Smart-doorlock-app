import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:my_face_detection/IPAddress.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:animated_text_kit/animated_text_kit.dart';




class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isSwitched=true;
  bool? newVal;
  String doorStatus="The Door Is Open";


  final DBref = FirebaseDatabase.instance.reference();

  LedOn() async {
    await DBref.child("DHT11")
        .child("Device1")
        .child("LED_STATUS")
        .update({'DATA': 'TRUE'});
  }

  LedOFF() async {
    await DBref.child("DHT11")
        .child("Device1")
        .child("LED_STATUS")
        .update({'DATA': 'FALSE'});
  }

  getStatus() async {

    await DBref
        .child('DHT11/Device1/LED_STATUS/DATA')
        .onValue
        .listen((event) {
      String newValue = event.snapshot.value.toString();
      print("Hello $newValue");

      setState(() {
        if (newValue == 'TRUE') {
          isSwitched = true;
        } else {
          isSwitched = false;
        }
        _doorStatus(isSwitched);
      });
    });
  }

  _handleSwitch(bool value) async {
    if( value ) {
      await LedOn();
    } else {
      await LedOFF();
    }
    setState(() {
      isSwitched = value;
      _doorStatus(isSwitched);
    });

  }

  _doorStatus(isSwitched)async{
    if(isSwitched==true){
      doorStatus="door is open ";
    }
    else{
      doorStatus="door is closed ";
    }
  }
  


  //Notification start
  FirebaseMessaging? _firebaseMessaging;
  String? token1;

  void firebaseCloudMessaging_Listeners(){
    FirebaseMessaging.instance.getToken().then((token) {

      token1= token;
      print("Token is"+token1!);
      updateToken();


      setState(() {

      });
    });
  }

  Future updateToken() async{
    final uri =Uri.parse(Globals.ipAddress+"/SmartDoorLockApp/updateToken.php");
    var request = http.MultipartRequest('POST',uri);
    request.fields['token']=token1!;
    var response = await request.send();

    if(response.statusCode == 200){
      print("update token");

    }else{
      print("Failed for update token");
    }

  }

  //Notification end

//new code for NN

  initialize() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);

    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });


    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved2");
      print(event.notification!.body);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "Notification",
                style: GoogleFonts.alfaSlabOne(
                  color: Colors.red,
                ),
              ),
              content: Text(
                  event.notification!.body!,
                style: GoogleFonts.breeSerif(),
              ),
              actions: [
                FlatButton(
                  child: Text("Ok"),
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }
// end here

  @override
  void initState() {
    getStatus();
    super.initState();
    firebaseCloudMessaging_Listeners();
    initialize();
    print(Globals.ipAddress);


  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Smart Door Lock',
          style:GoogleFonts.lobster(
            fontSize: 30,

          ),
        ) ,
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
                isSwitched ? 'assets/open.jpg' : 'assets/closed.jpg',
              height: 150,

            ),
            SizedBox(
              height: 140,
              width: 170,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Switch(
                  value: isSwitched,
                  activeColor: Colors.green,
                  activeTrackColor: Colors.green[200],
                  inactiveTrackColor: Colors.red[100],
                  inactiveThumbColor: Colors.red,
                  onChanged: (value) async {
                    await _handleSwitch(value);

                  },
                ),
              ),
            ),
            SizedBox(height: 1,),
            Text(
                "$doorStatus",
              style: GoogleFonts.bebasNeue(
                fontSize: 40,

              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: (){
                Navigator.pushNamed(context, '/newUser');
              },
              style:ButtonStyle(
                backgroundColor:MaterialStateProperty.all<Color>(Colors.amberAccent) ,
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  )
                ),
              ) ,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      Icons.add,
                    color: Colors.black,
                    size: 25,
                  ),
                  SizedBox(width: 10,),
                  Text(
                      'Add New Member',
                    style: GoogleFonts.fjallaOne(
                      fontSize: 25,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),


            SizedBox(height: 2,),

            ElevatedButton(
              onPressed: (){
                Navigator.pushNamed(context, '/savedFaces');
              },
              style:ButtonStyle(
                backgroundColor:MaterialStateProperty.all<Color>(Colors.amberAccent) ,
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    )
                ),
              ) ,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.tag_faces,
                    color: Colors.black,
                    size: 25,
                  ),
                  SizedBox(width: 10,),
                  Text(
                    'Saved Faces',
                    style: GoogleFonts.fjallaOne(
                      fontSize: 25,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 2,),

            ElevatedButton(
              onPressed: (){
                Navigator.pushNamed(context, '/unKnownFaces');
              },
              style:ButtonStyle(
                backgroundColor:MaterialStateProperty.all<Color>(Colors.amberAccent) ,
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    )
                ),
              ) ,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.perm_device_information,
                    color: Colors.black,
                    size: 25,
                  ),
                  SizedBox(width: 10,),
                  Text(
                    'Unknown Faces',
                    style: GoogleFonts.fjallaOne(
                      fontSize: 25,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),





          ],
        ),
      ),
    );
  }
}
