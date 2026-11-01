import 'package:flutter/material.dart';
import 'generic_module_view.dart';

class StockView extends GenericModuleView {
  const StockView({super.key})
      : super(
          moduleTitle: 'Módulo de Stock e Inventario',
          filterType: 'PRODUCTO',
        );
}
