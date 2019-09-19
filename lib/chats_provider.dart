import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:fractal/auth_state.dart';



/*
https://stackoverflow.com/questions/53459669/so-what-is-the-simplest-approach-for-caching-in-flutter
*/

// TODO: later name CachedChatsAndFirebase
class CachedChats with ChangeNotifier {
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  QuerySnapshot _cachedSavedChats;
  QuerySnapshot _cachedExploredChats;
  Future<QuerySnapshot> _exploredChatsFuture;
  // DateTime _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(0);
  // Duration _cacheValidDuration = Duration(minutes: 30);


  CachedChats()
      :
        // TODO: fix this quick and dirty solution
        _exploredChatsFuture = Firestore.instance
            .collection('chats')
            .where('isSubchat', isEqualTo: false)
            .orderBy('reddit.rank')
            .limit(70)
            .getDocuments();

  QuerySnapshot getCachedSavedChats() {
    // bool shouldRefreshCache = (null == _cachedSavedChats || _lastFetchTime.isBefore(DateTime.now().subtract(_cacheValidDuration)));
    return _cachedSavedChats;
  }
  
  get cachedExploredChats => _cachedExploredChats;
  get exploredChatsFuture => _exploredChatsFuture;

  fetchSavedChatsForCache() async {
    QuerySnapshot savedChats = await Firestore.instance
        .collection('joinedChats')
        .where('user.id', isEqualTo: AuthState.currentUser.documentID)
        .orderBy('lastMessageTimestamp', descending: true)
        .limit(80)
        .getDocuments();
    updatedCachedSavedChats(savedChats);
  }

  void updatedCachedSavedChats(QuerySnapshot updatedSavedChats) {
    _cachedSavedChats = updatedSavedChats;
    notifyListeners();
  }

  void updatedCachedExploredChats(QuerySnapshot updatedCachedExploredChats) {
    _cachedExploredChats = updatedCachedExploredChats;
  }

  // TODO: move the whole firebase logic here
  // TODO: bring explored chats logic here
  // TODO: make a getter for the subchats of a specific chat

  // TODO: memoise this?
  Future<QuerySnapshot> _fetchExploredChats() async {
    QuerySnapshot explored = await Firestore.instance
        .collection('chats')
        .where('isSubchat', isEqualTo: false)
        .orderBy('reddit.rank')
        .limit(70)
        .getDocuments()
        .then((snapshot) {
     // print("Updating Cached Explored Chats");
      updatedCachedExploredChats(snapshot);
    });

    //TODO:  can map to chat models in here
    return explored;
  }

  Future<Null> handleRefresh() async {
    // update function for the future
    _exploredChatsFuture = _fetchExploredChats();
    return null;
  }
}