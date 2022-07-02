import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class RestaurantWideDonations extends StatelessWidget {
  final String restaurantId;
  final String restaurantName;

  const RestaurantWideDonations({Key? key, required this.restaurantId, required this.restaurantName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donations"),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 8.0,
          ),
          Text("Donations from $restaurantName"),
          Expanded(
            child: SingleChildScrollView(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('allorders')
                      .doc(restaurantId)
                      .collection('orders')
                      .orderBy('timeOfGeneration', descending: true)
                      .snapshots(),
                  builder: ((BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Text(snapshot.data?.docs[index]['title']),
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                  Text(snapshot.data?.docs[index]['body']),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Visibility(
                                    visible:(snapshot.data?.docs[index]['status'].toString()!="Delivered"),
                                    replacement:const Text("Delivered",style: TextStyle(color: Colors.green,fontSize: 20),),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children:[
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: ElevatedButton(
                                                onPressed: () async {
                                                  var res = (await FirebaseFirestore.instance.collection('DeliveryAgents').get()).docs;
                                                  var res2 = (await FirebaseFirestore.instance.collection('Orphanages').get()).docs;
                                                  String name = "";
                                                  String userId = "";
                                                  String donatorName = "";
                                                  String donatorAddress = "";
                                                  String destinationName = "";
                                                  String destinationAddress = "";
                                                  double destinationLatitude = 0;
                                                  double destinationLongitude = 0;
                                                  String orphanageId = '';

                                                  String mobileNumber = "0";
                                                  double minDistance = 1000000000;
                                                  for (int i = 0; i < res.length; i++) {
                                                    double latitude = res[i].data()['latitude'];
                                                    double longitude = res[i].data()['longitude'];
                                                    double distance = (Geolocator.distanceBetween(snapshot.data?.docs[index]['latitude'],
                                                            snapshot.data?.docs[index]['longitude'], latitude, longitude)) /
                                                        1000;
                                                    if (distance < minDistance) {
                                                      minDistance = distance;
                                                      name = res[i].data()['userName'];
                                                      print("$distance for user $name");
                                                      userId = res[i].id;
                                                      mobileNumber = res[i].data()['mobileNumber'];
                                                      donatorName = snapshot.data?.docs[index]['restaurantName'];
                                                      donatorAddress = snapshot.data?.docs[index]['address'];
                                                    }
                                                  }
                                                  print("Done work1");
                                                  double minDestinationDistance = 100000000;
                                                  for (int j = 0; j < res2.length; j++) {
                                                    double latitude = res2[j].data()['latitude'];
                                                    double longitude = res2[j].data()['longitude'];
                                                    double destinationDistance = (Geolocator.distanceBetween(snapshot.data?.docs[index]['latitude'],
                                                            snapshot.data?.docs[index]['longitude'], latitude, longitude)) /
                                                        1000;
                                                    if (destinationDistance < minDestinationDistance) {
                                                      minDestinationDistance = destinationDistance;
                                                      destinationName = res2[j].data()['orphanageName'];
                                                      destinationAddress = res2[j].data()['orphanageAddress'];
                                                      destinationLatitude = res2[j].data()['latitude'];
                                                      destinationLongitude = res2[j].data()['longitude'];
                                                      orphanageId = res2[j].id;
                                                    }
                                                  }
                                                  print("userId is $userId");
                                                  print("Orphanage Id is $orphanageId");
                                                  var deliveryAgentAssignedOrderReference =
                                                      FirebaseFirestore.instance.collection('DeliveryAgents').doc(userId).collection('assignedOrders');
                                                  var receivedOrdersReference = FirebaseFirestore.instance
                                                      .collection('Orphanages')
                                                      .doc(orphanageId)
                                                      .collection('receivedOrders');
                                                  String orderNumber = snapshot.data?.docs[index]['orderNumber'];
                                                  print("orderNumber is $orderNumber");
                                                  var dataToBeSet = snapshot.data?.docs[index].data();
                                                  var dataForReceivedOrders = snapshot.data?.docs[index].data();
                                                  dataForReceivedOrders?['status']="Assigned to$name";
                                                  dataForReceivedOrders?['agentMobileNumber']=mobileNumber;
                                                  dataForReceivedOrders?['donatorName']=donatorName;
                                                  dataForReceivedOrders?['donatorAddress']=donatorAddress;
                                                  print("dataForReceivedOrders is $dataForReceivedOrders");

                                                  await receivedOrdersReference.doc(orderNumber).set(dataForReceivedOrders as Map<String, dynamic>);
                                                  dataToBeSet?['destinationName'] = destinationName;
                                                  dataToBeSet?['destinationAddress'] = destinationAddress;
                                                  dataToBeSet?['destinationLongitude'] = destinationLongitude;
                                                  dataToBeSet?['destinationLatitude'] = destinationLatitude;
                                                  dataToBeSet?['orphanageId'] = orphanageId;

                                                  await deliveryAgentAssignedOrderReference.doc(orderNumber).set(dataToBeSet as Map<String,dynamic>);
                                                  var ref2 = FirebaseFirestore.instance
                                                      .collection('allorders')
                                                      .doc(restaurantId)
                                                      .collection('orders')
                                                      .doc(orderNumber);
                                                  ref2.update({
                                                    "status": "Assigned to$name",
                                                    "agentMobileNumber": mobileNumber,
                                                    "destinationName": destinationName,
                                                    "destinationAddress": destinationAddress
                                                  });
                                                },
                                                child: const Text("Assign")),
                                          ),
                                        ),
                                        const Text('Status::  '),
                                        Center(child: Text(snapshot.data?.docs[index]['status'] ?? " ")),
                                      ],
                                    ),
                                  )
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
                    } else {
                      return const CircularProgressIndicator();
                    }
                  })),
            ),
          ),
        ],
      ),
    );
  }
}
