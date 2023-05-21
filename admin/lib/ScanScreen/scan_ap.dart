import 'package:admin/ScanScreen/scan_main.dart';
import 'package:flutter/material.dart';

class ApInfo extends StatefulWidget {
  final String ssid, bssid;
  final int dbm;
  const ApInfo({
    super.key,
    required this.ssid,
    required this.bssid,
    required this.dbm,
  });

  @override
  State<ApInfo> createState() => _ApInfoState();
}

class _ApInfoState extends State<ApInfo> {
  IconData setIconData() {
    if (widget.dbm < -70) return Icons.wifi_1_bar_rounded;
    if (widget.dbm <= -50 && widget.dbm >= -70) return Icons.wifi_2_bar_rounded;
    if (widget.dbm > -50) return Icons.wifi;
    return Icons.question_mark;
  }

  IconButton setIconButton() {
    if (ScanScreen.apMap.containsKey("${widget.ssid} ${widget.bssid}")) {
      ScanScreen.apMap.addAll({"${widget.ssid} ${widget.bssid}": widget.dbm});
      return IconButton(
        icon: const Icon(
          Icons.check_circle,
          size: 36,
          color: Colors.green,
        ),
        onPressed: () {
          setState(() {
            ScanScreen.apMap.remove("${widget.ssid} ${widget.bssid}");
          });
        },
      );
    } else {
      return IconButton(
        icon: const Icon(
          Icons.check_circle_outline,
          size: 36,
          color: Colors.black,
        ),
        onPressed: () {
          setState(() {
            ScanScreen.apMap
                .addAll({"${widget.ssid} ${widget.bssid}": widget.dbm});
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            setIconData(),
            size: 46,
            color: Colors.black,
          ),
          SizedBox(
            width: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.ssid,
                  style: const TextStyle(fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  widget.bssid,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              ],
            ),
          ),
          Row(
            children: [
              Text(
                "${widget.dbm}",
                style: const TextStyle(fontSize: 24),
              ),
              const Text(" dBm"),
            ],
          ),
          Row(
            children: [
              const VerticalDivider(
                indent: 12,
                endIndent: 12,
                thickness: 2,
                color: Colors.black26,
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 14,
                  ),
                  setIconButton()
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
