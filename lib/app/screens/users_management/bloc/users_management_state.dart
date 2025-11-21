part of 'users_management_bloc.dart';

@immutable
sealed class UsersManagementState {}

final class UsersManagementInitial extends UsersManagementState {}

final class UsersManagementLoaded extends UsersManagementState {
  final users;
  final stats;
  UsersManagementLoaded({required this.stats, required this.users});
}
