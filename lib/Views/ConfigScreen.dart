// ignore_for_file: file_names, non_constant_identifier_names
import "dart:developer";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

//Not used now:
//import "../DataModels/CardDetails.dart";
import "../Bloc/AppBloc.dart";
import "../DataModels/CountryDataModels.dart";

class ConfigScreen extends StatefulWidget 
{
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> 
{
  final _formKey=GlobalKey<FormState>();
  bool isUpdatingExistingCountry = false;
  int? isBanned = 0;
  final banReasonController = TextEditingController();
  final countryCodeController = TextEditingController();
  final countryNameController = TextEditingController();
  //List<String> cardDetails = [];
  //List<String> countries = [];
  //Establish a list of dropdown menu items with a default unset item:
  List<DropdownMenuItem<String>> dropdownMenuItems = [
    const DropdownMenuItem(
      value: "nothing selected",
      child: Text("Nothing selected"),
    )
  ];
  String selectedCountryCode = "nothing selected";
  
  bool ValidateData()
  {
    if(_formKey.currentState != null && _formKey.currentState!.validate())
    {
      //Check that all the inputs are properly populated and that if the "true" option is selected, that the ban reason is not empty and not "not banned":
      if(isBanned == 1 && banReasonController.text.isNotEmpty && countryCodeController.text.isNotEmpty && countryNameController.text.isNotEmpty)
      {
        if(banReasonController.text != "not banned")
        {
          //return because the condition is satisfied.
          return true;
        }
        else
        {
          //This would occur if either the ban reason is not specified or "not banned" : warn the user using an infobar:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please specify a valid ban reason"),
            )
          );
          return false;
        }
      }
      else if (isBanned == 0 && countryCodeController.text.isNotEmpty && countryNameController.text.isNotEmpty)
      {
        if(banReasonController.text.isEmpty)
        {
          //Default this to "Not banned" and return
          banReasonController.text = "Not banned";
          return true;
        }
      }
      else
      {
        //Show an infobar and return false:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please specify a valid country name and country code"),
          ) 
        );
        return false;
      }
    }
    return false;
  }

  @override
  void initState()
  {
    super.initState();
    BlocProvider.of<AppBloc>(context).add(LoadCards([]));
    BlocProvider.of<AppBloc>(context).add(LoadCountries([]));
  }
  List<DropdownMenuItem<String>> populateDropdownMenu(List<CountryInfo> countries)
  {
    for (CountryInfo country in countries)
    {
      log("Country data retrieved: ${country.countryName} ${country.countryCode}");
      if(!dropdownMenuItems.any((element) => element.value == country.countryCode))
      {
        log("Adding ${country.countryCode} to the dropdown menu");
        dropdownMenuItems.add(
          DropdownMenuItem(
            value: country.countryCode,
            child: Text(country.countryName),
          )
        );
      } 
    }
    return dropdownMenuItems;
  }
  //Responsive appbar item builder:
  Widget _buildResponsiveAction(BuildContext context, IconData iconData, String label, VoidCallback onPressed, double screenWidthThreshold)
  {
    final double screenWidth = MediaQuery.of(context).size.width;
    //Log the screen width to output -> needed for testing the appbar rerender:
    log("Screen width: $screenWidth");
    if(screenWidth > screenWidthThreshold)
    {
      //Text button with icon:
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(iconData),
        label: Text(label),
      );
    }
    else
    {
      //Icon button:
      return IconButton(
        onPressed: onPressed,
        icon: Icon(iconData),
      );
    }
  }
  //List item builder:
  Widget BuildCountryListTile(BuildContext context, CountryInfo country)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        tileColor: const Color.fromARGB(255, 137, 218, 255),
        style: ListTileStyle.drawer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: LayoutBuilder(
          builder: (context,constraints)
          {
            //Widescreen/landscape: width > 500:
            if(constraints.maxWidth > 500)
            {
              return Row(
                children: [
                  Text(country.countryName),
                  const SizedBox(width: 20),
                  Text(country.countryCode),
                  const SizedBox(width: 20),
                  TextButton.icon(onPressed: ()
                  {
                    log("Delete button pressed");
                    try
                    {
                      BlocProvider.of<AppBloc>(context).add(
                        DeleteCountryEntry(country)
                      );
                    } 
                    catch(ex) 
                    {
                      //Need to see what went wrong here without killing the app.
                      log(ex.toString());
                    }
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete"))
                ]
              );
            }
            //else widescreen/landscape: width < 500:
            else
            {
              return Column(
                children: [
                  Text(country.countryName),
                  Text(country.countryCode),
                  const SizedBox(width: 20),
                  TextButton.icon(onPressed: ()
                  {
                    log("Delete button pressed");
                    try
                    {
                      BlocProvider.of<AppBloc>(context).add(
                        DeleteCountryEntry(country)
                      );
                    }
                    catch(ex)
                    {
                      //Need to see what went wrong here without killing the app.
                      log(ex.toString());
                    }
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete"))
                ]
              );
            }
          }
        ),
        subtitle: LayoutBuilder(
        builder: (context,constraints)
          {
            //Widescreen/landscape: width > 500:
            if(constraints.maxWidth > 500)
            {
              return Row(
                children: [
                  Text("Is banned: ${country.isBanned}"),
                  const SizedBox(width: 20),
                  Text(country.banReason)
                ]
              );
            }
            //else widescreen/landscape: width < 500:
            else
            {
              return Column(
                children: [
                  Text("Is banned: ${country.isBanned}"),
                  const SizedBox(width: 20),
                  Text(country.banReason)
                ]
              );
            }
          }
        ),
      )
    );
  }
  //List builder:
  Widget BuildCountryList(BuildContext context, List<CountryInfo> countries)
  {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: countries.length,
      itemBuilder: (context, index)
      {
        return BuildCountryListTile(context, countries[index]);
      }
    );
  }
  Widget CountryUpdateForm(Key formKey)
  {
    return Column(
      children: [
        //Placeholder for now.
        Row(children: [
          //Will need to load in the data from the database here.
          const Text("Select a country to edit: "),
          const SizedBox(width: 20),
          DropdownButton(
           items: const [
             DropdownMenuItem(
               value: "nothing selected",
               child: Text("Nothing selected"),
             ),
           ],onChanged: (value) {
             
           },
             )
           ], 
        )
      ],
    );
  }
  Widget CountryRegistrationForm(Key formKey)
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //These are inputs:
        //Text fields to receive the country name, code and reason for the ban:
        TextFormField(
          controller: countryCodeController,
          decoration: const InputDecoration(
          labelText: "Country code"),
        ),
        TextFormField(
          controller: countryNameController,
          decoration: const InputDecoration(
          labelText: "Country name "),
          
        ),
       TextFormField(
          controller: banReasonController,
          decoration: const InputDecoration(
          labelText: "Reason for ban"),
        ),
        const Row(
          //This should include a text field and a pair of buttons or checkboxes for setting the ban state.
          //Retrieve the ban state from the database -> countries table -> isBanned integer value.
          //How it should work: checkbox "true" if checked: -> checked: isBanned = 1 and uncheck the "false" checkbox
          //                    checkbox "false" if checked: -> checked: isBanned = 0 and uncheck the "true" checkbox
          children: [
            Text("Register current country as banned?: "),
          ],
        ),
        Row(
          children:[
            const Text("Yes"),
            Checkbox(value: isBanned == 1, onChanged: (newVal)
            {
              setState(() {
                isBanned = newVal! ? 1 : 0;
              });
            }),
            const SizedBox(width: 20),
            const Text("No"),
            Checkbox(value: isBanned == 0, onChanged: (newVal)
            {
              setState(() {
                isBanned = newVal! ? 0 : 1;
              });
            }),
          ]
        ),
        Row(
          children: [
            ElevatedButton.icon(onPressed: () async
            {
              try
              {
                //First make sure everything is valid:
                bool isValid = ValidateData();
                if(isValid)
                {
                //Handle the registration or updating process appropriately.
                  if(isUpdatingExistingCountry)
                  {
                    log("update country data is true");
                    //Use the UpdateCountryDetails event:
                    BlocProvider.of<AppBloc>(context).add(UpdateCountryDetails(
                      countryCodeController.text, countryNameController.text, banReasonController.text, isBanned!
                    ));
                    //Update existing country data set: isUpdatingExisting = true
                  }
                  else
                  {
                    log("update country data is false");
                    //Register new country data set: isUpdatingExisting = false
                    BlocProvider.of<AppBloc>(context).add(RegisterCountryDetails(
                      countryCodeController.text, countryNameController.text, banReasonController.text, isBanned!
                    ));
                  }
                  Navigator.pop(context, true);
                }
                //Should this not be valid, the user will be notified and the form will not close.
              }
              //Something's a bit off... Time to see what it is so we can squish it :D
              catch(ex)
              {
                log(ex.toString());
              }
            }, 
              icon: const Icon(Icons.check), 
              label: const Text("Submit")),
            const SizedBox(width: 20),
            ElevatedButton.icon(onPressed: () {
              Navigator.pop(context, true);
            }, 
            icon: const Icon(Icons.do_disturb_alt_outlined), 
            label: const Text("Cancel")),
          ]
        ), 
      ],
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    context.read<AppBloc>().add(LoadCountries([]));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () 
          {
            Navigator.pop(context, true);
          }
        ),
        title: const Text("Config"),
        actions: <Widget>[
        _buildResponsiveAction(context,
          Icons.check_box_outlined, "Add country", () 
          {
            //control the form being displayed in the scaffold below, and set the isUpdatingExistingCountry to false
            setState(() {
              isUpdatingExistingCountry = false;
            });
          }, 820),
        _buildResponsiveAction(context,
          Icons.edit_outlined, "Edit existing country", ()
          {
            //control the form being displayed in the scaffold below, and set the isUpdatingExistingCountry to true
            setState(() {
              isUpdatingExistingCountry = true;
            });
          }, 820)
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              isUpdatingExistingCountry 
                ? CountryUpdateForm(_formKey)
                : CountryRegistrationForm(_formKey),
              Column(
                children: [
                  const SizedBox(height: 10),
                  const Text("Registered countries"),
                  Column(
                    children: [
                      BlocBuilder<AppBloc,BlocState>(
                      builder: (context, state)
                      { 
                        if(state is AppState)
                        {
                          //Need to update the countries list if it is empty
                          if(state.countries.isEmpty)
                          {
                            //How to smooth this out so as to avoid the hard rerenders?
                            context.read<AppBloc>().add(LoadCountries([]));
                          }
                          return BuildCountryList(context, state.countries);
                        }
                        else
                        {
                          return const Column( children:[CircularProgressIndicator(),SizedBox(height: 20),Text("Loading details...")]);
                        }
                      }),
                    ],
                  )
                ]
              )
            ],
          ),
        ),
      ),
    );
  }
}