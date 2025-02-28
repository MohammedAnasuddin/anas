// import 'package:campusbuzz/token.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';


// final eventListProvider = StateNotifierProvider<EventListNotifier, List<Evvent>>((ref) {
//   return EventListNotifier();
// });

// class EventListNotifier extends StateNotifier<List<Evvent>> {
//   EventListNotifier() : super([]);

//   void addEvent(Evvent event) {
//     state = [...state, event];
//   }
// }

import 'package:campusbuzz/token.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventListProvider = StateNotifierProvider<EventListNotifier, List<Evvent>>((ref) {
  return EventListNotifier();
});

class EventListNotifier extends StateNotifier<List<Evvent>> {
  EventListNotifier() : super([]);

  // Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Collection reference for events
  final CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');

  void addEvent(Evvent event) async {
    try {
      // Add the event to Firebase Firestore
      await eventsCollection.add({
        'title': event.title,
        'imageUrl': event.imageUrl,
        'token':event.token,
        'time':event.time,
        'date':event.date,
        'leaderName':event.leaderName,
        'college_name':event.college_name,
      });


      state = [...state, event];
    } catch (e) {
      print('Error adding event to Firestore: $e');
    }
  }
}