//ignore_for_file: file_names
import "package:sqflite/sqflite.dart" as sqflite; 
import "package:sqflite_common_ffi/sqflite_ffi.dart" as sqflite_ffi;
import 'dart:developer';

abstract class BaseDatabaseHelper
{
  Future<sqflite.Database?> getDatabase();
}

//Got you now, you bastard!
class AndroidDbHelper implements  BaseDatabaseHelper
{
  @override
  Future<sqflite.Database?> getDatabase() async 
  {
    var dbpath = await sqflite.getDatabasesPath();
    var db = await sqflite.openDatabase("$dbpath/cards.sqlite");
    //cards
    await db.execute("CREATE TABLE IF NOT EXISTS cards (id INTEGER PRIMARY KEY, cardNumber TEXT, cardholderName TEXT, cardType TEXT,expirationDate TEXT, issuingCountry TEXT, cvv TEXT)",);
    //banned countries
    await db.execute("CREATE TABLE IF NOT EXISTS bannedCountries (id INTEGER PRIMARY KEY, countryCode TEXT, countryName TEXT, banReason TEXT)");
    //Countries list
    await db.execute("CREATE TABLE IF NOT EXISTS countries (id INTEGER PRIMARY KEY, countryCode TEXT, countryName TEXT, isBanned BOOLEAN NOT NULL, banReason TEXT)");
    //This just tells me that it's working and that the db is being created.
    log("Database ready for use: $db");
    return db;
  }
}
//Working on windows, woot! :D
class WindowsDbHelper implements BaseDatabaseHelper
{
  
  @override
  Future<sqflite.Database?> getDatabase() async
  {
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;
    var db = await sqflite_ffi.openDatabase("cards.sqlite");
    //cards
    await db.execute("CREATE TABLE IF NOT EXISTS cards (id INTEGER PRIMARY KEY, cardNumber TEXT, cardholderName TEXT, cardType TEXT, expirationDate TEXT, issuingCountry TEXT, cvv TEXT)");
    //countries
    await db.execute("CREATE TABLE IF NOT EXISTS bannedCountries (id INTEGER PRIMARY KEY, countryCode TEXT, countryName TEXT, banReason TEXT)");
    //Countries list
    await db.execute("CREATE TABLE IF NOT EXISTS countries (id INTEGER PRIMARY KEY, countryCode TEXT, countryName TEXT, isBanned BOOLEAN NOT NULL, banReason TEXT)");
    //This just tells me that it's working and that the db is being created.
    log("Database ready for use: $db");
    return db;
  }
}