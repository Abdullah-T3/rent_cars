import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../../../Responsive/UiComponanets/InfoWidget.dart';
import '../../Models/customers/CustomersDataModel.dart';
import '../../View Model/customer_view_model.dart';

class CustomerDataView extends StatefulWidget {
  const CustomerDataView({super.key});
  
  @override
  State<CustomerDataView> createState() => _CustomerDataViewState();
}

class _CustomerDataViewState extends State<CustomerDataView> {
  // Create scroll controllers for vertical and horizontal scrolling
  final ScrollController verticalScrollController = ScrollController();
  final ScrollController horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerViewModel>(context, listen: false).fetchCustomers();
    });
  }

  Widget buildTable(CustomerViewModel customerViewModel) {
    return Infowidget(builder: (context, deviceInfo) {
      return SizedBox(
        width: deviceInfo.screenWidth,
        height: deviceInfo.screenHeight,
        child: Scrollbar(
          thumbVisibility: true, // Show scrollbar thumb for vertical scrolling
          controller: verticalScrollController,
          child: SingleChildScrollView(
            controller: verticalScrollController,
            child: Scrollbar(
              thumbVisibility: true, // Show scrollbar thumb for horizontal scrolling
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
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Customer Name')),
                      DataColumn(label: Text('Mobile Number')), // New column for mobile number
                      DataColumn(label: Text('ID Number')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Landline')),
                      DataColumn(label: Text('Reference Line')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: customerViewModel.customers.map<DataRow>((customer) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(customer.customerName ?? 'N/A')),
                          DataCell(Text(customer.mobileNumber.toString() )), // New cell for mobile number
                          DataCell(Text(customer.idNumber ?? 'N/A')),
                          DataCell(Text(customer.address ?? 'N/A')),
                          DataCell(Text(customer.landline ?? 'N/A')),
                          DataCell(Text(customer.referenceNumber ?? 'N/A')),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(context, customer, customerViewModel);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/add_customer');              
            },
          ),
        ],
      ),
      body: Center(
        child: Consumer<CustomerViewModel>(
          builder: (context, customerViewModel, child) {
            if (customerViewModel.isLoading) {
              return const CircularProgressIndicator();
            }

            return buildTable(customerViewModel);
          },
        ),
      ),
    );
  }

 void _showEditDialog(BuildContext context, CustomersDataModel customer, CustomerViewModel viewModel) {
    final TextEditingController nameController = TextEditingController(text: customer.customerName);
    final TextEditingController mobileController = TextEditingController(text: customer.mobileNumber?.toString() ?? "");
    final TextEditingController idController = TextEditingController(text: customer.idNumber);
    final TextEditingController addressController = TextEditingController(text: customer.address);
    final TextEditingController landlineController = TextEditingController(text: customer.landline);
    final TextEditingController referenceController = TextEditingController(text: customer.referenceNumber);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Customer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.number, // Add this to show numeric keyboard
                  decoration: const InputDecoration(labelText: 'Mobile Number'),
                ),
                // ... other TextField widgets
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                customer.customerName = nameController.text;
                // Use int.tryParse() to safely convert string to integer
                customer.mobileNumber = int.tryParse(mobileController.text) ?? 0;
                customer.idNumber = idController.text;
                customer.address = addressController.text;
                customer.landline = landlineController.text;
                customer.referenceNumber = referenceController.text;
                viewModel.updateCustomer(customer);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}