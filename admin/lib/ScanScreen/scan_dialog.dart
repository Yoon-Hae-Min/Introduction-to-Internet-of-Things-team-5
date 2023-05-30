import 'package:flutter/material.dart';
import 'scan_main.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PushDialog extends StatefulWidget {
  const PushDialog({super.key});

  @override
  State<PushDialog> createState() => _PushDialogState();
}

class _PushDialogState extends State<PushDialog> {
  final textController = TextEditingController();
  //final _url = 'http://43.200.252.1:8080/point'; //해민님 서버
  final _url = 'http://158.247.215.83:5000/train'; //상연님 서버
  final _url2 = 'http://158.247.215.83:5000/predict'; //상연님 서버
  late Future<Response> postFuture;

  Map<String, dynamic> pushJson(String spot) {
    Map<String, dynamic> jsonData = {};
    List<Map<String, dynamic>> aplist = [];
    for (var element in ScanScreen.apJson) {
      aplist.add(element);
    }
    jsonData.addAll({"name": spot, "data": aplist});
    return jsonData;
  }

//Function to send only information of ap detected in scan
  String pushString() {
    late String pushAPs = "";
    late List<String> compareString = [];
    ScanScreen.apJson.clear();
    ScanScreen.pushStringNum = 0;

    for (int i = 0; i < ScanScreen.accessPoints.length; i++) {
      compareString.add(ScanScreen.accessPoints[i].bssid);
    }

    for (var element in ScanScreen.apMap) {
      if (compareString.contains(element['bssid'])) {
        pushAPs +=
            'ssid : ${element['ssid']}, bssid : ${element['bssid']}, quality : ${element['quality']}\n';
        ScanScreen.apJson.add({
          'ssid': element['ssid'],
          'bssid': element['bssid'],
          'quality': element['quality']
        });
        ScanScreen.pushStringNum++;
      }
    }
    return pushAPs;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
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
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    fixedSize: Size(
                      MediaQuery.of(context).size.width / 5,
                      MediaQuery.of(context).size.height / 30,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  onPressed: () async {
                    Map<String, dynamic> predict = pushJson("asdfs");
                    predict.remove('name');
                    var response = await Dio().post(
                      _url2,
                      data: predict,
                    );
                    Fluttertoast.showToast(
                        msg: response.data.toString(),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  },
                  child: const Text("Predict")),
            ],
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
                  postFuture = Dio().post(
                    _url,
                    data: pushJson(textController.text),
                  ); //Avoid futurebuilder duplicate calls
                  showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return AlertDialog(
                          content: SizedBox(
                            height: 50,
                            child: Center(
                                child: FutureBuilder<Response>(
                                    future: postFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator(
                                          color: Colors.black,
                                        );
                                      } else if (snapshot.hasError) {
                                        return const Text(
                                            "Failed to Send Data");
                                      } else {
                                        return const Text(
                                            "Completed to Send Data");
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
