import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:newproject/main.dart';
import 'package:newproject/ngoadmin/restaurant_wise_donations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NGOAdminHomeScreen extends StatefulWidget {
  const NGOAdminHomeScreen({Key? key, required this.userName}) : super(key: key);
  final String? userName;

  @override
  State<NGOAdminHomeScreen> createState() => _NGOAdminHomeScreenState();
}

class _NGOAdminHomeScreenState extends State<NGOAdminHomeScreen> {
  String? userId;

  Future getUid() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userId = sharedPreferences.getString('userId');
    });
  }

  Future<List<Map<String, String>>> getRestaurantNames() async {
    await Future.delayed(const Duration(seconds: 2));
    List<Map<String, String>> list = [];
    var response = (await FirebaseFirestore.instance.collection('allorders').get()).docs;
    for (int i = 0; i < response.length; i++) {
      var name = response[i]['restaurantName'];
      var id = response[i]['restaurantId'];
      list.add({"restaurantName": name, "restaurantId": id});
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    getUid();
    getRestaurantNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NGO User"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text("Hai ${widget.userName}",style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8.0,),
            const Text("Restaurant Names",style: TextStyle(fontSize: 18),),
            const SizedBox(height: 8.0,),
            Expanded(
              child: SingleChildScrollView(
                child: FutureBuilder<List<Map<String, String>>>(
                    future: getRestaurantNames(),
                    builder: (context, AsyncSnapshot<List<Map<String, String>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data?.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                                        return RestaurantWideDonations(
                                          restaurantId: snapshot.data?[index]['restaurantId'] ?? " ",
                                          restaurantName: snapshot.data?[index]['restaurantName'] ?? " ",
                                        );
                                      }));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: const [BoxShadow(color: Color(0x0d000000), offset: Offset(0, 2), blurRadius: 8.0)]),
                                      height: 40,
                                      child: Center(child: Text(snapshot.data?[index]['restaurantName'] ?? " ")),
                                    ),
                                  ),
                                );
                              });
                        }
                      }
                      return const Center(child: CircularProgressIndicator());
                    }),
              ),
            ),
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
              child: const Text("Log Out"),)],),),);}}
