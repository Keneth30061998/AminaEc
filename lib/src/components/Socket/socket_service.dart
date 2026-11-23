import 'package:amina_ec/src/environment/environment.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../models/user.dart';

class _SocketListener {
  final String event;
  final Function(dynamic) callback;
  final bool persistent;
  _SocketListener(this.event,this.callback,this.persistent);
}
class SocketService {
  static final SocketService _singleton=SocketService._internal();
  factory SocketService()=>_singleton;
  User userSession=User.fromJson(GetStorage().read('user') ?? {});
  late IO.Socket socket;
  String _token='';
  final List<_SocketListener> _listeners=[];
  SocketService._internal(){_recreate(userSession.session_token ?? '');}
  void _recreate(String token) {
    _token=token;
    socket=IO.io(Environment.API_URL_SOCKET,IO.OptionBuilder().setTransports(['websocket'])
        .setPath('/socket.io').setAuth({'token':token}).enableForceNew().disableAutoConnect().build());
    for(final listener in _listeners){socket.on(listener.event,listener.callback);}
  }
  void updateUserSession(User newUser) {
    final changedUser=newUser.id!=userSession.id;
    final token=newUser.session_token ?? '';
    userSession=newUser;
    if(changedUser){
      for(final l in _listeners.where((l)=>!l.persistent).toList()){
        socket.off(l.event,l.callback);_listeners.remove(l);
      }
    }
    if(token!=_token){socket.dispose();_recreate(token);}
    if(token.isNotEmpty)connect();else socket.disconnect();
  }
  void connect(){if(_token.isNotEmpty&&!socket.connected)socket.connect();}
  void disconnect(){
    socket.disconnect();
    for(final l in _listeners.where((l)=>!l.persistent).toList()){
      socket.off(l.event,l.callback);_listeners.remove(l);
    }
  }
  bool isConnected()=>socket.connected;
  void on(String event,Function(dynamic) callback){subscribe(event,callback);}
  void Function() subscribe(String event,Function(dynamic) callback,{bool persistent=false}) {
    final listener=_SocketListener(event,callback,persistent);
    _listeners.add(listener);socket.on(event,callback);
    return (){socket.off(event,callback);_listeners.remove(listener);};
  }
  void once(String event,Function(dynamic) callback){
    late void Function() cancel;
    cancel=subscribe(event,(data){cancel();callback(data);});
  }
  void off(String event){
    // Los servicios permanentes conservan sus escuchas aunque una pantalla quite las propias.
    for(final l in _listeners.where((l)=>l.event==event&&!l.persistent).toList()){
      socket.off(event,l.callback);_listeners.remove(l);
    }
  }
  void notifyLocal(String event,dynamic data){
    for(final l in _listeners.where((l)=>l.event==event).toList()){
      try{l.callback(data);}catch(_){/* Una vista no interrumpe la confirmación de otra. */}
    }
  }
  void emit(String event,dynamic data){connect();socket.emit(event,data);}
  void emitSafe(String event,dynamic data){if(socket.connected)socket.emit(event,data);}
  void join(String room)=>emit('join',{'room':room});
  void leaveRoom(String room)=>emitSafe('leave',{'room':room});
  void dispose()=>disconnect();
}
