import 'dart:async';
import 'package:camp_harmony_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Manage user-related endpoints, such as fetching and updating user information.
class ServerpodUserEndpoint extends Endpoint {
  /// Fetch a user by their Firebase UID
  /// Returns the user if found, otherwise returns null.
  /// The [session] is implied, but the [uid] is required.
  Future<ServerpodUser?> getUser(Session session, String uid) async {
    final ServerpodUser? user = await ServerpodUser.db
        .findFirstRow(session, where: (u) => u.firebaseUID.equals(uid));
    return user;
  }

  /// Add a new user to the database.
  /// Returns the newly created user if successful, otherwise returns null.
  /// The [session] is implied, but the [user] object is required.
  /// The user will be created as a regular user with the role of 'user'.
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

  /// Update an existing user in the database.
  /// Returns the updated user if successful, otherwise returns null.
  /// The [session] is implied, but the [user] object with updated fields is required.
  Future<ServerpodUser?> updateUser(Session session, ServerpodUser user) async {
    try {
      return await ServerpodUser.db.updateRow(session, user);
    } catch (e) {
      return null;
    }
  }

  /// Update a user's phone number.
  /// Returns the updated user if successful, otherwise returns null.
  /// The [session] is implied, but the [uid] and [phoneNumber] are required.
  Future<ServerpodUser?> updatePhoneNumber(
      Session session, String uid, String phoneNumber) async {
    final user = await getUser(session, uid);
    if (user == null) {
      return null;
    }

    user.phoneNumber = phoneNumber;
    return await updateUser(session, user);
  }

  /// Update a user's profile information.
  /// Returns the updated user if successful, otherwise returns null.
  /// The [session] is implied, but the [uid], [firstName], [lastName], and [phoneNumber] are required.
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
