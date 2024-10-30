import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Responsive/UiComponanets/InfoWidget.dart';
import '../../../Responsive/enums/DeviceType.dart';
import '../../../generated/l10n.dart';
import '../../../widgets/myDrawer.dart';
import '../../Models/orders/orders_model.dart';
import '../../View Model/cars_data_view_model.dart';
import '../../View Model/customer_view_model.dart';
import '../../View Model/orders_view_model.dart';
import '../../View Model/photo_viewmodel.dart';
import 'widgets/build_time_picker.dart';

class AddOrderView extends StatefulWidget {
  const AddOrderView({super.key});

  @override
  _AddOrderViewState createState() => _AddOrderViewState();
}

class _AddOrderViewState extends State<AddOrderView> {
  final _formKey = GlobalKey<FormState>();
  final OrdersModel _order = OrdersModel();
  bool isDesktop = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerViewModel>(context, listen: false).fetchCustomers();
      Provider.of<CarsViewModel>(context, listen: false).fetchCars();
    });
  }

  void _clearFields() {
    setState(() {
      // Reset order model fields
      _order.customerName = '';
      _order.customerMobile = '';
      _order.carLicensePlate = '';
      _order.carName = '';
      _order.rentalDays = null;
      _order.rentalAmount = null;
      _order.carKmAtRental = null;
      _order.rentalDate = null;
      _order.imageUrl = null;

      // Clear the selected image from PhotoViewModel
      Provider.of<PhotoViewModel>(context, listen: false).clearSelectedImage();
    });

    // Clear the form by resetting the controllers if needed
    _formKey.currentState?.reset();
  }

  Future<void> _handleSubmit() async {
    final viewModel = Provider.of<OrderViewModel>(context, listen: false);
    final photoViewModel = Provider.of<PhotoViewModel>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check if an image has been selected
      if (photoViewModel.selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please upload an image before submitting.')),
        );
        return; // Prevent submission
      }

      // Show loading indicator while uploading the image
      if (viewModel.isLoading) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );
      }
      if (viewModel.errorMessage != null) {
        Navigator.pop(context); // Close the loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage!)),
        );
        return; // Prevent further processing
      }

      try {
        final imageUrl = await photoViewModel.uploadPhoto();

        if (imageUrl != null && imageUrl.isNotEmpty) {
          _order.imageUrl = imageUrl;
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Image upload failed. Please try again.')),
          );
          return;
        }

        await viewModel.addOrder(_order);

        if (viewModel.errorMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).order_added_successfully)),
          );
          _clearFields(); // Clear all fields after successful submission
          Navigator.of(context).pushReplacementNamed('/add_order');
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoViewModel = Provider.of<PhotoViewModel>(context);

    return Infowidget(builder: (context, deviceInfo) {
      isDesktop = deviceInfo.deviceType == DeviceType.desktop;
      return Scaffold(
        drawer: const Mydrawer(),
        appBar: AppBar(
          title: Text(S.of(context).add_order),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Customer Name Input
                  TextFormField(
                    controller:
                        TextEditingController(text: _order.customerName),
                    decoration: InputDecoration(
                      labelText: S.of(context).customer_name,
                    ),
                    onSaved: (value) => _order.customerName = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).please_enter_customer_name;
                      }
                      return null;
                    },
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
                              .map((customer) =>
                                  customer.mobileNumber?.toString() ?? '')
                              .where((mobile) => mobile.isNotEmpty);
                          return matchingCustomers;
                        },
                        onSelected: (String selection) {
                          _order.customerMobile = selection;

                          final customer =
                              customerVM.getCustomerByMobile(selection);
                          setState(() {
                            _order.customerName = customer.customerName;
                          });
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: S.of(context).customer_mobile,
                            ),
                            onSaved: (value) =>
                                _order.customerMobile = value ?? '',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S
                                    .of(context)
                                    .please_enter_customer_mobile;
                              }
                              return null;
                            },
                          );
                        },
                      );
                    },
                  ),

// Car License Plate Input with Autocomplete
                  Consumer<CarsViewModel>(
                    builder: (context, carsVM, child) {
                      return Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          final matchingCars = carsVM
                              .searchCarsByLicensePlate(textEditingValue.text)
                              .map((car) => car.license_plate.toString())
                              .where((plate) => plate.isNotEmpty);
                          return matchingCars;
                        },
                        onSelected: (String selection) {
                          _order.carLicensePlate = selection;

                          // Fetch the car details using the selected license plate
                          final car = carsVM.getCarByLicensePlate(selection);

                          if (car != null) {
                            print(
                                'Selected Car: ${car.brand} ${car.model}'); // Debugging
                            setState(() {
                              _order.carName =
                                  '${car.brand} ${car.model}'; // Correctly concatenate brand and model
                            });
                          } else {
                            print(
                                'No car found for the selected license plate.'); // Debugging
                          }
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: S.of(context).car_license_plate,
                            ),
                            onSaved: (value) =>
                                _order.carLicensePlate = value ?? '',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S
                                    .of(context)
                                    .please_enter_car_license_plate;
                              }
                              return null;
                            },
                          );
                        },
                      );
                    },
                  ),
                  // Rental Days Input
                  TextFormField(
                    controller: TextEditingController(text: _order.carName),
                    decoration: InputDecoration(
                      labelText: S.of(context).car_name,
                    ),
                    onSaved: (value) => _order.carName = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).please_enter_rental_days;
                      }
                      return null;
                    },
                  ),

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: S.of(context).rental_days,
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      // Ensure value is a String and parse it to int
                      _order.rentalDays = int.tryParse(
                          value!); // Correctly handle null and non-integer inputs
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).please_enter_rental_days;
                      }
                      return null;
                    },
                  ),

// Rental Amount Input
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: S.of(context).rental_amount,
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      // Use tryParse to convert the String to an int
                      _order.rentalAmount = int.tryParse(value ?? '');
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).please_enter_rental_amount;
                      }
                      // Optionally, check if the parsed value is valid
                      if (int.tryParse(value) == null) {
                        return S
                            .of(context)
                            .please_enter_rental_amount; // You may need to define this message
                      }
                      return null;
                    },
                  ),

// Car KM At Rental Input
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: S.of(context).rental_kilometers,
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      // Use tryParse to convert the String to an int
                      _order.carKmAtRental = int.tryParse(value ?? '');
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).please_enter_rental_kilometers;
                      }
                      // Optionally, check if the parsed value is valid
                      if (int.tryParse(value) == null) {
                        return S
                            .of(context)
                            .please_enter_rental_kilometers; // You may need to define this message
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Rental Date Picker
                  BuildTimePicker(
                    onDateSelected: (selectedDate) {
                      setState(() {
                        _order.rentalDate =
                            selectedDate; // Update the rental date in the order model
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Image Picker
                  photoViewModel.selectedImage != null
                      ? Column(
                          children: [
                            Image.file(photoViewModel
                                .selectedImage!), // Display selected image
                            MaterialButton(
                              color: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              onPressed: () {
                                // Clear the selected image when the button is pressed
                                photoViewModel.clearSelectedImage();
                                setState(() {
                                  // No need for local _selectedImage since we're using the ViewModel
                                });
                              },
                              child: Text(S.of(context).remove_image),
                            ),
                          ],
                        )
                      : MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: Colors.blue,
                          onPressed: () async {
                            await photoViewModel
                                .pickImageFromGallery(); // Open image picker
                            setState(() {
                              // No need for additional state update since the ViewModel handles it
                            });
                          },
                          child: Text(S.of(context).add_image),
                        ),
                  const SizedBox(height: 16),
                  // Submit Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onPressed: _handleSubmit,
                        color: Colors.blue,
                        child: Text(S.of(context).submit_order),
                      ),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onPressed: _clearFields,
                        color: Colors.blue,
                        child: Text(S.of(context).clear_fields),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
