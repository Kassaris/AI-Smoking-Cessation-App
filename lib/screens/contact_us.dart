import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  void _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@quitsmokingapp.com',
      query: 'subject=Support Request',
    );

    final canLaunch = await canLaunchUrl(emailUri);
    debugPrint('Can launch mailto: $canLaunch');

    final launched = await launchUrl(
      emailUri,
      mode: LaunchMode.platformDefault,
    );

    debugPrint('Launch result: $launched');

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No email app found.")),
      );
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+1234567890');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  //void _launchWebsite() async {
  //  final Uri websiteUri = Uri.parse('https://www.quitsmokingapp.com');
  //if (await canLaunchUrl(websiteUri)) {
  // await launchUrl(websiteUri);
  // }
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text('Contact Us',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child:
                Image.asset('assets/images/secondary.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          SafeArea(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.85,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(5, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Get in Touch',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800])),
                      const SizedBox(height: 20),
                      _buildContactTile(
                        icon: Icons.email,
                        title: 'Email Us',
                        subtitle: 'support@quitsmokingapp.com',
                        onTap: () => _launchEmail(context),
                      ),
                      const SizedBox(height: 15),
                      _buildContactTile(
                        icon: Icons.phone,
                        title: 'Call Us',
                        subtitle: '+1 234 567 890',
                        onTap: _launchPhone,
                      ),
                      //const SizedBox(height: 15),
                      //_buildContactTile(
                      //icon: Icons.web,
                      //title: 'Visit Our Website',
                      //subtitle: 'www.quitsmokingapp.com',
                      //onTap: _launchWebsite,
                      //),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.green[800], size: 28),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 46, 125, 55))),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
