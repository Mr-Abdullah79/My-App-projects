import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semester_project_app/providers/calculation_provider.dart';
import 'package:semester_project_app/models/appliance_model.dart';

void main() {
  test('calculation provider computes totals and recommendations', () {
    final provider = CalculationProvider();

    final a1 = ApplianceModel(
      name: 'Bulb',
      watts: 15,
      icon: Icons.lightbulb,
      isSelected: true,
      hoursPerDay: 5,
      quantity: 4,
      daysPerMonth: 30,
    );

    final a2 = ApplianceModel(
      name: 'Fan',
      watts: 80,
      icon: Icons.air,
      isSelected: true,
      hoursPerDay: 8,
      quantity: 2,
      daysPerMonth: 30,
    );

    final appliances = [a1, a2];

    final totalWatts = provider.calculateTotalWatts(appliances);
    expect(totalWatts, equals(15 * 4 + 80 * 2));

    final dailyWh = provider.calculateDailyWh(appliances);
    expect(dailyWh, equals((15 * 5 * 4) + (80 * 8 * 2)));

    final monthlyKWh = provider.calculateMonthlyKWh(appliances);
    expect(monthlyKWh, closeTo((dailyWh * 30) / 1000.0, 1e-6));

    final bill = provider.estimateMonthlyBillFromKwh(monthlyKWh);
    expect(bill, closeTo(monthlyKWh * provider.ratePerKWh, 1e-6));

    final systemKW = provider.recommendSystemKWFromDailyWh(dailyWh);
    expect(systemKW, greaterThanOrEqualTo(0));

    final panels = provider.recommendPanelCount(systemKW);
    expect(panels, greaterThanOrEqualTo(0));
  });
}
