// ignore_for_file: file_names
//This is the screen widget that will be responsible for the submission of bank card details.

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../Bloc/AppBloc.dart";
import "../DataModels/CardDetails.dart";

class BankCardDetailsScreen extends StatefulWidget 
{
  const BankCardDetailsScreen({super.key});

  @override
  State<BankCardDetailsScreen> createState() => _BankCardDetailsScreenState();
}

class _BankCardDetailsScreenState extends State<BankCardDetailsScreen>
 {
  String _cardType ="";

  void updateCardType(String cardNumber)
  {
    _cardType = GetCardType(cardNumber);
  }

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardholderNameController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  final TextEditingController _countryOfIssueController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) 
  {
    //Construct a new scaffold here.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bank Card Details"),
      ),
      //Create a new form to capture the bank card number, expiration date, country of issue and the cvv.
      body: BlocBuilder<AppBloc, BlocState>(
        builder: (context, state) 
        {
          return SingleChildScrollView(
            child: Form(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                      ),
                      controller: _cardNumberController,
                      onChanged: (cardNumber)
                      {
                        updateCardType(cardNumber);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Cardholder Name',
                      ),
                      controller: _cardholderNameController,
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                     //Use the CardDetails -> GetCardType function to determine the card type.
                    child:Text("Card Type: $_cardType"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Expiration Date',
                      ),
                      controller: _expirationDateController,
                    ),
                  ),
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: TextFormField(
                     decoration: const InputDecoration(
                       labelText: 'Country of Issue',
                     ),
                     controller: _countryOfIssueController,
                   ),
                 ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                     decoration: const InputDecoration(
                       labelText: 'CVV',
                     ),
                     controller: _cvvController,
                   ),
                ),
                 const SizedBox(height: 20),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     ElevatedButton.icon(onPressed: (){
                      context.read<AppBloc>().add(AddCard(CardDetails(
                          cardNumber: _cardNumberController.text.isEmpty ? "0000000000000000" : _cardNumberController.text,
                          cardholderName: _cardholderNameController.text.isEmpty? "Unknown" : _cardholderNameController.text,
                          //This value should be refreshed based on the input to cardNumber.
                          cardType: GetCardType(_cardNumberController.text),
                          expirationDate: _expirationDateController.text.isEmpty ? "00/00" : _expirationDateController.text,
                          cvv: _cvvController.text.isEmpty ? "000" : _cvvController.text,
                          issuingCountry: _countryOfIssueController.text.isEmpty? "Unknown" : _countryOfIssueController.text
                        )
                      ));
                      Navigator.of(context).pop();
                     },
                     icon: const Icon(Icons.check), 
                     label: const Text("Submit")),
                     const SizedBox(width: 20),
                     ElevatedButton.icon(onPressed: (){
                      //Clear the inputs.
                      _cardNumberController.clear();
                      _cardholderNameController.clear();
                      _expirationDateController.clear();
                      _countryOfIssueController.clear();
                      _cvvController.clear();
                      //Return to the previous screen:
                      Navigator.of(context).pop();
                     },
                     icon: const Icon(Icons.cancel_presentation_rounded), 
                     label: const Text("Cancel")),
                   ],
                 )
                ]
              )
            ),
          );
        }
      )
    );
  }
}