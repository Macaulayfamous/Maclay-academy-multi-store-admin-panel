// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';
// import 'package:uuid/uuid.dart';

// class TestingScreen extends StatefulWidget {
//   @override
//   _TestingScreenState createState() => _TestingScreenState();
// }

// class _TestingScreenState extends State<TestingScreen> {
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<String> imagesUrl = [];
//   final String apiKey = 'MkxwUSsKqmyJ2G2i1wRMoEc6';
//   FilePickerResult? result;

//   Future<void> pickImage() async {
//     result = await FilePicker.platform.pickFiles(
//       type: FileType.image,
//       allowMultiple: true,
//     );

//     if (result != null) {
//       for (var file in result!.files) {
//         Uint8List? fileBytes = file.bytes;

//         if (fileBytes != null) {
//           Uint8List? outputImage = await removeBackground(fileBytes);

//           if (outputImage != null) {
//             img.Image? decodedImage = img.decodeImage(outputImage);

//             if (decodedImage != null) {
//               print('Image Format: ${decodedImage.format}');
//             }

//             String imageUrl =
//                 await uploadImageToStorage(outputImage, file.name!);

//             setState(() {
//               imagesUrl.add(imageUrl);
//             });
//           } else {
//             print('Error: Image not processed');
//           }
//         } else {
//           print('Error: File bytes are null.');
//         }
//       }
//     }
//   }

//   Future<Uint8List?> removeBackground(Uint8List inputImage) async {
//     String base64Image = base64Encode(inputImage);

//     try {
//       final response = await http.post(
//         Uri.parse('https://api.remove.bg/v1.0/removebg'),
//         headers: {
//           'X-Api-Key': apiKey,
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'image_file_b64': base64Image,
//           'size': 'regular',
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Background removal successful');
//         return response.bodyBytes;
//       } else {
//         print('Error: ${response.statusCode} - ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       print('Error removing background: $e');
//       return null;
//     }
//   }

//   Future<String> uploadImageToStorage(Uint8List image, String imageName) async {
//     try {
//       // Append '.png' to the image name
//       String imageNameWithExtension = Uuid().v4() + '_' + imageName + '.png';
//       Reference ref = _storage.ref().child('pm').child(imageNameWithExtension);

//       // Set the content type to 'image/png' explicitly
//       final metadata = SettableMetadata(contentType: 'image/png');
//       await ref.putData(image, metadata);

//       String imageUrl = await ref.getDownloadURL();
//       return imageUrl;
//     } catch (e) {
//       print('Error uploading image: $e');
//       return '';
//     }
//   }

//   Future<void> uploadData() async {
//     final productId = Uuid().v4();
//     await _firestore.collection('tes').doc(productId).set({
//       'productId': productId,
//       'productImages': imagesUrl,
//     });
//   }

//   Future<void> downloadUrls() async {
//     try {
//       // Get the documents directory
//       Directory documentsDirectory = await getApplicationDocumentsDirectory();

//       for (String imageUrl in imagesUrl) {
//         // Extract the filename from the URL
//         String fileName = imageUrl.split('/').last;

//         // Create the file path in the documents directory
//         String filePath = '${documentsDirectory.path}/$fileName';

//         // Download the image from the URL
//         http.Response response = await http.get(Uri.parse(imageUrl));

//         // Write the image to the file
//         File file = File(filePath);
//         await file.writeAsBytes(response.bodyBytes);

//         print('Image downloaded to: $filePath');
//       }
//     } catch (e) {
//       print('Error downloading image: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Product Upload'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: pickImage,
//               child: Text('Pick Images'),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 if (result != null) {
//                   for (var file in result!.files) {
//                     Uint8List? fileBytes = file.bytes;

//                     if (fileBytes != null) {
//                       Uint8List? outputImage =
//                           await removeBackground(fileBytes);

//                       if (outputImage != null) {
//                         img.Image? decodedImage = img.decodeImage(outputImage);

//                         if (decodedImage != null) {
//                           print('Image Format: ${decodedImage.format}');
//                         }

//                         await uploadImageToStorage(outputImage, file.name!);
//                       } else {
//                         print('Error: Image not processed');
//                       }
//                     } else {
//                       print('Error: File bytes are null.');
//                     }
//                   }
//                 }

//                 await uploadData();
//                 print('Data uploaded successfully');

//                 // Do any additional processing or navigation after upload
//               },
//               child: Text('Upload Data'),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: downloadUrls,
//               child: Text('Download URLs'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
