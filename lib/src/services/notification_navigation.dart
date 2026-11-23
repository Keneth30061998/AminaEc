import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user.dart';
import 'pending_navigation_service.dart';
import 'waitlist_service.dart';

void handleNotificationData(Map<String,dynamic> data){
  String? route;Map<String,dynamic> args={};
  if(data['type']=='reservation_queue_offer' && data['queue_id']!=null){
    route='/user/waitlist';args={'queue_id':'${data['queue_id']}',if(data['user_id']!=null)'target_user_id':'${data['user_id']}'};
  }else if(data['type']=='CLASS_RATING_REQUEST' && data['attendance_id']!=null){
    route='/user/class-rating';args={'attendanceId':'${data['attendance_id']}'};
  }
  if(route==null)return;
  PendingNavigationService.setPendingRoute(route:route,arguments:args);
  processPendingNotificationNavigation();
}
bool processPendingNotificationNavigation(){
  final user=User.fromJson(GetStorage().read('user') ?? {});
  if(user.session_token?.isNotEmpty!=true || Get.key.currentState==null)return false;
  if(!(user.roles?.any((r)=>r.id=='2') ?? false))return false;
  final pending=PendingNavigationService.consumePendingRoute();
  if(pending==null)return false;
  final route='${pending['route']}',args=Map<String,dynamic>.from(pending['arguments'] ?? {});
  if(args['target_user_id']!=null && '${args['target_user_id']}'!=user.id){
    Get.snackbar('Notificación','Esta notificación corresponde a otra sesión.');return true;
  }
  if(route=='/user/waitlist' && Get.isRegistered<WaitlistService>()){
    WaitlistService.to.openList(queueId:args['queue_id']?.toString(),targetUserId:args['target_user_id']?.toString());
  }else if(Get.currentRoute!=route){Get.toNamed(route,arguments:args);}
  return true;
}
