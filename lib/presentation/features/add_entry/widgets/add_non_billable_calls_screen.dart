import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_non_billable_calls_bloc.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_non_billable_calls_event.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_non_billable_calls_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';

class AddNonBillableCallsScreen extends StatelessWidget {
  const AddNonBillableCallsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddNonBillableCallsBloc(
        repository: context.read<PerformanceRepository>(),
      )..add(const InitializeNonBillableCalls()),
      child: const AddNonBillableCallsView(),
    );
  }
}

class AddNonBillableCallsView extends StatefulWidget {
  const AddNonBillableCallsView({Key? key}) : super(key: key);

  @override
  State<AddNonBillableCallsView> createState() => _AddNonBillableCallsViewState();
}

class _AddNonBillableCallsViewState extends State<AddNonBillableCallsView> {
  late final TextEditingController _nonBillableCallsController;

  @override
  void initState() {
    super.initState();
    _nonBillableCallsController = TextEditingController();
  }

  @override
  void dispose() {
    _nonBillableCallsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Non-billable Calls'),
      body: BlocConsumer<AddNonBillableCallsBloc, AddNonBillableCallsState>(
        listener: (context, state) {
          if (state.status == AddNonBillableCallsStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Non-billable calls saved successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            Navigator.pop(context, true);
          } else if (state.status == AddNonBillableCallsStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to save non-billable calls'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state.status == AddNonBillableCallsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_nonBillableCallsController.text != state.nonBillableCalls.toString()) {
            _nonBillableCallsController.text = state.nonBillableCalls.toString();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                CustomFormField(
                  label: 'Non-billable Calls',
                  hintText: 'Enter number of non-billable calls',
                  icon: Icons.phone_disabled,
                  controller: _nonBillableCallsController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    context.read<AddNonBillableCallsBloc>().add(
                          NonBillableCallsValuechanged(nonBillableCalls: int.tryParse(value) ?? 0),
                        );
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: state.isUpdate ? 'Update Entry' : 'Add Entry',
                    onPressed: () {
                      context.read<AddNonBillableCallsBloc>().add(const SubmitNonBillableCalls());
                    },
                    icon: state.isUpdate ? Icons.update : Icons.add,
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
    final bloc = context.read<AddNonBillableCallsBloc>();
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
      bloc.add(NonBillableCallsDateChanged(date: selectedDate));
    }
  }
}