import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class OrderWidget extends StatefulWidget {
  @override
  _OrderWidgetState createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  final Stream<QuerySnapshot> _orderStrem =
      FirebaseFirestore.instance.collection('orders').snapshots();

  Widget vendorData(Widget widget, int? flex) {
    return Expanded(
      flex: flex!,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _orderStrem,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: LinearProgressIndicator());
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: ((context, index) {
            final vendor = snapshot.data!.docs[index];
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                vendorData(
                    Container(
                      height: 50,
                      width: 50,
                      child: Image.network(
                        vendor['productImage'],
                        width: 50,
                        height: 50,
                      ),
                    ),
                    1),
                vendorData(
                    Text(
                      vendor['fullName'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    3),
                vendorData(
                    Text(
                      vendor['locality'] +
                          " " +
                          vendor['city'] +
                          vendor['state'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    2),
                vendorData(
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C55EF),
                      ),
                      onPressed: () async {
                        try {
                          // Update 'delivered' status to true and increment 'deliveredCount' in Firestore
                          await FirebaseFirestore.instance
                              .collection('orders')
                              .doc(vendor['orderId'])
                              .update({
                            'delivered': true,
                            "processing": false,
                            'deliveredCount': FieldValue.increment(1),
                          });

                          // You might want to show a confirmation message to the user
                        } catch (error) {
                          print('Error marking order as delivered: $error');
                        }
                      },
                      child: Text(
                        'mark Delivered',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    1),
                vendorData(
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .doc(vendor['orderId'])
                            .update({"delivered": false, 'processing': false});
                      },
                      child: Text(
                        'cancel',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    1),
              ],
            );
          }),
        );
      },
    );
  }
}
