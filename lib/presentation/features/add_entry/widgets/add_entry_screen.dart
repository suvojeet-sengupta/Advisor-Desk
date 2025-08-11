import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/presentation/features/add_entry/widgets/add_csat_entry_screen.dart';
import 'package:advisor_desk/presentation/features/add_entry/widgets/add_cq_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_bloc.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_event.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_state.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_csat_entry_bloc.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_cq_entry_bloc.dart';

class AddEntryScreen extends StatelessWidget {
  final DailyEntry? entryToEdit;

  const AddEntryScreen({Key? key, this.entryToEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AddEntryBloc(
            repository: context.read<PerformanceRepository>(),
          )..add(InitializeAddEntry(entry: entryToEdit)),
        ),
        BlocProvider(
          create: (context) => AddCSATEntryBloc(
            repository: context.read<PerformanceRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => AddCQEntryBloc(
            repository: context.read<PerformanceRepository>(),
          ),
        ),
      ],
      child: const AddEntryView(),
    );
  }
}

class AddEntryView extends StatefulWidget {
  const AddEntryView({Key? key}) : super(key: key);

  @override
  State<AddEntryView> createState() => _AddEntryViewState();
}

class _AddEntryViewState extends State<AddEntryView> {
  late final TextEditingController _loginHoursController;
  late final TextEditingController _loginMinutesController;
  late final TextEditingController _loginSecondsController;
  late final TextEditingController _callCountController;

  @override
  void initState() {
    super.initState();
    final state = context.read<AddEntryBloc>().state;

    _loginHoursController = TextEditingController(
        text: state.isUpdate ? state.loginHours.toString() : (state.loginHours == 0 ? '' : state.loginHours.toString()));
    _loginMinutesController = TextEditingController(
        text: state.isUpdate ? state.loginMinutes.toString() : (state.loginMinutes == 0 ? '' : state.loginMinutes.toString()));
    _loginSecondsController = TextEditingController(
        text: state.isUpdate ? state.loginSeconds.toString() : (state.loginSeconds == 0 ? '' : state.loginSeconds.toString()));
    _callCountController = TextEditingController(
        text: state.isUpdate ? state.callCount.toString() : (state.callCount == 0 ? '' : state.callCount.toString()));
  }

  @override
  void dispose() {
    _loginHoursController.dispose();
    _loginMinutesController.dispose();
    _loginSecondsController.dispose();
    _callCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BlocListener<AddEntryBloc, AddEntryState>(
        listener: (context, state) {
          if (state.status == AddEntryStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.isDelete
                        ? 'Entry deleted successfully!'
                        : (state.isUpdate
                            ? 'Entry updated successfully!'
                            : 'Entry added successfully!'),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                ),
              );
            Navigator.pop(context, true); 
          } else if (state.status == AddEntryStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to save entry'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
          }
        },
        child: Scaffold(
          appBar: CustomAppBar(
            title: context.watch<AddEntryBloc>().state.isUpdate
                ? 'Edit Entry'
                : 'Add New Entry',
            bottom: TabBar(
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(
                  icon: Icon(Icons.work_outline),
                  text: 'Daily Entry',
                ),
                Tab(
                  icon: Icon(Icons.sentiment_satisfied_alt),
                  text: 'CSAT Entry',
                ),
                Tab(
                  icon: Icon(Icons.assessment),
                  text: 'CQ Entry',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Daily Entry Tab
              _buildDailyEntryTab(context),
              // CSAT Entry Tab
              const AddCSATEntryScreen(),
              // CQ Entry Tab
              const AddCQEntryScreen(),
            ],
          ),
        ),),
    );
  }

  Widget _buildDailyEntryTab(BuildContext context) {
    return BlocBuilder<AddEntryBloc, AddEntryState>(
      builder: (context, state) {
        if (state.status == AddEntryStatus.initial || state.status == AddEntryStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Section
              _buildSectionTitle(context, 'Date'),
              const SizedBox(height: 8),
              CustomCard(
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    width: double.infinity,
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
                          DateFormat('dd MMM yyyy').format(state.date),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Time Section
              _buildSectionTitle(context, 'Login Time'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomFormField(
                      label: 'Hours',
                      hintText: 'HH',
                      icon: Icons.timer,
                      controller: _loginHoursController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => context.read<AddEntryBloc>().add(
                            LoginHoursChanged(hours: int.tryParse(value) ?? 0),
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFormField(
                      label: 'Minutes',
                      hintText: 'MM',
                      icon: Icons.timer,
                      controller: _loginMinutesController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => context.read<AddEntryBloc>().add(
                            LoginMinutesChanged(minutes: int.tryParse(value) ?? 0),
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFormField(
                      label: 'Seconds',
                      hintText: 'SS',
                      icon: Icons.timer,
                      controller: _loginSecondsController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => context.read<AddEntryBloc>().add(
                            LoginSecondsChanged(seconds: int.tryParse(value) ?? 0),
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Call Count Section
              CustomFormField(
                label: 'Call Count',
                hintText: 'Enter number of calls',
                icon: Icons.call,
                controller: _callCountController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  context.read<AddEntryBloc>().add(
                        CallCountChanged(callCount: int.tryParse(value) ?? 0),
                      );
                },
              ),
              const SizedBox(height: 32),

              // Buttons Section
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: state.isUpdate ? 'Update Entry' : 'Add Entry',
                  onPressed: () {
                          context.read<AddEntryBloc>().add(const SubmitEntry());
                        },
                  icon: state.isUpdate ? Icons.update : Icons.add,
                ),
              ),

              if (state.isUpdate) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Delete Entry',
                    onPressed: () => _showDeleteConfirmationDialog(context),
                    isPrimary: false, 
                    icon: Icons.delete_outline,
                  ),
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final bloc = context.read<AddEntryBloc>();
    final currentDate = bloc.state.date;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
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

    if (selectedDate != null) {
      bloc.add(DateChanged(date: selectedDate));
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: Theme.of(context).dialogTheme.shape,
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this entry? This action cannot be undone.'),
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
                context.read<AddEntryBloc>().add(const DeleteEntry());
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


