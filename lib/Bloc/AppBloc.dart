//ignore_for_file: file_names, non_constant_identifier_names
import "dart:async";

import "package:flutter_bloc/flutter_bloc.dart";
import "dart:io";
import "dart:developer";

import "../DataModels/CardDetails.dart";
import "../DataModels/CountryDataModels.dart";
import "../Helpers/DatabaseHelper.dart";
//import "AppStates.dart";


//Bloc - events
abstract class BlocEvent{}

class AddCard extends BlocEvent
{
  final CardDetails cardDetails;
  AddCard(this.cardDetails);
}
class LoadCards extends BlocEvent
{
  final List<CardDetails> cards;
  LoadCards(this.cards);
}
class DeleteCardDetails extends BlocEvent
{
  final CardDetails cardDetails;
  DeleteCardDetails(this.cardDetails);
}
class DeleteCountryEntry extends BlocEvent
{
  final CountryInfo countryInfo;
  DeleteCountryEntry(this.countryInfo);
}
//Register a new country entry:
class RegisterCountryDetails extends BlocEvent
{
  final String countryCode;
  final String countryName;
  final String banReason;
  final int isBanned;
  RegisterCountryDetails(this.countryCode, this.countryName, this.banReason, this.isBanned);
}
//Update an existing country entry:
class UpdateCountryDetails extends BlocEvent
{
  final String countryCode;
  final String countryName;
  final String banReason;
  final int isBanned;
  UpdateCountryDetails(this.countryCode, this.countryName, this.banReason, this.isBanned);
}
class LoadCountries extends BlocEvent
{
  final List<CountryInfo> countries;
  LoadCountries(this.countries);
}

//
//Bloc - states
abstract class BlocState {}

class AppState extends BlocState 
{
  final List<CardDetails> cards;
  final List<CountryInfo> countries;

  AppState(this.cards, this.countries);
  AppState loadedFromDb(List<CardDetails> cards, List<CountryInfo> countries)
  {
    return AppState(cards, countries);
  }
}
//Country information classes


BaseDatabaseHelper createDbHelper()
{
  if (!Platform.isWindows)
  {
    return AndroidDbHelper();
  }
  else
  {
    return WindowsDbHelper();
  }
}

class AppBloc extends Bloc<BlocEvent, BlocState> 
{
  //Need to be able to swap this between windows and android.
  final BaseDatabaseHelper _dbHelper;
  AppBloc() : _dbHelper = createDbHelper(), super(AppState([],[]))
  {
    //Use this handler for the country of issue to check it against a ban list in the database.
    on<AddCard>((event, emit) async
    {
      try
      {
        final cardDetails = event.cardDetails;
        await checkIsFromBannedCountry(cardDetails);
        // Store the card details to the database
        final db = await _dbHelper.getDatabase();
        //Check if there is an existing entry with this card number:
        final existingEntry = await db?.query("cards", where: "cardNumber = ?", whereArgs: [cardDetails.cardNumber]);
        if(existingEntry!.isNotEmpty)
        {
          log("Duplicate card entry:$existingEntry");
          duplicateEntryMessageController.add("Duplicate card entry not added to database: ${cardDetails.cardNumber}");
        }
        else
        {
          duplicateEntryMessageController.add("");
          await db?.insert("cards", cardDetails.toDictionary());
        }
        // Retrieve the updated list of cards from the database
        final cardsFromDb = await loadCardsFromDb();

        // Emit a new state with the updated list of cards
        emit(AppState(cardsFromDb,[]));
      } 
      catch (ex) 
      {
        //Log the exception to the console for debug purposes.
        log(ex.toString());
      }
    });
    on<LoadCards>((event, emit) async
    {
      try
      {
        final cardsFromDb = await loadCardsFromDb();
        emit (AppState(cardsFromDb,[]));
      }
      catch(ex)
      {
        log(ex.toString());
      }
    });
    on<DeleteCardDetails>((event, emit) async
    {
      try
      {
        final cardDetails = event.cardDetails;
        //Get the database from the helper:
        final db = await _dbHelper.getDatabase();
        //Execute the query to delete the entry using the cardNumber value
        await db?.delete("cards", where: "cardNumber = ?", whereArgs: [cardDetails.cardNumber]);

        //Retrieve the updated list of cards from the database
        final cardsFromDb = await loadCardsFromDb();

        //Emit a new state with the updated list of cards
        emit(AppState(cardsFromDb,[]));
      }
      catch(ex)
      {
        log(ex.toString());
      }
    });
    //Register a new country to the database:
    on<RegisterCountryDetails>((event, emit)async
    {
      try
      {
        final countryCode = event.countryCode;
        final countryName = event.countryName;
        final banReason = event.banReason;
        final isBanned = event.isBanned;
        final db = await _dbHelper.getDatabase();
        //Insert a new entry using the country code
        await db?.insert(
          "countries",
          {"countryCode": countryCode},
        );
        //Update the other data relating to the new entry:
        await db?.update(
          "countries",
          {"banReason": banReason},
          where: "countryCode = ?",
          whereArgs: [countryCode],
        );
        await db?.update(
          "countries",
          {"countryName": countryName},
          where: "countryCode = ?",
          whereArgs: [countryCode],
        );
        await db?.update(
          "countries",
          {"isBanned": isBanned},
          where: "countryCode = ?",
          whereArgs: [countryCode],
        );
      }
      catch(ex)
      {
        log(ex.toString());
      }
    });
    on<UpdateCountryDetails>((event, emit) async 
    {
      try 
      {
        final countryCode = event.countryCode;
        final countryName = event.countryName;
        final banReason = event.banReason;
        final isBanned = event.isBanned;
        final db = await _dbHelper.getDatabase();
        //Update the ban state in the countries table:
        await db?.update(
          "countries",
          {"isBanned": isBanned},
          where: "countryCode = ?",
          whereArgs: [countryCode],
        );

        await db?.update(
          "countries",
          {"countryName": countryName},
          where: "countryCode = ?",
          whereArgs: [countryCode],
        );

        await db?.update(
          "countries",
          {"banReason": banReason},
          where: "countryCode = ?",
          whereArgs: [countryCode],
        );
      } 
      catch (ex) 
      {
        log(ex.toString());
      }
    });

    on<DeleteCountryEntry>((event, emit) async 
    {
      try 
      {
        final countryInfo = event.countryInfo;
        final db = await _dbHelper.getDatabase();
        //Update the ban state in the countries table:
        await db?.delete(
          "countries",
          where: "countryCode = ?",
          whereArgs: [countryInfo.countryCode],
        );
      } 
      catch (ex) 
      {
        log(ex.toString());
      }
    });
    on<LoadCountries> ((event, emit) async
    {
      try
      {
        final db = await _dbHelper.getDatabase();
        final countries = await db?.query("countries");
        emit(AppState([],countries!.map((country) 
        {
          final countryCode = country["countryCode"] as String;
          final countryName = country["countryName"] as String;
          final isBanned = country["isBanned"] as int;
          final banReason = country["banReason"] as String;
          if(isBanned == 1)
          {
            return CountryInfo(countryCode, countryName, true, banReason);
          }
          else
          {
            return CountryInfo(countryCode, countryName, false, banReason);
          }
        }).toList()));
      }
      catch(ex)
      {
        log(ex.toString());
      }
    });
  }
  //No existing method to overrride - commented out the directive as below:
  final duplicateEntryMessageController = StreamController<String>.broadcast();
  //@override 
  Stream<BlocState> mapEventToState(BlocEvent event) async*
  {
    if(event is AddCard)
    {
      final cardDetails = event.cardDetails;
      await checkIsFromBannedCountry(cardDetails);
      //Store the card details to the database
      final db = await _dbHelper.getDatabase();
      //Need to check in the db for an existing entry with this card number:
      final existingCard = await db?.query("cards", where: "cardNumber = ?", whereArgs: [cardDetails.cardNumber]);
      if(existingCard!.isNotEmpty)
      {
        log("Duplicate card entry:$existingCard");
        duplicateEntryMessageController.add("Duplicate card entry not added to database: ${cardDetails.cardNumber}");
        return;
      }
      else
      {
        duplicateEntryMessageController.add("");
        await db?.insert("cards",cardDetails.toDictionary());
      }
      //Retrieve the details from the db
      final cardsFromDb = await loadCardsFromDb();
      yield AppState(cardsFromDb,[]);
    }
    else if (event is LoadCountries)
    {
      try
      {
        final db = await _dbHelper.getDatabase();
        final countries = await db?.query("countries");
        final countriesList = countries!.map((country) 
        {
          final  countryCode = country["countryCode"] as String;
          final countryName = country["countryName"] as String;
          final isBanned = country["isBanned"] as int;
          final banReason = country["banReason"] as String;
          if(isBanned == 1)
          {
            return CountryInfo(countryCode, countryName, true, banReason);
          }
          else 
          {
            return CountryInfo(countryCode, countryName, false, banReason);
          }
        }).toList();
        yield AppState([],countriesList);
      }
      catch(ex)
      {
        log(ex.toString());
      }
    }
  }
  Future<List<CardDetails>> loadCardsFromDb() async
  {
    final cardDetails = await _dbHelper.getDatabase();
    final List<Map<String, Object?>>? cardDatasets = await cardDetails?.query("cards");
    return List.generate(cardDatasets!.length,(index)
      {
        final cardData = cardDatasets[index];
        for (var data in cardDatasets)
        {
          log(data.toString());
        }
        bool isFromBannedCountry = cardData['isFromBannedCountry'] == 1;
        return CardDetails.fromDictionary(cardData, isFromBannedCountry:isFromBannedCountry);
      }
    );
  }
  Future<void> checkIsFromBannedCountry(CardDetails cardDetails) async
  {
    final db = await _dbHelper.getDatabase();
    if (db != null)
    {
      final countries = await db.query(
        "countries", where: "countryCode = ?", whereArgs: [cardDetails.issuingCountry],
      );
      for (var country in countries)
      {
        if(country["isBanned"] == 1)
        {
          cardDetails.isFromBannedCountry = true;
        }
        else
        {
          cardDetails.isFromBannedCountry = false;
        }
      }
    }
  }
  Future<bool> GetCountryBanState(String queriedCountryCode) async
  {
    final db = await _dbHelper.getDatabase();
    bool isBanned = false;
    if(db != null)
    {
      final result = await db.query("countries", columns: ["isBanned"], where: "countryCode = ?", whereArgs: [queriedCountryCode]);
      if(result.isNotEmpty)
      {
        isBanned = result[0]["isBanned"] == 1;
      }
      return isBanned;
    }
    return false;
  }
  Future<String> GetCountryCode(String queriedCountryCode) async
  {
    final db = await _dbHelper.getDatabase();
    if(db != null)
    {
      final result = await db.query("countries", columns: ["countryCode"], where: "countryCode = ?", whereArgs: [queriedCountryCode]);
      if(result.isNotEmpty)
      {
        return result[0]["countryCode"] as String;
      }
    }
    return "No data found";
  }
  Future<String> GetBanReason(String queriedCountryCode) async
  {
    final db = await _dbHelper.getDatabase();
    if(db != null)
    {
      final result = await db.query("countries", columns: ["banReason"], where: "countryCode = ?", whereArgs: [queriedCountryCode]);
      if(result.isNotEmpty)
      {
        return result[0]["banReason"] as String;
      }
    }
    return "No data found";
  }
}