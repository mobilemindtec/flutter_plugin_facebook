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
        params["fields"] = permissions;

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
        params["fields"] = permissions;

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

  Future<Map> getAccessToken() async {
    try{
      final Map result = await platform.invokeMethod('getAccessToken');
      return new FbResult(status: FbStatus.Success, data: result);
<<<<<<< HEAD
=======
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

  Future<bool> canInvite() async {
    try{
      final bool val = await platform.invokeMethod('canInvite');
      return val;
    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }


  Future<FbResult> invite(String appLinkUrl, String appPreviewImageUrl) async {
    try{
      final Map result = await platform.invokeMethod('invite', {
        "appLinkUrl": appLinkUrl,
        "appPreviewImageUrl": appPreviewImageUrl
      });

      if(result["status"] == "success")
        return new FbResult(status: FbStatus.Success);

      return new FbResult(status: FbStatus.Error, message: result["message"]);

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
        return new FbResult(status: FbStatus.Success, data: result);

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
        return new FbResult(status: FbStatus.Success, data: result);

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

>>>>>>> 65c0acc5332c191c4a775f82cb956c07c3adb3db
    }on PlatformException catch (e) {
      throw new FacebookException(e.message);
    }
  }
}