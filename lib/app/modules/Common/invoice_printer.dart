import 'dart:async';

import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/utils/order_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class InvoicePrinter extends StatefulWidget {
  final FoodOrder order;
  InvoicePrinter({required this.order});

  @override
  _InvoicePrinterState createState() => _InvoicePrinterState();
}

class _InvoicePrinterState extends State<InvoicePrinter> {
  String _info = "";
  String _msj = '';
  bool connected = false;
  List<BluetoothInfo> items = [];
  BluetoothInfo? selectedPrinter;

  String optionprinttype = "58 mm";
  List<String> options = ["58 mm", "80 mm"];

  @override
  void initState() {
    super.initState();
    initPlatformState();
    loadSavedPrinter();
  }

  Future<void> initPlatformState() async {
    try {
      String platformVersion = await PrintBluetoothThermal.platformVersion;
      int batteryLevel = await PrintBluetoothThermal.batteryLevel;
      bool bluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;

      setState(() {
        _info = "$platformVersion ($batteryLevel% battery)";
        _msj = bluetoothEnabled
            ? "Bluetooth enabled, search and connect"
            : "Bluetooth not enabled";
      });
    } on PlatformException {
      setState(() => _info = 'Failed to get platform version.');
    }
  }

  Future<void> loadSavedPrinter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPrinterName = prefs.getString("printer_name");
    String? savedPrinterAddress = prefs.getString("printer_mac");

    if (savedPrinterName != null && savedPrinterAddress != null) {
      setState(() {
        selectedPrinter = BluetoothInfo(
            name: savedPrinterName, macAdress: savedPrinterAddress);
        connected = true;
      });
    }
  }

  Future<void> searchPrinters() async {
    setState(() {
      _msj = "Searching for printers...";
    });
    List<BluetoothInfo> printers = await PrintBluetoothThermal.pairedBluetooths;
    setState(() {
      items = printers;
      _msj = printers.isEmpty
          ? "No printers found"
          : "Select a printer from the list";
    });
  }

  Future<void> connectPrinter(BluetoothInfo printer) async {
    bool success = await PrintBluetoothThermal.connect(
        macPrinterAddress: printer.macAdress);
    if (success) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("printer_name", printer.name);
      await prefs.setString("printer_mac", printer.macAdress);

      setState(() {
        selectedPrinter = printer;
        connected = true;
        _msj = "Connected to ${printer.name}";
      });
    } else {
      setState(() => _msj = "Failed to connect");
    }
  }

  Future<void> resetPrinter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("printer_name");
    await prefs.remove("printer_mac");

    setState(() {
      selectedPrinter = null;
      connected = false;
      _msj = "Printer reset. Please select a new printer.";
    });
  }

  Future<void> printInvoice() async {
    if (connected) {
      List<int> ticket = await generateInvoiceTicket();
      bool result = await PrintBluetoothThermal.writeBytes(ticket);
      print("Invoice print result:  $result");
    } else {
      setState(() => _msj = "No connected device");
    }
  }

  Future<List<int>> generateInvoiceTicket() async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(
        optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);

    bytes += generator.reset();
    bytes += generator.text('Invoice:', styles: PosStyles(bold: true));
    bytes += generator.text(
        "Order: # ${parseOrderId(widget.order.orderId)["counter"]}",
        styles: PosStyles(bold: true));
    bytes += generator
        .text("Customer Name: ${widget.order.customerData.customerName}");

    if (widget.order.tableData != null) {
      bytes += generator.text("Table No: ${widget.order.tableData?.tableName}");
    }

    bytes += generator.text(
        "Order Type: ${widget.order.orderType == OrderType.DINE_IN ? "Dine In" : "Take Away"}");

    bytes += generator.text("Items:", styles: PosStyles(underline: true));

    widget.order.orderItems.forEach((foodItem, quantity) {
      bytes += generator.row([
        PosColumn(text: foodItem.foodName, width: 6),
        PosColumn(text: 'x$quantity', width: 2),
      ]);
    });

    bytes += generator.text("Total: ${widget.order.totalAmount}",
        styles: PosStyles(bold: true));
    bytes += generator.cut();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Invoice Printer')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Info: $_info'),
            Text(_msj),
            DropdownButton<String>(
              value: optionprinttype,
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option, style: TextStyle(color: Colors.black)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  optionprinttype = newValue!;
                });
              },
            ),
            ElevatedButton(
              onPressed: searchPrinters,
              child: Text("Search Printers"),
            ),
            selectedPrinter != null
                ? Text("Selected Printer: ${selectedPrinter!.name}")
                : SizedBox(),
            ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index].name),
                  subtitle: Text(items[index].macAdress),
                  onTap: () => connectPrinter(items[index]),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetPrinter,
              child: Text("Reset Printer"),
            ),
            SizedBox(height: 20),
            Text("Invoice Preview:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 2.h),
            Container(
              width: 100.w,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Order: # ${parseOrderId(widget.order.orderId)["counter"]}",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      "Customer Name: ${widget.order.customerData.customerName}"),
                  widget.order.tableData != null
                      ? Text("Table No: ${widget.order.tableData?.tableName}")
                      : SizedBox(),
                  Text(
                      "Order Type: ${widget.order.orderType == OrderType.DINE_IN ? "Dine In" : "Take Away"}"),
                  Text("Items:"),
                  ...widget.order.orderItems.entries.map(
                      (entry) => Text("${entry.key.foodName} x${entry.value}")),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: connected ? printInvoice : null,
              child: Text("Print Invoice"),
            ),
          ],
        ),
      ),
    );
  }
}
