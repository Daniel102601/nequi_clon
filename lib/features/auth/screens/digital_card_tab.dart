import 'package:flutter/material.dart';

class DigitalCardTab extends StatefulWidget {
  const DigitalCardTab({super.key});

  @override
  State<DigitalCardTab> createState() => _DigitalCardTabState();
}

class _DigitalCardTabState extends State<DigitalCardTab> {
  // Estados de la tarjeta
  bool isFrozen = false;
  bool showDetails = false;

  // Variables configurables de la tarjeta
  Color _currentCardColor = const Color(0xFF2C004F); // Morado Nequi por defecto
  bool _allowOnlinePurchases = true;
  bool _allowIntlPurchases = false;

  // Lista dinámica de suscripciones
  List<Map<String, dynamic>> _subscriptions = [
    {"name": "Netflix", "amount": "\$ 26.900", "icon": Icons.movie, "color": Colors.red},
    {"name": "Spotify", "amount": "\$ 16.900", "icon": Icons.music_note, "color": Colors.green},
  ];

  final Color nequiPink = const Color(0xFFE80070);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// HEADER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          width: double.infinity,
          color: const Color(0xFF2C004F),
          child: const Text(
            "Tu Tarjeta",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),

        /// CONTENIDO
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 1. Diseño visual de la tarjeta
                _buildCardVisual(),

                const SizedBox(height: 35),

                // 2. Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: showDetails ? Icons.visibility_off : Icons.visibility,
                      label: showDetails ? "Ocultar" : "Ver datos",
                      onTap: () {
                        setState(() {
                          showDetails = !showDetails;
                        });
                      },
                    ),
                    _buildActionButton(
                      icon: isFrozen ? Icons.ac_unit : Icons.pause,
                      label: isFrozen ? "Descongelar" : "Congelar",
                      color: isFrozen ? Colors.blue.shade400 : null,
                      onTap: () {
                        setState(() {
                          isFrozen = !isFrozen;
                          if (isFrozen) showDetails = false;
                        });
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.palette, // Cambiado el ícono para que sea más claro
                      label: "Color",
                      onTap: () => _showSettingsSheet(context),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 3. Opciones adicionales de la tarjeta
                _buildMenuOption(
                  icon: Icons.receipt_long,
                  title: "Tus suscripciones",
                  subtitle: "${_subscriptions.length} servicios activos",
                  onTap: () => _showSubscriptionsSheet(context),
                ),
                _buildMenuOption(
                  icon: Icons.security,
                  title: "Seguridad y topes",
                  subtitle: "Ajusta compras online e intl.",
                  onTap: () => _showSecuritySheet(context),
                ),
                _buildMenuOption(
                  icon: Icons.help_outline,
                  title: "Ayuda con tu tarjeta",
                  subtitle: "4x1000, cobros y soporte",
                  onTap: () => _showHelpSheet(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // WIDGETS DE LA INTERFAZ
  // ==========================================

  // WIDGET: La tarjeta de crédito dibujada con estilo Premium
  Widget _buildCardVisual() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isFrozen ? 0.8 : 1.0,
      child: Container(
        width: double.infinity,
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // El color ahora es dinámico y depende de la variable _currentCardColor
          gradient: LinearGradient(
            colors: isFrozen
                ? [Colors.grey.shade600, Colors.grey.shade800]
                : [_currentCardColor, _currentCardColor.withBlue(150)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isFrozen ? Colors.grey : _currentCardColor).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Stack(
          children: [
            // Efecto Glassmorphism (Círculos decorativos)
            Positioned(
              right: -50,
              top: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white.withOpacity(0.08),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white.withOpacity(0.08),
              ),
            ),

            // Contenido real de la tarjeta
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Fila superior: Logo y Contactless
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "nequi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const Icon(Icons.contactless, color: Colors.white, size: 30),
                    ],
                  ),

                  // Chip de la tarjeta mejorado
                  Container(
                    width: 45,
                    height: 35,
                    decoration: BoxDecoration(
                        color: Colors.amber.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade500, width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(1, 2))
                        ]
                    ),
                    child: Center(
                      child: Icon(Icons.memory, color: Colors.amber.shade900, size: 28),
                    ),
                  ),

                  // Fila inferior: Números, Nombre y Logo Franquicia
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showDetails ? "4123  5678  9012  3456" : "••••  ••••  ••••  3456",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          letterSpacing: showDetails ? 3 : 4,
                          fontFamily: 'monospace',
                          shadows: [Shadow(color: Colors.black.withOpacity(0.3), offset: const Offset(1, 1), blurRadius: 2)],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                showDetails ? "VÁLIDA HASTA: 12/28   CVV: 123" : "VÁLIDA HASTA: ••/••   CVV: •••",
                                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "DANIEL PEREZ",
                                style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          // Logo simulado de Mastercard
                          SizedBox(
                            width: 50,
                            height: 30,
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 20,
                                  child: CircleAvatar(radius: 15, backgroundColor: Colors.red.withOpacity(0.8)),
                                ),
                                Positioned(
                                  right: 0,
                                  child: CircleAvatar(radius: 15, backgroundColor: Colors.orange.withOpacity(0.8)),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Icon(icon, color: color ?? const Color(0xFF2C004F), size: 28),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMenuOption({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
            ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: nequiPink.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: nequiPink, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BOTTOM SHEETS (MENÚS DESPLEGABLES INTERACTIVOS)
  // ==========================================

  // 1. Selector de Color de Tarjeta
  void _showSettingsSheet(BuildContext context) {
    // Colores disponibles
    final List<Color> availableColors = [
      const Color(0xFF2C004F), // Morado original
      const Color(0xFF1E1E1E), // Negro
      const Color(0xFF004D40), // Verde oscuro
      const Color(0xFF0D47A1), // Azul profundo
      const Color(0xFFE80070), // Fucsia
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Elige el color de tu tarjeta", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: availableColors.map((color) {
                bool isSelected = _currentCardColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentCardColor = color; // Actualiza el estado principal
                    });
                    Navigator.pop(context); // Cierra el menú al elegir
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: nequiPink, width: 3) : null,
                        boxShadow: [
                          BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                        ]
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 2. Suscripciones dinámicas con StatefulBuilder
  void _showSubscriptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que ocupe más pantalla si hay teclado
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24, // Ajusta si sale el teclado
                  top: 24, left: 24, right: 24
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tus Suscripciones", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Cobros asociados a esta tarjeta:", style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 15),

                  // Lista de suscripciones
                  if (_subscriptions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text("No tienes suscripciones activas.")),
                    )
                  else
                    ..._subscriptions.map((sub) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(sub["icon"], color: sub["color"], size: 30),
                      title: Text(sub["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(sub["amount"], style: const TextStyle(fontSize: 16)),
                    )),

                  const Divider(height: 30),

                  // Botón para añadir una nueva
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _showAddSubscriptionDialog(setModalState),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text("Vincular nuevo comercio"),
                      style: TextButton.styleFrom(foregroundColor: nequiPink),
                    ),
                  )
                ],
              ),
            );
          }
      ),
    );
  }

  // Diálogo para agregar una nueva suscripción
  void _showAddSubscriptionDialog(StateSetter setModalState) {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva Suscripción"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Comercio (ej. Amazon)")),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Valor (ej. \$ 15.000)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: nequiPink),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                // Actualizamos el estado de la hoja de abajo y el estado global
                setModalState(() {
                  _subscriptions.add({
                    "name": nameCtrl.text,
                    "amount": amountCtrl.text,
                    "icon": Icons.shopping_bag,
                    "color": Colors.blue,
                  });
                });
                setState(() {}); // Actualiza el subtítulo en la pantalla principal
                Navigator.pop(context);
              }
            },
            child: const Text("Añadir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 3. Menú de Seguridad con Switches interactivos
  void _showSecuritySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder( // Necesario para que los switches se muevan al tocarlos
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Seguridad y Topes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Compras por internet", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Pagar en webs y aplicaciones"),
                    value: _allowOnlinePurchases,
                    activeColor: nequiPink,
                    onChanged: (bool value) {
                      setModalState(() => _allowOnlinePurchases = value); // Actualiza el BottomSheet
                      setState(() => _allowOnlinePurchases = value); // Actualiza la pantalla global
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Compras internacionales", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Habilitar pagos en dólares u otras monedas"),
                    value: _allowIntlPurchases,
                    activeColor: nequiPink,
                    onChanged: (bool value) {
                      setModalState(() => _allowIntlPurchases = value);
                      setState(() => _allowIntlPurchases = value);
                    },
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  // 4. Ayuda con explicación del 4x1000
  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ayuda", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle), child: const Icon(Icons.account_balance, color: Colors.blue)),
              title: const Text("¿Cómo funciona el 4x1000?", style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context); // Cierra el bottom sheet
                _show4x1000Explanation(context); // Abre el cuadro de diálogo
              },
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle), child: const Icon(Icons.support_agent, color: Colors.green)),
              title: const Text("Chatear con soporte", style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // Cuadro de diálogo explicativo para el 4x1000
  void _show4x1000Explanation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Color(0xFFE80070)),
            SizedBox(width: 10),
            Text("Sobre el 4x1000")
          ],
        ),
        content: const Text(
          "El Gravamen a los Movimientos Financieros (GMF), más conocido como 4x1000, es un impuesto del Gobierno de Colombia.\n\n"
              "Significa que por cada \$1.000 pesos que saques, envíes o pagues, el banco retiene \$4 pesos para el gobierno.\n\n"
              "💡 Tip: Por ley puedes tener UNA cuenta en el país exenta de este cobro hasta por un tope mensual de movimientos. Si quieres eximir tu Nequi, ve a los ajustes de tu perfil.",
          style: TextStyle(height: 1.4, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
    );
  }
}