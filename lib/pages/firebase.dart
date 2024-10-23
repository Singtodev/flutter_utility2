import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

class FirebasePage extends StatefulWidget {
  const FirebasePage({super.key});

  @override
  State<FirebasePage> createState() => _FirebasePageState();
}

class _FirebasePageState extends State<FirebasePage> {
  final TextEditingController docCtl = TextEditingController();
  final TextEditingController nameCtl = TextEditingController();
  final TextEditingController messageCtl = TextEditingController();
  final db = FirebaseFirestore.instance;
  late StreamSubscription listener;

  void readData() async {
    var result = await db.collection('inbox').doc(docCtl.text).get();
    var data = result.data();
    debugPrint(data!['message']);
    debugPrint(
        (data['createAt'] as Timestamp).millisecondsSinceEpoch.toString());
  }

  void queryData() async {
    var inboxRef = db.collection("inbox");
    var query = inboxRef.where("name", isEqualTo: nameCtl.text);
    var result = await query.get();
    if (result.docs.isNotEmpty) {
      for (var result in result.docs) {
        debugPrint(result.data()['message']);
      }
    }
  }

  void startRealtimeGet() {
    final docRef = db.collection("inbox").doc(docCtl.text);
    listener = docRef.snapshots().listen(
      (event) {
        var data = event.data();
        Get.snackbar(data!['name'].toString(), data['message'].toString());
        debugPrint("current data: ${event.data()}");
      },
      onError: (error) => debugPrint("Listen failed: $error"),
    );
  }

  void stopRealTime() {
    try {
      listener.cancel().then(
        (value) {
          debugPrint('Listener is stopped');
        },
      );
    } catch (e) {
      debugPrint('Listener is not running...');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop){
        stopRealTime();
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text('Document'),
                TextField(
                  controller: docCtl,
                ),
                const Text('Name'),
                TextField(
                  controller: nameCtl,
                ),
                const Text('Message'),
                TextField(
                  controller: messageCtl,
                ),
                FilledButton(
                    onPressed: () {
                      var data = {
                        'name': nameCtl.text,
                        'message': messageCtl.text,
                        'createAt': DateTime.timestamp()
                      };
                      db.collection('inbox').doc(docCtl.text).set(data);
                    },
                    child: const Text('Add Data')),
                FilledButton(onPressed: readData, child: const Text('Read Data')),
                FilledButton(
                    onPressed: queryData, child: const Text('Query Data')),
                FilledButton(
                    onPressed: startRealtimeGet,
                    child: const Text('Start Real-time Get')),
                FilledButton(
                    onPressed: stopRealTime,
                    child: const Text('Stop Real-time Get'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
