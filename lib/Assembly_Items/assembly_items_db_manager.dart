import 'dart:async';

import 'package:crafted_manager/Models/assembly_item_model.dart';
import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/Products/product_db_manager.dart';
import 'package:postgres/postgres.dart';

class AssemblyItemsPostgres {
  static Future<PostgreSQLConnection> _createConnection() async {
    final connection = PostgreSQLConnection(
      'web.craftedsolutions.co',
      5432,
      'craftedmanager_db',
      username: 'craftedmanager_dbuser',
      password: '!!Laganga1983',
    );
    await connection.open();
    return connection;
  }

  Future<void> closeConnection(PostgreSQLConnection connection) async {
    await connection.close();
  }

  Future<void> addAssemblyItem(
      AssemblyItem assemblyItem, Product product) async {
    final connection = await _createConnection();

    try {
      await ProductPostgres.addProduct(product);

      await connection.execute(
        'INSERT INTO assembled_items (product_id, ingredient_id, quantity, unit) VALUES (@product_id, @ingredient_id, @quantity, @unit)',
        substitutionValues: {
          'product_id': product.id,
          'ingredient_id': assemblyItem.productId,
          'quantity': assemblyItem.quantity,
          'unit': assemblyItem.unit,
        },
      );
    } catch (e) {
      print('Error adding assembly item: $e');
    } finally {
      await closeConnection(connection);
    }

// Add your update, delete, and query methods for assembly items here
    // Update assembly item
    Future<void> updateAssemblyItem(AssemblyItem assemblyItem) async {
      final connection = await _createConnection();

      try {
        await connection.execute(
          'UPDATE assembled_items SET product_id = @product_id, ingredient_id = @ingredient_id, quantity = @quantity, unit = @unit WHERE id = @id',
          substitutionValues: {
            'id': assemblyItem.id,
            'product_id': assemblyItem.productId,
            'ingredient_id': assemblyItem.ingredientId,
            'quantity': assemblyItem.quantity,
            'unit': assemblyItem.unit,
          },
        );
      } catch (e) {
        print('Error updating assembly item: $e');
      } finally {
        await closeConnection(connection);
      }
    }

    // Delete assembly item
    Future<void> deleteAssemblyItem(int id) async {
      final connection = await _createConnection();

      try {
        await connection.execute(
          'DELETE FROM assembled_items WHERE id = @id',
          substitutionValues: {
            'id': id,
          },
        );
      } catch (e) {
        print('Error deleting assembly item: $e');
      } finally {
        await closeConnection(connection);
      }
    }

    // Get assembly items by product id
    Future<List<AssemblyItem>> getAssemblyItemsByProductId(
        int productId) async {
      final connection = await _createConnection();
      final results = await connection.query(
        'SELECT * FROM assembled_items WHERE product_id = @product_id',
        substitutionValues: {
          'product_id': productId,
        },
      );
      await closeConnection(connection);
      return results
          .map((row) => AssemblyItem.fromMap(row.toColumnMap()))
          .toList();
    }
  }
}
