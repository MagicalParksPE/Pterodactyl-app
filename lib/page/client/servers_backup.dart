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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pterodactyl_app/globals.dart' as globals;
import 'package:pterodactyl_app/page/auth/shared_preferences_helper.dart';
import 'package:pterodactyl_app/main.dart';
import 'actionserver.dart';

class User {
  final String id;
  final String name;
  const User({required this.id, required this.name});
}

class ServerListPage extends StatefulWidget {
  const ServerListPage({super.key});

  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

class _ServerListPageState extends State<ServerListPage> {
  List<dynamic> userData = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchServers();
  }

  Future<void> _fetchServers({String search = ''}) async {
    final api = await SharedPreferencesHelper.getString("apiKey") ?? '';
    final url = await SharedPreferencesHelper.getString("panelUrl") ?? '';
    final https = await SharedPreferencesHelper.getString("https") ?? '';

    final response = await http.get(
      Uri.parse("$https$url/api/client"),
      headers: {
        "Accept": "Application/vnd.pterodactyl.v1+json",
        "Authorization": "Bearer $api",
      },
    );

    final data = json.decode(response.body);
    setState(() {
      if (search.isEmpty) {
        userData = data['data'];
      } else {
        userData = data['data']
            .where((v) => v['attributes']['name'].toString().contains(search))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchServers(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: userData.length,
        itemBuilder: (context, index) {
          final server = userData[index];
          final name = server["attributes"]["name"] ?? '';
          final description = server["attributes"]["description"] ?? '';
          final identifier = server["attributes"]["identifier"] ?? '';
          final memory = server["attributes"]["limits"]["memory"] ?? 0;
          final disk = server["attributes"]["limits"]["disk"] ?? 
