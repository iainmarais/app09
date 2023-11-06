// ignore_for_file: file_names, non_constant_identifier_names

class CardDetails 
{
  final String cardNumber;
  final String cardholderName;
  final String cardType;
  final String expirationDate;
  final String cvv;
  final String issuingCountry;
  bool isFromBannedCountry;

  CardDetails({
    required this.cardNumber,
    required this.cardholderName,
    required this.cardType,
    required this.expirationDate,
    required this.cvv,
    required this.issuingCountry,
    this.isFromBannedCountry = false,
  });
  Map<String,dynamic> toDictionary()
  {
    return 
    {
      'cardNumber': cardNumber,
      'cardholderName': cardholderName,
      'cardType': cardType,
      'expirationDate': expirationDate,
      'cvv': cvv,
      'issuingCountry': issuingCountry,
      'isFromBannedCountry': isFromBannedCountry
    };
  }
  factory CardDetails.fromDictionary(Map<String,dynamic> dictionary, {bool? isFromBannedCountry})
  {
    return CardDetails(
      cardNumber: dictionary['cardNumber'],
      cardholderName: dictionary['cardholderName'],
      cardType: dictionary['cardType'],
      expirationDate: dictionary['expirationDate'],
      cvv: dictionary['cvv'],
      issuingCountry: dictionary['issuingCountry'],
      isFromBannedCountry: isFromBannedCountry!,
    );
  } 
}
String GetCardType(String cardNum)
  {
    String cardType = "";
    if(cardNum.isNotEmpty)
    {
      //If the bank card number starts with a 4, it is a Visa card.
      if(cardNum.startsWith("4"))
      {
        cardType = "Visa";
      }
      //Mastercard numbers:
      if(cardNum.startsWith( "51") || cardNum.startsWith("52") || cardNum.startsWith("53") || cardNum.startsWith( "54") || cardNum.startsWith("55"))
      {
        cardType = "Mastercard";
      }
      //American express numbers:
      if(cardNum.startsWith("34") || cardNum.startsWith("37"))
      {
        cardType = "American Express";
      }
    }
    else
    {
      cardType ="Unknown";
    }
    return cardType;
  }