String datetimeToString(DateTime dateTime) {
  int intHour = dateTime.hour;
  int intMin = dateTime.minute;

  String hour = (intHour < 10) ? "0$intHour" : "$intHour";
  String min = (intMin < 10) ? "0$intMin" : "$intMin";

  return "$hour:$min";
}
