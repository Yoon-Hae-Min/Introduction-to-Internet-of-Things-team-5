import 'package:admin/ScanScreen/scan_ap.dart';
import 'package:flutter/material.dart';

class ScanScreen extends StatefulWidget {
  static Map<String, int> apMap = {};
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TextStyle _textStyle = const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  ApInfo(
                    ssid: "Gachon_Free_Wifi",
                    bssid: "AB::CD::EE::45",
                    dbm: -36,
                  )
                ],
              ),
            ),
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
                    onPressed: () {},
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
                        late String pushAPs = "";
                        ScanScreen.apMap.forEach((key, value) {
                          pushAPs += '$key : $value\n';
                        });
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
                                                pushAPs,
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
                                      "Pushes ${ScanScreen.apMap.length} AP Info",
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
                                          onPressed: () {},
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
