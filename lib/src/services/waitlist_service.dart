import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../components/Socket/socket_service.dart';
import '../models/user.dart';
import '../models/waitlist_entry.dart';
import '../models/response_api.dart';
import '../providers/reservation_queue_provider.dart';
import 'pending_navigation_service.dart';
import 'fcm_service.dart';
import 'calendar_sync_service.dart';
import '../providers/google_calendar_provider.dart';

class WaitlistService extends GetxService with WidgetsBindingObserver {
  static WaitlistService get to => Get.find<WaitlistService>();
  final provider=ReservationQueueProvider();
  final entries=<WaitlistEntry>[].obs;
  final loading=false.obs;
  final error=RxnString();
  final busyIds=<String>{}.obs;
  final now=DateTime.now().toUtc().obs;
  final List<void Function()> _subscriptions=[];
  final Set<String> _announced={};
  final Set<String> _calendarPending={};
  Timer? _poll,_clock;
  void Function()? _storageCancel;
  Future<void>? _refreshing;
  Duration _offset=Duration.zero;
  String _identity='';
  int _generation=0;
  bool _enabled=false;
  AppLifecycleState _lifecycle=AppLifecycleState.resumed;
  int get activeCount=>entries.where((e)=>e.active).length;
  int get offerCount=>entries.where((e)=>e.canAccept(now.value)).length;
  @override
  void onInit(){
    super.onInit();WidgetsBinding.instance.addObserver(this);
    final socket=SocketService();
    for(final event in ['queue:offer','queue:changed','queue:accepted','connect']){
      _subscriptions.add(socket.subscribe(event,(_)=>refresh(),persistent:true));
    }
    _subscriptions.add(socket.subscribe('waitlist:slot:changed',(data){
      if(data is Map && entries.any((e)=>e.active && e.classDate=='${data['class_date']}' &&
          e.classTime==WaitlistEntry.normalizeTime('${data['class_time']}')))refresh();
    },persistent:true));
    _storageCancel=GetStorage().listenKey('user',(value)=>sessionChanged(User.fromJson(value ?? {})));
    sessionChanged(User.fromJson(GetStorage().read('user') ?? {}));
    _poll=Timer.periodic(const Duration(seconds:20),(_){if(_lifecycle==AppLifecycleState.resumed)refresh();});
    _clock=Timer.periodic(const Duration(seconds:1),(_){if(_lifecycle==AppLifecycleState.resumed&&entries.any((e)=>e.status=='offered'))now.value=DateTime.now().toUtc().add(_offset);});
  }
  void sessionChanged(User user){
    if(_identity!='${user.id ?? ''}:${user.session_token ?? ''}'){
      _generation++;_identity='${user.id ?? ''}:${user.session_token ?? ''}';
      entries.clear();busyIds.clear();_announced.clear();error.value=null;loading.value=false;_refreshing=null;
    }
    _enabled=(user.session_token?.isNotEmpty==true) && (user.roles?.any((r)=>r.id=='2') ?? false);
    SocketService().updateUserSession(user);
    if(_enabled)refresh();
  }
  void syncClock(ResponseApi response){
    if(response.serverTime!=null){_offset=response.serverTime!.difference(DateTime.now().toUtc());}
    now.value=DateTime.now().toUtc().add(_offset);
  }
  Future<void> refresh({bool force=false}){
    if(force)return _forceRefresh();
    if(!_enabled)return Future.value();
    return _refreshing ??= _load(_generation);
  }
  Future<void> _forceRefresh() async {
    if(_refreshing!=null)await _refreshing;
    await refresh();
  }
  Future<void> _load(int generation) async {
    loading.value=true;
    try{
      final response=await provider.mine();
      if(generation!=_generation)return;
      syncClock(response);
      if(response.success!=true||response.data is! List){error.value=response.message ?? 'No se pudo consultar tu lista.';return;}
      error.value=null;
      entries.assignAll((response.data as List).whereType<Map>().map((e)=>WaitlistEntry.fromJson(Map<String,dynamic>.from(e))));
      for(final offer in entries.where((e)=>e.canAccept(now.value))){
        if(Get.key.currentState!=null && Get.currentRoute.startsWith('/user/') && _announced.add(offer.id)){
          Get.snackbar('Bicicleta disponible','Clase ${offer.classDate}, ${offer.classTime.substring(0,5)} · Bici #${offer.bicycle}',
              backgroundColor:Colors.black87,colorText:Colors.white,duration:const Duration(seconds:6),
              mainButton:TextButton(onPressed:()=>openList(queueId:offer.id),child:const Text('Ver oferta',style:TextStyle(color:Colors.white))));
        }
      }
    }catch(_){if(generation==_generation)error.value="No se pudo recuperar la cola. Actualiza para volver a consultar.";}finally{if(generation==_generation){loading.value=false;_refreshing=null;}}
  }
  void remember(WaitlistEntry entry){
    if(entry.userId!=User.fromJson(GetStorage().read('user') ?? {}).id)return;
    final index=entries.indexWhere((e)=>e.id==entry.id);
    if(index<0)entries.add(entry);else entries[index]=entry;
  }
  Future<void> _syncCalendar(WaitlistEntry entry,Map data,int generation) async {
    final id='${data['reservation_id'] ?? data['id'] ?? ''}';
    if(id.isEmpty||!_calendarPending.add(id))return;
    try{
      final connected=await GoogleCalendarProvider().status().timeout(const Duration(seconds:10));
      if(generation!=_generation||connected.success!=true||connected.data is! Map)return;
      if(connected.data['connected']==true)return; // El outbox sincroniza Google en el servidor.
      final start=DateTime.tryParse('${data['class_date'] ?? entry.classDate}T${data['class_time'] ?? entry.classTime}-05:00');
      if(start==null)return;
      await CalendarSyncService.instance.createOrUpdateEvent(reservationId:id,title:'AMINA — Clase con ${entry.coachName}',
          start:start,durationMinutes:50,description:'Bicicleta #${data['bicycle'] ?? entry.bicycle}',location:'AMINA Studio');
    }catch(_){/* Un permiso o error de calendario no cambia la reserva ya confirmada. */}
    finally{_calendarPending.remove(id);}
  }
  WaitlistEntry? activeFor(String day,String time,{String? scheduleId}){
    final matches=entries.where((e)=>e.active&&e.classDate==day.split('T').first &&
        e.classTime==WaitlistEntry.normalizeTime(time) && (scheduleId==null||scheduleId.isEmpty||e.scheduleId==scheduleId));
    return matches.isEmpty?null:matches.first;
  }
  Future<ResponseApi> act(WaitlistEntry entry,String action) async {
    if(busyIds.contains(entry.id))return ResponseApi(success:false,message:'Operación en curso.');
    busyIds.add(entry.id);final generation=_generation;
    try{
      final response=await (action=='accept'?provider.acceptOffer(entry.id):
      action=='reject'?provider.rejectOffer(entry.id):provider.cancelEntry(entry.id));
      if(generation!=_generation)return ResponseApi(success:false,message:'La sesión cambió.');
      syncClock(response);
      if(response.success==true && action=='accept' && response.data is Map){
        remember(entry.withStatus('accepted',reservationId:'${response.data['reservation_id'] ?? response.data['id']}'));
        unawaited(_syncCalendar(entry,response.data as Map,generation));
        SocketService().notifyLocal('class:coach:reserved',response.data);
        SocketService().notifyLocal('rides:updated',{'user_id':entry.userId});
      }
      if(response.success==true && action!='accept' && response.data is Map)remember(WaitlistEntry.fromJson(Map<String,dynamic>.from(response.data)));
      // Tras una respuesta incierta se consulta el servidor antes de ofrecer un reintento.
      if(_refreshing!=null)await _refreshing;
      await refresh();
      return response;
    }finally{busyIds.remove(entry.id);}
  }
  void openList({String? queueId,String? targetUserId}){
    final stored=User.fromJson(GetStorage().read('user') ?? {});
    final args=<String,dynamic>{if(queueId!=null)'queue_id':queueId,if(targetUserId!=null)'target_user_id':targetUserId};
    if(stored.session_token?.isNotEmpty!=true||Get.key.currentState==null){
      PendingNavigationService.setPendingRoute(route:'/user/waitlist',arguments:args);return;
    }
    if(targetUserId!=null&&targetUserId!=stored.id){Get.snackbar('Lista de espera','Esta notificación corresponde a otra sesión.');return;}
    if(Get.currentRoute=='/user/waitlist'){
      refresh();return;
    }
    Get.toNamed('/user/waitlist',arguments:args);
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    _lifecycle=state;if(state==AppLifecycleState.resumed){SocketService().connect();refresh();registerCurrentPushToken();}
  }
  @override
  void onClose(){
    WidgetsBinding.instance.removeObserver(this);_storageCancel?.call();_poll?.cancel();_clock?.cancel();
    for(final cancel in _subscriptions){cancel();}super.onClose();
  }
}
