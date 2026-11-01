import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final loadedProducts = await DatabaseHelper.instance.getProducts();
    setState(() {
      products = loadedProducts;
      isLoading = false;
    });
  }

  void _showTransactionDialog() {
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Primero debes registrar productos en el inventario.')),
      );
      return;
    }

    Product selectedProduct = products.first;
    String type = 'SALE';
    bool isCollaborator = false;
    final quantityController = TextEditingController(text: '1');
    final clientNameController = TextEditingController();
    final conceptController = TextEditingController(text: 'Venta a crédito');
    bool creditSale = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF151c2c),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double unitPrice = type == 'SALE'
                ? (isCollaborator ? selectedProduct.collaboratorPrice : selectedProduct.clientPrice)
                : selectedProduct.clientPrice;

            int qty = int.tryParse(quantityController.text) ?? 1;
            double total = unitPrice * qty;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nueva Operación',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text('Venta'),
                            selected: type == 'SALE',
                            selectedColor: Colors.greenAccent,
                            onSelected: (val) => setModalState(() => type = 'SALE'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ChoiceChip(
                            label: Text('Compra / Reposición'),
                            selected: type == 'PURCHASE',
                            selectedColor: Colors.purpleAccent,
                            onSelected: (val) => setModalState(() => type = 'PURCHASE'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<Product>(
                      value: selectedProduct,
                      dropdownColor: Color(0xFF151c2c),
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Producto',
                        labelStyle: TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: Color(0xFF0b0f19),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      items: products.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                      onChanged: (val) {
                        setModalState(() => selectedProduct = val!);
                      },
                    ),
                    SizedBox(height: 12),
                    if (type == 'SALE') ...[
                      SwitchListTile(
                        title: Text('¿Es tarifa de Colaborador?', style: TextStyle(color: Colors.white, fontSize: 14)),
                        value: isCollaborator,
                        activeColor: Color(0xFF3b82f6),
                        onChanged: (val) => setModalState(() => isCollaborator = val),
                      ),
                      SwitchListTile(
                        title: Text('Registrar en Cuentas por Cobrar (Crédito)', style: TextStyle(color: Colors.white, fontSize: 14)),
                        value: creditSale,
                        activeColor: Colors.orangeAccent,
                        onChanged: (val) => setModalState(() => creditSale = val),
                      ),
                      if (creditSale) ...[
                        SizedBox(height: 8),
                        TextField(
                          controller: clientNameController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Nombre del Cliente / Deudor',
                            labelStyle: TextStyle(color: Colors.white60),
                            filled: true,
                            fillColor: Color(0xFF0b0f19),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ],
                    SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        labelStyle: TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: Color(0xFF0b0f19),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) => setModalState(() {}),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Total a calcular: ${total.toStringAsFixed(2)} €',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3b82f6),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        int qty = int.tryParse(quantityController.text) ?? 0;
                        if (qty <= 0) return;

                        final db = await DatabaseHelper.instance.database;

                        int newStock = type == 'SALE'
                            ? selectedProduct.stock - qty
                            : selectedProduct.stock + qty;

                        final updatedProduct = Product(
                          id: selectedProduct.id,
                          name: selectedProduct.name,
                          stock: newStock,
                          clientPrice: selectedProduct.clientPrice,
                          collaboratorPrice: selectedProduct.collaboratorPrice,
                          minStock: selectedProduct.minStock,
                        );

                        await DatabaseHelper.instance.updateProduct(updatedProduct);

                        await db.insert('transactions', {
                          'type': type,
                          'productId': selectedProduct.id,
                          'quantity': qty,
                          'totalPrice': total,
                          'date': DateTime.now().toString().substring(0, 10),
                        });

                        if (type == 'SALE' && creditSale) {
                          await db.insert('accounts_receivable', {
                            'clientName': clientNameController.text.isNotEmpty ? clientNameController.text : 'Cliente General',
                            'concept': 'Compra de ${selectedProduct.name} (x$qty)',
                            'totalAmount': total,
                            'paidAmount': 0.0,
                            'dueDate': DateTime.now().add(Duration(days: 30)).toString().substring(0, 10),
                            'status': 'Pendiente',
                          });
                        }

                        Navigator.pop(context);
                        _loadProducts();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Operación registrada con éxito.')),
                        );
                      },
                      child: Text('Confirmar Operación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0b0f19),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF151c2c),
        title: Text('Ventas, Compras y Cobros', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.point_of_sale, color: Color(0xFF3b82f6), size: 64),
              SizedBox(height: 16),
              Text(
                'Motor de Operaciones',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Pulsa el botón inferior para registrar una nueva venta aplicando precio de cliente o colaborador, o reponer stock.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF3b82f6),
        icon: Icon(Icons.add_shopping_cart, color: Colors.white),
        label: Text('Nueva Venta / Compra', style: TextStyle(color: Colors.white)),
        onPressed: _showTransactionDialog,
      ),
    );
  }
}
