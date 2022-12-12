#include <HCSR04.h>

// C++ code
#include <Servo.h>
#include <Ultrasonic.h>
#include <LiquidCrystal_I2C.h>

#define sensor1TriggerPin 2
#define sensor1EchoPin 3

#define sensor2TriggerPin 4
#define sensor2EchoPin 5

#define sensor3TriggerPin 6
#define sensor3EchoPin 7

#define sensor4TriggerPin 8
#define sensor4EchoPin 9

#define insideButtonPin 13
#define outsideButtonPin 12

#define angClose 90
#define angOpen 20
#define servoPin 11

Servo servo;
int currentAngleServo = angClose;
int sensorDebug = 1;


class ParkingSpace {
   public:
    int sensorId;
    float gateDistance;
    String name;
    String path;

    ParkingSpace(int sensorId, float gateDistance, String name, String path) {
      this->sensorId = sensorId;
      this->gateDistance = gateDistance;
      this->name = name;
      this->path = path;
    };
};

LiquidCrystal_I2C lcd(0x27, 16, 2);
UltraSonicDistanceSensor ultrasonic1(sensor1TriggerPin, sensor1EchoPin);
UltraSonicDistanceSensor ultrasonic2(sensor2TriggerPin, sensor2EchoPin);
UltraSonicDistanceSensor ultrasonic3(sensor3TriggerPin, sensor3EchoPin);
UltraSonicDistanceSensor ultrasonic4(sensor4TriggerPin, sensor4EchoPin);



UltraSonicDistanceSensor sensors[4] = {ultrasonic1, ultrasonic2, ultrasonic3, ultrasonic4};

ParkingSpace parkingSpaces[4] = { 
 ParkingSpace(0, 3, "B4", "S4RGBRE"),
 ParkingSpace(1, 4, "B1", "S5RGBGRE"), 
 ParkingSpace(2, 2, "A1", "S3RBRE"), 
 ParkingSpace(3, 1, "A2", "S6RBGBGRE")  
};

void clearRowLcd(int row) {
  lcd.setCursor(0, row);
  lcd.print("                ");
}

void moveGate(int moviment){
    int end;
    int inc;

    if(moviment == 0) {
      end = angClose;
      inc = 2;
    } else if(moviment == 1) {
      end = angOpen;
      inc = -2;
    }

    while(currentAngleServo!=end){
      currentAngleServo += inc;
      servo.write(currentAngleServo);
      delay(25);
    }
}

int freeParkingSpace(UltraSonicDistanceSensor ultrasonic) {
  float cmMsec = ultrasonic.measureDistanceCm();

  return cmMsec > 10;
}

ParkingSpace getBestParkingSpace() {
  float bestDistance = 100;
  int bestParkingSpace = 0;
  for(int i = 0; i < 4; i++) {
    float distance = parkingSpaces[i].gateDistance;
    int sensorId = parkingSpaces[i].sensorId;

    if(freeParkingSpace(sensors[sensorId])) {
      if(distance < bestDistance) {
        bestDistance = distance;
        bestParkingSpace = i;
      }
    }
  }
  Serial.println((String)parkingSpaces[bestParkingSpace].name + (String)parkingSpaces[bestParkingSpace].sensorId + (String)parkingSpaces[bestParkingSpace].gateDistance);
  return parkingSpaces[bestParkingSpace];
}

void openGate(int timeToCLose = 5000){
  moveGate(1);
  delay(timeToCLose);
  moveGate(0);
}

void openGateButtonPressed(String button){
  delay(500);
  if(button == "outside") {
    lcd.setCursor(0, 1);
    ParkingSpace bestSpot = getBestParkingSpace();
    lcd.print(bestSpot.name + " " + (String)bestSpot.gateDistance + " " + (String)bestSpot.path);
    openGate();
    clearRowLcd(1);
  } else if(button == "inside") {
    openGate();
  }
}

//void sendParkingStringToSerial(String parkingStrin)

void setup()
{


  Serial.begin(9600);
  pinMode(insideButtonPin, INPUT);
  pinMode(outsideButtonPin, INPUT);
  servo.attach(servoPin);
  servo.write(90);
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("EstaciOne");
  
  
}
void loop()
{     
    int openGateOutsideButton = digitalRead(outsideButtonPin);
    int openGateInsideButton = digitalRead(insideButtonPin);
    if(openGateOutsideButton) {
      openGateButtonPressed("outside");
    } else if(openGateInsideButton) {
      openGateButtonPressed("inside");
    }

    if(Serial.available()){
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("Serial: " + Serial.readString());
      Serial.flush();
    }
    
    float distance1 = ultrasonic1.measureDistanceCm();
    float distance2 = ultrasonic2.measureDistanceCm();
    float distance3 = ultrasonic3.measureDistanceCm();
    float distance4 = ultrasonic4.measureDistanceCm();
    Serial.println("Sensor 1 - B4: " + (String)distance1 + " cm");
    Serial.println("Sensor 2 - B1: " + (String)distance2 + " cm");
    Serial.println("Sensor 3 - A1: " + (String)distance3 + " cm");
    Serial.println("Sensor 4 - A2: " + (String)distance4 + " cm");
    Serial.println();
    // if(Serial.available()){
    //   sensorDebug = Serial.readString().toInt();
    // }
    // clearRowLcd(1);
    // lcd.setCursor(0, 1);
    // switch(sensorDebug){
    //   case 1:
    //     lcd.print(distance1);
    //     break;
    //   case 2:
    //     lcd.print(distance2);
    //     break;
    //   case 3:
    //     lcd.print(distance3);
    //     break;
    //   case 4:
    //     lcd.print(distance4);
    //     break;  
    // }


    delay(500);
 
}
