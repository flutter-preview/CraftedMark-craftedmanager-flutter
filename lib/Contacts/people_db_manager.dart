import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Orders/database_functions.dart';
import 'package:uuid/uuid.dart';

class PeoplePostgres {
  // Fetch a customer by customerId
  static Future<People?> fetchCustomer(String customerId) async {
    final connection = await connectToPostgres();
    final result = await connection.query(
        'SELECT * FROM people WHERE id = @customerId',
        substitutionValues: {'customerId': customerId});

    await connection.close();
    return result.isNotEmpty
        ? People.fromMap(result.first.toColumnMap())
        : null;
  }

  // Refresh the customer list
  static Future<List<People>> refreshCustomerList() async {
    final connection = await connectToPostgres();
    final result = await connection.query('SELECT * FROM people');

    await connection.close();
    return result.map((row) => People.fromMap(row.toColumnMap())).toList();
  }

  static Future<People?> updateCustomer(People customer) async {
    if (customer.id.isEmpty) {
      throw Exception('Invalid UUID: Customer ID is empty');
    }

    final connection = await connectToPostgres();
    final map = customer.toMap();
    final values = <String>[];
    map.forEach((key, value) {
      // Skip updating createdby, updatedby, and null timestamp columns
      if (key != "createdby" &&
          key != "updatedby" &&
          !(value == null && (key == "created" || key == "updated"))) {
        values.add("$key = ${value != null ? "'$value'" : 'NULL'}");
      }
    });
    final allValues = values.join(",\n");
    await connection.execute(
        "UPDATE people SET $allValues WHERE id = @customerId",
        substitutionValues: {'customerId': customer.id});

    // Fetch the updated customer data
    final result = await connection.query(
        'SELECT * FROM people WHERE id = @customerId',
        substitutionValues: {'customerId': customer.id});

    await connection.close();
    return result.isNotEmpty
        ? People.fromMap(result.first.toColumnMap())
        : null;
  }

  // Add this method in the PeoplePostgres class
  static Future<People?> fetchCustomerByDetails(
      String firstName, String lastName, String phone) async {
    final connection = await connectToPostgres();
    final result = await connection.query(
        'SELECT * FROM people WHERE firstname = @firstName OR lastname = @lastName OR phone = @phone',
        substitutionValues: {
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone
        });

    await connection.close();
    return result.isNotEmpty
        ? People.fromMap(result.first.toColumnMap())
        : null;
  }

  static Future<String> createCustomer(People customer) async {
    final connection = await connectToPostgres();
    final uuid = Uuid(); // Create a Uuid instance
    final newId = uuid.v4(); // Generate a new UUID
    final map = customer.toMap()
      ..['id'] = newId; // Update the id field with the new UUID

    final columns = map.keys.join(', ');
    final values = map.values
        .map((value) => value == null ? 'NULL' : "'${value}'")
        .join(', ');

    await connection.execute(
      "INSERT INTO people ($columns) VALUES ($values)",
    );

    await connection.close();

    return newId; // Return the new contact ID
  }
}