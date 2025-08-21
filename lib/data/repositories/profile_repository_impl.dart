
import 'package:advisor_desk/data/datasources/profile_data_source.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource dataSource;

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
