void setup()
{
  // Inits the XBee 802.15.4 library
  xbee802.init(XBEE_802_15_4,FREQ2_4G,NORMAL);  
  // Powers XBee
  xbee802.ON();
  // Check the MAC address of the attached XBee
  // Results in saving in source variables
  xbee802.getOwnMac();
  // Print the MAC address on the screen (byte for byte)
  XBee.println("XBee's MAC address:");
  for(int j=0;j<4;j++)
  {
    if(xbee802.sourceMacHigh[j]!=0)
    {
      XBee.print(xbee802.sourceMacHigh[j],16);
    }
    else
    {
      XBee.print("00");
    }
  }
  for(int i=0;i<4;i++)
  {
    if(xbee802.sourceMacLow[i]!=0)
    {
      XBee.print(xbee802.sourceMacLow[i],16);
    }
    else
    {
      XBee.print("00");
    }
  }
}

void loop()
{
  // Do nothing
}

