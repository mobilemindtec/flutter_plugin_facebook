import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:facebook/facebook.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = 'Unknown';
  String _imageUrl = "http://2.bp.blogspot.com/_6UXYawCQWIo/S-sk4_Q1clI/AAAAAAAADrU/8iGQzpirths/s1600/20101012+chuck-norris.jpg";

  Facebook facebook = new Facebook();

  @override
  initState() {
    super.initState();
    _initSdk();
  }

  _initSdk () {
    print("ok");
    facebook.initSdk().then((result){
      print("facebook login ${result}");
      if(result.status == FbStatus.Success)
        setState((){  _status = "Sdk init ok!"; });
      else
        setState((){  _status = "Sdk init problems!"; });
    }).catchError((err){
      print(err);
      setState((){  _status = "Sdk init error: ${err}"; });
    });
  }

  _isLoggedIn() {
    facebook.isLoggedIn().then((result){
      if(result)
        setState((){  _status = "fb is logged"; });
      else
        setState((){  _status = "fb is not logged "; });
    }).catchError((err){
      print(err);
      setState((){  _status = "call error: ${err}"; });
    });
  }

  _logIn() {

    var permissions = "public_profile,email,user_birthday";
    var fields = "id,name,email,birthday,gender,cover,picture.type(large)";

    facebook.logInWithReadPermissions(fields: fields, permissions: permissions).then((result){
      if(result.status == FbStatus.Success)
        setState((){  _status = "login ok with user id: ${result.data}"; });
      else
        setState((){  _status = "login fail: ${result.message}"; });
    }).catchError((err){
      print(err);
      setState((){  _status = "call error: ${err}"; });
    });
  }

  _logOut() {
    facebook.logOut().then((result){
      setState((){  _status = "logout ok"; });
    }).catchError((err){
      print(err);
      setState((){  _status = "call error: ${err}"; });
    });
  }

  _isInstaled() {
    facebook.isInstalled().then((result){
      if(result)
        setState((){  _status = "facebook app is installed"; });
      else
        setState((){  _status = "facebook app is not installed"; });
    }).catchError((err){
      print(err);
      setState((){  _status = "call error: ${err}"; });
    });
  }


  _requestMe() {
    facebook.requestMe().then((result){
      if(result.status == FbStatus.Success) {
        setState(() {
          _status = " ${result.data}";
          _imageUrl = result.data["picture"]["data"]["url"];
        });
      }else
        setState((){  _status = "fail: ${result.message}"; });
    }).catchError((err){
      print(err);
      setState((){  _status = "call error: ${err}"; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Facebook Plugin example'),
        ),
        body: new Container(
          child: new ListView(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.only(top: 30.0),
                child: new Center(
                  child: new Text(
                    'Result: $_status\n',
                    softWrap: true,
                  ),
                ),
              ),
              new Container(
                child: new Image(
                  image: new NetworkImage(this._imageUrl),
                  height: 100.0,
                  width: 100.0,
                  fit: BoxFit.contain,
                )
              ),
              createButton("is logged", _isLoggedIn),
              createButton("log in", _logIn),
              createButton("log out", _logOut),
              createButton("fb app is installed", _isInstaled),
              createButton("request me profile", _requestMe)              
            ],
          ),
        ),
      ),
    );
  }

  Container createButton(String text, VoidCallback action){
    return new Container(
      padding: const EdgeInsets.only(top: 10.0),
      width: 200.0,
      child: new FlatButton(
        color: Colors.blue[700],
        onPressed: action,
        child: new Text(
          text,
          style: new TextStyle(
            color: Colors.white
          ),
        ),
      ),
    );
  }
}

