import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndividualOrder extends StatefulWidget {
  final double latitude;
  final double destinationLatitude;
  final double longitude;
  final double destinationLongitude;
  final String foodTitle;
  final String address;
  final String destinationAddress;
  final String foodBody;
  final String destinationName;
  final String restaurantName;
  final String restaurantId;
  final String orderNumber;
  final String destinationId;


  const IndividualOrder({Key? key,
    required this.restaurantName,
    required this.orderNumber,
    required this.destinationLatitude,
    required this.destinationAddress,
    required this.destinationLongitude,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.foodBody,
    required this.destinationName,
    required this.foodTitle,
    required this.destinationId,
  required this.restaurantId
  })
      : super(key: key);

  @override
  State<IndividualOrder> createState() => _IndividualOrderState();
}

class _IndividualOrderState extends State<IndividualOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Food Details",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(
              height: 4,
            ),
            const Text("Food Title is:", style: TextStyle(fontSize: 18, color: Colors.green),),
            Text(
              widget.foodTitle,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(
              height: 4,
            ),
            const Text("Food Details are:", style: TextStyle(fontSize: 18, color: Colors.green),),
            const SizedBox(
              height: 4,
            ),
            Text(widget.foodBody),
            const SizedBox(
              height: 8,
            ),
            const Text("Restaurant Name is:", style: TextStyle(fontSize: 18, color: Colors.green),),
            Text(widget.restaurantName),
            const SizedBox(
              height: 4,
            ),
            const SizedBox(
              height: 8,
            ),
            const Text("Restaurant Address is:", style: TextStyle(fontSize: 18, color: Colors.green),),
            const SizedBox(
              height: 4,
            ),
            Text(widget.address),
            const SizedBox(
              height: 8,
            ),
            const Text("OR Tap On below button to show Directions"),
            ElevatedButton(
                onPressed: () async {
                  var isAvailable = await MapLauncher.isMapAvailable(MapType.google);
                  if (isAvailable != null && isAvailable) {
                    await MapLauncher.showDirections(
                      mapType: MapType.google,
                      destination: Coords(widget.latitude, widget.longitude),
                    );
                  }
                },
                child: const Text("Show Directions")),
            const Text("Destination Name is:", style: TextStyle(fontSize: 18, color: Colors.green),),
            const SizedBox(
              height: 4,
            ),
            Text(widget.destinationName),
            const Text("Destination Address is:", style: TextStyle(fontSize: 18, color: Colors.green),),
            const SizedBox(
              height: 4,
            ),
            Text(widget.destinationAddress),
            const SizedBox(
              height: 8,
            ),
            const Text("OR Tap On below button to show Directions"),
            ElevatedButton(
                onPressed: () async {
                  var isAvailable = await MapLauncher.isMapAvailable(MapType.google);
                  if (isAvailable != null && isAvailable) {
                    await MapLauncher.showDirections(
                      mapType: MapType.google,
                      destination: Coords(widget.destinationLatitude, widget.destinationLongitude),
                    );
                  }
                },
                child: const Text("Show Directions")),
            const SizedBox(height: 20,),
            ElevatedButton(onPressed: ()async{
              var ref2 = FirebaseFirestore.instance
                  .collection('allorders')
                  .doc(widget.restaurantId)
                  .collection('orders')
                  .doc(widget.orderNumber);
              ref2.update({
                "status":"Delivered"
              });
              print("Done1");
              var receivedOrdersReference = FirebaseFirestore.instance
                  .collection('Orphanages')
                  .doc(widget.destinationId)
                  .collection('receivedOrders').doc(widget.orderNumber);
              print("Done2 with${widget.destinationId+"  "+widget.orderNumber}");
              receivedOrdersReference.update({
                "status":"Delivered"
              });
              SharedPreferences sharedPrefs= await SharedPreferences.getInstance();
              var userId= sharedPrefs.getString('userId');
              var ref3= FirebaseFirestore.instance.collection('DeliveryAgents').doc(userId).collection('assignedOrders').doc(widget.orderNumber).update({
                "status":"Delivered"
              });
            }, child: const Text("Delivered"))
          ],
        ),
      ),
    );
  }
}
