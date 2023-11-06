// ignore_for_file: file_names
//This could be put into the main.dart, but I want to use that as an entry point and/or global state management file, which is why the main gui will be here instead.

import 'dart:developer';

import 'package:app09/Views/BankCardDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import "../Bloc/AppBloc.dart";
import '../DataModels/CardDetails.dart';
import 'ConfigScreen.dart';

class MainScreen extends StatefulWidget 
{
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> 
{
  String _duplicateEntryMessage = "";

  @override 
  void initState() 
  {
    super.initState();
    context.read<AppBloc>().duplicateEntryMessageController.stream.listen((message) {
      setState(() {
        _duplicateEntryMessage = message;
      });
    });
  }
  //Use the card details from the sqlite database to build out a list tile with the card details in it.
  Widget buildCardTile(BuildContext context,CardDetails cardDetails)
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
            if(constraints.maxWidth > 500)
            {
              return Row(
                children: [
                  Text("Card Number: ${cardDetails.cardNumber}"),
                  const SizedBox(width: 20),
                  TextButton.icon(onPressed: (){
                    log("Delete button pressed");
                    try
                    {
                      BlocProvider.of<AppBloc>(context).add(
                        DeleteCardDetails(cardDetails)
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
                ],
              );
            }
            else
            {
              return Column(
                children: [
                  Text("Card Number: ${cardDetails.cardNumber}"),
                  const SizedBox(width: 20),
                  TextButton.icon(onPressed: (){
                    log("Delete button pressed");
                    try
                    {
                      BlocProvider.of<AppBloc>(context).add(
                        DeleteCardDetails(cardDetails)
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
                ],
              );
            }
          }
        ),
        subtitle: Column(
          children: [
            Text("Cardholder name: ${cardDetails.cardholderName}"),
            Text("Valid until: ${cardDetails.expirationDate}"),
            Text("Card Type: ${cardDetails.cardType}"),
            Text("Issuing Country: ${cardDetails.issuingCountry}"),
            Text("CVV: ${cardDetails.cvv}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Is from a banned country?"),
                const SizedBox(width: 20),
                Icon(cardDetails.isFromBannedCountry ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined)
              ]
            )
          ],
        ),
        
      ),
    );
  }

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

  @override
  Widget build(BuildContext context)
  {
    //This should handle the initial loading of data:
    context.read<AppBloc>().add(LoadCards([]));
    return Scaffold(
        appBar: AppBar(
              title: const Text("Bank Card Validator"),
              actions: <Widget>[
                _buildResponsiveAction(context, Icons.refresh_outlined, "Refresh", () 
                {
                  context.read<AppBloc>().add(LoadCards([]));
                }, 820),
                _buildResponsiveAction(context, Icons.settings_applications_outlined, "Configuration", () async
                {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const ConfigScreen();
                      },
                    )
                  );
                  if(result == true && context.mounted)
                  {
                    BlocProvider.of<AppBloc>(context).add(LoadCards([]));
                  }
                }, 820),
                _buildResponsiveAction(context, Icons.check_box_outlined, "Register new card", () 
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BankCardDetailsScreen(),
                    )
                  );
                }, 820),
                _buildResponsiveAction(context, Icons.photo_camera_outlined, "Photograph card", () { }, 820),
          ],
        ),
        body: Column(
          children: [
             Builder(
              builder: (BuildContext scaffoldContext) {
                if (_duplicateEntryMessage.isNotEmpty) {
                  log(_duplicateEntryMessage);
                  // Use ScaffoldMessenger to show the notification
                  try
                  {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      //Clear any previous infobars:
                      ScaffoldMessenger.of(scaffoldContext).clearSnackBars();
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text(_duplicateEntryMessage, style: const TextStyle(fontWeight: FontWeight.bold),),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                  }
                  catch(ex)
                  {
                    log(ex.toString());
                  }

                }
                return const SizedBox.shrink(); // Empty SizedBox
              },
            ),
            Expanded(
              //This list can grow, hence scrollable view.
              //Ultimately this column should scroll independently but be contained within the main scroll view.
              //It is just a case of how do I achieve that? Not sure yet...
              child: BlocBuilder<AppBloc, BlocState>(
                builder: (context, state)
                {
                  if(state is AppState)
                  {
                    final cards = state.cards;
                    return ListView.builder(
                      itemCount: cards.length,
                      itemBuilder: (context, index)
                      {
                        final cardDetails = cards[index];
                        return buildCardTile(context, cardDetails);
                      }
                    );
                  }
                  else
                  {
                    return const Column( children:[CircularProgressIndicator(),SizedBox(height: 20),Text("Loading details...")]);
                  }
                }
              ),
            ),
          ],
        )
      );
  }
}