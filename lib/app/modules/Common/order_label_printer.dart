import 'dart:async';
import 'dart:ui' as ui;

import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:niimbot_label_printer/niimbot_label_printer.dart';
import 'package:sizer/sizer.dart';

class FoodLabelPrinter extends StatefulWidget {
  final FoodOrder order;

  const FoodLabelPrinter({super.key, required this.order});

  @override
  State<FoodLabelPrinter> createState() => _FoodLabelPrinterState();
}

class _FoodLabelPrinterState extends State<FoodLabelPrinter> {
  final double labelWidth = 300;
  final double labelHeight = 180;

  List<TextEditingController> nameControllers = [];
  List<TextEditingController> instructionsControllers = [];
  List<bool> activeLabels = [];

  int? selectedIndex;
  TextEditingController editNameController = TextEditingController();
  TextEditingController editInstructionsController = TextEditingController();

  final NiimbotLabelPrinter _niimbotLabelPrinterPlugin = NiimbotLabelPrinter();
  String _printerStatus = 'Not Connected';
  List<BluetoothDevice> _devices = [];
  String? _connectedDeviceAddress;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    widget.order.orderItems.forEach((item, count) {
      nameControllers.add(
          TextEditingController(text: widget.order.customerData.customerName));
      instructionsControllers.add(
          TextEditingController(text: widget.order.specialInstructions ?? ""));
      activeLabels.add(true);
    });
    _initializePrinter();
  }

  @override
  void dispose() {
    for (var controller in nameControllers) {
      controller.dispose();
    }
    for (var controller in instructionsControllers) {
      controller.dispose();
    }
    editNameController.dispose();
    editInstructionsController.dispose();
    _niimbotLabelPrinterPlugin.disconnect();
    super.dispose();
  }

  Future<void> _initializePrinter() async {
    final bool permissionGranted =
        await _niimbotLabelPrinterPlugin.requestPermissionGrant();
    if (permissionGranted) {
      final bool bluetoothEnabled =
          await _niimbotLabelPrinterPlugin.bluetoothIsEnabled();
      if (bluetoothEnabled) {
        _devices = await _niimbotLabelPrinterPlugin.getPairedDevices();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable Bluetooth')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth permission denied')),
      );
    }
  }

  Future<void> _connectToPrinter(BluetoothDevice device) async {
    setState(() => _printerStatus = 'Connecting...');
    try {
      final bool connected = await _niimbotLabelPrinterPlugin.connect(device);
      setState(() {
        _printerStatus = connected ? 'Connected' : 'Connection Failed';
        _connectedDeviceAddress = connected ? device.address : null;
      });
    } catch (e) {
      setState(() => _printerStatus = 'Connection Error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }
  }

  Future<ui.Image> _createLabelImage(int index) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(labelWidth, labelHeight);

    // Create white background
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, paint);

    // Add text
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Label number
    textPainter.text = TextSpan(
      text: "Label ${index + 1}",
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(16, 16));

    // Customer name
    textPainter.text = TextSpan(
      text: "Customer: ${nameControllers[index].text}",
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(16, 46));

    // Food item and count
    FoodItem item = widget.order.orderItems.keys.elementAt(index);
    int count = widget.order.orderItems[item] ?? 1;
    textPainter.text = TextSpan(
      text: "${item.foodName} x$count",
      style: const TextStyle(fontSize: 16),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(16, 76));

    // Instructions
    textPainter.text = TextSpan(
      text: "Instructions: ${instructionsControllers[index].text}",
      style: const TextStyle(fontSize: 14),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(16, 106));

    final picture = recorder.endRecording();
    return picture.toImage(labelWidth.toInt(), labelHeight.toInt());
  }

  Future<void> _printLabel(int index) async {
    if (_printerStatus != 'Connected') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to a printer first')),
      );
      return;
    }

    if (_isPrinting) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please wait for current print to finish')),
      );
      return;
    }

    setState(() => _isPrinting = true);

    try {
      final ui.Image image = await _createLabelImage(index);
      final ByteData? byteData = await image.toByteData();
      if (byteData == null) {
        throw Exception('Failed to get image data');
      }

      final PrintData printData = PrintData.fromMap({
        "bytes": byteData.buffer.asUint8List().toList(),
        "width": image.width,
        "height": image.height,
        "rotate": false,
        "invertColor": false,
        "density": 3,
        "labelType": 1,
      });

      final bool printed = await _niimbotLabelPrinterPlugin.send(printData);
      if (printed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Label ${index + 1} printed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to print label ${index + 1}')),
        );

        throw Exception('Print operation failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing label: $e')),
      );
    } finally {
      setState(() => _isPrinting = false);
    }
  }

  Future<void> _printAllLabels() async {
    if (_printerStatus != 'Connected') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to a printer first')),
      );
      return;
    }

    if (_isPrinting) return;

    setState(() => _isPrinting = true);

    try {
      for (int i = 0; i < activeLabels.length; i++) {
        if (activeLabels[i]) {
          await _printLabel(i);
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } finally {
      setState(() => _isPrinting = false);
    }
  }

  void removeLabel(int index) {
    setState(() {
      activeLabels[index] = false;
      if (selectedIndex == index) {
        selectedIndex = null;
      }
    });
  }

  void selectLabel(int index) {
    setState(() {
      selectedIndex = index;
      editNameController.text = nameControllers[index].text;
      editInstructionsController.text = instructionsControllers[index].text;
    });
  }

  void saveChanges() {
    if (selectedIndex != null) {
      setState(() {
        nameControllers[selectedIndex!].text = editNameController.text;
        instructionsControllers[selectedIndex!].text =
            editInstructionsController.text;
        selectedIndex = null;
      });
    }
  }

  void cancelEdit() {
    setState(() {
      selectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _isPrinting ? null : _printAllLabels,
        child: _isPrinting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.print),
      ),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Printer - $_printerStatus',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Printer'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: _devices.length > 0
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: _devices.length,
                            itemBuilder: (context, index) {
                              final device = _devices[index];
                              return ListTile(
                                title: Text(device.name),
                                subtitle: Text(device.address),
                                selected:
                                    device.address == _connectedDeviceAddress,
                                onTap: () {
                                  Navigator.pop(context);
                                  _connectToPrinter(device);
                                },
                              );
                            },
                          )
                        : SizedBox(
                            height: 100,
                            child: Center(
                              child: Text('No devices found'),
                            ),
                          ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.print),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                for (var i = 0; i < activeLabels.length; i++) {
                  activeLabels[i] = true;
                }
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Label Preview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: labelHeight,
              child: ListView.builder(
                itemCount: widget.order.orderItems.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  if (!activeLabels[index]) return const SizedBox.shrink();

                  FoodItem item = widget.order.orderItems.keys.elementAt(index);
                  int count = widget.order.orderItems[item] ?? 1;
                  bool isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () => selectLabel(index),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Container(
                        width: labelWidth,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Label ${index + 1}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => removeLabel(index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Customer: ${nameControllers[index].text}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${item.foodName} x$count",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Instructions: ${instructionsControllers[index].text}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (selectedIndex != null) ...[
              const SizedBox(height: 24),
              Text(
                "Edit Label ${selectedIndex! + 1}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: editNameController,
                decoration: const InputDecoration(
                  labelText: "Customer Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: editInstructionsController,
                maxLength: 100,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Special Instructions",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: cancelEdit,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: saveChanges,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ],
            SizedBox(
              height: 2.h,
            ),
          ],
        ),
      ),
    );
  }
}
