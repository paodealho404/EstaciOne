#include <HCSR04.h>
#include <Servo.h>
#include <Ultrasonic.h>
#include <LiquidCrystal_I2C.h>

/* Definições Úteis */
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

typedef enum {
  WAITING_ACTION,
  BUTTON_PRESSED,
  RUNNING,
  DONE,
} PARKING_STATE;

Servo servo;

LiquidCrystal_I2C lcd(0x27, 16, 2);

UltraSonicDistanceSensor ultrasonic1(sensor1TriggerPin, sensor1EchoPin);
UltraSonicDistanceSensor ultrasonic2(sensor2TriggerPin, sensor2EchoPin);
UltraSonicDistanceSensor ultrasonic3(sensor3TriggerPin, sensor3EchoPin);
UltraSonicDistanceSensor ultrasonic4(sensor4TriggerPin, sensor4EchoPin);

UltraSonicDistanceSensor sensors[4] = {ultrasonic1, ultrasonic2, ultrasonic3, ultrasonic4};

PARKING_STATE state = WAITING_ACTION;

String buttonPressed = "inside";
int currentAngleServo = angClose;
int parkingSpacesCount = -1;

class ParkingSpace {
   public:
    int sensorId;
    float gateDistance;
    String name;
    String path;
    bool isFree;
    int timeTo;

    ParkingSpace(int sensorId, float gateDistance, String name, String path) {
      this->sensorId = sensorId;
      this->gateDistance = gateDistance;
      this->name = name;
      this->path = path;
      this->isFree = true;
    };
};

ParkingSpace bestSpot = ParkingSpace(-1, -1, "Nenhuma vaga", "Nenhuma vaga");
ParkingSpace parkingSpaces[4] = { 
 ParkingSpace(0, 3, "B4", "S7RGRBRBGE"),
 ParkingSpace(1, 4, "B1", "S4RGRGE"), 
 ParkingSpace(2, 2, "A1", "S3RBGE"), 
 ParkingSpace(3, 1, "A2", "S4RBRGE")  
};

void waiting_action_exec();
void button_pressed_exec();
void running_exec();
void done_exec();
void clearRowLcd(int row);
void moveGate(int moviment);
float getMean(float array[], int size);
float getSensorDistance(UltraSonicDistanceSensor sensor);
int freeParkingSpace(UltraSonicDistanceSensor ultrasonic);
ParkingSpace getBestParkingSpace();
void openGate(int timeToCLose);
void openGateButtonPressed(String button);
void updateParkingSpacesNumber();
void countParkingSpaces();

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
    bestSpot = getBestParkingSpace();
    if(bestSpot.sensorId != -1){
      Serial.println(bestSpot.path);
    }
    countParkingSpaces();
    
    switch(state){
      case WAITING_ACTION:
        waiting_action_exec();
        break;
      case BUTTON_PRESSED:
        button_pressed_exec();
        break;
      case RUNNING:
        running_exec();
        break;
      case DONE:
        done_exec();
        break;
    }
    
    

    // float distance1 = getSensorDistance(ultrasonic1);
    // float distance2 = getSensorDistance(ultrasonic2);
    // float distance3 = getSensorDistance(ultrasonic3);
    // float distance4 = getSensorDistance(ultrasonic4);
    // Serial.println("Sensor 1 - B4: " + (String)distance1 + " cm");
    // Serial.println("Sensor 2 - B1: " + (String)distance2 + " cm");
    // Serial.println("Sensor 3 - A1: " + (String)distance3 + " cm");
    // Serial.println("Sensor 4 - A2: " + (String)distance4 + " cm");
    // Serial.println();

    delay(500);
 
}

void waiting_action_exec(){
  int openGateOutsideButton = digitalRead(outsideButtonPin);
  int openGateInsideButton = digitalRead(insideButtonPin);

  if(openGateOutsideButton) {
    buttonPressed = "outside";
    state = BUTTON_PRESSED;
  } else if(openGateInsideButton) {
    buttonPressed = "inside";
    state = BUTTON_PRESSED;
  }
}

void button_pressed_exec() {
  openGateButtonPressed(buttonPressed);
  if(buttonPressed == "outside"){
    state = RUNNING;
  } else {
    state = DONE;
  }
}

void running_exec() {
  if(bestSpot.sensorId != -1) {
    UltraSonicDistanceSensor bestSpotSensor = sensors[bestSpot.sensorId];

    if(!freeParkingSpace(bestSpotSensor)) {
      Serial.println("A vaga " + bestSpot.name + " foi ocupada!");
      state = DONE;
    }
  } else {
    state = DONE;
  }
}

void done_exec(){
  state = WAITING_ACTION;
}

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


float getMean(float array[], int size) {
  float sum = 0;
  float max = array[0];
  float min = array[0];
  for(int i = 0; i < size; i++) {
    sum += array[i];
    if(array[i] > max) {
      max = array[i];
    }
    if(array[i] < min) {
      min = array[i];
    }
  }
  return (sum - max - min) / (size - 2);
}

float getSensorDistance(UltraSonicDistanceSensor sensor) {
  float measures[10];
  for(int i = 0;i < 10; i++) {
    measures[i] = sensor.measureDistanceCm();
  }

  int n = sizeof(measures) / sizeof(measures[0]);

  float mean = getMean(measures, n);
  
  return mean;
}

int freeParkingSpace(UltraSonicDistanceSensor ultrasonic) {
  float distance = getSensorDistance(ultrasonic);

  return distance > 10;
}

ParkingSpace getBestParkingSpace() {
  float bestDistance = 100;
  int bestParkingSpace = -1;
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
  
  if(bestParkingSpace != -1 && parkingSpaces[bestParkingSpace].isFree) {
    return parkingSpaces[bestParkingSpace];
  } else {
    return ParkingSpace(-1, -1, "Nenhuma vaga", "Nenhuma vaga");
  }
}

void openGate(int timeToCLose = 10000){
  moveGate(1);
  delay(timeToCLose);
  moveGate(0);
}

void openGateButtonPressed(String button){
  delay(500);
  if(button == "outside") {
    lcd.setCursor(0, 1);
    bestSpot = getBestParkingSpace();
    if(bestSpot.sensorId != -1){
      lcd.print("Sua vaga eh: "+ bestSpot.name);
      //bestSpot->isFree = false;
      openGate();
      clearRowLcd(1);
    } else {
      lcd.print(bestSpot.name);
      delay(5000);
      clearRowLcd(1);
    }
  } else if(button == "inside") {
    openGate();
  }
}

void updateParkingSpacesNumber(){
  clearRowLcd(1);
  lcd.setCursor(0, 1);
  lcd.print("Vagas disp.: " + (String)parkingSpacesCount);
}

void countParkingSpaces(){

  int count = 0;

  for(int i = 0; i < 4; i++) {
    int sensorId = parkingSpaces[i].sensorId;
    if(freeParkingSpace(sensors[sensorId])) {
      count++;
    }
  }

  if(count != parkingSpacesCount) {
    parkingSpacesCount = count;
    updateParkingSpacesNumber();
  }
}
