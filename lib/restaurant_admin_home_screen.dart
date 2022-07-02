import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:newproject/main.dart';
import 'package:newproject/newticket.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class RestaurantAdminHomeScreen extends StatefulWidget {
  const RestaurantAdminHomeScreen({Key? key, required this.userName}) : super(key: key);
  final String? userName;

  @override
  State<RestaurantAdminHomeScreen> createState() => _RestaurantAdminHomeScreenState();
}

class _RestaurantAdminHomeScreenState extends State<RestaurantAdminHomeScreen> {
  String userId = "";
  String restId = "";

  Future getUid() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userId = sharedPreferences.getString('userId').toString();
    });
    bool isExists = await getRestId(userId);
    if (!isExists) {
      String restaurantId = const Uuid().v1();
      await post(Uri.parse('https://7557-117-219-201-248.in.ngrok.io/addRestaurantId/$userId'),
          body: jsonEncode({'restId': restaurantId}),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });
      setState(() {
        restId = restaurantId;
      });
    }
  }

  Future<bool> getRestId(String userId) async {
    var data = await FirebaseFirestore.instance.collection("restaurantIds").doc('allrestaurants').get();
    if (data.data() != null) {
      List finResult = data.data()?['restaurantIds'];
      print(finResult.length);
      for (int i = 0; i < finResult.length; i++) {
        print(finResult[i]['userId']);
        if (userId == finResult[i]['userId']) {
          setState(() {
            restId = (finResult[i]['restaurantId']);
          });
          return true;
        }
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    getUid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant Owner"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 4,
            ),
            const Text(
              "Your Latest Donations are ::",
              style: TextStyle(color: Colors.teal),
            ),
            const SizedBox(
              height: 4,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: (restId.isEmpty)
                    ? const CircularProgressIndicator()
                    : StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('allorders').doc(restId).collection('orders').orderBy('timeOfGeneration', descending: true)
                            .snapshots(),
                        builder: ((BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                          if (snapshot.hasData) {
                            return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data?.docs[index]['title'],
                                        style: TextStyle(color: Colors.green, fontSize: 16),
                                      ),
                                      Text(
                                        snapshot.data?.docs[index]['body'],
                                        style: TextStyle(color: Colors.blue, fontSize: 16),
                                      ),
                                      const SizedBox(height: 6),
                                      (snapshot.data?.docs[index]['status'] != "InQueue")
                                          ? Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Orphanage Name: ${snapshot.data?.docs[index]['destinationName']}",
                                                  style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Text("Orphanage Address: ${snapshot.data?.docs[index]['destinationAddress']}",
                                                    style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                GestureDetector(
                                                    onTap: () async {
                                                      await launchUrl(
                                                          Uri(scheme: 'tel', path: snapshot.data?.docs[index]['agentMobileNumber'].toString()));
                                                    },
                                                    child: Text("Call The Agent: ${snapshot.data?.docs[index]['agentMobileNumber']}",
                                                        style: TextStyle(color: Colors.deepPurple, fontSize: 16))),
                                              ],
                                            )
                                          : Container(),
                                      Row(
                                        children: [
                                          const Text('Status::  ', style: TextStyle(color: Colors.black, fontSize: 16)),
                                          Text(snapshot.data?.docs[index]['status'] ?? " ", style: TextStyle(color: Colors.black54, fontSize: 16)),
                                        ],),],);},
                                separatorBuilder: (context, index1) {
                                  return const Divider(
                                    height: 20,
                                    thickness: 1,
                                  );
                                },
                                itemCount: snapshot.data?.size ?? 0);
                          } else {
                            return const CircularProgressIndicator();
                          }
                        })),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return FoodDetails(restaurantId:restId);
                  }));
                },
                child: const Text("Raise a New Ticket")),
            TextButton(
              onPressed: () async {
                await GoogleSignIn().disconnect();
                await FirebaseAuth.instance.signOut();
                SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                sharedPreferences.clear();
                if (mounted) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
                    return const LandingPage();
                  }));
                }
              },
              child: const Text("Log Out"),
            )],),),);}}
