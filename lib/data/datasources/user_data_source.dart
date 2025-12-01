import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/domain/entities/user.dart';

class UserDataSource {
  static const String _usersListKey = 'users_list';
  static const String _currentUserIdKey = 'current_user_id';

  Future<List<AppUser>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersListKey) ?? [];
    if (usersJson.isEmpty) {
      // Return default user if no users exist
      return [
        AppUser(id: '1', name: 'Default User', profilePicturePath: '')
      ];
    }
    return usersJson
        .map((str) => AppUser.fromMap(json.decode(str)))
        .toList();
  }

  Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();
    
    final index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }

    final usersJson = users.map((u) => json.encode(u.toMap())).toList();
    await prefs.setStringList(_usersListKey, usersJson);
  }

  Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserIdKey) ?? '1'; // Default to User 1
  }

  Future<void> setCurrentUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserIdKey, id);
  }
  
  Future<AppUser?> getUserById(String id) async {
    final users = await getUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }
  Future<void> deleteUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();
    
    users.removeWhere((u) => u.id == userId);
    
    final usersJson = users.map((u) => json.encode(u.toMap())).toList();
    await prefs.setStringList(_usersListKey, usersJson);
  }
}
