import 'package:amina_ec/src/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/coach.dart';
import '../../../models/scheduled_class.dart';
import '../../../providers/class_reservation_provider.dart';

class RescheduleSheet extends StatefulWidget {
  final ScheduledClass reservation;
  final List<Coach> coaches;
  final VoidCallback onSuccess;

  const RescheduleSheet({
    Key? key,
    required this.reservation,
    required this.coaches,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _RescheduleSheetState createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<RescheduleSheet> {
  late String selectedCoach;
  late String selectedDate;
  late String selectedTime;
  late int selectedBike;

  List<String> dates = [];
  List<String> times = [];
  List<int> bikes = [];

  final classProv = ClassReservationProvider();

  @override
  void initState() {
    super.initState();
    selectedCoach = widget.reservation.coachId;
    selectedDate = widget.reservation.classDate.split('T').first;
    selectedTime = widget.reservation.classTime;
    selectedBike = widget.reservation.bicycle;
    _loadDates();
  }

  Future<void> _loadDates() async {
    dates = await classProv.getAvailableDates(coachId: selectedCoach);
    if (!dates.contains(selectedDate) && dates.isNotEmpty) {
      selectedDate = dates.first;
    }
    await _loadTimes();
    setState(() {});
  }

  Future<void> _loadTimes() async {
    times = await classProv.getAvailableTimes(
      coachId: selectedCoach,
      date: selectedDate,
    );
    if (!times.contains(selectedTime) && times.isNotEmpty) {
      selectedTime = times.first;
    }
    await _loadBikes();
    setState(() {});
  }

  Future<void> _loadBikes() async {
    bikes = await classProv.getAvailableBikes(
      coachId: selectedCoach,
      date: selectedDate,
      time: selectedTime,
    );
    if (!bikes.contains(selectedBike) && bikes.isNotEmpty) {
      selectedBike = bikes.first;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                'Reagendar Clase',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: indigoAmina,
                ),
              ),
              const SizedBox(height: 20),

              // Coach
              _buildDropdown<String>(
                label: "Coach",
                value: widget.coaches
                        .map((c) => c.id)
                        .toSet()
                        .contains(selectedCoach)
                    ? selectedCoach
                    : null,
                items: widget.coaches.map((c) {
                  return DropdownMenuItem<String>(
                    value: c.id!,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(c.user?.photo_url ?? ""),
                          radius: 16,
                        ),
                        const SizedBox(width: 10),
                        Text(c.user?.name ?? ''),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    selectedCoach = v;
                    dates = [];
                    times = [];
                    bikes = [];
                  });
                  _loadDates();
                },
              ),

              const SizedBox(height: 16),

              // Fecha
              _buildDropdown<String>(
                label: "Fecha",
                value: dates.contains(selectedDate) ? selectedDate : null,
                items: dates.map((d) {
                  return DropdownMenuItem<String>(
                    value: d,
                    child: Text(
                      DateFormat.yMMMMd().format(DateTime.parse(d)),
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    selectedDate = v;
                    times = [];
                    bikes = [];
                  });
                  _loadTimes();
                },
              ),

              const SizedBox(height: 16),

              // Hora
              _buildDropdown<String>(
                label: "Hora",
                value: times.contains(selectedTime) ? selectedTime : null,
                items: times.map((t) {
                  return DropdownMenuItem<String>(
                    value: t,
                    child: Text(t.substring(0, 5)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    selectedTime = v;
                    bikes = [];
                  });
                  _loadBikes();
                },
              ),

              const SizedBox(height: 16),

              // Bicicleta (ahora chips en vez de dropdown)
              // Bicicletas estilo "asientos de cine"
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Selecciona tu bicicleta",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: indigoAmina,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 5 bicis por fila, ajusta según diseño
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: bikes.length,
                itemBuilder: (context, index) {
                  final b = bikes[index];
                  final isSelected = b == selectedBike;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedBike = b);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? limeGreen : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? whiteGrey : Colors.grey.shade400,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: whiteGrey,
                                  blurRadius: 4,
                                  offset: const Offset(2, 3),
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          "$b",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? almostBlack : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: almostBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text(
                    'Confirmar',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  onPressed: () async {
                    final resp = await classProv.rescheduleClass(
                      reservationId: widget.reservation.id,
                      newDate: selectedDate,
                      newTime: selectedTime,
                      newCoachId: selectedCoach,
                      newBicycle: selectedBike,
                    );
                    if (resp.success == true) {
                      Navigator.of(context).pop();
                      widget.onSuccess();
                      Get.snackbar(
                        'Éxito',
                        resp.message ?? 'Clase reagendada',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    } else {
                      Get.snackbar(
                        'Error',
                        resp.message ?? 'Falló el reagendamiento',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      initialValue: value,
      items: items,
      onChanged: onChanged,
    );
  }
}
