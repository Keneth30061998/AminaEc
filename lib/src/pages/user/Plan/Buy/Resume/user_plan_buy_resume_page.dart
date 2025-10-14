import 'package:amina_ec/src/pages/user/Plan/Buy/Resume/user_plan_buy_resume_controller.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../models/card.dart';
import '../../../../../utils/iconos.dart';
import '../AddCard/user_plan_buy_addCard_webview_page.dart';

class UserPlanBuyResumePage extends StatelessWidget {
  final UserPlanBuyResumeController con =
  Get.put(UserPlanBuyResumeController());

  UserPlanBuyResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Resumen de la compra',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: almostBlack,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '* Revise que los datos estén correctos',
            style: GoogleFonts.roboto(
              color: darkGrey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 10),

          // Datos del plan
          Card(
            elevation: 0,
            color: colorBackgroundBox,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Paquete seleccionado", con.plan.name!),
                  _buildInfoRow("Rides acreditados", "${con.plan.rides}"),
                  const Divider(height: 32),
                  _buildInfoRow("Subtotal",
                      "${con.calculateSubtotal().toStringAsFixed(2)} USD"),
                  _buildInfoRow("IVA (15%)",
                      "${con.calculateIVA().toStringAsFixed(2)} USD"),
                  const Divider(height: 32),
                  _buildInfoRow(
                    "Total",
                    "${con.calculateTotal().toStringAsFixed(2)} USD",
                    highlight: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Mensaje ultra visual de flujo de pago
          Card(
            color: colorBackgroundBox,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(iconInfo, color: Colors.blue, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Cómo se realiza el pago',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Paso 1 - Selección de tarjeta
                  _buildStep(
                    stepNumber: '1',
                    icon: iconCard,
                    title: 'Selecciona tarjeta',
                    description:
                    'Elige una tarjeta existente o agrega una nueva.',
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 15),

                  // Paso 2 - OTP
                  _buildStep(
                    stepNumber: '2',
                    icon: iconSMS,
                    title: 'Recibe OTP',
                    description:
                    'Tu banco puede enviarte un código a tu correo o teléfono para verificar la tarjeta.',
                    color: indigoAmina,
                  ),

                  const SizedBox(height: 15),

                  // Paso 3 - Confirmación
                  _buildStep(
                    stepNumber: '3',
                    icon: iconCheck,
                    title: 'Confirma y paga',
                    description:
                    'Ingresa el código cuando se solicite para completar la compra y acreditar tu plan.',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            'Método de pago',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGrey,
            ),
          ),
          const SizedBox(height: 12),

          Obx(() {
            if (con.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (con.cards.isEmpty) {
              return Text(
                'No tienes tarjetas registradas',
                style: GoogleFonts.roboto(color: Colors.grey),
              );
            }

            // Tarjetas estilizadas
            return Column(
              children: con.cards.map((card) {
                return GestureDetector(
                  onTap: () {
                    con.payWithToken(card);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: darkGrey,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 10,
                          top: 35,
                          child: IconButton(
                            onPressed: () {
                              _confirmDelete(card);
                            },
                            icon: Icon(
                              iconDelete,
                              color: Colors.white70,
                            ),
                          ),
                        ),

                        // Contenido principal tarjeta
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Número Datos Tarjetas
                              Text(
                                "${card.bank}",
                                style: GoogleFonts.robotoMono(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "${card.bin} ** **** ${card.last4 ?? '0000'}",
                                style: GoogleFonts.robotoMono(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Titular y fecha
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${card.expiryMonth?.toString().padLeft(2, '0')}/${card.expiryYear?.toString().substring(2) ?? '00'}",
                                    style: GoogleFonts.roboto(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 30),

          FilledButton.icon(
            onPressed: () async {
              // Lanza la WebView directamente
              final added = await Get.to<bool?>(
                    () => AddCardWebViewPage(),
                arguments: {
                  'userId': con.user.id.toString(),
                  'email': con.user.email!,
                },
              );

              // Si viene true, recarga la lista
              if (added == true) {
                con.loadCards();
              }
            },
            icon: const Icon(iconAdd),
            label: const Text("Agregar Tarjeta"),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(55),
              backgroundColor: almostBlack,
              foregroundColor: Colors.white,
              textStyle: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: highlight ? indigoAmina : almostBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String stepNumber,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$stepNumber. $title',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(CardModel card) {
    Get.defaultDialog(
      title: 'Eliminar tarjeta',
      middleText: '¿Deseas eliminar ${card.displayName}?',
      middleTextStyle: TextStyle(color: almostBlack),
      buttonColor: Colors.black54,
      cancelTextColor: whiteGrey,
      onConfirm: () {
        con.deleteCard(card.token!);
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }
}
