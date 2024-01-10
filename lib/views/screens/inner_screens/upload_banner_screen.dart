import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mac_store_web/views/screens/inner_screens/widgets/uploadBannerList_widget.dart';

class UploadBanners extends StatefulWidget {
  static const String id = '\UploadBanners';
  const UploadBanners({super.key});

  @override
  State<UploadBanners> createState() => _UploadBannersState();
}

class _UploadBannersState extends State<UploadBanners> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  dynamic _image;
  String? fileName;
  pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _image = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    }
  }

  _uploadImageToStorage(dynamic image) async {
    Reference ref =
        _firebaseStorage.ref().child('homeBanners').child(fileName!);

    UploadTask uploadTask = ref.putData(image!);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();

    return downloadUrl;
  }

  uploadToFirebase() async {
    // EasyLoading.show();
    if (_formKey.currentState!.validate()) {
      if (_image != null) {
        String imageUrl = await _uploadImageToStorage(_image);

        await _firestore.collection('banners').doc(fileName).set({
          'image': imageUrl,
        }).whenComplete(() {
          setState(() {
            _formKey.currentState!.reset();
            _image = null;

            // EasyLoading.dismiss();
          });
        });
      } else {
        // EasyLoading.dismiss();
      }
    } else {
      // EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Banners',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 36,
                    ),
                  ),
                ),
                Divider(
                  color: Colors.grey,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          Container(
                            height: 140,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade500,
                              border: Border.all(
                                color: Colors.grey.shade800,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: _image != null
                                  ? Image.memory(_image)
                                  : Text(
                                      'Banner Image',
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF3C55EF),
                            ),
                            onPressed: () {
                              pickImage();
                            },
                            child: Text(
                              'Upload  Image',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3C55EF),
                      ),
                      onPressed: uploadToFirebase,
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    )
                  ],
                ),
                Divider(
                  color: Colors.grey,
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(10),
            child: const Text(
              'banners',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 36,
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          UploadBannerList(),
        ],
      ),
    );
  }
}
