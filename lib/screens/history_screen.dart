import 'package:flutter/material.dart';

import '../app.dart';
import '../models/analysis_result.dart';
import '../models/scan_record.dart';
import '../services/history_service.dart';
import '../widgets/scan_record_tile.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.historyService});

  final HistoryService? historyService;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final HistoryService _historyService;
  final TextEditingController _searchController = TextEditingController();
  List<ScanRecord> _records = const [];
  bool _loading = true;
  String? _error;
  String _search = '';
  Set<String> _riskFilters = const {'Safe', 'Caution', 'High Risk'};

  @override
  void initState() {
    super.initState();
    _historyService = widget.historyService ?? HistoryService();
    _loadRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    if (mounted) setState(() => _loading = true);
    try {
      final records = await _historyService.getRecords();
      if (!mounted) return;
      setState(() {
        _records = records;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load scan history from this device.';
      });
    }
  }

  List<ScanRecord> get _filteredRecords {
    final query = _search.trim().toLowerCase();
    return _records.where((record) {
      final uri = Uri.tryParse(record.content);
      final domain = uri?.host.toLowerCase() ?? '';
      final risk = switch (record.riskLevel) {
        RiskLevel.low => 'Safe',
        RiskLevel.medium => 'Caution',
        RiskLevel.high => 'High Risk',
      };
      final matchesSearch = query.isEmpty ||
          record.content.toLowerCase().contains(query) ||
          domain.contains(query);
      return matchesSearch && _riskFilters.contains(risk);
    }).toList(growable: false);
  }

  Future<void> _openRecord(ScanRecord record) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          decodedContent: record.content,
          analysisOverride: record.toAnalysisResult(),
          historyService: _historyService,
          returnLabel: 'Back to history',
          allowReanalyse: record.isValidUrl,
        ),
      ),
    );
    await _loadRecords();
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded,
            color: QRGuardTheme.caution),
        title: const Text('Clear scan history?'),
        content: const Text(
          'This removes QRGuard scan records stored on this device. It does not affect other app data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Clear history'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _historyService.clearHistory();
      await _loadRecords();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan history cleared.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not clear scan history.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            tooltip: 'Clear scan history',
            onPressed: _records.isEmpty || _loading ? null : _confirmClear,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorState(message: _error!, onRetry: _loadRecords)
                : _records.isEmpty
                    ? const _EmptyHistory()
                    : RefreshIndicator(
                        onRefresh: _loadRecords,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                          itemCount: _filteredRecords.length + 2,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      key: const Key('history-search'),
                                      controller: _searchController,
                                      onChanged: (value) => setState(() => _search = value),
                                      decoration: const InputDecoration(
                                        hintText: 'Search content or domain',
                                        prefixIcon: Icon(Icons.search_rounded),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      children: ['Safe', 'Caution', 'High Risk'].map((risk) {
                                        return FilterChip(
                                          label: Text(risk),
                                          selected: _riskFilters.contains(risk),
                                          onSelected: (selected) => setState(() {
                                            final next = {..._riskFilters};
                                            if (selected) {
                                              next.add(risk);
                                            } else {
                                              next.remove(risk);
                                            }
                                            _riskFilters = next;
                                          }),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              );
                            }
                            if (index == 1) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  '${_filteredRecords.length} ${_filteredRecords.length == 1 ? 'scan' : 'scans'} stored on this device',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: QRGuardTheme.textSecondary),
                                ),
                              );
                            }
                            final record = _filteredRecords[index - 2];
                            return ScanRecordTile(
                              record: record,
                              onTap: () => _openRecord(record),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history_rounded,
                  size: 60, color: QRGuardTheme.textFaded),
              const SizedBox(height: 18),
              Text(
                'No scans yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: QRGuardTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'QR codes you analyze will appear here.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: QRGuardTheme.caution),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}