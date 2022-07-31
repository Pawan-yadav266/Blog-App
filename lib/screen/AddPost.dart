import 'dart:io';

import 'package:blogapp/components/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_database/firebase_database.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool showSpinner = false;

  final postRef = FirebaseDatabase.instance.reference().child('Posts');
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  FirebaseAuth _auth = FirebaseAuth.instance;

  File? _image;
  final picker = ImagePicker();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future getImageGallery() async {
    final pickFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickFile != null) {
        _image = File(pickFile.path);
      } else {
        print('no image selected');
      }
    });
  }

  Future getImageCamera() async {
    final pickFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickFile != null) {
        _image = File(pickFile.path);
      } else {
        print('no image selected');
      }
    });
  }

  void dialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Container(
              height: 120,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      getImageCamera();
                      Navigator.pop(context);
                    },
                    child: ListTile(
                      leading: Icon(Icons.camera),
                      title: Text('camera'),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      getImageGallery();
                      Navigator.pop(context);
                    },
                    child: ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('gallery'),
                    ),
                  )
                ],
              ),
            ),
          );
        });
    ;
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Upload Blogs'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    dialog(context);
                  },
                  child: Center(
                    child: Container(
                      height: 100,
                      child: _image != null
                          ? ClipRect(
                              child: Image.file(_image!.absolute,
                                  width: double.infinity,
                                  height: 100,
                                  fit: BoxFit.fill),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: double.infinity,
                              height: 100,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.blue,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Form(
                    child: Column(
                  children: [
                    TextFormField(
                      controller: titleController,
                      minLines: 1,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter post title',
                        border: OutlineInputBorder(),
                        hintStyle: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.normal),
                        labelStyle: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.normal),
                      ),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: descriptionController,
                      keyboardType: TextInputType.text,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter post Description',
                        border: OutlineInputBorder(),
                        hintStyle: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.normal),
                        labelStyle: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.normal),
                      ),
                    ),
                    SizedBox(height: 30),
                    RoundButton(
                        title: 'Upload',
                        onPressed: () async {
                          setState(() {
                            showSpinner = true;
                          });

                          try {
                            int date = DateTime.now().microsecondsSinceEpoch;

                            firebase_storage.Reference ref = firebase_storage
                                .FirebaseStorage.instance
                                .ref('blogapp$date');

                            UploadTask upladTask = ref.putFile(_image!.absolute);
                            await Future.value(upladTask);
                            var newUrl = await ref.getDownloadURL();

                            final User? user= _auth.currentUser;

                            postRef.child('Post List').child(date.toString()).set({

                              'pId':date.toString(),
                              'pImage':newUrl.toString(),
                              'pTime':date.toString(),
                              'pTitle':titleController.text.toString(),
                              'pDescription':descriptionController.text.toString(),
                              'uEmail':user?.email.toString(),
                              'uid': user?.uid.toString(),

                            }).then((value){
                              toastMessage('Post Published');
                              setState(() {
                                showSpinner = false;
                              });
                            }).onError((error, stackTrace){
                              toastMessage('error occured');
                              setState(() {
                                showSpinner=false;
                              });
                            });

                          } catch (e) {
                            toastMessage('error occured');
                            setState(() {
                              showSpinner = false;
                            });
                          }
                        })
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void toastMessage(String message) {
    Fluttertoast.showToast(
        msg: message.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }
}
