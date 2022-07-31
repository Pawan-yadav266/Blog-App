import 'package:blogapp/screen/AddPost.dart';
import 'package:blogapp/screen/Signin.dart';
import 'package:blogapp/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dbRef = FirebaseDatabase.instance.reference().child('Posts');
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    if (auth.currentUser == null) {
      return LoginScreen();
    }
    return WillPopScope(
      onWillPop: ()async{
            SystemNavigator.pop();
        return true ;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('New Blogs'),
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: [
            InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddPostScreen()));
                },
                child: Icon(Icons.add)),
            SizedBox(
              width: 20,
            ),
            InkWell(
                onTap: () {
                  auth.signOut().then((value){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  });

                },
                child: Icon(Icons.logout)),

            SizedBox(
              width: 10,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Column(
            children: [
              Expanded(
                  child: FirebaseAnimatedList(
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  var value = Map<String, dynamic>.from(snapshot.value as Map);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius:  BorderRadius.circular(10)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FadeInImage.assetNetwork(
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width*1,
                                height: MediaQuery.of(context).size.height*.25,
                                placeholder: 'images/bloger.jpg',
                                image: value['pImage']),
                          ),
                          SizedBox(height: 10,),
                          Text(value['pTitle'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                          SizedBox(height: 3,),
                          Text(value['pDescription'],style:TextStyle(fontWeight: FontWeight.normal,fontSize: 15),)
                        ],

                      ),
                    ),
                  );
                },
                query: dbRef.child('Post List'),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
