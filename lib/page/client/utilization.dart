/*
* Copyright 2018-2019 Ruben Talstra and Yvan Watchman
*
* Licensed under the GNU General Public License v3.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*    https://www.gnu.org/licenses/gpl-3.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sparkline/sparkline.dart';
import 'package:http/http.dart' as http;
import 'package:pterodactyl_app/globals.dart' as globals;
import 'package:pterodactyl_app/page/auth/shared_preferences_helper.dart';
import 'package:pterodactyl_app/main.dart';
import 'actionserver.dart';

class StatePage extends StatefulWidget {
  final Stats server;
  const StatePage({super.key, required this.server});

  @override
  State<StatePage> createState() => _StatePageState();
}

class _StatePageState extends State<StatePage> {
  String? _stats;
  int _memorycurrent = 0;
  int _memorylimit = 0;
  List<double> _cpu = [0.0];
  double _currentCpu = 0.0;
  int _limitCpu = 0;
  int _diskcurrent = 0;
  int _disklimit = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchData());
  }

  Future<void> _fetchData() async {
    final api = await SharedPreferencesHelper.getString("apiKey") ?? '';
    final url = await SharedPreferencesHelper.getString("panelUrl") ?? '';
    final https = await SharedPreferencesHelper.getString("https") ?? '';

    final response = await http.get(
      Uri.parse("$https$url/api/client/servers/${widget.server.id}/utilization"),
      headers: {
        "Accept": "Application/vnd.pterodactyl.v1+json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $api",
      },
    );

    final data = json.decode(response.body);
    final cpuCores = List<double>.from(
        (data["attributes"]["cpu"]["cores"] as List).map((e) => e.toDouble()));

    setState(() {
      _stats = data["attributes"]["state"];
      _memorycurrent = data["attributes"]["memory"]["current"];
      _memorylimit = data["attributes"]["memory"]["limit"];
      _cpu = cpuCores;
      _currentCpu = (data["attributes"]["cpu"]["current"] as num).toDouble();
      _limitCpu = data["attributes"]["cpu"]["limit"];
      _diskcurrent = data["attributes"]["disk"]["current"];
      _disklimit = data["attributes"]["disk"]["limit"];
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget _buildTile(Widget child, {VoidCallback? onTap}) {
    return Material(
      elevation: 14.0,
      borderRadius: BorderRadius.circular(12.0),
      shadowColor: globals.useDarkTheme ? Colors.blueGrey : const Color(0x802196F3),
      child: InkWell(
        onTap: onTap ?? () => debugPrint('Not set yet'),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: globals.useDarkTheme ? null : Colors.transparent,
        leading: IconButton(
          color: globals.useDarkTheme ? Colors.white : Colors.black,
          icon: Icon(Icons.arrow_back, color: globals.useDarkTheme ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
            timer?.cancel();
          },
        ),
        title: Text(DemoLocalizations.of(context).trans('utilization_stats'),
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: StaggeredGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        children: [
          _buildTile(
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Status:", style: TextStyle(color: Colors.blueAccent)),
                      Text(
                        _stats ?? 'Loading',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                      ),
                    ],
                  ),
                  Material(
                    color: _stats == "on"
                        ? Colors.green
                        : _stats == "off"
                            ? Colors.red
                            : Colors.amber,
                    shape: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(Icons.data_usage, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildTile(
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('CPU Usage', style: TextStyle(color: Colors.blueAccent)),
                  Text('$_currentCpu% / $_limitCpu%'),
                  SizedBox(
                    height: 100,
                    child: Sparkline(data: _cpu, lineWidth: 3, lineColor: Colors.green),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
