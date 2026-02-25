import 'package:flutter/services.dart';
import 'package:advisor_desk/core/localization/app_strings.dart';
import 'package:advisor_desk/core/localization/language_cubit.dart';
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
  final int initialTabIndex;

  const AddEntryScreen({Key? key, this.entryToEdit, this.initialTabIndex = 0}) : super(key: key);

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
      child: AddEntryView(initialTabIndex: initialTabIndex),
    );
  }
}

class AddEntryView extends StatefulWidget {
  final int initialTabIndex;
  const AddEntryView({Key? key, this.initialTabIndex = 0}) : super(key: key);

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
      initialIndex: widget.initialTabIndex,
      length: 3,
      child: MultiBlocListener(
        listeners: [
          BlocListener<AddEntryBloc, AddEntryState>(
            listener: (context, state) {
               final language = context.read<LanguageCubit>().state;
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
                            ? AppStrings.get(language, 'entry_deleted_success')
                            : (state.isUpdate
                                ? AppStrings.get(language, 'entry_updated_success')
                                : AppStrings.get(language, 'entry_added_success')),
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
                      content: Text(state.errorMessage ?? AppStrings.get(language, 'failed_save_entry')),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
              }
            },
          ),
          BlocListener<AddCSATEntryBloc, AddCSATEntryState>(
            listener: (context, state) {
               final language = context.read<LanguageCubit>().state;
              if (state.status == AddCSATEntryStatus.success) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        state.isDelete
                            ? AppStrings.get(language, 'csat_deleted_success')
                            : (state.isUpdate
                                ? AppStrings.get(language, 'csat_updated_success')
                                : AppStrings.get(language, 'csat_added_success')),
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
                      content: Text(state.errorMessage ?? AppStrings.get(language, 'failed_save_csat')),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
              }
            },
          ),
          BlocListener<AddCQEntryBloc, AddCQEntryState>(
            listener: (context, state) {
               final language = context.read<LanguageCubit>().state;
              if (state.status == AddCQEntryStatus.success) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        state.isDelete
                            ? AppStrings.get(language, 'cq_deleted_success')
                            : (state.isUpdate
                                ? AppStrings.get(language, 'cq_updated_success')
                                : AppStrings.get(language, 'cq_added_success')),
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
                      content: Text(state.errorMessage ?? AppStrings.get(language, 'failed_save_entry')),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
              }
            },
          ),
        ],
        child: BlocBuilder<LanguageCubit, Language>(
        builder: (context, language) {
          return Scaffold(
          appBar: CustomAppBar(
            title: context.watch<AddEntryBloc>().state.isUpdate
                ? AppStrings.get(language, 'edit_entry')
                : AppStrings.get(language, 'add_new_entry'),
            bottom: TabBar(
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: [
                Tab(
                  icon: const Icon(Icons.bolt_rounded, size: 20),
                  text: AppStrings.get(language, 'daily_entry_tab'),
                ),
                Tab(
                  icon: const Icon(Icons.reviews_rounded, size: 20),
                  text: AppStrings.get(language, 'csat_entry_tab'),
                ),
                Tab(
                  icon: const Icon(Icons.fact_check_rounded, size: 20),
                  text: AppStrings.get(language, 'cq_entry_tab'),
                ),
              ],
            ),
          ),
          body: TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              // Daily Entry Tab
              _buildDailyEntryTab(context, language),
              // CSAT Entry Tab
              const AddCSATEntryScreen(),
              // CQ Entry Tab
              const AddCQEntryScreen(),
            ],
          ),
           bottomNavigationBar: const BannerAdWidget(),
        );
        }
    ),
    ),
    );
  }

  Widget _buildDailyEntryTab(BuildContext context, Language language) {
    return BlocBuilder<AddEntryBloc, AddEntryState>(
      builder: (context, state) {
        if (state.status == AddEntryStatus.initial || state.status == AddEntryStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Section
              _buildSectionTitle(context, AppStrings.get(language, 'select_date')),
              const SizedBox(height: 12),
              CustomCard(
                onTap: () => _selectDate(context),
                padding: EdgeInsets.zero,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(state.date).toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('d MMMM, EEEE').format(state.date),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.edit_calendar_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Hours Section
              _buildSectionTitle(context, AppStrings.get(language, 'login_duration')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomFormField(
                      label: AppStrings.get(language, 'hours_label'),
                      hintText: '00',
                      controller: _loginHoursController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return '??';
                        final hours = int.tryParse(value);
                        if (hours == null || hours < 0 || hours > 23) return '!';
                        return null;
                      },
                      onChanged: (value) => context.read<AddEntryBloc>().add(
                            LoginHoursChanged(hours: int.tryParse(value) ?? 0),
                          ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 20),
                    child: Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  Expanded(
                    child: CustomFormField(
                      label: AppStrings.get(language, 'minutes_label'),
                      hintText: '00',
                      controller: _loginMinutesController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                         if (value == null || value.isEmpty) return '??';
                        final mins = int.tryParse(value);
                        if (mins == null || mins < 0 || mins > 59) return '!';
                        return null;
                      },
                      onChanged: (value) => context.read<AddEntryBloc>().add(
                            LoginMinutesChanged(minutes: int.tryParse(value) ?? 0),
                          ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 20),
                    child: Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  Expanded(
                    child: CustomFormField(
                      label: AppStrings.get(language, 'seconds_label'),
                      hintText: '00',
                      controller: _loginSecondsController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return '??';
                        final secs = int.tryParse(value);
                        if (secs == null || secs < 0 || secs > 59) return '!';
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
              _buildSectionTitle(context, AppStrings.get(language, 'performance_section')),
              const SizedBox(height: 12),
              CustomFormField(
                label: AppStrings.get(language, 'total_calls_label'),
                hintText: '0',
                icon: Icons.phone_in_talk_rounded,
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
              _buildSectionTitle(context, AppStrings.get(language, 'advanced_options')),
              const SizedBox(height: 12),
              CustomCard(
                padding: EdgeInsets.zero,
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(AppStrings.get(language, 'custom_per_call_rate'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(AppStrings.get(language, 'override_default_rate'), style: const TextStyle(fontSize: 12)),
                  value: state.isCustomRateEnabled,
                  onChanged: (_) {
                    context.read<AddEntryBloc>().add(const ToggleCustomRate());
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.currency_rupee_rounded, color: Colors.amber, size: 20),
                  ),
                ),
              ),
              if (state.isCustomRateEnabled)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CustomFormField(
                    label: AppStrings.get(language, 'custom_rate_label'),
                    hintText: '15.0',
                    icon: Icons.edit_note_rounded,
                    controller: _customCallRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      context.read<AddEntryBloc>().add(
                            CustomRateChanged(rate: double.tryParse(value) ?? 0.0),
                          );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return AppStrings.get(language, 'required_error');
                      final rate = double.tryParse(value);
                      if (rate == null || rate <= 0) return AppStrings.get(language, 'invalid_rate_error');
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
                      Icon(state.isUpdate ? Icons.published_with_changes_rounded : Icons.save_rounded),
                      const SizedBox(width: 10),
                      Text(
                        state.isUpdate ? AppStrings.get(language, 'update_entry_btn') : AppStrings.get(language, 'save_daily_entry_btn'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              if (state.isUpdate) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _showDeleteConfirmationDialog(context, language),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_sweep_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(AppStrings.get(language, 'delete_entry_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
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

    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
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

  void _showDeleteConfirmationDialog(BuildContext context, Language language) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: Theme.of(context).dialogTheme.shape,
          title: Text(AppStrings.get(language, 'confirm_delete_title')),
          content: Text(AppStrings.get(language, 'confirm_delete_message')),
          actions: <Widget>[
            TextButton(
              child: Text(AppStrings.get(language, 'cancel')),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppStrings.get(language, 'delete')),
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