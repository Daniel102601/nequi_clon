import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // El cliente HTTP ahora es una variable de clase
  final http.Client _client;

  // Constructor: Si no se recibe un cliente, usa el por defecto de Flutter
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  // IP para emulador Android: 10.0.2.2
  final String _baseUrl = "http://10.0.2.2/nequi_api";

  // Llaves para SharedPreferences
  static const String _keyLogged = "is_logged_in";
  static const String _keyUserId = "user_id";
  static const String _keyUserName = "user_name";

  // Verificar si hay sesión activa
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLogged) ?? false;
  }

  // Obtener el ID del usuario
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // --- LOGIN REAL (USANDO EL CLIENTE INYECTADO) ---
  Future<Map<String, dynamic>> login(String telefono, String pin) async {
    try {
      // Usamos _client en lugar de http.post directamente
      final response = await _client.post(
        Uri.parse("$_baseUrl/login.php"),
        body: {
          "telefono": telefono,
          "pin": pin,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyLogged, true);
        await prefs.setString(_keyUserId, data['data']['id'].toString());
        await prefs.setString(_keyUserName, data['data']['nombre']);
        return data;
      } else {
        return {"status": "error", "message": data['message'] ?? "Error de credenciales"};
      }
    } catch (e) {
      return {"status": "error", "message": "Error de conexión: $e"};
    }
  }

  // --- REGISTRO REAL ---
  Future<Map<String, dynamic>> register(String nombre, String telefono, String pin) async {
    try {
      final response = await _client.post(
        Uri.parse("$_baseUrl/register.php"),
        body: {
          "nombre": nombre,
          "telefono": telefono,
          "pin": pin,
        },
      );

      return json.decode(response.body);
    } catch (e) {
      return {"status": "error", "message": "No se pudo registrar: $e"};
    }
  }

  // --- CERRAR SESIÓN ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}