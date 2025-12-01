import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/entities/user.dart';
import 'package:advisor_desk/data/datasources/user_data_source.dart';
import 'package:advisor_desk/data/datasources/local_data_source.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/presentation/features/profile/bloc/profile_cubit.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<AppUser> users;
  final String currentUserId;

  UserLoaded({required this.users, required this.currentUserId});
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}

class UserCubit extends Cubit<UserState> {
  final UserDataSource _userDataSource;
  final ProfileCubit _profileCubit;

  UserCubit(this._userDataSource, this._profileCubit) : super(UserInitial()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    emit(UserLoading());
    try {
      final users = await _userDataSource.getUsers();
      final currentUserId = await _userDataSource.getCurrentUserId();
      emit(UserLoaded(users: users, currentUserId: currentUserId));
    } catch (e) {
      emit(UserError("Failed to load users: $e"));
    }
  }

  Future<void> addUser(String name) async {
    try {
      final newUser = AppUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        profilePicturePath: '',
      );
      await _userDataSource.saveUser(newUser);
      await loadUsers();
    } catch (e) {
      emit(UserError("Failed to add user: $e"));
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _userDataSource.deleteUser(userId);
      await loadUsers();
    } catch (e) {
      emit(UserError("Failed to delete user: $e"));
    }
  }

  Future<void> switchUser(String userId) async {
    try {
      emit(UserLoading());
      await _userDataSource.setCurrentUserId(userId);
      
      // Re-initialize app components with new user context
      await AppConstants.init(userId: userId);
      
      // We need to close the existing DB and re-open with new user DB
      // Assuming LocalDataSource.init handles re-opening or we might need a close method
      await LocalDataSource().closeDatabase(); 
      await LocalDataSource.init(userId: userId);
      
      // Refresh profile cubit
      await _profileCubit.loadProfile(userId: userId);

      await loadUsers();
    } catch (e) {
      emit(UserError("Failed to switch user: $e"));
      // Reload to restore state
      await loadUsers();
    }
  }
}
