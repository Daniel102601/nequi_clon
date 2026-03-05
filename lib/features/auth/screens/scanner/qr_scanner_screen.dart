import 'package:flutter/material.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final Color nequiPink = const Color(0xFFE80070);
  bool isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro simulando la cámara
      body: Stack(
        children: [
          // 1. Simulación de la vista de la cámara (Fondo estático oscuro)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade900, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 2. Área de escaneo (El cuadro central)
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: nequiPink, width: 3),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.05), // Ligeramente transparente
              ),
              child: Stack(
                children: [
                  // Línea de escaneo estilo láser (¡Corregida!)
                  Positioned(
                    top: 120, // En una app real esto se animaría arriba y abajo
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: nequiPink, // El color debe ir DENTRO de la decoración si hay sombras
                        boxShadow: [
                          BoxShadow(
                            color: nequiPink.withOpacity(0.8),
                            blurRadius: 10,
                            spreadRadius: 3,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // 3. Textos e instrucciones
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            child: const Column(
              children: [
                Text(
                  "Apunta al código QR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Encuádralo en el centro de la pantalla\npara leerlo automáticamente",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // 4. Barra superior (Botón Cerrar y Flash)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón Volver
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Botón Flash
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isFlashOn = !isFlashOn;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Botón de subir desde la galería
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  // Acción simulada
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Abriendo galería de imágenes..."))
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white10,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.image, color: Colors.white),
                label: const Text(
                  "Subir desde galería",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}