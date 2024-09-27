import 'package:easestore/screens/customer/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Orders',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ),
        body: const Center(
          child: Text('Please log in to view your orders.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Snapshot error: ${snapshot.error}");
            return const Center(child: Text('Something went wrong.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('You have no orders.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];
              List items = order['items'] ?? [];
              double totalAmount = order['totalAmount'] ?? 0.0;
              String status = order['status'] ?? 'N/A';

              return Card(
                color: const Color.fromARGB(255, 160, 211, 238),
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: ${order.id}'),
                      Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}'),
                      const SizedBox(height: 10),
                      const Text('Items:'),
                      ...items.map((item) {
                        return Text(
                          '${item['productName']} (Qty: ${item['quantity']}) - ₹${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                        );
                      }).toList(),
                      const SizedBox(height: 10),
                      Text(
                          'Order Date: ${order['timestamp'] != null ? (order['timestamp'] as Timestamp).toDate().toString() : 'N/A'}'),
                      Text(
                        'Status: $status',
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (status == 'Delivered')
                        FeedbackSection(
                          orderId: order.id,
                          userId: currentUser.uid,
                          items: items,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const BottomNavBar(),
              ),
              (Route<dynamic> route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Continue shopping",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.arrow_forward,
                size: 24,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeedbackSection extends StatefulWidget {
  final String orderId;
  final String userId;
  final List items;

  const FeedbackSection({
    Key? key,
    required this.orderId,
    required this.userId,
    required this.items,
  }) : super(key: key);

  @override
  _FeedbackSectionState createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Leave feedback for this product:'),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _feedbackController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write your feedback here',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your feedback';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 10),
        _isSubmitting
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isSubmitting = true;
                    });

                    try {
                      await FirebaseFirestore.instance.collection('feedbacks').add({
                        'userId': widget.userId,
                        'orderId': widget.orderId,
                        'feedback': _feedbackController.text,
                        'items': widget.items.map((item) {
                          return {
                            'productId': item['productId'],
                            'productName': item['productName'],
                          };
                        }).toList(),
                        'timestamp': Timestamp.now(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(
                            'Feedback submitted successfully!',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const BottomNavBar(),
                        ),
                      );
                    } catch (e) {
                      print('Error submitting feedback: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to submit feedback.'),
                        ),
                      );
                    } finally {
                      setState(() {
                        _isSubmitting = false;
                      });
                    }
                  }
                },
                child: const Text('Submit Feedback'),
              ),
      ],
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
