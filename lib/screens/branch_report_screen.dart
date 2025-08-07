import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/branch.dart';
import '../models/branch_report.dart';
import '../services/branch_service.dart';
import '../widgets/chat_button.dart';

class BranchReportScreen extends StatefulWidget {
  final Branch branch;
  const BranchReportScreen({super.key, required this.branch});

  @override
  State<BranchReportScreen> createState() => _BranchReportScreenState();
}

class _BranchReportScreenState extends State<BranchReportScreen> {
  final BranchService _service = BranchService();
  BranchReport? _report;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final report = await _service.getBranchReport(widget.branch.id!);
    setState(() {
      _report = report;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reporte - ${widget.branch.name}')),
      floatingActionButton: const ChatButton(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _report == null
              ? const Center(child: Text('Sin datos'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Text('Ventas'),
                                    const SizedBox(height: 8),
                                    Text(
                                      _report!.salesCount.toString(),
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Text('Monto Total'),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Q${_report!.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: _report!.salesCount.toDouble(),
                                color: Colors.deepOrange,
                                title: 'Ventas',
                              ),
                              PieChartSectionData(
                                value: _report!.totalAmount,
                                color: Colors.orangeAccent,
                                title: 'Monto',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
