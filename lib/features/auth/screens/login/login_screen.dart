import 'package:flutter/material.dart';
import '../../../../services/auth_service.dart';
import '../../../dashboard/dashboard_screen.dart';
import '../register/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isPinVisible = false;

  final Color darkPurple = const Color(0xFF2C004F);
  final Color nequiPink = const Color(0xFFE80070);

  void _handleLogin() async {
    if (_phoneController.text.length < 10 || _pinController.text.length < 4) {
      _showSnackBar("Por favor, completa tus datos");
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authService.login(_phoneController.text, _pinController.text);

    if (mounted) setState(() => _isLoading = false);

    if (result['status'] == 'success') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } else {
      _showSnackBar(result['message'] ?? "Error al ingresar");
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: nequiPink));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER CURVO ESTILO NEQUI ---
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                color: nequiPink,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(80)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.face, size: 80, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "nequi",
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

            // --- FORMULARIO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("¡Bienvenido!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Entra a tu cuenta para manejar tu plata.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),

                  const SizedBox(height: 40),

                  // INPUT TELÉFONO
                  _buildStyledInput(
                    controller: _phoneController,
                    label: "Número de celular",
                    icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                  ),

                  const SizedBox(height: 30),

                  // INPUT PIN
                  _buildStyledInput(
                    controller: _pinController,
                    label: "Tu clave de 4 dígitos",
                    icon: Icons.lock_outline,
                    keyboardType: TextInputType.number,
                    obscureText: !_isPinVisible,
                    maxLength: 4,
                    suffixIcon: IconButton(
                      icon: Icon(_isPinVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: () => setState(() => _isPinVisible = !_isPinVisible),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // BOTÓN DE ENTRADA
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Entrar", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // REGISTRO
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: RichText(
                        text: TextSpan(
                          text: "¿No tienes cuenta? ",
                          style: const TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(text: "Crea una", style: TextStyle(color: nequiPink, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET PARA INPUTS ESTILIZADOS
  Widget _buildStyledInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    int? maxLength,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          decoration: InputDecoration(
            counterText: "",
            prefixIcon: Icon(icon, color: nequiPink, size: 20),
            suffixIcon: suffixIcon,
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: nequiPink, width: 2)),
          ),
        ),
      ],
    );
  }
}