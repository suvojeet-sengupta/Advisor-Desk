/// An abstract repository for managing user goals.
///
/// This class defines the contract for saving and retrieving user goals for
/// login hours and call count.
abstract class GoalRepository {
  /// Saves the user's goals.
  ///
  /// The [hours] parameter is the target number of login hours.
  /// The [calls] parameter is the target number of calls.
  Future<void> saveGoals({required int hours, required int calls});

  /// Retrieves the user's goals.
  ///
  /// Returns a `Map<String, int>` containing the 'hours' and 'calls' goals.
  Future<Map<String, int>> getGoals();
}
