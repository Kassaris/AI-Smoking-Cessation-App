import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoking_app/providers/user_provider.dart';
import 'package:smoking_app/screens/chatbot_screen.dart';

class NumberScrollButtons extends StatefulWidget {
  const NumberScrollButtons({super.key});

  @override
  _NumberScrollButtonsState createState() => _NumberScrollButtonsState();
}

class _NumberScrollButtonsState extends State<NumberScrollButtons> {
  int smokeFreeDays = 0;

  // Days that should always be red
  final List<int> criticalDays = [1, 3, 7, 10, 14, 20, 21, 28, 30];

  final Map<int, Map<String, String>> messages = {
    1: {
      'title': 'First Step!',
      'message': 'Day 1: You made the decision to quit — that’s powerful!'
    },
    2: {
      'title': 'Keep Going!',
      'message':
          'Day 2: Nicotine levels are dropping. You may feel withdrawal — hang in there!'
    },
    3: {
      'title': 'Critical Day',
      'message': 'Day 3: Peak withdrawal symptoms — stay focused and hydrated.'
    },
    4: {
      'title': 'Momentum Building',
      'message': 'Day 4: Physical withdrawal is easing. You’re doing great!'
    },
    5: {
      'title': 'Stay Strong',
      'message': 'Day 5: Cravings may still come. Deep breathing helps!'
    },
    6: {
      'title': 'Healing Begins',
      'message': 'Day 6: Your lungs are starting to heal — great job!'
    },
    7: {
      'title': 'One Week!',
      'message': 'Day 7: One full week smoke-free — celebrate your progress!'
    },
    8: {
      'title': 'Clean Start',
      'message':
          'Day 8: Oxygen levels have returned to normal. Keep moving forward!'
    },
    9: {
      'title': 'Clear Mind',
      'message': 'Day 9: Focus and memory are improving. Keep going!'
    },
    10: {
      'title': 'Double Digits!',
      'message':
          'Day 10: You’ve made it to double digits — impressive commitment!'
    },
    11: {
      'title': 'Stronger Than Before',
      'message': 'Day 11: Your risk of heart disease is already lowering.'
    },
    12: {
      'title': 'Reset',
      'message': 'Day 12: Blood circulation continues to improve — keep it up!'
    },
    13: {
      'title': 'Close to 2 Weeks!',
      'message': 'Day 13: Almost at two weeks. Stay mindful of cravings.'
    },
    14: {
      'title': 'Two Weeks In!',
      'message': 'Day 14: Lung function is improving. You’ve come a long way.'
    },
    15: {
      'title': 'Beyond the Hardest Part',
      'message':
          'Day 15: Physical addiction is fading — keep your mindset strong.'
    },
    16: {
      'title': 'Building Routine',
      'message': 'Day 16: You’re establishing a smoke-free routine.'
    },
    17: {
      'title': 'Health Gains',
      'message': 'Day 17: Your blood vessels are healing.'
    },
    18: {
      'title': 'Almost Three Weeks',
      'message': 'Day 18: Emotional triggers may pop up — stay prepared.'
    },
    19: {
      'title': 'Staying Steady',
      'message': 'Day 19: Cravings may feel easier to manage now.'
    },
    20: {
      'title': 'Critical Day Again',
      'message': 'Day 20: You’ve avoided hundreds of cigarettes. Be proud!'
    },
    21: {
      'title': 'Three Weeks!',
      'message':
          'Day 21: Habits take ~21 days to build — you’re rewriting yours!'
    },
    22: {
      'title': 'Healthier You',
      'message': 'Day 22: Coughing and shortness of breath should be less.'
    },
    23: {
      'title': 'Solid Progress',
      'message':
          'Day 23: You’re getting stronger each day — mentally and physically.'
    },
    24: {
      'title': 'Clarity Returns',
      'message':
          'Day 24: Your senses of taste and smell are likely sharper now.'
    },
    25: {
      'title': 'Milestone Approaching',
      'message': 'Day 25: You’re so close to the one-month mark!'
    },
    26: {
      'title': 'Strong Foundations',
      'message': 'Day 26: You’ve saved money and gained health.'
    },
    27: {
      'title': 'No Looking Back',
      'message': 'Day 27: Visualize how far you’ve come and why you started.'
    },
    28: {
      'title': 'One Month Incoming',
      'message': 'Day 28: You’ve built real momentum now!'
    },
    29: {
      'title': 'Nearly a Month',
      'message': 'Day 29: Take time to reward yourself for this journey.'
    },
    30: {
      'title': 'Major Milestone!',
      'message': 'Day 30: One month smoke-free — a tremendous achievement!'
    },
    31: {
      'title': 'Fresh Chapter',
      'message': 'Day 31: Welcome to your new smoke-free life.'
    }, /*
    60: {
      'title': '2 Months Smoke-Free',
      'message':
          'Your lung function has continued to improve. Breathing feels easier, and your risk of heart disease is lowering.'
    },
    90: {
      'title': '3 Months Milestone',
      'message':
          'Your circulation has significantly improved, and exercise feels easier. You’re building a strong smoke-free routine.'
    },
    180: {
      'title': 'Half-Year Victory',
      'message':
          'Six months without smoking! Coughing and shortness of breath have greatly decreased. Major health gains underway.'
    },
    365: {
      'title': '1 Year Smoke-Free',
      'message':
          'Your risk of coronary heart disease is half that of a smoker. You’ve reached a huge milestone – celebrate this success!'
    },
    730: {
      'title': '2 Years Free',
      'message':
          'Your risk of stroke is now greatly reduced, and relapse rates drop significantly. You’ve reclaimed your health!'
    },*/
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final smokeFreeDays = Provider.of<UserProvider>(context).smokeFreeDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
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
        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                MainAxisAlignment.center, // Center inside the Row
            children: [
              Icon(
                Icons.gps_fixed,
                color: Colors.green[800],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Daily Goals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 31,
              itemBuilder: (context, index) {
                final number = index + 1;
                final isLocked = number <= smokeFreeDays;
                final isCritical = criticalDays.contains(number);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: !isLocked
                        ? () {
                            final dayData = messages[number];
                            final title = dayData?['title'] ?? 'Day $number';
                            final message =
                                dayData?['message'] ?? 'You tapped day $number';

                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(title),
                                content: Text(message),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatbotScreen(
                                            initialMessage:
                                                "Tell me more about day $number in my smoke free journey, and analyse the importance of $message.",
                                            systemMessage:
                                                "You are a compassionate smoking cessation expert providing helpful daily guidance for people who are trying to quit smoking. Keep responses encouraging, scientific, and brief unless asked to elaborate. Give detailed info about $number in users smoke free journey. Elaborate in $message",
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text("Learn More"),
                                  )
                                ],
                              ),
                            );
                          }
                        : null,
                    child: Container(
                      decoration: isLocked
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.green.shade800,
                                width: 2,
                              ),
                            )
                          : null,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: isLocked
                            ? Colors.white
                            : isCritical
                                ? Colors.red
                                : Colors.green[800],
                        child: isLocked
                            ? Icon(
                                Icons.check,
                                color: Colors.green[800],
                              )
                            : Text(
                                '$number',
                                style: const TextStyle(color: Colors.white),
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
