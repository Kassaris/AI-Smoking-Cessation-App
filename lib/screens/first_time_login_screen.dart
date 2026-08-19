import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoking_app/providers/user_provider.dart';
import 'package:smoking_app/screens/home_screen.dart';

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirstTimeLoginScreen extends StatefulWidget {
  const FirstTimeLoginScreen({Key? key}) : super(key: key);

  @override
  State<FirstTimeLoginScreen> createState() => _FirstTimeLoginScreenState();
}

class _FirstTimeLoginScreenState extends State<FirstTimeLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cigarettesPerDayController =
      TextEditingController();
  final TextEditingController _cigarettesPerPackController =
      TextEditingController();
  final TextEditingController _costPerPackController = TextEditingController();
  String? _gender;
  final TextEditingController _smokingYearsController = TextEditingController();
  int smokingyears = 1; // For the counter UI

  bool _isSubmitting = false;

  final TextEditingController _quitDateController = TextEditingController();
  DateTime? _selectedQuitDateTime;

  final _whySmokeController = TextEditingController();
  final _feelWhenSmokingController = TextEditingController();
  final _typeOfSmokerController = TextEditingController();
  final _whyQuitController = TextEditingController();
  final _triedQuitMethodsController = TextEditingController();
  final _emotionalMeaningController = TextEditingController();
  final _cravingSituationsController = TextEditingController();
  final _confidenceLevelController = TextEditingController();
  final _smokingEnvironmentController = TextEditingController();
  final _biggestFearController = TextEditingController();
  final _biggestMotivationController = TextEditingController();

// Add this method to handle date picking
  Future<void> _selectQuitDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedQuitDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedQuitDateTime != null
            ? TimeOfDay.fromDateTime(_selectedQuitDateTime!)
            : TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _selectedQuitDateTime = finalDateTime;
          _quitDateController.text =
              DateFormat('MMM dd, yyyy - hh:mm a').format(finalDateTime);
        });
      }
    }
  }

  bool get _isFormValid {
    return _cigarettesPerDayController.text.isNotEmpty &&
        _cigarettesPerPackController.text.isNotEmpty &&
        _costPerPackController.text.isNotEmpty &&
        _gender != null &&
        _smokingYearsController.text.isNotEmpty &&
        _selectedQuitDateTime != null; // Add this check
  }

  void _submit() async {
    if (!_isFormValid || !_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Prepare data
      final data = {
        'cigarettesPerDay': int.parse(_cigarettesPerDayController.text.trim()),
        'cigarettesPerPack':
            int.parse(_cigarettesPerPackController.text.trim()),
        'costPerPack': double.parse(_costPerPackController.text.trim()),
        'quitDate': Timestamp.fromDate(_selectedQuitDateTime!),
        'gender': _gender!,
        'smokingYears': int.parse(_smokingYearsController.text.trim()),
        'questionnaireCompleted': true,
        'userXP': 0,
        'userRank': 0,
        'whySmoke': _whySmokeController.text.trim(),
        'feelWhenSmoking': _feelWhenSmokingController.text.trim(),
        'typeOfSmoker': _typeOfSmokerController.text.trim(),
        'whyQuit': _whyQuitController.text.trim(),
        'triedQuitMethods': _triedQuitMethodsController.text.trim(),
        'emotionalMeaning': _emotionalMeaningController.text.trim(),
        'cravingSituations': _cravingSituationsController.text.trim(),
        'confidenceLevel': _confidenceLevelController.text.trim(),
        'smokingEnvironment': _smokingEnvironmentController.text.trim(),
        'biggestFear': _biggestFearController.text.trim(),
        'biggestMotivation': _biggestMotivationController.text.trim(),
      };

      // Save to Firestore through UserProvider
      await userProvider.updateUserData(data);

      // Navigate to home screen on success
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text('First Time Setup',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/god4.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 30, top: 30, right: 30, bottom: 30),
                        child: Container(
                          padding: const EdgeInsets.all(30),
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Let\'s get started!',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800])),
                                const SizedBox(height: 20),

                                // Cigarettes per day
                                TextFormField(
                                  controller: _cigarettesPerDayController,
                                  keyboardType: TextInputType.number,
                                  cursorColor: Colors.green.shade700,
                                  decoration: InputDecoration(
                                    labelText: 'Cigarettes per day',
                                    labelStyle:
                                        TextStyle(color: Colors.black54),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                          color: Colors.green.shade800),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Required';
                                    if (int.tryParse(value) == null)
                                      return 'Enter a valid number';
                                    return null;
                                  },
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 20),

                                // Cigarettes per pack
                                TextFormField(
                                  controller: _cigarettesPerPackController,
                                  keyboardType: TextInputType.number,
                                  cursorColor: Colors.green.shade700,
                                  decoration: InputDecoration(
                                    labelText: 'Cigarettes per pack',
                                    labelStyle:
                                        TextStyle(color: Colors.black54),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                          color: Colors.green.shade800),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Required';
                                    if (int.tryParse(value) == null)
                                      return 'Enter a valid number';
                                    return null;
                                  },
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 20),

                                // Cost per pack
                                TextFormField(
                                  controller: _costPerPackController,
                                  keyboardType: TextInputType.number,
                                  cursorColor: Colors.green.shade700,
                                  decoration: InputDecoration(
                                    labelText: 'Cost per pack (€)',
                                    labelStyle:
                                        TextStyle(color: Colors.black54),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                          color: Colors.green.shade800),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Enter a valid cost';
                                    }
                                    return null;
                                  },
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 20),

                                // Quit Date-Time Picker
                                TextFormField(
                                  controller: _quitDateController,
                                  readOnly: true,
                                  onTap: () => _selectQuitDateTime(context),
                                  decoration: InputDecoration(
                                    labelText: 'Quit Date & Time',
                                    labelStyle:
                                        TextStyle(color: Colors.black54),
                                    suffixIcon: Icon(Icons.calendar_today,
                                        color: Colors.green[800]),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                          color: Colors.green.shade800),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (_selectedQuitDateTime == null) {
                                      return 'Please select quit date and time';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                DropdownButtonFormField<String>(
                                  // hint:
                                  value: _gender,
                                  items: ['Male', 'Female', 'Other']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _gender = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Select your gender',
                                    labelStyle:
                                        TextStyle(color: Colors.black54),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 1),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                          color: Colors.green.shade800),
                                    ),
                                  ),
                                  validator: (value) => value == null
                                      ? 'Please select gender'
                                      : null,
                                ),
                                const SizedBox(height: 10),

                                // Years of smoking counter
                                Text('Years of Smoking',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87)),
                                const SizedBox(height: 5),
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            if (smokingyears > 1) {
                                              smokingyears--;
                                            }
                                            _smokingYearsController.text =
                                                smokingyears.toString();
                                          });
                                        },
                                      ),
                                      Text('$smokingyears years',
                                          style: const TextStyle(fontSize: 16)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle,
                                            color: Colors.green),
                                        onPressed: () {
                                          setState(() {
                                            smokingyears++;
                                            _smokingYearsController.text =
                                                smokingyears.toString();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),
                                _buildTextField(
                                    "Why do you smoke?", _whySmokeController),
                                _buildTextField(
                                    "What do you feel when smoking?",
                                    _feelWhenSmokingController),
                                _buildTextField("What type of smoker are you?",
                                    _typeOfSmokerController),
                                _buildTextField("Why do you want to quit?",
                                    _whyQuitController),
                                _buildTextField(
                                    "Have you tried quitting before? Methods?",
                                    _triedQuitMethodsController),
                                _buildTextField(
                                    "What do cigarettes mean to you emotionally?",
                                    _emotionalMeaningController),
                                _buildTextField(
                                    "In what situations do you crave cigarettes?",
                                    _cravingSituationsController),
                                _buildTextField(
                                    "How confident are you in quitting? (0-10)",
                                    _confidenceLevelController,
                                    keyboardType: TextInputType.number),
                                _buildTextField(
                                    "Do you live/work with other smokers?",
                                    _smokingEnvironmentController),
                                _buildTextField(
                                    "Your biggest fear about quitting?",
                                    _biggestFearController),
                                _buildTextField(
                                    "Your biggest motivation to stay smoke-free?",
                                    _biggestMotivationController),

                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isFormValid && !_isSubmitting
                                        ? _submit
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[800],
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                    ),
                                    child: _isSubmitting
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : const Text('Save and Continue',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildTextField(String label, TextEditingController controller,
    {TextInputType keyboardType = TextInputType.text}) {
  return Column(
    children: [
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.green.shade800),
          ),
        ),
        keyboardType: keyboardType,
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
      const SizedBox(height: 15),
    ],
  );
}
