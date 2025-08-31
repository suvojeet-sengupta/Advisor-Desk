import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/presentation/features/monthly_data/bloc/monthly_data_bloc.dart';
import 'package:advisor_desk/presentation/features/monthly_data/bloc/monthly_data_event.dart';
import 'package:advisor_desk/presentation/features/monthly_data/bloc/monthly_data_state.dart';
import 'package:advisor_desk/domain/entities/monthly_data.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';

class MonthlyDataScreen extends StatefulWidget {
  final int month;
  final int year;

  const MonthlyDataScreen({super.key, required this.month, required this.year});

  @override
  State<MonthlyDataScreen> createState() => _MonthlyDataScreenState();
}

class _MonthlyDataScreenState extends State<MonthlyDataScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nonBillableCallsController;

  @override
  void initState() {
    super.initState();
    _nonBillableCallsController = TextEditingController();
    context.read<MonthlyDataBloc>().add(LoadMonthlyData(widget.month, widget.year));
  }

  @override
  void dispose() {
    _nonBillableCallsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Edit Monthly Data'),
      body: BlocConsumer<MonthlyDataBloc, MonthlyDataState>(
        listener: (context, state) {
          if (state is MonthlyDataLoaded) {
            _nonBillableCallsController.text = state.monthlyData.nonBillableCalls.toString();
          }
        },
        builder: (context, state) {
          if (state is MonthlyDataLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MonthlyDataError) {
            return Center(child: Text(state.message));
          } else if (state is MonthlyDataLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomFormField(
                      controller: _nonBillableCallsController,
                      labelText: 'Non-Billable Calls',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a value';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Save',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final nonBillableCalls = int.parse(_nonBillableCallsController.text);
                          context.read<MonthlyDataBloc>().add(
                                UpdateNonBillableCalls(
                                  widget.month,
                                  widget.year,
                                  nonBillableCalls,
                                ),
                              );
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
