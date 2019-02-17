import 'package:flutter/material.dart';
// import '../view/ChatScreen.dart';
import '../model/chat_model.dart';
import '../chat/chatscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../view/chatItem.dart';
import '../auth_state.dart';


class chats extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ChatState();
  }
}

class ChatState extends State<chats> {

  final joinedChats = Firestore.instance.collection('joinedChats').where(
    'userId', isEqualTo: AuthState.currentUser.documentID
  ).snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: joinedChats,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return new Text('Loading...');
          default:
            return new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {

                return new ChatItem(chatDocument: document);
              }).toList(),
            );
        }
      },
    );
  }

}


