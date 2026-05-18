import 'package:flutter/foundation.dart';
import '../models/appliance_model.dart';

class CalculationResult {
  final int totalWatts;
  final double dailyWh;
  final double monthlyKWh;
  final double estimatedMonthlyBill;
  final double recommendedSystemKW;
  final int recommendedPanelCount;

  CalculationResult({
    required this.totalWatts,
    required this.dailyWh,
    required this.monthlyKWh,
    required this.estimatedMonthlyBill,
    required this.recommendedSystemKW,
    required this.recommendedPanelCount,
  });
}

class CalculationProvider extends ChangeNotifier {
  // Configurable defaults
  double ratePerKWh = 40.0; // PKR per kWh (default)
  double avgSunHours = 5.0; // average effective sun-hours per day
  int defaultPanelWatt = 550;

  CalculationProvider();

  int calculateTotalWatts(List<ApplianceModel> appliances) {
    int total = 0;
    for (final a in appliances) {
      if (!a.isSelected) continue;
      total += a.effectiveWatts * a.quantity;
    }
    return total;
  }

  double calculateDailyWh(List<ApplianceModel> appliances) {
    double total = 0.0;
    for (final a in appliances) {
      if (!a.isSelected) continue;
      total += a.effectiveWatts * a.hoursPerDay * a.quantity;
    }
    return total;
  }

  double calculateMonthlyKWh(List<ApplianceModel> appliances) {
    final daily = calculateDailyWh(appliances);
    // Use daysPerMonth from first appliance (assumes consistent) or default 30
    int days = appliances.isNotEmpty ? appliances.first.daysPerMonth : 30;
    return (daily * days) / 1000.0;
  }

  double estimateMonthlyBillFromKwh(double monthlyKWh) {
    return monthlyKWh * ratePerKWh;
  }

  double recommendSystemKWFromDailyWh(double dailyWh) {
    // Required kW = dailyWh / (avgSunHours * 1000)
    if (avgSunHours <= 0) avgSunHours = 5.0;
    double kw = dailyWh / (avgSunHours * 1000.0);
    // round up to nearest 0.5
    return (kw * 2).ceilToDouble() / 2.0;
  }

  int recommendPanelCount(double systemKW, {int panelWatt = 0}) {
    final pw = panelWatt > 0 ? panelWatt : defaultPanelWatt;
    final totalWatts = (systemKW * 1000).ceil();
    return (totalWatts / pw).ceil();
  }

  CalculationResult calculateAll(List<ApplianceModel> appliances) {
    final totalWatts = calculateTotalWatts(appliances);
    final dailyWh = calculateDailyWh(appliances);
    final monthlyKWh = calculateMonthlyKWh(appliances);
    final bill = estimateMonthlyBillFromKwh(monthlyKWh);
    final systemKW = recommendSystemKWFromDailyWh(dailyWh);
    final panels = recommendPanelCount(systemKW);

    return CalculationResult(
      totalWatts: totalWatts,
      dailyWh: dailyWh,
      monthlyKWh: monthlyKWh,
      estimatedMonthlyBill: bill,
      recommendedSystemKW: systemKW,
      recommendedPanelCount: panels,
    );
  }
}
