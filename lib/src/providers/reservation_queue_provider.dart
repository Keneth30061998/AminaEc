import 'dart:convert';
import 'package:amina_ec/src/environment/environment.dart';
import 'package:amina_ec/src/models/response_api.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ReservationQueueProvider {
  Map<String,String> get _headers => {'Content-Type':'application/json',
    'Authorization':'${(GetStorage().read('user') ?? {})['session_token'] ?? ''}'};
  Future<ResponseApi> _request(String path,{Map<String,dynamic>? body,Map<String,String>? query}) async {
    try {
      final base=Uri.parse('${Environment.API_URL}$path');
      final uri=query==null?base:base.replace(queryParameters:query);
      final response=await (body==null?http.get(uri,headers:_headers):
      http.post(uri,headers:_headers,body:jsonEncode(body))).timeout(const Duration(seconds:15));
      final decoded=jsonDecode(response.body);
      if(decoded is! Map<String,dynamic>)throw const FormatException('Respuesta inválida');
      final result=ResponseApi.fromJson(decoded);
      if(response.statusCode>=400)result.success=false;
      return result;
    }catch(_){return ResponseApi(success:false,message:'No se pudo conectar. Actualiza para consultar el estado real de la cola.');}
  }
  Future<ResponseApi> joinQueue({required String coachId,required String classDate,required String classTime,String? scheduleId}) =>
      _request('api/reservation-queue',body:{'coach_id':coachId,'class_date':classDate,
        'class_time':classTime.split('.').first,if(scheduleId?.isNotEmpty==true)'schedule_id':scheduleId});
  Future<ResponseApi> mine() => _request('api/reservation-queue/mine');
  Future<ResponseApi> getEntry(String id) => _request('api/reservation-queue/$id');
  Future<ResponseApi> acceptOffer(String id) => _request('api/reservation-queue/$id/accept',body:{});
  Future<ResponseApi> rejectOffer(String id) => _request('api/reservation-queue/$id/reject',body:{});
  Future<ResponseApi> cancelEntry(String id) => _request('api/reservation-queue/$id/cancel',body:{});
  Future<ResponseApi> adminList(String scheduleId) => _request('api/admin/schedules/$scheduleId/waitlist');
  Future<ResponseApi> adminByClass({required String coachId,required String classDate,required String classTime}) =>
      _request('api/admin/waitlist/by-class',query:{'coach_id':coachId,'class_date':classDate,'class_time':classTime});
  Future<ResponseApi> counts(String date) => _request('api/admin/waitlist/counts',query:{'date':date});
}
