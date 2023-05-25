import 'package:flutter/material.dart';
import 'scan_main.dart';
import 'package:dio/dio.dart';

class PushDialog extends StatefulWidget {
  const PushDialog({super.key});

  @override
  State<PushDialog> createState() => _PushDialogState();
}

class _PushDialogState extends State<PushDialog> {
  final Dio _dio = Dio();
  final textController = TextEditingController();

  final _url = 'http://43.200.252.1:8080/point';

//Function to send only information of ap detected in scan
  String pushString() {
    late String pushAPs = "";
    late List<String> compareString = [];
    ScanScreen.apJson.clear();
    ScanScreen.pushStringNum = 0;

    for (int i = 0; i < ScanScreen.accessPoints.length; i++) {
      compareString.add(
          "${ScanScreen.accessPoints[i].ssid} ${ScanScreen.accessPoints[i].bssid}");
    }
    ScanScreen.apMap.forEach((key, value) {
      if (compareString.contains(key)) {
        pushAPs += '$key : $value\n';
        ScanScreen.apJson.addAll({key: value});
        ScanScreen.pushStringNum++;
      }
    });
    return pushAPs;
  }

  Map<String, dynamic> pushJson(String spot) {
    Map<String, dynamic> jsonData = {};
    List<Map<String, int>> aplist = [];
    ScanScreen.apJson.forEach((key, value) {
      aplist.add({key: value});
    });
    jsonData.addAll({"name": spot, "data": aplist});
    return jsonData;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4,
              color: Colors.blueGrey.shade200,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      pushString(),
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ],
                ),
              )),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            height: 30,
            child: TextField(
              controller: textController,
              maxLines: 1,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Spot',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                filled: true,
                fillColor: Colors.black26,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Pushes ${ScanScreen.pushStringNum} AP Info",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          )
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  fixedSize: Size(
                    MediaQuery.of(context).size.width / 3,
                    MediaQuery.of(context).size.height / 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancle")),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(
                    MediaQuery.of(context).size.width / 3,
                    MediaQuery.of(context).size.height / 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return AlertDialog(
                          content: SizedBox(
                            height: 50,
                            child: Center(
                                child: FutureBuilder(
                                    future: _dio.post(
                                      _url,
                                      data: pushJson(textController.text),
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator(
                                          color: Colors.black,
                                        );
                                      } else if (snapshot.hasError) {
                                        return const Text(
                                            "Failed to Send Data.");
                                      } else {
                                        return const Text(
                                            "Completed to Send Data.");
                                      }
                                    })),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      fixedSize: Size(
                                        MediaQuery.of(context).size.width / 6,
                                        MediaQuery.of(context).size.height / 32,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                    ),
                                    child: const Text("OK"))
                              ],
                            )
                          ],
                        );
                      });
                },
                child: const Text("Push")),
          ],
        ),
      ],
    );
  }
}