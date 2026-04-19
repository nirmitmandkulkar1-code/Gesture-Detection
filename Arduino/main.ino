#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <SoftwareSerial.h>
#include <DFRobotDFPlayerMini.h>

// LCD
LiquidCrystal_I2C lcd(0x27, 16, 2);

// DFPlayer
SoftwareSerial mySerial(2, 3);
DFRobotDFPlayerMini myDFPlayer;

// Thresholds
int t1 = 910;   
int t2 = 926;
int t3 = 865;
int t4 = 914;

void setup() {
  Serial.begin(9600);
  mySerial.begin(9600);

  lcd.init();
  lcd.backlight();
  lcd.print("System Start");
  delay(1500);
  lcd.clear();

  if (!myDFPlayer.begin(mySerial)) {
    lcd.print("DF Error");
    while (true);
  }

  myDFPlayer.volume(25);
}

void loop() {
  int s1 = analogRead(A0);  
  int s2 = analogRead(A1);
  int s3 = analogRead(A2);
  int s4 = analogRead(A3);

  Serial.print("S1: "); Serial.print(s1);
  Serial.print(" | S2: "); Serial.print(s2);
  Serial.print(" | S3: "); Serial.print(s3);
  Serial.print(" | S4: "); Serial.println(s4);

  // -------- SENSOR 1 --------
  if (s1 > t1) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Finger 1");
    lcd.setCursor(0, 1);
    lcd.print("NEED WATER");

    myDFPlayer.play(1); // 0001.mp3
    delay(2000);
  }

  // -------- SENSOR 2 --------
  else if (s2 > t2) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Finger 2");
    lcd.setCursor(0, 1);
    lcd.print("PAIN ALERT");

    myDFPlayer.play(2); // 0002.mp3
    delay(2000);
  }

  // -------- SENSOR 3 --------
  else if (s3 > t3) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Finger 3");
    lcd.setCursor(0, 1);
    lcd.print("NEED ASSISTANCE");

    myDFPlayer.play(3); // 0003.mp3
    delay(2000);
  }

  // -------- SENSOR 4 --------
  else if (s4 > t4) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Finger 4");
    lcd.setCursor(0, 1);
    lcd.print("WANT TO GO WASHROOM");

    myDFPlayer.play(4); // 0004.mp3
    delay(2000);
  }

  else {
    lcd.setCursor(0, 0);
    lcd.print("Waiting...     ");
  }

  delay(200);
}
