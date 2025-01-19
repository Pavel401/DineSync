import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:flutter/material.dart';
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

  // For editing
  int? selectedIndex;
  TextEditingController editNameController = TextEditingController();
  TextEditingController editInstructionsController = TextEditingController();

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
    super.dispose();
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
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.print)),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Order Label Printer'),
        actions: [
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
