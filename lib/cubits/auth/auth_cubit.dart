import 'package:email_validator/email_validator.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/logger.dart';
import 'package:once_upon_a_time/barrel.dart';

part 'auth_state.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  final AuthRepository authRepository;
  final Logger log;

  AuthCubit({required this.authRepository})
    : log = Logger(),
      super(const AuthState());

  Future<void> login() async {
    if (state.status == AuthStatus.submitting) return;
    emit(state.copyWith(errorMessage: '', status: AuthStatus.submitting));

    if (state.email == null || state.email == '') {
      emit(
        state.copyWith(
          errorMessage: 'Enter your email.',
          status: AuthStatus.unauthenticated,
        ),
      );
    } else if (state.password == null || state.password == '') {
      emit(
        state.copyWith(
          errorMessage: 'Enter your password.',
          status: AuthStatus.unauthenticated,
        ),
      );
    } else if (!EmailValidator.validate(state.email!)) {
      emit(
        state.copyWith(
          errorMessage: 'Enter a valid email.',
          status: AuthStatus.unauthenticated,
        ),
      );
    } else {
      try {
        auth.User? user = await authRepository.loginWithFirebase(
          email: state.email!,
          password: state.password!,
        );

        // TODO: update userBloc (?); probably gonna ignore for now
        // await _userRepository.createUser(
        //   user: User.emptyUser.copyWith(
        //     createdAt: userCredentials.user!.metadata.creationTime,
        //     deviceOS: deviceInfo['deviceOS'],
        //     deviceType: deviceInfo['deviceType'],
        //     email: email,
        //     id: userCredentials.user!.uid,
        //     name: name,
        //     updatedAt: userCredentials.user!.metadata.creationTime,
        //   ),
        // );

        emit(
          state.copyWith(
            authUser: user,
            email: state.email,
            lastUpdate: DateTime.now(),
            status: AuthStatus.authenticated,
          ),
        );
      } catch (err) {
        log.e('login (auth cubit)', error: err);
        emit(
          state.copyWith(
            email: state.email,
            errorMessage: err.toString(),
            status: AuthStatus.unauthenticated,
          ),
        );
      }
    }
  }

  Future<void> logout() async {
    if (state.status == AuthStatus.submitting) return;
    emit(state.copyWith(status: AuthStatus.submitting));

    try {
      await authRepository.signOut();

      emit(state.initialize());
    } catch (err) {
      log.e('logout (auth cubit)', error: err);
      emit(
        state.copyWith(
          status: AuthStatus.unknown,
          errorMessage: err.toString(),
        ),
      );
    }
  }

  // Future<void> registerUser() async {
  //   if (state.status == AuthStatus.submitting) return;
  //   emit(state.copyWith(status: AuthStatus.submitting));

  //   try {
  //     auth.User? user = await authRepository.devRegisterUser();

  //     emit(
  //       state.copyWith(
  //         authUser: user,
  //         lastUpdate: DateTime.now(),
  //         status: AuthStatus.authenticated,
  //       ),
  //     );
  //   } catch (err) {
  //     log.e('register (auth cubit)', error: err);
  //     emit(
  //       state.copyWith(
  //         status: AuthStatus.unauthenticated,
  //         errorMessage: err.toString(),
  //       ),
  //     );
  //   }
  // }

  void reset() {
    print('derp');
    emit(AuthState().initialize());
  }

  void updateLogin({String? email, String? password}) {
    emit(state.copyWith(email: email, password: password));
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    return AuthState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return state.toJson();
  }
}
