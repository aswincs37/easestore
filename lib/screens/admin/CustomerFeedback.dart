import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFeedbackPage extends StatelessWidget {
  const AdminFeedbackPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Management'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('feedbacks').snapshots(),
        builder: (context, snapshot) {
          // Error handling
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return const Center(
              child: Text('Something went wrong. Please try again later.'),
            );
          }

          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // No feedback data found
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No feedback found.'),
            );
          }

          final feedbackDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: feedbackDocs.length,
            itemBuilder: (context, index) {
              var data = feedbackDocs[index].data() as Map<String, dynamic>?; // Ensure type safety

              // Handle missing data safely
              if (data == null) {
                return const SizedBox.shrink();
              }

              List productNames = [];
              if (data['items'] != null && data['items'] is List) {
                productNames = (data['items'] as List)
                    .map((item) => item['productName'].toString())
                    .toList();
              }

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feedback ID: ${feedbackDocs[index].id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('User ID: ${data['userId'] ?? 'N/A'}'),
                   
                      Text('Order ID: ${data['orderId'] ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      Text('Products: ${productNames.isNotEmpty ? productNames.join(', ') : 'No Products'}'),
                      const SizedBox(height: 8),
                      Text('Feedback: ${data['feedback'] ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      Text(
                        'Timestamp: ${data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString() : 'N/A'}',
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
