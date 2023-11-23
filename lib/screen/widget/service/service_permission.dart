import 'package:listenable_tools/async.dart';
import 'package:permission_handler/permission_handler.dart';

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
          emit(SuccessState(permission));
          break;
        case PermissionStatus.denied:
        case PermissionStatus.restricted:
        case PermissionStatus.permanentlyDenied:
          emit(FailureState(
            code: 'no-permission',
            event: this,
          ));
          break;
      }
    } catch (error) {
      emit(FailureState(
        code: 'internal-error',
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
          emit(SuccessState(permission));
          break;
        case PermissionStatus.denied:
          return permission.request().then((status) => handle(emit));
        case PermissionStatus.restricted:
        case PermissionStatus.permanentlyDenied:
          emit(FailureState(
            code: 'no-permission',
            event: this,
          ));
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
