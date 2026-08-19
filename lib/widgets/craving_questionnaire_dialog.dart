import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart'; // Adjust path as needed

class CravingQuestionnaireDialog extends StatefulWidget {
  const CravingQuestionnaireDialog({super.key});

  @override
  State<CravingQuestionnaireDialog> createState() =>
      _CravingQuestionnaireDialogState();
}

class _CravingQuestionnaireDialogState
    extends State<CravingQuestionnaireDialog> {
  List<String> intensityLevels = [
    'Low',
    'Mild',
    'Moderate',
    'Strong',
    'Intense',
    'Extreme'
  ];

  String? _selectedIntensity;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _triggerController = TextEditingController();
  final TextEditingController _copingMethodController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitCravingLog() async {
    final uid = Provider.of<UserProvider>(context, listen: false).user?.id;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_selectedIntensity == null ||
        _descriptionController.text.isEmpty ||
        _triggerController.text.isEmpty ||
        _copingMethodController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('craving_logs').add({
        'intensity': _selectedIntensity,
        'description': _descriptionController.text.trim(),
        'trigger': _triggerController.text.trim(),
        'coping_method': _copingMethodController.text.trim(),
        'timestamp': Timestamp.now(),
        'userId': uid,
      });

      userProvider.incrementXP(200); // Adjust XP amount as needed

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Craving Log',
        style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: DropdownButtonFormField<String>(
                value: _selectedIntensity,
                decoration: InputDecoration(
                  labelText: 'Intensity',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                items: intensityLevels.map((level) {
                  return DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIntensity = value;
                  });
                },
              ),
            ),
            _buildTextField(_descriptionController, 'Description'),
            _buildTextField(_triggerController, 'Trigger'),
            _buildTextField(_copingMethodController, 'Coping Method'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitCravingLog,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.green[800], // Set the background color to green
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          //fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  Widget _buildTextNumField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          //fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}
