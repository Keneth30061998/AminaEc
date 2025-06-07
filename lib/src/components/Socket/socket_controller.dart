import 'package:amina_ec/src/components/Socket/socket_service.dart';

import '../../models/plan.dart';

class SocketController {
  final _socket = SocketService().socket;

  void listenForNewPlans(Function(Plan) onNewPlan) {
    _socket.on('plan:new', (data) {
      final plan = Plan.fromJson(data);
      onNewPlan(plan);
    });
  }
}
