import 'package:flutter/material.dart';
import 'generic_module_view.dart';

class ClientesView extends GenericModuleView {
  const ClientesView({super.key})
      : super(
          moduleTitle: 'Gestión de Clientes',
          filterType: 'VENTA',
        );
}
