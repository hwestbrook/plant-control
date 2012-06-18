/*
this code does a number of thigs with two major goals:
  1. turn a pump on and off
  2. read the temperature and display it via a servo
 
 */

#include <DHT22.h> // include the temperature library
#include <Servo.h> // include the servo library

// Data wire is plugged into port 7 on the Arduino
// Connect a 4.7K resistor between VCC and the data pin (strong pullup)
#define DHT22_PIN 7

// Setup a DHT22 instance
DHT22 myDHT22(DHT22_PIN);

// create Servo Object
Servo myservo; // servo object

int sensorPin = A0;    // select the input pin for the potentiometer
int ledPin = 13;      // select the pin for the LED
int powerPin = 11;      // select the pin for the power tail
long sensorValue = 0;  // variable to store the value coming from the sensor
long timeMultiple = 200; // variable to slow the blinking see google doc for spreadsheet, 6000 should be 15 min at 150
long timeValue = 0;    // the time value the program will stop for
int servoVal = 0;  // variable to store servo position

void setup() {
  // declare the ledPin as an OUTPUT:
  pinMode(ledPin, OUTPUT);  

  // declare the powerPin as an OUTPUT:
  pinMode(powerPin, OUTPUT);  
  
  // open serial for testing
  Serial.begin(9600); // open serial at 9600 bps
  
  // attach servo to pin 9
  myservo.attach(9);
}

void loop() {

  // XXXXXXXXXXXXXXXXXXXXXX below is all related to temp and humidity
  DHT22_ERROR_t errorCode;

  delay(2000);
  Serial.print("Requesting data...");
  errorCode = myDHT22.readData();
  switch(errorCode)
  {
    case DHT_ERROR_NONE:
      Serial.print("Got Data ");
      Serial.print(myDHT22.getTemperatureC()*1.8+32);
      Serial.print("F ");
      Serial.print(myDHT22.getHumidity());
      Serial.println("%");
      
      // servo controls
      servoVal = myDHT22.getTemperatureC();     // reads the temp (value between -40 C and 80 C) 
      servoVal = map(servoVal, 0, 44, 0, 179);  // scale it to use it with the servo (value between 0 and 180) 
      // Serial.print(servoVal);                // debug
      myservo.write(servoVal);                  // sets the servo position according to the scaled value 
      delay(15);  
      
      break;
    case DHT_ERROR_CHECKSUM:
      Serial.print("check sum error ");
      Serial.print(myDHT22.getTemperatureC()*1.8+32);
      Serial.print("F ");
      Serial.print(myDHT22.getHumidity());
      Serial.println("%");
      break;
    case DHT_BUS_HUNG:
      Serial.println("BUS Hung ");
      break;
    case DHT_ERROR_NOT_PRESENT:
      Serial.println("Not Present ");
      break;
    case DHT_ERROR_ACK_TOO_LONG:
      Serial.println("ACK time out ");
      break;
    case DHT_ERROR_SYNC_TIMEOUT:
      Serial.println("Sync Timeout ");
      break;
    case DHT_ERROR_DATA_TIMEOUT:
      Serial.println("Data Timeout ");
      break;
    case DHT_ERROR_TOOQUICK:
      Serial.println("Polled to quick ");
      break;
  }
  // XXXXXXXXXXXXXXXXXXXXXX above is related to temp and humidity
  
  // ZZZZZZZZZZZZZZZZZZZZZZ below is related to powerswitch 
  // read the value from the sensor:
  sensorValue = analogRead(sensorPin);
  
  // print to serial to follow amount of time; this is for testing only
  Serial.print("Time Value (ms): ");
  Serial.print(sensorValue * timeMultiple);
  Serial.println(" "); 
  
  // if the sensor shows less than 100 delay between on and off, lets leave on
  if(sensorValue < 100) { 
    
    // turn the ledPin and powerPin on:
    digitalWrite(ledPin, HIGH);  
    digitalWrite(powerPin, HIGH);
    
  }
  
  else {
    // turn the ledPin and powerPin on:
    digitalWrite(ledPin, HIGH);  
    digitalWrite(powerPin, HIGH);
    
    // stop the program for 10 seconds ( 10,000 milliseconds):
    delay(10000);          
    
    // turn the ledPin and powerPin off:        
    digitalWrite(ledPin, LOW);   
    digitalWrite(powerPin, LOW);  
    
    // stop the program for for <timeValue> milliseconds:
    delay(sensorValue * timeMultiple);
  }    
  // ZZZZZZZZZZZZZZZZZZZZZZ above is related to powerswitch 
}
