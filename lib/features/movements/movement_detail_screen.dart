import 'package:flutter/material.dart';

class MovementDetailScreen extends StatelessWidget {
  final Map<String, dynamic> movement;

  const MovementDetailScreen({super.key, required this.movement});

  @override
  Widget build(BuildContext context) {
    // Paleta de colores
    final Color nequiPink = const Color(0xFFE80070);
    final bool isIncome = movement["isIncome"];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detalle del movimiento",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Ícono principal
            CircleAvatar(
              radius: 40,
              backgroundColor: isIncome ? Colors.green.shade50 : nequiPink.withOpacity(0.1),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? Colors.green.shade700 : nequiPink,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),

            // Título y Monto
            Text(
              movement["title"],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              movement["amount"],
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green.shade700 : Colors.black87,
              ),
            ),
            const SizedBox(height: 40),

            // Tarjeta de detalles (Recibo)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow("Fecha", movement["date"]),
                  const Divider(height: 30),
                  _buildDetailRow("Referencia", _generateMockReference()),
                  const Divider(height: 30),
                  _buildDetailRow("Estado", "Aprobado", valueColor: Colors.green.shade700),
                  const Divider(height: 30),
                  _buildDetailRow("Origen/Destino", isIncome ? "Bancolombia" : "Pago Nequi"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para las filas del recibo
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  // Genera un número de referencia aleatorio para darle realismo
  String _generateMockReference() {
    return "M-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
  }
}