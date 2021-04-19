import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:novo_health_africa_companion/bottom_navigation/dashboard.dart';
import 'package:novo_health_africa_companion/chat/fullphoto.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  var doctorDetails = Get.arguments;
  final TextEditingController editingController = TextEditingController();
  final ScrollController listscrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  bool isDisplayStickers;
  bool isLoading;

  PickedFile imageFile;
  File _singleImage;
  String imageUrl;

  String chatId;
  SharedPreferences preferences;
  String id;

  var listMessages;

  String profileImageDoctor;
  String doctorName;
  String doctorPolicyNumber;
  String doctorEmail;
  String doctorUniqueId;
  String profession;
  String state;
  String senderUid;
  String doctorPhone;
  String doctorToken;

  StreamSubscription _subscriptionTodo;
  DatabaseReference _userProfiles, _key, notification, recentChat;
  FirebaseAuth _auth = FirebaseAuth.instance;

  String userUID;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  StreamSubscription iosSubscription;

  String _fullName;
  String _user_token = "";
  String _onlineStatus = "";
  String _profileImageUrl =
      "https://www.novohealthafrica.org/new/images/logo/icon.png";
  String _dateOfBirth = "Display the todo name here";
  String _coverImageUrl = "Display the todo name here";
  String _user_unique_id;
  String _email = "saintiano@gmail.com";
  String _imageProfile =
      'https://www.novohealthafrica.org/new/images/logo/icon.png';
  String _sex = "user unique id";
  String _maritalStatus = "user unique id";
  String _occupation = "user unique id";
  String _phoneNumber = "user unique id";
  String _state = "user unique id";
  String _status = "User unique id";
  String _homeAddress = "user unique id";
  String _dateBirth = "user unique id";
  String _policy_number = "user unique id";
  String _company_name = "user unique id";
  String _company_plan = "user unique id";
  String _subscription_status = "user unique id";
  String _health_plan = "user unique id";
  String _preferred_provider = "user unique id";
  String _id_card_status = "user unique id";
  String _date_joined = "user unique id";
  String _expiring_date = "user unique id";
  String _number_dependants = "user unique id";
  String _profession = "user unique id";
  String _username = "user unique id";
  String _password = "user unique id";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Realtime update
    FirebaseTodos.getUsertream(_updateUser)
        .then((StreamSubscription s) => _subscriptionTodo = s);
    super.initState();

    userUID = _auth.currentUser.uid;

    setState(() {
      _user_unique_id = userUID;
    });

    focusNode.addListener(onFocusChange);

    isDisplayStickers = false;
    isLoading = false;

    chatId = "";

    readlocalStorage();

    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        var data = message['data'] ?? message;
        String notificationMessage = data['fromName'];
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['data']['screen']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
        var data = message['data'] ?? message;
        String screen = message['data']['screen'];
        String notificationMessage = data['screen'];
        if (screen == "CHAT") {
          Get.to(Chat());
        } else {
          Get.to(Dashboard());
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
        var data = message['data'] ?? message;
        String screen = message['data']['screen'];
        String notificationMessage = data['screen'];
        if (screen == "CHAT") {
          Get.to(Chat());
        } else {
          Get.to(Dashboard());
        }
      },
    );
  }

  //read local storage from shared preference
  //compare user id and doctor id and the assign chat id using both ids
  void readlocalStorage() async {
    preferences = await SharedPreferences.getInstance();

    if (_user_unique_id.hashCode <= doctorUniqueId.hashCode) {
      chatId = '$_user_unique_id-$doctorUniqueId';
    } else {
      chatId = '$doctorUniqueId-$_user_unique_id';
    }

    FirebaseFirestore.instance
        .collection("User_Profiles")
        .doc(_user_unique_id)
        .update({'chattingwith': doctorUniqueId});

    _userProfiles = FirebaseDatabase.instance
        .reference()
        .child('User_Profiles')
        .child(_user_unique_id);

    _userProfiles.update({'chattingwith': doctorUniqueId});

    setState(() {});
  }

  onFocusChange() {
    if (focusNode.hasFocus) {
      //hide sticker when keyboard shows
      setState(() {
        isDisplayStickers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    profileImageDoctor = doctorDetails[0];
    doctorName = doctorDetails[1];
    doctorPolicyNumber = doctorDetails[2];
    doctorEmail = doctorDetails[3];
    doctorUniqueId = doctorDetails[4];
    profession = doctorDetails[5];
    state = doctorDetails[6];
    senderUid = doctorDetails[7];
    doctorPhone = doctorDetails[8];
    doctorToken = doctorDetails[9];

    return Scaffold(
      appBar: AppBar(
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {},
                  child: CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(profileImageDoctor),
                  ),
                )),
            Padding(
                padding: EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.medical_services),
                )),
          ],
          title: Center(
            child: Text(doctorName.toString(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          )),
      body: WillPopScope(
        child: Stack(
          children: [
            Column(
              children: [
                //create list of messages
                CreateListMessages(),
                //show stickers
                (isDisplayStickers ? createStickers() : Container()),
                //input controllers
                CreateInput(),
              ],
            ),
            CreateLoading(),
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  Widget ChatScreen(String receiverID, String receiverProfileImage) {}

  //input controllers
  CreateInput() {
    return Container(
      child: Row(
        children: [
          //select image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                  icon: Icon(Icons.image),
                  color: Colors.lightBlueAccent,
                  onPressed: () {
                    getImage();
                  }),
            ),
            color: Colors.white,
          ),
          //select Emojis
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                  icon: Icon(Icons.face_retouching_natural),
                  color: Colors.lightBlueAccent,
                  onPressed: () {
                    getStickers();
                  }),
            ),
            color: Colors.white,
          ),

          //Edit textfield
          Flexible(
            child: Container(
                child: TextField(
              controller: editingController,
              decoration: InputDecoration(
                  hintText: "Write your message",
                  hintStyle: TextStyle(color: Colors.grey)),
              focusNode: focusNode,
            )),
          ), //send message button
          Material(
              child: Container(
            color: Colors.white,
            child: IconButton(
                icon: Icon(Icons.send),
                color: Colors.lightBlueAccent,
                onPressed: () {
                  onSendMessage(editingController.text, 0);
                }),
          ))
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
              bottom: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ))),
    );
  }

  //create list of messages
  CreateListMessages() {
    return Flexible(
        child: chatId == ""
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.amberAccent),
                ),
              )
            : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatIOSMessage")
                    .doc(chatId)
                    .collection(chatId)
                    .orderBy("timestamp", descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.amberAccent),
                      ),
                    );
                  } else {
                    //save data to list
                    listMessages = snapshot.data.documents;

                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) {
                        return createItems(
                            index, snapshot.data.documents[index]);
                      },
                      itemCount: snapshot.data.documents.length,
                      reverse: true,
                      controller: listscrollController,
                    );
                  }
                },
              ));
  }

  //send message to user
  //the number is used to differentiate the stickers, images and messages sent by user
  onSendMessage(String messageContent, int type) {
    //type = 0, its means its a message
    //type = 1, its means its a images
    //type = 2, its means its a stickers

    //check if message is empty
    if (messageContent != "") {
      editingController.clear();

      var docRef = FirebaseFirestore.instance
          .collection("chatIOSMessage")
          .doc(chatId)
          .collection(chatId)
          .doc(DateTime.now().microsecondsSinceEpoch.toString());

      //TODO: create database for notification

      var notifyDevice = FirebaseFirestore.instance
          .collection("Notifications")
          .doc(doctorUniqueId)
          .collection("firebaseNotification")
          .doc(DateTime.now().microsecondsSinceEpoch.toString());

      var userProfile = FirebaseFirestore.instance
          .collection("User_Profiles")
          .doc(_user_unique_id);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(docRef, {
          "idFrom": _user_unique_id,
          "idTo": doctorUniqueId,
          "timestamp": DateTime.now().microsecondsSinceEpoch.toString(),
          "type": type,
          "content": messageContent,
        });
      });

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(notifyDevice, {
          "idFrom": _user_unique_id,
          "idTo": doctorUniqueId,
          "timestamp": DateTime.now().microsecondsSinceEpoch.toString(),
          "type": type,
          "content": messageContent,
          "fromName": _fullName,
          "notification_title": "CHAT",
          "fromImage": _profileImageUrl,
          "profileImageDoctor": profileImageDoctor,
          "doctorName": doctorName,
          "doctorPolicyNumber": doctorPolicyNumber.toString(),
          "doctorEmail": doctorEmail,
          "doctorUniqueId": doctorUniqueId,
          "profession": profession,
          "state": state,
          "senderUid": _user_unique_id,
          "doctorPhone": doctorPhone,
          "fcmToken": doctorToken,
          "myToken": _user_token,
        });
      });

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(userProfile, {
          "fullName": _fullName,
          "policNumber": _policy_number,
          "phoneNumber": _phoneNumber,
          "profession": _profession,
          "userId": userUID,
          "email": _email,
          "username": senderUid,
          "company_name": _company_name,
          "company_plan": _company_plan,
          "profileImageUrl": _profileImageUrl,
          "myToken": _user_token,
          "fcmToken": doctorToken
        });
      });

      var dataRef = FirebaseDatabase.instance
          .reference()
          .child("chatIOSMessage")
          .child(chatId)
          .child(chatId)
          .child(DateTime.now().microsecondsSinceEpoch.toString());

      var recentChat = FirebaseDatabase.instance
          .reference()
          .child("Recent_Chats")
          .child(doctorUniqueId)
          .child(_user_unique_id);

      var notifications = FirebaseDatabase.instance
          .reference()
          .child("Notifications")
          .child(doctorUniqueId)
          .child("firebaseNotification")
          .child(DateTime.now().microsecondsSinceEpoch.toString());

      dataRef.set({
        "idFrom": _user_unique_id,
        "idTo": doctorUniqueId,
        "timestamp": DateTime.now().microsecondsSinceEpoch.toString(),
        "type": type,
        "content": messageContent,
      });

      notifications.set({
        "post_unique_id": _user_unique_id,
        "userId": doctorUniqueId,
        "timestamp": DateTime.now().microsecondsSinceEpoch.toString(),
        "content": messageContent,
        "comment": messageContent,
        "fromName": _fullName,
        "fromImage": _profileImageUrl,
        "sortDate": DateTime.now().microsecondsSinceEpoch.toString(),
        "suggested_dateTime": DateTime.now().toString(),
        "notification_title": "CHAT",
        "senderUid": _user_unique_id,
        "profileImageUrl": profileImageDoctor,
        "doctorName": doctorName,
        "policyNumber": doctorPolicyNumber,
        "doctorEmail": doctorEmail,
        "doctorUniqueId": doctorUniqueId,
        "profession": profession,
        "state": state,
        "phoneNumber": doctorPhone,
        "fcmToken": doctorToken,
      });

      recentChat.update({
        "content": messageContent,
        "sortDate": DateTime.now().microsecondsSinceEpoch.toString(),
        "notification_title": "CHAT",
        "timestamp": DateTime.now().microsecondsSinceEpoch.toString(),
        "email": _email,
        "fullName": _fullName,
        "profession": _profession,
        "senderUid": _user_unique_id,
        "profileImageUrl": _profileImageUrl,
        "doctorName": doctorName,
        "policyNumber": _policy_number,
        "userId": _user_unique_id,
        "phoneNumber": _phoneNumber,
        "state": _state,
        "fcmToken": _user_token,
        "chatingWith": doctorUniqueId,
      });

      listscrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Get.snackbar(_fullName, "Please enter a message",
          snackPosition: SnackPosition.TOP);
    }
  }

  //getting stcikers to show on screen
  void getStickers() {
    focusNode.unfocus();
    setState(() {
      //if false then true will be assigned and if its false, true is assigned
      isDisplayStickers = !isDisplayStickers;
    });
  }

  //remove stickers from screen
  Future<bool> onBackPress() {
    if (isDisplayStickers) {
      setState(() {
        isDisplayStickers = false;
      });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  //progress when loading messages
  CreateLoading() {
    return Positioned(
        child: isLoading ? CircularProgressIndicator() : Container());
  }

  //getting images from gallery
  Future getImage() async {
    ImagePicker picker = ImagePicker();

    imageFile = await picker.getImage(source: ImageSource.gallery);

    if (imageFile != null) {
      _singleImage = File(imageFile.path);
      isLoading = true;
    }
    uploadImage();
  }

  //send image to user and upload to firebase storage
  void uploadImage() async {
    String filename = DateTime.now().microsecondsSinceEpoch.toString();

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child("Chat_Images")
        .child("image1" + DateTime.now().toString());
    UploadTask uploadTask = ref.putFile(_singleImage);
    await uploadTask.whenComplete(() async {
      await ref.getDownloadURL().then((value) => imageUrl = value);
      setState(() {
        isLoading = false;

        //the number is used to differentiate the stickers, images and messages sent by user
        onSendMessage(imageUrl, 1);
      });
    });
  }

  //create items of messages list
  Widget createItems(int index, DocumentSnapshot document) {
    //my message - right side if idFrom = _user_unique_id
    if (document["idFrom"] == _user_unique_id) {
      return Row(
        children: [
          document["type"] == 0
              ?
              //type = o, message
              Container(
                  child: Text(
                    document["content"],
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 15.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessage(index) ? 20.0 : 10.0, right: 10.0),
                )
              : document["type"] == 1
                  ?
                  //type = 1, images
                  Container(
                      child: FlatButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) {
                              return Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      Colors.lightBlueAccent),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              );
                            },
                            errorWidget: (context, url, error) {
                              return Material(
                                child: Image.asset(
                                  "assets/name.png",
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                clipBehavior: Clip.hardEdge,
                              );
                            },
                            imageUrl: document["content"],
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          Get.to(Full_Photo(),
                              arguments: [document["content"]]);
                        },
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessage(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
                  :
                  //type = 2, emoji
                  Container(
                      child: Image.asset(
                          "assets/emoji/${document['content']}.png",
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover),
                      margin: EdgeInsets.only(
                          bottom: isLastMessage(index) ? 20.0 : 10.0,
                          right: 10.0),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      //receiver - left side if idFrom != _user_unique_id
      return Container(
        child: Column(
          children: [
            Row(
              children: [
                isLastLeftMessage(index)
                    ? Material(
                        //Retrieve profile images from doctor
                        child: CachedNetworkImage(
                          placeholder: (context, url) {
                            return Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                    Colors.lightBlueAccent),
                              ),
                              width: 35.0,
                              height: 35.0,
                              padding: EdgeInsets.all(10.0),
                            );
                          },
                          imageUrl: profileImageDoctor,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(
                        width: 35.0,
                      ),

                //Retrieve messages from doctor
                document["type"] == 0
                    ?
                    //type = o, message
                    Container(
                        child: Text(
                          document["content"],
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w400),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 15.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : document["type"] == 1
                        ?
                        //type = 1, images
                        Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) {
                                    return Container(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.lightBlueAccent),
                                      ),
                                      width: 200.0,
                                      height: 200.0,
                                      padding: EdgeInsets.all(70.0),
                                      decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                    );
                                  },
                                  errorWidget: (context, url, error) {
                                    return Material(
                                      child: Image.asset(
                                        "assets/name.png",
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      clipBehavior: Clip.hardEdge,
                                    );
                                  },
                                  imageUrl: document["content"],
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Get.to(Full_Photo(), arguments: [
                                  profileImageDoctor,
                                  doctorName,
                                  doctorPolicyNumber,
                                  doctorEmail,
                                  doctorUniqueId,
                                  profession,
                                  state,
                                ]);
                              },
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        :
                        //type = 2, emoji
                        Container(
                            child: Image.asset(
                                "assets/emoji/${document['content']}.png",
                                width: 100.0,
                                height: 100.0,
                                fit: BoxFit.cover),
                            margin: EdgeInsets.only(
                                bottom: isLastMessage(index) ? 20.0 : 10.0,
                                left: 10.0),
                          ),
              ],
            ),
            //display message time
            isLastLeftMessage(index)
                ? Container(
                    child: Text(
                      DateFormat("dd MMMM, yyyy - hh:mm:aa").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document["timestamp"]))),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 50.0, bottom: 5.0),
                  )
                : Container(),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

//checking for the last message on the right
  bool isLastMessage(int index) {
    if ((index > 0 &&
            listMessages != null &&
            listMessages[index - 1]["idFrom"] != _user_unique_id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

//checking for the last message on the left
  bool isLastLeftMessage(int index) {
    if ((index > 0 &&
            listMessages != null &&
            listMessages[index - 1]["idFrom"] == _user_unique_id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  //create stickers
  createStickers() {
    return Container(
      child: Column(
        children: [
          Row(children: [
            FlatButton(
                onPressed: onSendMessage("angry", 2),
                child: Image.asset(
                  "assets/emoji/angry.png",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )),
            FlatButton(
                onPressed: onSendMessage("disappointed", 2),
                child: Image.asset(
                  "assets/emoji/disappointed.png",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )),
            FlatButton(
                onPressed: onSendMessage("laugh", 2),
                child: Image.asset(
                  "assets/emoji/laugh.png",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ))
          ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
          Row(children: [
            FlatButton(
                onPressed: onSendMessage("oh", 2),
                child: Image.asset(
                  "assets/emoji/oh.png",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )),
            FlatButton(
                onPressed: onSendMessage("raised_brow", 2),
                child: Image.asset(
                  "assets/emoji/raised_brow.png",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )),
            FlatButton(
                onPressed: onSendMessage("sad", 2),
                child: Image.asset(
                  "assets/emoji/sad.png",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ))
          ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
          Row(
            children: [
              FlatButton(
                  onPressed: onSendMessage("satisfied", 2),
                  child: Image.asset(
                    "assets/emoji/satisfied.png",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )),
              FlatButton(
                  onPressed: onSendMessage("shocked", 2),
                  child: Image.asset(
                    "assets/emoji/shocked.png",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )),
              FlatButton(
                  onPressed: onSendMessage("smiles", 2),
                  child: Image.asset(
                    "assets/emoji/smiles.png",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ))
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          )),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180,
    );
  }

  _updateUser(UserData value) {
    var companyName = value.companyName;
    var companyPlan = value.companyPlan;
    var coverImageUrl = value.coverImageUrl;
    var dateOfBirth = value.dateOfBirth;
    var email = value.email;
    var fullName = value.fullName;
    var houseAddress = value.houseAddress;
    var maritalStatus = value.maritalStatus;
    var onlineStatus = value.onlineStatus;
    var phoneNumber = value.phoneNumber;
    var policNumber = value.policNumber;
    var profession = value.profession;
    var profileImageUrl = value.profileImageUrl;
    var sex = value.sex;
    var state = value.state;
    var status = value.status;
    var userId = value.userId;
    var username = value.username;
    var userToken = value.user_token;

    setState(() {
      _email = email;
      _onlineStatus = onlineStatus;
      _profileImageUrl = profileImageUrl;
      _dateOfBirth = dateOfBirth;
      _coverImageUrl = coverImageUrl;
      _imageProfile = 'assets/images/avatar.png';
      _sex = sex;
      _fullName = fullName;
      _maritalStatus = maritalStatus;
      _occupation = "user unique id";
      _phoneNumber = phoneNumber;
      _state = state;
      _status = status;
      _homeAddress = houseAddress;
      _dateBirth = dateOfBirth;
      _policy_number = policNumber;
      _company_name = companyName;
      _company_plan = companyPlan;
      _subscription_status = "user unique id";
      _health_plan = "user unique id";
      _preferred_provider = "user unique id";
      _id_card_status = "user unique id";
      _date_joined = "user unique id";
      _expiring_date = "user unique id";
      _number_dependants = "user unique id";
      _profession = profession;
      _username = username;
      _user_token = userToken;

      //Assigning data to textfields
      // enrollee_name.text = fullName;
      // enrollee_email.text = email;
    });
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
  String user_token;

  UserData.fromJson(this.key, Map data) {
    fullName = data['fullName'];
    companyName = data['company_name'];
    companyPlan = data['company_plan'];
    coverImageUrl = data['coverImageUrl'];
    dateOfBirth = data['date_of_birth'];
    email = data['email'];
    user_token = data['user_token'];
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
    if (user_token == null) {
      user_token = "";
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

class FirebaseTodos {
  /// FirebaseTodos.getTodoStream("-KriJ8Sg4lWIoNswKWc4", _updateTodo)
  /// .then((StreamSubscription s) => _subscriptionTodo = s);
  static Future<StreamSubscription<Event>> getUsertream(
      void onData(UserData user)) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    String userUID = _auth.currentUser.uid;

    StreamSubscription<Event> subscription = FirebaseDatabase.instance
        .reference()
        .child("User_Profiles")
        .child(userUID)
        .onValue
        .listen((Event event) {
      var userData =
          new UserData.fromJson(event.snapshot.key, event.snapshot.value);
      onData(userData);
    });

    return subscription;
  }
}
