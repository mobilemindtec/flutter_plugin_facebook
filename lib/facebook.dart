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
        return new FbResult(status: FbStatus.Success);

      return new FbResult(status: FbStatus.Error, message: result["message"]);

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
        params["fields"] = fields;

      print("logInWithReadPermissions params = $params");

      final Map result = await platform.invokeMethod('logInWithReadPermissions', params);

      return new FbResult(status: FbStatus.Success, data: result);

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
        params["fields"] = fields;

      final Map result = await platform.invokeMethod('logInWithPublishPermissions', params);

      return new FbResult(status: FbStatus.Success, data: result);

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

  Future<FbResult> getAccessToken() async {
    try{
      final Map result = await platform.invokeMethod('getAccessToken');

      new FbResult(status: FbStatus.Success, data: result != null ? result["token"] : null);
    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }

  Future<bool> isInstalled() async {
    try{
      final bool installed = await platform.invokeMethod('isInstalled');
      return installed;
    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }

  Future<FbResult> requestMe([String fields]) async {
    try{

      var args = {};

      if(fields != null)
        args["fields"] = fields;

      final Map result = await platform.invokeMethod('requestMe', args);

      if(result["status"] == "success")
        return new FbResult(status: FbStatus.Success, data: result["result"]);

      return new FbResult(status: FbStatus.Error, message: result["message"]);

    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }

  Future<FbResult> requestGraph([Map parameters]) async {
    try{

      var args = {};

      final Map result = await platform.invokeMethod('requestGraphPath', parameters);

      if(result["status"] == "success")
        return new FbResult(status: FbStatus.Success, data: result["result"]);

      return new FbResult(status: FbStatus.Error, message: result["message"]);

    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }

  Future<FbResult> shareLink(String linkUrl) async {
    try{

      var args = {};

      final Map result = await platform.invokeMethod('shareLink', {
        "linkUrl": linkUrl
      });

      if(result["status"] == "success")
        return new FbResult(status: FbStatus.Success);

      if(result["status"] == "cancel")
        return new FbResult(status: FbStatus.Cancel);

      return new FbResult(status: FbStatus.Error, message: result["message"]);

    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }

  Future<FbResult> shareVideo(String videoUrl) async {
    try{

      var args = {};

      final Map result = await platform.invokeMethod('shareLink', {
        "videoUrl": videoUrl
      });

      if(result["status"] == "success")
        return new FbResult(status: FbStatus.Success);

      if(result["status"] == "cancel")
        return new FbResult(status: FbStatus.Cancel);

      return new FbResult(status: FbStatus.Error, message: result["message"]);

    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }

  Future<FbResult> sharePhoto(String photoUrl) async {
    return sharePhotos([photoUrl]);
  }

  Future<FbResult> sharePhotos(List<String> photosUrl) async {
    try{

      var args = {};

      final Map result = await platform.invokeMethod('shareLink', {
        "sharePhotosUrl": photosUrl
      });

      if(result["status"] == "success")
        return new FbResult(status: FbStatus.Success);

      if(result["status"] == "cancel")
        return new FbResult(status: FbStatus.Cancel);

      return new FbResult(status: FbStatus.Error, message: result["message"]);


    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }
}