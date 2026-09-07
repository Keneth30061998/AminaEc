import 'package:flutter/material.dart';
import '../../../providers/notifications_provider.dart';
import '../Shared/admin_ui.dart';

class AdminNotificationPage extends StatefulWidget {
  const AdminNotificationPage({super.key});
  @override
  State<AdminNotificationPage> createState() => _AdminNotificationPageState();
}

class _AdminNotificationPageState extends State<AdminNotificationPage> {
  final title = TextEditingController();
  final message = TextEditingController();
  final provider = NotificationsProvider();
  String? emoji;
  bool sending = false;
  @override
  void dispose() {
    title.dispose();
    message.dispose();
    super.dispose();
  }

  Future<void> send() async {
    if (sending) return;
    if (title.text.trim().isEmpty || emoji == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Debe ingresar un título y elegir un emoji')));
      return;
    }
    setState(() => sending = true);
    try {
      final result = await provider.sendGlobalNotification(
          '${title.text.trim()} $emoji', message.text.trim());
      if (!mounted) return;
      final success = result['success'] == true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? 'Notificación enviada correctamente'
              : '${result['message'] ?? 'No se pudo enviar la notificación'}')));
      if (success) {
        title.clear();
        message.clear();
        setState(() => emoji = null);
      }
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'No se pudo enviar la notificación. Intenta nuevamente.')));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !sending,
        child: Scaffold(
          appBar: AppBar(title: const Text('Notificaciones')),
          body: ListView(padding: const EdgeInsets.all(20), children: [
            const Text('Enviar a todos los usuarios',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
            const SizedBox(height: 8),
            const Text(
                'Escribe el título, selecciona un emoji y añade el mensaje.',
                style: TextStyle(color: AdminUi.muted)),
            const SizedBox(height: 24),
            TextField(
                controller: title,
                enabled: !sending,
                decoration: const InputDecoration(labelText: 'Título')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
                value: emoji,
                decoration: const InputDecoration(labelText: 'Emoji'),
                items: const [
                  '🔴',
                  '🟠',
                  '🟡',
                  '🟢',
                  '⏱️',
                  '🚴‍♂️',
                  '🚨',
                  '⏳',
                  '🎵'
                ]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged:
                    sending ? null : (value) => setState(() => emoji = value)),
            const SizedBox(height: 16),
            TextField(
                controller: message,
                enabled: !sending,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Mensaje')),
            const SizedBox(height: 24),
            FilledButton.icon(
                onPressed: sending ? null : send,
                icon: const Icon(Icons.send_outlined),
                label: Text(sending ? 'Enviando…' : 'Enviar notificación')),
          ]),
        ),
      );
}
