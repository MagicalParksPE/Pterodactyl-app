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
import 'package:pterodactyl_app/globals.dart' as globals;
import 'package:pterodactyl_app/page/auth/sponsorlist.dart';
import 'package:url_launcher/url_launcher.dart';

class SponsorPage extends StatelessWidget {
  const SponsorPage({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: globals.useDarkTheme ? null : Colors.transparent,
        leading: IconButton(
          color: globals.useDarkTheme ? Colors.white : Colors.black,
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back,
              color: globals.useDarkTheme ? Colors.white : Colors.black),
        ),
        title: Text(
          'Sponsor List',
          style: TextStyle(
              color: globals.useDarkTheme ? Colors.white : Colors.black,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView.builder(
        itemCount: SponsorList.sponsorList.length,
        itemBuilder: (context, index) {
          final sponsor = SponsorList.sponsorList[index];
          return GestureDetector(
            onTap: () => _launchUrl(sponsor.link),
            child: Column(
              children: [
                const Divider(height: 12.0),
                ListTile(
                  leading: CircleAvatar(
                    radius: 24.0,
                    backgroundImage: NetworkImage(sponsor.avatarUrl),
                  ),
                  title: Row(
                    children: [
                      Text(sponsor.name),
                      const SizedBox(width: 16.0),
                      Text(sponsor.donation, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  subtitle: Text(sponsor.message),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14.0),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _launchUrl('https://www.paypal.me/RDTalstra'),
        icon: const Icon(Icons.add),
        label: const Text('Donate'),
      ),
    );
  }
}
