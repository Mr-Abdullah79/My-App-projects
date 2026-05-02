import 'package:flutter/material.dart';
import 'solar_summary_screen.dart';

class SolarRoiScreen extends StatelessWidget {
  final String systemType;
  final String brandName;
  final List<String> selectedAppliances;
  final double systemCost;
  final double monthlyBillWithoutSolar;
  final double yearlyBillWithoutSolar;

  const SolarRoiScreen({
    super.key,
    required this.systemType,
    required this.brandName,
    required this.selectedAppliances,
    required this.systemCost,
    required this.monthlyBillWithoutSolar,
    required this.yearlyBillWithoutSolar,
  });

  double get _coverageSavingsRate {
    switch (systemType) {
      case 'On-Grid':
        return 0.78;
      case 'Hybrid':
        return 0.68;
      case 'Off-Grid':
        return 0.60;
      default:
        return 0.65;
    }
  }

  double get _annualMaintenanceCost => systemCost * 0.012;

  double get _monthlyMaintenanceCost => _annualMaintenanceCost / 12;

  double get _monthlyBillWithSolar {
    final reducedGridBill =
        monthlyBillWithoutSolar * (1 - _coverageSavingsRate);
    return (reducedGridBill + _monthlyMaintenanceCost).clamp(
      0,
      double.infinity,
    );
  }

  double get _yearlyBillWithSolar => _monthlyBillWithSolar * 12;

  double get _monthlySavings =>
      (monthlyBillWithoutSolar - _monthlyBillWithSolar)
          .clamp(0, double.infinity)
          .toDouble();

  double get _yearlySavings => (yearlyBillWithoutSolar - _yearlyBillWithSolar)
      .clamp(0, double.infinity)
      .toDouble();

  double get _roiMonths {
    if (_monthlySavings <= 0) return double.infinity;
    return systemCost / _monthlySavings;
  }

  double get _roiYears => _roiMonths / 12;

  List<String> get _benefits => [
    'Monthly electricity bills are reduced after solar installation.',
    'Long-term savings improve resilience against unit-rate increases.',
    'Hybrid and off-grid systems provide backup during outages.',
    'Solar power reduces carbon emissions and environmental impact.',
  ];

  List<String> get _considerations => [
    'Initial installation cost can be high.',
    'Regular maintenance and panel cleaning are required.',
    'Battery-based systems may require future replacement costs.',
    'Actual savings depend on weather and usage patterns.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Benefits & ROI Analysis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Selected Solar Option'),
            _buildRow('System', 0, valueText: systemType),
            _buildRow('Brand', 0, valueText: brandName),
            _buildRow('Estimated Solar Cost', systemCost),
            const SizedBox(height: 14),
            _buildSectionTitle('Bill Comparison'),
            _buildRow('Bill Without Solar (Monthly)', monthlyBillWithoutSolar),
            _buildRow('Bill With Solar (Monthly)', _monthlyBillWithSolar),
            _buildRow('Monthly Savings', _monthlySavings, isHighlight: true),
            _buildRow('Bill Without Solar (Yearly)', yearlyBillWithoutSolar),
            _buildRow('Bill With Solar (Yearly)', _yearlyBillWithSolar),
            _buildRow('Yearly Savings', _yearlySavings, isHighlight: true),
            const SizedBox(height: 14),
            _buildSectionTitle('ROI'),
            _buildRow(
              'Payback (Months)',
              _roiMonths.isFinite ? _roiMonths : 0,
              valueText: _roiMonths.isFinite
                  ? _roiMonths.toStringAsFixed(1)
                  : 'N/A',
            ),
            _buildRow(
              'Payback (Years)',
              _roiMonths.isFinite ? _roiYears : 0,
              valueText: _roiMonths.isFinite
                  ? _roiYears.toStringAsFixed(2)
                  : 'N/A',
            ),
            const SizedBox(height: 14),
            _buildSectionTitle('Benefits'),
            ..._benefits.map(_buildBullet),
            const SizedBox(height: 10),
            _buildSectionTitle('Considerations'),
            ..._considerations.map(_buildBullet),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SolarSummaryScreen(
                        systemType: systemType,
                        brandName: brandName,
                        selectedAppliances: selectedAppliances,
                        monthlyBillWithoutSolar: monthlyBillWithoutSolar,
                        monthlyBillWithSolar: _monthlyBillWithSolar,
                        monthlySavings: _monthlySavings,
                        yearlySavings: _yearlySavings,
                        solarCost: systemCost,
                        roiMonths: _roiMonths,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text(
                  'Next: View Total Summary',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRow(
    String label,
    double value, {
    bool isHighlight = false,
    String? valueText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        Text(
          valueText ?? 'Rs. ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? Colors.green : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.circle, size: 8),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
