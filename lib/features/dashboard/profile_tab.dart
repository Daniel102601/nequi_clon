import 'package:flutter/material.dart';
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
  final Color bgColor = const Color(0xFFF5F5F5);

  bool _biometricsEnabled = true;

  void _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// HEADER DEL PERFIL
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
              const Text("Daniel", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const Text("Cel: 300 000 0000", style: TextStyle(color: Colors.white70, fontSize: 16)),
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
                subtitle: "Datos personales y ubicación",
                onTap: () => _showPersonalInfo(context),
              ),
              _buildProfileOption(
                icon: Icons.devices,
                title: "Dispositivos vinculados",
                subtitle: "Sesiones activas",
                onTap: () => _showLinkedDevices(context),
              ),

              const SizedBox(height: 25),
              _buildSectionTitle("Seguridad"),
              _buildProfileOption(
                icon: Icons.lock_outline,
                title: "Cambiar clave",
                subtitle: "Actualiza tu PIN de seguridad",
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

  // ==========================================
  // LÓGICA DE CADA APARTADO (BottomSheets)
  // ==========================================

  // 1. PERFIL COMERCIAL
  void _showCommercialProfile(BuildContext context) {
    _showSheet(context, "Perfil Comercial", [
      const ListTile(leading: Icon(Icons.business), title: Text("Nombre del Negocio"), subtitle: Text("Soporte Técnico Daniel")),
      const ListTile(leading: Icon(Icons.category), title: Text("Categoría"), subtitle: Text("Servicios de Tecnología / IT")),
      const ListTile(leading: Icon(Icons.location_on), title: Text("Ciudad Operación"), subtitle: Text("Bogotá, Colombia")),
      ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: nequiPink), child: const Text("Editar Perfil Comercial", style: TextStyle(color: Colors.white))),
    ]);
  }

  // 2. DOCUMENTOS
  void _showDocuments(BuildContext context) {
    _showSheet(context, "Mis Documentos", [
      _buildDocItem("RUT - Persona Natural", "Actualizado 2025"),
      _buildDocItem("Cámara de Comercio", "Vigente - Bogotá"),
      _buildDocItem("Extractos Bancarios", "Mes de Febrero"),
    ]);
  }

  // 3. TU INFORMACIÓN
  void _showPersonalInfo(BuildContext context) {
    _showSheet(context, "Tu Información", [
      const ListTile(leading: Icon(Icons.badge), title: Text("Documento"), subtitle: Text("CC 1.000.XXX.XXX")),
      const ListTile(leading: Icon(Icons.email), title: Text("Correo"), subtitle: Text("daniel.it@servicios.com")),
      const ListTile(leading: Icon(Icons.home), title: Text("Dirección Residencia"), subtitle: Text("Calle XX # XX, Bogotá")),
    ]);
  }

  // 4. DISPOSITIVOS VINCULADOS
  void _showLinkedDevices(BuildContext context) {
    _showSheet(context, "Dispositivos Vinculados", [
      const ListTile(leading: Icon(Icons.phone_android, color: Colors.green), title: Text("Este dispositivo"), subtitle: Text("Pixel 6 - Activo ahora")),
      const ListTile(leading: Icon(Icons.computer), title: Text("Windows PC"), subtitle: Text("Bogotá - Hace 2 horas")),
      const SizedBox(height: 10),
      TextButton(onPressed: () {}, child: const Text("Cerrar todas las demás sesiones", style: TextStyle(color: Colors.red))),
    ]);
  }

  // 5. CAMBIAR CLAVE
  void _showChangePassword(BuildContext context) {
    _showSheet(context, "Cambiar Clave", [
      const TextField(obscureText: true, decoration: InputDecoration(labelText: "Clave actual", prefixIcon: Icon(Icons.lock_open))),
      const SizedBox(height: 15),
      const TextField(obscureText: true, decoration: InputDecoration(labelText: "Nueva clave", prefixIcon: Icon(Icons.lock_outline))),
      const SizedBox(height: 15),
      const TextField(obscureText: true, decoration: InputDecoration(labelText: "Confirmar nueva clave", prefixIcon: Icon(Icons.check_circle_outline))),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: darkPurple), child: const Text("Actualizar PIN", style: TextStyle(color: Colors.white)))),
    ]);
  }

  // ==========================================
  // WIDGETS REUTILIZABLES
  // ==========================================

  void _showSheet(BuildContext context, String title, List<Widget> children) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDocItem(String title, String status) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
      title: Text(title),
      subtitle: Text(status),
      trailing: const Icon(Icons.download),
      onTap: () {},
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1.1)),
    );
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