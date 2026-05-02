import 'package:flutter/material.dart';

import '../../services/history_storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await HistoryStorageService.getHistory();
    if (!mounted) return;
    setState(() {
      _entries = data;
      _loading = false;
    });
  }

  Future<void> _deleteAt(int index) async {
    await HistoryStorageService.deleteAt(index);
    await _load();
  }

  Future<void> _clearAll() async {
    await HistoryStorageService.clearAll();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved History'),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              onPressed: _clearAll,
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Delete All History',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
          ? const Center(
              child: Text('No saved history yet.'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final e = _entries[index];
                final appliances = (e['appliances'] as List?)
                        ?.map((x) => x.toString())
                        .toList() ??
                    <String>[];

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${e['systemType']} • ${e['brandName']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _deleteAt(index),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                      Text('Date: ${e['savedAt'] ?? '-'}'),
                      Text('Bill (without solar): Rs. ${e['monthlyBill'] ?? 0} / month'),
                      Text('Solar setup cost: Rs. ${e['solarCost'] ?? 0}'),
                      Text('ROI: ${e['roiMonths'] ?? '-'} months'),
                      const SizedBox(height: 8),
                      const Text(
                        'Appliances on Solar:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appliances.isEmpty ? '-' : appliances.join(', '),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
