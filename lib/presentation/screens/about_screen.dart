import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.solar_power_outlined,
              size: 80,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 24),
            Text(
              'Solar Install Pro',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Founder Profile\nInnovator | Software Engineer | AI Specialist\nI am Muhammad Abdullah Arif,a Software Engineering student at National Textile University with a passion for building practical systems that simplify complex energy planning decisions. My focus is on Mobile Development (Flutter & Dart) and AI-assisted automation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange.withOpacity(0.25)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Benefits',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Estimates energy usage from appliance selection and usage hours.',
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• Applies company-based tariff and surcharge inputs for bill projection.',
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• Recommends suitable solar systems (On-Grid, Off-Grid, Hybrid).',
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• Calculates expected monthly/yearly savings and return on investment (ROI).',
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• Stores completed analyses in history for future comparison.',
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
