import 'package:get/get.dart';

import '../../../../../components/Socket/socket_service.dart';
import '../../../../../models/sponsor.dart';
import '../../../../../providers/sponsor_provider.dart';

class AdminSponsorListController extends GetxController {
  final SponsorProvider sponsorProvider = SponsorProvider();

  // Lista reactiva de sponsors
  var sponsors = <Sponsor>[].obs;

  @override
  void onInit() {
    super.onInit();
    getSponsors();

    // 🔄 Escuchar cambios en tiempo real (mismos eventos que planes)
    SocketService().on('sponsor:new', (data) {
      getSponsors();
    });

    SocketService().on('sponsor:delete', (data) {
      getSponsors();
    });

    SocketService().on('sponsor:update', (data) {
      getSponsors();
    });
  }

  void getSponsors() async {
    final result = await sponsorProvider.getAll();
    sponsors.value = result;
  }

  @override
  void refresh() {
    getSponsors();
  }

  void deleteSponsor(String id) async {
    final res = await sponsorProvider.deleteSponsor(id);
    if (res.statusCode == 201 || res.statusCode == 200) {
      Get.snackbar('Éxito', 'Sponsor eliminado correctamente');
      getSponsors(); // recargar lista
    } else {
      Get.snackbar('Error', 'No se pudo eliminar el sponsor');
    }
  }
}
