#include "Adafruit_TCS34725.h"

/* Definições Úteis */
#define LONGEST_PATH 7
#define BUZZER 9
#define BUZZER_FREQ 2000
#define BUZZER_FREQ_DONE 5000
#define DELAY_LONG_BEEP 500
#define DELAY_SHORT_BEEP 200
#define MSG_IDX_SIZE 1
#define MSG_IDX_BEGIN 2
#define RED_PIN 3
#define GREEN_PIN 5
#define BLUE_PIN 6
#define CALIB_RED 85
#define CALIB_BLUE 95
#define CALIB_GREEN 96
/********************/

typedef enum {
  NO_COLOR = 0,
  RED,
  GREEN,
  BLUE,
  UNKNOWN_COLOR,
  __COLOR_AMOUNT,
} COLOR;

typedef struct {
  COLOR color_list[LONGEST_PATH];
} PATH_MAP;

typedef enum {
  WAITING_MESSAGE,
  RUNNING,
  DONE,
} CAR_STATE;

typedef struct _ColorSensor {
  float red;
  float green;
  float blue;
} ColorSensor;

Adafruit_TCS34725 tcs =
    Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_240MS, TCS34725_GAIN_1X);
PATH_MAP road_path = {0};
ColorSensor colorRead = {0};
CAR_STATE state = WAITING_MESSAGE;
COLOR current_path = {0};
COLOR next_path = {0};
int path_idx = 0;
boolean parked = false;

void short_beep(int times, int done);
void long_beep(int times);
void waiting_message_exec();
void running_exec();
void done_exec();
void assign_path();
void print_path();
COLOR read_car_color();

void setup() {
  Serial.begin(9600);
  pinMode(BUZZER, OUTPUT);
  analogWrite(RED_PIN, 255);
  analogWrite(GREEN_PIN, 255);
  analogWrite(BLUE_PIN, 255);
  pinMode(RED_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(BLUE_PIN, OUTPUT);

  Serial.println("Starting...");
  long_beep(2);
}

void loop() {
  switch (state) {
  case WAITING_MESSAGE:
    waiting_message_exec();
    break;
  case RUNNING:
    running_exec();
    break;
  case DONE:
    done_exec();
    break;
  default:
    break;
  }
}

/* As funções devem ser implementadas abaixo desta linha*/

void short_beep(int times, int done) {
  for (int i = 0; i < times; i++) {
    if (done) {
      tone(BUZZER, BUZZER_FREQ_DONE, DELAY_SHORT_BEEP);
    } else {
      tone(BUZZER, BUZZER_FREQ, DELAY_SHORT_BEEP);
    }

    delay(2 * DELAY_SHORT_BEEP);
  }
}
void long_beep(int times) {
  for (int i = 0; i < times; i++) {
    tone(BUZZER, BUZZER_FREQ, DELAY_LONG_BEEP);
    delay(2 * DELAY_LONG_BEEP);
  }
}

void waiting_message_exec() {
  if (Serial.available()) {
    String recv_message = Serial.readString();
    Serial.println(recv_message);
    String beg = "S";
    String end_1 = "E\n";
    String end_2 = "E";
    if (recv_message.startsWith(beg) &&
        (recv_message.endsWith(end_1) || recv_message.endsWith(end_2))) {
      int path_size = recv_message.charAt(MSG_IDX_SIZE) - '0';
      path_idx = 0;
      assign_path(path_size, recv_message.substring(MSG_IDX_BEGIN,
                                                    MSG_IDX_BEGIN + path_size));
      print_path();
      state = RUNNING;
      short_beep(2, false);
    }
  }
}

COLOR read_car_color() {
  tcs.getRGB(&colorRead.red, &colorRead.green, &colorRead.blue);
  Serial.println("Running (R: " + String(colorRead.red) +
                 " G: " + String(colorRead.green) +
                 " B: " + String(colorRead.blue) + " ) ...");

  if ((colorRead.red >= CALIB_RED) && (colorRead.green < CALIB_GREEN) &&
      (colorRead.blue < CALIB_BLUE)) {
    Serial.println("RED");
    return RED;
  }

  if ((colorRead.blue >= CALIB_BLUE) && (colorRead.green < CALIB_GREEN) &&
      (colorRead.red < CALIB_RED)) {
    Serial.println("BLUE");
    return BLUE;
  }

  if ((colorRead.green >= CALIB_GREEN) && (colorRead.red < CALIB_RED) &&
      (colorRead.blue < CALIB_BLUE)) {
    Serial.println("GREEN");
    return GREEN;
  }
  Serial.println("UNKNOWN");
  return UNKNOWN_COLOR;
}

void assign_path(int size, String path) {

  for (int i = 0; i < size; i++) {
    COLOR segment = NO_COLOR;
    switch (path.charAt(i)) {
    case 'R':
      segment = RED;
      break;

    case 'G':
      segment = GREEN;
      break;

    case 'B':
      segment = BLUE;
      break;
    }
    road_path.color_list[i] = segment;
  }
  next_path = road_path.color_list[0];
  current_path = road_path.color_list[0];
}

void print_path() {
  for (int i = 0; i < LONGEST_PATH; i++) {
    switch (road_path.color_list[i]) {

    case RED:
      Serial.print("R ");
      break;
    case GREEN:
      Serial.print("G ");
      break;

    case BLUE:
      Serial.print("B ");
      break;

    case NO_COLOR:
      Serial.print("X ");
      break;
    }
  }
  Serial.print('\n');
}

void print_current_path() {

  Serial.print("Follow: ");
  switch (current_path) {
  case RED:
    Serial.println("RED");
    break;
  case GREEN:
    Serial.println("GREEN");
    break;
  case BLUE:
    Serial.println("BLUE");
    break;
  case NO_COLOR:
    Serial.println("FINISHED");
    break;
  }
}

void print_next_path() {

  Serial.print("Next: ");
  switch (next_path) {
  case RED:
    Serial.println("RED");
    break;
  case GREEN:
    Serial.println("GREEN");
    break;
  case BLUE:
    Serial.println("BLUE");
    break;
  case NO_COLOR:
    Serial.println("FINISHED");
    break;
  }
}

void running_exec() {
  COLOR curr_read = read_car_color();
  if (curr_read != current_path && curr_read != next_path) {
    short_beep(1, false);
    delay(20);
  } else if (curr_read == next_path) {
    path_idx += 1;
    current_path = next_path;
    next_path = road_path.color_list[path_idx];
    print_current_path();
    print_next_path();
    if (next_path == NO_COLOR) {
      state = DONE;
    }
  }

  switch (curr_read) {
  case RED:
    analogWrite(RED_PIN, 0);
    analogWrite(GREEN_PIN, 255);
    analogWrite(BLUE_PIN, 255);
    break;
  case GREEN:
    analogWrite(GREEN_PIN, 0);
    analogWrite(BLUE_PIN, 255);
    analogWrite(RED_PIN, 255);
    break;
  case BLUE:
    analogWrite(BLUE_PIN, 0);
    analogWrite(RED_PIN, 255);
    analogWrite(GREEN_PIN, 255);
    break;
  case UNKNOWN_COLOR:
    analogWrite(GREEN_PIN, 0);
    analogWrite(BLUE_PIN, 0);
    analogWrite(RED_PIN, 0);
    print_current_path();
    print_next_path();
    break;
  }
}

void done_exec() {
  if(parked == false){
    Serial.println("You may park the vehicle");
    
    short_beep(3, true);
    analogWrite(GREEN_PIN, 255);
    analogWrite(BLUE_PIN, 255);
    analogWrite(RED_PIN, 255); 
    parked = true; 
  }
  
}
