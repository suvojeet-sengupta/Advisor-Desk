import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/presentation/features/user/bloc/user_cubit.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';

class SalarySettingsScreen extends StatefulWidget {
  const SalarySettingsScreen({Key? key}) : super(key: key);

  @override
  State<SalarySettingsScreen> createState() => _SalarySettingsScreenState();
}

class _SalarySettingsScreenState extends State<SalarySettingsScreen> {
  late TextEditingController _baseRatePerCallController;
  late TextEditingController _bonusAmountController;
  late TextEditingController _bonusCallTargetController;
  late TextEditingController _bonusHourTargetController;
  late TextEditingController _csatBonusPercentageController;
  late TextEditingController _csatBonusCallTargetController;
  late TextEditingController _csatBonusRateController;
  late TextEditingController _tdsRateController;

  @override
  void initState() {
    super.initState();
    _baseRatePerCallController = TextEditingController(text: AppConstants.baseRatePerCall.toString());
    _bonusAmountController = TextEditingController(text: AppConstants.bonusAmount.toString());
    _bonusCallTargetController = TextEditingController(text: AppConstants.bonusCallTarget.toString());
    _bonusHourTargetController = TextEditingController(text: AppConstants.bonusHourTarget.toString());
    _csatBonusPercentageController = TextEditingController(text: AppConstants.csatBonusPercentage.toString());
    _csatBonusCallTargetController = TextEditingController(text: AppConstants.csatBonusCallTarget.toString());
    _csatBonusRateController = TextEditingController(text: AppConstants.csatBonusRate.toString());
    _tdsRateController = TextEditingController(text: AppConstants.tdsRate.toString());
  }

  @override
  void dispose() {
    _baseRatePerCallController.dispose();
    _bonusAmountController.dispose();
    _bonusCallTargetController.dispose();
    _bonusHourTargetController.dispose();
    _csatBonusPercentageController.dispose();
    _csatBonusCallTargetController.dispose();
    _csatBonusRateController.dispose();
    _tdsRateController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    try {
      final userId = context.read<UserCubit>().state is UserLoaded
          ? (context.read<UserCubit>().state as UserLoaded).currentUserId
          : '1';

      await AppConstants.saveSettings(
        newBaseRatePerCall: double.parse(_baseRatePerCallController.text),
        newBonusAmount: double.parse(_bonusAmountController.text),
        newBonusCallTarget: int.parse(_bonusCallTargetController.text),
        newBonusHourTarget: int.parse(_bonusHourTargetController.text),
        newCsatBonusPercentage: double.parse(_csatBonusPercentageController.text),
        newCsatBonusCallTarget: int.parse(_csatBonusCallTargetController.text),
        newCsatBonusRate: double.parse(_csatBonusRateController.text),
        newTdsRate: double.parse(_tdsRateController.text),
        userId: userId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salary settings saved successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Signal success and pop
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: \$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Salary Parameters'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            _buildSectionHeader(context, 'Core Earnings'),
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  CustomFormField(
                    label: 'Base Rate (Per Call)',
                    hintText: '4.30',
                    icon: Icons.currency_rupee_rounded,
                    controller: _baseRatePerCallController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 20),
                  CustomFormField(
                    label: 'Bonus Amount',
                    hintText: '2000',
                    icon: Icons.card_giftcard_rounded,
                    controller: _bonusAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSectionHeader(context, 'Targets'),
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  CustomFormField(
                    label: 'Bonus Call Target',
                    hintText: '750',
                    icon: Icons.call_made_rounded,
                    controller: _bonusCallTargetController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  CustomFormField(
                    label: 'Bonus Hour Target (Hrs)',
                    hintText: '100',
                    icon: Icons.timer_outlined,
                    controller: _bonusHourTargetController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'CSAT & Quality'),
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                   CustomFormField(
                    label: 'CSAT Bonus Target',
                    hintText: '1000',
                    icon: Icons.stars_rounded,
                    controller: _csatBonusCallTargetController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  CustomFormField(
                    label: 'CSAT Percentage Required (%)',
                    hintText: '60',
                    icon: Icons.percent_rounded,
                    controller: _csatBonusPercentageController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 20),
                  CustomFormField(
                    label: 'CSAT Bonus Rate (Decimal)',
                    hintText: '0.05 (for 5%)',
                    icon: Icons.calculate_outlined,
                    controller: _csatBonusRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Deductions'),
            CustomCard(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: CustomFormField(
                label: 'TDS Rate (Decimal)',
                hintText: '0.10 (for 10%)',
                icon: Icons.money_off_rounded,
                controller: _tdsRateController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: AnimatedButton(
                onPressed: _saveSettings,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_rounded),
                    SizedBox(width: 8),
                    Text('Save Configuration'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
