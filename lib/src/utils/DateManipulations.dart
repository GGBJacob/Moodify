String monthToString(int month) //returns string for month number
{
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    return months[month - 1];
  }


String ?getDateEnding(int day) //returns ending of date day
{
  String ending = '';
  if((day >= 4 && day <=20) || (day>=24 && day <=30))
  {
    ending = 'th';
  }
  else if(day == 1 || day == 21 || day == 31)
  {
    ending = 'st';
  }
  else if(day == 2 || day == 22)
  {
    ending = 'nd';
  }
  else
  {
    ending = 'rd';
  }

  return ending;
}

 String noteDate(DateTime selected_day) //returns date of note
{
  return '${selected_day.day}${getDateEnding(selected_day.day)} ${monthToString(selected_day.month)} ${selected_day.year}';
}