import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Orders/order_postgres.dart';
import 'package:crafted_manager/Orders/search_people_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../Models/people_model.dart';
import '../Models/product_model.dart';
import 'order_detail_screen.dart';
import 'ordered_item_postgres.dart';

class OrdersList extends StatefulWidget {
  const OrdersList({Key? key, required String title}) : super(key: key);

  @override
  _OrdersListState createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<OrderedItem>> fetchOrderedItems(int orderId) async {
    return await OrderedItemPostgres.fetchOrderedItems(orderId);
  }

  Future<List<Product>> fetchProducts(List<OrderedItem> orderedItems) async {
    // Implement the logic to fetch the list of products from the database based on the orderedItems list
    return [];
  }

  Future<People?> _getCustomerById(int customerId) async {
    return await PeoplePostgres.fetchCustomer(customerId);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: const Text('Orders'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => SearchPeopleScreen(),
              ),
            );
          },
          child: const Icon(
            CupertinoIcons.add,
            size: 28,
          ),
        ),
      ),
      child: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: OrderPostgres.fetchAllOrders(),
          builder: (BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasData) {
              final orders = snapshot.data!;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (BuildContext context, int index) {
                  final order = Order.fromMap(orders[index]);
                  return Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: CupertinoColors.black),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        // Fetch customer, orderedItems, and products data here
                        final customer =
                            await _getCustomerById(int.parse(order.customerId));
                        if (customer == null) {
                          return;
                        }
                        List<OrderedItem> orderedItems =
                            await fetchOrderedItems(order.id);
                        List<Product> products =
                            await fetchProducts(orderedItems);

                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => OrderDetailScreen(
                              order: order,
                              customer: customer,
                              orderedItems: orderedItems,
                              products: products,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order ID: ${order.id}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Total: \$${order.totalAmount}'),
                            Text('Status: ${order.orderStatus}'),
                            Text(
                                'Order Date: ${DateFormat('MM-dd-yyyy').format(order.orderDate)}'),
                            //Text('First Name: ${order.firstName}'),
                            //Text('Last Name: ${order.lastName}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
