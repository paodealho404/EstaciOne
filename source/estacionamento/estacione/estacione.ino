/*
* Projeto Final da disciplina de Microcontroladores e Aplicações (2022.1)
*
* Alunos:
* - José Ferreira Leite Neto (19111153)
* - Lilian Giselly Pereira Santos (19111115)
* -Lucas Lemos Cerqueira de Freitas (19111116)
* - Pedro Henrique de Brito Nascimento (19111287)
*
*/

/* Importações de bibliotecas */
#include <HCSR04.h>
#include <Servo.h>
#include <Ultrasonic.h>
#include <LiquidCrystal_I2C.h>

/* Definições Úteis */

/**
 * @brief Pino trigger do sensor 1.
 */
#define sensor1TriggerPin 2

/**
 * @brief Pino echo do sensor 1.
 */
#define sensor1EchoPin 3

/**
 * @brief Pino trigger do sensor 4.
 */
#define sensor2TriggerPin 4

/**
 * @brief Pino echo do sensor 5.
 */
#define sensor2EchoPin 5

/**
 * @brief Pino trigger do sensor 6.
 */
#define sensor3TriggerPin 6

/**
 * @brief Pino echo do sensor 7.
 */
#define sensor3EchoPin 7

/**
 * @brief Pino trigger do sensor 8.
 */
#define sensor4TriggerPin 8

/**
 * @brief Pino echo do sensor 9.
 */
#define sensor4EchoPin 9

/**
 * @brief Pino do botão interno.
 */
#define insideButtonPin 13

/**
 * @brief Pino do botão externo.
 */
#define outsideButtonPin 12

/**
 * @brief Pino do servomotor.
 */
#define servoPin 11

/**
 * @brief Ângulo de fechamento da cancela (°).
 */
#define angClose 90

/**
 * @brief Ângulo de abertura da cancela (°).
 */
#define angOpen 20

/**
 * @brief Distância mínima para que a vaga seja considerada livre (cm).
 */
#define minFreeDistance 10

/**
 * @brief Tempo para fechar a cancela (ms).
 */
#define timeToCLose 6000

/**
 * @brief Número de leituras para calcular a média do sensor ultrassônico.
 */
#define numberOfReads 10

/**
 * @brief Declaração dos estados do estacionamento.
 */
typedef enum {
  WAITING_ACTION,
  BUTTON_PRESSED,
  RUNNING,
  DONE,
} PARKING_STATE;

/**
 * @brief Definição da classe ParkingSpace (representa uma vaga).
 */
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

ParkingSpace bestSpot = ParkingSpace(-1, -1, "Nenhuma vaga", "Nenhuma vaga");

ParkingSpace parkingSpaces[4] = { 
 ParkingSpace(0, 3, "B4", "S7RGRBRBGE"),
 ParkingSpace(1, 4, "B1", "S4RGRGE"), 
 ParkingSpace(2, 2, "A1", "S3RBGE"), 
 ParkingSpace(3, 1, "A2", "S4RBRGE")  
};

/**
 * @brief Verifica se um dos botões da cancela foi pressionado e atualiza o estado.
 */
void waiting_action_exec();

/**
 * @brief Atualiza o estado de acordo com o botão que foi pressionado para abrir a cancela.
 */
void button_pressed_exec();

/**
 * @brief Se uma vaga tiver sido solicitada, monitora a ocupação desta e, quando ocupada, atualiza o estado.
 */
void running_exec();

/**
 * @brief Atualiza o estado após o fim do ciclo da máquina de estados.
 */
void done_exec();

/**
 * @brief Limpa a linha selecionada no LCD.
 * @param int Linha selecionada.
 */
void clearRowLcd(int row);

/**
 * @brief Movimenta a cancela de acordo com o movimento informado.
 * @param int Movimento desejado 0 = Fecha | 1 = Abre.
 */
void moveGate(int moviment);

/**
 * @brief Abre a cancela.
 */
void openGate();

/**
 * @brief Abre a cancela e, se o botão pressionado foi o externo apresenta a vaga selecionada (se indisponível, informa).
 * @param String Botão pressionado.
 */
void openGateButtonPressed(String button);

/**
 * @brief Conta a quantidade de vagas disponíveis e atualiza o LCD.
 */
void updateParkingSpaces();

/**
 * @brief Remove os outliers das leituras informadas e calcula a média.
 * @param float[] Array de leituras.
 * @param int Quantidade de leituras.
 * @return float Média calculada.
 */
float getMean(float array[], int size);

/**
 * @brief Calcula a distância lida pelo sensor.
 * @param UltraSonicDistanceSensor Sensor que se deseja obter a distância.
 * @return float Distância lida.
 */
float getSensorDistance(UltraSonicDistanceSensor sensor);

/**
 * @brief Verifica se a vaga passada como parâmetro está livre.
 * @param UltraSonicDistanceSensor Sensor ultrassonico em questão.
 * @return int 0 = Vaga está ocupada | 1 = Vaga está disponível.
 */
int freeParkingSpace(UltraSonicDistanceSensor ultrasonic);

/**
 * @brief Avalia a melhor vaga disponível caso haja, e a retorna, ou informa que não há vagas.
 * @return ParkingSpace Melhor vaga disponível.
 */
ParkingSpace getBestParkingSpace();

/* Implementação do setup e loop */
void setup()
{
  Serial.begin(9600);
  pinMode(insideButtonPin, INPUT);
  pinMode(outsideButtonPin, INPUT);
  servo.attach(servoPin);
  servo.write(angClose);
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

  updateParkingSpaces();
  
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

  delay(500);
}

/* As funções devem ser implementadas abaixo desta linha */
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
  float measures[numberOfReads];

  for(int i = 0;i < numberOfReads; i++) {
    measures[i] = sensor.measureDistanceCm();
  }

  return getMean(measures, numberOfReads);
}

int freeParkingSpace(UltraSonicDistanceSensor ultrasonic) {
  float distance = getSensorDistance(ultrasonic);

  return distance > minFreeDistance;
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
  
  if(bestParkingSpace != -1) {
    return parkingSpaces[bestParkingSpace];
  } else {
    return ParkingSpace(-1, -1, "Nenhuma vaga", "Nenhuma vaga");
  }
}

void openGate(){
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

void updateParkingSpaces(){
  int count = 0;

  for(int i = 0; i < 4; i++) {
    int sensorId = parkingSpaces[i].sensorId;
    if(freeParkingSpace(sensors[sensorId])) {
      count++;
    }
  }

  if(count != parkingSpacesCount) {
    parkingSpacesCount = count;
    clearRowLcd(1);
    lcd.setCursor(0, 1);
    lcd.print("Vagas disp.: " + (String)parkingSpacesCount);
  }
}
