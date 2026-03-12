import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../services/auth_service.dart';
import '../auth/screens/login/login_screen.dart';
import '../movements/movements_screen.dart';
import '../transfer/send_screen.dart';
import '../transfer/request_screen.dart';
import '../auth/screens/scanner/qr_scanner_screen.dart';
import '../auth/screens/services_screen.dart';
import '../auth/screens/digital_card_tab.dart';
import '../dashboard/notifications_screen.dart';
import 'profile_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();

  String userName = "Cargando...";
  String balance = "0.00";
  int pendingCount = 0;
  bool isLoading = true;
  bool hideBalance = false;
  int _selectedIndex = 0;

  // NUEVA VARIABLE PARA LOS MOVIMIENTOS REALES
  List<dynamic> _recentMovements = [];

  final Color darkPurple = const Color(0xFF2C004F);
  final Color nequiPink = const Color(0xFFE80070);
  final Color bgColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  // REFRESCAR SALDO, NOTIFICACIONES Y MOVIMIENTOS
  Future<void> _refreshAll() async {
    await _loadUserData();
    await _checkNotifications();
    await _fetchRecentMovements(); // <--- CARGAMOS LOS MOVIMIENTOS AQUÍ
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null) return;

    try {
      final response = await http.get(
          Uri.parse("http://10.0.2.2/nequi_api/get_user_data.php?usuario_id=$userId")
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            userName = data['nombre'];
            balance = data['saldo'].toString();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error datos: $e");
    }
  }

  // MÉTODO PARA TRAER LOS ÚLTIMOS 4 MOVIMIENTOS DE MARIA DB
  Future<void> _fetchRecentMovements() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null) return;

    try {
      final response = await http.get(
          Uri.parse("http://10.0.2.2/nequi_api/get_recent_movements.php?usuario_id=$userId")
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _recentMovements = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error movimientos: $e");
    }
  }

  Future<void> _checkNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    try {
      final response = await http.get(
          Uri.parse("http://10.0.2.2/nequi_api/get_requests.php?usuario_id=$userId")
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pendingCount = (data['data'] as List).length;
        });
      }
    } catch (e) {
      debugPrint("Error notificaciones: $e");
    }
  }

  void logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _goToNotifications(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
    if (result == true || result == null) {
      _refreshAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _selectedIndex == 0
            ? _buildHomeTab(context)
            : _selectedIndex == 1
            ? const DigitalCardTab()
            : const ProfileTab(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshAll,
            color: nequiPink,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildBalanceCard(),
                  _buildQuickActions(context),
                  const SizedBox(height: 35),
                  _buildMovementsHeader(),
                  // --- CAMBIO AQUÍ: LLAMAMOS A LA LISTA DINÁMICA ---
                  _buildRecentMovementsList(),
                  const SizedBox(height: 30)
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: darkPurple),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 20, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 12),
              Text("Hola, $userName 👋", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                    onPressed: () => _goToNotifications(context),
                  ),
                  if (pendingCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text('$pendingCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
              IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: logout),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SendScreen())), child: QuickAction(icon: Icons.arrow_upward, label: "Envía", iconColor: darkPurple)),
          GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestScreen())), child: QuickAction(icon: Icons.arrow_downward, label: "Pide", iconColor: darkPurple)),
          GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QRScannerScreen())), child: QuickAction(icon: Icons.qr_code_scanner, label: "Escanea", iconColor: darkPurple)),
          GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ServicesScreen())), child: QuickAction(icon: Icons.apps, label: "Servicios", iconColor: darkPurple)),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: nequiPink, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Disponible", style: TextStyle(color: Colors.white, fontSize: 16)),
              IconButton(
                icon: Icon(hideBalance ? Icons.visibility_off : Icons.visibility, color: Colors.white),
                onPressed: () => setState(() => hideBalance = !hideBalance),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(hideBalance ? "•••••••" : "\$ $balance", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMovementsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Movimientos recientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MovementsScreen())), child: Text("Ver todos", style: TextStyle(color: nequiPink))),
        ],
      ),
    );
  }

  // --- NUEVA LISTA DE MOVIMIENTOS DINÁMICA ---
  Widget _buildRecentMovementsList() {
    if (_recentMovements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text("Aún no tienes movimientos.", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentMovements.length,
      itemBuilder: (context, index) {
        final movement = _recentMovements[index];
        final bool isIncome = movement['tipo'] == 'recibo' || movement['tipo'] == 'recarga';

        return Container(
          margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5)]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movement["descripcion"] ?? "Movimiento", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                        movement["fecha"].toString().substring(5, 16),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)
                    ),
                  ],
                ),
              ),
              Text(
                "${isIncome ? '+' : '-'} \$${movement['monto']}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green : Colors.black,
                    fontSize: 16
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      selectedItemColor: nequiPink,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "Inicio"),
        BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "Tarjeta"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Perfil"),
      ],
    );
  }
}

// Widget de acciones rápidas (Ya corregido)
class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  const QuickAction({super.key, required this.icon, required this.label, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 55, height: 55,
          decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}