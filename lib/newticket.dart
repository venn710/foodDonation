import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class FoodDetails extends StatefulWidget {
  final String restaurantId;
  const FoodDetails({Key? key,required this.restaurantId}) : super(key: key);

  @override
  State<FoodDetails> createState() => _FoodDetailsState();
}

class _FoodDetailsState extends State<FoodDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController restaurantNameController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController foodBodyController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Food Ticket"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                      errorMessage: "Enter Restaurant Name",
                      textEditingController: restaurantNameController,
                      hintText: "Enter Restaurant Name",
                      labelName: "Restaurant Name"),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                      errorMessage: "Enter Full Address",
                      textEditingController: addressController,
                      hintText: "Enter Full Address",
                      labelName: "Address"),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                      errorMessage: "Enter Food Details",
                      textEditingController: foodNameController,
                      hintText: "Enter Food Title",
                      labelName: "FoodTitle"),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                      errorMessage: "Enter Food Details",
                      textEditingController: foodBodyController,
                      hintText: "Enter Food Details",
                      labelName: "FoodDetails"),
                  (loading) ? const CircularProgressIndicator() : Container(),
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          DateTime dateTime = DateTime.now();
                          print(dateTime.toString());
                          Location location = Location();
                          var locData = await location.getLocation();
                          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                          var userId = sharedPreferences.getString('userId');
                          var body = jsonEncode({
                            "timeOfGeneration": dateTime.toString(),
                            "title": foodNameController.value.text,
                            "body": foodBodyController.value.text,
                            "address": addressController.value.text,
                            "latitude": locData.latitude,
                            "longitude": locData.longitude,
                            "status": "InQueue",
                            "restaurantName":restaurantNameController.value.text,
                            "restaurantId":widget.restaurantId
                          });
                          // var response = await get(Uri.parse('http://10.0.2.2:5000/getrestaurantIds'));
                          var response = await get(Uri.parse('https://7557-117-219-201-248.in.ngrok.io/getrestaurantIds'));

                          print("Work done1");
                          List finResult = (jsonDecode(response.body))['restaurantIds'];
                          String restId = "";
                          for (int i = 0; i < finResult.length; i++) {
                            print(finResult[i]['userId']);
                            if (userId == finResult[i]['userId']) {
                              restId = (finResult[i]['restaurantId']);
                            }
                          }
                          if (restId.isEmpty) {
                            restId = const Uuid().v1();
                            await post(Uri.parse('https://7557-117-219-201-248.in.ngrok.io/addRestaurantId/$userId'),
                                body: jsonEncode({"restId": restId}),
                                headers: <String, String>{
                                  'Content-Type': 'application/json; charset=UTF-8',
                                });
                          }
                          var response1 = await post(Uri.parse('https://7557-117-219-201-248.in.ngrok.io/addTicket/$restId/${restaurantNameController.value.text}'),
                              body: body,
                              headers: <String, String>{
                                'Content-Type': 'application/json; charset=UTF-8',
                              });
                          setState(() {
                            loading = false;
                          });
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: const Text("Raise Ticket"))
                ],
              )),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String errorMessage;
  final String hintText;
  final String labelName;
  final TextEditingController textEditingController;

  const CustomTextField({Key? key, required this.errorMessage, required this.textEditingController, required this.hintText, required this.labelName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: textEditingController,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          label: Text(labelName),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return errorMessage;
          }
          return null;
        });
  }
}
