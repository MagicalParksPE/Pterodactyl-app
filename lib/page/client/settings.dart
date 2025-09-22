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
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pterodactyl_app/globals.dart' as globals;
import 'package:pterodactyl_app/sponsor.dart';
import 'package:pterodactyl_app/main.dart';

class SettingsList extends StatefulWidget {
  const SettingsList({super.key});

  @override
  State<SettingsList> createState() => _SettingsListPageState();
}

class _SettingsListPageState extends State<SettingsList> {
  String _projectVersion = '';

  @override
  void initState() {
    super.initState();
    _initVersion();
  }

  Future<void> _initVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _projectVersion = info.version);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw Exception('Could not launch $url');
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('Value', value);
    setState(() => globals.useDarkTheme = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: globals.useDarkTheme ? null : Colors.transparent,
        title: Text('Settings', style: TextStyle(color: globals.useDarkTheme ? Colors.white : Colors.black)),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark theme'),
            value: globals.useDarkTheme,
            onChanged: _toggleTheme,
          ),
          ListTile(
            leading: const Icon(Icons.euro_symbol),
            title: const Text('Sponsors'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SponsorPage())),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            subtitle: Text(_projectVersion),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete Data'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
