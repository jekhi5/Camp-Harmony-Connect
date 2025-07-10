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
import 'dart:async' as _i2;
import 'package:camp_harmony_client/src/protocol/check_in_response.dart' as _i3;
import 'protocol.dart' as _i4;

/// {@category Endpoint}
class EndpointCheckIn extends _i1.EndpointRef {
  EndpointCheckIn(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'checkIn';

  /// Check in a user to the camp.
  _i2.Future<_i3.CheckInStatus> checkIn(int userId) =>
      caller.callServerEndpoint<_i3.CheckInStatus>(
        'checkIn',
        'checkIn',
        {'userId': userId},
      );

  /// Check out a user from the camp.
  _i2.Future<void> checkOut(String userId) => caller.callServerEndpoint<void>(
        'checkIn',
        'checkOut',
        {'userId': userId},
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          _i4.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    checkIn = EndpointCheckIn(this);
  }

  late final EndpointCheckIn checkIn;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {'checkIn': checkIn};

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
