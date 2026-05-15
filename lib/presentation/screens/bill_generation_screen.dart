import 'package:flutter/material.dart';
import 'generated_bill_screen.dart';

class BillGenerationScreen extends StatefulWidget {
  final double totalUnits;
  final int days;
  final List<String> selectedAppliances;
  final List<Color> themeGradient;

  const BillGenerationScreen({
    super.key,
    required this.totalUnits,
    required this.days,
    required this.selectedAppliances,
    required this.themeGradient,
  });

  @override
  State<BillGenerationScreen> createState() => _BillGenerationScreenState();
}

class _BillGenerationScreenState extends State<BillGenerationScreen> {
  String _selectedCompany = 'LESCO';
  final List<String> _companies = [
    'LESCO',
    'MEPCO',
    'GEPCO',
    'FESCO',
    'IESCO',
    'OTHER',
  ];

  final Map<String, Map<String, double>> _companyTariffSlabs = {
    'LESCO': {'upto200': 28.0, 'above200': 36.0},
    'MEPCO': {'upto200': 29.0, 'above200': 37.5},
    'GEPCO': {'upto200': 27.5, 'above200': 35.5},
    'FESCO': {'upto200': 28.5, 'above200': 36.5},
    'IESCO': {'upto200': 26.5, 'above200': 34.5},
  };

  final _unitRateController = TextEditingController();
  final _customUpto200RateController = TextEditingController();
  final _customAbove200RateController = TextEditingController();
  final _fpaController = TextEditingController();
  final _fcSurchargeController = TextEditingController();
  final _trSurchargeController = TextEditingController();
  final _electricityDutyController = TextEditingController();
  final _gstPercentController = TextEditingController();
  final _tvFeeController = TextEditingController();

  // Pre-defined dummy rates for autofill demonstration
  final Map<String, Map<String, String>> _companyRates = {
    'LESCO': {
      'unit': '30.5',
      'fpa': '2.50',
      'fc': '0.43',
      'tr': '1.50',
      'duty': '1.5',
      'gst': '18',
      'tv': '35',
    },
    'MEPCO': {
      'unit': '32.0',
      'fpa': '3.10',
      'fc': '0.43',
      'tr': '1.20',
      'duty': '1.5',
      'gst': '18',
      'tv': '35',
    },
    'GEPCO': {
      'unit': '29.8',
      'fpa': '2.10',
      'fc': '0.43',
      'tr': '1.80',
      'duty': '1.5',
      'gst': '18',
      'tv': '35',
    },
    'FESCO': {
      'unit': '31.2',
      'fpa': '2.80',
      'fc': '0.43',
      'tr': '1.40',
      'duty': '1.5',
      'gst': '18',
      'tv': '35',
    },
    'IESCO': {
      'unit': '28.5',
      'fpa': '1.50',
      'fc': '0.43',
      'tr': '1.10',
      'duty': '1.5',
      'gst': '18',
      'tv': '35',
    },
  };

  @override
  void initState() {
    super.initState();
    _applyRates(_selectedCompany);
  }

  bool get _isOtherSelected => _selectedCompany == 'OTHER';

  double _getTariffRateForCompany(String company, double units) {
    final slabs = _companyTariffSlabs[company];
    if (slabs == null) return 0.0;
    return units <= 200
        ? (slabs['upto200'] ?? 0.0)
        : (slabs['above200'] ?? 0.0);
  }

  double _getCustomTariffRateForUnits(double units) {
    final upto200 = double.tryParse(_customUpto200RateController.text) ?? 0.0;
    final above200 = double.tryParse(_customAbove200RateController.text) ?? 0.0;
    return units <= 200 ? upto200 : above200;
  }

  void _syncAppliedUnitRateFromCurrentSelection() {
    final appliedRate = _isOtherSelected
        ? _getCustomTariffRateForUnits(widget.totalUnits)
        : _getTariffRateForCompany(_selectedCompany, widget.totalUnits);
    _unitRateController.text = appliedRate.toStringAsFixed(2);
  }

  void _applyRates(String company) {
    if (company == 'OTHER') {
      _customUpto200RateController.text =
          _customUpto200RateController.text.isEmpty
          ? '0.00'
          : _customUpto200RateController.text;
      _customAbove200RateController.text =
          _customAbove200RateController.text.isEmpty
          ? '0.00'
          : _customAbove200RateController.text;
      _fpaController.text = _fpaController.text.isEmpty
          ? '0.00'
          : _fpaController.text;
      _fcSurchargeController.text = _fcSurchargeController.text.isEmpty
          ? '0.00'
          : _fcSurchargeController.text;
      _trSurchargeController.text = _trSurchargeController.text.isEmpty
          ? '0.00'
          : _trSurchargeController.text;
      _electricityDutyController.text = _electricityDutyController.text.isEmpty
          ? '0.00'
          : _electricityDutyController.text;
      _gstPercentController.text = _gstPercentController.text.isEmpty
          ? '0.00'
          : _gstPercentController.text;
      _tvFeeController.text = _tvFeeController.text.isEmpty
          ? '0.00'
          : _tvFeeController.text;

      _syncAppliedUnitRateFromCurrentSelection();
      return;
    }

    if (_companyRates.containsKey(company)) {
      final rates = _companyRates[company]!;
      final autoTariff = _getTariffRateForCompany(company, widget.totalUnits);
      _unitRateController.text = autoTariff.toStringAsFixed(2);
      _fpaController.text = rates['fpa']!;
      _fcSurchargeController.text = rates['fc']!;
      _trSurchargeController.text = rates['tr']!;
      _electricityDutyController.text = rates['duty']!;
      _gstPercentController.text = rates['gst']!;
      _tvFeeController.text = rates['tv']!;
    }
  }

  void _navigateToGeneratedBill() {
    // Collect all inputs
    double unitRate = _isOtherSelected
        ? _getCustomTariffRateForUnits(widget.totalUnits)
        : _getTariffRateForCompany(_selectedCompany, widget.totalUnits);
    double fpa = double.tryParse(_fpaController.text) ?? 0.0;
    double fc = double.tryParse(_fcSurchargeController.text) ?? 0.0;
    double tr = double.tryParse(_trSurchargeController.text) ?? 0.0;
    double duty = double.tryParse(_electricityDutyController.text) ?? 0.0;
    double gstPercent = double.tryParse(_gstPercentController.text) ?? 0.0;
    double tvFee = double.tryParse(_tvFeeController.text) ?? 0.0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneratedBillScreen(
          companyName: _selectedCompany,
          days: widget.days,
          totalUnits: widget.totalUnits,
          selectedAppliances: widget.selectedAppliances,
          unitRate: unitRate,
          fpa: fpa,
          fc: fc,
          tr: tr,
          duty: duty,
          gstPercent: gstPercent,
          tvFee: tvFee,
          themeGradient: widget.themeGradient,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    String? suffixText,
    bool readOnly = false,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          hintText: hint,
          suffixText: suffixText,
          suffixStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor.withAlpha(230),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _unitRateController.dispose();
    _customUpto200RateController.dispose();
    _customAbove200RateController.dispose();
    _fpaController.dispose();
    _fcSurchargeController.dispose();
    _trSurchargeController.dispose();
    _electricityDutyController.dispose();
    _gstPercentController.dispose();
    _tvFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Taxes & Rates',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.themeGradient[1],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.themeGradient[1].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.themeGradient[1].withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: widget.themeGradient[1],
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Unit tariff is auto-applied by company slab rules: up to 200 units and above 200 units. Select OTHER if you want to enter all rates manually according to your own bill.',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Select Electric Supply Company:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _isOtherSelected
                            ? Colors.grey.withAlpha(35)
                            : null,
                        image: _isOtherSelected
                            ? null
                            : DecorationImage(
                                image: AssetImage(
                                  'assets/images/${_selectedCompany.toLowerCase()}_logo.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: _isOtherSelected
                          ? const Icon(Icons.business, color: Colors.blueGrey)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCompany,
                            isExpanded: true,
                            dropdownColor: Theme.of(context).cardColor,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            items: _companies.map((String company) {
                              return DropdownMenuItem<String>(
                                value: company,
                                child: Text(
                                  company == 'OTHER'
                                      ? 'OTHER (Custom)'
                                      : company,
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCompany = newValue;
                                  _applyRates(newValue);
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Rate Details & Taxes:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isOtherSelected)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Custom mode active: enter slab rates based on your bill (<=200 and >200 units). The applied unit rate is calculated automatically.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Unit Rate is company slab based and auto-set (${widget.totalUnits <= 200 ? '<= 200 units' : '> 200 units'}).',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                if (_isOtherSelected) ...[
                  _buildTextField(
                    'Custom Tariff (<= 200 Units)',
                    _customUpto200RateController,
                    hint: '28.0',
                    suffixText: 'Rs',
                    onChanged: (_) {
                      setState(() {
                        _syncAppliedUnitRateFromCurrentSelection();
                      });
                    },
                  ),
                  _buildTextField(
                    'Custom Tariff (> 200 Units)',
                    _customAbove200RateController,
                    hint: '36.0',
                    suffixText: 'Rs',
                    onChanged: (_) {
                      setState(() {
                        _syncAppliedUnitRateFromCurrentSelection();
                      });
                    },
                  ),
                ],
                _buildTextField(
                  'Applied Unit Rate',
                  _unitRateController,
                  hint: '30.5',
                  suffixText: 'Rs',
                  readOnly: true,
                ),
                _buildTextField(
                  'FPA',
                  _fpaController,
                  hint: '2.5',
                  suffixText: 'Rs',
                ),
                _buildTextField(
                  'F.C. Surcharge',
                  _fcSurchargeController,
                  hint: '0.43',
                  suffixText: 'Rs',
                ),
                _buildTextField(
                  'TR Surcharge',
                  _trSurchargeController,
                  hint: '1.2',
                  suffixText: 'Rs',
                ),
                _buildTextField(
                  'Electricity Duty',
                  _electricityDutyController,
                  hint: '1.5',
                  suffixText: '%',
                ),
                _buildTextField(
                  'GST Rate',
                  _gstPercentController,
                  hint: '18',
                  suffixText: '%',
                ),
                _buildTextField(
                  'TV Fee',
                  _tvFeeController,
                  hint: '35',
                  suffixText: 'Rs',
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToGeneratedBill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeGradient[1],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Generate Bill Receipt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
