import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CardSettingsScreen extends StatefulWidget {
  final Map<String, dynamic> cardData;
  const CardSettingsScreen({super.key, required this.cardData});

  @override
  State<CardSettingsScreen> createState() => _CardSettingsScreenState();
}

class _CardSettingsScreenState extends State<CardSettingsScreen> {
  final Color nequiPink = const Color(0xFFE80070);

  // FUNCIÓN GENÉRICA PARA ACTUALIZAR EN MARIA DB
  Future<void> _updateSetting(String accion, String valor) async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2/nequi_api/update_card_settings.php"),
        body: {
          "usuario_id": widget.cardData['usuario_id'].toString(),
          "accion": accion,
          "valor": valor,
        },
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("¡${accion.toUpperCase()} actualizado!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // DIÁLOGO PARA CAMBIAR PIN
  void _showPinDialog() {
    TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nuevo PIN (4 dígitos)"),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(hintText: "Ej: 1234"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              _updateSetting('pin', pinController.text);
              Navigator.pop(context);
            },
            child: const Text("Cambiar"),
          ),
        ],
      ),
    );
  }

  // DIÁLOGO PARA CANCELAR TARJETA
  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar tarjeta?"),
        content: const Text("Esta acción no se puede deshacer. Perderás tu número de tarjeta actual."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No, volver")),
          TextButton(
            onPressed: () {
              _updateSetting('cancelar', '');
              Navigator.pop(context); // Cierra diálogo
              Navigator.pop(context); // Vuelve al Tab de tarjeta
            },
            child: const Text("Sí, cancelar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Ajustes", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Seguridad", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSettingItem(
            Icons.lock_outline,
            "Cambiar PIN de la tarjeta",
            "Para cajeros y compras",
            onTap: _showPinDialog,
          ),

          const SizedBox(height: 30),
          const Text("Límites", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSettingItem(
            Icons.trending_up,
            "Límites de uso",
            "Actualmente: \$ ${widget.cardData['limite_diario'] ?? '1.000.000'}",
            onTap: () => _updateSetting('limite', '2000000'), // Ejemplo rápido
          ),

          const SizedBox(height: 30),
          const Text("Estado", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSettingItem(
            Icons.cancel_outlined,
            "Cancelar tarjeta",
            "Elimina tu tarjeta permanentemente",
            color: Colors.red,
            onTap: _confirmCancel,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, {Color? color, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }
}