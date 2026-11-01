import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<Product>> _productList;

  @override
  void initState() {
    super.initState();
    _refreshProductList();
  }

  void _refreshProductList() {
    setState(() {
      _productList = DatabaseHelper.instance.getProducts();
    });
  }

  void _showProductForm({Product? product}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final stockController = TextEditingController(text: product != null ? product.stock.toString() : '');
    final clientPriceController = TextEditingController(text: product != null ? product.clientPrice.toString() : '');
    final collaboratorPriceController = TextEditingController(text: product != null ? product.collaboratorPrice.toString() : '');
    final minStockController = TextEditingController(text: product != null ? product.minStock.toString() : '5');

    bool isEditing = product != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF151c2c),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Editar Producto' : 'Nuevo Producto en Inventario',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildTextField('Nombre del producto', nameController),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField('Stock actual', stockController, isNumber: true)),
                  SizedBox(width: 12),
                  Expanded(child: _buildTextField('Stock mínimo', minStockController, isNumber: true)),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField('Precio Cliente (€)', clientPriceController, isNumber: true)),
                  SizedBox(width: 12),
                  Expanded(child: _buildTextField('Precio Colaborador (€)', collaboratorPriceController, isNumber: true)),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3b82f6),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  if (nameController.text.isEmpty) return;

                  final newProduct = Product(
                    id: product?.id,
                    name: nameController.text,
                    stock: int.tryParse(stockController.text) ?? 0,
                    clientPrice: double.tryParse(clientPriceController.text) ?? 0.0,
                    collaboratorPrice: double.tryParse(collaboratorPriceController.text) ?? 0.0,
                    minStock: int.tryParse(minStockController.text) ?? 5,
                  );

                  if (isEditing) {
                    await DatabaseHelper.instance.updateProduct(newProduct);
                  } else {
                    await DatabaseHelper.instance.insertProduct(newProduct);
                  }

                  Navigator.pop(context);
                  _refreshProductList();
                },
                child: Text(isEditing ? 'Guardar Cambios' : 'Crear Producto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Color(0xFF0b0f19),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0b0f19),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF151c2c),
        title: Text('Gestión de Inventario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF3b82f6)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No hay productos registrados aún.', style: TextStyle(color: Colors.white60)),
            );
          }

          final products = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              bool isLowStock = product.stock <= product.minStock;

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Color(0xFF151c2c),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isLowStock ? Colors.redAccent.withOpacity(0.5) : Colors.transparent),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Text('Stock: ${product.stock}', style: TextStyle(color: isLowStock ? Colors.redAccent : Colors.greenAccent, fontWeight: FontWeight.bold)),
                              SizedBox(width: 12),
                              Text('Cliente: ${product.clientPrice}€', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              SizedBox(width: 8),
                              Text('Colab: ${product.collaboratorPrice}€', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Color(0xFF3b82f6)),
                      onPressed: () => _showProductForm(product: product),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        await DatabaseHelper.instance.deleteProduct(product.id!);
                        _refreshProductList();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF3b82f6),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showProductForm(),
      ),
    );
  }
}
