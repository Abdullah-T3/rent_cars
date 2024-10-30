import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Responsive/UiComponanets/InfoWidget.dart';
import '../../../generated/l10n.dart';
import '../../Models/expenses/expenses_data_model.dart';
import '../../View Model/expenses_data_view_model.dart';
import '../../View Model/customer_view_model.dart';

class AddExpenseView extends StatefulWidget {
  const AddExpenseView({super.key});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerMobileController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _carDetailsController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _remainingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Infowidget(builder: (context, device) {
      return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).add_expenses),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _customerNameController,
                decoration: InputDecoration(labelText: S.of(context).customer_name),
              ),
              
              // Customer Mobile Input with Autocomplete
              Consumer<CustomerViewModel>(
                builder: (context, customerVM, child) {
                  return Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      final matchingCustomers = customerVM
                          .searchCustomersByMobile(textEditingValue.text)
                          .map((customer) => customer.mobileNumber?.toString() ?? '')
                          .where((mobile) => mobile.isNotEmpty);
                      return matchingCustomers;
                    },
                    onSelected: (String selection) {
                      _customerMobileController.text = selection;

                      // Fetch customer by selected mobile and set customer name
                      final customer = customerVM.getCustomerByMobile(selection);
                      setState(() {
                        _customerNameController.text = customer?.customerName ?? '';
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(labelText: S.of(context).customer_mobile),
                      );
                    },
                  );
                },
              ),

              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: S.of(context).description),
              ),
              TextField(
                controller: _carDetailsController,
                decoration: InputDecoration(labelText: S.of(context).car_details),
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: S.of(context).date),
              ),
              TextField(
                controller: _costController,
                decoration: InputDecoration(labelText: S.of(context).cost),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _remainingController,
                decoration: InputDecoration(labelText: S.of(context).remaining),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Container(
                width: device.screenWidth * 0.7,
                height: device.screenHeight * 0.05,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: MaterialButton(
                  onPressed: () {
                    _addExpense(context);
                  },
                  child: Text(S.of(context).save),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _addExpense(BuildContext context) {
    final expensesViewModel = Provider.of<ExpensesViewModel>(context, listen: false);

    final newExpense = ExpensesDataModel(
      customerName: _customerNameController.text,
      description: _descriptionController.text,
      carDetails: _carDetailsController.text,
      expensesDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      cost: _costController.text,
      remaining: _remainingController.text,
    );

    expensesViewModel.addExpense(newExpense).then((_) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        // ignore: use_build_context_synchronously
        SnackBar(content: Text(S.of(context).expense_added_successfully)),
      );
      _clearFields();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add expense: $error')),
      );
    });
  }

  void _clearFields() {
    _customerNameController.clear();
    _customerMobileController.clear();
    _descriptionController.clear();
    _carDetailsController.clear();
    _dateController.clear();
    _costController.clear();
    _remainingController.clear();
  }
}
