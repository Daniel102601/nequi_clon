import 'package:flutter/material.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final Color darkPurple = const Color(0xFF2C004F);
  final Color nequiPink = const Color(0xFFE80070);
  final Color bgColor = const Color(0xFFF5F5F5);

  // Controladores de texto
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Contactos frecuentes para pedir
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

  // Simula la acción de solicitar dinero
  void _requestMoney() {
    if (_phoneController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ingresa el número y la cantidad que vas a pedir"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Diálogo de éxito simulado
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Icon(Icons.arrow_circle_down, color: darkPurple, size: 60), // Ícono hacia abajo (recibir)
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "¡Solicitud enviada!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Le pediste \$ ${_amountController.text} al número ${_phoneController.text}. Te avisaremos cuando te paguen.",
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                Navigator.pop(context); // Vuelve al Dashboard
              },
              child: const Text("Entendido", style: TextStyle(color: Colors.white, fontSize: 16)),
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
        title: const Text(
          "Pide plata",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
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
                  // 1. A QUIÉN PEDIRLE (CONTACTOS)
                  const Text(
                    "¿A quién le vas a pedir?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: frequentContacts.length,
                      itemBuilder: (context, index) {
                        final contact = frequentContacts[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _phoneController.text = contact["phone"]!;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: nequiPink.withOpacity(0.1), // Cambiamos el color para diferenciarlo de Envía
                                  child: Text(
                                    contact["name"]![0],
                                    style: TextStyle(
                                      color: nequiPink,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  contact["name"]!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 2. INPUT DE CELULAR
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      hintText: "Número de celular",
                      prefixIcon: const Icon(Icons.phone_android),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      counterText: "",
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 3. INPUT DE PLATA
                  const Text(
                    "¿Cuánto necesitas?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 4. INPUT DE MENSAJE
                  const Text(
                    "Mensaje (Opcional)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _messageController,
                    maxLength: 40,
                    decoration: InputDecoration(
                      hintText: "Ej: Para el almuerzo de hoy",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. BOTÓN INFERIOR
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ]
            ),
            child: ElevatedButton(
              onPressed: _requestMoney,
              style: ElevatedButton.styleFrom(
                backgroundColor: darkPurple, // Usamos el morado oscuro para contrastar con el Envía
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Pide",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}