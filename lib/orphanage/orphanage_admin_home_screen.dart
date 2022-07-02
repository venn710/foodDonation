import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:newproject/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OrphanageAdminHomeScreen extends StatefulWidget {
  const OrphanageAdminHomeScreen({Key? key, required this.userName}) : super(key: key);
  final String? userName;

  @override
  State<OrphanageAdminHomeScreen> createState() => _OrphanageAdminHomeScreenState();
}

class _OrphanageAdminHomeScreenState extends State<OrphanageAdminHomeScreen> {
  String orphanageId = "";
  String orphanageName = "";
  bool isLoading = true;
  TextEditingController orphanageNameController = TextEditingController();
  TextEditingController orphanageAddressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future getOrphanageDetails() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var userId = sharedPreferences.getString('userId');
    var documentReference = (FirebaseFirestore.instance.collection('Orphanages').doc(userId));
    var documentData = await documentReference.get();
    if (documentData.exists) {
      print(documentData.data());
      setState(() {
        isLoading = false;
        orphanageName = documentData.data()?['orphanageName'];
        orphanageId = userId.toString();
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getOrphanageDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OrphanageAdmin"),
      ),
      body: (isLoading)
          ? (const CircularProgressIndicator())
          : (orphanageName.isNotEmpty && orphanageId.isNotEmpty)
              ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Welcome $orphanageName",style: TextStyle(fontSize: 20,color: Colors.black38),),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Orphanages')
                              .doc(orphanageId)
                              .collection('receivedOrders')
                              .orderBy('timeOfGeneration', descending: true)
                              .snapshots(),
                          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else {
                              if (snapshot.hasData) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                                  child: ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(snapshot.data?.docs[index]['title'],style: TextStyle(color: Colors.blueGrey,fontSize: 18),),
                                            Text(snapshot.data?.docs[index]['body'],style: TextStyle(color: Colors.blue,fontSize: 18),),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text("Donor:: ${snapshot.data?.docs[index]['restaurantName']}",style: TextStyle(color: Colors.green,fontSize: 16),),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text("Donor Address:: ${snapshot.data?.docs[index]['address']}",style: TextStyle(color: Colors.green,fontSize: 16),),
                                            Row(
                                              children: [
                                                const Text('Status::  ',style: TextStyle(fontSize: 16),),
                                                Text(snapshot.data?.docs[index]['status'] ?? " ",style: TextStyle(color: Colors.teal),),
                                              ],
                                            ),
                                            (snapshot.data?.docs[index]['status'] != "InQueue")
                                                ? GestureDetector(
                                                onTap: () async {
                                                  await launchUrl(Uri(scheme: 'tel', path: snapshot.data?.docs[index]['agentMobileNumber'].toString()));
                                                },
                                                child: Text("Call The Agent: ${snapshot.data?.docs[index]['agentMobileNumber']}",style: TextStyle(fontSize: 16),))
                                                : Container()
                                          ],
                                        );
                                      },
                                      separatorBuilder: (context, index1) {
                                        return const Divider(
                                          height: 20,
                                          thickness: 1,
                                        );
                                      },
                                      itemCount: snapshot.data?.size ?? 0),
                                );
                              } else if (snapshot.hasError) {
                                return Text(snapshot.error.toString());
                              }
                            }
                            return Container();
                          }),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        await GoogleSignIn().disconnect();
                      }on PlatformException{
                        await FirebaseAuth.instance.signOut();
                      }
                      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                      sharedPreferences.clear();
                      if (mounted) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
                          return const LandingPage();
                        }));
                      }
                    },
                    child: const Text("Log Out"),
                  )
                ],
              )
              : Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextFormField(
                            controller: orphanageNameController,
                            decoration: InputDecoration(
                              hintText: "Enter Orphanage Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              label: const Text("Orphanage Name"),
                            ), validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter Orphanage name';
                              }
                              return null;}),
                        const SizedBox(height: 10,),
                        TextFormField(
                            controller: orphanageAddressController,
                            decoration: InputDecoration(
                              hintText: "Enter Orphanage Address",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              label: const Text("Orphanage Address"),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter Orphanage orphanageAddress';
                              }
                              return null;}),
                        ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                Location location = Location();
                                location.requestPermission();
                                var locationData = await location.getLocation();
                                var userName = widget.userName.toString();
                                SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                                var documentReference =
                                    (FirebaseFirestore.instance.collection('Orphanages').doc(sharedPreferences.getString('userId')));
                                documentReference.set({
                                  'latitude': locationData.latitude,
                                  'longitude': locationData.longitude,
                                  'orphanageName': orphanageNameController.value.text,
                                  'orphanageAddress': orphanageAddressController.value.text
                                });
                                getOrphanageDetails();
                              }
                            },
                            child: const Text("Proceed"))
                      ],
                    ),
                  )),);}}
