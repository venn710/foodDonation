// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:newproject/deliveryagent/delivery_agent_home_screen.dart';
import 'package:newproject/ngoadmin/ngo_admin_home_screen.dart';
import 'package:newproject/orphanage/orphanage_admin_home_screen.dart';
import 'package:newproject/restaurant_admin_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

Future<void> signup(BuildContext context, TypeOfLogin typeOfLogin) async {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  print("came till here");
  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  print("came till here1");
  if (googleSignInAccount != null) {
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    UserCredential result = await auth.signInWithCredential(authCredential);
    User? user = result.user;
    print("user is $user");
    if (user != null) {
      // var restUser = await firebaseFirestore
      //     .collection('restaurantOwners')
      //     .doc(user.uid)
      //     .get();
      // bool isUserExists = restUser.exists;
      // print("USER DATA IS ${restUser.exists}");
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString("userName", user.displayName.toString());
      sharedPreferences.setString("userId", user.uid.toString());
      if (typeOfLogin == TypeOfLogin.restaurantAdmin) {
        sharedPreferences.setString('userType', "RestaurantAdmin");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return RestaurantAdminHomeScreen(userName: user.displayName);
        }));
      } else if (typeOfLogin == TypeOfLogin.deliveryAgent) {
        sharedPreferences.setString('userType', "DeliveryAgent");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return DeliveryAgentHomeScreen(
            userName: user.displayName,
          );
        }));
      } else if (typeOfLogin == TypeOfLogin.ngoAdmin) {
        sharedPreferences.setString('userType', "NgoAdmin");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return NGOAdminHomeScreen(userName: user.displayName);
        }));
      }
      else if (typeOfLogin == TypeOfLogin.orphanageAdmin) {
        sharedPreferences.setString('userType', "OrphanageAdmin");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
              return OrphanageAdminHomeScreen(userName: user.displayName);
            }));
      }
    }
  }
}

enum TypeOfLogin { deliveryAgent, ngoAdmin, restaurantAdmin,orphanageAdmin }
