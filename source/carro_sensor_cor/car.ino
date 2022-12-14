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

#include "Adafruit_TCS34725.h"

/* Definições Úteis */
/**
 * @brief Tamanho do maior caminho do array de cores.
*/
#define LONGEST_PATH 10

/**
 * @brief Pino do Buzzer.
*/
#define BUZZER 9

/**
 * @brief Frequência padrão emitida pelo Buzzer.
*/
#define BUZZER_FREQ 2000

/**
 * @brief Frequência emitida pelo Buzzer ao chegar na vaga correta.
*/
#define BUZZER_FREQ_DONE 5000

/**
 * @brief Delay (duração) do beep longo.
*/
#define DELAY_LONG_BEEP 500

/**
 * @brief Delay (duração) do beep curto.
*/
#define DELAY_SHORT_BEEP 200

/**
 * @brief Índice onde se inicia o tamanho da mensagem do protocolo.
*/
#define MSG_IDX_SIZE 1

/**
 * @brief Índice onde se inicia o caminho a ser seguido na mensagem.
*/
#define MSG_IDX_BEGIN 2

/**
 * @brief Pino do LED de cor vermelha.
*/
#define RED_PIN 3

/**
 * @brief Pino do LED de cor verde.
*/
#define GREEN_PIN 5

/**
 * @brief Pino do LED de cor azul.
*/
#define BLUE_PIN 6

/**
 * @brief Valor mínimo de limiar de calibração da cor Vermelha. 
*/
#define CALIB_RED 85

/**
 * @brief Valor mínimo de limiar de calibração da cor Azul. 
*/
#define CALIB_BLUE 95

/**
 * @brief Valor mínimo de limiar de calibração da cor Verde. 
*/
#define CALIB_GREEN 96

/**
 * @brief Valor definido para desligar o LED.
 * 
 */
#define LED_OFF 255

/**
 * @brief Valor definido para ligar o LED.
 * 
 */
#define LED_ON 0

/**
 * @brief Tipos de cores detectados pelo sensor.
 */
typedef enum {
  NO_COLOR = 0,
  RED,
  GREEN,
  BLUE,
  UNKNOWN_COLOR,
  __COLOR_AMOUNT,
} COLOR;

/**
 * @brief Caminho do mapa a ser percorrido pelo carrinho.
*/
typedef struct {
  COLOR color_list[LONGEST_PATH];
} PATH_MAP;

/**
 * @brief Declaração dos estados do carro.
*/
typedef enum {
  WAITING_MESSAGE,
  RUNNING,
  DONE,
} CAR_STATE;

/**
 * @brief Estrutura com as leituras das cores.
*/
typedef struct _ColorSensor {
  float red;
  float green;
  float blue;
} ColorSensor;

Adafruit_TCS34725 tcs = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_240MS, TCS34725_GAIN_1X);
PATH_MAP road_path = {0};
ColorSensor colorRead = {0};
CAR_STATE state = WAITING_MESSAGE;
COLOR current_path = {0};
COLOR next_path = {0};
int path_idx = 0;
boolean parked = false;

/**
 * @brief Emite bipes curtos de acordo com o solicitado.
 * @param int Quantidade de vezes que os bipes devem ser emitidos. 
 * @param int 0 - caso não tenha chegado na vaga, 1 - caso contrário.
 */
void short_beep(int times, int done);

/**
 * @brief Emite bipes longos de acordo com o solicitado.
 * @param int Quantidade de vezes que os bipes devem ser emitidos. 
 */
void long_beep(int times);

/**
 * @brief Execução do estado onde o carro aguarda pela mensagem do protocolo.
 * 
 */
void waiting_message_exec();

/**
 * @brief Execução do estado onde o carro está verificando o caminho e buscando sua vaga.
 * 
 */
void running_exec();

/**
 * @brief Execução do estado onde o carro está estacionando em sua vaga.
 * 
 */
void done_exec();

/**
 * @brief Função utilizada para construir o caminho a ser percorrido.
 * @param int tamanho do caminho informado na mensagem.
 * @param String caminho informado na mensagem.
 */
void assign_path(int size, String path);

/**
 * @brief Função que executa e avalia a leitura da cor sendo feita pelo sensor.
 * @return COLOR - Cor identificada.
 */
COLOR read_car_color();


/* Início da implementação padrão */
void setup() {
  Serial.begin(9600);
  pinMode(BUZZER, OUTPUT);
  pinMode(RED_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(BLUE_PIN, OUTPUT);
  analogWrite(RED_PIN, LED_OFF);
  analogWrite(GREEN_PIN, LED_OFF);
  analogWrite(BLUE_PIN, LED_OFF);

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

/* As funções devem ser implementadas abaixo desta linha */

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
    String beg = "S";
    String end_1 = "E\n";
    String end_2 = "E\r\n";

    if (recv_message.startsWith(beg) &&
        (recv_message.endsWith(end_1) || recv_message.endsWith(end_2))) {
      int path_size = recv_message.charAt(MSG_IDX_SIZE) - '0';
      path_idx = 0;
      assign_path(path_size, recv_message.substring(MSG_IDX_BEGIN,
                                                    MSG_IDX_BEGIN + path_size));
      state = RUNNING;
      short_beep(2, false);
    }
  }
  delay(200);
}

COLOR read_car_color() {
  tcs.getRGB(&colorRead.red, &colorRead.green, &colorRead.blue);

  if ((colorRead.red >= CALIB_RED) && (colorRead.green < CALIB_GREEN) && (colorRead.blue < CALIB_BLUE)) {
    return RED;
  }

  if ((colorRead.blue >= CALIB_BLUE) && (colorRead.green < CALIB_GREEN) && (colorRead.red < CALIB_RED)) {
    return BLUE;
  }

  if ((colorRead.green >= CALIB_GREEN) && (colorRead.red < CALIB_RED) && (colorRead.blue < CALIB_BLUE)) {
    return GREEN;
  }

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

void running_exec() {
  COLOR curr_read = read_car_color();
  if (curr_read != current_path && curr_read != next_path) {
    short_beep(1, false);
    delay(20);
  } else if (curr_read == next_path) {
    path_idx += 1;
    current_path = next_path;
    next_path = road_path.color_list[path_idx];
    if (next_path == NO_COLOR) {
      state = DONE;
    }
  }

  switch (curr_read) {
  case RED:
    analogWrite(RED_PIN, LED_ON);
    analogWrite(GREEN_PIN, LED_OFF);
    analogWrite(BLUE_PIN, LED_OFF);
    break;
  case GREEN:
    analogWrite(GREEN_PIN, LED_ON);
    analogWrite(BLUE_PIN, LED_OFF);
    analogWrite(RED_PIN, LED_OFF);
    break;
  case BLUE:
    analogWrite(BLUE_PIN, LED_ON);
    analogWrite(RED_PIN, LED_OFF);
    analogWrite(GREEN_PIN, LED_OFF);
    break;
  case UNKNOWN_COLOR:
    analogWrite(GREEN_PIN, LED_ON);
    analogWrite(BLUE_PIN, LED_ON);
    analogWrite(RED_PIN, LED_ON);
    break;
  }
}

void done_exec() {
  if(parked == false){    
    short_beep(3, true);
    delay(1200);
    analogWrite(GREEN_PIN, LED_OFF);
    analogWrite(BLUE_PIN, LED_OFF);
    analogWrite(RED_PIN, LED_OFF); 
    parked = true; 
  }
  
}
