import 'package:get/get.dart';

import '../../../../components/Socket/socket_service.dart';
import '../../../../models/sponsor.dart';
import '../../../../providers/sponsor_provider.dart';


class UserSponsorListController extends GetxController {
  final SponsorProvider provider = SponsorProvider();

  RxList<Sponsor> sponsors = <Sponsor>[].obs;

  @override
  void onInit() {
    super.onInit();
    getSponsors();

    // tiempo real
    SocketService().on('sponsor:new', (_) => getSponsors());
    SocketService().on('sponsor:update', (_) => getSponsors());
    SocketService().on('sponsor:delete', (_) => getSponsors());
  }

  void getSponsors() async {
    sponsors.value = await provider.getAll();
  }

  @override
  void refresh() {
    getSponsors();
  }
}
