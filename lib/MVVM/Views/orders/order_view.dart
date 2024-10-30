import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Responsive/enums/DeviceType.dart';
import '../../../Responsive/UiComponanets/InfoWidget.dart';
import '../../Models/orders/orders_model.dart';
import '../../View Model/orders_view_model.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine if the current locale is Arabic
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Create a ScrollController
    final ScrollController verticalScrollController = ScrollController();
    final ScrollController horizontalScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderViewModel>(context, listen: false).fetchOrders();
    });

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed('/add_order');
              },
            ),
          ],
        ),
        body: Consumer<OrderViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: Image.asset("assets/images/Progress.gif"));
            }

            if (viewModel.errorMessage != null) {
              print('Error: ${viewModel.errorMessage}');
              return Center(child: Text(viewModel.errorMessage!));
            }

            if (viewModel.orders.isEmpty) {
              return const Center(child: Text('No orders available.'));
            }

            return Infowidget(builder: (context, deviceInfo) {
              bool isDesktop = deviceInfo.deviceType == DeviceType.desktop;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 50.0 : 10.0,
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: verticalScrollController,
                  child: SingleChildScrollView(
                    controller: verticalScrollController,
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: horizontalScrollController,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: horizontalScrollController,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: deviceInfo.screenWidth,
                          ),
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(Colors.blue),
                            showBottomBorder: true,
                            columns: const <DataColumn>[
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Customer Name')),
                              DataColumn(label: Text('Mobile')),
                              DataColumn(label: Text('Car Name')),
                              DataColumn(label: Text('Car License Plate')),
                              DataColumn(label: Text('Rental Date')),
                              DataColumn(label: Text('Rental Days')),
                              DataColumn(label: Text('Rental Amount')),
                              DataColumn(label: Text('Photo')),
                              DataColumn(label: Text('Actions')),
                              DataColumn(label: Text('Delete')),
                            ],
                            rows: viewModel.orders.map((order) {
                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(order.orderId?.toString() ?? '')),
                                  DataCell(Text(order.customerName ?? '')),
                                  DataCell(Text(order.customerMobile ?? '')),
                                  DataCell(Text(order.carName ?? '')),
                                  DataCell(Text(order.carLicensePlate ?? '')),
                                  DataCell(Text(order.rentalDate?.toIso8601String().substring(0, 10) ?? '')),
                                  DataCell(Text(order.rentalDays?.toString() ?? '')),
                                  DataCell(Text(order.rentalAmount?.toString() ?? '')),
                                  DataCell(
                                    order.imageUrl != null
                                        ? Image.network(
                                      order.imageUrl!,
                                      width: 50, // Set a width for the image
                                      height: 50, // Set a height for the image
                                      fit: BoxFit.cover, // Adjust fit as needed
                                    )
                                        : const Text('No Image'),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        _showEditDialog(context, order);
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        await viewModel.deleteOrder(order.orderId);
                                        if (viewModel.errorMessage != null) {
                                          print(viewModel.errorMessage);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(viewModel.errorMessage!)),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Order deleted successfully.')),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, OrdersModel order) {
    final viewModel = Provider.of<OrderViewModel>(context, listen: false);
    final TextEditingController customerNameController =
    TextEditingController(text: order.customerName);
    final TextEditingController customerMobileController =
    TextEditingController(text: order.customerMobile);
    final TextEditingController carNameController =
    TextEditingController(text: order.carName);
    final TextEditingController carLicensePlateController =
    TextEditingController(text: order.carLicensePlate);
    final TextEditingController rentalDaysController =
    TextEditingController(text: order.rentalDays?.toString());
    final TextEditingController rentalAmountController =
    TextEditingController(text: order.rentalAmount?.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Order'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: customerNameController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
                TextField(
                  controller: customerMobileController,
                  decoration: const InputDecoration(labelText: 'Customer Mobile'),
                ),
                TextField(
                  controller: carNameController,
                  decoration: const InputDecoration(labelText: 'Car Name'),
                ),
                TextField(
                  controller: carLicensePlateController,
                  decoration: const InputDecoration(labelText: 'Car License Plate'),
                ),
                TextField(
                  controller: rentalDaysController,
                  decoration: const InputDecoration(labelText: 'Rental Days'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: rentalAmountController,
                  decoration: const InputDecoration(labelText: 'Rental Amount'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final updatedOrder = OrdersModel(
                  orderId: order.orderId,
                  customerName: customerNameController.text,
                  customerMobile: customerMobileController.text,
                  carName: carNameController.text,
                  carLicensePlate: carLicensePlateController.text,
                  rentalDate: order.rentalDate,
                  rentalDays: int.tryParse(rentalDaysController.text),
                  rentalAmount: int.tryParse(rentalAmountController.text),
                  carKmAtRental: order.carKmAtRental,
                  imageUrl: order.imageUrl, // Ensure to maintain the photo URL
                );
                await viewModel.updateOrder(updatedOrder);

                if (viewModel.errorMessage != null) {
                  print(viewModel.errorMessage);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(viewModel.errorMessage!)),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Success'),
                      content: const Text('Order updated successfully.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
