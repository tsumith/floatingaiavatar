import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}
class AuthSignOutRequested extends AuthEvent {}
class AuthGoogleSignInRequested extends AuthEvent {} 

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInRequested(this.email, this.password);
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  const AuthSignUpRequested(this.email, this.password, this.displayName);
}