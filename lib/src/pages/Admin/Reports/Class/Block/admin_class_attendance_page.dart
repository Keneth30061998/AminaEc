import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Start/admin_start_controller.dart';
import '../../../../../widgets/student_attendance_card.dart';

class AdminClassAttendancePage extends StatefulWidget {
  final String coachId;
  final String coachName;
  final DateTime date;
  final String classTime;
  const AdminClassAttendancePage(
      {super.key,
      required this.coachId,
      required this.coachName,
      required this.date,
      required this.classTime});
  @override
  State<AdminClassAttendancePage> createState() =>
      _AdminClassAttendancePageState();
}

class _AdminClassAttendancePageState extends State<AdminClassAttendancePage> {
  final con = Get.find<AdminStartController>();
  bool loading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await con.loadStudents(widget.coachId);
      if (mounted)
        setState(() {
          loading = false;
          error = null;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          loading = false;
          error = 'No se pudieron cargar los alumnos.';
        });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Asistencia de la clase')),
        body: Column(children: [
          ListTile(
              title: Text(widget.coachName),
              subtitle: Text(
                  '${widget.date.day}/${widget.date.month}/${widget.date.year} · ${widget.classTime}')),
          Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? Center(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              Text(error!),
                              TextButton(
                                  onPressed: _load,
                                  child: const Text('Reintentar'))
                            ]))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: StudentAttendanceCard(
                              coachId: widget.coachId,
                              date: widget.date,
                              onlyClassTime: widget.classTime))),
        ]),
      );
}
