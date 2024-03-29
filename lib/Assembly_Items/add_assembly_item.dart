import 'package:crafted_manager/Models/assembly_item_model.dart';
import 'package:crafted_manager/Models/product_model.dart';
import 'package:flutter/material.dart';

class AddAssemblyItem extends StatefulWidget {
  @override
  _AddAssemblyItemState createState() => _AddAssemblyItemState();
}

class _AddAssemblyItemState extends State<AddAssemblyItem> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AssemblyItem _assemblyItem;

  // Example products list
  List<Product> products = [];

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    // Add your assembly item to the database here.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(color: Colors.black),
        textTheme: TextTheme(
          headline4: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          subtitle1: TextStyle(color: Colors.white),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Add Assembly Item'),
        ),
        backgroundColor: Colors.black,
        body: Container(
          padding: const EdgeInsets.only(top: 45, left: 16, right: 16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Add Assembly Item',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProductDropdown(),
                  const SizedBox(height: 16),
                  _buildIngredientDropdown(),
                  const SizedBox(height: 16),
                  _buildQuantityInput(),
                  const SizedBox(height: 16),
                  _buildUnitInput(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Create Assembly Item'),
                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDropdown() {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: 'Product',
        labelStyle: TextStyle(color: Colors.white),
      ),
      items: products.map((Product product) {
        return DropdownMenuItem(
          value: product.id,
          child: Text(
            product.name,
            style: TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: (value) {
        // Handle selected product ID here
      },
    );
  }

  Widget _buildIngredientDropdown() {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: 'Ingredient',
        labelStyle: TextStyle(color: Colors.white),
      ),
      items: products.map((Product product) {
        return DropdownMenuItem(
          value: product.id,
          child: Text(
            product.name,
            style: TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: (value) {
        // Handle selected ingredient ID here
      },
    );
  }

  Widget _buildQuantityInput() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Quantity',
        labelStyle: TextStyle(color: Colors.white),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onSaved: (String? value) {
        // Handle quantity input here
      },
    );
  }

  Widget _buildUnitInput() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Unit',
        labelStyle: TextStyle(color: Colors.white),
      ),
      onSaved: (String? value) {
        // Handle unit input here
      },
    );
  }
}
