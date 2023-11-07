import 'package:listenable_tools/async.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionStateGranted extends AsyncState {
  const PermissionStateGranted({required this.permission});
  final Permission permission;
  @override
  Record get equality => (permission,);
}

class PermissionStatePermanentlyDenied extends AsyncState {
  const PermissionStatePermanentlyDenied({required this.permission});
  final Permission permission;
  @override
  Record get equality => (permission,);
}

class GetPermissionEvent extends AsyncEvent<AsyncState> {
  const GetPermissionEvent({
    required this.permission,
  });
  final Permission permission;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final status = await permission.status;
      switch (status) {
        case PermissionStatus.granted:
        case PermissionStatus.limited:
        case PermissionStatus.provisional:
          emit(PermissionStateGranted(permission: permission));
          break;
        case PermissionStatus.denied:
        case PermissionStatus.restricted:
        case PermissionStatus.permanentlyDenied:
          emit(PermissionStatePermanentlyDenied(permission: permission));
          break;
      }
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}

class RequestPermissionEvent extends AsyncEvent<AsyncState> {
  const RequestPermissionEvent({
    required this.permission,
  });

  final Permission permission;

  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final status = await permission.status;
      switch (status) {
        case PermissionStatus.granted:
        case PermissionStatus.limited:
        case PermissionStatus.provisional:
          emit(PermissionStateGranted(permission: permission));
          break;
        case PermissionStatus.denied:
          return permission.request().then((status) => handle(emit));
        case PermissionStatus.restricted:
        case PermissionStatus.permanentlyDenied:
          emit(PermissionStatePermanentlyDenied(permission: permission));
          break;
      }
    } catch (error) {
      emit(FailureState(
        code: error.toString(),
        event: this,
      ));
    }
  }
}
