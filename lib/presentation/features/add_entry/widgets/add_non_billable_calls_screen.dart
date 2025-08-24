import 'package:advisor_desk/data/datasources/ad_service.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_non_billable_calls_bloc.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_non_billable_calls_event.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_non_billable_calls_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _nonBillableCallsController = TextEditingController();
    _adService.loadAd();
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
                    onPressed: () async {
                      await _adService.showAd();
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
}