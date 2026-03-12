import 'package:flutter/material.dart';
import '../../../../services/auth_service.dart';
import '../../../dashboard/dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final Color darkPurple = const Color(0xFF2C004F);
  final Color nequiPink = const Color(0xFFE80070);

  void _handleRegister() async {
    // 1. Validaciones básicas
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      _showError("Por favor completa todos los campos");
      return;
    }
    if (_pinController.text.length < 4) {
      _showError("El PIN debe ser de 4 dígitos");
      return;
    }
    if (_pinController.text != _confirmPinController.text) {
      _showError("Los PIN no coinciden");
      return;
    }

    setState(() => _isLoading = true);

    // 2. Llamada al Backend (XAMPP)
    final result = await _authService.register(
      _nameController.text,
      _phoneController.text,
      _pinController.text,
    );

    setState(() => _isLoading = false);

    // 3. Respuesta del servidor
    if (result['status'] == 'success') {
      _showSuccess("¡Cuenta creada! Ahora inicia sesión.");
      if (!mounted) return;
      Navigator.pop(context); // Regresa al Login
    } else {
      _showError(result['message'] ?? "Error al registrar");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Crea tu cuenta",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Únete a la comunidad Nequi",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  _buildInput(controller: _nameController, label: "Nombre completo", icon: Icons.person_outline),
                  const SizedBox(height: 20),
                  _buildInput(controller: _phoneController, label: "Número de celular", icon: Icons.phone_android, keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  _buildInput(controller: _pinController, label: "Crea tu PIN (4 dígitos)", icon: Icons.lock_outline, obscureText: true, keyboardType: TextInputType.number, maxLength: 4),
                  const SizedBox(height: 20),
                  _buildInput(controller: _confirmPinController, label: "Confirma tu PIN", icon: Icons.lock_clock_outlined, obscureText: true, keyboardType: TextInputType.number, maxLength: 4),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Registrarme", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: darkPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: nequiPink, width: 2), borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}