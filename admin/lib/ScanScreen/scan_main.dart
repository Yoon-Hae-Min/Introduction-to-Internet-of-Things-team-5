import 'package:admin/ScanScreen/scan_ap.dart';
import 'package:admin/ScanScreen/scan_dialog.dart';
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ScanScreen extends StatefulWidget {
  static List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  static Map<String, int> apMap = {};
  static Map<String, int> apJson = {};
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

  late bool isLoading = false;
  late bool isScanSuccess = false;

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
    results.sort((a, b) => a.level.compareTo(b.level));
    ScanScreen.accessPoints = results.reversed.toList();

    setState(() {
      isLoading = false;
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
                        ? AnimationLimiter(
                            child: ListView.separated(
                              scrollDirection: Axis.vertical,
                              itemCount: ScanScreen.accessPoints.length,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  child: FadeInAnimation(
                                    child: SlideAnimation(
                                      verticalOffset: 50,
                                      child: ApInfo(
                                        ssid:
                                            ScanScreen.accessPoints[index].ssid,
                                        bssid: ScanScreen
                                            .accessPoints[index].bssid,
                                        dbm: ScanScreen
                                            .accessPoints[index].level,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 7),
                            ),
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
                            barrierDismissible: false,
                            builder: (context) {
                              return PushDialog();
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
