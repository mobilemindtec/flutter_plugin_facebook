import 'dart:async';

import 'package:flutter/services.dart';

class FacebookException implements Exception {
  final message;

  FacebookException([this.message]);

  String toString() {
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}

enum FbStatus {
  Error,
  Success,
  Cancel
}

class FbResult{
  FbStatus status;
  String message;
  Map data;

  FbResult({this.status, this.message, this.data});
}

class Facebook {

  static const platform = const MethodChannel('plugins.flutter.io/facebook');

  Future<FbResult> initSdk() async {
    try{
      final Map result = await platform.invokeMethod('initSdk');

      if(result["status"] == "success")
        return new FbResult({status: FbStatus.Success});

      return new FbResult({status: FbStatus.Error, message: result["message"]});

    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }

  Future<FbResult> logInWithReadPermissions({String permissions, String fields}) async {
    try{


      var params = {};

      if(permissions != null)
        params["permissions"] = permissions;

      if(fields != null)
        params["fields"] = permissions;

      final Map result = await platform.invokeMethod('logInWithReadPermissions', params);

      return new FbResult({status: FbStatus.Success, data: result});

    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }

  Future<FbResult> logInWithPublishPermissions({String permissions, String fields}) async {
    try{


      var params = {};

      if(permissions != null)
        params["permissions"] = permissions;

      if(fields != null)
        params["fields"] = permissions;

      final Map result = await platform.invokeMethod('logInWithPublishPermissions', params);

      return new FbResult({status: FbStatus.Success, data: result});

    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }

  Future logOut() async {
    try{
      await platform.invokeMethod('logOut');
    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }

  Future<bool> isLoggedIn() async {
    try{
      final bool loggedIn = await platform.invokeMethod('isLoggedIn');
      return loggedIn;
    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }

  Future<Map> getAccessToken() async {
    try{
      final Map result = await platform.invokeMethod('getAccessToken');
      return new FbResult({status: FbStatus.Success, data: result});
    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }
}