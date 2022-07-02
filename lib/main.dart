import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:newproject/deliveryagent/delivery_agent_home_screen.dart';
import 'package:newproject/ngoadmin/ngo_admin_home_screen.dart';
import 'package:newproject/orphanage/orphanage_admin_home_screen.dart';
import 'package:newproject/restaurant_admin_home_screen.dart';
import 'package:newproject/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userName = prefs.getString('userName');
  var userType = prefs.getString('userType');
  runApp(MyApp(userName: userName,userType:userType ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.userName,required this.userType}) : super(key: key);
  final String? userName;
  final String? userType;

  @override
  Widget build(BuildContext context) {
    if(userType==null || userName==null) {
      return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LandingPage()
      );
    }
    else if(userType!=null && userName!=null)
      {
        if(userType == "RestaurantAdmin")
          {
            return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: RestaurantAdminHomeScreen(userName: userName));
          }
        else if(userType == "NgoAdmin")
          {
            return MaterialApp(
                debugShowCheckedModeBanner: false,
                home:NGOAdminHomeScreen(userName: userName));
          }
        else if(userType == "DeliveryAgent")
          {
            return MaterialApp(
                debugShowCheckedModeBanner: false,
                home:DeliveryAgentHomeScreen(userName: userName));
          }
        else if(userType == "OrphanageAdmin")
          {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: OrphanageAdminHomeScreen(userName: userName),);
          }
      }
      return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LandingPage());
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  TypeOfLogin typeOfLogin = TypeOfLogin.ngoAdmin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Please Select the type of Login"),
              SizedBox(
                height: 100,
                child: DropdownButton<TypeOfLogin>(
                    value: typeOfLogin,
                    items: [
                      DropdownMenuItem<TypeOfLogin>(
                          onTap: () => setState(() {
                                typeOfLogin = TypeOfLogin.ngoAdmin;
                              }),
                          value: TypeOfLogin.ngoAdmin,
                          child: const Text("NGO Admin")),
                      DropdownMenuItem<TypeOfLogin>(
                          onTap: () => setState(() {
                                typeOfLogin = TypeOfLogin.restaurantAdmin;
                              }),
                          value: TypeOfLogin.restaurantAdmin,
                          child: const Text("Restaurant Admin")),
                      DropdownMenuItem<TypeOfLogin>(
                          onTap: () => setState(() {
                                typeOfLogin = TypeOfLogin.deliveryAgent;
                              }),
                          value: TypeOfLogin.deliveryAgent,
                          child: const Text("Delivery Agent")),
                      DropdownMenuItem<TypeOfLogin>(
                          onTap: () => setState(() {
                            typeOfLogin = TypeOfLogin.orphanageAdmin;
                          }),
                          value: TypeOfLogin.orphanageAdmin,
                          child: const Text("Orphanage Admin"))
                    ],
                    onChanged: (value) {}),
              ),
              ElevatedButton(
                  onPressed: () {
                    signup(context, typeOfLogin);
                  },
                  child: Row(children: [
                    SvgPicture.asset('assets/images/google_icon.svg'),
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      "Sign In With Google",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ])),
            ],
          ),
        ),
      ),
    );
  }
}
