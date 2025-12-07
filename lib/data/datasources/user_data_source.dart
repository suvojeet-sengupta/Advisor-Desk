import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/domain/entities/user.dart';

class UserDataSource {
  static const String _usersListKey = 'users_list';
  static const String _currentUserIdKey = 'current_user_id';

  Future<List<AppUser>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Ensure we have the latest data
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
    // Re-fetch users to ensure we don't overwrite with stale data
    await prefs.reload();
    final usersJsonRaw = prefs.getStringList(_usersListKey) ?? [];
    List<AppUser> users;
    
    if (usersJsonRaw.isEmpty) {
      users = [AppUser(id: '1', name: 'Default User', profilePicturePath: '')];
    } else {
      users = usersJsonRaw.map((str) => AppUser.fromMap(json.decode(str))).toList();
    }
    
    final index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }

    final usersJson = users.map((u) => json.encode(u.toMap())).toList();
    final result = await prefs.setStringList(_usersListKey, usersJson);
    if (!result) {
       print("Failed to save users list!");
    }
  }

  Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Ensure we have the latest data
    return prefs.getString(_currentUserIdKey) ?? '1'; // Default to User 1
  }

  Future<bool> setCurrentUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final result = await prefs.setString(_currentUserIdKey, id);
    if (!result) {
      print("Failed to save current user ID!");
    }
    return result;
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
    await prefs.reload();
    final users = await getUsers();
    
    users.removeWhere((u) => u.id == userId);
    
    final usersJson = users.map((u) => json.encode(u.toMap())).toList();
    final result = await prefs.setStringList(_usersListKey, usersJson);
    if (!result) {
       print("Failed to delete user!");
    }
  }
}
