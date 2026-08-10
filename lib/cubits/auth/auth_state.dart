part of 'auth_cubit.dart';

enum AuthStatus { authenticated, submitting, unauthenticated, unknown }

class AuthState extends Equatable {
  final auth.User? authUser;
  final AuthStatus status;
  final DateTime? lastUpdate;
  final String? email;
  final String? errorMessage;
  final String? password;

  const AuthState({
    this.authUser,
    this.email,
    this.errorMessage,
    this.lastUpdate,
    this.password,
    this.status = AuthStatus.unknown,
  });

  @override
  List<Object?> get props => [
    authUser,
    email,
    errorMessage,
    lastUpdate,
    password,
    status,
  ];

  factory AuthState.initial() {
    return const AuthState();
  }

  AuthState copyWith({
    auth.User? authUser,
    AuthStatus? status,
    DateTime? lastUpdate,
    String? email,
    String? errorMessage,
    String? password,
  }) {
    return AuthState(
      authUser: authUser ?? this.authUser,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }

  AuthState initialize() {
    return AuthState(status: AuthStatus.unknown);
  }

  factory AuthState.fromJson(Map<String, dynamic> json) {
    DateTime updatedTime = json['lastUpdate'] != null
        ? DateTime.parse(json['lastUpdate'])
        : DateTime.now();

    if (updatedTime.isUtc) {
      updatedTime = updatedTime.toLocal();
    }

    return AuthState(
      email: json['email'],
      errorMessage: json['errorMessage'],
      lastUpdate: updatedTime,
      status: AuthStatus.values.firstWhere(
        (status) => status.name.toString() == json['status'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    DateTime lastDT = lastUpdate ?? DateTime.now();

    return {
      'email': email,
      'errorMessage': errorMessage,
      'lastUpdate': lastDT.toUtc().toString(),
      'status': status.name,
    };
  }
}
