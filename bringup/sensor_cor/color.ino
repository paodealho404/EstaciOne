#include "Adafruit_TCS34725.h"
#include <Wire.h>
typedef struct _ColorSensor {
  float oldRed;
  float oldGreen;
  float oldBlue;
  float red;
  float green;
  float blue;
  float mean_red;
  float mean_blue;
  float mean_green;

} ColorSensor;

Adafruit_TCS34725 tcs =
    Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_240MS, TCS34725_GAIN_1X);

ColorSensor colorRead = {0};
#define RED 3
#define GREEN 5
#define BLUE 6
#define CASE_RED 0
#define CASE_GREEN 1
#define CASE_BLUE 2
#define UNKNOWN 3

uint8_t case_cor = UNKNOWN;
void setup() {
  Serial.begin(9600);
  pinMode(RED, OUTPUT);
  pinMode(GREEN, OUTPUT);
  pinMode(BLUE, OUTPUT);
  for (int i = 0; i < 10; i++) {
    tcs.getRGB(&colorRead.red, &colorRead.green, &colorRead.blue);
    colorRead.mean_red += colorRead.red;
    colorRead.mean_green += colorRead.green;
    colorRead.mean_blue += colorRead.blue;
  }

  colorRead.mean_red /= 10;
  colorRead.mean_green /= 10;
  colorRead.mean_blue /= 10;
}
void loop() {
  if (tcs.begin()) {
    Serial.println("Found sense");
    delay(10);
    tcs.getRGB(&colorRead.red, &colorRead.green, &colorRead.blue);
    Serial.println("R: " + String(colorRead.red) + " G: " +
                   String(colorRead.green) + " B: " + String(colorRead.blue));
    
    float delta_red = colorRead.red - colorRead.mean_red;
    float delta_green = colorRead.green - colorRead.mean_green;
    float delta_blue = colorRead.blue - colorRead.mean_blue;
    Serial.println("R: "+String(delta_red));
    Serial.println("G: "+String(delta_green));
    Serial.println("B: "+String(delta_blue));
    if ((abs(delta_red) >= 2) || (abs(delta_green) >= 2) ||
        (abs(delta_blue) >= 2)) {
      if (delta_green > delta_blue && delta_green > delta_red) {
        case_cor = CASE_GREEN;
        analogWrite(RED, 255);
        analogWrite(BLUE, 255);
        analogWrite(GREEN, 255 - round(1.25 * colorSensor.green));
      } else if (delta_blue > delta_green &&
                 delta_blue > delta_red) {
        case_cor = CASE_BLUE;
        analogWrite(RED, 255);
        analogWrite(BLUE, 255 - round(1.25 * colorSensor.blue));
        analogWrite(GREEN, 255);
      } else if (delta_red > delta_green &&
                 delta_red > delta_blue) {
        case_cor = CASE_RED;
        analogWrite(RED, 255 - round(1.25 * colorSensor.red));
        analogWrite(BLUE, 255);
        analogWrite(GREEN, 255);
      }
    } else {

      switch (case_cor) {
      case CASE_RED:
        analogWrite(RED, 255 - round(1.25 * colorSensor.red));
        analogWrite(BLUE, 255);
        analogWrite(GREEN, 255);
        break;
      case CASE_BLUE:
        analogWrite(BLUE, 255 - round(1.25 * colorSensor.blue));
        analogWrite(GREEN, 255);
        analogWrite(RED, 255);
        break;
      case CASE_GREEN:
        analogWrite(RED, 255);
        analogWrite(BLUE, 255);
        analogWrite(GREEN, 255 - round(1.25 * colorSensor.green));
        break;
      case UNKNOWN:
        analogWrite(RED, 255 - round(1.25 * colorSensor.red));
        analogWrite(BLUE, 255 - round(1.25* colorSensor.blue));
        analogWrite(GREEN, 255 - round(1.25* colorSensor.green));
      }
    }

  } else
    Serial.println("No TCS34725 found ... check your connections");
  delay(20);
}