import 'package:flutter/material.dart';
import 'package:mac_store_web/views/screens/inner_screens/widgets/buyers_widget.dart';
import 'package:mac_store_web/views/screens/inner_screens/widgets/vendors_widget.dart';

class VendorsScreen extends StatefulWidget {
  static const String routeName = '\VendorsScreen';

  @override
  State<VendorsScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<VendorsScreen> {
  Widget _rowHeader(int flex, String text) {
    return Expanded(
        flex: flex,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade700),
            color: const Color(0xFF3C55EF),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manage Vendors',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  _rowHeader(1, 'Image'),
                  _rowHeader(3, 'Store Name'),
                  _rowHeader(2, 'Address'),
                  _rowHeader(2, 'Email'),
                  _rowHeader(1, 'VIEW MORE'),
                ],
              ),

              VendorWidget()
            ],
            
          ),
        ),
      ),
    );
  }
}
