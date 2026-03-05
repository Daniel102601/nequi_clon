import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/screens/login/login_screen.dart';
import '../movements/movements_screen.dart';
import '../transfer/send_screen.dart';
import '../transfer/request_screen.dart';
import '../auth/screens/scanner/qr_scanner_screen.dart';
import '../auth/screens/services_screen.dart';
import '../auth/screens/digital_card_tab.dart';
import 'profile_tab.dart'; // ¡NUEVO! Importamos la pestaña de Perfil

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  bool hideBalance = false;

  // Variable para controlar la pestaña activa en el menú inferior
  int _selectedIndex = 0;

  // Paleta de colores Nequi
  final Color darkPurple = const Color(0xFF2C004F);
  final Color nequiPink = const Color(0xFFE80070);
  final Color bgColor = const Color(0xFFF5F5F5);

  final List<Map<String, String>> movements = [
    {"title": "Transferencia enviada", "amount": "- \$50.000"},
    {"title": "Recarga celular", "amount": "- \$20.000"},
    {"title": "Pago servicio", "amount": "- \$80.000"},
    {"title": "Transferencia recibida", "amount": "+ \$150.000"},
  ];

  void logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  // Método para cambiar de pestaña al tocar el menú inferior
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // El cuerpo principal decide qué mostrar según la pestaña seleccionada
      body: SafeArea(
        child: _selectedIndex == 0
            ? _buildHomeTab(context)
            : _selectedIndex == 1
            ? const DigitalCardTab()
            : const ProfileTab(), // ¡AQUÍ CARGAMOS EL PERFIL FINAL!
      ),
      // La barra de navegación inferior
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed, // Evita que los íconos se muevan
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: nequiPink,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), // El ícono clásico de $ para el inicio
              label: "Inicio",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: "Tarjeta",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Perfil",
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE CONTENIDO ---

  // Este método contiene TODO el código del Inicio
  Widget _buildHomeTab(BuildContext context) {
    return Column(
      children: [
        /// 1. HEADER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: darkPurple,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Hola, Daniel 👋",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: logout,
                  )
                ],
              )
            ],
          ),
        ),

        /// 2. CONTENIDO SCROLLABLE DEL INICIO
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                /// TARJETA SALDO
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: nequiPink,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: nequiPink.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Disponible",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              hideBalance ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () {
                              setState(() {
                                hideBalance = !hideBalance;
                              });
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hideBalance ? "•••••••" : "\$ 1.250.000",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                /// ACCIONES RAPIDAS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SendScreen()));
                        },
                        child: QuickAction(icon: Icons.arrow_upward, label: "Envía", iconColor: darkPurple),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestScreen()));
                        },
                        child: QuickAction(icon: Icons.arrow_downward, label: "Pide", iconColor: darkPurple),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const QRScannerScreen()));
                        },
                        child: QuickAction(icon: Icons.qr_code_scanner, label: "Escanea", iconColor: darkPurple),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ServicesScreen()));
                        },
                        child: QuickAction(icon: Icons.apps, label: "Servicios", iconColor: darkPurple),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                /// SECCIÓN DE MOVIMIENTOS RECIENTES
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Movimientos recientes",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const MovementsScreen()));
                        },
                        child: Text(
                          "Ver todos",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: nequiPink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                /// LISTA DE MOVIMIENTOS
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: movements.length,
                  itemBuilder: (context, index) {
                    final movement = movements[index];
                    final isIncome = movement["amount"]!.startsWith("+");

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            movement["title"]!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            movement["amount"]!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isIncome ? Colors.green.shade700 : Colors.black87,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30)
              ],
            ),
          ),
        )
      ],
    );
  }
}

// Widget reutilizable para los botones de acción rápida
class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 26,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        )
      ],
    );
  }
}