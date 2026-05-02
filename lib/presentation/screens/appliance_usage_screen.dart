import 'package:flutter/material.dart';
import '../../models/appliance_model.dart';
import 'bill_generation_screen.dart';

class ApplianceUsageScreen extends StatefulWidget {
  final List<ApplianceModel> selectedAppliances;

  const ApplianceUsageScreen({super.key, required this.selectedAppliances});

  @override
  State<ApplianceUsageScreen> createState() => _ApplianceUsageScreenState();
}

class _ApplianceUsageScreenState extends State<ApplianceUsageScreen> {
  bool _isMonthly = true;
  final TextEditingController _daysController = TextEditingController(
    text: '30',
  );

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  // Return daily total kWh
  double _calculateDailyUnits() {
    double totalWattsHours = 0;
    for (var app in widget.selectedAppliances) {
      double averageHoursPerDay = app.hoursPerDay * (app.daysPerMonth / 30.0);
      totalWattsHours +=
          (app.effectiveWatts * app.quantity * averageHoursPerDay);
    }
    return totalWattsHours / 1000.0;
  }

  @override
  Widget build(BuildContext context) {
    double dailyUnits = _calculateDailyUnits();
    final parsedDays = int.tryParse(_daysController.text) ?? 30;
    int activeDays = _isMonthly ? 30 : parsedDays.clamp(1, 365);
    double totalUnits = dailyUnits * activeDays;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Daily Usage Time'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Text(
              'Please select the daily usage hours for each appliance. We will automatically estimate your monthly units!',
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.4,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 150),
              itemCount: widget.selectedAppliances.length,
              itemBuilder: (context, index) {
                final app = widget.selectedAppliances[index];
                return _buildUsageSliderCard(app);
              },
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: _isMonthly,
                        activeColor: Colors.teal,
                        onChanged: (val) => setState(() => _isMonthly = val!),
                      ),
                      const Text('Monthly (30 Days)'),
                      const SizedBox(width: 8),
                      Radio<bool>(
                        value: false,
                        groupValue: _isMonthly,
                        activeColor: Colors.teal,
                        onChanged: (val) => setState(() => _isMonthly = val!),
                      ),
                      const Text('Specific Days'),
                    ],
                  ),
                ),
              ],
            ),
            if (!_isMonthly)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Enter number of days',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated Units:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  '${totalUnits.toStringAsFixed(1)} Units',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Based on exactly $activeDays days of estimated usage.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final applianceNames = widget.selectedAppliances
                      .map(
                        (e) =>
                            '${e.quantity}x ${e.name} (${e.effectiveWatts}W)',
                      )
                      .toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BillGenerationScreen(
                        totalUnits: totalUnits,
                        days: activeDays,
                        selectedAppliances: applianceNames,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Generate Estimated Bill',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageSliderCard(ApplianceModel app) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(app.icon, color: Colors.teal),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${app.quantity}x ${app.name}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Text(
                '${app.hoursPerDay} hrs/day',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Daily Usage: ${app.hoursPerDay} hours/day',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Slider(
            value: app.hoursPerDay.toDouble(),
            min: 0,
            max: 24,
            divisions: 24,
            activeColor: Colors.teal,
            inactiveColor: Colors.teal[100],
            label: '${app.hoursPerDay} hrs',
            onChanged: (val) {
              setState(() {
                app.hoursPerDay = val.toInt();
              });
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Monthly Usage: ${app.daysPerMonth} days/month',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Slider(
            value: app.daysPerMonth.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: Colors.orange,
            inactiveColor: Colors.orange[100],
            label: '${app.daysPerMonth} days',
            onChanged: (val) {
              setState(() {
                app.daysPerMonth = val.toInt();
              });
            },
          ),
        ],
      ),
    );
  }
}
