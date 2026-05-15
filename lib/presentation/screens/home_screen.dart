import 'package:flutter/material.dart';
import '../../main.dart';
import 'appliances_selection_screen.dart';
import 'package:semester_project_app/services/auth_service.dart';
import 'login_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        bool isDarkMode = themeMode == ThemeMode.dark;
        
        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
          appBar: AppBar(
            title: const Text(
              'Solar installation app by Mr Abdullah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            centerTitle: true,
            foregroundColor: isDarkMode ? Colors.white : Colors.blueGrey,
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: 'History',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Sign Out',
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: isDarkMode ? const Color(0xFF121212) : Colors.white,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Solar Install Pro',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Smart Energy Estimation',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          ValueListenableBuilder<ThemeMode>(
                            valueListenable: themeNotifier,
                            builder: (context, mode, child) {
                              bool isDark = mode == ThemeMode.dark;
                              return Container(
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white24 : Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    isDark ? Icons.light_mode : Icons.dark_mode,
                                    color: isDark ? Colors.white : Colors.blueGrey,
                                  ),
                                  onPressed: () {
                                    themeNotifier.value = isDark
                                        ? ThemeMode.light
                                        : ThemeMode.dark;
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Select Property Type',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.blueGrey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Choose a category to calculate custom load.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    GridView.count(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 8.0,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.85,
                      children: [
                        _buildPropertyCard(
                          context,
                          icon: Icons.house_rounded,
                          title: 'Single Story\nHouse',
                          gradient: [Colors.lightBlue[400]!, Colors.blue[700]!],
                          propertyType: 'Single Story House',
                        ),
                        _buildPropertyCard(
                          context,
                          icon: Icons.domain_rounded,
                          title: 'Double Story\nHouse',
                          gradient: [Colors.orange[400]!, Colors.deepOrange[600]!],
                          propertyType: 'Double Story House',
                        ),
                        _buildPropertyCard(
                          context,
                          icon: Icons.business_rounded,
                          title: 'Office\nCommercial',
                          gradient: [Colors.teal[400]!, Colors.teal[700]!],
                          propertyType: 'Office Commercial',
                        ),
                        _buildPropertyCard(
                          context,
                          icon: Icons.storefront_rounded,
                          title: 'Shop\nRetail',
                          gradient: [Colors.purple[400]!, Colors.purple[700]!],
                          propertyType: 'Shop Retail',
                        ),
                        _buildPropertyCard(
                          context,
                          icon: Icons.agriculture_rounded,
                          title: 'Agriculture\nFarming',
                          gradient: [Colors.green[400]!, Colors.green[800]!],
                          propertyType: 'Agriculture',
                        ),
                        _buildPropertyCard(
                          context,
                          icon: Icons.factory_rounded,
                          title: 'Industrial\nDomain',
                          gradient: [Colors.blueGrey[400]!, Colors.blueGrey[700]!],
                          propertyType: 'Industrial',
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Why Go Solar?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.blueGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          _buildBenefitItem(
                            context,
                            icon: Icons.battery_charging_full_rounded,
                            title: 'Save on Electricity Bills',
                            description:
                                'Zero electricity bills allows you to save money for other needs.',
                            color: Colors.greenAccent,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 12),
                          _buildBenefitItem(
                            context,
                            icon: Icons.park_rounded,
                            title: 'Eco-Friendly',
                            description:
                                'Reduces your carbon footprint and fights global warming.',
                            color: Colors.cyanAccent,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 12),
                          _buildBenefitItem(
                            context,
                            icon: Icons.home_repair_service_rounded,
                            title: 'Ultra Low Maintenance',
                            description:
                                'Just keep them clean. Panels last for 25+ years without issues.',
                            color: Colors.orangeAccent,
                            isDarkMode: isDarkMode,
                          ),
                        ],
                      ),
                    ),

                    // Solar Facts Banner Container
                    Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white30
                              : Colors.grey[400]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.wb_sunny_rounded,
                            color: Colors.amber,
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Did you know?',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Solar panels can increase a property\'s value significantly!',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.blueGrey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        },
      );
  }

  Widget _buildPropertyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Color> gradient,
    required String propertyType,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppliancesSelectionScreen(
                propertyType: propertyType,
                themeGradient: gradient,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white30,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradient[0].withValues(alpha: 0.85),
                gradient[1].withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: gradient[1].withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    height: 1.4,
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
