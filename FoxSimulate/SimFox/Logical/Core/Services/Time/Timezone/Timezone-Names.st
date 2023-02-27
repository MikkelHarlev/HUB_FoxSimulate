(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: Timezone
 * File: Timezone-Names.st
 * Author: duem
 * Created: January 14, 2014
 ********************************************************************
 * Implementation of program Timezone
 ********************************************************************) 

(* Add a new action to your IEC program or library *)
ACTION TimezoneNames:
	memset(ADR(Timezone_Names), 0, SIZEOF(Timezone_Names));
	 
	Timezone_Names[1]									:= '(GMT -12:00) International date line (west)';
	Timezone_Names[2]									:= '(GMT -11:00) Midway Islands, Samoa';
	Timezone_Names[3]									:= '(GMT -10:00) Hawaii';
	Timezone_Names[4]									:= '(GMT -09:00) Alaska';
	Timezone_Names[5]									:= '(GMT -08:00) Pacific Time (USA & Canada), San Francisco, Vancouver, Tijuana';
	Timezone_Names[6]									:= '(GMT -07:00) Arizona';
	Timezone_Names[7]									:= '(GMT -07:00) Mountain Time (USA & Canada), Denver, Salt Lake City';
	Timezone_Names[8]									:= '(GMT -07:00) Chihuahua, Mazatlan';
	Timezone_Names[9]									:= '(GMT -06:00) Guadalajara, Mexico City, Monterrey';
	Timezone_Names[10]								:= '(GMT -06:00) Central Time (USA & Canada), Kansas City, Houston';
	Timezone_Names[11]								:= '(GMT -06:00) Saskatchewan';
	Timezone_Names[12]								:= '(GMT -05:00) Bogota, Lima, Quito';
	Timezone_Names[13]								:= '(GMT -05:00) New York, Miami, Atlanta, Detroit, Toronto';
	Timezone_Names[14]								:= '(GMT -05:00) Cuba';
	Timezone_Names[15]								:= '(GMT -05:00) Indiana (east)';
	Timezone_Names[16]								:= '(GMT -04:00) Caracas, La Paz';
	Timezone_Names[17]								:= '(GMT -04:00) Santiago';
	Timezone_Names[18]								:= '(GMT -04:00) Atlantic Time (Canada)';
	Timezone_Names[19]								:= '(GMT -03:30) Newfoundland';
	Timezone_Names[20]								:= '(GMT -03:00) Greenland';
	Timezone_Names[21]								:= '(GMT -03:00) Brazil';
	Timezone_Names[22]								:= '(GMT -03:00) Buenos Aires, Georgetown';
	Timezone_Names[23]								:= '(GMT -02:00) Mid Atlantic';
	Timezone_Names[24]								:= '(GMT -01:00) Azores';
	Timezone_Names[25]								:= '(GMT -01:00) Cape Verde';
	Timezone_Names[26]								:= '(GMT) Dublin, Edinburgh, Lisbon, London';
	Timezone_Names[27]								:= '(GMT) Casablanca, Monrovia';
	Timezone_Names[28]								:= '(GMT +01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna';
	Timezone_Names[29]								:= '(GMT +01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague';
	Timezone_Names[30]								:= '(GMT +01:00) Brussels, Copenhagen, Madrid, Paris';
	Timezone_Names[31]								:= '(GMT +01:00) West Central Africa';
	Timezone_Names[32]								:= '(GMT +01:00) Sarajevo, Skopje, Warsaw, Zagreb';
	Timezone_Names[33]								:= '(GMT +02:00) Athens, Beirut, Istanbul, Minsk; Bucharest';
	Timezone_Names[34]								:= '(GMT +02:00) Bucharest';
	Timezone_Names[35]								:= '(GMT +02:00) Helsinki, Kiev, Riga, Sofia, Tallinn, Vilnius';
	Timezone_Names[36]								:= '(GMT +02:00) Cairo';
	Timezone_Names[37]								:= '(GMT +02:00) Harare, Pretoria';
	Timezone_Names[38]								:= '(GMT +02:00) Jerusalem';
	Timezone_Names[39]								:= '(GMT +03:00) Nairobi';
	Timezone_Names[40]								:= '(GMT +03:00) Baghdad';
	Timezone_Names[41]								:= '(GMT +03:00) Kuwait, Riyadh';
	Timezone_Names[42]								:= '(GMT +03:00) Moskow, St. Petersburg, Volgograd';
	Timezone_Names[43]								:= '(GMT +03:30) Tehran';
	Timezone_Names[44]								:= '(GMT +04:00) Abu Dhabi, Muscat';
	Timezone_Names[45]								:= '(GMT +04:00) Samara';
	Timezone_Names[46]								:= '(GMT +04:00) Baku, Tbilisi, Yerevan';
	Timezone_Names[47]								:= '(GMT +04:30) Kabul';
	Timezone_Names[48]								:= '(GMT +05:00) Ekaterinburg';
	Timezone_Names[49]								:= '(GMT +05:00) Islamabad, Karachi, Tashkent';
	Timezone_Names[50]								:= '(GMT +05:30) Chennai, Calcutta, Bombay, New Delhi';
	Timezone_Names[51]								:= '(GMT +05:45) Kathmandu';
	Timezone_Names[52]								:= '(GMT +06:00) Almaty';
	Timezone_Names[53]								:= '(GMT +06:00) Novosibirsk';
	Timezone_Names[54]								:= '(GMT +06:00) Astana, Dhaka';
	Timezone_Names[55]								:= '(GMT +06:00) Sri Jayawardenpura';
	Timezone_Names[56]								:= '(GMT +06:30) Rangoon';
	Timezone_Names[57]								:= '(GMT +07:00) Bangkok, Hanoi, Jakarta';
	Timezone_Names[58]								:= '(GMT +07:00) Krasnoyarsk';
	Timezone_Names[59]								:= '(GMT +08:00) Peking, Chongqing, Hong Kong, Urumqi';
	Timezone_Names[60]								:= '(GMT +08:00) Irkutsk, Ulaan Bataar';
	Timezone_Names[61]								:= '(GMT +08:00) Perth';
	Timezone_Names[62]								:= '(GMT +08:00) Kuala Lumpur, Singapore';
	Timezone_Names[63]								:= '(GMT +08:00) Taipei';
	Timezone_Names[64]								:= '(GMT +09:00) Osaka, Sapporo, Tokyo';
	Timezone_Names[65]								:= '(GMT +09:00) Seoul';
	Timezone_Names[66]								:= '(GMT +09:00) Yakutsk';
	Timezone_Names[67]								:= '(GMT +09:30) Adelaide; Darwin';
	Timezone_Names[68]								:= '(GMT +10:00) Vladivostok';
	Timezone_Names[69]								:= '(GMT +10:00) Brisbane';
	Timezone_Names[70]								:= '(GMT +10:00) Canberra, Melbourne, Sydney';
	Timezone_Names[71]								:= '(GMT +10:00) Guam, Port Moresby';
	Timezone_Names[72]								:= '(GMT +10:00) Hobart';
	Timezone_Names[73]								:= '(GMT +11:00) Magadan, Solomon Is., New Caledonia';
	Timezone_Names[74]								:= '(GMT +12:00) Auckland, Wellington';
	Timezone_Names[75]								:= '(GMT +12:00) Fiji, Kamchatka, Marshall Is.';
	Timezone_Names[76]								:= '(GMT +13:00) Nuku alofa';
	
END_ACTION
