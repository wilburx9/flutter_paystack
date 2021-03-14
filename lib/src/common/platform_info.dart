import 'dart:io';

import 'package:flutter/services.dart';

/// Holds data that's different on Android and iOS
class PlatformInfo {
  final String userAgent;
  final String paystackBuild;
  final String deviceId;

  static Future<PlatformInfo> fromMethodChannel(MethodChannel channel) async {
    // TODO: Update for every new versions.
    //  And there should a better way to fucking do this
    final pluginVersion = "1.0.5";

    final platform = Platform.operatingSystem;
    String userAgent = "${platform}_Paystack_$pluginVersion";
    String deviceId = await channel.invokeMethod('getDeviceId') ?? "";
    return PlatformInfo._(
      userAgent: userAgent,
      paystackBuild: pluginVersion,
      deviceId: deviceId,
    );
  }

  const PlatformInfo._({
    required String userAgent,
    required String paystackBuild,
    required String deviceId,
  })   : userAgent = userAgent,
        paystackBuild = paystackBuild,
        deviceId = deviceId;

  @override
  String toString() {
    return '[userAgent = $userAgent, paystackBuild = $paystackBuild, deviceId = $deviceId]';
  }
}
