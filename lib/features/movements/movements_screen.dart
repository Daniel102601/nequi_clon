import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movement_detail_screen.dart';

class MovementsScreen extends StatefulWidget {
  const MovementsScreen({super.key});

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  final Color darkPurple = const Color(0xFF2C004F);
  final Color nequiPink = const Color(0xFFE80070);
  final Color bgColor = const Color(0xFFF5F5F5);

  String _currentFilter = 'Todos';
  List<dynamic> _allMovements = []; // Lista que vendrá de la DB
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovements(); // Cargar datos al entrar
  }

  // --- PETICIÓN REAL AL BACKEND ---
  Future<void> _fetchMovements() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");

    if (userId == null) return;

    try {
      final response = await http.get(
          Uri.parse("http://10.0.2.2/nequi_api/get_movements.php?usuario_id=$userId")
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _allMovements = data['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error cargando movimientos: $e");
      setState(() => _isLoading = false);
    }
  }

  // Getter filtrado adaptado a los datos de la DB
  List<dynamic> get filteredMovements {
    if (_currentFilter == 'Entradas') {
      return _allMovements.where((m) => m['tipo'] == 'recibo' || m['tipo'] == 'recarga').toList();
    } else if (_currentFilter == 'Salidas') {
      return _allMovements.where((m) => m['tipo'] == 'envio' || m['tipo'] == 'pago').toList();
    }
    return _allMovements;
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Filtrar por", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildFilterOption(String filterName) {
    return ListTile(
      title: Text(
        filterName,
        style: TextStyle(
          fontWeight: _currentFilter == filterName ? FontWeight.bold : FontWeight.normal,
          color: _currentFilter == filterName ? nequiPink : Colors.black87,
        ),
      ),
      trailing: _currentFilter == filterName ? Icon(Icons.check, color: nequiPink) : null,
      onTap: () {
        setState(() => _currentFilter = filterName);
        Navigator.pop(context);
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
        title: const Text("Tus movimientos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_currentFilter == 'Todos' ? Icons.filter_alt_outlined : Icons.filter_alt, color: Colors.white),
            onPressed: _showFilterMenu,
          )
        ],
      ),
      body: Column(
        children: [
          if (_currentFilter != 'Todos')
            Container(
              width: double.infinity,
              color: nequiPink.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text("Mostrando: $_currentFilter", style: TextStyle(color: nequiPink, fontWeight: FontWeight.w600)),
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _fetchMovements,
              color: nequiPink,
              child: movementsToShow.isEmpty
                  ? ListView(children: [SizedBox(height: 200), Center(child: Text("No hay movimientos", style: TextStyle(color: Colors.grey)))])
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: movementsToShow.length,
                itemBuilder: (context, index) {
                  final movement = movementsToShow[index];
                  // Convertimos el tipo de la DB a la lógica del UI
                  final bool isIncome = movement['tipo'] == 'recibo' || movement['tipo'] == 'recarga';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
                    child: InkWell(
                      onTap: () {
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
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
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
                                    movement["descripcion"] ?? "Movimiento",
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    movement["fecha"] ?? "",
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${isIncome ? '+' : '-'} \$${movement['monto']}",
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
          ),
        ],
      ),
    );
  }
}