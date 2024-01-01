import 'package:campusbuzz/token.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';


class YourEvents extends ConsumerStatefulWidget {
  final List<Evvent> events;

  YourEvents({
    super.key,
    required this.events,
  });

  @override
  ConsumerState<YourEvents> createState() => _YourEventsState(events: events);
}

class _YourEventsState extends ConsumerState<YourEvents> {
  final CollectionReference _events = FirebaseFirestore.instance
      .collection('Event'); // Assuming your collection is named 'Event'

  List<Evvent> events;

  _YourEventsState({required this.events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Events"),
      ),
      body: FutureBuilder(
        future: getRegisteredEvents(), // Function to get registered event IDs
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading events"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No registered events found."),
            );
          } else {
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return FutureBuilder(
                  future: getEventDetails(snapshot.data![index]),
                  builder: (context, AsyncSnapshot<Evvent?> eventSnapshot) {
                    if (eventSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (eventSnapshot.hasError) {
                      return const Center(
                        child: Text("Error loading event details"),
                      );
                    } else if (!eventSnapshot.hasData) {
                      return const Center(
                        child: Text("Event details not found"),
                      );
                    } else {
                      Evvent event = eventSnapshot.data!;
                      return buildEventCard(event);
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<String>> getRegisteredEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    // Replace with the actual user UID
    DocumentSnapshot userDocument =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    List<String> registeredEventIds =
        List<String>.from(userDocument.get("registeredEvents"));
    log("Registerd Events Ids: ${registeredEventIds}");
    return registeredEventIds;
  }

  Future<Evvent?> getEventDetails(String eventId) async {
    List<String> registeredEvents = await getRegisteredEvents();

    for(String eventId in registeredEvents ){
    DocumentSnapshot eventDocument =
        await FirebaseFirestore.instance.collection('Event').doc(eventId).get();

    if (eventDocument.exists) {
      Map<String, dynamic> eventData =
          eventDocument.data() as Map<String, dynamic>;

      return Evvent(
        token: eventDocument.id,
        imageUrl: eventData["imageUrl"],
        time: eventData["time"],
        date: eventData["date"],
        title: eventData["title"],
        leaderName: eventData["leaderName"],
        college_name: eventData["college_name"],
      );
    } else {
      return null;
    }
    }
    
  }

  Widget buildEventCard(Evvent event) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ticket"),
      ),
      body: StreamBuilder(
        stream: _events.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              //no of rows
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                // Evvent event = eventList[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TokenDisplayScreen(
                            event: Evvent(
                                token: "token",
                                imageUrl: "imageUrl",
                                time: "time",
                                date: "date",
                                title: "title",
                                leaderName: "leaderName",
                                college_name: "college_name"),
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        FadeInImage(
                          placeholder: MemoryImage(kTransparentImage),
                          image: AssetImage(documentSnapshot['imageUrl']),
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        ),
                        Column(
                          children: [],
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black45,
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 44),
                            child: Column(
                              children: [
                                Text(
                                  documentSnapshot['title'],
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  overflow: TextOverflow
                                      .ellipsis, // Very long text ...
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                                //const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ); //
          }
          return const Center(
            child: Center(
                child: Text(
              "Loading..",
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w400, color: Colors.red),
            )),
          );
        },
      ),
    );
    // ...
  }
}