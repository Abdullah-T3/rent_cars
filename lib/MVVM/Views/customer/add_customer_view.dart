
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rental_app/generated/l10n.dart';
import '../../Models/customers/CustomersDataModel.dart';

import '../../../Responsive/UiComponanets/InfoWidget.dart';
import '../../View Model/customer_view_model.dart';

class AddCustomerView extends StatefulWidget {
  const AddCustomerView({super.key});

  @override
  _AddCustomerViewState createState() => _AddCustomerViewState();
}

class _AddCustomerViewState extends State<AddCustomerView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerMobileController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landlineController = TextEditingController();
  final TextEditingController _referenceNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final customersViewModel = Provider.of<CustomerViewModel>(context);

    return Infowidget(
      builder: (context, deviceInfo) {
      return Scaffold(
        appBar: AppBar(
          title:  Text(S.of(context).Add_Customer),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Customer Name Field
                TextFormField(
                  controller: _customerNameController,
                  decoration:  InputDecoration(labelText: S.of(context).customer_name),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).please_enter_customer_name;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Customer Mobile Field
                TextFormField(
                  controller: _customerMobileController,
                  decoration:  InputDecoration(labelText: S.of(context).customer_mobile),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).please_enter_customer_mobile;
                    }
                    return null;
                  },
                ),
                // ID Number Field
                TextFormField(
                  controller: _idNumberController,
                  decoration:  InputDecoration(labelText: S.of(context).id_number),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).please_enter_id_number;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
      
                // Address Field
                TextFormField(
                  controller: _addressController,
                  decoration:  InputDecoration(labelText: S.of(context).address),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).please_enter_address;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
      
                // Landline Field
                TextFormField(
                  controller: _landlineController,
                  decoration:  InputDecoration(labelText: S.of(context).landline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).please_enter_landline;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
      
                // Reference Number Field
                TextFormField(
                  controller: _referenceNumberController,
                  decoration:  InputDecoration(labelText: S.of(context).reference_number), 
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).please_enter_reference_number;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
      
                // Submit Button
                Container(
                  width: deviceInfo.screenWidth * 0.5,
                  height: deviceInfo.screenHeight * 0.07,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.blue,
                  ),
                  child: MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Create a new customer object
                        final newCustomer = CustomersDataModel(
                          customerName: _customerNameController.text,
                          idNumber: _idNumberController.text,
                          address: _addressController.text,
                          landline: _landlineController.text,
                          referenceNumber: _referenceNumberController.text,
                        );
                  
                        // Call the ViewModel to add the customer
                        await customersViewModel.addCustomer(newCustomer);
                  
                        // Navigate back or show a success message
                        if (customersViewModel.errorMessage == null || customersViewModel.errorMessage!.isEmpty) {

                          Navigator.pop(context); // Go back to previous screen
                        } else {
                          // Show error message if there's an issue
                          print('Error adding customer: ${customersViewModel.errorMessage}');
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(customersViewModel.errorMessage!)));
                        }
                      }
                    },
                    child: const Text('Add Customer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );  
      }
      
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _idNumberController.dispose();
    _addressController.dispose();
    _landlineController.dispose();
    _referenceNumberController.dispose();
    super.dispose();
  }
}
