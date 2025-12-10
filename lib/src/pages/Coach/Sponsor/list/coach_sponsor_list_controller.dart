import 'package:get/get.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../models/sponsor.dart';
import '../../../../providers/sponsor_provider.dart';

class CoachSponsorListController extends GetxController {
  final SponsorProvider provider = SponsorProvider();

  RxList<Sponsor> sponsors = <Sponsor>[].obs;

  @override
  void onInit() {
    super.onInit();
    getSponsors();

    // Eventos en tiempo real
    SocketService().on('sponsor:new', (_) => getSponsors());
    SocketService().on('sponsor:update', (_) => getSponsors());
    SocketService().on('sponsor:delete', (_) => getSponsors());
  }

  void getSponsors() async {
    final list = await provider.getAll();

    // 🔥 Filtrar solo sponsors para COACHES
    sponsors.value = list.where((s) {
      return s.target == "coach" || s.target == "both";
    }).toList();
  }

  @override
  void refresh() {
    getSponsors();
  }
}
