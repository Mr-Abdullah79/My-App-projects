import 'package:flutter/material.dart';
import 'system_details_screen.dart';

class SystemRecommendationScreen extends StatefulWidget {
  final double totalUnits;
  final List<String> selectedAppliances;
  final double estimatedMonthlyBill;
  final double estimatedYearlyBill;
  final List<Color> themeGradient;

  const SystemRecommendationScreen({
    super.key,
    required this.totalUnits,
    required this.selectedAppliances,
    required this.estimatedMonthlyBill,
    required this.estimatedYearlyBill,
    required this.themeGradient,
  });

  @override
  State<SystemRecommendationScreen> createState() =>
      _SystemRecommendationScreenState();
}

class _SystemRecommendationScreenState
    extends State<SystemRecommendationScreen> {
  String? _selectedSystem;
  String _recommendedSystem = '';

  @override
  void initState() {
    super.initState();
    _determineRecommendation();
  }

  void _determineRecommendation() {
    // Basic logic for suggestion:
    // Small loads might benefit from Off-Grid (battery only).
    // Large loads definitely need Hybrid or On-Grid.
    if (widget.totalUnits < 300) {
      _recommendedSystem = 'Off-Grid';
    } else if (widget.totalUnits < 800) {
      _recommendedSystem = 'Hybrid';
    } else {
      _recommendedSystem = 'On-Grid';
    }
    // Initially auto-select the recommended one
    _selectedSystem = _recommendedSystem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('System Recommendation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.themeGradient[0].withValues(alpha: 0.8),
              widget.themeGradient[1].withValues(alpha: 0.9),
              widget.themeGradient[1],
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recommendation Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blueAccent.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.amber,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'AI Recommendation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on your total usage of ${widget.totalUnits.toStringAsFixed(1)} units, we highly recommend the $_recommendedSystem System for maximum efficiency and savings.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  'Explore Solar Systems',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap on any system to select it as your preference.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 24),

                _buildSystemOption(
                  title: 'On-Grid System (Peak)',
                  description:
                      'This system is connected directly to the regular utility power grid. It does NOT use batteries. Any extra power you produce is sent back to the grid (Net Metering), saving you money. Great if you rarely have power outages.',
                  icon: Icons.grid_on_rounded,
                  systemType: 'On-Grid',
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildSystemOption(
                  title: 'Off-Grid System',
                  description:
                      'This system is completely disconnected from the power grid. It purely relies on solar panels and batteries to store power. Perfect for remote areas where grid access is impossible.',
                  icon: Icons.battery_charging_full_rounded,
                  systemType: 'Off-Grid',
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildSystemOption(
                  title: 'Hybrid System',
                  description:
                      'The best of both worlds! Connected to the grid AND uses batteries. It stores energy for nighttime or power outages in batteries, and can still send extra power back to the grid.',
                  icon: Icons.sync_rounded,
                  systemType: 'Hybrid',
                  color: Colors.blue,
                ),

                const SizedBox(height: 40),

                // Proceed / Select button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeGradient[1],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SystemDetailsScreen(
                            systemType: _selectedSystem!,
                            totalUnits: widget.totalUnits,
                            selectedAppliances: widget.selectedAppliances,
                            currentMonthlyBill: widget.estimatedMonthlyBill,
                            currentYearlyBill: widget.estimatedYearlyBill,
                            themeGradient: widget.themeGradient,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Confirm $_selectedSystem',
                      style: const TextStyle(
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

  Widget _buildSystemOption({
    required String title,
    required String description,
    required IconData icon,
    required String systemType,
    required Color color,
  }) {
    bool isSelected = _selectedSystem == systemType;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSystem = systemType;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: color, size: 24),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
