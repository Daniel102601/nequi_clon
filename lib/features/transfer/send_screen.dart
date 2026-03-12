import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final Color darkPurple = const Color(0xFF2C004F);
  final Color nequiPink = const Color(0xFFE80070);
  final Color bgColor = const Color(0xFFF5F5F5);

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isLoading = false; // Para controlar el estado del botón

  // Datos mock para contactos
  final List<Map<String, String>> recentContacts = [
    {"name": "Mamá", "phone": "3123456789"},
    {"name": "Carlos M.", "phone": "3009876543"},
    {"name": "Arriendo", "phone": "3151112233"},
    {"name": "Laura", "phone": "3105554444"},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE ENVÍO REAL A MARIA DB ---
  Future<void> _handleSendMoney() async {
    // 1. Validaciones básicas de Front-end
    if (_phoneController.text.length < 10 || _amountController.text.isEmpty) {
      _showSnackBar("Ingresa un número de 10 dígitos y un monto válido", Colors.redAccent);
      return;
    }

    double? monto = double.tryParse(_amountController.text);
    if (monto == null || monto <= 0) {
      _showSnackBar("El monto debe ser mayor a 0", Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Obtener el ID del emisor (quien está logueado)
      final prefs = await SharedPreferences.getInstance();
      final emisorId = prefs.getString("user_id");

      // 3. Petición POST al PHP
      final response = await http.post(
        Uri.parse("http://10.0.2.2/nequi_api/enviar_plata.php"),
        body: {
          "emisor_id": emisorId,
          "telefono_receptor": _phoneController.text,
          "monto": _amountController.text,
          "descripcion": _messageController.text, // Opcional
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        _showSuccessDialog(); // Si todo salió bien en la DB
      } else {
        _showSnackBar(data['message'] ?? "Error en la transacción", Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar("Error de conexión: $e", Colors.redAccent);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Icon(Icons.check_circle, color: Colors.green.shade600, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("¡Envío exitoso!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              "Le enviaste \$ ${_amountController.text} al número ${_phoneController.text}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
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
                Navigator.pop(context); // Cierra el diálogo
                Navigator.pop(context); // Vuelve al Dashboard
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Envía plata", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                  const Text("Recientes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: recentContacts.length,
                      itemBuilder: (context, index) {
                        final contact = recentContacts[index];
                        return GestureDetector(
                          onTap: () => setState(() => _phoneController.text = contact["phone"]!),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: darkPurple.withOpacity(0.1),
                                  child: Text(contact["name"]![0], style: TextStyle(color: darkPurple, fontSize: 22, fontWeight: FontWeight.bold)),
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
                  const Text("¿A qué número?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      hintText: "Ej: 300 000 0000",
                      prefixIcon: const Icon(Icons.phone_android),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      counterText: "",
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text("¿Cuánta plata?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "0",
                      prefixText: "\$ ",
                      prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text("Mensaje (Opcional)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _messageController,
                    maxLength: 40,
                    decoration: InputDecoration(
                      hintText: "¿Para qué es esta plata?",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSendMoney, // Desactiva si está cargando
              style: ElevatedButton.styleFrom(
                backgroundColor: nequiPink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Envía", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}