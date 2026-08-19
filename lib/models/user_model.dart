import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String password;
  final String gender;
  final int cigarettesPerDay;
  final int cigarettesPerPack;
  final double costPerPack;
  final int smokingYears;
  final int userRank;
  final int userXP;
  final Timestamp quitDate;
  final bool questionnaireCompleted;
  final bool hasRated;
  final List<String> completedAchievements;
  final List<String> friendsList;
  final String socialTag;
  final String whySmoke;
  final String feelWhenSmoking;
  final String typeOfSmoker;
  final String whyQuit;
  final String triedQuitMethods;
  final String emotionalMeaning;
  final String cravingSituations;
  final String confidenceLevel;
  final String smokingEnvironment;
  final String biggestFear;
  final String biggestMotivation;

  UserModel(
      {required this.id,
      required this.username,
      required this.email,
      required this.password,
      required this.gender,
      required this.cigarettesPerDay,
      required this.cigarettesPerPack,
      required this.costPerPack,
      required this.smokingYears,
      required this.userRank,
      required this.userXP,
      required this.quitDate,
      this.questionnaireCompleted = false,
      this.hasRated = false,
      required this.completedAchievements,
      required this.friendsList,
      required this.socialTag,
      required this.whySmoke,
      required this.feelWhenSmoking,
      required this.typeOfSmoker,
      required this.whyQuit,
      required this.triedQuitMethods,
      required this.emotionalMeaning,
      required this.cravingSituations,
      required this.confidenceLevel,
      required this.smokingEnvironment,
      required this.biggestFear,
      required this.biggestMotivation});

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
        id: id,
        username: map['username'] ?? '',
        email: map['email'] ?? '',
        password: map['password'] ?? '',
        gender: map['gender'] ?? '',
        cigarettesPerDay: map['cigarettesPerDay'] ?? 0,
        cigarettesPerPack: map['cigarettesPerPack'] ?? 0,
        costPerPack: (map['costPerPack'] ?? 0).toDouble(),
        smokingYears: map['smokingYears'] ?? 0,
        userRank: map['userRank'] ?? 1,
        userXP: map['userXP'] ?? 0,
        quitDate: map['quitDate'] ?? Timestamp.now(),
        questionnaireCompleted: map['questionnaireCompleted'] ?? false,
        hasRated: map['hasRated'] ?? false,
        completedAchievements: map['completedAchievements'] != null
            ? List<String>.from(map['completedAchievements'])
            : <String>[],
        friendsList: map['friendsList'] != null
            ? List<String>.from(map['friendsList'])
            : <String>[],
        socialTag: map['socialTag'] ?? '0000',
        whySmoke: map['whySmoke'] ?? '',
        feelWhenSmoking: map['feelWhenSmoking'] ?? '',
        typeOfSmoker: map['typeOfSmoker'] ?? '',
        whyQuit: map['whyQuit'] ?? '',
        triedQuitMethods: map['triedQuitMethods'] ?? '',
        emotionalMeaning: map['emotionalMeaning'] ?? '',
        cravingSituations: map['cravingSituations'] ?? '',
        confidenceLevel: map['confidenceLevel'] ?? '',
        smokingEnvironment: map['smokingEnvironment'] ?? '',
        biggestFear: map['biggestFear'] ?? '',
        biggestMotivation: map['biggestMotivation'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'gender': gender,
      'cigarettesPerDay': cigarettesPerDay,
      'cigarettesPerPack': cigarettesPerPack,
      'costPerPack': costPerPack,
      'smokingYears': smokingYears,
      'userRank': userRank,
      'userXP': userXP,
      'quitDate': quitDate,
      'questionnaireCompleted': questionnaireCompleted,
      'hasRated': hasRated,
      'completedAchievements': completedAchievements,
      'friendsList': friendsList,
      'socialTag': socialTag,
      'whySmoke': whySmoke,
      'feelWhenSmoking': feelWhenSmoking,
      'typeOfSmoker': typeOfSmoker,
      'whyQuit': whyQuit,
      'triedQuitMethods': triedQuitMethods,
      'emotionalMeaning': emotionalMeaning,
      'cravingSituations': cravingSituations,
      'confidenceLevel': confidenceLevel,
      'smokingEnvironment': smokingEnvironment,
      'biggestFear ': biggestFear,
      'biggestMotivation': biggestMotivation
    };
  }

  UserModel copyWith(
      {String? username,
      String? email,
      String? password,
      String? gender,
      int? cigarettesPerDay,
      int? cigarettesPerPack,
      double? costPerPack,
      int? smokingDuration,
      int? userRank,
      int? userXP,
      Timestamp? quitDate,
      bool? questionnaireCompleted,
      bool? hasRated,
      int? smokingYears,
      List<String>? completedAchievements,
      List<String>? friendsList,
      String? socialTag,
      String? whySmoke,
      String? feelWhenSmoking,
      String? typeOfSmoker,
      String? whyQuit,
      String? triedQuitMethods,
      String? emotionalMeaning,
      String? cravingSituations,
      String? confidenceLevel,
      String? smokingEnvironment,
      String? biggestFear,
      String? biggestMotivation}) {
    return UserModel(
        id: id,
        username: username ?? this.username,
        email: email ?? this.email,
        password: password ?? this.password,
        gender: gender ?? this.gender,
        cigarettesPerDay: cigarettesPerDay ?? this.cigarettesPerDay,
        cigarettesPerPack: cigarettesPerPack ?? this.cigarettesPerPack,
        costPerPack: costPerPack ?? this.costPerPack,
        smokingYears: smokingDuration ?? smokingYears ?? this.smokingYears,
        userRank: userRank ?? this.userRank,
        userXP: userXP ?? this.userXP,
        quitDate: quitDate ?? this.quitDate,
        questionnaireCompleted:
            questionnaireCompleted ?? this.questionnaireCompleted,
        hasRated: hasRated ?? this.hasRated,
        completedAchievements:
            completedAchievements ?? this.completedAchievements,
        friendsList: friendsList ?? this.friendsList,
        socialTag: socialTag ?? this.socialTag,
        whySmoke: whySmoke ?? this.whySmoke,
        feelWhenSmoking: feelWhenSmoking ?? this.feelWhenSmoking,
        typeOfSmoker: typeOfSmoker ?? this.typeOfSmoker,
        whyQuit: whyQuit ?? this.whyQuit,
        triedQuitMethods: triedQuitMethods ?? this.triedQuitMethods,
        emotionalMeaning: emotionalMeaning ?? this.emotionalMeaning,
        cravingSituations: cravingSituations ?? this.cravingSituations,
        confidenceLevel: confidenceLevel ?? this.confidenceLevel,
        smokingEnvironment: smokingEnvironment ?? this.smokingEnvironment,
        biggestFear: biggestFear ?? this.biggestFear,
        biggestMotivation: biggestMotivation ?? this.biggestMotivation);
  }

  int get smokeFreeDays {
    final now = DateTime.now();
    final quitDateTime = quitDate.toDate();
    final difference = now.difference(quitDateTime).inDays;
    return difference >= 0 ? difference : 0;
  }

  Map<String, int> calculateFullTimeDifference(DateTime from, DateTime to) {
    if (from.isAfter(to)) {
      return {'years': 0, 'months': 0, 'days': 0};
    }

    int years = to.year - from.year;
    int months = to.month - from.month;
    int days = to.day - from.day;

    if (days < 0) {
      months--;
      final lastMonth = DateTime(to.year, to.month - 1, 1);
      days += lastMonth
          .difference(
              DateTime(lastMonth.year, lastMonth.month, lastMonth.day + 1))
          .inDays
          .abs();
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return {'years': years, 'months': months, 'days': days};
  }
}
