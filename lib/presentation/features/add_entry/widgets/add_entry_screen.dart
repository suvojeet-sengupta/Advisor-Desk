import 'package:flutter/services.dart';
import 'package:advisor_desk/data/datasources/ad_service.dart';
import 'package:advisor_desk/presentation/common/widgets/banner_ad_widget.dart';
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
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_bloc.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_event.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_state.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_csat_entry_bloc.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_csat_entry_state.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_cq_entry_bloc.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_cq_entry_state.dart';

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
            adService: context.read<AdService>(),
          )..add(InitializeAddEntry(entry: entryToEdit)),
        ),
        BlocProvider(
          create: (context) => AddCSATEntryBloc(
            repository: context.read<PerformanceRepository>(),
            adService: context.read<AdService>(),
          ),
        ),
        BlocProvider(
          create: (context) => AddCQEntryBloc(
            repository: context.read<PerformanceRepository>(),
            adService: context.read<AdService>(),
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
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _loginHoursController;
  late final TextEditingController _loginMinutesController;
  late final TextEditingController _loginSecondsController;
  late final TextEditingController _callCountController;
  late final TextEditingController _customCallRateController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers without text
    _loginHoursController = TextEditingController();
    _loginMinutesController = TextEditingController();
    _loginSecondsController = TextEditingController();
    _callCountController = TextEditingController();
    _customCallRateController = TextEditingController();
  }

  @override
  void dispose() {
    _loginHoursController.dispose();
    _loginMinutesController.dispose();
    _loginSecondsController.dispose();
    _callCountController.dispose();
    _customCallRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: MultiBlocListener(
        listeners: [
          BlocListener<AddEntryBloc, AddEntryState>(
            listener: (context, state) {
              // Update controllers when the state changes
              if (state.isUpdate) {
                if (_loginHoursController.text != state.loginHours.toString()) {
                  _loginHoursController.text = state.loginHours.toString();
                }
                if (_loginMinutesController.text != state.loginMinutes.toString()) {
                  _loginMinutesController.text = state.loginMinutes.toString();
                }
                if (_loginSecondsController.text != state.loginSeconds.toString()) {
                  _loginSecondsController.text = state.loginSeconds.toString();
                }
                if (_callCountController.text != state.callCount.toString()) {
                  _callCountController.text = state.callCount.toString();
                }
                if (state.customCallRate != null &&
                    _customCallRateController.text != state.customCallRate.toString()) {
                  _customCallRateController.text = state.customCallRate.toString();
                }
              }

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
          ),
          BlocListener<AddCSATEntryBloc, AddCSATEntryState>(
            listener: (context, state) {
              if (state.status == AddCSATEntryStatus.success) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        state.isDelete
                            ? 'CSAT entry deleted successfully!'
                            : (state.isUpdate
                                ? 'CSAT entry updated successfully!'
                                : 'CSAT entry added successfully!'),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                    ),
                  );
                Navigator.pop(context, true);
              } else if (state.status == AddCSATEntryStatus.failure) {
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
          ),
          BlocListener<AddCQEntryBloc, AddCQEntryState>(
            listener: (context, state) {
              if (state.status == AddCQEntryStatus.success) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        state.isDelete
                            ? 'CQ entry deleted successfully!'
                            : (state.isUpdate
                                ? 'CQ entry updated successfully!'
                                : 'CQ entry added successfully!'),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                    ),
                  );
                Navigator.pop(context, true);
              } else if (state.status == AddCQEntryStatus.failure) {
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
          ),
        ],
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
           bottomNavigationBar: const BannerAdWidget(),
        ),
    ),
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
          child: Form(
            key: _formKey,
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

              // Login Hours Section
              _buildSectionTitle(context, 'Login Hours'),
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter hours';
                        }
                        final hours = int.tryParse(value);
                        if (hours == null || hours < 0 || hours > 23) {
                          return '0-23';
                        }
                        return null;
                      },
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter mins';
                        }
                        final mins = int.tryParse(value);
                        if (mins == null || mins < 0 || mins > 59) {
                          return '0-59';
                        }
                        return null;
                      },
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter secs';
                        }
                        final secs = int.tryParse(value);
                        if (secs == null || secs < 0 || secs > 59) {
                          return '0-59';
                        }
                        return null;
                      },
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
              const SizedBox(height: 24),

              // Custom Call Rate Section
              _buildSectionTitle(context, 'Custom Per Call Rate'),
              const SizedBox(height: 8),
              CustomCard(
                child: SwitchListTile(
                  title: const Text('Enable Custom Rate'),
                  value: state.isCustomRateEnabled,
                  onChanged: (_) {
                    context.read<AddEntryBloc>().add(const ToggleCustomRate());
                  },
                  secondary: Icon(
                    Icons.price_change,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              if (state.isCustomRateEnabled)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CustomFormField(
                    label: 'Custom Rate',
                    hintText: 'Enter custom rate per call',
                    icon: Icons.monetization_on,
                    controller: _customCallRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      context.read<AddEntryBloc>().add(
                            CustomRateChanged(rate: double.tryParse(value) ?? 0.0),
                          );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a rate';
                      }
                      final rate = double.tryParse(value);
                      if (rate == null || rate <= 0) {
                        return 'Enter a valid rate';
                      }
                      return null;
                    },
                  ),
                ),
              const SizedBox(height: 32),

              // Buttons Section
              SizedBox(
                width: double.infinity,
                child: AnimatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<AddEntryBloc>().add(const SubmitEntry());
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(state.isUpdate ? Icons.update : Icons.add),
                      const SizedBox(width: 8),
                      Text(state.isUpdate ? 'Update Entry' : 'Add Entry'),
                    ],
                  ),
                ),
              ),

              if (state.isUpdate) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: AnimatedButton(
                    onPressed: () => _showDeleteConfirmationDialog(context),
                    backgroundColor: AppColors.secondaryBackground,
                    foregroundColor: AppColors.textPrimary,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 8),
                        Text('Delete Entry'),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
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