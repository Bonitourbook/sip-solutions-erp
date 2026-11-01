import 'package:flutter/material.dart';
import '../controllers/erp_controller.dart';
import '../models/transaction_model.dart';

class FormScreen extends StatefulWidget {
  final String title;
  final String type; // 'VENTA', 'COBRO', 'PRODUCTO', 'COMPRA'
  const FormScreen({super.key, required this.title, required this.type});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final clientC = TextEditingController();
  final amountC = TextEditingController();
  final paidC = TextEditingController();

  String clientType = 'Cliente Final';
  String paymentMode = 'Contado';
  bool hasDelivery = false;

  final List<double> presetAmounts = [50.0, 100.0, 500.0, 1000.0];

  void save() async {
    final client = clientC.text.trim();
    final amount = double.tryParse(amountC.text) ?? 0.0;
    final paidAmount = paymentMode == 'Contado'
        ? amount
        : (paymentMode == 'Crédito' ? 0.0 : (double.tryParse(paidC.text) ?? 0.0));

    if (client.isEmpty || amount <= 0) return;

    final newTx = TransactionModel(
      type: widget.type,
      client: client,
      clientType: widget.type == 'VENTA' ? clientType : 'General',
      amount: amount,
      paidAmount: paidAmount,
      paymentMode: paymentMode,
      hasDelivery: hasDelivery,
      status: paidAmount < amount ? 'Pendiente / Crédito' : 'Completada',
      date: DateTime.now().toString().substring(0, 10),
    );

    await ErpController.instance.insertTransaction(newTx);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isVenta = widget.type == 'VENTA' || widget.type == 'COBRO';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF0b0f19),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: clientC,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: widget.type == 'PRODUCTO' ? 'Nombre del Producto' : 'Cliente / Razón Social',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF111827),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.type == 'VENTA') ...[
              DropdownButtonFormField<String>(
                value: clientType,
                dropdownColor: const Color(0xFF111827),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Tipo de Comprador',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF111827),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 'Cliente Final', child: Text('Cliente Final (Precio Normal)')),
                  DropdownMenuItem(value: 'Colaborador', child: Text('Colaborador (Precio Diferenciado)')),
                ],
                onChanged: (val) => setState(() => clientType = val ?? 'Cliente Final'),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: amountC,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Monto Total (\$)',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF111827),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Montos preestablecidos:', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: presetAmounts.map((val) => ActionChip(
                label: Text('\$$val'),
                backgroundColor: const Color(0xFF1f2937),
                labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                onPressed: () => setState(() => amountC.text = val.toString()),
              )).toList(),
            ),
            const SizedBox(height: 16),
            if (isVenta) ...[
              DropdownButtonFormField<String>(
                value: paymentMode,
                dropdownColor: const Color(0xFF111827),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Modalidad de Pago',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF111827),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 'Contado', child: Text('Contado (Pago Total)')),
                  DropdownMenuItem(value: 'Crédito', child: Text('Crédito (Cuenta por Cobrar)')),
                  DropdownMenuItem(value: 'Mixto', child: Text('Mixto (Parte contado, parte crédito)')),
                ],
                onChanged: (val) => setState(() => paymentMode = val ?? 'Contado'),
              ),
              if (paymentMode == 'Mixto') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: paidC,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Monto Pagado de Contado (\$)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF111827),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('¿Incluye Delivery?', style: TextStyle(color: Colors.white, fontSize: 14)),
                value: hasDelivery,
                activeColor: Colors.blueAccent,
                onChanged: (val) => setState(() => hasDelivery = val),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3b82f6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: Text('Guardar ${widget.title}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
