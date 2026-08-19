import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smoking_app/screens/browse_logs_screen.dart';
import 'package:smoking_app/widgets/craving_questionnaire_dialog.dart';

class AddDocsScreen extends StatelessWidget {
  const AddDocsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text('Add Docs',
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
                      Text('Add New Log',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800])),
                      const SizedBox(height: 20),
                      _buildAddButton(
                        icon: Icons.person,
                        title: 'Add Yours',
                        subtitle: 'Add a new craving log',
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) =>
                              const CravingQuestionnaireDialog(),
                        ),
                      ),

                      SizedBox(height: 15),
                      _buildAddButton(
                        icon: Icons.public,
                        title: 'Browse',
                        subtitle:
                            'See how others coped with \nwithdrawals and take ideas',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BrowseCravingLogsScreen(),
                          ),
                        ),
                      ),

                      //const SizedBox(height: 15),
                      //_buildAddButton(
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

  Widget _buildAddButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
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
