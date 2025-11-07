import 'package:flutter/material.dart';

class HealthDashboardPage extends StatelessWidget {
  const HealthDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comprehensive Health Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
            const Divider(height: 30, thickness: 1.8, color: Colors.white12),
            const SizedBox(height: 20),

            _buildSectionCard(
              context,
              title: 'Metabolic Performance',
              content: Column(
                children: [
                  _buildMetricRow(Icons.bolt, 'Energy Burn (Daily)', '2000 kcal', Colors.amber),
                  _buildMetricRow(Icons.fitness_center, 'Muscle Growth Index', 'High', Colors.lightGreen),
                  _buildMetricRow(Icons.speed, 'Metabolic Rate', 'Optimal', Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionCard(
              context,
              title: 'Activity & Recovery',
              content: Column(
                children: [
                  _buildMetricRow(Icons.directions_run, 'Steps Today', '8,500', Colors.purpleAccent),
                  _buildMetricRow(Icons.bedtime, 'Sleep Score (Last Night)', '8.2/10', Colors.indigoAccent),
                  _buildMetricRow(Icons.spa, 'Recovery Status', 'Excellent', Colors.pinkAccent),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionCard(
              context,
              title: 'Long-Term Trends',
              content: Column(
                children: [
                  _buildMetricRow(Icons.trending_up, 'Weight Trend', 'Stable (-0.5kg/month)', Colors.cyan),
                  _buildMetricRow(Icons.favorite, 'Heart Health Score', '95/100', Colors.redAccent),
                  _buildMetricRow(Icons.analytics, 'Overall Health Index', 'A+', Colors.limeAccent),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: Text(
                'Data is updated in real-time by Nexus\'s integrated sensors and AI protocols.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.white54),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required Widget content}) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 25, thickness: 1.5, color: Colors.white12),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}