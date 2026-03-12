import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'card_settings_screen.dart';

class DigitalCardTab extends StatefulWidget {
  const DigitalCardTab({super.key});

  @override
  State<DigitalCardTab> createState() => _DigitalCardTabState();
}

class _DigitalCardTabState extends State<DigitalCardTab> {
  final Color darkPurple = const Color(0xFF2C004F);
  final Color nequiPink = const Color(0xFFE80070);

  Map<String, dynamic>? cardData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCardData();
  }

  Future<void> _fetchCardData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");

    try {
      final response = await http.get(
          Uri.parse("http://10.0.2.2/nequi_api/get_card_data.php?usuario_id=$userId")
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          cardData = json.decode(response.body)['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error al obtener datos de la tarjeta: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _toggleStatus() async {
    if (cardData == null) return;

    final String currentStatus = cardData!['estado'];
    final String nextStatus = currentStatus == 'activa' ? 'congelada' : 'activa';

    try {
      await http.post(
          Uri.parse("http://10.0.2.2/nequi_api/toggle_card_status.php"),
          body: {
            "usuario_id": cardData!['usuario_id'].toString(),
            "estado": nextStatus
          }
      );
      _fetchCardData();
    } catch (e) {
      debugPrint("Error al cambiar estado: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cardData == null) {
      return const Center(child: Text("No se pudo cargar la información de la tarjeta"));
    }

    final bool isFrozen = cardData!['estado'] == 'congelada';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          // --- TARJETA DIGITAL CORREGIDA ---
          Container(
            width: double.infinity,
            height: 220,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isFrozen
                    ? [Colors.grey.shade800, Colors.grey.shade600]
                    : [nequiPink, const Color(0xFFFF3399)],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8)
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Texto estilizado en lugar de imagen externa para evitar error 404
                    const Text(
                        "VISA",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            fontStyle: FontStyle.italic
                        )
                    ),
                    const Icon(Icons.contactless, color: Colors.white, size: 28),
                  ],
                ),
                const SizedBox(height: 20),

                // FittedBox soluciona el error de RenderFlex overflow
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    cardData!['numero_tarjeta'] ?? "0000 0000 0000 0000",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace'
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCardInfoLabel("VENCE", cardData!['fecha_exp'] ?? "--/--"),
                    _buildCardInfoLabel("CVV", isFrozen ? "***" : (cardData!['cvv'] ?? "***")),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 40),

          // --- OPCIONES DE MENÚ ---
          _buildMenuOption(
            icon: isFrozen ? Icons.lock_open : Icons.ac_unit,
            label: isFrozen ? "Descongelar tarjeta" : "Congelar tarjeta",
            subtitle: isFrozen ? "Toca para habilitar compras" : "Nadie podrá usar tu tarjeta",
            iconColor: isFrozen ? Colors.green : Colors.lightBlueAccent,
            onTap: _toggleStatus,
          ),

          const Divider(height: 30),

          _buildMenuOption(
            icon: Icons.settings,
            label: "Ajustes de tarjeta",
            subtitle: "PIN, Límites y seguridad",
            iconColor: darkPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CardSettingsScreen(cardData: cardData!)
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfoLabel(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)
        ),
        Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)
        ),
      ],
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}