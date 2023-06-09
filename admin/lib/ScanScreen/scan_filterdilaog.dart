import 'package:admin/ScanScreen/scan_main.dart';
import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key, required this.setparent});

  final Function() setparent;

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "SSID",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 5,
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    return filtered(ScanScreen.filterSSID[index], true);
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                        height: 10,
                      ),
                  itemCount: ScanScreen.filterSSID.length),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "BSSID",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 5,
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    return filtered(ScanScreen.filterBSSID[index], false);
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                        height: 10,
                      ),
                  itemCount: ScanScreen.filterBSSID.length),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: const Text(
                "Remove By sliding  -->",
                style: TextStyle(
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              widget.setparent();
              Navigator.pop(context);
              FocusScope.of(context).unfocus();
            },
            child: const Text("OK"))
      ],
    );
  }

  Dismissible filtered(String id, bool ssidORbssid) {
    return Dismissible(
        key: ObjectKey(widget.key),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          if (ssidORbssid) {
            ScanScreen.filterSSID.remove(id);
          } else {
            ScanScreen.filterBSSID.remove(id);
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 10,
          height: 30,
          decoration: BoxDecoration(
              color: Colors.blueGrey.shade200,
              borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Text(
              id,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ));
  }
}
