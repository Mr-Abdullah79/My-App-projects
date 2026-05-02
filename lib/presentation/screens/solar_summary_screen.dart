import 'package:flutter/material.dart';

import '../../services/history_storage_service.dart';
import 'thank_you_screen.dart';

class SolarSummaryScreen extends StatefulWidget {
  final String systemType;
  final String brandName;
  final List<String> selectedAppliances;
  final double monthlyBillWithoutSolar;
  final double monthlyBillWithSolar;
  final double monthlySavings;
  final double yearlySavings;
  final double solarCost;
  final double roiMonths;

  const SolarSummaryScreen({
    super.key,
    required this.systemType,
    required this.brandName,
    required this.selectedAppliances,
    required this.monthlyBillWithoutSolar,
    required this.monthlyBillWithSolar,
    required this.monthlySavings,
    required this.yearlySavings,
    required this.solarCost,
    required this.roiMonths,
  });

  @override
  State<SolarSummaryScreen> createState() => _SolarSummaryScreenState();
}

class _SolarSummaryScreenState extends State<SolarSummaryScreen> {
  Future<void> _finish() async {
    await HistoryStorageService.saveEntry({
      'savedAt': DateTime.now().toIso8601String(),
      'systemType': widget.systemType,
      'brandName': widget.brandName,
      'appliances': widget.selectedAppliances,
      'monthlyBill': widget.monthlyBillWithoutSolar.toStringAsFixed(0),
      'solarCost': widget.solarCost.toStringAsFixed(0),
      'roiMonths': widget.roiMonths.isFinite
          ? widget.roiMonths.toStringAsFixed(1)
          : 'N/A',
    });

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ThankYouScreen()),
      (route) => false,
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Total Summary')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionCard(
              title: 'System Selection',
              child: Column(
                children: [
                  _infoRow('System Type', widget.systemType),
                  _infoRow('Brand', widget.brandName),
                  _infoRow(
                    'Solar Setup Cost',
                    'Rs. ${widget.solarCost.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ),
            _sectionCard(
              title: 'Appliances on Solar',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.selectedAppliances.isEmpty
                    ? [const Text('No appliances selected.')]
                    : widget.selectedAppliances
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('• $e'),
                            ),
                          )
                          .toList(),
              ),
            ),
            _sectionCard(
              title: 'Bill Comparison',
              child: Column(
                children: [
                  _infoRow(
                    'Bill Without Solar (Monthly)',
                    'Rs. ${widget.monthlyBillWithoutSolar.toStringAsFixed(0)}',
                  ),
                  _infoRow(
                    'Bill With Solar (Monthly)',
                    'Rs. ${widget.monthlyBillWithSolar.toStringAsFixed(0)}',
                  ),
                  _infoRow(
                    'Monthly Savings',
                    'Rs. ${widget.monthlySavings.toStringAsFixed(0)}',
                  ),
                  _infoRow(
                    'Yearly Savings',
                    'Rs. ${widget.yearlySavings.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ),
            _sectionCard(
              title: 'ROI (Return on Investment)',
              child: _infoRow(
                'Estimated Payback Time',
                widget.roiMonths.isFinite
                    ? '${widget.roiMonths.toStringAsFixed(1)} months'
                    : 'N/A',
              ),
            ),
            const ListTile(
              leading: Icon(Icons.save_rounded, color: Colors.teal),
              title: Text('History is saved automatically'),
              subtitle: Text(
                'Your summary remains available after app restart until you delete it from History.',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _finish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Finish',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
