import 'dart:async';

import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/post_code.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

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
  List<String> _options = [
    "permission bluetooth granted",
    "bluetooth enabled",
    "connection status",
    "update info"
  ];

  String _selectSize = "2";
  final _txtText = TextEditingController(text: "Hello developer");
  bool _progress = false;
  String _msjprogress = "";

  String optionprinttype = "58 mm";
  List<String> options = ["58 mm", "80 mm"];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(' Invoice Printer'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('info: $_info\n '),
                Text(_msj),
                Row(
                  children: [
                    Text("Type print"),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: optionprinttype,
                      items: options.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          optionprinttype = newValue!;
                        });
                      },
                    ),
                  ],
                ),
                // Displaying order items
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  child: Column(
                    children: [
                      Text("Order Items:"),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.order.orderItems.length,
                        itemBuilder: (context, index) {
                          var item =
                              widget.order.orderItems.keys.elementAt(index);
                          var quantity = widget.order.orderItems[item];
                          return ListTile(
                            title: Text('${item.foodName}'),
                            subtitle: Text('Quantity: $quantity'),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: connected ? this.printInvoice : null,
                        child: Text("Print Invoice"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    int porcentbatery = 0;
    try {
      platformVersion = await PrintBluetoothThermal.platformVersion;
      porcentbatery = await PrintBluetoothThermal.batteryLevel;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    final bool result = await PrintBluetoothThermal.bluetoothEnabled;
    if (result) {
      _msj = "Bluetooth enabled, please search and connect";
    } else {
      _msj = "Bluetooth not enabled";
    }

    setState(() {
      _info = platformVersion + " ($porcentbatery% battery)";
    });
  }

  Future<void> printInvoice() async {
    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
    if (conexionStatus) {
      List<int> ticket = await generateInvoiceTicket();
      bool result = await PrintBluetoothThermal.writeBytes(ticket);
      print("Invoice print result:  $result");
    } else {
      setState(() {
        _msj = "No connected device";
      });
      print("No connected");
    }
  }

  Future<List<int>> generateInvoiceTicket() async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(
        optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);

    bytes += generator.reset();

    // Adding order details to the ticket
    bytes += generator.text('Invoice:');
    bytes += generator.text('Order ID: ${widget.order.orderId}');
    bytes += generator.text('Time: ${widget.order.orderTime.toLocal()}');

    widget.order.orderItems.forEach((foodItem, quantity) {
      bytes += generator.row([
        PosColumn(text: foodItem.foodName, width: 6),
        PosColumn(text: 'x$quantity', width: 2),
      ]);
    });

    bytes += PostCode.line();
    bytes += generator.text('Total: ${widget.order.totalAmount}');
    bytes += generator.cut();

    return bytes;
  }
}
