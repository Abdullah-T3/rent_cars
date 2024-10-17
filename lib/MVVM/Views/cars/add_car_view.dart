import 'package:bookingcars/MVVM/Models/cars_data_model.dart';
import 'package:bookingcars/MVVM/View%20Model/cars_data_view_model.dart';
import 'package:bookingcars/generated/l10n.dart';
import 'package:bookingcars/widgets/myDrawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddCarView extends StatefulWidget {
  const AddCarView({super.key});

  @override
  _AddCarViewState createState() => _AddCarViewState();
}

class _AddCarViewState extends State<AddCarView> {
  final _formKey = GlobalKey<FormState>();
  final _licensePlateController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearOfManufactureController = TextEditingController();
  final _odometerReadingController = TextEditingController();
  final _nextOilChangeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CarsViewModel>(context, listen: false);
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Add Car'),
      ),
      drawer: const Mydrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _licensePlateController,
                  decoration:  InputDecoration(
                    labelText: S.of(context).car_license_plate,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter license plate';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _brandController,
                  decoration:  InputDecoration(
                    labelText: S.of(context).brand,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter brand';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modelController,
                  decoration:  InputDecoration(
                    labelText: S.of(context).model,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter model';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _yearOfManufactureController,
                  decoration:  InputDecoration(
                    labelText: S.of(context).year_of_manufacture,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter year of manufacture';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _odometerReadingController,
                  decoration:  InputDecoration(
                    labelText: S.of(context).odometer_reading,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter odometer reading';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nextOilChangeController,
                  decoration:  InputDecoration(
                    labelText: S.of(context).next_oil_change,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter next oil change';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      CarsDataModel car = CarsDataModel(
                        license_plate: _licensePlateController.text,
                        brand: _brandController.text,
                        model: _modelController.text,
                        yearOfManufacture:
                            int.parse(_yearOfManufactureController.text),
                        odometerReading:
                            int.parse(_odometerReadingController.text),
                        nextOilChange: int.parse(_nextOilChangeController.text),
                      );
                      await viewModel.addCar(car);
                      if (viewModel.errorMessage!.isNotEmpty) {
                        showDialog(
                          // ignore: use_build_context_synchronously
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: Text(viewModel.errorMessage!),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        showDialog(
                          // ignore: use_build_context_synchronously
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Success'),
                              content: const Text('Car added successfully'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }

                      // Call the addCar function from your view model
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    }
                  },
                  child:  Text(S.of(context).add_car),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
