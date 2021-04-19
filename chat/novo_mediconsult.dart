import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novo_health_africa_companion/chat/chat.dart';
import 'package:novo_health_africa_companion/chat/recentChat.dart';
import 'package:novo_health_africa_companion/chat/userChat.dart';

class Novo_MediConsult extends StatefulWidget {
  final List<UserChat> user;
  Novo_MediConsult({Key key, this.user}) : super(key: key);

  @override
  _Novo_MediConsultState createState() => _Novo_MediConsultState();
}

class _Novo_MediConsultState extends State<Novo_MediConsult> {
  final dbRef = FirebaseDatabase.instance.reference().child("Doctors");
  TextEditingController editingController = TextEditingController();
  String _imageProfile =
      'https://www.novohealthafrica.org/new/images/logo/icon.png';
  String _profileImageUrl =
      "https://www.novohealthafrica.org/new/images/logo/icon.png";

  //List<Provider_Model> lists;
  List<Map<dynamic, dynamic>> lists = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(Recent_Chat());
                    },
                    child: Icon(Icons.chat),
                  )),
            ],
            title: Center(
              child: Text("Doctors",
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
                  values.forEach((key, values) {
                    lists.add(values);
                  });

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
                                              lists[index]["fullName"],
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
                                            "Availability :",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Expanded(
                                            child: Text(
                                              lists[index]["policNumber"],
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
                                              lists[index]["email"],
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
