import 'package:listenable_tools/listenable_tools.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '_service.dart';

AsyncController<AsyncState> get currentAuth => singleton(AsyncController(const InitState()));

class AuthStateSmsCodeSent extends AsyncState {
  const AuthStateSmsCodeSent({
    required this.verificationId,
    required this.resendToken,
    required this.phoneNumber,
    required this.country,
    required this.timeout,
  });
  final String verificationId;
  final String phoneNumber;
  final Country country;
  final Duration timeout;
  final int? resendToken;
  @override
  List<Object?> get props => [
        verificationId,
        resendToken,
        phoneNumber,
        country,
        timeout,
      ];
}

class AuthStateCodeAutoRetrievalTimeout extends AsyncState {
  const AuthStateCodeAutoRetrievalTimeout({
    required this.verificationId,
    required this.phoneNumber,
    required this.timeout,
  });
  final String verificationId;
  final String phoneNumber;
  final Duration timeout;
  @override
  List<Object?> get props => [
        verificationId,
        phoneNumber,
        timeout,
      ];
}

class AuthStatePhoneNumberVerified extends AsyncState {
  const AuthStatePhoneNumberVerified({
    required this.credential,
  });
  final PhoneAuthCredential credential;
  @override
  List<Object?> get props => [
        credential,
      ];
}

class AuthStateUserSigned extends AsyncState {
  const AuthStateUserSigned({
    required this.userId,
    required this.idToken,
  });
  final String userId;
  final String idToken;
  @override
  List<Object?> get props => [
        userId,
        idToken,
      ];
}

class AuthStateSignedOut extends AsyncState {
  const AuthStateSignedOut();
}

class VerifyPhoneNumberEvent extends AsyncEvent<AsyncState> {
  const VerifyPhoneNumberEvent({
    this.timeout = const Duration(seconds: 30),
    required this.phoneNumber,
    required this.country,
    this.resendToken,
  });
  final Country country;
  final String phoneNumber;
  final int? resendToken;
  final Duration timeout;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());

      return FirebaseConfig.firebaseAuth.verifyPhoneNumber(
        codeAutoRetrievalTimeout: (verificationId) {
          emit(AuthStateCodeAutoRetrievalTimeout(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
            timeout: timeout,
          ));
        },
        codeSent: (verificationId, resendToken) {
          emit(AuthStateSmsCodeSent(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
            resendToken: resendToken,
            country: country,
            timeout: timeout,
          ));
        },
        verificationCompleted: (credential) {
          emit(AuthStatePhoneNumberVerified(
            credential: credential,
          ));
        },
        verificationFailed: (exception) {
          emit(FailureState(
            exception.code,
            event: this,
          ));
        },
        phoneNumber: country.dialCode! + phoneNumber,
        forceResendingToken: resendToken,
        timeout: timeout,
      );
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}

class UpdatePhoneNumber extends AsyncEvent<AsyncState> {
  const UpdatePhoneNumber({
    required this.verificationId,
    required this.smsCode,
    this.authCredential,
  });
  final PhoneAuthCredential? authCredential;
  final String verificationId;
  final String smsCode;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final credential = switch (authCredential) {
        PhoneAuthCredential() => authCredential,
        _ => PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode,
          ),
      };
      await FirebaseConfig.firebaseAuth.currentUser!.updatePhoneNumber(credential!);
      final userId = FirebaseConfig.firebaseAuth.currentUser!.uid;
      final idToken = await FirebaseConfig.firebaseAuth.currentUser!.getIdToken();
      emit(AuthStateUserSigned(userId: userId, idToken: idToken!));
    } on FirebaseAuthException catch (error) {
      emit(FailureState(
        error.code,
        event: this,
      ));
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}

class SignInEvent extends AsyncEvent<AsyncState> {
  SignInEvent({
    required this.verificationId,
    required this.smsCode,
    this.authCredential,
  });
  final AuthCredential? authCredential;
  final String verificationId;
  final String smsCode;
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      final credential = switch (authCredential) {
        PhoneAuthCredential() => authCredential,
        _ => PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode,
          ),
      };
      await FirebaseConfig.firebaseAuth.signInWithCredential(credential!);
      final userId = FirebaseConfig.firebaseAuth.currentUser!.uid;
      final idToken = await FirebaseConfig.firebaseAuth.currentUser!.getIdToken();
      emit(AuthStateUserSigned(userId: userId, idToken: idToken!));
    } on FirebaseAuthException catch (error) {
      emit(FailureState(
        error.code,
        event: this,
      ));
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}

class SignOutEvent extends AsyncEvent<AsyncState> {
  const SignOutEvent();
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    try {
      emit(const PendingState());
      await FirebaseConfig.firebaseAuth.signOut();
      emit(const AuthStateSignedOut());
    } on FirebaseAuthException catch (error) {
      emit(FailureState(
        error.code,
        event: this,
      ));
    } catch (error) {
      emit(FailureState(
        'internal-error',
        event: this,
      ));
    }
  }
}
