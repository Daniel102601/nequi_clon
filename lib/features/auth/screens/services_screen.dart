import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  final Color darkPurple = const Color(0xFF2C004F);
  final Color nequiPink = const Color(0xFFE80070);
  final Color bgColor = const Color(0xFFF5F5F5);

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
          "Servicios",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buscador simulado
            TextField(
              decoration: InputDecoration(
                hintText: "Busca un servicio...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 30),

            // Categoría 1: Recargas y Pagos
            _buildCategoryTitle("Recargas y pagos"),
            const SizedBox(height: 15),
            _buildServicesGrid(
              context,
              [
                {"icon": Icons.phone_android, "name": "Celular"},
                {"icon": Icons.receipt_long, "name": "Recibos"},
                {"icon": Icons.directions_bus, "name": "TuLlave"},
                {"icon": Icons.wifi, "name": "Internet"},
              ],
            ),

            const SizedBox(height: 30),

            // Categoría 2: Entretenimiento
            _buildCategoryTitle("Entretenimiento"),
            const SizedBox(height: 15),
            _buildServicesGrid(
              context,
              [
                {"icon": Icons.movie, "name": "Netflix"},
                {"icon": Icons.music_note, "name": "Spotify"},
                {"icon": Icons.sports_esports, "name": "Juegos"},
                {"icon": Icons.tv, "name": "DirecTV"},
              ],
            ),

            const SizedBox(height: 30),

            // Categoría 3: Seguros y Salud
            _buildCategoryTitle("Seguros y Salud"),
            const SizedBox(height: 15),
            _buildServicesGrid(
              context,
              [
                {"icon": Icons.health_and_safety, "name": "SOAT"},
                {"icon": Icons.favorite, "name": "Salud"},
                {"icon": Icons.pets, "name": "Mascotas"},
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para los títulos de las categorías
  Widget _buildCategoryTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // Widget para crear la cuadrícula de servicios
  Widget _buildServicesGrid(BuildContext context, List<Map<String, dynamic>> services) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 íconos por fila
        crossAxisSpacing: 10,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8, // Ajusta la altura de cada ítem
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Abriendo ${service['name']}...")),
            );
          },
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Icon(
                  service["icon"],
                  color: darkPurple,
                  size: 30,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service["name"],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}