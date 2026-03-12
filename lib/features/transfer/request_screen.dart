import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final Color darkPurple = const Color(0xFF2C004F);
  final Color nequiPink = const Color(0xFFE80070);
  final Color bgColor = const Color(0xFFF5F5F5);

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isLoading = false;

  // Contactos frecuentes (Simulados para la interfaz)
  final List<Map<String, String>> frequentContacts = [
    {"name": "Papá", "phone": "3159998877"},
    {"name": "Daniela", "phone": "3012223344"},
    {"name": "Felipe", "phone": "3204445566"},
    {"name": "Trabajo", "phone": "3107778899"},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE SOLICITUD A MARIA DB ---
  Future<void> _handleRequestMoney() async {
    // 1. Validaciones de cliente
    if (_phoneController.text.length < 10 || _amountController.text.isEmpty) {
      _showSnackBar("Revisa el número (10 dígitos) y el monto", Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final myId = prefs.getString("user_id");

      // 2. Petición POST a XAMPP
      final response = await http.post(
        Uri.parse("http://10.0.2.2/nequi_api/pedir_plata.php"),
        body: {
          "solicitante_id": myId,
          "telefono_pagador": _phoneController.text,
          "monto": _amountController.text,
          "mensaje": _messageController.text,
        },
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _showSuccessDialog();
      } else {
        _showSnackBar(data['message'] ?? "No pudimos enviar tu pedido", Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar("Error de conexión. Revisa tu servidor XAMPP", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Icon(Icons.send_rounded, color: darkPurple, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("¡Pedido enviado!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              "Le pediste \$ ${_amountController.text} a ${_phoneController.text}. El destinatario recibirá un aviso en su campana 🔔.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: nequiPink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver al inicio
              },
              child: const Text("Listo", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: darkPurple,
        elevation: 0,
        title: const Text("Pide plata", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Contactos rápidos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 15),

                  // LISTA DE CONTACTOS RECIENTES
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: frequentContacts.length,
                      itemBuilder: (context, index) {
                        final contact = frequentContacts[index];
                        return GestureDetector(
                          onTap: () => setState(() => _phoneController.text = contact["phone"]!),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: nequiPink.withOpacity(0.1),
                                  child: Text(contact["name"]![0], style: TextStyle(color: nequiPink, fontSize: 22, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 8),
                                Text(contact["name"]!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(height: 40),

                  // INPUT DEL CELULAR
                  _buildInputLabel("¿A quién le pides?"),
                  _buildTextField(
                    controller: _phoneController,
                    hint: "300 000 0000",
                    icon: Icons.phone_android,
                    type: TextInputType.phone,
                    maxLength: 10,
                  ),

                  const SizedBox(height: 25),

                  // INPUT DEL MONTO
                  _buildInputLabel("¿Cuánta plata pides?"),
                  _buildTextField(
                    controller: _amountController,
                    hint: "0",
                    icon: Icons.monetization_on,
                    type: TextInputType.number,
                    prefix: "\$ ",
                  ),

                  const SizedBox(height: 25),

                  // INPUT DEL MENSAJE
                  _buildInputLabel("Mensaje"),
                  _buildTextField(
                    controller: _messageController,
                    hint: "¿Para qué es?",
                    icon: Icons.chat_bubble_outline,
                    type: TextInputType.text,
                    maxLength: 40,
                  ),
                ],
              ),
            ),
          ),

          // BOTÓN DE ACCIÓN
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRequestMoney,
              style: ElevatedButton.styleFrom(
                backgroundColor: darkPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Pide", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // WIDGETS DE APOYO
  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType type,
    int? maxLength,
    String? prefix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLength: maxLength,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        counterText: "",
        hintText: hint,
        prefixText: prefix,
        prefixIcon: Icon(icon, color: darkPurple, size: 22),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}