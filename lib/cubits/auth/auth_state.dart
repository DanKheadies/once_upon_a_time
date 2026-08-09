part of 'auth_cubit.dart';

enum AuthStatus { authenticated, submitting, unauthenticated, unknown }

class AuthState extends Equatable {
  final auth.User? authUser;
  final AuthStatus status;
  final DateTime? lastUpdate;
  final String? errorMessage;

  const AuthState({
    this.authUser,
    this.errorMessage,
    this.lastUpdate,
    this.status = AuthStatus.unknown,
  });

  @override
  List<Object?> get props => [authUser, errorMessage, lastUpdate, status];

  factory AuthState.initial() {
    return const AuthState();
  }

  AuthState copyWith({
    auth.User? authUser,
    AuthStatus? status,
    DateTime? lastUpdate,
    String? errorMessage,
  }) {
    return AuthState(
      authUser: authUser ?? this.authUser,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdate: lastUpdate ?? this.lastUpdate,
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
      'errorMessage': errorMessage,
      'lastUpdate': lastDT.toUtc().toString(),
      'status': status.name,
    };
  }
}
