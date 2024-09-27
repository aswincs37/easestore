import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          // Check if still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if there is no data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders available.'));
          }

          // Display the orders in a ListView
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];
              List items = order['items'] ?? [];
              double totalAmount = order['totalAmount'] ?? 0.0;
              String userId = order['userId'] ?? 'Unknown User';
              String orderStatus = order['status'] ?? 'Packed';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: ${order.id}'),
                      Text('User ID: $userId'),
                      Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}'),
                      const SizedBox(height: 10),
                      const Text('Items:'),
                      ...items.map((item) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product ID: ${item['productId']}', // Display product ID
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${item['productName']} (Qty: ${item['quantity']}) - ₹${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                            ),
                          ],
                        );
                      }).toList(),
                      const SizedBox(height: 10),
                      const Text('Status:'),
                      OrderStatusCheckbox(
                        orderId: order.id,
                        currentStatus: orderStatus,
                      ),
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

class OrderStatusCheckbox extends StatefulWidget {
  final String orderId;
  final String currentStatus;

  const OrderStatusCheckbox({
    Key? key,
    required this.orderId,
    required this.currentStatus,
  }) : super(key: key);

  @override
  _OrderStatusCheckboxState createState() => _OrderStatusCheckboxState();
}

class _OrderStatusCheckboxState extends State<OrderStatusCheckbox> {
  bool isPacked = false;
  bool isShipped = false;
  bool isDelivered = false;

  @override
  void initState() {
    super.initState();
    // Set initial checkbox values based on current order status
    setStatus(widget.currentStatus);
  }

  void setStatus(String status) {
    setState(() {
      if (status == 'Packed') {
        isPacked = true;
        isShipped = false;
        isDelivered = false;
      } else if (status == 'Shipped') {
        isPacked = true;
        isShipped = true;
        isDelivered = false;
      } else if (status == 'Delivered') {
        isPacked = true;
        isShipped = true;
        isDelivered = true;
      }
    });
  }

  Future<void> updateOrderStatus(String newStatus) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .update({'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Packed'),
          value: isPacked,
          onChanged: (bool? value) {
            if (value == true) {
              setStatus('Packed');
              updateOrderStatus('Packed');
            }
          },
        ),
        CheckboxListTile(
          title: const Text('Shipped'),
          value: isShipped,
          onChanged: isPacked
              ? (bool? value) {
                  if (value == true) {
                    setStatus('Shipped');
                    updateOrderStatus('Shipped');
                  }
                }
              : null, // Only enable if 'Packed' is checked
        ),
        CheckboxListTile(
          title: const Text('Delivered'),
          value: isDelivered,
          onChanged: isShipped
              ? (bool? value) {
                  if (value == true) {
                    setStatus('Delivered');
                    updateOrderStatus('Delivered');
                  }
                }
              : null, // Only enable if 'Shipped' is checked
        ),
      ],
    );
  }
}
