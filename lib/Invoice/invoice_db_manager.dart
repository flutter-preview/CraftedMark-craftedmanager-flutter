import 'package:crafted_manager/Models/invoice_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Orders/orders_db_manager.dart';
import 'package:postgres/postgres.dart';

class InvoicePostgres {
  static Future<PostgreSQLConnection> openConnection() async {
    print('Opening connection...');
    final connection = PostgreSQLConnection(
      'web.craftedsolutions.co', // Database host
      5432, // Port number
      'craftedmanager_db', // Database name
      username: 'craftedmanager_dbuser', // Database username
      password: '!!Laganga1983', // Database password
    );
    await connection.open();
    print('Connection opened');
    return connection;
  }

  static Future<void> closeConnection(PostgreSQLConnection connection) async {
    print('Closing connection...');
    await connection.close();
    print('Connection closed');
  }

  Future<void> createInvoice(Invoice invoice) async {
    final connection = await InvoicePostgres.openConnection();

    try {
      await connection.transaction((ctx) async {
        final resultInvoice = await ctx.query('''
INSERT INTO invoices (id, order_id, invoice_date, due_date, status)
VALUES (@id, @order_id, @invoiceDate, @dueDate, @status)
''', substitutionValues: {
          'id': invoice.id,
          'order_id': invoice.order.id,
          'invoiceDate': invoice.invoiceDate.toIso8601String(),
          'dueDate': invoice.dueDate.toIso8601String(),
          'status': invoice.status,
        });

        print('Invoice inserted. Result: $resultInvoice');

        // Insert ordered items associated with the invoice
        for (OrderedItem item in invoice.orderedItems) {
          await ctx.query('''
INSERT INTO ordered_items (invoice_id, product_id, quantity, price, discount, description)
VALUES (@invoice_id, @productId, @quantity, @price, @discount, @description)
''', substitutionValues: {
            'invoice_id': invoice.id,
            ...item.toMap(),
          });
        }
        print('Ordered items inserted with invoice');
      });
    } catch (e) {
      print('Error creating invoice: ${e.toString()}');
    } finally {
      await OrderPostgres.closeConnection(connection);
    }
  }

  Future<Invoice?> getInvoiceById(String id) async {
    try {
      final connection = await InvoicePostgres.openConnection();

      final results = await connection.mappedResultsQuery('''
SELECT * FROM invoices WHERE id = @id
''', substitutionValues: {
        'id': id,
      });

      if (results.isNotEmpty) {
        final row = results.first['invoices'];
        final orderId = row?['order_id'];
        final order = await InvoicePostgres.getOrderById(orderId);
        if (order != null) {
          // Get the ordered items associated with the invoice
          final orderedItemsResults = await connection.mappedResultsQuery('''
SELECT * FROM ordered_items WHERE invoice_id = @invoice_id
''', substitutionValues: {
            'invoice_id': id,
          });

          List<OrderedItem> orderedItems = [];
          for (var itemRow in orderedItemsResults) {
            orderedItems.add(OrderedItem.fromMap(itemRow['ordered_items']!));
          }

          // Build the Invoice object with associated ordered items
          final invoice = Invoice.fromJson({
            ...row!,
            'order': order.toJson(),
            'ordered_items': orderedItems.map((item) => item.toJson()).toList(),
          });

          return invoice;
        }
      }
      await InvoicePostgres.closeConnection(connection);
    } catch (e) {
      print(e.toString());
      return null;
    }
    return null;
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final connection = await InvoicePostgres.openConnection();

    try {
      await connection.transaction((ctx) async {
        await ctx.query('''
UPDATE invoices
SET order_id = @order_id, invoice_date = @invoiceDate, due_date = @dueDate, status = @status
WHERE id = @id
''', substitutionValues: {
          'id': invoice.id,
          'order_id': invoice.order.id,
          'invoiceDate': invoice.invoiceDate.toIso8601String(),
          'dueDate': invoice.dueDate.toIso8601String(),
          'status': invoice.status,
        });

        print('Invoice updated');

        // Delete existing ordered items for this invoice
        await ctx.query('''
          DELETE FROM ordered_items WHERE invoice_id = @invoice_id
        ''', substitutionValues: {
          'invoice_id': invoice.id,
        });
        print('Existing ordered items deleted');

        // Insert updated ordered items associated with the invoice
        for (OrderedItem item in invoice.orderedItems) {
          await ctx.query('''
INSERT INTO ordered_items (invoice_id, product_id, quantity, price, discount, description)
VALUES (@invoice_id, @productId, @quantity, @price, @discount, @description)
''', substitutionValues: {
            'invoice_id': invoice.id,
            ...item.toMap(),
          });
        }
        print('Updated ordered items inserted with invoice');
      });
    } catch (e) {
      print('Error updating invoice: ${e.toString()}');
    } finally {
      await OrderPostgres.closeConnection(connection);
    }
  }

  Future<void> deleteInvoice(int id) async {
    final connection = await OrderPostgres.openConnection();

    try {
      await connection.transaction((ctx) async {
        // Delete ordered items for this invoice
        await ctx.query('''
        DELETE FROM ordered_items WHERE invoice_id = @invoice_id
      ''', substitutionValues: {
          'invoice_id': id,
        });

        // Delete invoice from invoices table
        await ctx.query('''
        DELETE FROM invoices WHERE id = @id
      ''', substitutionValues: {
          'id': id,
        });

        print('Invoice and associated ordered items deleted');
      });
    } catch (e) {
      print('Error deleting invoice: ${e.toString()}');
    } finally {
      await OrderPostgres.closeConnection(connection);
    }
  }

// Additional helper methods if needed
// ...
}
