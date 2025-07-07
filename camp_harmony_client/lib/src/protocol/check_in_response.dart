/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class CheckInStatus implements _i1.SerializableModel {
  CheckInStatus._({
    required this.userId,
    required this.checkedIn,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLocation,
    this.checkOutLocation,
    this.statusMessage,
  });

  factory CheckInStatus({
    required int userId,
    required bool checkedIn,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? checkInLocation,
    String? checkOutLocation,
    String? statusMessage,
  }) = _CheckInStatusImpl;

  factory CheckInStatus.fromJson(Map<String, dynamic> jsonSerialization) {
    return CheckInStatus(
      userId: jsonSerialization['userId'] as int,
      checkedIn: jsonSerialization['checkedIn'] as bool,
      checkInTime: jsonSerialization['checkInTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['checkInTime']),
      checkOutTime: jsonSerialization['checkOutTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['checkOutTime']),
      checkInLocation: jsonSerialization['checkInLocation'] as String?,
      checkOutLocation: jsonSerialization['checkOutLocation'] as String?,
      statusMessage: jsonSerialization['statusMessage'] as String?,
    );
  }

  int userId;

  bool checkedIn;

  DateTime? checkInTime;

  DateTime? checkOutTime;

  String? checkInLocation;

  String? checkOutLocation;

  String? statusMessage;

  /// Returns a shallow copy of this [CheckInStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CheckInStatus copyWith({
    int? userId,
    bool? checkedIn,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? checkInLocation,
    String? checkOutLocation,
    String? statusMessage,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'checkedIn': checkedIn,
      if (checkInTime != null) 'checkInTime': checkInTime?.toJson(),
      if (checkOutTime != null) 'checkOutTime': checkOutTime?.toJson(),
      if (checkInLocation != null) 'checkInLocation': checkInLocation,
      if (checkOutLocation != null) 'checkOutLocation': checkOutLocation,
      if (statusMessage != null) 'statusMessage': statusMessage,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CheckInStatusImpl extends CheckInStatus {
  _CheckInStatusImpl({
    required int userId,
    required bool checkedIn,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? checkInLocation,
    String? checkOutLocation,
    String? statusMessage,
  }) : super._(
          userId: userId,
          checkedIn: checkedIn,
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
          checkInLocation: checkInLocation,
          checkOutLocation: checkOutLocation,
          statusMessage: statusMessage,
        );

  /// Returns a shallow copy of this [CheckInStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CheckInStatus copyWith({
    int? userId,
    bool? checkedIn,
    Object? checkInTime = _Undefined,
    Object? checkOutTime = _Undefined,
    Object? checkInLocation = _Undefined,
    Object? checkOutLocation = _Undefined,
    Object? statusMessage = _Undefined,
  }) {
    return CheckInStatus(
      userId: userId ?? this.userId,
      checkedIn: checkedIn ?? this.checkedIn,
      checkInTime: checkInTime is DateTime? ? checkInTime : this.checkInTime,
      checkOutTime:
          checkOutTime is DateTime? ? checkOutTime : this.checkOutTime,
      checkInLocation:
          checkInLocation is String? ? checkInLocation : this.checkInLocation,
      checkOutLocation: checkOutLocation is String?
          ? checkOutLocation
          : this.checkOutLocation,
      statusMessage:
          statusMessage is String? ? statusMessage : this.statusMessage,
    );
  }
}
