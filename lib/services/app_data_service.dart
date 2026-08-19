class MockDataService {
  static List<Tip> cravingsTips = [
    Tip(
      title: "Stay Hydrated",
      description:
          "Drink plenty of water throughout the day whenever you feel a craving. Staying hydrated helps flush nicotine and toxins from your body, and drinking water can distract your mind from the urge to smoke.",
    ),
    Tip(
      title: "Take a Walk",
      description:
          "Go for a short walk outside or around your home when a craving hits. Physical activity releases endorphins, helps reduce stress, and distracts you from cigarette urges.",
    ),
    Tip(
      title: "Chew Gum",
      description:
          "Keep sugar-free gum handy and chew it when you want to smoke. Chewing helps satisfy oral fixation and keeps your mouth busy, reducing the intensity of cravings.",
    ),
    Tip(
      title: "Practice Deep Breathing",
      description:
          "Take slow, deep breaths in through your nose and out through your mouth to relax your body and mind. Deep breathing reduces stress and can help ease the discomfort of cravings.",
    ),
    Tip(
      title: "Exercise Regularly",
      description:
          "Engage in regular light exercise such as stretching, jogging, or yoga. Exercise helps release mood-enhancing endorphins and reduces withdrawal symptoms, making cravings easier to manage.",
    ),
    Tip(
      title: "Distract Yourself with Hobbies",
      description:
          "Keep your mind engaged with hobbies like reading, drawing, or puzzles when cravings arise. Staying busy with activities you enjoy helps shift focus away from smoking urges.",
    ),
    Tip(
      title: "Avoid Smoking Triggers",
      description:
          "Identify and avoid people, places, or routines that you associate with smoking, especially in early quit days. Avoiding these triggers reduces the chance of relapse.",
    ),
    Tip(
      title: "Use Nicotine Replacement Therapy",
      description:
          "Consider using nicotine patches, gum, or lozenges to help reduce withdrawal symptoms. These therapies provide controlled nicotine doses without harmful smoke.",
    ),
    Tip(
      title: "Snack on Healthy Foods",
      description:
          "Keep healthy snacks like fruits, nuts, or raw vegetables handy to munch on. Eating helps occupy your mouth and can reduce cravings, especially for oral fixations.",
    ),
    Tip(
      title: "Practice Mindfulness Meditation",
      description:
          "Observe your cravings as passing sensations without reacting to them. Mindfulness meditation helps you accept cravings without judgment, reducing their impact.",
    ),
    Tip(
      title: "Connect with Supportive People",
      description:
          "Reach out to friends, family, or support groups when cravings feel intense. Talking with someone who encourages you can strengthen your resolve and provide motivation.",
    ),
    Tip(
      title: "Set Manageable Daily Goals",
      description:
          "Break your quit plan into small daily goals and focus on achieving each day smoke-free. Celebrating daily wins builds confidence and momentum.",
    ),
    Tip(
      title: "Reward Yourself Regularly",
      description:
          "Give yourself small rewards for reaching milestones like a day, a week, or a month smoke-free. Rewards help reinforce positive behavior and keep motivation high.",
    ),
    Tip(
      title: "Use Positive Affirmations",
      description:
          "Repeat positive statements like ‘I am stronger than my cravings’ or ‘Every smoke-free day improves my health.’ Affirmations boost your mental strength and confidence.",
    ),
    Tip(
      title: "Drink Herbal Teas",
      description:
          "Sip calming herbal teas such as chamomile, peppermint, or green tea to soothe nerves and reduce stress associated with quitting.",
    ),
    Tip(
      title: "Chew Sugar-Free Mints",
      description:
          "Use sugar-free mints to keep your mouth busy and freshen your breath. This can help reduce cravings triggered by oral fixation or the taste of cigarettes.",
    ),
    Tip(
      title: "Practice Yoga or Stretching",
      description:
          "Engage in yoga or gentle stretching to reduce tension, improve breathing, and calm the nervous system. Physical relaxation techniques can help combat cravings.",
    ),
    Tip(
      title: "Keep a Quitting Journal",
      description:
          "Write about your quitting experience, how you feel each day, and strategies that work for you. Journaling helps process emotions and track progress.",
    ),
    Tip(
      title: "Avoid Alcohol and Other Triggers",
      description:
          "Limit alcohol consumption and avoid situations where you are more likely to smoke. Alcohol often lowers inhibitions and can lead to relapse.",
    ),
    Tip(
      title: "Get Plenty of Rest",
      description:
          "Ensure you get enough sleep to help your body heal and your mind stay strong. Fatigue can increase stress and cravings.",
    ),
    Tip(
      title: "Use Visualization Techniques",
      description:
          "Imagine yourself healthy, happy, and smoke-free. Visualization reinforces your goals and motivates you to resist cravings.",
    ),
    Tip(
      title: "Keep Your Hands Busy",
      description:
          "Use stress balls, fidget spinners, knitting, or other activities to keep your hands occupied and distract from the urge to smoke.",
    ),
    Tip(
      title: "Practice Gratitude Daily",
      description:
          "Focus on the positive benefits of quitting, such as improved health and saved money. Gratitude helps improve mood and motivation.",
    ),
    Tip(
      title: "Plan for Difficult Moments",
      description:
          "Identify challenging situations in advance and plan coping strategies. Preparation helps you respond calmly when cravings arise.",
    ),
    Tip(
      title: "Manage Stress Effectively",
      description:
          "Use stress management techniques such as meditation, listening to music, or talking to friends. Reducing stress lowers cravings and relapse risk.",
    ),
    Tip(
      title: "Stay Accountable",
      description:
          "Share your quitting goals with a friend, family member, or support group. Accountability encourages commitment and offers encouragement.",
    ),
    Tip(
      title: "Use Quit-Smoking Apps",
      description:
          "Leverage smartphone apps that track progress, provide motivational messages, and offer quitting tools to stay engaged and supported.",
    ),
    Tip(
      title: "Stay Hydrated",
      description:
          "Drinking water helps flush toxins from your body and reduces feelings of hunger or cravings for cigarettes.",
    ),
    Tip(
      title: "Practice Slow, Deep Breathing",
      description:
          "When you feel a craving, take slow deep breaths to calm your nervous system and refocus your mind away from urges.",
    ),
    Tip(
      title: "Reach Out to Support Networks",
      description:
          "Connect regularly with people who support your quit attempt, such as friends, family, counselors, or online groups.",
    ),
  ];

  static DateTime quitDate = DateTime.now().subtract(Duration(days: 1));

  static List<HealthGoal> healthGoals = [
    HealthGoal(
      description: "Heart rate normalizes after 20 minutes",
      targetDuration: Duration(minutes: 20),
    ),
    HealthGoal(
      description: "Carbon monoxide eliminated after 12 hours",
      targetDuration: Duration(hours: 12),
    ),
    HealthGoal(
      description:
          "After 24 hours of quitting, your heart rate returns to normal.",
      targetDuration: Duration(days: 1),
    ),
    HealthGoal(
      description:
          "Nerve endings start regrowing; senses improve after 48 hours",
      targetDuration: Duration(days: 2),
    ),
    HealthGoal(
      description: "Bronchial tubes relax, breathing easier after 72 hours",
      targetDuration: Duration(days: 3),
    ),
    HealthGoal(
      description: "Circulation improves after 1 week",
      targetDuration: Duration(days: 7),
    ),
    HealthGoal(
      description: "Lung function improves after 2 weeks",
      targetDuration: Duration(days: 14),
    ),
    HealthGoal(
      description:
          "Cilia in lungs regenerate, improving mucus clearance after 1 month",
      targetDuration: Duration(days: 30),
    ),
    HealthGoal(
      description: "After 3 months, lung function improves by 30%",
      targetDuration: Duration(days: 90),
    ),
    HealthGoal(
      description:
          "Blood circulation continues to improve; energy levels increase after 3 months",
      targetDuration: Duration(days: 90),
    ),
    HealthGoal(
      description:
          "Psychological benefits: improved mood and less anxiety over months",
      targetDuration: Duration(days: 90), // initial mental health improvements
    ),
    HealthGoal(
      description: "Lung function can be up to 30-50% better after 6 months",
      targetDuration: Duration(days: 180),
    ),
    HealthGoal(
      description:
          "Lung cilia function normalizes after 9 months, reducing infection risk",
      targetDuration: Duration(days: 270),
    ),
    HealthGoal(
      description: "Risk of coronary heart disease reduced by 50% after 1 year",
      targetDuration: Duration(days: 365),
    ),
    HealthGoal(
      description: "Improved immune system and reduced infections over time",
      targetDuration:
          Duration(days: 365), // Approximate early benefits within a year
    ),
    HealthGoal(
      description:
          "Better skin health and reduced premature aging after 1 year",
      targetDuration: Duration(days: 365),
    ),
    HealthGoal(
      description:
          "Improved fertility and reproductive health over months to years",
      targetDuration: Duration(days: 365), // generalized timeline
    ),
    HealthGoal(
      description: "Reduced risk of type 2 diabetes after quitting smoking",
      targetDuration: Duration(days: 365), // gradual improvement over months
    ),
    HealthGoal(
      description:
          "Improved dental health and gum disease risk reduction after 1 year",
      targetDuration: Duration(days: 365),
    ),
    HealthGoal(
      description:
          "Stroke risk decreases to that of a non-smoker after 5 years",
      targetDuration: Duration(days: 1825),
    ),
    HealthGoal(
      description:
          "Risk of cancers (mouth, throat, esophagus, bladder) drops by half after 5 years",
      targetDuration: Duration(days: 1825),
    ),
    HealthGoal(
      description: "Lung cancer mortality risk reduces by 50% after 10 years",
      targetDuration: Duration(days: 3650),
    ),
    HealthGoal(
      description: "Risk of other cancers continues to decline after 10 years",
      targetDuration: Duration(days: 3650),
    ),
    HealthGoal(
      description:
          "Risk of coronary heart disease equals that of a non-smoker after 15 years",
      targetDuration: Duration(days: 5475),
    ),
  ];
}

class HealthGoal {
  final String description;
  final Duration targetDuration;

  HealthGoal({required this.description, required this.targetDuration});
}

class Tip {
  final String title;
  final String description;
  int rating;

  Tip({required this.title, required this.description, this.rating = 0});
}
