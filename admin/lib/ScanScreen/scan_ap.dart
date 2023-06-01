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
          Container(
            width: MediaQuery.of(context).size.width / 2,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.ssid,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  widget.bssid,
                  style: const TextStyle(fontSize: 15),
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
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
              ),
              const Text(" dBm"),
              SizedBox(
                width: MediaQuery.of(context).size.width / 15,
              )
            ],
          ),
        ],
      ),
    );
  }
}
