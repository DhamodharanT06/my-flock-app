import 'dart:convert';
import 'dart:math';
import 'package:flock_app/main.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flock_app/parameters.dart';
import 'package:http/http.dart' as http;

class Graph extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final String yKey;
  final Color color;

  const Graph({
    super.key,
    required this.title,
    required this.data,
    required this.yKey,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final fs = width * 0.2;

    // Use data directly in order from API (last 7 days)
    final List<Map<String, dynamic>> orderedData = data.isNotEmpty ? data : [];
    final List<double> values =
        orderedData
            .map((e) => double.tryParse(e[yKey]?.toString() ?? '') ?? 0.0)
            .toList();

    final maxY =
        values.isNotEmpty
            ? (values.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble()
            : 10.0;

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),

          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.12),
          //     blurRadius: 16,
          //     offset: const Offset(0, 6),
          //   ),
          // ],
          // gradient: LinearGradient(
          //   colors: [
          //     Colors.white,
          //     maincol.withAlpha(50),
          //   ], //Colors.blue.shade50.withOpacity(0.4)],
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          // ),
          color: maincol.withAlpha(30),
          // color: color.withOpacity(0.08),
          border: Border.all(color: textcol),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with gradient text effect
              ShaderMask(
                shaderCallback:
                    (bounds) => LinearGradient(
                      // colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      colors: [textcol, textcol],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Graph Container with enhanced styling
              Container(
                height: height * 0.4,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.transparent,
                ),
                child:
                    orderedData.isEmpty
                        ? Center(
                          child: Text(
                            'No data available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                        : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxY,
                            minY: 0,
                            barGroups: List.generate(values.length, (index) {
                              final value = values[values.length - 1 - index];
                              return BarChartGroupData(
                                x: values.length - 1 - index,
                                barRods: [
                                  BarChartRodData(
                                    toY: value,
                                    width: 20,
                                    color: color,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: maxY,
                                      color: Colors.grey.shade100.withOpacity(
                                        0.0,
                                      ),
                                    ),
                                    rodStackItems: [],
                                  ),
                                ],
                              );
                            }),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 ||
                                        index >= orderedData.length) {
                                      return const Text('');
                                    }
                                    final day =
                                        orderedData[index]['day'] ?? 'N/A';
                                    final date =
                                        orderedData[index]['date'] ?? '';
                                    final dateStr =
                                        date.isNotEmpty
                                            ? date.split('-').skip(2).join('/')
                                            : '';

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            day,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            dateStr,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: maxY.toString().length * 3 + 18,
                                  interval: maxY > 0 ? max(1, maxY / 5) : 1,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text(
                                        value.toStringAsFixed(0),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),

                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                left: BorderSide(
                                  color: Colors.black54.withOpacity(0.4),
                                  width: 2.5,
                                ),
                                bottom: BorderSide(
                                  color: Colors.black54.withOpacity(0.4),
                                  width: 2.5,
                                ),
                                right: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                                top: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                            ),

                            gridData: FlGridData(
                              show: false,
                              // drawHorizontalLine: true,
                              // horizontalInterval:
                              //     maxY > 0 ? max(1, maxY / 5) : 1,
                              // getDrawingHorizontalLine:
                              //     (value) => FlLine(
                              //       strokeWidth: 1.2,
                              //       color: Colors.grey.shade300.withOpacity(
                              //         0.6,
                              //       ),
                              //       dashArray: [6, 4],
                              //     ),
                            ),

                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipRoundedRadius: 14,
                                tooltipPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                getTooltipItem: (
                                  group,
                                  groupIndex,
                                  rod,
                                  rodIndex,
                                ) {
                                  final index = group.x.toInt();
                                  if (index < 0 ||
                                      index >= orderedData.length) {
                                    return null;
                                  }
                                  final dayName =
                                      orderedData[index]['day'] ?? 'N/A';
                                  var dateStr = "";
                                  var datStr = orderedData[index]['date'] ?? '';
                                  datStr = datStr.split('-');
                                  for (int i = datStr.length - 1; i >= 0; i--) {
                                    if (i == 0) {
                                      dateStr += datStr[i];
                                      break;
                                    }
                                    dateStr += datStr[i] + "-";
                                  }

                                  return BarTooltipItem(
                                    '$dayName\n$dateStr\n',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${rod.toY.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          swapAnimationDuration: const Duration(
                            milliseconds: 1200,
                          ),
                          swapAnimationCurve: Curves.easeInOutCubic,
                        ),
              ),
              const SizedBox(height: 24),

              // Enhanced info bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.transparent,
                  // gradient: LinearGradient(
                  //   colors: [
                  //     // Colors.blue.shade50.withOpacity(0.6),
                  //     // Colors.indigo.shade50.withOpacity(0.4),
                  //     maincol.withOpacity(0.2),
                  //     maincol.withOpacity(0.2),
                  //   ],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                  border: Border.all(color: textcol.withAlpha(200), width: 0.4),
                  // border: Border.all(color: Colors.blue.shade200, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: textcol.withAlpha(30),
                        // color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        // color: Colors.blue.shade700,
                        color: textcol,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last 7 Days Data',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              // color: Colors.blue.shade700,
                              color: textcol,
                            ),
                          ),
                          Text(
                            'Showing average values by day',
                            style: TextStyle(
                              fontSize: 11,
                              // color: Colors.blue.shade600.withOpacity(0.7),
                              color: textcol,
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
    );
  }
}

class GraphScreen extends StatefulWidget {
  final Future<Map<String, dynamic>?> chickData;
  final String? nodeId;

  const GraphScreen({super.key, required this.chickData, this.nodeId});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  late Future<Map<String, dynamic>?> _graphDataFuture;
  int _selectedIndex = 0;

  static List<Map<String, dynamic>> sensorTypes = [
    const {
      'key': 'temperature',
      'label': 'Temperature (°C)',
      'color': Colors.red,
      'icon': '🌡️',
    },
    const {
      'key': 'humidity',
      'label': 'Humidity (%)',
      'color': Colors.blue,
      'icon': '💧',
    },
    const {
      'key': 'co2',
      'label': 'CO₂ (ppm)',
      'color': Colors.green,
      'icon': '🌬️',
    },
    const {
      'key': 'nh3',
      'label': 'NH₃ (ppm)',
      'color': Colors.orange,
      'icon': '⚠️',
    },
    const {
      'key': 'h2s',
      'label': 'H₂S (ppm)',
      'color': Colors.purple,
      'icon': '☠️',
    },
    const {
      'key': 'weight',
      'label': 'Weight (kg)',
      'color': Colors.cyan,
      'icon': '⚖️',
    },
    const {
      'key': 'battery',
      'label': 'Battery (%)',
      'color': Colors.amber,
      'icon': '🔋',
    },
    {'key': 'lux', 'label': 'Light (lux)', 'color': maincol, 'icon': '💡'},
  ];

  @override
  void initState() {
    super.initState();
    // Use data fetched from details page (no redundant fetch)
    _graphDataFuture = widget.chickData;
  }

  List<Map<String, dynamic>> _extractNodeData(
    Map<String, dynamic> apiData,
    String sensorKey,
  ) {
    List<Map<String, dynamic>> result = [];
    final weeklyData = apiData['weekly_data'] as Map<String, dynamic>?;

    if (weeklyData == null) return result;

    // Get node to display - either specified or first available
    final nodeId = widget.nodeId ?? weeklyData.keys.first;
    final nodeDataList = weeklyData[nodeId] as List<dynamic>?;

    if (nodeDataList == null) return result;

    for (var item in nodeDataList) {
      if (item is Map<String, dynamic>) {
        final mappedItem = <String, dynamic>{
          'date': item['date'],
          'day': item['day'],
          'timestamp': '${item['date']} 00:00:00',
          'temperature': item['temperature'] ?? 0.0,
          'humidity': item['humidity'] ?? 0.0,
          'co2': item['co2'] ?? 0.0,
          'nh3': item['nh3'] ?? 0.0,
          'h2s': item['h2s'] ?? 0.0,
          'weight': item['weight'] ?? 0.0,
          'battery': item['battery'] ?? 0.0,
          'lux': item['lux'] ?? 0.0,
        };
        result.add(mappedItem);
      }
    }

    return result;
  }

  Future<Map<String, dynamic>?> getGraphData() async {
    try {
      final res = await http.get(
        Uri.parse("$graph_url?phonenumber=${mobilenum.text.trim()}"),
      );
      if (res.statusCode == 200) {
        print("Graph Data Success : ${res.body}");
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) return decoded;
        return null;
      } else {
        print("Graph Data error : ${res.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final fs = width * 0.2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analysis"),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _graphDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: fs, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load data'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _graphDataFuture = getGraphData();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final apiData = snapshot.data!;
          final currentSensor = sensorTypes[_selectedIndex];
          final nodeData = _extractNodeData(apiData, currentSensor['key']);

          return Column(
            children: [
              // Sensor selector chips
              SizedBox(
                height: height * 0.12,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: sensorTypes.length,
                  itemBuilder: (context, index) {
                    final sensor = sensorTypes[index];
                    final isSelected = index == _selectedIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedIndex = index);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          width: 100,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? (sensor['color'] as Color).withOpacity(
                                      0.3,
                                    )
                                    : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? (sensor['color'] as Color)
                                      : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                sensor['icon'],
                                style: const TextStyle(fontSize: 22),
                              ),
                              SizedBox(height: 5),
                              Text(
                                sensor['label'].toString().split('(')[0].trim(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected
                                          ? Colors.black
                                          : Colors.black26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Graph display
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Graph(
                          title: currentSensor['label'],
                          data: nodeData,
                          yKey: currentSensor['key'],
                          color: currentSensor['color'],
                        ),
                      ),
                      // Data summary
                      _buildDataSummary(nodeData, currentSensor),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataSummary(
    List<Map<String, dynamic>> data,
    Map<String, dynamic> sensor,
  ) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final key = sensor['key'];
    final values =
        data
            .map((e) => double.tryParse(e[key]?.toString() ?? '') ?? 0.0)
            .toList();

    final avg =
        values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / values.length;
    final max = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    final min = values.isEmpty ? 0.0 : values.reduce((a, b) => a < b ? a : b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (sensor['color'] as Color).withOpacity(0.1),
            (sensor['color'] as Color).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (sensor['color'] as Color).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: sensor['color'],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryCard('Average', avg.toStringAsFixed(2)),
              _buildSummaryCard('Maximum', max.toStringAsFixed(2)),
              _buildSummaryCard('Minimum', min.toStringAsFixed(2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
