/*****************************************************************
 This code for reading data form the gas board and sending to the 
 receiver.
                
*****************************************************************/

// Declaring and initializing a variable for the ADC reading
int sensorReading = 0;
// Declaring and initializing a variable for the converted temperature
float temperature = 0.0;
// Declaring and initializing a variable for CO
float co = 0.0;
// Declaring and initializing a variable for humidity
float humidity =0.0;

packetXBee* dataPacket;
 //Channel 14
uint8_t channel = 0x0E;
//PAN ID 
uint8_t pan[2] = {0x06, 0x16}; 
char data[3];


 
void setup()
{
   // Initializing the XBee communication settings
  xbee802.init(XBEE_802_15_4,FREQ2_4G,NORMAL); 
  // Powering and opening a connection to the XBee module
  xbee802.ON();
  // Define the transmitters own network address (16 bit)
  xbee802.setOwnNetAddress(0x12,0x34);
   // Setting frequency channel
  xbee802.setChannel(channel);
  // Setting PAN ID
  xbee802.setPAN(pan);
   // Disable encryption
  xbee802.encryptionMode(0);
  // Save the values
  // This is important to have the new configuration available even after
  // power was removed from the board
  xbee802.writeValues();
  
  // Initializing the RTC
  RTC.ON();
  // Set the current time
  RTC.setTime("11:05:08:07:14:49:00");
  // Power the sensor board
  SensorEvent.setBoardMode(SENS_ON);
  
  // Give the sensors some time to warm up
  delay(100);
  
}

void loop()
{
  int tmp = 0;
  int co1 = 0;
  int hum = 0;
  
  
  // Read the ADC value of the temperature sensor
  sensorReading = analogRead(ANALOG1);
  // Conversion of the analog reading into temperature
  temperature = ((sensorReading*3.3/1023)-0.5)*100;
  //cover float to int
  tmp = (int)temperature;
 // Read the ADC value of the CO sensor
  co = analogRead(SENS_SOCKET3B);
  //cover float to int
  co1 = (int)co;
  // Read the ADC value of the humidity sensor
  humidity = analogRead(ANALOG4);
  //cover float to int
  hum = (int)((humidity*5000/1023 )- 800)/31;
  data[0] = (char)tmp;
  data[1] = (char)co1;
  data[2] = (char)hum;

  // Set packet parameters
  // Allocate memory for the data packet
  dataPacket=(packetXBee*) calloc(1,sizeof(packetXBee));
  // Send the message to one specific node only
  dataPacket->mode=UNICAST;
  // Give the data packet a number
  dataPacket->packetID=0x01;
  // No options
  dataPacket->opt=0;
  
   // Give the user some feedback
  XBee.println("Packet Initialized");
  
  // Use the defined short address as the origin address
  xbee802.setOriginParams(dataPacket, "1234", MY_TYPE);
  // Use the receivers MAC address as destination indicator
  xbee802.setDestinationParams(dataPacket, "0013A20040693768", data, MAC_TYPE, DATA_ABSOLUTE);
  
  // Send the packet
  xbee802.sendXBee(dataPacket);
  
  // Give again some feedback
  XBee.println("Packet Sent");
  XBee.println(tmp);
  XBee.println(co1);
  XBee.println(hum);
  for(int i =0;i<3;i++){
  XBee.println(int(data[i]));
  }
 
  // Free the memory for the packet again
  free(dataPacket); 
  dataPacket=NULL;
  
 
  
  delay(10000);
  // Go to sleep for one hour
//  PWR.deepSleep("00:00:00:10",RTC_OFFSET,RTC_ALM1_MODE2,ALL_OFF);
  
}

