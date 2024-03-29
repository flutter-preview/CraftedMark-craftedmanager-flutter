import 'dart:async';

import 'package:crafted_manager/postgres.dart';

class OrdersPostgres {
  static Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    final connection = await connectToPostgres();
    // Replace 'orders' with your table name
    final results = await connection.query('SELECT * FROM orders');

    List<Map<String, dynamic>> orders = [];
    for (final row in results) {
      orders.add(row.toColumnMap());
    }
    print("------------------------------------");
    print("Orders received from Postgres");
    orders.forEach((o) =>print( o["order_id"]));
    print("------------------------------------");
    await connection.close();
    return orders;
  }
}
