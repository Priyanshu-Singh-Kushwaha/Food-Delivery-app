import 'package:flutter/material.dart';

class VitalsPage extends StatefulWidget {
  final Map<String, dynamic> vitalsConsumed;
  const VitalsPage({super.key, required this.vitalsConsumed});

  @override
  State<VitalsPage> createState() => _VitalsPageState();
}

class _VitalsPageState extends State<VitalsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Metabolic Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const Divider(height: 30, thickness: 1.8, color: Colors.white12),
          const SizedBox(height: 20),
          _buildVitalsSummaryGrid(context),
          const SizedBox(height: 50),

          Text(
            'Historical Vital Trends',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const Divider(height: 30, thickness: 1.8, color: Colors.white12),
          const SizedBox(height: 20),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Graphs and detailed historical vital data will be displayed here for comprehensive analysis.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildVitalsSummaryGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
        childAspectRatio: 1.0,
      ),
      itemCount: widget.vitalsConsumed.length,
      itemBuilder: (context, index) {
        String vitalName = widget.vitalsConsumed.keys.elementAt(index);
        int consumed = widget.vitalsConsumed[vitalName]['value'] as int;
        int target = widget.vitalsConsumed[vitalName]['target'] as int;
        double progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
        Color progressColor = progress > 0.9 ? Colors.redAccent.shade400 : (progress > 0.7 ? Colors.orangeAccent.shade400 : Theme.of(context).colorScheme.primary);

        int remaining = target - consumed;
        String remainingText = remaining >= 0 ? '$remaining remaining' : '${remaining.abs()} over target';
        Color remainingColor = remaining >= 0 ? Colors.white54 : Colors.redAccent;

        return _buildVitalCard(
          context: context,
          vitalName: vitalName,
          consumed: consumed,
          target: target,
          progress: progress,
          progressColor: progressColor,
          remainingText: remainingText,
          remainingColor: remainingColor,
        );
      },
    );
  }

  Widget _buildVitalCard({
    required BuildContext context,
    required String vitalName,
    required int consumed,
    required int target,
    required double progress,
    required Color progressColor,
    required String remainingText,
    required Color remainingColor,
  }) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vitalName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[850],
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    borderRadius: BorderRadius.circular(6),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: progressColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$consumed / $target',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              remainingText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: remainingColor),
            ),
          ],
        ),
      ),
    );
  }
}