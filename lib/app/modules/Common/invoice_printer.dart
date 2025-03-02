import 'dart:async';
import 'dart:io';

import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/utils/order_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/post_code.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal_windows.dart';
import 'package:sizer/sizer.dart';

class InvoicePrinter extends StatefulWidget {
  final FoodOrder order;

  const InvoicePrinter({Key? key, required this.order}) : super(key: key);

  @override
  _InvoicePrinterState createState() => _InvoicePrinterState();
}

class _InvoicePrinterState extends State<InvoicePrinter> {
  String _info = "";
  String _errorMessage = '';
  bool _isConnected = false;
  bool _isLoading = false;
  String _loadingMessage = "";
  List<BluetoothInfo> _devices = [];

  String _printerWidth = "58 mm";
  final List<String> _printerWidthOptions = ["58 mm", "80 mm"];

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  // Initialize Bluetooth state
  Future<void> _initializeBluetooth() async {
    try {
      String platformVersion = await PrintBluetoothThermal.platformVersion;
      int batteryLevel = await PrintBluetoothThermal.batteryLevel;
      bool isBluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;

      if (!mounted) return;

      setState(() {
        _info = "$platformVersion ($batteryLevel% battery)";
        _errorMessage = isBluetoothEnabled
            ? "Bluetooth enabled, please search and connect"
            : "Bluetooth not enabled";
      });
    } on PlatformException {
      setState(() {
        _info = 'Failed to get platform information.';
      });
    }
  }

  // Search for paired Bluetooth devices
  Future<void> _searchDevices() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = "Searching for devices...";
      _devices = [];
    });

    try {
      final List<BluetoothInfo> deviceList =
          await PrintBluetoothThermal.pairedBluetooths;

      if (!mounted) return;

      setState(() {
        _devices = deviceList;
        _errorMessage = deviceList.isEmpty
            ? "No paired Bluetooth devices found. Go to settings to pair your printer."
            : "Touch a device to connect";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error searching for devices: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Connect to a Bluetooth device
  Future<void> _connectToDevice(String macAddress) async {
    setState(() {
      _isLoading = true;
      _loadingMessage = "Connecting...";
    });

    try {
      final bool result =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);

      if (!mounted) return;

      setState(() {
        _isConnected = result;
        _errorMessage = result ? "Connected successfully" : "Failed to connect";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Connection error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Disconnect from the current device
  Future<void> _disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;

      if (!mounted) return;

      setState(() {
        _isConnected = false;
        _errorMessage = "Disconnected";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error disconnecting: $e";
      });
    }
  }

  // Print test receipt
  Future<void> _printTest() async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;

    if (!connectionStatus) {
      setState(() {
        _errorMessage = "No printer connected";
        _isConnected = false;
      });
      return;
    }

    try {
      List<int> ticket;
      bool result;

      if (Platform.isWindows) {
        ticket = await _generateWindowsTestTicket();
        result = await PrintBluetoothThermalWindows.writeBytes(bytes: ticket);
      } else {
        ticket = await _generateTestTicket();
        result = await PrintBluetoothThermal.writeBytes(ticket);
      }

      setState(() {
        _errorMessage = "Test print result: $result";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Print error: $e";
      });
    }
  }

  // Print the order receipt
  Future<void> _printOrderReceipt() async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;

    if (!connectionStatus) {
      setState(() {
        _errorMessage = "No printer connected";
        _isConnected = false;
      });
      return;
    }

    try {
      List<int> ticket;
      bool result;

      if (Platform.isWindows) {
        ticket = await _generateWindowsOrderTicket();
        result = await PrintBluetoothThermalWindows.writeBytes(bytes: ticket);
      } else {
        ticket = await _generateOrderTicket();
        result = await PrintBluetoothThermal.writeBytes(ticket);
      }

      setState(() {
        _errorMessage = "Order print result: $result";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Print error: $e";
      });
    }
  }

  // Generate test ticket for non-Windows platforms
  Future<List<int>> _generateTestTicket() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(
        _printerWidth == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);

    List<int> bytes = [];
    bytes += generator.reset();

    // Header
    bytes += generator.text('TEST RECEIPT',
        styles: PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    bytes += generator.feed(1);
    bytes += generator.text('${DateTime.now()}',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.feed(1);

    // Content
    bytes += generator.text('This is a test receipt',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.feed(1);

    // Footer
    bytes += generator.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.feed(4);

    return bytes;
  }

  // Generate order ticket for non-Windows platforms
  Future<List<int>> _generateOrderTicket() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(
        _printerWidth == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);

    List<int> bytes = [];
    bytes += generator.reset();

    // Header
    bytes += generator.text('ORDER RECEIPT',
        styles: PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    bytes += generator.feed(1);
    bytes += generator.text('${DateTime.now()}',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.feed(1);

    // Order details
    bytes += generator.text(
        'Order: #${parseOrderId(widget.order.orderId)["counter"]}',
        styles: PosStyles(bold: true));
    bytes +=
        generator.text('Customer: ${widget.order.customerData.customerName}');

    if (widget.order.tableData != null) {
      bytes += generator.text('Table: ${widget.order.tableData?.tableName}');
    }

    bytes += generator.text(
        'Type: ${widget.order.orderType == OrderType.DINE_IN ? "Dine In" : "Take Away"}');
    bytes += generator.feed(1);

    // Order items
    bytes += generator.text('ITEMS:',
        styles: PosStyles(bold: true, underline: true));

    // Column header
    bytes += generator.row([
      PosColumn(text: 'Item', width: 8),
      PosColumn(
          text: 'Qty', width: 1, styles: PosStyles(align: PosAlign.right)),
      // PosColumn(
      //     text: 'Price', width: 3, styles: PosStyles(align: PosAlign.right)),
    ]);

    // Items
    double total = 0;
    widget.order.orderItems.forEach((item, quantity) {
      bytes += generator.row([
        PosColumn(text: item.foodName, width: 8),
        PosColumn(
            text: '$quantity',
            width: 1,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
          text: '${(item.foodPrice * quantity).toStringAsFixed(2)}',
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
      total += item.foodPrice * quantity;
    });

    bytes += generator.feed(1);

    // Total
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL:',
        width: 9,
        styles: PosStyles(bold: true),
      ),
      PosColumn(
        text: total.toStringAsFixed(2),
        width: 3,
        styles: PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);

    bytes += generator.feed(1);

    // Footer
    bytes += generator.text('Thank you for your order!',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.feed(4);

    return bytes;
  }

  // Generate test ticket for Windows platforms
  Future<List<int>> _generateWindowsTestTicket() async {
    List<int> bytes = [];

    bytes += PostCode.text(
        text: "TEST RECEIPT",
        fontSize: FontSize.big,
        bold: true,
        align: AlignPos.center);
    bytes += PostCode.text(text: "${DateTime.now()}", align: AlignPos.center);
    bytes += PostCode.enter();
    bytes +=
        PostCode.text(text: "This is a test receipt", align: AlignPos.center);
    bytes += PostCode.enter();
    bytes +=
        PostCode.text(text: "Thank you!", bold: true, align: AlignPos.center);
    bytes += PostCode.enter(nEnter: 4);

    return bytes;
  }

  // Generate order ticket for Windows platforms
  Future<List<int>> _generateWindowsOrderTicket() async {
    List<int> bytes = [];

    bytes += PostCode.text(
        text: "ORDER RECEIPT",
        fontSize: FontSize.big,
        bold: true,
        align: AlignPos.center);
    bytes += PostCode.text(text: "${DateTime.now()}", align: AlignPos.center);
    bytes += PostCode.enter();

    bytes += PostCode.text(
        text: "Order: #${parseOrderId(widget.order.orderId)["counter"]}",
        bold: true);
    bytes += PostCode.text(
        text: "Customer: ${widget.order.customerData.customerName}");

    if (widget.order.tableData != null) {
      bytes +=
          PostCode.text(text: "Table: ${widget.order.tableData?.tableName}");
    }

    bytes += PostCode.text(
        text:
            "Type: ${widget.order.orderType == OrderType.DINE_IN ? "Dine In" : "Take Away"}");
    bytes += PostCode.enter();

    bytes += PostCode.text(text: "ITEMS:", bold: true);
    bytes += PostCode.line();

    // Column header
    bytes += PostCode.row(
      texts: ["Item", "Qty", "Price"],
      proportions: [70, 10, 20],
    );

    // Items
    double total = 0;
    widget.order.orderItems.forEach((item, quantity) {
      bytes += PostCode.row(
        texts: [
          item.foodName,
          quantity.toString(),
          (item.foodPrice * quantity).toStringAsFixed(2)
        ],
        proportions: [70, 10, 20],
      );
      total += item.foodPrice * quantity;
    });

    bytes += PostCode.line();
    bytes += PostCode.row(
      texts: ["TOTAL:", total.toStringAsFixed(2)],
      proportions: [80, 20],
    );

    bytes += PostCode.enter();
    bytes += PostCode.text(
        text: "Thank you for your order!", bold: true, align: AlignPos.center);
    bytes += PostCode.enter(nEnter: 4);

    return bytes;
  }

  // Widget to display the order preview
  Widget _buildOrderPreview() {
    return Container(
      width: 90.w,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "ORDER RECEIPT",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Center(
            child: Text(
              "${DateTime.now()}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Order: #${parseOrderId(widget.order.orderId)["counter"]}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            "Customer: ${widget.order.customerData.customerName}",
            style: TextStyle(color: Colors.black),
          ),
          if (widget.order.tableData != null)
            Text(
              "Table: ${widget.order.tableData?.tableName}",
              style: TextStyle(color: Colors.black),
            ),
          Text(
            "Type: ${widget.order.orderType == OrderType.DINE_IN ? "Dine In" : "Take Away"}",
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(height: 16),
          Text(
            "ITEMS:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: TextDecoration.underline,
            ),
          ),
          SizedBox(height: 8),
          ...widget.order.orderItems.entries.map((entry) {
            final item = entry.key;
            final quantity = entry.value;
            final price = item.foodPrice * quantity;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Text(
                      item.foodName,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "x$quantity",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          SizedBox(height: 16),
          Divider(color: Colors.black),
          SizedBox(height: 16),
          Center(
            child: Text(
              "Thank you for your order!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Printer'),
        // backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _initializeBluetooth,
            tooltip: 'Update Bluetooth Information',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(_loadingMessage, style: TextStyle(color: Colors.white)),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Status information
                    Card(
                      // color: Colors.blueGrey[800],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Device Info: $_info',
                                style: context.textTheme.bodyLarge),
                            SizedBox(height: 8),
                            Text(
                                'Status: ${_isConnected ? "Connected" : "Disconnected"}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      _isConnected ? Colors.green : Colors.red,
                                )),
                            SizedBox(height: 8),
                            Text(_errorMessage,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.amber)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Printer Width selection
                    Card(
                      // color: Colors.blueGrey[800],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text(
                              'Printer Width:',
                              style: context.textTheme.bodyLarge,
                            ),
                            SizedBox(width: 16),
                            DropdownButton<String>(
                              // dropdownColor: Colors.grey[900],
                              value: _printerWidth,
                              items: _printerWidthOptions.map((String option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option,
                                      style: TextStyle(color: Colors.black)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _printerWidth = newValue;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _searchDevices,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text("Search Devices"),
                        ),
                        ElevatedButton(
                          onPressed: _isConnected ? _disconnect : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text("Disconnect"),
                        ),
                        ElevatedButton(
                          onPressed: _isConnected ? _printTest : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                          ),
                          child: Text("Test Print"),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Devices list
                    if (_devices.isNotEmpty)
                      Card(
                        color: Colors.blueGrey[800],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Available Devices',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                              SizedBox(height: 8),
                              Container(
                                height: 20.h,
                                child: ListView.builder(
                                  itemCount: _devices.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      onTap: () => _connectToDevice(
                                          _devices[index].macAdress),
                                      title: Text('${_devices[index].name}',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      subtitle: Text(
                                          '${_devices[index].macAdress}',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      trailing: Icon(Icons.bluetooth,
                                          color: Colors.blue),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 16),

                    // Order preview
                    Text('Order Preview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(height: 8),
                    _buildOrderPreview(),
                    SizedBox(height: 16),

                    // Print button
                    ElevatedButton.icon(
                      onPressed: _isConnected ? _printOrderReceipt : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      icon: Icon(Icons.print),
                      label: Text("Print Order Receipt",
                          style: TextStyle(fontSize: 16)),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
