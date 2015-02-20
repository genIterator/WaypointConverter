#!/usr/bin/env ruby

####################
# Mission Planner Commands
#
###################
module COMMAND
  WAYPOINT = "16";
  LOITER_UNLIM = "17";
  LOITER_TURNS = "18";
  LOITER_TIME = "19";
  RETURN_TO_LAUNCH = "20";
  LAND = "21";
  TAKEOFF = "22";
  CONDITION_DELAY = "112";
  CONDITION_CHANGE_ALT = "113";
  CONDITION_DISTANCE = "114";
  CONDITION_YAW = "115";
  DO_SET_MODE = "176";
  DO_JUMP = "177";
  DO_CHANGE_SPEED = "178";
  DO_SET_HOME = "179";
  DO_SET_RELAY = "181";
  DO_REPEAT_RELAY = "182";
  DO_SET_SERVO = "183";
  DO_REPEAT_SERVO = "184";
  DO_DIGICAM_CONFIGURE = "202";
  DO_DIGICAM_CONTROL = "203";
  DO_MOUNT_CONFIGURE = "204";
  DO_MOUNT_CONTROL = "205";
  DO_SET_CAM_TRIGG_DIST = "206";
  DO_INVERTED_FLIGHT = "210";
end

####################
# Daten Klasse fuer Wegpunkte
#
###################
class Waypoint

  attr_accessor :pointNumber
  attr_accessor :latitude; #width
  attr_accessor :longitude; #length
  attr_accessor :radius;
  attr_accessor :altitude;
  attr_accessor :climbRate;
  attr_accessor :delayTime;
  attr_accessor :wpEventChannelValue;
  attr_accessor :heading;
  attr_accessor :speed;
  attr_accessor :camNick;
  attr_accessor :type;
  attr_accessor :prefix;
  def initialize (_pointNumber, _latitude, _longitude, _radius, _altitude, _climbRate, _delayTime, _wpEventChannelValue, _heading, _speed, _camNick, _type = "1", _prefix = "P")
    @pointNumber =  _pointNumber;
    @latitude = _latitude;
    @longitude = _longitude;
    @radius = _radius;
    @altitude = _altitude;
    @climbRate = _climbRate;
    @delayTime = delayTime;
    @wpEventChannelValue = _wpEventChannelValue;
    @heading = _heading;
    @speed = _speed;
    @camNick = _camNick;
    @type = _type;
    @prefix = _prefix;
  end

end

####################
# Daten einlesen welche im Mission Planner.txt nicht vorkommen
#
###################
def readWaypointInputData(readRadius, readClimbRate, readDelay, readWPEvent, readHeading, readSpeed, readCamNick, wayPointInputData)
  # 0 = radius, 1 = climbrate, 2 = delayTime, 3 = wp event channel value, 4 = heading, 5 = speed, 6 = cam-nick
  temp = "0";
  weiter = false

  puts "Nicht vorhandene Mission Planner Daten müssen eingegeben werden. Diese Werte gelten für alle Wegpunkte! "
  if (readRadius)
    #Radius
    puts "Wegpunkt-Radius [m] eingeben: "
    while !weiter do
      temp = STDIN.gets();
      temp = temp.chomp();
      if (temp.to_i() >= 1 && temp.to_i() <= 20) #Radius above 20m seems unpropitious
        wayPointInputData[0] = temp;
        weiter = true;
      else
        puts "Der Radius sollte zwischen 1 m und 20 m liegen: ";
        weiter = false;
      end
    end #while
    weiter = false
  end
  if (readClimbRate)
    #climbRate
    puts "Steigrate [0.1m/s] eingeben: "
    while !weiter do
      temp = STDIN.gets();
      temp = temp.chomp();
      if (temp.to_i() >= 1 && temp.to_i() <= 100) #climbrate above 10m/s not recommended
        wayPointInputData[1] = temp;
        weiter = true;
      else
        puts "Die Steigrate sollte zwischen 1 *0.1m/s  und 100 *0.1m/s liegen: ";
        weiter = false;
      end
    end #while
    weiter = false
  end
  if (readDelay)
    #DelayTime
    puts "Wartezeit am Wegpunkt eingeben [s]: "
    while !weiter do
      temp = STDIN.gets();
      temp = temp.chomp();
      if (temp.to_i() >= 0 && temp.to_i() <= 30) #delay time above 30s seems unpropitious
        wayPointInputData[2] = temp;
        weiter = true;
      else
        puts "Die Wartezeit am Wegpunkt sollte zwischen 0 s und 30 s liegen: ";
        weiter = false;
      end
    end #while
    weiter = false
  end
  if (readWPEvent)
    #Waypoint Event Channel Value
    puts "Waypoint Event Kanal eingeben (0 bei Flächenaufnahmen ): "
    while !weiter do
      temp = STDIN.gets();
      temp = temp.chomp();
      if (temp.to_i() >= 0)
        wayPointInputData[3] = temp;
        weiter = true;
      else
        puts "Der Waypoint Event Kanal sollte mindestens 0 sein: ";
        weiter = false;
      end
    end #while
    weiter = false
  end
  if (readHeading)
    #heading
    puts "Blickrichtung eingeben [°]: "
    while !weiter do
      temp = STDIN.gets();
      temp = temp.chomp();
      if (temp.to_i() >= 1 && temp.to_i() <= 360)
        wayPointInputData[4] = temp;
        weiter = true;
      else
        puts "Die Blickrichtung sollte zwischen 1° und 360° betragen: ";
        weiter = false;
      end
    end #while
    weiter = false
  end
  if (readSpeed)
    #speed
    puts "Fluggeschwindigkeit eingeben [0.1m/s]: "
    while !weiter do
      temp = STDIN.gets();
      temp = temp.chomp();
      if (temp.to_i() >= 1 && temp.to_i() <= 100)
        wayPointInputData[5] = temp;
        weiter = true;
      else
        puts "Die Fluggeschwindigkeit sollte zwischen 1 *0.1m/s und 100 *0.1m/s betragen: ";
        weiter = false;
      end
    end #while
    weiter = false
  end
  if (readCamNick)
    #Cam nick
    puts "Kameraneigung eingeben [°]: "
    while !weiter do
      temp = STDIN.gets();
      temp = temp.chomp();
      if (temp.to_i() >= 0 && temp.to_i() <= 90)
        wayPointInputData[6] = temp;
        weiter = true;
      else
        puts "Die Kameraneigung sollte zwischen 0° und 90° betragen: ";
        weiter = false;
      end
    end #while
    weiter = false
  end
  return wayPointInputData;
end

####################
# .wpl Datei schreiben
#
###################
def createNewWPL(fileName, wayPoints, numberOfWaypoints)
  splittedFileName = [];
  splittedFileName = fileName.split(".");
  fileName = splittedFileName[0] + ".wpl";
  while (File.exists?(fileName)) do
    puts "Ausgabgedatei existiert bereits, bitte einen neuen Namen eingeben: ";
    temp = STDIN.gets();
    temp = temp.chomp();
    fileName = temp + ".wpl";
  end

  outputFile = File.new(fileName, "w+");
  outputFile.puts("[General]");
  outputFile.puts("FileVersion=3");
  outputFile.puts("NumberOfWaypoints="+numberOfWaypoints.to_s());

  wayPoints.each {|wp|
    outputFile.puts("[Point" + wp.pointNumber + "]");
    outputFile.puts("Latitude=" + wp.latitude);
    outputFile.puts("Longitude="+ wp.longitude);
    outputFile.puts("Radius="+ wp.radius);
    outputFile.puts("Altitude=" + wp.altitude);
    outputFile.puts("ClimbRate=" + wp.climbRate);
    outputFile.puts("DelayTime=" + wp.delayTime);
    outputFile.puts("WP_Event_Channel_Value=" + wp.wpEventChannelValue);
    outputFile.puts("Heading=" + wp.heading);
    outputFile.puts("Speed=" + wp.speed);
    outputFile.puts("CAM-Nick=" + wp.camNick);
    outputFile.puts("Type=" + wp.type);
    outputFile.puts("Prefix=" + wp.prefix);
  }
  outputFile.close();
  puts "Datei erstellt."
end

####################
# prints message if altitude is to low or to high
# user input to change value
###################
def printAltitudeWarning(warnMessage, question, altitude, value)
  yesNo = true;
  temp = "k";

  puts warnMessage;
  puts question;
  while yesNo do
    temp = STDIN.gets();
    temp = temp.chomp();
    if (temp == "j")
      altitude = value;
      yesNo = false;
    else
      if (temp == "n")
        yesNo = false;
      else
        puts "Eingabe nicht erkannt, bitte wiederholen: ";
        yesNo = true;
      end
    end
  end #while

  return altitude

end

####################
# Mission Planner Daten einlesen und .wpl Datei erstellen
#
###################
def readMissionPlannerData (fileName)
  numberOfWaypoints = 0;
  cameraTriggerDistance = [];
  currLine = 0;
  wayPointNumber = 0;
  altitude = [];
  wayPointInputData = Array.new(7,""); # 0 = radius, 1 = climbrate, 2 = delayTime, 3 = wp event channel value, 4 = heading, 5 = speed, 6 = cam-nick
  wayPoints = [];
  splittedSpeed = [];
  splittedDelay = [];
  readRadius = true;
  readClimbRate = true;
  readDelay = true;
  readWPEvent = true;
  readHeading = true;
  readSpeed = true;
  readCamNick = true;

  text=File.open(fileName).read;
  text.each_line {|line|
    currLine += 1;
    line = line.chomp();
    wpLine = line.split("\t");
    if (wpLine.length >= 12) #default MP-entries have 12 values
      case wpLine[3]
      when COMMAND::WAYPOINT
        wayPointNumber += 1;
        numberOfWaypoints += 1;
        altitude = wpLine[10].split(".");
        if (altitude[0].to_i() == 0) #  waypoint altitude to low!
          altitude[0] = printAltitudeWarning("Achtung, Flughöhe für Wegpunkt "+wayPointNumber.to_s()+" ist 0 m!", "Soll eine Sicherheitshöhe von 5 m eingetragen werden? (j/n): ", altitude[0], "5");
        else
          if (altitude[0].to_i() > 100) #waypoint altitude to high!
            altitude[0] = printAltitudeWarning("Achtung, Flughöhe für Wegpunkt "+wayPointNumber.to_s()+" ist größer als 100 m!", "Soll die Höhe auf 100 m verringert werden? (j/n): ", altitude[0], "100")
          end
        end #end check valid altitude

        splittedDelay = wpLine[4].split(".");
        if (! splittedDelay[0].eql?("0"))         #check if Delay Time was set
          wayPointInputData[2] = splittedDelay[0];
        end
        #                           _pointNumber,   _latitude, _longitude,       _radius,              _altitude,  _climbRate,           _delayTime,          _wpEventChannelValue,   _heading,           _speed,                 _camNick,           _type, _prefix
        wayPoints.push(Waypoint.new(wayPointNumber.to_s(), wpLine[8], wpLine[9], wayPointInputData[0], altitude[0], wayPointInputData[1], wayPointInputData[2], wayPointInputData[3], wayPointInputData[4], wayPointInputData[5], wayPointInputData[6], "1", "P"));
      when COMMAND::DO_SET_CAM_TRIGG_DIST
        cameraTriggerDistance = wpLine[4].split(".");
        puts "Kamera Trigger Distance muss nach Wegpunkt "+ wayPointNumber.to_s()+" auf "+cameraTriggerDistance[0] +" m gesetzt werden.";
      when COMMAND::DO_CHANGE_SPEED
        tempfloat = (wpLine[5].to_f())*10;
        splittedSpeed = (tempfloat.to_s()).split(".");
        wayPointInputData[5] = splittedSpeed[0];

      else
        puts "Nicht verarbeiteter command in Zeile: "+currLine.to_s();
      end
    end
  }
  if (! wayPointInputData[2].eql?("")) #check if waypoint delay was set
    readDelay = false;
  end
  if (! wayPointInputData[5].eql?("")) #check if waypoint speed was set
    readSpeed = false;
  end
  wayPointInputData = readWaypointInputData(readRadius, readClimbRate, readDelay, readWPEvent, readHeading, readSpeed, readCamNick, wayPointInputData) #get missing data from user input

  #fill empty data
  wayPoints.each{|wp|
    if (wp.radius.eql?("") || (wp.radius == nil))
      wp.radius = wayPointInputData[0];
    end
    if (wp.climbRate.eql?("") || (wp.climbRate == nil))
      wp.climbRate = wayPointInputData[1];
    end
    if (wp.delayTime.eql?("") || (wp.delayTime == nil))
      wp.delayTime = wayPointInputData[2];
    end
    if (wp.wpEventChannelValue.eql?("") || (wp.wpEventChannelValue == nil))
      wp.wpEventChannelValue = wayPointInputData[3];
    end
    if (wp.heading.eql?("") || (wp.heading == nil))
      wp.heading = wayPointInputData[4];
    end
    if (wp.speed.eql?("") || (wp.speed == nil))
      wp.speed = wayPointInputData[5];
    end
    if (wp.camNick.eql?("") || (wp.camNick == nil))
      wp.camNick = wayPointInputData[6];
    end
  }

  #create new .wpl file
  createNewWPL(fileName, wayPoints, numberOfWaypoints);

end

####################
# main Function
#
###################
def run(fileName)
  if (fileName.eql?("/help"))
    puts "Programm zur Konvertierung von Mission Planner Wegepunktlisten in .wpl Dateien fuer das Mikrokopter OSD Tool.\n";
    puts "Verwenden sie WPConv.rb <<Dateiname.txt>> als Parameter.";
    puts "Nur ASCII Zeichen fuer den Dateinamen verwenden."
    puts "Nur eine Kamera Trigger Distance wird unterstützt.";
  else
    if (fileName != nil)
      #check for filename
      if (File.exists?(fileName))
        puts "Datei gefunden, lese Daten..."
        readMissionPlannerData(fileName);
      else
        puts "Datei nicht gefunden. Verwenden sie /help für Hilfe."
      end
    else
      # nichts gefunden
      puts "Keine Parameter gefunden, verwenden sie /help für Hilfe.";
    end
  end
end

#######Run#############

run(ARGV[0]);
#######################
