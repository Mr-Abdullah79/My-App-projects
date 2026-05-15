import 'dart:ui';
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
  final List<Color> themeGradient;

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
    required this.themeGradient,
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

    // Duty is percentage of base cost
    double dutyCost = baseCost * (duty / 100);

    double subTotal = baseCost + fpaCost + fcCost + trCost + dutyCost;
    double gstCost = subTotal * (gstPercent / 100);

    double totalBill = subTotal + gstCost + tvFee;
    double yearlyEstimate = days > 0
        ? (totalBill / days) * 365
        : totalBill * 12;

    // Calculate percentages for the visual breakdown bar
    double taxesAndSurcharges = fpaCost + fcCost + trCost + dutyCost + gstCost + tvFee;
    double basePercent = totalBill > 0 ? (baseCost / totalBill).clamp(0.0, 1.0) : 0.0;
    double taxPercent = totalBill > 0 ? (taxesAndSurcharges / totalBill).clamp(0.0, 1.0) : 0.0;

    int baseFlex = (basePercent * 100).toInt();
    int taxFlex = (taxPercent * 100).toInt();

    // Ensure at least 1 flex if there is any value, to avoid flex=0 errors
    if (baseFlex == 0 && baseCost > 0) baseFlex = 1;
    if (taxFlex == 0 && taxesAndSurcharges > 0) taxFlex = 1;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Energy Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Professional Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeGradient[0].withValues(alpha: 0.8),
                  themeGradient[1].withValues(alpha: 0.9),
                  themeGradient[1],
                ],
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- HEADER GLASS CARD ---
                  _GlassContainer(
                    child: Row(
                      children: [
                        Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withValues(alpha: 0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ],
                            image: companyName == 'OTHER'
                                ? null
                                : DecorationImage(
                                    image: AssetImage(
                                      'assets/images/${companyName.toLowerCase()}_logo.png',
                                    ),
                                    fit: BoxFit.contain,
                                  ),
                          ),
                          child: companyName == 'OTHER'
                              ? const Icon(Icons.bolt, color: Colors.blueGrey, size: 35)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$companyName Estimate',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${totalUnits.toStringAsFixed(1)} Units • $days Days',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[300],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.cyanAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  'Slab: ${_tariffCategoryLabel(companyName, totalUnits)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.cyanAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- TOTAL BILL HIGHLIGHT CARD ---
                  _GlassContainer(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    child: Column(
                      children: [
                        const Text(
                          'TOTAL EXPECTED BILL',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Rs. ${totalBill.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.cyanAccent,
                            shadows: [
                              Shadow(
                                color: Colors.cyanAccent,
                                blurRadius: 20,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        
                        // Visual Cost Breakdown Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Base Cost ${(basePercent * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Taxes ${(taxPercent * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Row(
                            children: [
                              if (baseFlex > 0)
                                Expanded(
                                  flex: baseFlex,
                                  child: Container(height: 8, color: Colors.cyanAccent),
                                ),
                              if (taxFlex > 0)
                                Expanded(
                                  flex: taxFlex,
                                  child: Container(height: 8, color: Colors.orangeAccent),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- ITEMIZED RECEIPT GLASS CARD ---
                  _GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.receipt_long, color: Colors.cyanAccent),
                            SizedBox(width: 10),
                            Text(
                              'Cost Breakdown',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildReceiptRow('Base Energy', baseCost, subtitle: '${totalUnits.toStringAsFixed(1)} units @ Rs.${appliedUnitRate.toStringAsFixed(2)}'),
                        _buildReceiptRow('FPA', fpaCost),
                        _buildReceiptRow('F.C. Surcharge', fcCost),
                        _buildReceiptRow('T.R. Surcharge', trCost),
                        _buildReceiptRow('Electricity Duty ($duty%)', dutyCost),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Colors.white30, thickness: 1),
                        ),
                        _buildReceiptRow('Sub Total', subTotal, isHighlight: true),
                        const SizedBox(height: 12),
                        _buildReceiptRow('GST ($gstPercent%)', gstCost, isTax: true),
                        _buildReceiptRow('TV Fee', tvFee, isTax: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- YEARLY ESTIMATE GLASS CARD ---
                  _GlassContainer(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orangeAccent.withValues(alpha: 0.3),
                        Colors.deepOrange.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderColor: Colors.orangeAccent.withValues(alpha: 0.5),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.orangeAccent,
                          size: 35,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Yearly Projection',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Estimated annual cost without solar:',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey[300]),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'Rs. ${yearlyEstimate.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.orangeAccent,
                              shadows: [Shadow(color: Colors.orangeAccent, blurRadius: 10)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- ACTION BUTTON ---
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                              themeGradient: themeGradient,
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wb_sunny_rounded, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Find the Best Solar System',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
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
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String title, double amount, {bool isHighlight = false, bool isTax = false, String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isHighlight ? 16 : 14,
                    color: isHighlight ? Colors.white : Colors.grey[300],
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ]
              ],
            ),
          ),
          Text(
            'Rs. ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isHighlight ? 18 : 15,
              color: isHighlight ? Colors.cyanAccent : (isTax ? Colors.orangeAccent : Colors.white),
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// --- CUSTOM GLASS CONTAINER WIDGET ---
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final Color? borderColor;

  const _GlassContainer({
    required this.child,
    this.padding,
    this.gradient,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient ?? LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
