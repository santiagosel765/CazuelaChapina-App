
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_summary.dart';
import '../services/dashboard_service.dart';
import '../theme_notifier.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chat_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _service = DashboardService();
  DashboardSummary? _summary;
  bool _loading = true;
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _range = DateTimeRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final summary = await _service.fetchSummary(
      startDate: _range!.start,
      endDate: _range!.end,
    );
    setState(() {
      _summary = summary;
      _loading = false;
    });
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _range,
    );
    if (picked != null) {
      setState(() => _range = picked);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pantalla de dashboard',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Estratégico'),
          actions: [
            Semantics(
              button: true,
              label: 'Seleccionar rango de fechas',
              child: IconButton(
                icon: const Icon(Icons.date_range),
                tooltip: 'Seleccionar rango de fechas',
                onPressed: _pickRange,
              ),
            ),
            Semantics(
              label: 'Menú de perfil',
              child: PopupMenuButton<String>(
                tooltip: 'Perfil',
                icon: const Icon(Icons.person),
                onSelected: (value) {
                  final notifier = context.read<ThemeNotifier>();
                  switch (value) {
                    case 'light':
                      notifier.setTheme(ThemeMode.light);
                      break;
                    case 'dark':
                      notifier.setTheme(ThemeMode.dark);
                      break;
                    default:
                      notifier.setTheme(ThemeMode.system);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'light', child: Text('Tema claro')),
                  PopupMenuItem(value: 'dark', child: Text('Tema oscuro')),
                  PopupMenuItem(value: 'system', child: Text('Usar sistema')),
                ],
              ),
            ),
          ],
        ),
        drawer: const AppDrawer(),
        floatingActionButton: const ChatButton(),
        body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _summary == null
              ? const Center(child: Text('Sin datos'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSalesCards(),
                      const SizedBox(height: 16),
                      _buildTopTamalesChart(),
                      const SizedBox(height: 16),
                      _buildProfitChart(),
                      const SizedBox(height: 16),
                      _buildKpiList(),
                    ],
                  ),
                ),
        ),
      );
    }

  Widget _buildSalesCards() {
    final sales = _summary!.sales;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        if (isWide) {
          return Row(
            children: [
              Expanded(child: _summaryCard('Ventas Hoy', sales.day)),
              const SizedBox(width: 16),
              Expanded(child: _summaryCard('Ventas Mensuales', sales.month)),
            ],
          );
        } else {
          return Column(
            children: [
              _summaryCard('Ventas Hoy', sales.day),
              const SizedBox(height: 16),
              _summaryCard('Ventas Mensuales', sales.month),
            ],
          );
        }
      },
    );
  }

  Card _summaryCard(String title, num value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('\$${value.toString()}', style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTamalesChart() {
    final tamales = _summary!.topTamales;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: List.generate(
                tamales.length,
                (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: tamales[i].quantity.toDouble(),
                      color: Colors.deepOrange,
                    ),
                  ],
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < tamales.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            tamales[index].name,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfitChart() {
    final p = _summary!.profit;
    final lines = [
      {'name': 'Tamales', 'value': p.tamales},
      {'name': 'Bebidas', 'value': p.beverages},
      {'name': 'Combos', 'value': p.combos},
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: List.generate(
                lines.length,
                (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: (lines[i]['value'] as num).toDouble(),
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < lines.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(lines[index]['name'] as String),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: true)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiList() {
    final b = _summary!.popularBeverages;
    final s = _summary!.spiceLevel;
    final w = _summary!.waste;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.local_cafe, color: Colors.brown),
            title: const Text('Bebidas preferidas'),
            subtitle: Text(
              'Mañana: ${b.morning?.name ?? '-'}\n'
              'Tarde: ${b.afternoon?.name ?? '-'}\n'
              'Noche: ${b.night?.name ?? '-'}',
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.whatshot, color: Colors.red),
            title: const Text('Picante vs No Picante'),
            subtitle: Text(
              'Picante: ${s.spicy}  No picante: ${s.nonSpicy}',
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.grey),
            title: const Text('Mermas'),
            subtitle: Text(
              'Cantidad: ${w.quantity}  Costo: \$${w.cost.toString()}',
            ),
          ),
        ],
      ),
    );
  }
}
