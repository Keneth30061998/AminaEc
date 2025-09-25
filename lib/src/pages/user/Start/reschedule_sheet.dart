// lib/src/pages/user/Start/reschedule_sheet.dart

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
    dates = await classProv.getAvailableDates(
      coachId: selectedCoach,
    );
    if (dates.isNotEmpty && !dates.contains(selectedDate)) {
      selectedDate = dates.first;
    }
    await _loadTimes();
    setState(() {});
  }

  Future<void> _loadTimes() async {
    final coach = widget.coaches.firstWhere((c) => c.id == selectedCoach);
    final dateSchedules = coach.schedules.where((s) => s.date == selectedDate);

    times = dateSchedules
        .map((s) => s.start_time ?? '')
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    if (times.isNotEmpty && !times.contains(selectedTime)) {
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
    if (bikes.isNotEmpty && !bikes.contains(selectedBike)) {
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
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Reagendar Clase', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            // Coach
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Coach'),
              value: widget.coaches
                      .map((c) => c.id)
                      .toSet()
                      .contains(selectedCoach)
                  ? selectedCoach
                  : null,
              items: widget.coaches.map((c) => c.id!).toSet().map((id) {
                final coach = widget.coaches.firstWhere((c) => c.id == id);
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(coach.user?.name ?? ''),
                );
              }).toList(),
              onChanged: (v) {
                if (v == null) return;
                selectedCoach = v;
                dates = [];
                times = [];
                bikes = [];
                _loadDates();
              },
            ),

            const SizedBox(height: 12),

            // Fecha
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Fecha'),
              value: dates.contains(selectedDate) ? selectedDate : null,
              items: dates.map((d) {
                return DropdownMenuItem<String>(
                  value: d,
                  child: Text(DateFormat.yMd().format(DateTime.parse(d))),
                );
              }).toList(),
              onChanged: (v) {
                if (v == null) return;
                selectedDate = v;
                times = [];
                bikes = [];
                _loadTimes();
              },
            ),

            const SizedBox(height: 12),

            // Hora
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Hora'),
              value: times.contains(selectedTime) ? selectedTime : null,
              items: times.map((t) {
                return DropdownMenuItem<String>(
                  value: t,
                  child: Text(t.substring(0, 5)),
                );
              }).toList(),
              onChanged: (v) {
                if (v == null) return;
                selectedTime = v;
                bikes = [];
                _loadBikes();
              },
            ),

            const SizedBox(height: 12),

            // Máquina
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Máquina'),
              value: bikes.contains(selectedBike) ? selectedBike : null,
              items: bikes.map((b) {
                return DropdownMenuItem<int>(
                  value: b,
                  child: Text('Bicicleta $b'),
                );
              }).toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  selectedBike = v;
                });
              },
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              child: Text('Confirmar'),
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
                  Get.snackbar('Éxito', resp.message ?? 'Reagendada');
                } else {
                  Get.snackbar('Error', resp.message ?? 'Falló');
                }
              },
            ),
          ]),
        ),
      ),
    );
  }
}
