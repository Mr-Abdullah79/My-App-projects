import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'solar_roi_screen.dart';

class SystemDetailsScreen extends StatefulWidget {
  final String systemType;
  final double totalUnits;
  final List<String> selectedAppliances;
  final double currentMonthlyBill;
  final double currentYearlyBill;

  const SystemDetailsScreen({
    super.key,
    required this.systemType,
    required this.totalUnits,
    required this.selectedAppliances,
    required this.currentMonthlyBill,
    required this.currentYearlyBill,
  });

  @override
  State<SystemDetailsScreen> createState() => _SystemDetailsScreenState();
}

class _SystemDetailsScreenState extends State<SystemDetailsScreen> {
  static const double _panelWatt = 585; // Typical modern panel in Pakistan
  static const double _peakSunHours = 5.2;
  static const double _systemDerating = 0.78;
  static const double _batteryVoltage = 12;
  static const double _batteryAmpHours = 200;
  static const double _batteryUsableDod = 0.50;

  late Map<String, Equipment> _equipmentMap;
  String _selectedBrand = 'Budget (JA + Growatt + Narada)';
  bool _isRefreshingRates = false;
  String? _ratesSyncMessage;
  final TextEditingController _ratesApiController = TextEditingController(
    text:
        'https://raw.githubusercontent.com/solar-rate-sync/pakistan-market/main/solar_rates_pk.json',
  );

  late Map<String, BrandPreset> _brandPresets = {
    'Budget (JA + Growatt + Narada)': BrandPreset(
      lastUpdated: 'April 2026',
      referenceTitle: 'Pakistan market retail snapshots',
      referenceUrl:
          'https://www.daraz.pk/ ; https://www.growatt.com/ ; https://www.naradapower.com/',
      rates: {
        'solar_panels': 28500,
        'inverter': 108000,
        'hybrid_inverter': 182000,
        'battery': 26500,
        'charge_controller': 30500,
        'wiring': 130,
        'monitoring': 15500,
        'grid_synchronizer': 13800,
      },
    ),
    'Standard (Longi + Inverex + Pylontech)': BrandPreset(
      lastUpdated: 'April 2026',
      referenceTitle: 'Brand pages + local installer quotations',
      referenceUrl:
          'https://www.longi.com/ ; https://www.inverex.com/ ; https://www.pylontech.com.cn/',
      rates: {
        'solar_panels': 32900,
        'inverter': 142000,
        'hybrid_inverter': 218000,
        'battery': 31500,
        'charge_controller': 40500,
        'wiring': 160,
        'monitoring': 20500,
        'grid_synchronizer': 18800,
      },
    ),
    'Premium (Jinko N-Type + Fronius + BYD)': BrandPreset(
      lastUpdated: 'April 2026',
      referenceTitle: 'OEM official pages + premium dealer quotes',
      referenceUrl:
          'https://www.jinkosolar.com/ ; https://www.fronius.com/ ; https://www.byd.com/',
      rates: {
        'solar_panels': 38900,
        'inverter': 202000,
        'hybrid_inverter': 292000,
        'battery': 41200,
        'charge_controller': 53500,
        'wiring': 208,
        'monitoring': 30200,
        'grid_synchronizer': 24900,
      },
    ),
  };

  @override
  void initState() {
    super.initState();
    _initializeEquipment();
    _loadBundledRates();
  }

  @override
  void dispose() {
    for (final equipment in _equipmentMap.values) {
      equipment.rateController.dispose();
    }
    _ratesApiController.dispose();
    super.dispose();
  }

  void _initializeEquipment() {
    _equipmentMap = _getEquipmentForSystem(widget.systemType);
    _applySelectedBrandRates();
    _applyAutoSizingQuantities();
  }

  double get _dailyKwh => widget.totalUnits / 30.0;

  double get _sizingMultiplier {
    switch (widget.systemType) {
      case 'Off-Grid':
        return 1.22;
      case 'Hybrid':
        return 1.12;
      case 'On-Grid':
      default:
        return 1.00;
    }
  }

  double get _rawSolarKw {
    final base = _dailyKwh / (_peakSunHours * _systemDerating);
    return base * _sizingMultiplier;
  }

  int get _recommendedPanelCount {
    final count = (_rawSolarKw * 1000 / _panelWatt).ceil();
    return count < 1 ? 1 : count;
  }

  double get _recommendedSolarKw =>
      (_recommendedPanelCount * _panelWatt) / 1000;

  double get _batteryNominalKwh => (_batteryVoltage * _batteryAmpHours) / 1000;

  double get _batteryUsableKwh => _batteryNominalKwh * _batteryUsableDod;

  double get _requiredBackupKwh {
    switch (widget.systemType) {
      case 'Off-Grid':
        return _dailyKwh * 0.80;
      case 'Hybrid':
        return _dailyKwh * 0.35;
      case 'On-Grid':
      default:
        return 0;
    }
  }

  int get _recommendedBatteryCount {
    if (_requiredBackupKwh <= 0) return 0;
    final count = (_requiredBackupKwh / _batteryUsableKwh).ceil();
    return count < 1 ? 1 : count;
  }

  double _roundUpToHalf(double value) {
    return (value * 2).ceil() / 2;
  }

  double get _recommendedInverterKw {
    final factor = widget.systemType == 'On-Grid'
        ? 0.85
        : widget.systemType == 'Off-Grid'
        ? 0.75
        : 0.90;
    final kw = _recommendedSolarKw * factor;
    return _roundUpToHalf(kw < 1.0 ? 1.0 : kw);
  }

  double get _panelsPerBattery {
    if (_recommendedBatteryCount == 0) return 0;
    return _recommendedPanelCount / _recommendedBatteryCount;
  }

  void _applyAutoSizingQuantities() {
    final panel = _equipmentMap['solar_panels'];
    if (panel != null) {
      panel.quantity = _recommendedPanelCount.toDouble();
    }

    final battery = _equipmentMap['battery'];
    if (battery != null) {
      battery.quantity = _recommendedBatteryCount.toDouble();
    }

    final inverter = _equipmentMap['inverter'];
    if (inverter != null) {
      inverter.quantity = 1;
    }

    final hybridInverter = _equipmentMap['hybrid_inverter'];
    if (hybridInverter != null) {
      hybridInverter.quantity = 1;
    }

    final chargeController = _equipmentMap['charge_controller'];
    if (chargeController != null) {
      chargeController.quantity = (_recommendedPanelCount / 12).ceilToDouble();
    }
  }

  void _applySelectedBrandRates() {
    final preset = _brandPresets[_selectedBrand];
    if (preset == null) return;

    for (final entry in _equipmentMap.entries) {
      final matchedRate = preset.rates[entry.key];
      if (matchedRate != null) {
        entry.value.rateController.text = matchedRate.toStringAsFixed(0);
      }
    }
  }

  Map<String, BrandPreset> _parseBrandPresetsFromPayload(
    Map<String, dynamic> decoded, {
    required String fallbackUrl,
  }) {
    final dynamic brandsNode = decoded['brands'];
    if (brandsNode is! Map<String, dynamic>) {
      throw Exception('Missing brands object in response');
    }

    final fetched = <String, BrandPreset>{};
    for (final entry in brandsNode.entries) {
      final dynamic value = entry.value;
      if (value is! Map<String, dynamic>) continue;

      final rates = <String, double>{};
      for (final rateEntry in value.entries) {
        final parsed = double.tryParse(rateEntry.value.toString());
        if (parsed != null) {
          rates[rateEntry.key] = parsed;
        }
      }

      if (rates.isEmpty) continue;

      fetched[entry.key] = BrandPreset(
        lastUpdated: decoded['lastUpdated']?.toString() ?? 'Live sync',
        referenceTitle:
            decoded['source']?.toString() ?? 'Online synced rate source',
        referenceUrl: decoded['sourceUrl']?.toString() ?? fallbackUrl,
        rates: rates,
      );
    }

    if (fetched.isEmpty) {
      throw Exception('No valid brand rates found in payload');
    }

    return fetched;
  }

  Future<void> _loadBundledRates({bool showMessage = false}) async {
    try {
      final raw = await rootBundle.loadString(
        'assets/data/solar_rates_pk.json',
      );
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid bundled JSON');
      }

      final fetched = _parseBrandPresetsFromPayload(
        decoded,
        fallbackUrl: 'assets/data/solar_rates_pk.json',
      );

      if (!mounted) return;

      setState(() {
        _brandPresets = fetched;
        if (!_brandPresets.containsKey(_selectedBrand)) {
          _selectedBrand = _brandPresets.keys.first;
        }
        _applySelectedBrandRates();
        if (showMessage) {
          _ratesSyncMessage =
              'Offline bundled rates loaded successfully (no internet).';
        }
      });
    } catch (_) {
      if (!mounted) return;
      if (showMessage) {
        setState(() {
          _ratesSyncMessage =
              'Online and bundled rate sync failed. Keeping existing rates.';
        });
      }
    }
  }

  Future<void> _refreshRatesFromApi() async {
    final url = _ratesApiController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _ratesSyncMessage = 'Please enter API URL first.';
      });
      return;
    }

    setState(() {
      _isRefreshingRates = true;
      _ratesSyncMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid JSON payload');
      }

      final fetched = _parseBrandPresetsFromPayload(decoded, fallbackUrl: url);

      setState(() {
        _brandPresets = fetched;
        if (!_brandPresets.containsKey(_selectedBrand)) {
          _selectedBrand = _brandPresets.keys.first;
        }
        _applySelectedBrandRates();
        _ratesSyncMessage =
            'Latest rates synced successfully from online source.';
      });
    } catch (_) {
      await _loadBundledRates(showMessage: true);
    } finally {
      setState(() {
        _isRefreshingRates = false;
      });
    }
  }

  double get _dailyUnits => widget.totalUnits / 30.0;

  double get _fallbackUnitRate {
    if (widget.totalUnits <= 200) return 28;
    if (widget.totalUnits <= 500) return 34;
    return 38;
  }

  double get _totalSystemCost {
    double total = 0;
    for (final equipment in _equipmentMap.values) {
      total += equipment.quantity * equipment.currentRate;
    }
    return total;
  }

  Map<String, Equipment> _getEquipmentForSystem(String systemType) {
    if (systemType == 'On-Grid') {
      return {
        'solar_panels': Equipment(
          name: 'Solar Panels',
          description: 'Generate power from sunlight',
          icon: Icons.wb_sunny_rounded,
          baseQuantity: 8,
          unit: 'plates',
          rate: 32900,
          benefits: 'Maximize energy generation from available sunlight',
          disadvantages: 'More panels = higher initial cost',
        ),
        'inverter': Equipment(
          name: 'Inverter (On-Grid)',
          description: 'Converts DC to AC power',
          icon: Icons.electric_bolt_rounded,
          baseQuantity: 1,
          unit: 'pcs',
          rate: 142000,
          benefits: 'Essential for grid synchronization and efficiency',
          disadvantages: 'Cannot provide power during grid failure',
        ),
        'wiring': Equipment(
          name: 'Wiring & Cables',
          description: 'Connect all components safely',
          icon: Icons.router_rounded,
          baseQuantity: 500,
          unit: 'meters',
          rate: 160,
          benefits: 'Thicker cables reduce power loss',
          disadvantages: 'More wiring = higher material and installation costs',
        ),
        'monitoring': Equipment(
          name: 'Monitoring System',
          description: 'Track system performance',
          icon: Icons.assessment_rounded,
          baseQuantity: 1,
          unit: 'pcs',
          rate: 20500,
          benefits: 'Better monitoring ensures optimal performance',
          disadvantages: 'Advanced monitoring increases upfront cost',
        ),
      };
    } else if (systemType == 'Off-Grid') {
      return {
        'solar_panels': Equipment(
          name: 'Solar Panels',
          description: 'Generate power from sunlight',
          icon: Icons.wb_sunny_rounded,
          baseQuantity: 12,
          unit: 'plates',
          rate: 32900,
          benefits: 'More panels ensure better charging during cloudy days',
          disadvantages: 'Oversizing increases initial cost significantly',
        ),
        'battery': Equipment(
          name: 'Battery Bank',
          description: 'Store solar energy',
          icon: Icons.battery_charging_full_rounded,
          baseQuantity: 6,
          unit: 'batteries',
          rate: 31500,
          benefits: 'Larger capacity ensures 24/7 power availability',
          disadvantages: 'Battery cost is high; requires regular maintenance',
        ),
        'inverter': Equipment(
          name: 'Inverter (Off-Grid)',
          description: 'Converts DC to AC power',
          icon: Icons.electric_bolt_rounded,
          baseQuantity: 1,
          unit: 'pcs',
          rate: 150000,
          benefits: 'Off-grid inverters provide complete independence',
          disadvantages: 'Cannot export excess power to grid',
        ),
        'charge_controller': Equipment(
          name: 'Charge Controller',
          description: 'Regulates charging to batteries',
          icon: Icons.settings_remote_rounded,
          baseQuantity: 1,
          unit: 'pcs',
          rate: 40500,
          benefits: 'Protects batteries from overcharging',
          disadvantages: 'Additional component increases complexity',
        ),
      };
    } else {
      // Hybrid System
      return {
        'solar_panels': Equipment(
          name: 'Solar Panels',
          description: 'Generate power from sunlight',
          icon: Icons.wb_sunny_rounded,
          baseQuantity: 10,
          unit: 'plates',
          rate: 32900,
          benefits: 'Balanced size for both charging and grid supply',
          disadvantages: 'Must balance between battery charging and export',
        ),
        'battery': Equipment(
          name: 'Battery Bank',
          description: 'Store solar energy',
          icon: Icons.battery_charging_full_rounded,
          baseQuantity: 4,
          unit: 'batteries',
          rate: 31500,
          benefits: 'Provides backup during outages and night time',
          disadvantages: 'Battery replacement costs occur every 5-10 years',
        ),
        'hybrid_inverter': Equipment(
          name: 'Hybrid Inverter',
          description: 'Manages power flow between sources',
          icon: Icons.sync_rounded,
          baseQuantity: 1,
          unit: 'pcs',
          rate: 218000,
          benefits: 'Switches seamlessly between grid, battery, and solar',
          disadvantages: 'Hybrid inverters are more expensive than basic ones',
        ),
        'charge_controller': Equipment(
          name: 'Smart Charge Controller',
          description: 'Optimizes battery charging',
          icon: Icons.settings_remote_rounded,
          baseQuantity: 1,
          unit: 'pcs',
          rate: 40500,
          benefits: 'Improves battery lifespan and efficiency',
          disadvantages: 'Adds complexity to system management',
        ),
        'grid_synchronizer': Equipment(
          name: 'Grid Synchronization Unit',
          description: 'Handles excess power export',
          icon: Icons.router_rounded,
          baseQuantity: 1,
          unit: 'pcs',
          rate: 18800,
          benefits: 'Allows net metering and earning credits',
          disadvantages: 'Requires utility approval and additional setup',
        ),
      };
    }
  }

  void _adjustQuantity(String equipmentKey, bool increase) {
    setState(() {
      final equipment = _equipmentMap[equipmentKey]!;
      if (increase) {
        equipment.quantity += equipment.baseQuantity * 0.1;
        _showMessage(equipment.name, '✅ ${equipment.benefits}', Colors.green);
      } else {
        if (equipment.quantity > equipment.baseQuantity * 0.5) {
          equipment.quantity -= equipment.baseQuantity * 0.1;
          _showMessage(
            equipment.name,
            '⚠️ ${equipment.disadvantages}',
            Colors.orange,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '❌ Cannot reduce further. Minimum threshold reached.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  void _showMessage(String title, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(fontSize: 13)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showCalculationDetailsDialog() {
    final baseSolarKw = _dailyKwh / (_peakSunHours * _systemDerating);
    final panelCountRaw = (_rawSolarKw * 1000) / _panelWatt;
    final inverterFactor = widget.systemType == 'On-Grid'
        ? 0.85
        : widget.systemType == 'Off-Grid'
        ? 0.75
        : 0.90;
    final rawInverterKw = _recommendedSolarKw * inverterFactor;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Calculation Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('System Type: ${widget.systemType}'),
                Text('Monthly Units: ${widget.totalUnits.toStringAsFixed(1)}'),
                const SizedBox(height: 10),
                const Text(
                  '1) Daily Energy Demand',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.totalUnits.toStringAsFixed(1)} / 30 = ${_dailyKwh.toStringAsFixed(2)} kWh/day',
                ),
                const SizedBox(height: 8),
                const Text(
                  '2) Base Solar Size',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_dailyKwh.toStringAsFixed(2)} / (${_peakSunHours.toStringAsFixed(1)} x ${_systemDerating.toStringAsFixed(2)}) = ${baseSolarKw.toStringAsFixed(2)} kW',
                ),
                Text(
                  'System multiplier (${_sizingMultiplier.toStringAsFixed(2)}) -> ${baseSolarKw.toStringAsFixed(2)} x ${_sizingMultiplier.toStringAsFixed(2)} = ${_rawSolarKw.toStringAsFixed(2)} kW',
                ),
                const SizedBox(height: 8),
                const Text(
                  '3) Panel Count',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Panel power = ${_panelWatt.toStringAsFixed(0)}W each'),
                Text(
                  '(${_rawSolarKw.toStringAsFixed(2)} x 1000) / ${_panelWatt.toStringAsFixed(0)} = ${panelCountRaw.toStringAsFixed(2)} -> ceil = $_recommendedPanelCount panels',
                ),
                Text(
                  'Installed solar size = $_recommendedPanelCount x ${_panelWatt.toStringAsFixed(0)} / 1000 = ${_recommendedSolarKw.toStringAsFixed(2)} kW',
                ),
                const SizedBox(height: 8),
                const Text(
                  '4) Inverter Sizing',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Inverter factor (${inverterFactor.toStringAsFixed(2)}) -> ${_recommendedSolarKw.toStringAsFixed(2)} x ${inverterFactor.toStringAsFixed(2)} = ${rawInverterKw.toStringAsFixed(2)} kW',
                ),
                Text(
                  'Rounded to nearest 0.5kW = ${_recommendedInverterKw.toStringAsFixed(1)} kW',
                ),
                if (widget.systemType != 'On-Grid') ...[
                  const SizedBox(height: 8),
                  const Text(
                    '5) Battery Sizing',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Battery model: ${_batteryVoltage.toStringAsFixed(0)}V ${_batteryAmpHours.toStringAsFixed(0)}Ah',
                  ),
                  Text(
                    'Nominal battery energy = ${_batteryVoltage.toStringAsFixed(0)} x ${_batteryAmpHours.toStringAsFixed(0)} / 1000 = ${_batteryNominalKwh.toStringAsFixed(2)} kWh',
                  ),
                  Text(
                    'Usable battery energy (DoD ${(_batteryUsableDod * 100).toStringAsFixed(0)}%) = ${_batteryUsableKwh.toStringAsFixed(2)} kWh',
                  ),
                  Text(
                    'Required backup = ${_requiredBackupKwh.toStringAsFixed(2)} kWh',
                  ),
                  Text(
                    '${_requiredBackupKwh.toStringAsFixed(2)} / ${_batteryUsableKwh.toStringAsFixed(2)} = ${(_requiredBackupKwh / _batteryUsableKwh).toStringAsFixed(2)} -> ceil = $_recommendedBatteryCount batteries',
                  ),
                  Text(
                    'Panel-to-battery ratio = ${_recommendedPanelCount.toStringAsFixed(0)} / $_recommendedBatteryCount = ${_panelsPerBattery.toStringAsFixed(2)} panels per battery',
                  ),
                ],
                const SizedBox(height: 8),
                const Text(
                  'Note: These are planning estimates. Final design depends on site conditions, shading, wiring losses, and installer standards.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalEquipment = _equipmentMap.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${widget.systemType} System Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/solar_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // System Info Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blueAccent.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.build_circle,
                        color: Colors.amber,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.systemType} System',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Load: ${widget.totalUnits.toStringAsFixed(1)} units',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Approx Daily Load: ${_dailyUnits.toStringAsFixed(1)} units/day',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Contains $totalEquipment key components',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Auto Sizing (Based on Your Load)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Recommended solar capacity: ${_recommendedSolarKw.toStringAsFixed(2)} kW',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Panel size: ${_panelWatt.toStringAsFixed(0)}W per plate',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Panels required: $_recommendedPanelCount plates',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recommended inverter: ${_recommendedInverterKw.toStringAsFixed(1)} kW (${widget.systemType})',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      if (widget.systemType != 'On-Grid') ...[
                        const SizedBox(height: 4),
                        Text(
                          'Battery model used: ${_batteryVoltage.toStringAsFixed(0)}V ${_batteryAmpHours.toStringAsFixed(0)}Ah (usable ${_batteryUsableKwh.toStringAsFixed(2)} kWh per battery)',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Batteries required: $_recommendedBatteryCount',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Panel-to-battery ratio: ${_panelsPerBattery.toStringAsFixed(2)} panels per battery',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: _showCalculationDetailsDialog,
                          icon: const Icon(Icons.calculate_outlined, size: 18),
                          label: const Text('View Calculation Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Brand Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.35),
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How this option works',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '• Selecting a brand auto-applies component rates.\n'
                              '• "Refresh Latest Rates" tries to fetch updated rates from the online API.\n'
                              '• If internet/API fails, the app automatically uses bundled offline rates.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedBrand,
                        dropdownColor: const Color(0xFF1E1E1E),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        items: _brandPresets.keys.map((brand) {
                          return DropdownMenuItem<String>(
                            value: brand,
                            child: Text(
                              brand,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedBrand = value;
                            _applySelectedBrandRates();
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _ratesApiController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Live Rates API URL (JSON)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isRefreshingRates
                              ? null
                              : _refreshRatesFromApi,
                          icon: _isRefreshingRates
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.sync),
                          label: Text(
                            _isRefreshingRates
                                ? 'Refreshing...'
                                : 'Refresh Latest Rates',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      if (_ratesSyncMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _ratesSyncMessage!,
                          style: TextStyle(
                            color: _ratesSyncMessage!.contains('success')
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        'Reference: ${_brandPresets[_selectedBrand]!.referenceTitle}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _brandPresets[_selectedBrand]!.referenceUrl,
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last checked: ${_brandPresets[_selectedBrand]!.lastUpdated}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimated System Cost',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rs. ${_totalSystemCost.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Equipment Requirements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Quantities are auto-calculated from your load. You can fine-tune with + / - and edit rates to match the latest market.',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),

                const SizedBox(height: 20),

                ..._equipmentMap.entries.map((entry) {
                  final key = entry.key;
                  final equipment = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildEquipmentCard(key, equipment),
                  );
                }),

                const SizedBox(height: 30),

                // Proceed Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final fallbackMonthlyBill =
                          widget.totalUnits * _fallbackUnitRate;
                      final monthlyBill = widget.currentMonthlyBill > 0
                          ? widget.currentMonthlyBill
                          : fallbackMonthlyBill;
                      final yearlyBill = widget.currentYearlyBill > 0
                          ? widget.currentYearlyBill
                          : monthlyBill * 12;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SolarRoiScreen(
                            systemType: widget.systemType,
                            brandName: _selectedBrand,
                            selectedAppliances: widget.selectedAppliances,
                            systemCost: _totalSystemCost,
                            monthlyBillWithoutSolar: monthlyBill,
                            yearlyBillWithoutSolar: yearlyBill,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Confirm & View Benefits / ROI',
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
        ),
      ),
    );
  }

  Widget _buildEquipmentCard(String key, Equipment equipment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(equipment.icon, color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      equipment.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current rate: Rs. ${equipment.currentRate.toStringAsFixed(0)} / ${equipment.unit}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quantity Display and Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity: ${equipment.quantityString} ${equipment.unit}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _adjustQuantity(key, false),
                    child: const Icon(
                      Icons.remove,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _adjustQuantity(key, true),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: equipment.rateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              setState(() {});
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Rate per ${equipment.unit}',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixText: 'Rs. ',
              prefixStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Line total', style: TextStyle(color: Colors.white70)),
              Text(
                'Rs. ${equipment.lineTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Benefits and Disadvantages
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.thumb_up_rounded,
                  color: Colors.green,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Increase: ${equipment.benefits}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.thumb_down_rounded,
                  color: Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Decrease: ${equipment.disadvantages}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Equipment {
  final String name;
  final String description;
  final IconData icon;
  final double baseQuantity;
  final String unit;
  final TextEditingController rateController;
  final String benefits;
  final String disadvantages;
  double quantity;

  double get currentRate => double.tryParse(rateController.text) ?? 0;

  double get lineTotal => quantity * currentRate;

  String get quantityString {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toStringAsFixed(0);
    }
    return quantity.toStringAsFixed(1);
  }

  Equipment._internal({
    required this.name,
    required this.description,
    required this.icon,
    required this.baseQuantity,
    required this.unit,
    required double rate,
    required this.benefits,
    required this.disadvantages,
    required this.quantity,
  }) : rateController = TextEditingController(text: rate.toStringAsFixed(0));

  factory Equipment({
    required String name,
    required String description,
    required IconData icon,
    required double baseQuantity,
    required String unit,
    required double rate,
    required String benefits,
    required String disadvantages,
  }) {
    return Equipment._internal(
      name: name,
      description: description,
      icon: icon,
      baseQuantity: baseQuantity,
      unit: unit,
      rate: rate,
      benefits: benefits,
      disadvantages: disadvantages,
      quantity: baseQuantity,
    );
  }
}

class BrandPreset {
  final String lastUpdated;
  final String referenceTitle;
  final String referenceUrl;
  final Map<String, double> rates;

  BrandPreset({
    required this.lastUpdated,
    required this.referenceTitle,
    required this.referenceUrl,
    required this.rates,
  });
}
