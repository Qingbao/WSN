/*****************************************************************
  This  receiver for receive data and creat text file to SD card.

  Implementation: Qingbao Guo, 2011

  Description:  Setting frequency channel, PAN-ID, Security,SD card
                
*****************************************************************/
 //Channel 14
uint8_t channel = 0x0E;
//PAN ID 
uint8_t pan[2] = {0x06, 0x16}; 
//store MAC address
int sourceADD[8];
//store receive data
char recData[3]; 
//store upload data
char upload[20];
//get time;
char* time = "";

void setup()
{
  USB.begin();
  RTC.ON();
  RTC.setTime("11:04:05:05:12:15:00");
  
  // Connect the SD card
  SD.ON(); // Set SD ON
   if(SD.isSD())
  {  
    if(SD.del("WSN"))  USB.println("Folder deleted");  
    else  USB.println("Error deleting folder");
    
    if(SD.mkdir("WSN"))  USB.println("Folder created");
    else  USB.println("Error creating folder");
    
    if(SD.cd("WSN"))  USB.println("Entered Folder");
    else  USB.println("Error changing directory");
    
    if(SD.create("upload.txt"))  USB.println("File created");
    else  USB.println("Error creating file");
  }
  else
  {
    USB.println("No SD card present");
  }



  // Init the XBEE module
  xbee802.init(XBEE_802_15_4,FREQ2_4G,NORMAL);
  // Powers XBee
  xbee802.ON();
  // Define the Network Address
  xbee802.setOwnNetAddress(0x12,0x34);
  
  // Setting frequency channel
  xbee802.setChannel(channel);
  if( !xbee802.error_AT )
  {
    XBee.print("Channel set to: ");
    XBee.println(channel, HEX);
  }
  else XBee.println("Error while setting channel");
  
  // Setting PAN ID
  xbee802.setPAN(pan);
  if( !xbee802.error_AT )
  {
    XBee.print("PANID set to: ");
    XBee.println((pan[0]<<8)|pan[1],HEX);
  }
  else XBee.println("Error while changing PANID");  
  
  // Disable encryption
  xbee802.encryptionMode(0);
  if( !xbee802.error_AT ) XBee.println("Encryption disabled");
  else XBee.println("Error while disabling security");   
  
  // Save the values
  // This is important to have the new configuration available even after
  // power was removed from the board
  xbee802.writeValues();
  if( !xbee802.error_AT ) XBee.println("Configuration saved");
  else XBee.println("Error while saving configuration");  
}

void loop()
{
  // Check for the reception of a new packet
  if( XBee.available() )
  {
    // Treat the data that is available
    xbee802.treatData();
    // Check if there were any errors
    if( !xbee802.error_RX )
    {
      // Writing the parameters of the packet received
      while(xbee802.pos>0)
      {
        XBee.print("MAC Address Source: ");         
        for(int b=0;b<4;b++)
          {
            XBee.print(xbee802.packet_finished[xbee802.pos-1]->macSH[b],HEX);
            sourceADD[b] = xbee802.packet_finished[xbee802.pos-1]->macSH[b];
          }
          for(int c=0;c<4;c++)
          {
            XBee.print(xbee802.packet_finished[xbee802.pos-1]->macSL[c],HEX);
            sourceADD[c+4] = xbee802.packet_finished[xbee802.pos-1]->macSL[c];
          }
        XBee.println();
        
        recData [0] |= (uint8_t)xbee802.packet_finished[xbee802.pos-1]->data[0];
        recData [1] |= (uint8_t)xbee802.packet_finished[xbee802.pos-1]->data[1];
        recData [2] |= (uint8_t)xbee802.packet_finished[xbee802.pos-1]->data[2];
        
        time = RTC.getTime();
        
        sprintf(upload,"%X%X%X%X%X%X%X%X;%d;%d;%d;%s", sourceADD[0],sourceADD[1],sourceADD[2],sourceADD[3],sourceADD[4],
                                      sourceADD[5],sourceADD[6],sourceADD[7],recData[0],recData[1],recData[2],time);
        USB.println(upload);
        
        if(SD.appendln("upload.txt",upload))
        {  
          USB.println("Data written");}
        else{
          USB.println("error");
        
        }
       
        
       // Delete the treated oacket
        free(xbee802.packet_finished[xbee802.pos-1]);
        xbee802.packet_finished[xbee802.pos-1]=NULL;
        // Reduce the position counter by one
        xbee802.pos--;
   
         
         
      }
    }
    else
    {
      // If we should get a transmission error, show that on the screen
      XBee.println("Transmission error");
      XBee.println("");
    }
  } 
}
