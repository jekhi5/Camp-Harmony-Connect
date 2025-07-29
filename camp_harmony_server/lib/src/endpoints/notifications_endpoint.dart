import 'dart:async';
import 'package:camp_harmony_server/src/generated/protocol.dart';
import 'package:firebase_verify_token_dart/firebase_verify_token_dart.dart';
import 'package:serverpod/serverpod.dart';
import '../services/fcm_service.dart';

// Send notifications
class NotificationsEndpoint extends Endpoint {
  final _fcm = FcmService();
  final UserType requiredRolePermissions = UserType.admin;

  Future<String> sendNotification(
    Session session,
    String authToken,
    String title,
    String message,
    bool onlyToCheckedInUsers,
  ) async {
    try {
      FirebaseVerifyToken.projectIds = ['camp-harmony'];
      final isValid = await FirebaseVerifyToken.verify(authToken);
      if (!isValid) {
        return "User token is invalid. Try logging out and then logging back in";
      }
    } catch (e) {
      return "User ID token validation failed: ${e.toString()}";
    }

    final sendingfbUID = FirebaseVerifyToken.getUserID(authToken);

    final sendingUser = await ServerpodUser.db.findFirstRow(session,
        where: (u) => u.firebaseUID.equals(sendingfbUID));

    if (sendingUser == null ||
        sendingUser.role.toJson() < requiredRolePermissions.toJson()) {
      return "User does not have required permissions to send notifications";
    }

    List<FCMToken> tokensToSendTo;
    if (onlyToCheckedInUsers) {
      final checkedInUsers = await ServerpodUser.db
          .find(session, where: (u) => u.isCheckedIn.equals(true));

      final Set<int?> checkedInIds = checkedInUsers.map((u) => u.id).toSet();
      final Set<int> nonNullIds = {};

      for (var id in checkedInIds) {
        if (id != null) {
          nonNullIds.add(id);
        }
      }

      tokensToSendTo = await FCMToken.db
          .find(session, where: (t) => t.userId.inSet(nonNullIds));
    } else {
      return "Sending to all users is not yet supported";
    }

    bool someSentSuccessfully = false;
    bool someFailed = false;

    for (var t in tokensToSendTo) {
      if (await _fcm.sendNotification(
              token: t.token, title: title, body: message) ==
          false) {
        print("Failed token: ${t.token}");
        someFailed = true;
      } else {
        someSentSuccessfully = true;
      }
    }

    if (someSentSuccessfully && !someFailed) {
      return "All notifications sent successfully";
    } else if (someSentSuccessfully && someFailed) {
      return "Some notifications sent successfully, others failed";
    } else if (!someSentSuccessfully && !someFailed) {
      return "No notifications sent. Perhaps nobody is checked in";
    } else {
      return "All notifications failed to send";
    }
  }

  Future<bool> deregisterToken(
      Session session, String token, int? userId) async {
    await FCMToken.db.deleteWhere(
      session,
      where: (t) => t.token.equals(token) & t.userId.equals(userId),
    );
    return true;
  }

  Future<bool> registerToken(Session session, String token, int userId) async {
    // The token object to be inserted
    final FCMToken newTokenObj =
        FCMToken(token: token, userId: userId, lastUpdate: DateTime.now());

    // Delete any instances in which other users are associated with this token
    // The logic is that a device only has a single token, and only one user can
    // be logged in at a time, so there should only ever be one instance of a
    // token at a given time
    await FCMToken.db.deleteWhere(session,
        where: (t) => t.token.equals(token) & t.userId.notEquals(userId));

    var existingToken = await FCMToken.db.findFirstRow(session,
        where: (t) => t.token.equals(token) & t.userId.equals(userId));

    if (existingToken == null) {
      await FCMToken.db.insertRow(session, newTokenObj);
    }

    return true;
  }
}
