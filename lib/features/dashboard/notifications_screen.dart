import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Color darkPurple = const Color(0xFF2C004F);
  final Color nequiPink = const Color(0xFFE80070);

  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  // --- OBTENER SOLICITUDES (CORREGIDO) ---
  Future<void> _fetchRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");

    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // Agregamos un tiempo de espera de 10 segundos
      final response = await http.get(
          Uri.parse("http://10.0.2.2/nequi_api/get_requests.php?usuario_id=$userId")
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          if (mounted) {
            setState(() {
              _requests = data['data'];
            });
          }
        } else {
          _showSnackBar(data['message'] ?? "Error al cargar datos", Colors.orange);
        }
      } else {
        _showSnackBar("Error de servidor: ${response.statusCode}", Colors.redAccent);
      }
    } catch (e) {
      debugPrint("Error en fetch: $e");
      _showSnackBar("Sin respuesta del servidor. Revisa tu conexión.", Colors.redAccent);
    } finally {
      // ESTA ES LA CLAVE: El cargador se apaga siempre al final
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- PROCESAR PAGO O RECHAZO ---
  Future<void> _processRequest(String solicitudId, String accion) async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2/nequi_api/responder_solicitud.php"),
        body: {
          "solicitud_id": solicitudId,
          "accion": accion,
        },
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _showSnackBar(data['message'], Colors.green);
        _fetchRequests(); // Recargamos la lista automáticamente
      } else {
        _showSnackBar(data['message'], Colors.redAccent);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar("Error de red al procesar", Colors.redAccent);
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: darkPurple,
        elevation: 0,
        title: const Text("Notificaciones", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // Enviamos 'true' al volver para que el Dashboard refresque el saldo
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRequests,
        color: nequiPink,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _requests.isEmpty
            ? _buildEmptyState()
            : _buildRequestList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            children: [
              Icon(Icons.notifications_none_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 10),
              Text("No tienes solicitudes pendientes", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final req = _requests[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundColor: nequiPink.withOpacity(0.1), child: Icon(Icons.person, color: nequiPink)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(req['solicitante_nombre'] ?? "Usuario", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Te pide plata", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ),
                  Text("\$ ${req['monto']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                ],
              ),
              if (req['mensaje'] != null && req['mensaje'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text("\"${req['mensaje']}\"", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _processRequest(req['id'].toString(), 'rechazada'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Rechazar", style: TextStyle(color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _processRequest(req['id'].toString(), 'aceptada'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: nequiPink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text("Pagar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}