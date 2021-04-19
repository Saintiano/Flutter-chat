import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novo_health_africa_companion/bottom_navigation/home.dart';
import 'package:novo_health_africa_companion/chat/recentChat.dart';

import 'package:photo_view/photo_view.dart';

class Full_Photo extends StatefulWidget {
  @override
  _Full_PhotoState createState() => _Full_PhotoState();
}

class _Full_PhotoState extends State<Full_Photo> {
  var doctorDetails = Get.arguments;
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.to(Recent_Chat()),
        ),
        title: Center(
          child: Text(
            "Full Image",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(doctorDetails[0]),
        ),
      ),
    );
  }
}
