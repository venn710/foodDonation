import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:newproject/deliveryagent/individual_order.dart';
import 'package:newproject/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryAgentHomeScreen extends StatefulWidget {
  final String? userName;

  const DeliveryAgentHomeScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<DeliveryAgentHomeScreen> createState() => _DeliveryAgentHomeScreenState();
}

class _DeliveryAgentHomeScreenState extends State<DeliveryAgentHomeScreen> {
  String userId = '';
  String deliveryAgentName = "";
  TextEditingController mobileNumberController = TextEditingController();
  bool isLoading = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getLocationStatus();
    getUserId();
  }

  Future getUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userId = sharedPreferences.getString('userId').toString();
    });
    getAgentDetails(userId);
  }

  Future<bool> getAgentDetails(userId) async {
    var deliveryAgentsReference = await FirebaseFirestore.instance.collection('DeliveryAgents').doc(userId).get();
    if (deliveryAgentsReference.exists) {
      setState(() {
        deliveryAgentName = deliveryAgentsReference.data()?['userName'];
        isLoading = false;
      });
      return true;
    } else {
      setState(() {
        isLoading = false;
      });
      return false;
    }
  }

  Future getLocationStatus() async {
    Location location = Location();
    location.requestPermission();
    location.enableBackgroundMode(enable: true);
    var locationData = await location.getLocation();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var userId = sharedPreferences.getString('userId');
    if (userId != null) {
      var documentReference = (FirebaseFirestore.instance.collection('DeliveryAgents').doc(userId));
      var documentData = await documentReference.get();
      var userName = widget.userName.toString();
      if (documentData.exists) {
        var data = documentData.data() as Map<String, Object?>;
        data['longitude'] = locationData.longitude;
        data['latitude'] = locationData.latitude;
        documentReference.update(data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Orders"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text("Hai ${widget.userName}",style: const TextStyle(fontSize: 20,color: Colors.black45),),
              const Text(
                "Orders Assigned to you",
                style: TextStyle(fontSize: 20),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: (isLoading && userId.isNotEmpty)
                      ? const CircularProgressIndicator()
                      : (deliveryAgentName.isNotEmpty)
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: StreamBuilder(
                                  stream: FirebaseFirestore.instance.collection('DeliveryAgents').doc(userId).collection('assignedOrders')
                                      .orderBy('timeOfGeneration', descending: true)
                                      .snapshots(),
                                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                    if (snapshot.hasData) {
                                      return ListView.separated(
                                        physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                                  return IndividualOrder(
                                                      restaurantName: snapshot.data?.docs[index]['restaurantName'],
                                                      address: snapshot.data?.docs[index]['address'],
                                                      foodBody: snapshot.data?.docs[index]['body'],
                                                      foodTitle: snapshot.data?.docs[index]['title'],
                                                      latitude: snapshot.data?.docs[index]['latitude'],
                                                      longitude: snapshot.data?.docs[index]['longitude'],
                                                      destinationAddress: snapshot.data?.docs[index]['destinationAddress'],
                                                      destinationLatitude: snapshot.data?.docs[index]['destinationLatitude'],
                                                      destinationLongitude: snapshot.data?.docs[index]['destinationLongitude'],
                                                      destinationName: snapshot.data?.docs[index]['destinationName'],
                                                      restaurantId:snapshot.data?.docs[index]['restaurantId'],
                                                      orderNumber:snapshot.data?.docs[index]['orderNumber'],
                                                      destinationId:snapshot.data?.docs[index]['orphanageId']
                                                  );
                                                }));
                                              },
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(snapshot.data?.docs[index]['title'],style: const TextStyle(fontSize: 18,color: Colors.teal),),
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(snapshot.data?.docs[index]['body'],style: const TextStyle(fontSize: 18,color: Colors.green),),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  Visibility(
                                                      visible:(snapshot.data?.docs[index]['status'].toString()!="InQueue"),
                                                      child: Text("Status: ${snapshot.data?.docs[index]['status']}"))
                                                ],
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, state) {
                                            return const Divider(
                                              height: 20,
                                              thickness: 1,
                                            );
                                          },
                                          itemCount: snapshot.data?.docs.length ?? 0);
                                      return Text(snapshot.data?.docs[0].data().toString() as String);
                                    } else if (snapshot.hasError) {
                                      return const Center(
                                        child: Text("There is some issue please try again later"),
                                      );
                                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    return Container();
                                  }),
                            )
                          : Form(
                              key: _formKey,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  children: [
                                    TextFormField(
                                        controller: mobileNumberController,
                                        decoration: InputDecoration(
                                          hintText: "Enter Mobile Number",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          label: const Text("Mobile Number"),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Enter Mobile Number';
                                          }
                                          return null;
                                        }),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    ElevatedButton(
                                        onPressed: () async{
                                          if (_formKey.currentState!.validate()) {
                                            Location location = Location();
                                            location.requestPermission();
                                            location.enableBackgroundMode(enable: true);
                                            var locationData = await location.getLocation();
                                            var documentReference = (FirebaseFirestore.instance.collection('DeliveryAgents').doc(userId));
                                            documentReference.set({'latitude': locationData.latitude, 'longitude': locationData.longitude, 'userName': widget.userName,'mobileNumber':mobileNumberController.value.text});
                                            getAgentDetails(userId);
                                          }
                                        },
                                        child: const Text("Proceed")),
                                  ],
                                ),
                              )),
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
                child: const Text("Log Out"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
