import 'package:flutter/material.dart';
import 'system_recommendation_screen.dart';

class GeneratedBillScreen extends StatelessWidget {
  final String companyName;
  final int days;
  final double totalUnits;
  final List<String> selectedAppliances;
  final double unitRate;
  final double fpa;
  final double fc;
  final double tr;
  final double duty;
  final double gstPercent;
  final double tvFee;

  const GeneratedBillScreen({
    super.key,
    required this.companyName,
    required this.days,
    required this.totalUnits,
    required this.selectedAppliances,
    required this.unitRate,
    required this.fpa,
    required this.fc,
    required this.tr,
    required this.duty,
    required this.gstPercent,
    required this.tvFee,
  });

  double _getTariffRateForCompany(String company, double units) {
    const companyTariffSlabs = {
      'LESCO': {'upto200': 28.0, 'above200': 36.0},
      'MEPCO': {'upto200': 29.0, 'above200': 37.5},
      'GEPCO': {'upto200': 27.5, 'above200': 35.5},
      'FESCO': {'upto200': 28.5, 'above200': 36.5},
      'IESCO': {'upto200': 26.5, 'above200': 34.5},
    };

    final slabs = companyTariffSlabs[company];
    if (slabs == null) return unitRate;
    return units <= 200
        ? (slabs['upto200'] ?? unitRate)
        : (slabs['above200'] ?? unitRate);
  }

  String _tariffCategoryLabel(String company, double units) {
    if (company == 'OTHER') {
      return 'Custom Tariff (User Entered)';
    }
    return units <= 200
        ? 'Protected (<= 200 Units)'
        : 'Non-Protected (> 200 Units)';
  }

  @override
  Widget build(BuildContext context) {
    final appliedUnitRate = _getTariffRateForCompany(companyName, totalUnits);
    double baseCost = totalUnits * appliedUnitRate;
    double fpaCost = totalUnits * fpa;
    double fcCost = totalUnits * fc;
    double trCost = totalUnits * tr;

    // Assuming duty is percentage of base cost
    double dutyCost = baseCost * (duty / 100);

    double subTotal = baseCost + fpaCost + fcCost + trCost + dutyCost;
    double gstCost = subTotal * (gstPercent / 100);

    double totalBill = subTotal + gstCost + tvFee;
    double yearlyEstimate = days > 0
        ? (totalBill / days) * 365
        : totalBill * 12;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Digital Receipt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: companyName == 'OTHER'
                              ? Colors.grey.shade200
                              : null,
                          image: companyName == 'OTHER'
                              ? null
                              : DecorationImage(
                                  image: AssetImage(
                                    'assets/images/${companyName.toLowerCase()}_logo.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        child: companyName == 'OTHER'
                            ? const Icon(Icons.business, color: Colors.blueGrey)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$companyName Bill Estimate',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Calculated for $days Days • ${totalUnits.toStringAsFixed(1)} Units',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tariff Applied: Rs. ${appliedUnitRate.toStringAsFixed(2)} / Unit',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.teal[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Slab: ${_tariffCategoryLabel(companyName, totalUnits)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Receipt body
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50], // light grey paper feel
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow(
                        'Base Energy Cost (Rs. ${appliedUnitRate.toStringAsFixed(2)} x ${totalUnits.toStringAsFixed(1)} units)',
                        baseCost,
                      ),
                      _buildReceiptRow('Fuel Price Adjustment (FPA)', fpaCost),
                      _buildReceiptRow('F.C. Surcharge', fcCost),
                      _buildReceiptRow('T.R. Surcharge', trCost),
                      _buildReceiptRow('Electricity Duty ($duty%)', dutyCost),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(color: Colors.black26),
                      ),
                      _buildReceiptRow('Sub Total', subTotal, isBold: true),
                      const SizedBox(height: 8),
                      _buildReceiptRow('GST ($gstPercent%)', gstCost),
                      _buildReceiptRow('TV Fee', tvFee),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(color: Colors.black54, thickness: 2),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL EXPECTED BILL',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          Text(
                            'Rs. ${totalBill.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Yearly Estimate Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Estimated Yearly Average',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'If using these appliances at the current rate throughout the whole year, your total expected electricity cost would be around:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Rs. ${yearlyEstimate.toStringAsFixed(0)} / year',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Button to System Recommendation Screen
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent.shade400,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Colors.tealAccent.withOpacity(0.5),
                    ),
                    onPressed: () {
                      final monthlyEquivalentBill = days > 0
                          ? (totalBill / days) * 30
                          : totalBill;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SystemRecommendationScreen(
                            totalUnits: totalUnits,
                            selectedAppliances: selectedAppliances,
                            estimatedMonthlyBill: monthlyEquivalentBill,
                            estimatedYearlyBill: yearlyEstimate,
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.solar_power, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Find the Best Solar System for Me',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildReceiptRow(String title, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: isBold ? Colors.black87 : Colors.grey[700],
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            'Rs. ${amount.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 15,
              color: isBold ? Colors.black87 : Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
