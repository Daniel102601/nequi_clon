import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import '../auth/screens/login/login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final Color darkPurple = const Color(0xFF2C004F);
  final Color nequiPink = const Color(0xFFE80070);

  // VARIABLES PARA DATOS REALES
  String userName = "Cargando...";
  String userPhone = "300 000 0000";
  String balance = "0.00"; // <--- NUEVA VARIABLE PARA EL SALDO
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // MÉTODO PARA TRAER DATOS DE MARIA DB (PHP)
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
            userPhone = data['telefono'];
            balance = data['saldo'].toString(); // <--- CAPTURAMOS EL SALDO REAL
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error en perfil: $e");
    }
  }

  void _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        /// HEADER DINÁMICO
        Container(
          padding: const EdgeInsets.only(top: 30, bottom: 40, left: 20, right: 20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: darkPurple,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 15),
              Text(
                userName,
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Text(
                "Cel: $userPhone",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),

        /// LISTA DE OPCIONES
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              _buildSectionTitle("Tu Negocio"),
              _buildProfileOption(
                icon: Icons.storefront,
                title: "Perfil Comercial",
                subtitle: "Servicios IT y Mantenimiento",
                onTap: () => _showCommercialProfile(context),
              ),
              _buildProfileOption(
                icon: Icons.description_outlined,
                title: "Documentos",
                subtitle: "RUT y Cámara de Comercio",
                onTap: () => _showDocuments(context),
              ),

              const SizedBox(height: 25),
              _buildSectionTitle("Tu Cuenta"),
              _buildProfileOption(
                icon: Icons.person_outline,
                title: "Tu información",
                subtitle: "Ver tus datos registrados",
                onTap: () => _showPersonalInfo(context),
              ),
              _buildProfileOption(
                icon: Icons.devices,
                title: "Dispositivos vinculados",
                subtitle: "Gestiona tus sesiones activas",
                onTap: () => _showLinkedDevices(context),
              ),

              const SizedBox(height: 25),
              _buildSectionTitle("Seguridad"),
              _buildProfileOption(
                icon: Icons.lock_outline,
                title: "Cambiar clave",
                subtitle: "Actualiza tu PIN de acceso",
                onTap: () => _showChangePassword(context),
              ),

              const SizedBox(height: 40),
              _buildLogoutButton(context),
              const SizedBox(height: 30),
            ],
          ),
        )
      ],
    );
  }

  // --- MODALES Y BOTTOM SHEETS ---

  void _showPersonalInfo(BuildContext context) {
    _showSheet(context, "Tu Información", [
      ListTile(leading: const Icon(Icons.person), title: const Text("Nombre"), subtitle: Text(userName)),
      ListTile(leading: const Icon(Icons.phone), title: const Text("Celular"), subtitle: Text(userPhone)),
      ListTile(
        leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
        title: const Text("Saldo Actual"),
        subtitle: Text("\$ $balance", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
      ),
    ]);
  }

  void _showCommercialProfile(BuildContext context) {
    _showSheet(context, "Perfil Comercial", [
      const ListTile(leading: Icon(Icons.business), title: Text("Negocio"), subtitle: Text("Soporte y Mantenimiento IT")),
      const ListTile(leading: Icon(Icons.category), title: Text("Rubro"), subtitle: Text("Tecnología")),
    ]);
  }

  void _showDocuments(BuildContext context) {
    _showSheet(context, "Mis Documentos", [
      _buildDocTile("RUT_Daniel_2026.pdf", "Vigente"),
      _buildDocTile("Camara_Comercio.pdf", "Actualizado"),
    ]);
  }

  void _showLinkedDevices(BuildContext context) {
    _showSheet(context, "Dispositivos", [
      const ListTile(leading: Icon(Icons.phone_android, color: Colors.green), title: Text("Este dispositivo"), subtitle: Text("Sesión activa")),
    ]);
  }

  void _showChangePassword(BuildContext context) {
    _showSheet(context, "Seguridad", [
      const TextField(obscureText: true, maxLength: 4, decoration: InputDecoration(labelText: "PIN Actual")),
      const TextField(obscureText: true, maxLength: 4, decoration: InputDecoration(labelText: "Nuevo PIN")),
      const SizedBox(height: 10),
      ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: darkPurple), child: const Text("Cambiar PIN", style: TextStyle(color: Colors.white))),
    ]);
  }

  // --- MÉTODOS AUXILIARES ---

  void _showSheet(BuildContext context, String title, List<Widget> children) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...children,
        ]),
      ),
    );
  }

  Widget _buildDocTile(String name, String status) {
    return ListTile(
      leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
      title: Text(name),
      subtitle: Text(status),
      trailing: const Icon(Icons.download),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 12, left: 5), child: Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1.1)));
  }

  Widget _buildProfileOption({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))]),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: darkPurple)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _logout(context),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.redAccent, width: 1.5)), elevation: 0),
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout), SizedBox(width: 10), Text("Cerrar Sesión", style: TextStyle(fontWeight: FontWeight.bold))]),
    );
  }
}