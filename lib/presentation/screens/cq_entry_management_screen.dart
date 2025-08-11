import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';

// Define a Bloc/Cubit for this screen
class CqEntryManagementCubit extends Cubit<CqEntryManagementState> {
  final PerformanceRepository repository;

  CqEntryManagementCubit(this.repository) : super(CqEntryManagementState.initial()) {
    loadEntriesForDate(state.selectedDate);
  }

  Future<void> loadEntriesForDate(DateTime date) async {
    emit(state.copyWith(status: CqEntryManagementStatus.loading, selectedDate: date));
    try {
      // Normalize date to start of day for accurate query
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final entries = await repository.getCQEntriesForDateRange(normalizedDate, normalizedDate);
      emit(state.copyWith(status: CqEntryManagementStatus.loaded, entries: entries));
    } catch (e) {
      emit(state.copyWith(status: CqEntryManagementStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> deleteEntry(int id) async {
    emit(state.copyWith(status: CqEntryManagementStatus.loading));
    try {
      await repository.deleteCQEntry(id);
      // Reload entries for the current selected date after deletion
      await loadEntriesForDate(state.selectedDate);
      emit(state.copyWith(status: CqEntryManagementStatus.success, successMessage: 'Entry deleted successfully!'));
    } catch (e) {
      emit(state.copyWith(status: CqEntryManagementStatus.error, errorMessage: 'Failed to delete entry: ${e.toString()}'));
    }
  }
}

enum CqEntryManagementStatus { initial, loading, loaded, error, success }

class CqEntryManagementState {
  final CqEntryManagementStatus status;
  final List<CQEntry> entries;
  final DateTime selectedDate;
  final String? errorMessage;
  final String? successMessage;

  CqEntryManagementState({
    required this.status,
    required this.entries,
    required this.selectedDate,
    this.errorMessage,
    this.successMessage,
  });

  factory CqEntryManagementState.initial() {
    return CqEntryManagementState(
      status: CqEntryManagementStatus.initial,
      entries: [],
      selectedDate: DateTime.now(),
    );
  }

  CqEntryManagementState copyWith({
    CqEntryManagementStatus? status,
    List<CQEntry>? entries,
    DateTime? selectedDate,
    String? errorMessage,
    String? successMessage,
  }) {
    return CqEntryManagementState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      selectedDate: selectedDate ?? this.selectedDate,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class CQEntryManagementScreen extends StatelessWidget {
  const CQEntryManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CqEntryManagementCubit(context.read<PerformanceRepository>()),
      child: _CQEntryManagementView(),
    );
  }
}

class _CQEntryManagementView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Manage CQ Entries'),
      body: BlocConsumer<CqEntryManagementCubit, CqEntryManagementState>(
        listener: (context, state) {
          if (state.status == CqEntryManagementStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
            );
          } else if (state.status == CqEntryManagementStatus.success && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () => _selectDate(context, state.selectedDate),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('dd MMM yyyy').format(state.selectedDate),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: state.status == CqEntryManagementStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.entries.isEmpty
                        ? Center(
                            child: Text(
                              'No CQ entries for ${DateFormat('dd MMM yyyy').format(state.selectedDate)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.entries.length,
                            itemBuilder: (context, index) {
                              final entry = state.entries[index];
                              return CustomCard(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  title: Text('CQ Score: ${entry.percentage.toStringAsFixed(2)}%'),
                                  subtitle: Text('Audit Date: ${DateFormat('dd MMM yyyy').format(entry.auditDate)}'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                    onPressed: () => _confirmDelete(context, entry.id!),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime currentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != currentDate) {
      context.read<CqEntryManagementCubit>().loadEntriesForDate(picked);
    }
  }

  void _confirmDelete(BuildContext context, int entryId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this CQ entry? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<CqEntryManagementCubit>().deleteEntry(entryId);
              },
            ),
          ],
        );
      },
    );
  }
}
