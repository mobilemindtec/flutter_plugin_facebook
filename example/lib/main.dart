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
        setState((){  _status = "fb is logged in"; });
      else
        setState((){  _status = "fb is not logged in "; });
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
              new Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: new FlatButton(
                  color: Colors.blue[700],
                  onPressed: _initSdk,
                  child: new Text(
                    "Init SDK",
                    style: new TextStyle(
                        color: Colors.white
                    ),
                  ),
                ),
              ),
              new Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: new FlatButton(
                  color: Colors.blue[700],
                  onPressed: _isLoggedIn,
                  child: new Text(
                    "Is Logged In",
                    style: new TextStyle(
                      color: Colors.white
                    ),
                  ),
                ),
              ),
              new Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: new FlatButton(
                  color: Colors.blue[700],
                  onPressed: _logIn,
                  child: new Text(
                    "LogIn",
                    style: new TextStyle(
                        color: Colors.white
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
