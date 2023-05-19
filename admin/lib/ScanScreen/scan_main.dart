import 'package:admin/ScanScreen/scan_ap.dart';
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

class ScanScreen extends StatefulWidget {
  static Map<String, int> apMap = {};
  static int pushStringNum = 0;
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TextStyle _textStyle = const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );

  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  late bool isLoading = false;
  late bool isScanSuccess = false;

  List<WiFiAccessPoint> getSortedAPs(List<WiFiAccessPoint> accessPoints) {
    accessPoints.sort((a, b) => a.level.compareTo(b.level));
    return accessPoints.reversed.toList();
  }

  //Function to send only information of ap detected in scan
  String pushString() {
    late String pushAPs = "";
    late List<String> compareString = [];
    ScanScreen.pushStringNum = 0;

    for (int i = 0; i < accessPoints.length; i++) {
      compareString.add("${accessPoints[i].ssid} ${accessPoints[i].bssid}");
    }
    ScanScreen.apMap.forEach((key, value) {
      if (compareString.contains(key)) {
        pushAPs += '$key : $value\n';
        ScanScreen.pushStringNum++;
      }
    });

    return pushAPs;
  }

  Future<bool> getScanResult(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    var canScan =
        await WiFiScan.instance.canStartScan(); // check if can-startScan
    if (canScan != CanStartScan.yes) {
      return false;
    } // if can-not, then show error
    await WiFiScan.instance.startScan(); // call startScan API
    var canGetResult = await WiFiScan.instance
        .canGetScannedResults(); // check if can-getScannedResults
    if (canGetResult != CanGetScannedResults.yes) {
      return false;
    } // if can-not, then show error
    final results = await WiFiScan.instance.getScannedResults();
    setState(() {
      isLoading = false;
      accessPoints = results;
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 8,
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : isScanSuccess
                        ? ListView.separated(
                            scrollDirection: Axis.vertical,
                            itemCount: accessPoints.length,
                            itemBuilder: (context, index) {
                              return ApInfo(
                                ssid: getSortedAPs(accessPoints)[index].ssid,
                                bssid: getSortedAPs(accessPoints)[index].bssid,
                                dbm: getSortedAPs(accessPoints)[index].level,
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 7),
                          )
                        : const Center(
                            child: Text("No Scan Results"),
                          )),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade400,
                      fixedSize: Size(
                        MediaQuery.of(context).size.width / 2.5,
                        MediaQuery.of(context).size.height / 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    onPressed: () async {
                      isScanSuccess = await getScanResult(context);
                      setState(() {});
                    },
                    child: Text("Scan", style: _textStyle),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(
                          MediaQuery.of(context).size.width / 2.5,
                          MediaQuery.of(context).size.height / 12,
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
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2,
                                        color: Colors.blueGrey.shade200,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              Text(
                                                pushString(),
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        )),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Pushes ${ScanScreen.pushStringNum} AP Info",
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.grey.shade400,
                                            fixedSize: Size(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                              MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Cancle")),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: Size(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                              MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                          ),
                                          onPressed:
                                              () {}, //To Do: Send to Database in NodeJS
                                          child: const Text("Push")),
                                    ],
                                  ),
                                ],
                              );
                            });
                      },
                      child: Text(
                        "Push",
                        style: _textStyle,
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
