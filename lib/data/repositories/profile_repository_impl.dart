import 'package:advisor_desk/data/datasources/profile_data_source.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/domain/repositories/profile_repository.dart';

/// The implementation of the [ProfileRepository] interface.
///
/// This class acts as a bridge between the domain layer and the data layer
/// for profile-related operations. It uses a [ProfileDataSource] to fetch and
/// save profile data.
class ProfileRepositoryImpl implements ProfileRepository {
  /// The data source for the profile.
  final ProfileDataSource dataSource;

  /// Creates a new instance of [ProfileRepositoryImpl].
  ///
  /// The [dataSource] is the [ProfileDataSource] to be used for data operations.
  ProfileRepositoryImpl(this.dataSource);

  @override
  Future<Profile> getProfile() {
    return dataSource.getProfile();
  }

  @override
  Future<void> saveProfile(Profile profile) {
    return dataSource.saveProfile(profile);
  }
}
