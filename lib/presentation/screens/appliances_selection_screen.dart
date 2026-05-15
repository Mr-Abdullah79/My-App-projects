import 'package:flutter/material.dart';
import '../../models/appliance_model.dart';
import 'appliance_usage_screen.dart';

class AppliancesSelectionScreen extends StatefulWidget {
  final String propertyType;
  final List<Color> themeGradient;
  const AppliancesSelectionScreen({super.key, required this.propertyType, required this.themeGradient});

  @override
  State<AppliancesSelectionScreen> createState() =>
      _AppliancesSelectionScreenState();
}

class _AppliancesSelectionScreenState extends State<AppliancesSelectionScreen> {
  late List<ApplianceModel> _appliances;

  @override
  void initState() {
    super.initState();
    _appliances = getAppliancesForCategory(widget.propertyType);
  }

  void _addCustomAppliance() {
    final nameController = TextEditingController();
    final wattsController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Custom Appliance'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Appliance Name',
                    hintText: 'e.g. Water Cooler',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: wattsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Watts',
                    hintText: 'Enter watts if known',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'If you already know the watts, enter them here. Otherwise, ask the appliance label or manual before saving.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final watts = int.tryParse(wattsController.text.trim()) ?? 0;

                if (name.isEmpty || watts <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter appliance name and watts.'),
                    ),
                  );
                  return;
                }

                setState(() {
                  _appliances.add(
                    buildCustomAppliance(name: name, watts: watts),
                  );
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _onNext() {
    final selectedAppliances = _appliances
        .where((app) => app.isSelected)
        .toList();
    if (selectedAppliances.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one appliance to continue.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ApplianceUsageScreen(selectedAppliances: selectedAppliances, themeGradient: widget.themeGradient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Appliances: ${widget.propertyType}'),
        backgroundColor: widget.themeGradient[1],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: widget.themeGradient[1].withValues(alpha: 0.1),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select appliances, add custom items if needed, and enter their quantities. Unknown watts can be added manually.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addCustomAppliance,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeGradient[1],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _appliances.length,
              itemBuilder: (context, index) {
                final app = _appliances[index];
                return CustomCheckboxTile(
                  appliance: app,
                  themeColor: widget.themeGradient[1],
                  onChanged: (val) {
                    setState(() {
                      app.isSelected = val ?? false;
                    });
                  },
                  onQuantityChanged: (qty) {
                    setState(() {
                      app.quantity = qty;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.themeGradient[1],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Next (Enter Usage Time)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCheckboxTile extends StatelessWidget {
  final ApplianceModel appliance;
  final Color themeColor;
  final ValueChanged<bool?> onChanged;
  final ValueChanged<int> onQuantityChanged;

  const CustomCheckboxTile({
    super.key,
    required this.appliance,
    required this.themeColor,
    required this.onChanged,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: appliance.isSelected
            ? themeColor.withValues(alpha: 0.1)
            : Theme.of(context).cardColor,
        border: Border.all(
          color: appliance.isSelected
              ? themeColor
              : Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            activeColor: themeColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            secondary: CircleAvatar(
              backgroundColor: appliance.isSelected
                  ? themeColor
                  : Colors.grey.withValues(alpha: 0.2),
              child: Icon(
                appliance.icon,
                color: appliance.isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            title: Text(
              appliance.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Text('${appliance.watts} Watts'),
            value: appliance.isSelected,
            onChanged: onChanged,
          ),
          if (appliance.isCustom)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Custom appliance — watts are editable in the add flow.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          if (appliance.isSelected)
            Padding(
              padding: const EdgeInsets.only(left: 70, right: 16, bottom: 12),
              child: Row(
                children: [
                  const Text(
                    'Quantity: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: themeColor,
                    ),
                    onPressed: appliance.quantity > 1
                        ? () => onQuantityChanged(appliance.quantity - 1)
                        : null,
                  ),
                  Text(
                    '${appliance.quantity}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: themeColor,
                    ),
                    onPressed: () => onQuantityChanged(appliance.quantity + 1),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
