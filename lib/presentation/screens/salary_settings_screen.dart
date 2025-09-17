import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';

/// A screen where users can configure the parameters for salary calculation.
///
/// This screen provides a form to modify various constants such as base pay rates,
/// bonus targets, and TDS rates. The settings are persisted using [AppConstants].
class SalarySettingsScreen extends StatefulWidget {
  /// Creates a [SalarySettingsScreen].
  const SalarySettingsScreen({super.key});

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
    // Initialize controllers with current values from AppConstants.
    _baseRatePerCallController =
        TextEditingController(text: AppConstants.baseRatePerCall.toString());
    _bonusAmountController =
        TextEditingController(text: AppConstants.bonusAmount.toString());
    _bonusCallTargetController =
        TextEditingController(text: AppConstants.bonusCallTarget.toString());
    _bonusHourTargetController =
        TextEditingController(text: AppConstants.bonusHourTarget.toString());
    _csatBonusPercentageController = TextEditingController(
        text: AppConstants.csatBonusPercentage.toString());
    _csatBonusCallTargetController = TextEditingController(
        text: AppConstants.csatBonusCallTarget.toString());
    _csatBonusRateController =
        TextEditingController(text: AppConstants.csatBonusRate.toString());
    _tdsRateController =
        TextEditingController(text: AppConstants.tdsRate.toString());
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

  /// Parses the values from the text controllers and saves them using [AppConstants].
  void _saveSettings() async {
    try {
      await AppConstants.saveSettings(
        newBaseRatePerCall: double.parse(_baseRatePerCallController.text),
        newBonusAmount: double.parse(_bonusAmountController.text),
        newBonusCallTarget: int.parse(_bonusCallTargetController.text),
        newBonusHourTarget: int.parse(_bonusHourTargetController.text),
        newCsatBonusPercentage: double.parse(_csatBonusPercentageController.text),
        newCsatBonusCallTarget: int.parse(_csatBonusCallTargetController.text),
        newCsatBonusRate: double.parse(_csatBonusRateController.text),
        newTdsRate: double.parse(_tdsRateController.text),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Salary settings saved successfully!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Signal success and pop
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save settings: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Salary Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomFormField(
              label: 'Base Rate Per Call',
              hintText: 'Enter base rate per call',
              icon: Icons.currency_rupee,
              controller: _baseRatePerCallController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            CustomFormField(
              label: 'Bonus Amount',
              hintText: 'Enter bonus amount',
              icon: Icons.card_giftcard,
              controller: _bonusAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            CustomFormField(
              label: 'Bonus Call Target',
              hintText: 'Enter bonus call target',
              icon: Icons.call,
              controller: _bonusCallTargetController,
              keyboardType: TextInputType.number,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            CustomFormField(
              label: 'Bonus Hour Target (in hours)',
              hintText: 'Enter bonus hour target',
              icon: Icons.timer,
              controller: _bonusHourTargetController,
              keyboardType: TextInputType.number,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            CustomFormField(
              label: 'CSAT Bonus Percentage',
              hintText: 'Enter CSAT bonus percentage',
              icon: Icons.sentiment_satisfied_alt,
              controller: _csatBonusPercentageController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            CustomFormField(
              label: 'CSAT Bonus Call Target',
              hintText: 'Enter CSAT bonus call target',
              icon: Icons.call,
              controller: _csatBonusCallTargetController,
              keyboardType: TextInputType.number,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            CustomFormField(
              label: 'CSAT Bonus Rate (e.g., 0.05 for 5%)',
              hintText: 'Enter CSAT bonus rate',
              icon: Icons.star,
              controller: _csatBonusRateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            CustomFormField(
              label: 'TDS Rate (e.g., 0.10 for 10%)',
              hintText: 'Enter TDS rate',
              icon: Icons.percent,
              controller: _tdsRateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {},
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Save Salary Settings',
                onPressed: _saveSettings,
                icon: Icons.save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
