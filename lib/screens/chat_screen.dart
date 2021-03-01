import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
UserCredential loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'ChatScreen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messagetextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  
  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      dynamic user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.user);
      }
    } catch (e) {
      print(e);
    }
  }

  void messageStreem() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pushNamed(context, WelcomeScreen.id);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messagetextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messagetextController.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('messages').orderBy("text", descending: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.orange,
            ),
          );
        }
        final messages = snapshot.data.docs.reversed;
        List<MessageBubble> messagesWidgets = [];

        for (var message in messages) {
          final messageText = message.data();
          final messagesender = message.data();

          final currentUser = loggedInUser;

          final messagesBubble = MessageBubble(
            sender: messagesender,
            text: messageText,
            isMe: currentUser == messagesender,
          );
          messagesWidgets.add(messagesBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20.0),
            children: messagesWidgets,
          ),
        );
      },
    );
  }
}

  class MessageBubble extends StatelessWidget {
    MessageBubble({this.sender, this.text, this.isMe});

    final dynamic sender;
    final dynamic text;
    final bool isMe;

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$sender',
              style: TextStyle(color: Colors.black54, fontSize: 12.0),
            ),
            Material(
                elevation: 5.0,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      30.0,
                    ),
                    bottomLeft: Radius.circular(
                      30.0,
                    ),
                    bottomRight: Radius.circular(
                      30.0,
                    )),
                color: isMe ? Colors.white : Colors.lightBlueAccent,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                  child: Text(
                    '$text',
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                  ),
                )),
          ],
        ),
      );
    }
  }
