import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class ProductUploadPage extends StatefulWidget {
  static const String id = '\productScreen';

  @override
  _ProductUploadPageState createState() => _ProductUploadPageState();
}

class _ProductUploadPageState extends State<ProductUploadPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<String> categories = ['Electronics', 'Clothing', 'Books', 'Toys'];
  String selectedCategory = 'Electronics';

  final List<String> imagesUrl = [];
  List<Uint8List> images = [];
  final TextEditingController _sizeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _categoryList = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String prouctName;
  late num price;
  late num discountPrice;
  late String description;
  String? _selectedCategory; // Initialize with a default value
  List<String> _sizeList = [];
  bool _entered = false;
  String? fileName;
  bool _isSave = false;

  final String apiKey = 'mLq1RQ3tbsna8my9oZG9vkNj';
  FilePickerResult? result;

  // upload image
  // upload image
  // upload image
  uploadImage() async {
    for (var selectedImage in images) {
      Reference ref = _storage.ref().child('productImages').child(Uuid().v4());

      await ref.putData(selectedImage).whenComplete(() async {
        await ref.getDownloadURL().then((value) {
          setState(() {
            imagesUrl.add(value);
          });
        });
      });
    }
  }

  bool _isUploading = false;

// upload data to cloud
  uploadData() async {
    setState(() {
      _isUploading = true;
    });

    // Check if there are processed images in the imagesUrl list
    if (imagesUrl.isNotEmpty) {
      final productId = Uuid().v4();

      await _firestore.collection('products').doc(productId).set({
        'productId': productId,
        'category': _selectedCategory,
        'productSize': _sizeList,
        'productName': prouctName,
        'price': price,
        'discountPrice': discountPrice,
        'description': description,
        'productImages': imagesUrl,
        "salesCount": 0,
        'totalReviews': 0,
        'popular': false,
        'recommened': true,
      }).whenComplete(() {
        _formKey.currentState!.reset();
        imagesUrl.clear();
        setState(() {
          _isUploading = false;
        });
      });
    } else {
      // Handle the case where there are no processed images
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('No processed images to upload. Please select an image')));
    }
  }

  bool _isRemovingBackground = false; // Add this flag

  Future<void> pickImage() async {
    setState(() {
      _isRemovingBackground =
          true; // Set the flag when background removal starts
    });
    result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      for (var file in result!.files) {
        Uint8List? fileBytes = file.bytes;

        if (fileBytes != null) {
          Uint8List? outputImage =
              await removeBackground(fileBytes).whenComplete(() {
            setState(() {
              _isRemovingBackground =
                  false; // Reset the flag when background removal completes
            });
          });

          if (outputImage != null) {
            img.Image? decodedImage = img.decodeImage(outputImage);

            if (decodedImage != null) {
              print('Image Format: ${decodedImage.format}');
            }

            String imageUrl =
                await uploadImageToStorage(outputImage, file.name);

            setState(() {
              // Add the selected image to the images list
              images.add(outputImage);
              imagesUrl.add(imageUrl);
            });
          } else {
            print('Error: Image not processed');
          }
        } else {
          print('Error: File bytes are null.');
        }
      }
    }
  }

  Future<String> uploadImageToStorage(Uint8List image, String imageName) async {
    try {
      // Append '.png' to the image name
      String imageNameWithExtension = Uuid().v4() + '_' + imageName + '.png';
      Reference ref = _storage.ref().child('pm').child(imageNameWithExtension);

      // Set the content type to 'image/png' explicitly
      final metadata = SettableMetadata(contentType: 'image/png');
      await ref.putData(image, metadata);

      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<Uint8List?> removeBackground(Uint8List inputImage) async {
    String base64Image = base64Encode(inputImage);

    try {
      final response = await http.post(
        Uri.parse('https://api.remove.bg/v1.0/removebg'),
        headers: {
          'X-Api-Key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image_file_b64': base64Image,
          'size': 'regular',
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Background removal successful')));
        print('Background removal successful');

        return response.bodyBytes;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error removing background: $e');
      return null;
    }
  }

  _getCategories() {
    return _firestore
        .collection('categories')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          _categoryList.add(doc['categoryName']);
        });
      });
    });
  }

  @override
  void initState() {
    _getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Product Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  buildInputField(
                    'Product Name',
                    TextInputType.text,
                    (value) {
                      prouctName = value;
                    },
                    (value) {
                      if (value!.isEmpty) {
                        return "Please enter a product name";
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: buildInputField(
                          'Price',
                          TextInputType.number,
                          (value) {
                            price = double.parse(value);
                          },
                          (value) {
                            if (value!.isEmpty) {
                              return "Please enter a price";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: buildDropdownField('Category'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  buildInputField(
                    'Discount Price',
                    TextInputType.number,
                    (value) {
                      discountPrice = int.parse(value);
                    },
                    (value) {
                      if (value!.isEmpty) {
                        return "Please enter a discount price";
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  buildInputField('Description', TextInputType.multiline,
                      (value) {
                    description = value;
                  }, (value) {
                    if (value!.isEmpty) {
                      return "Please enter a description";
                    } else {
                      return null;
                    }
                  }, maxLines: 3),
                  SizedBox(height: 16),
                  // Product Sizes

                  if (_selectedCategory != "Electronics")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: Container(
                            child: TextFormField(
                              controller: _sizeController,
                              onChanged: (value) {
                                setState(() {
                                  _entered = true;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Add Size',
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                              ),
                              keyboardType: TextInputType.text,
                              maxLines: 3,
                            ),
                          ),
                        ),
                        _entered == true
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade900,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _sizeList.add(_sizeController.text);
                                    _sizeController.clear();
                                    _entered = false;
                                  });
                                },
                                child: Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Text(''),
                      ],
                    ),
                  if (_sizeList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _sizeList.length,
                          itemBuilder: ((context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _sizeList.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade800,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      _sizeList[index],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  if (_sizeList.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isSave = true;
                        });
                      },
                      child: Text(
                        _isSave ? 'Saved' : 'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  SizedBox(height: 32),
                  Container(
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: images.length + 1,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: ((context, index) {
                        return index == 0
                            ? Center(
                                child: _isRemovingBackground
                                    ? CircularProgressIndicator()
                                    : IconButton(
                                        onPressed: pickImage,
                                        icon: Icon(Icons.add),
                                      ),
                              )
                            : Image.memory(
                                images[index - 1],
                                fit: BoxFit.cover,
                              );
                      }),
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await uploadData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Fields must not be empty')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isUploading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Upload Product',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField(
    String labelText,
    TextInputType keyboardType,
    void Function(String)? onChanged,
    String? Function(String?)? validator, {
    int? maxLines,
  }) {
    return TextFormField(
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget buildDropdownField(String labelText) {
    return DropdownButtonFormField(
      value: _selectedCategory,
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
      items: _categoryList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
    );
  }
}
