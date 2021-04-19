import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novo_health_africa_companion/bottom_navigation/home.dart';
import 'package:novo_health_africa_companion/chat/chat.dart';

class Recent_Chat extends StatefulWidget {
  final List<UserData> appointment;

  Recent_Chat({Key key, this.appointment}) : super(key: key);

  @override
  _Recent_ChatState createState() => _Recent_ChatState();
}

class _Recent_ChatState extends State<Recent_Chat> {
  TextEditingController editingController = TextEditingController();
  String _imageProfile =
      'https://www.novohealthafrica.org/new/images/logo/icon.png';
  String _profileImageUrl =
      "https://www.novohealthafrica.org/new/images/logo/icon.png";

  //List<Provider_Model> lists;
  List<Map<dynamic, dynamic>> lists = [];

  String userUID;
  FirebaseAuth _auth = FirebaseAuth.instance;
  var dbRef;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userUID = _auth.currentUser.uid;
    dbRef = FirebaseDatabase.instance
        .reference()
        .child("Recent_Chats")
        .child(userUID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(User_Home());
                    },
                    child: Icon(Icons.home_filled),
                  )),
            ],
            title: Center(
              child: Text("Recent Chats",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            )),
        body: Center(
            child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Color.fromRGBO(32, 50, 111, 1.0),
            Color.fromRGBO(32, 141, 86, 1.0),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          height: double.infinity,
          child: StreamBuilder(
              stream: dbRef.onValue,
              builder: (context, AsyncSnapshot<Event> snapshot) {
                if (snapshot.hasData) {
                  lists.clear();
                  DataSnapshot dataValues = snapshot.data.snapshot;
                  Map<dynamic, dynamic> values = dataValues.value;
                  //check if the node is already existing
                  if (values == null) {
                  } else {
                    values.forEach((key, values) {
                      lists.add(values);
                    });
                  }
                  return new ListView.builder(
                      shrinkWrap: true,
                      itemCount: lists.length,
                      itemBuilder: (BuildContext context, int index) {
                        String profileImageDoctor =
                            lists[index]["profileImageUrl"];
                        String doctorName = lists[index]["fullName"];
                        String doctorPolicyNumber = lists[index]["policNumber"];
                        String doctorEmail = lists[index]["email"];
                        String doctorUniqueId = lists[index]["userId"];
                        String profession = lists[index]["profession"];
                        String state = lists[index]["state"];
                        String username = lists[index]["username"];
                        String doctorPhone = lists[index]["phoneNumber"];
                        String user_token = lists[index]["user_token"];
                        return GestureDetector(
                          onTap: () {
                            Get.to(Chat(), arguments: [
                              profileImageDoctor,
                              doctorName,
                              doctorPolicyNumber,
                              doctorEmail,
                              doctorUniqueId,
                              profession,
                              state,
                              username,
                              doctorPhone,
                              user_token
                            ]);
                          },
                          child: Card(
                              child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: <Widget>[
                                      _profileImageUrl != null
                                          ? Container(
                                              height: 90,
                                              width: 90,
                                              child: CircleAvatar(
                                                radius: 60,
                                                backgroundImage: NetworkImage(
                                                    lists[index]
                                                        ["profileImageUrl"]),
                                              ),
                                            )
                                          : CircleAvatar(
                                              radius: 60,
                                              backgroundImage:
                                                  AssetImage(_imageProfile),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 8,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Doctor Name :",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Expanded(
                                            child: Text(
                                              lists[index]["fullName"]
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Phone Number :",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Expanded(
                                            child: Text(
                                              lists[index]["phoneNumber"]
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Email :",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Expanded(
                                            child: Text(
                                              lists[index]["email"].toString(),
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Date of Chat :",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Expanded(
                                            child: Text(
                                              lists[index]["time_date_chat"]
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ))
                            ],
                          )),
                        );
                      });
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              }),
        )));
  }
}

class UserData {
  final String key;
  String companyName;
  String companyPlan;
  String coverImageUrl;
  String dateOfBirth;
  String email;
  String fullName;
  String houseAddress;
  String maritalStatus;
  String onlineStatus;
  String phoneNumber;
  String policNumber;
  String profession;
  String profileImageUrl;
  String sex;
  String state;
  String status;
  String userId;
  String username;

  UserData.fromJson(this.key, Map data) {
    fullName = data['fullName'];
    companyName = data['company_name'];
    companyPlan = data['company_plan'];
    coverImageUrl = data['coverImageUrl'];
    dateOfBirth = data['dateOfBirth'];
    email = data['email'];
    houseAddress = data['houseAddress'];
    maritalStatus = data['maritalStatus'];
    onlineStatus = data['onlineStatus'];
    phoneNumber = data['phoneNumber'];
    policNumber = data['policNumber'];
    profession = data['profession'];
    profileImageUrl = data['profileImageUrl'];
    sex = data['sex'];
    state = data['state'];
    status = data['status'];
    userId = data['userId'];
    username = data['username'];

    if (fullName == null) {
      fullName = "";
    }
    if (companyName == null) {
      companyName = "";
    }
    if (companyPlan == null) {
      companyPlan = "";
    }
    if (coverImageUrl == null) {
      coverImageUrl = "";
    }
    if (dateOfBirth == null) {
      dateOfBirth = "";
    }
    if (email == null) {
      email = "";
    }
    if (houseAddress == null) {
      houseAddress = "";
    }
    if (maritalStatus == null) {
      maritalStatus = "";
    }
    if (onlineStatus == null) {
      onlineStatus = "";
    }
    if (phoneNumber == null) {
      phoneNumber = "";
    }
    if (policNumber == null) {
      policNumber = "";
    }
    if (profession == null) {
      profession = "";
    }
    if (profileImageUrl == null) {
      profileImageUrl = "";
    }
    if (sex == null) {
      sex = "";
    }
    if (state == null) {
      state = "";
    }
    if (status == null) {
      status = "";
    }
    if (userId == null) {
      userId = "";
    }
    if (username == null) {
      username = "";
    }
  }
}
