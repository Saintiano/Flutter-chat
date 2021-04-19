import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserChat {
  String key;
  String company_name;
  String company_plan;
  String coverImageUrl;
  String date_of_birth;
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

  UserChat(
    this.userId,
    this.username,
    this.status,
    this.company_name,
    this.company_plan,
    this.date_of_birth,
    this.state,
    this.sex,
    this.profileImageUrl,
    this.profession,
    this.policNumber,
    this.phoneNumber,
    this.onlineStatus,
    this.maritalStatus,
    this.houseAddress,
    this.fullName,
    this.email,
    this.coverImageUrl,
  );

  UserChat.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        fullName = snapshot.value['fullName'],
        company_name = snapshot.value['company_name'],
        company_plan = snapshot.value['company_plan'],
        coverImageUrl = snapshot.value['coverImageUrl'],
        date_of_birth = snapshot.value['date_of_birth'],
        email = snapshot.value['email'],
        houseAddress = snapshot.value['houseAddress'],
        maritalStatus = snapshot.value['maritalStatus'],
        onlineStatus = snapshot.value['onlineStatus'],
        phoneNumber = snapshot.value['phoneNumber'],
        policNumber = snapshot.value['policNumber'],
        profession = snapshot.value['profession'],
        profileImageUrl = snapshot.value['profileImageUrl'],
        sex = snapshot.value['sex'],
        state = snapshot.value['state'],
        status = snapshot.value['status'],
        userId = snapshot.value['userId'],
        username = snapshot.value['username'];

  toJson() {
    return {
      "fullName": fullName,
      "userId": userId,
      "username": username,
      "company_plan": company_plan,
      "company_name": company_name,
      "coverImageUrl": coverImageUrl,
      "date_of_birth": date_of_birth,
      "email": email,
      "houseAddress": houseAddress,
      "maritalStatus": maritalStatus,
      "onlineStatus": onlineStatus,
      "phoneNumber": phoneNumber,
      "policNumber": policNumber,
      "profession": profession,
      "profileImageUrl": profileImageUrl,
      "sex": sex,
      "state": state,
      "status": status,
    };
  }
}
