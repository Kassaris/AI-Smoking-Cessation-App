import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a batch instance for multiple writes
  WriteBatch createBatch() => _db.batch();

  Stream<UserModel?> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((snap) {
      if (snap.exists) {
        return UserModel.fromMap(snap.data()!, snap.id);
      }
      return null;
    });
  }

  // Mark multiple achievements as completed in a single batch
  Future<void> markAchievementsCompleted(
    String userId,
    List<String> achievementTitles,
    int xpToAdd,
  ) async {
    final userRef = _db.collection('users').doc(userId);
    final userDoc = await userRef.get();
    final currentXP = userDoc.data()?['userXP'] ?? 0;
    final newXP = currentXP + xpToAdd;
    final newRank = (newXP / 1000).floor() + 1; // Your rank calculation

    final batch = _db.batch();

    batch.update(userRef, {
      'userXP': newXP,
      'userRank': newRank,
      'completedAchievements': FieldValue.arrayUnion(achievementTitles),
    });

    // Add achievement completion records
    final timestamp = Timestamp.now();
    for (final title in achievementTitles) {
      final achievementRef = userRef.collection('achievements').doc(title);
      batch.set(achievementRef, {
        'title': title,
        'completedAt': timestamp,
        'xpAwarded': xpToAdd,
      });
    }

    await batch.commit();
  }

  Future<void> addUser(String userId, UserModel user) async {
    try {
      await _db.collection('users').doc(userId).set({
        'username': user.username,
        'email': user.email,
        'password': user.password,
        'gender': user.gender,
        'cigarettesPerDay': user.cigarettesPerDay,
        'cigarettesPerPack': user.cigarettesPerPack,
        'costPerPack': user.costPerPack,
        'smokingYears': user.smokingYears,
        'userRank': user.userRank,
        'userXP': user.userXP,
        'quitDate': user.quitDate,
        'questionnaireCompleted': user.questionnaireCompleted,
        'hasRated': user.hasRated,
        'completedAchievements': user.completedAchievements,
        'friendsList': user.friendsList,
        'socialTag': user.socialTag,
        'whySmoke': user.whySmoke,
        'feelWhenSmoking': user.feelWhenSmoking,
        'typeOfSmoker': user.typeOfSmoker,
        'whyQuit': user.whyQuit,
        'triedQuitMethods': user.triedQuitMethods,
        'emotionalMeaning': user.emotionalMeaning,
        'cravingSituations': user.cravingSituations,
        'confidenceLevel': user.confidenceLevel,
        'smokingEnvironment': user.smokingEnvironment,
        'biggestFear': user.biggestFear,
        'biggestMotivation': user.biggestMotivation // ✅ here

        //'calculatedRank': user.calculatedRank,
      });
      print('✅ User document created successfully');
    } catch (e, stack) {
      print('❌ Firestore error: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return UserModel.fromMap(doc.data(), doc.id); // pass ID here
      }
    } catch (e) {
      print('❌ Failed to fetch user by email: $e');
    }
    return null;
  }

  Future<void> updateUserDocument(String userId, Map<String, dynamic> data) {
    return _db.collection('users').doc(userId).update(data);
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e, stack) {
      print('❌ Error fetching user by ID: $e');
      print('Stack trace: $stack');
    }
    return null;
  }

  Future<List<String>> getCompletedAchievements(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return List<String>.from(doc.data()?['completedAchievements'] ?? []);
  }

  Future<void> markAchievementCompleted(
      String userId, String achievementTitle) async {
    await _db.collection('users').doc(userId).update({
      'completedAchievements': FieldValue.arrayUnion([achievementTitle]),
    });
  }

  Future<void> resetCompletedAchievements(String userId) async {
    final userDoc = _db.collection('users').doc(userId);

    await userDoc.update({'completedAchievements': []});
  }

  Future<String> assignUserToChatRoom(String userId, String username) async {
    final roomsRef = FirebaseFirestore.instance.collection('global_chat_rooms');

    // Check if user is already assigned to a room
    final roomsSnapshot = await roomsRef.get();

    for (final roomDoc in roomsSnapshot.docs) {
      final membersRef = roomDoc.reference.collection('members');
      final memberDoc = await membersRef.doc(userId).get();

      if (memberDoc.exists) {
        // Already assigned
        return roomDoc.id;
      }
    }

    // Find a room with < 20 members
    for (final roomDoc in roomsSnapshot.docs) {
      final membersRef = roomDoc.reference.collection('members');
      final membersSnapshot = await membersRef.get();

      if (membersSnapshot.size < 2) {
        await membersRef.doc(userId).set({
          'username': username,
          'joinedAt': FieldValue.serverTimestamp(),
        });
        return roomDoc.id;
      }
    }

    // If no suitable room, create a new one
    final newRoomId = 'room_${roomsSnapshot.docs.length + 1}';
    final newRoomRef = roomsRef.doc(newRoomId);

    await newRoomRef.set({'createdAt': FieldValue.serverTimestamp()});
    await newRoomRef.collection('members').doc(userId).set({
      'username': username,
      'joinedAt': FieldValue.serverTimestamp(),
    });

    return newRoomId;
  }

  Future<void> sendGlobalChatMessage(
      String userId, String username, String message) async {
    final roomId = await assignUserToChatRoom(userId, username);

    final messageData = {
      'senderId': userId,
      'senderName': username,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('global_chat_rooms')
        .doc(roomId)
        .collection('messages')
        .add(messageData);
  }

  Stream<QuerySnapshot> getGlobalChatMessagesStream(
      String userId, String username) async* {
    final roomId = await assignUserToChatRoom(userId, username);

    yield* FirebaseFirestore.instance
        .collection('global_chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<List<UserModel>> getAllUsers() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return querySnapshot.docs.map((doc) {
      return UserModel.fromMap(doc.data(), doc.id); // include document ID
    }).toList();
  }

  Future<void> updateUserTag(String uid, String tag) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'socialTag': tag,
      });
    } catch (e) {
      print('Error updating tag: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getChatMessagesStream(String roomId) {
    return FirebaseFirestore.instance
        .collection('global_chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendChatMessageToRoom(
      String roomId, String senderId, String senderName, String message) async {
    await FirebaseFirestore.instance
        .collection('global_chat_rooms')
        .doc(roomId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
