import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'scan_ap.dart';
import 'scan_dialog.dart';
import 'scan_filterdilaog.dart';

class ScanScreen extends StatefulWidget {
  static List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  static List<Map<String, dynamic>> apMap = [];
  static List<String> filterSSID = [];
  static List<String> filterBSSID = [];
  static int pushStringNum = 0;
  static bool selectAll = false;
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TextStyle _textStyle = const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );

  bool isScanBuild = false;
  late Future<bool> isScanSuccess;

  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _bssidController = TextEditingController();
  void setbuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade100,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.width / 7,
                                width: MediaQuery.of(context).size.width / 7,
                                child: IconButton(
                                  onPressed: () {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return FilterDialog(
                                            setparent: setbuild,
                                          );
                                        });
                                  },
                                  icon: const Icon(Icons.list_alt_outlined),
                                  iconSize:
                                      MediaQuery.of(context).size.height / 16,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.2,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              28,
                                          child: filterTextField(
                                              'SSID', _ssidController)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          2.2,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              28,
                                      child: filterTextField(
                                          'BSSID', _bssidController)),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 15,
                                    width:
                                        MediaQuery.of(context).size.height / 16,
                                    child: IconButton(
                                      onPressed: () {
                                        if (_ssidController.text != '') {
                                          ScanScreen.filterSSID
                                              .add(_ssidController.text);
                                          _ssidController.clear();
                                        }
                                        if (_bssidController.text != '') {
                                          ScanScreen.filterBSSID
                                              .add(_bssidController.text);
                                          _bssidController.clear();
                                        }
                                        FocusScope.of(context).unfocus();
                                      },
                                      icon: const Icon(Icons.input_rounded),
                                      iconSize:
                                          MediaQuery.of(context).size.height /
                                              22,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const VerticalDivider(
                                indent: 12,
                                endIndent: 12,
                                thickness: 2,
                                color: Colors.black26,
                              ),
                              selectAllButton(),
                            ],
                          ),
                        ],
                      ),
                    )),
                Expanded(
                  flex: 8,
                  child: isScanBuild ? scanBuildList() : rebuildList(),
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
                        onPressed: () async {
                          ScanScreen.apMap.clear();
                          isScanSuccess = getScanResult(context);
                          isScanBuild = true;
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
                                  return const PushDialog();
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
        ),
      ),
    );
  }

  Future<bool> getScanResult(BuildContext context) async {
    ScanScreen.accessPoints.clear();
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
    return true;
  }

  FutureBuilder scanBuildList() {
    ScanScreen.apMap.clear();
    isScanBuild = false;
    return FutureBuilder(
        future: isScanSuccess,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          } else if (snapshot.hasError) {
            return const Text("No Scan Result");
          } else {
            return AnimationLimiter(
              child: ListView.separated(
                cacheExtent: double.infinity,
                itemCount: ScanScreen.accessPoints.length,
                itemBuilder: (context, index) {
                  if (ScanScreen.filterSSID
                          .contains(ScanScreen.accessPoints[index].ssid) ||
                      ScanScreen.filterBSSID
                          .contains(ScanScreen.accessPoints[index].bssid) ||
                      ScanScreen.selectAll) {
                    ScanScreen.apMap.add({
                      "ssid": ScanScreen.accessPoints[index].ssid,
                      "bssid": ScanScreen.accessPoints[index].bssid,
                      "quality": ScanScreen.accessPoints[index].level,
                    });
                  }
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    child: FadeInAnimation(
                      child: SlideAnimation(
                        verticalOffset: 50,
                        child: ApInfo(
                          ssid: ScanScreen.accessPoints[index].ssid,
                          bssid: ScanScreen.accessPoints[index].bssid,
                          dbm: ScanScreen.accessPoints[index].level,
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 7),
              ),
            );
          }
        });
  }

  ListView rebuildList() {
    return ListView.separated(
      cacheExtent: double.infinity,
      itemBuilder: (context, index) {
        return ApInfo(
          ssid: ScanScreen.accessPoints[index].ssid,
          bssid: ScanScreen.accessPoints[index].bssid,
          dbm: ScanScreen.accessPoints[index].level,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 7),
      itemCount: ScanScreen.accessPoints.length,
    );
  }

  TextField filterTextField(
      String hint, TextEditingController filterController) {
    return TextField(
      controller: filterController,
      maxLines: 1,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          borderSide: BorderSide.none,
        ),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        filled: true,
        fillColor: Colors.black26,
      ),
    );
  }

  IconButton selectAllButton() {
    if (ScanScreen.selectAll) {
      return IconButton(
        onPressed: () {
          setState(() {
            ScanScreen.selectAll = false;
            ScanScreen.apMap.clear();
          });
        },
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
        iconSize: MediaQuery.of(context).size.height / 19,
      );
    } else {
      return IconButton(
        onPressed: () {
          setState(() {
            ScanScreen.selectAll = true;
            ScanScreen.apMap.clear();
            for (var apinfo in ScanScreen.accessPoints) {
              ScanScreen.apMap.add({
                'ssid': apinfo.ssid,
                'bssid': apinfo.bssid,
                'quality': apinfo.level
              });
            }
          });
        },
        icon: const Icon(Icons.check_circle_outline),
        iconSize: MediaQuery.of(context).size.height / 19,
      );
    }
  }
}
