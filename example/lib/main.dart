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

  Facebook facebook = new Facebook();

  @override
  initState() {
    super.initState();
    _initSdk();
  }

  _initSdk () {
    print("ok");
    facebook.initSdk().then((result){
      print("db login ${result}");
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
    facebook.logInWithReadPermissions().then((result){
      if(result.status == FbStatus.Success)
        setState((){  _status = "login ok with user id: ${result.data['userId']}"; });
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

  _canInvite() {
    facebook.canInvite().then((result){
      if(result)
        setState((){  _status = "yes, you can invite"; });
      else
        setState((){  _status = "no, you can not invite"; });
    }).catchError((err){
      print(err);
      setState((){  _status = "call error: ${err}"; });
    });
  }

  _requestMe() {
    facebook.requestMe().then((result){
      if(result.status == FbStatus.Success)
        setState((){  _status = "name = ${result.data['name']}"; });
      else
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
          child: new Column(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.only(top: 30.0),
                child: new Center(
                  child: new Text('Status: $_status\n'),
                ),
              ),
              createButton("is logged", _isLoggedIn),
              createButton("log in", _logIn),
              createButton("log out", _logOut),
              createButton("fb app is installed", _isInstaled),
              createButton("can invite", _canInvite),
              createButton("request me profile", _requestMe),
            ],
          ),
        ),
      ),
    );
  }

  Container createButton(String text, Function action){
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

