import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/waitlist_entry.dart';

class AdminWaitlistPanel extends StatelessWidget {
  final List<WaitlistEntry> entries;
  final bool loading;
  final String? error;
  final DateTime now;
  final VoidCallback onRefresh;
  const AdminWaitlistPanel({super.key,required this.entries,required this.loading,required this.now,required this.onRefresh,this.error});
  @override
  Widget build(BuildContext context){
    final active=entries.where((e)=>e.active).toList();
    final history=entries.where((e)=>!e.active).toList().reversed.toList();
    final waiting=active.where((e)=>e.status=='waiting').length;
    final offers=active.where((e)=>e.canAccept(now)).length;
    return Card(color:Colors.white,margin:const EdgeInsets.only(top:16),child:Padding(
        padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[const Expanded(child:Text('Lista de espera',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800,color:Colors.black87))),
        IconButton(onPressed:loading?null:onRefresh,tooltip:'Actualizar cola',icon:const Icon(Icons.refresh))]),
      Text('$waiting en espera · $offers ofertas activas',style:const TextStyle(color:Colors.black54)),
      const SizedBox(height:8),
      const Text('Los cupos se ofrecen por orden de ingreso. Una bicicleta en oferta permanece apartada hasta confirmar, rechazar o vencer.',style:TextStyle(fontSize:12,color:Colors.black54)),
      if(loading)const Padding(padding:EdgeInsets.symmetric(vertical:12),child:LinearProgressIndicator()),
      if(error!=null)Padding(padding:const EdgeInsets.symmetric(vertical:12),child:Text(error!,style:const TextStyle(color:Colors.red))),
      if(active.isEmpty&&!loading&&error==null)const Padding(padding:EdgeInsets.symmetric(vertical:16),child:Text('No hay personas en espera para esta clase.',style:TextStyle(color:Colors.black87))),
      for(final e in active)_row(e),
      if(history.isNotEmpty)ExpansionTile(tilePadding:EdgeInsets.zero,title:Text('Historial de la cola (${history.length})'),
          children:[for(final e in history.take(30))_row(e),
            if(history.length>30)const Text('Se muestran las últimas 30 solicitudes.',style:TextStyle(color:Colors.black54))]),
    ])));
  }
  Widget _row(WaitlistEntry e){
    final offer=e.status=='offered',live=e.canAccept(now);
    final joined=e.createdAt==null?'':DateFormat('dd/MM HH:mm').format(e.createdAt!.subtract(const Duration(hours:5)));
    return Padding(padding:const EdgeInsets.symmetric(vertical:10),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
      CircleAvatar(backgroundColor:offer?Colors.amber.shade100:Colors.indigo.shade50,
          child:Text(e.status=='waiting'?'${e.position ?? '–'}':offer?'${e.bicycle ?? '–'}':'✓',style:const TextStyle(color:Colors.black87))),
      const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(e.userName?.isNotEmpty==true?e.userName!:'Alumno #${e.userId}',style:const TextStyle(fontWeight:FontWeight.w700,color:Colors.black87)),
        if(e.userEmail?.isNotEmpty==true)Text(e.userEmail!,style:const TextStyle(fontSize:12,color:Colors.black54)),
        Text('${e.statusLabel}${e.status=='waiting'?' · Lugar ${e.position ?? '–'}':''}',style:TextStyle(color:offer?Colors.deepOrange:Colors.black54,fontWeight:FontWeight.w600)),
        if(offer)Text(live?'Bici #${e.bicycle} · Vence en ${e.remainingLabel(now)}':'Oferta vencida; actualizando estado.',style:const TextStyle(color:Colors.black87)),
        if(joined.isNotEmpty)Text('Ingresó $joined · Ecuador',style:const TextStyle(fontSize:11,color:Colors.black54)),
        if(e.closeReason?.isNotEmpty==true)Text(e.closeReason!,style:const TextStyle(fontSize:12,color:Colors.black54)),
        if(e.reservationId!=null)Text('Reserva #${e.reservationId}',style:const TextStyle(fontSize:12,color:Colors.black54)),
      ])),
    ]));
  }
}
