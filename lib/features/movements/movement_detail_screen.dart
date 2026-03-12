import 'package:flutter/material.dart';

class MovementDetailScreen extends StatelessWidget {
  // El mapa ahora contiene las llaves de la base de datos: tipo, monto, descripcion, fecha
  final Map<String, dynamic> movement;

  const MovementDetailScreen({super.key, required this.movement});

  @override
  Widget build(BuildContext context) {
    final Color nequiPink = const Color(0xFFE80070);
    final Color darkPurple = const Color(0xFF2C004F);

    // DETERMINAMOS SI ES ENTRADA O SALIDA SEGÚN EL TIPO DE LA DB
    final bool isIncome = movement["tipo"] == 'recibo' || movement["tipo"] == 'recarga';

    // FORMATEAMOS LOS VALORES PARA MOSTRAR
    final String title = movement["descripcion"] ?? "Movimiento";
    final String amount = movement["monto"].toString();
    final String date = movement["fecha"] ?? "Sin fecha";

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
            // Ícono principal dinámico
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

            // Título (Descripción) y Monto
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "${isIncome ? '+' : '-'} \$ $amount",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green.shade700 : Colors.black87,
              ),
            ),
            const SizedBox(height: 40),

            // Tarjeta de detalles (Recibo digital)
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
                  _buildDetailRow("Fecha", date),
                  const Divider(height: 30),
                  _buildDetailRow("Referencia", _generateMockReference()),
                  const Divider(height: 30),
                  _buildDetailRow("Estado", "Exitoso", valueColor: Colors.green.shade700),
                  const Divider(height: 30),
                  _buildDetailRow("Tipo de movimiento", movement["tipo"].toString().toUpperCase()),
                  const Divider(height: 30),
                  _buildDetailRow("Medio", "Billetera Digital"),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Botón decorativo de compartir
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.share_outlined, color: darkPurple),
              label: Text("Compartir comprobante", style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  String _generateMockReference() {
    return "REF-${movement["id"] ?? DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
  }
}