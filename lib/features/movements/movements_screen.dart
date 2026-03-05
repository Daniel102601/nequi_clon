import 'package:flutter/material.dart';
import 'movement_detail_screen.dart'; // Asegúrate de importar la nueva pantalla

class MovementsScreen extends StatefulWidget {
  const MovementsScreen({super.key});

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  final Color darkPurple = const Color(0xFF2C004F);
  final Color nequiPink = const Color(0xFFE80070);
  final Color bgColor = const Color(0xFFF5F5F5);

  // Estado del filtro actual
  String _currentFilter = 'Todos';

  final List<Map<String, dynamic>> allMovements = [
    {"title": "Transferencia enviada", "date": "Hoy, 10:30 a.m.", "amount": "- \$50.000", "isIncome": false},
    {"title": "Recarga celular", "date": "Ayer, 4:15 p.m.", "amount": "- \$20.000", "isIncome": false},
    {"title": "Transferencia recibida", "date": "Ayer, 9:00 a.m.", "amount": "+ \$150.000", "isIncome": true},
    {"title": "Pago servicio", "date": "28 Feb, 2:00 p.m.", "amount": "- \$80.000", "isIncome": false},
    {"title": "Pago en comercio", "date": "25 Feb, 8:45 p.m.", "amount": "- \$35.000", "isIncome": false},
    {"title": "Transferencia recibida", "date": "20 Feb, 11:20 a.m.", "amount": "+ \$300.000", "isIncome": true},
    {"title": "Suscripción streaming", "date": "18 Feb, 10:00 a.m.", "amount": "- \$25.000", "isIncome": false},
  ];

  // Getter que devuelve la lista filtrada según la selección
  List<Map<String, dynamic>> get filteredMovements {
    if (_currentFilter == 'Entradas') {
      return allMovements.where((m) => m['isIncome'] == true).toList();
    } else if (_currentFilter == 'Salidas') {
      return allMovements.where((m) => m['isIncome'] == false).toList();
    }
    return allMovements;
  }

  // Método para mostrar el menú de filtros
  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Filtrar por",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                _buildFilterOption('Todos'),
                _buildFilterOption('Entradas'),
                _buildFilterOption('Salidas'),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget para cada opción del menú de filtros
  Widget _buildFilterOption(String filterName) {
    return ListTile(
      title: Text(
        filterName,
        style: TextStyle(
          fontWeight: _currentFilter == filterName ? FontWeight.bold : FontWeight.normal,
          color: _currentFilter == filterName ? nequiPink : Colors.black87,
        ),
      ),
      trailing: _currentFilter == filterName
          ? Icon(Icons.check, color: nequiPink)
          : null,
      onTap: () {
        setState(() {
          _currentFilter = filterName;
        });
        Navigator.pop(context); // Cierra el BottomSheet
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final movementsToShow = filteredMovements;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: darkPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tus movimientos",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
                _currentFilter == 'Todos' ? Icons.filter_alt_outlined : Icons.filter_alt,
                color: Colors.white
            ),
            onPressed: _showFilterMenu, // Llama al menú de filtros
          )
        ],
      ),
      body: Column(
        children: [
          // Pequeño indicador de filtro activo (opcional)
          if (_currentFilter != 'Todos')
            Container(
              width: double.infinity,
              color: nequiPink.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  "Mostrando: $_currentFilter",
                  style: TextStyle(color: nequiPink, fontWeight: FontWeight.w600),
                ),
              ),
            ),

          Expanded(
            child: movementsToShow.isEmpty
                ? Center(child: Text("No hay $_currentFilter", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: movementsToShow.length,
              itemBuilder: (context, index) {
                final movement = movementsToShow[index];
                final isIncome = movement["isIncome"];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
                  child: InkWell( // Hace que el contenedor sea "clickeable"
                    onTap: () {
                      // Navega a la pantalla de detalle enviando los datos
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovementDetailScreen(movement: movement),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isIncome ? Colors.green.shade50 : nequiPink.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isIncome ? Colors.green.shade700 : nequiPink,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movement["title"],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  movement["date"],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            movement["amount"],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isIncome ? Colors.green.shade700 : Colors.black87,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}