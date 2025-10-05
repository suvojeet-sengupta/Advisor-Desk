import 'package:advisor_desk/domain/entities/csat_entry.dart';
import 'package:advisor_desk/domain/repositories/csat_repository.dart';
import 'package:advisor_desk/data/datasources/local_data_source.dart';

class CSATRepositoryImpl implements CSATRepository {
  final LocalDataSource localDataSource;

  CSATRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CSATEntry>> getCSATEntriesForDateRange(DateTime startDate, DateTime endDate) {
    return localDataSource.getCSATEntriesForDateRange(startDate, endDate);
  }

  @override
  Future<List<CSATEntry>> getCSATEntriesForMonth(int month, int year) {
    return localDataSource.getCSATEntriesForMonth(month, year);
  }
}