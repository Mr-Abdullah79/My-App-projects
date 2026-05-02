import 'package:flutter/material.dart';

class ApplianceModel {
  final String name;
  final int watts;
  final IconData icon;
  final bool isCustom;
  int? customWatts;
  bool isSelected;
  int hoursPerDay;
  int quantity;
  int daysPerMonth;
  String? notes;

  ApplianceModel({
    required this.name,
    required this.watts,
    required this.icon,
    this.isCustom = false,
    this.customWatts,
    this.isSelected = false,
    this.hoursPerDay = 0,
    this.quantity = 1,
    this.daysPerMonth = 30,
    this.notes,
  });

  int get effectiveWatts => customWatts ?? watts;

  bool get hasKnownWatts => effectiveWatts > 0;
}

// Dynamic Appliances per category
List<ApplianceModel> getAppliancesForCategory(String category) {
  String lc = category.toLowerCase();

  if (lc.contains('single') || lc.contains('small')) {
    return [
      ApplianceModel(
        name: 'Ceiling Fan',
        watts: 80,
        icon: Icons.mode_fan_off_rounded,
      ),
      ApplianceModel(
        name: 'LED Light / Bulb',
        watts: 15,
        icon: Icons.lightbulb_outline,
      ),
      ApplianceModel(name: 'Television', watts: 100, icon: Icons.tv),
      ApplianceModel(name: 'Refrigerator', watts: 250, icon: Icons.kitchen),
      ApplianceModel(
        name: 'Washing Machine',
        watts: 500,
        icon: Icons.local_laundry_service,
      ),
      ApplianceModel(name: 'Iron', watts: 1000, icon: Icons.iron),
      ApplianceModel(name: 'Water Pump', watts: 750, icon: Icons.water_drop),
      ApplianceModel(name: 'Air Cooler', watts: 150, icon: Icons.air),
    ];
  } else if (lc.contains('double') || lc.contains('large')) {
    return [
      ApplianceModel(
        name: 'Ceiling Fan',
        watts: 80,
        icon: Icons.mode_fan_off_rounded,
      ),
      ApplianceModel(
        name: 'LED Light / Bulb',
        watts: 15,
        icon: Icons.lightbulb_outline,
      ),
      ApplianceModel(
        name: 'Inverter AC (1.5 Ton)',
        watts: 1800,
        icon: Icons.ac_unit,
      ),
      ApplianceModel(
        name: 'Air Conditioner (1 Ton)',
        watts: 1200,
        icon: Icons.ac_unit,
      ),
      ApplianceModel(
        name: 'Refrigerator (Large)',
        watts: 350,
        icon: Icons.kitchen,
      ),
      ApplianceModel(name: 'Deep Freezer', watts: 400, icon: Icons.kitchen),
      ApplianceModel(name: 'Smart TV (55")', watts: 150, icon: Icons.tv),
      ApplianceModel(
        name: 'Washing Machine (Auto)',
        watts: 800,
        icon: Icons.local_laundry_service,
      ),
      ApplianceModel(
        name: 'Water Heater (Geyser)',
        watts: 2000,
        icon: Icons.hot_tub,
      ),
      ApplianceModel(
        name: 'Microwave Oven',
        watts: 1200,
        icon: Icons.microwave,
      ),
      ApplianceModel(name: 'Water Pump', watts: 1000, icon: Icons.water_drop),
      ApplianceModel(name: 'Dishwasher', watts: 1200, icon: Icons.local_drink),
    ];
  } else if (lc.contains('office') || lc.contains('commercial')) {
    return [
      ApplianceModel(name: 'LED Panel Light', watts: 24, icon: Icons.light),
      ApplianceModel(
        name: 'Desktop Computer',
        watts: 250,
        icon: Icons.desktop_windows,
      ),
      ApplianceModel(name: 'Laptop', watts: 65, icon: Icons.laptop_mac),
      ApplianceModel(
        name: 'Commercial AC (2 Ton)',
        watts: 2400,
        icon: Icons.ac_unit,
      ),
      ApplianceModel(
        name: 'Photocopier / Printer',
        watts: 600,
        icon: Icons.print,
      ),
      ApplianceModel(
        name: 'Water Dispenser',
        watts: 500,
        icon: Icons.local_drink,
      ),
      ApplianceModel(name: 'Server Rack', watts: 1500, icon: Icons.dns),
      ApplianceModel(name: 'Coffee Machine', watts: 800, icon: Icons.coffee),
      ApplianceModel(name: 'Exhaust Fan', watts: 60, icon: Icons.air),
    ];
  } else if (lc.contains('shop') || lc.contains('retail')) {
    return [
      ApplianceModel(name: 'LED Spotlights', watts: 20, icon: Icons.lightbulb),
      ApplianceModel(
        name: 'Ceiling Fan',
        watts: 80,
        icon: Icons.mode_fan_off_rounded,
      ),
      ApplianceModel(
        name: 'Signboard / Neon',
        watts: 150,
        icon: Icons.wb_iridescent,
      ),
      ApplianceModel(name: 'Display Fridge', watts: 450, icon: Icons.kitchen),
      ApplianceModel(
        name: 'Split AC (1.5 Ton)',
        watts: 1800,
        icon: Icons.ac_unit,
      ),
      ApplianceModel(
        name: 'POS Terminal / PC',
        watts: 150,
        icon: Icons.point_of_sale,
      ),
    ];
  } else if (lc.contains('agri')) {
    return [
      ApplianceModel(name: 'Tubewell (5 HP)', watts: 3700, icon: Icons.water),
      ApplianceModel(name: 'Tubewell (10 HP)', watts: 7500, icon: Icons.water),
      ApplianceModel(name: 'Heavy Duty Fan', watts: 200, icon: Icons.air),
      ApplianceModel(
        name: 'Chaff Cutter',
        watts: 2200,
        icon: Icons.agriculture,
      ),
      ApplianceModel(
        name: 'Field Lighting (Halogen)',
        watts: 500,
        icon: Icons.lightbulb,
      ),
    ];
  } else if (lc.contains('industrial') || lc.contains('factory')) {
    return [
      ApplianceModel(
        name: 'Industrial Motor (10 HP)',
        watts: 7500,
        icon: Icons.settings,
      ),
      ApplianceModel(name: 'High Bay LED Light', watts: 150, icon: Icons.light),
      ApplianceModel(name: 'Heavy Duty Exhaust', watts: 300, icon: Icons.air),
      ApplianceModel(name: 'Air Compressor', watts: 2200, icon: Icons.compress),
      ApplianceModel(
        name: 'Welding Machine',
        watts: 3500,
        icon: Icons.construction,
      ),
      ApplianceModel(
        name: 'HVAC System (5 Ton)',
        watts: 6000,
        icon: Icons.ac_unit,
      ),
      ApplianceModel(
        name: 'Conveyor Belt System',
        watts: 5000,
        icon: Icons.moving,
      ),
    ];
  }

  // Backup fallback
  return [
    ApplianceModel(name: 'Bulb', watts: 15, icon: Icons.lightbulb),
    ApplianceModel(name: 'Fan', watts: 80, icon: Icons.air),
  ];
}

ApplianceModel buildCustomAppliance({
  required String name,
  required int watts,
  int quantity = 1,
  int hoursPerDay = 0,
  int daysPerMonth = 30,
}) {
  return ApplianceModel(
    name: name,
    watts: watts,
    icon: Icons.devices_other_rounded,
    isCustom: true,
    isSelected: true,
    quantity: quantity,
    hoursPerDay: hoursPerDay,
    daysPerMonth: daysPerMonth,
    notes: 'Custom appliance added by user',
  );
}
