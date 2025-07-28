import 'dart:async';
import 'package:camp_harmony_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

class ServerpodUserEndpoint extends Endpoint {
  Future<ServerpodUser?> getUser(Session session, String uid) async {
    final ServerpodUser? user = await ServerpodUser.db
        .findFirstRow(session, where: (u) => u.firebaseUID.equals(uid));
    return user;
  }

  Future<ServerpodUser?> addUser(Session session, ServerpodUser user) async {
    final existingUser = await getUser(session, user.firebaseUID);
    if (existingUser != null) {
      return null;
    }

    final ServerpodUser newUser = ServerpodUser(
      firebaseUID: user.firebaseUID,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      registrationDate: DateTime.now(),
      isCheckedIn: false,
      role: UserType.user,
    );

    final ServerpodUser newUserWithId =
        await ServerpodUser.db.insertRow(session, newUser);

    return newUserWithId;
  }

  Future<ServerpodUser?> updateUser(Session session, ServerpodUser user) async {
    try {
      return await ServerpodUser.db.updateRow(session, user);
    } catch (e) {
      return null;
    }
  }

  Future<ServerpodUser?> updatePhoneNumber(
      Session session, String uid, String phoneNumber) async {
    final user = await getUser(session, uid);
    if (user == null) {
      return null;
    }

    user.phoneNumber = phoneNumber;
    return await updateUser(session, user);
  }

  Future<ServerpodUser?> updateProfile(Session session, String uid,
      String firstName, String lastName, String phoneNumber) async {
    final user = await getUser(session, uid);
    if (user == null) {
      return null;
    }

    user.firstName = firstName;
    user.lastName = lastName;
    user.phoneNumber = phoneNumber;
    return await updateUser(session, user);
  }
}
