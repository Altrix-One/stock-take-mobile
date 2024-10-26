import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stock_count/constants/theme.dart';
import 'package:stock_count/utilis/change_notifier.dart';
import 'package:sunmi_scanner/sunmi_scanner.dart';

class CalculatorCard extends StatefulWidget {
  final Database? database;
  final int entryId;
  final warehouse;
  final bool? recountEntry;

  const CalculatorCard({
    Key? key,
    this.database,
    required this.entryId,
    required this.warehouse,
    this.recountEntry,
  }) : super(key: key);

  @override
  _CalculatorCardState createState() => _CalculatorCardState();
}

class _CalculatorCardState extends State<CalculatorCard>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String displayText = '0'; // Used to display numbers on calculator

  bool isCameraInitialized = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addObserver(this);

    final countType =
        Provider.of<StockTakeNotifier>(context, listen: false).countType;

    // Listen to the scanner only if the count type is 'Beam'
    if (countType == 'Beam') {
      SunmiScanner.onBarcodeScanned().listen((event) {
        _setScannedValue(event);
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller != null) {
      if (state == AppLifecycleState.inactive) {
        controller!.pauseCamera();
      } else if (state == AppLifecycleState.resumed) {
        controller!.resumeCamera();
      }
    }
  }

  void _setScannedValue(String value) {
    Provider.of<StockTakeNotifier>(context, listen: false)
        .setScannedData(value);
    fetchExistingEntry(); // Fetch using the provider value
    print("Scanned: $value");
  }

  void fetchExistingEntry() async {
    final stockTakeNotifier =
        Provider.of<StockTakeNotifier>(context, listen: false);
    String barcode = stockTakeNotifier.scannedData; // Get from provider

    final existingEntry = await widget.database!.query(
      'StockCountEntryItem',
      where: 'stock_count_entry_id = ? AND item_barcode = ? AND warehouse = ?',
      whereArgs: [widget.entryId, barcode, widget.warehouse],
    );

    print("existingEntry: $existingEntry");

    setState(() {
      displayText = existingEntry.isNotEmpty
          ? existingEntry.first['qty'].toString()
          : '0';
    });
  }

  void _onButtonPressed(String label) {
    setState(() {
      if (label == 'Clear') {
        displayText = '0';
      } else if (label == '<') {
        if (displayText.length > 1) {
          displayText = displayText.substring(0, displayText.length - 1);
        } else {
          displayText = '0';
        }
      } else {
        if (displayText == '0') {
          displayText = label;
        } else {
          displayText += label;
        }
      }
    });
  }

  void submitEntry() async {
    final stockTakeNotifier =
        Provider.of<StockTakeNotifier>(context, listen: false);
    String barcode =
        stockTakeNotifier.scannedData; // Retrieve barcode from provider
    int quantity = int.tryParse(displayText) ?? 0;

    if (widget.database == null) {
      print("Database is null.");
      return;
    }

    if (widget.entryId != 0 && barcode.isNotEmpty && quantity > 0) {
      List<Map> existingEntries = await widget.database!.query(
        'StockCountEntryItem',
        where:
            'stock_count_entry_id = ? AND item_barcode = ? AND warehouse = ?',
        whereArgs: [widget.entryId, barcode, widget.warehouse],
      );

      if (existingEntries.isNotEmpty) {
        await widget.database!.update(
          'StockCountEntryItem',
          {'qty': quantity, 'synced': 0}, // Update quantity and mark unsynced
          where:
              'stock_count_entry_id = ? AND item_barcode = ? AND warehouse = ?',
          whereArgs: [widget.entryId, barcode, widget.warehouse],
        );
      } else {
        await widget.database!.insert('StockCountEntryItem', {
          'stock_count_entry_id': widget.entryId,
          'item_barcode': barcode,
          'warehouse': widget.warehouse,
          'qty': quantity,
          'synced': 0
        });
      }

      await widget.database!.update(
        'StockCountEntry',
        {'synced': 0},
        where: 'id = ?',
        whereArgs: [widget.entryId],
      );

      stockTakeNotifier.setScannedData(''); // Clear scanned data in provider
      setState(() {
        displayText = '0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockTakeNotifier>(
      builder: (context, stockTakeNotifier, child) {
        return Column(
          children: [
            if (stockTakeNotifier.countType == 'Beam')
              _buildBeamScannedDisplay(stockTakeNotifier.scannedData),
            if (stockTakeNotifier.countType != 'Beam') _buildCameraView(),
            Expanded(
              flex: 6,
              child: buildCalculator(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBeamScannedDisplay(String scannedData) {
    return Expanded(
      flex: 3,
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation,
                child: Icon(Icons.qr_code_scanner,
                    size: 48, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 20),
              Text(
                'Scanned Code: $scannedData',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Expanded(
      flex: 3,
      child: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: (QRViewController qrController) {
              controller = qrController;
              if (!isCameraInitialized) {
                controller!.scannedDataStream.listen((scanData) {
                  Provider.of<StockTakeNotifier>(context, listen: false)
                      .setScannedData(scanData.code!);
                  print("Scanned QR/Barcode: ${scanData.code}");
                  fetchExistingEntry();
                });
                isCameraInitialized = true;
              }
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Consumer<StockTakeNotifier>(
                    builder: (context, stockTakeNotifier, child) {
                      return Container(
                        color: Colors.white.withOpacity(0.5),
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Scanned Data: ${stockTakeNotifier.scannedData}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCalculator() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            alignment: Alignment.centerRight,
            child: Text(
              displayText,
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: List.generate(12, (index) {
                List<String> buttons = [
                  '1',
                  '2',
                  '3',
                  '4',
                  '5',
                  '6',
                  '7',
                  '8',
                  '9',
                  'Clear',
                  '0',
                  '<'
                ];
                return CalculatorButton(
                  label: buttons[index],
                  onTap: () => _onButtonPressed(buttons[index]),
                );
              }),
            ),
          ),
          InkWell(
            onTap: submitEntry,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: screenBgColor,
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(17.0),
              child: const Text(
                "Submit Entry",
                style: semibold16Black33,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const CalculatorButton({
    Key? key,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: screenBgColor,
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: semibold16Black33,
        ),
      ),
    );
  }
}
