abstract class GoalRepository {
  Future<void> saveGoals({required int hours, required int calls, required String userId});
  Future<Map<String, dynamic>> getGoals({required String userId});
}
