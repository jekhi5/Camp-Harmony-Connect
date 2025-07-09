import 'dart:async';
import 'package:camp_harmony_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

class ServerpodUserEndpoint extends Endpoint {
  Future<ServerpodUser?> getUser(Session session, String uid) async {
    final ServerpodUser? user = await ServerpodUser.db
        .findFirstRow(session, where: (u) => u.firebaseUID.equals(uid));
    return user;
  }

  Future<ServerpodUser> addUser(Session session, ServerpodUser user) async {
    final ServerpodUser newUser = ServerpodUser(
      firebaseUID: user.firebaseUID,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      registrationDate: DateTime.now(),
      isActive: true,
      roles: ['user'],
    );

    final ServerpodUser newUserWithId =
        await ServerpodUser.db.insertRow(session, newUser);

    return newUserWithId;
  }
}
