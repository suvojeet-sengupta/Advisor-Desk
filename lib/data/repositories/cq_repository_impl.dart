import 'package:advisor_desk/domain/entities/cq_entry.dart';
import 'package:advisor_desk/domain/repositories/cq_repository.dart';
import 'package:advisor_desk/data/datasources/local_data_source.dart';

class CQRepositoryImpl implements CQRepository {
  final LocalDataSource localDataSource;

  CQRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CQEntry>> getCQEntriesForDateRange(DateTime startDate, DateTime endDate) {
    return localDataSource.getCQEntriesForDateRange(startDate, endDate);
  }

  @override
  Future<List<CQEntry>> getCQEntriesForMonth(int month, int year) {
    return localDataSource.getCQEntriesForMonth(month, year);
  }
}