import 'dart:async';
import 'package:camp_harmony_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

// Manage checking in and out of being on camp grounds.
class CheckInEndpoint extends Endpoint {
  /// Check in a user to the camp.
  Future<bool> checkIn(Session session, String uid) async {
    // Implement check-in logic here
    ServerpodUser? user = await ServerpodUser.db
        .findFirstRow(session, where: (u) => u.firebaseUID.equals(uid));
    if (user == null) {
      print("User not found for check-in: $uid");
      return false;
    }
    user.isCheckedIn = true;
    try {
      await ServerpodUser.db.updateRow(session, user);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check out a user from the camp.
  Future<bool> checkOut(Session session, String uid) async {
    ServerpodUser? user = await ServerpodUser.db
        .findFirstRow(session, where: (u) => u.firebaseUID.equals(uid));
    if (user == null) {
      return false;
    }
    user.isCheckedIn = false;
    try {
      await ServerpodUser.db.updateRow(session, user);
      return true;
    } catch (e) {
      return false;
    }
  }
}
