#include <LiquidCrystal_I2C.h>
LiquidCrystal_I2C lcd(0x27, 16, 2);

#include "SoftwareSerial.h"
#include "DFRobotDFPlayerMini.h"

SoftwareSerial mySoftwareSerial(2, 3);  // RX, TX
DFRobotDFPlayerMini myDFPlayer;

unsigned int f;
unsigned int f1;
unsigned int f2;
unsigned int f3;   // Fourth sensor

void setup() {
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("Sign Language to");
  lcd.setCursor(0, 1);
  lcd.print("Speech Convert");
  delay(6000);
  lcd.clear();

  Serial.begin(115200);
  // Serial.begin(9600);
  mySoftwareSerial.begin(9600);

  Serial.println();
  Serial.println(F("Initializing DFPlayer..."));

  if (!myDFPlayer.begin(mySoftwareSerial)) {
    Serial.println(F("Unable to begin"));
    while (true);
  }

  Serial.println(F("DFPlayer Mini online."));
  myDFPlayer.volume(30);
}

void loop() {

  f = analogRead(A0);
  f1 = analogRead(A1);
  f2 = analogRead(A2);
  f3 = analogRead(A3);   

  // Add this inside your loop() to send data to the Flutter App
Serial.print("S1:"); Serial.print(f); 
Serial.print(",S2:"); Serial.print(f1);
Serial.print(",S3:"); Serial.print(f2);
Serial.print(",S4:"); Serial.println(f3);

  // Sensor 1
  if (f > 310) {

    Serial.println("I Am Hungry");
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Cmd 1");
    lcd.setCursor(0, 1);
    lcd.print("I Am Hungry");
    myDFPlayer.play(1);
    delay(1000);

  } 
  else if (f < 250) {

    Serial.println("Help Me To reach Home");
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Cmd 2");
    lcd.setCursor(0, 1);
    lcd.print("Help Me To reach Hom");
    myDFPlayer.play(2);
    delay(1000);

  } 
  else {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("No Sign Language");
  }

  // Sensor 2
  if (f1 > 309) {

    Serial.println("Call The Police");
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Cmd 3");
    lcd.setCursor(0, 1);
    lcd.print("Call The Police");
    myDFPlayer.play(3);
    delay(1000);

  } 
  else if (f1 < 270) {

    Serial.println("I Need Help");
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Cmd 4");
    lcd.setCursor(0, 1);
    lcd.print("I Need Help");
    myDFPlayer.play(4);
    delay(1000);

  } 
  else {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("No Sign Language");
  }

  // Sensor 3
  if (f2 > 250) {

    Serial.println("I Need Water");
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Cmd 5");
    lcd.setCursor(0, 1);
    lcd.print("I Need Water");
    myDFPlayer.play(5);
    delay(1000);

  } 
  else if (f2 < 225) {

    Serial.println("Call The Ambulance");
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Cmd 6");
    lcd.setCursor(0, 1);
    lcd.print("Call The Ambulance");
    myDFPlayer.play(6);
    delay(1000);

  } 
  else {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("No Sign Language");
  }

  // Sensor 4 (NEW)
  if (f3 > 300) {

    Serial.println("Thank You");
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Cmd 7");
    lcd.setCursor(0, 1);
    lcd.print("Thank You");
    myDFPlayer.play(7);
    delay(1000);

  } 
  else if (f3 < 250) {

    Serial.println("Good Morning");
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Cmd 8");
    lcd.setCursor(0, 1);
    lcd.print("Good Morning");
    myDFPlayer.play(8);
    delay(1000);

  } 
  else {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("No Sign Language");
  }

  delay(200);
}
