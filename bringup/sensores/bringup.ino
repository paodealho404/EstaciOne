/**
 * @file bringup.ino
 * @author Pedro (phbn@ic.ifal.br)
 * @brief Implementação para testes dos periféricos do Arduíno
 * @version 0.1
 * @date 2022-08-30
 *
 * @copyright Copyright (c) 2022
 *
 */

/**
 * @brief Se estiver setado para 1, o teste de bancada a se fazer é o de entrada
 * digital.
 *
 */
#define BRINGUP_DIGITAL_INPUT 1
/**
 * @brief Se estiver setado para 1, o teste de bancada a se fazer é o de saída
 * digital.
 *
 */
#define BRINGUP_DIGITAL_OUTPUT 0
/**
 * @brief Se estiver setado para 1, o teste de bancada a se fazer é o de entrada
 * analógica.
 *
 */
#define BRINGUP_ANALOG_INPUT 0
/**
 * @brief Se estiver setado para 1, o teste de bancada a se fazer é o de saída
 * analógica.
 *
 */
#define BRINGUP_ANALOG_OUTPUT 0
/**
 * @brief Se estiver setado para 1, o teste de bancada a se fazer é o de PWM.
 *
 */
#define BRINGUP_PWM 0
/**
 * @brief Se estiver setado para 1, o teste de bancada a se fazer é o de
 * comunicação serial.
 *
 */
#define BRINGUP_SERIAL 0

/**
 * @brief Mude este define para 1 caso a placa Arduino seja Mega e não Uno.
 * i.e.: 0 - Arduino Uno, 1 - Arduino Mega
 *
 */
#define ARDUINO_MEGA 0

#if ARDUINO_MEGA == 1
#define FIRST_ADC_PIN 54
#define ADC_AMOUNT 16
#define DIGITAL_AMOUNT  54
typedef enum {
  D_PIN0 = 2,
  D_PIN1 = 3,
  D_PIN2 = 6,
  D_PIN3 = 7,
  D_PIN4 = 1,
  D_PIN5 = 5,
  D_PIN6 = 15,
  D_PIN7 = 16,
  D_PIN8 = 17,
  D_PIN9 = 18,
  D_PIN10 = 23,
  D_PIN11 = 24,
  D_PIN12 = 25,
  D_PIN13 = 26,
  D_PIN14 = 64,
  D_PIN15 = 63,
  D_PIN16 = 13,
  D_PIN17 = 12,
  D_PIN18 = 46,
  D_PIN19 = 45,
  D_PIN20 = 40,
  D_PIN21 = 43,
  D_PIN22 = 78,
  D_PIN23 = 77,
  D_PIN24 = 76,
  D_PIN25 = 75,
  D_PIN26 = 74,
  D_PIN27 = 73,
  D_PIN28 = 72,
  D_PIN29 = 71,
  D_PIN30 = 60,
  D_PIN31 = 59,
  D_PIN32 = 58,
  D_PIN33 = 57,
  D_PIN34 = 56,
  D_PIN35 = 55,
  D_PIN36 = 54,
  D_PIN37 = 53,
  D_PIN38 = 50,
  D_PIN39 = 70,
  D_PIN40 = 52,
  D_PIN41 = 51,
  D_PIN42 = 42,
  D_PIN43 = 41,
  D_PIN44 = 40,
  D_PIN45 = 39,
  D_PIN46 = 38,
  D_PIN47 = 37,
  D_PIN48 = 36,
  D_PIN49 = 35,
  D_PIN50 = 22,
  D_PIN51 = 21,
  D_PIN52 = 20,
  D_PIN53 = 19
} digital_pin;

#elif ARDUINO_MEGA == 0
#define FIRST_ADC_PIN 14
#define ADC_AMOUNT 6
#define DIGITAL_AMOUNT  14
typedef enum{
  D_PIN0 = 0,
  D_PIN1 = 1,
  D_PIN2 = 2,
  D_PIN3 = 3,
  D_PIN4 = 4,
  D_PIN5 = 5,
  D_PIN6 = 6,
  D_PIN7 = 7,
  D_PIN8 = 8,
  D_PIN9 = 9,
  D_PIN10 = 10,
  D_PIN11 = 11,
  D_PIN12 = 12,
  D_PIN13 = 13
}digital_pin;
#endif


/**
 * @brief Teste de bancada de entrada digital
 *
 */
void bringup_digital_input();

/**
 * @brief Teste de bancada de saída digital
 *
 */
void bringup_digital_output();

/**
 * @brief Teste de bancada de entrada analógica
 *
 */
void bringup_analog_input();

/**
 * @brief Teste de bancada de saída analógica
 *
 */
void bringup_analog_output();

/**
 * @brief Teste de bancada de PWM.
 *
 */
void bringup_pwm();

/**
 * @brief Teste de bancada de
 *
 */
void bringup_serial();

/**
 * @brief Configuração dos pinos digitais como entradas
 *
 */
void setup_digital_input();

/**
 * @brief Configuração dos pinos digitais como saídas
 *
 */
void setup_digital_output();

/**
 * @brief Configuração dos pinos analógicos como entradas
 *
 */
void setup_analog_input();

/**
 * @brief Configuração dos pinos analógicos como saídas
 *
 */
void setup_analog_output();

/**
 * @brief Configuração dos pinos digitais como pwm
 *
 */
void setup_pwm();

/**
 * @brief Configuração dos pinos TX e RX para comunicação serial
 *
 */
void setup_serial();

void setup() {
#if BRINGUP_DIGITAL_INPUT
  setup_digital_input();
#endif
#if BRINGUP_DIGITAL_OUTPUT
  setup_digital_output();
#endif
#if BRINGUP_ANALOG_INPUT
  setup_analog_input();
#endif
#if BRINGUP_ANALOG_OUTPUT
  setup_analog_output();
#endif
#if BRINGUP_PWM
  setup_pwm();
#endif
#if BRINGUP_SERIAL
  setup_serial();
#endif
}

void loop() {
#if BRINGUP_DIGITAL_INPUT
  bringup_digital_input();
#endif
#if BRINGUP_DIGITAL_OUTPUT
  bringup_digital_output();
#endif
#if BRINGUP_ANALOG_INPUT
  bringup_analog_input();
#endif
#if BRINGUP_ANALOG_OUTPUT
  bringup_analog_output();
#endif
#if BRINGUP_PWM
  bringup_pwm();
#endif
#if BRINGUP_TX_RX
  bringup_serial();
#endif
}

/* As funções devem ser implementadas abaixo desta linha */

void setup_analog_input() {
  Serial.begin(9600);
  return; // Não é necessário configurar ADC
}
void bringup_analog_input() {
  uint16_t adc[ADC_AMOUNT];

  for (uint8_t i = 0; i < ADC_AMOUNT; i++) {
    adc[i] = analogRead(FIRST_ADC_PIN + i);

  }
  for (int i = 0; i < ADC_AMOUNT; i++)
  {
    Serial.print("ADC "+String(i)+": ");
    Serial.println(String(adc[i]));
  }
  Serial.println("********************");
  delay(1000);
}

void setup_digital_input(){
  Serial.begin(9600);
  for (uint8_t i = 0; i < DIGITAL_AMOUNT; i++) {
    pinMode(i, INPUT);
  }
}

void bringup_digital_input(){
  uint8_t digital[DIGITAL_AMOUNT];

  for (uint8_t i = 0; i < DIGITAL_AMOUNT; i++) {
    digital[i] = digitalRead(i);
  }
  for (int i = 0; i < DIGITAL_AMOUNT; i++)
  {
    Serial.print("D_PIN "+String(i)+": ");
    Serial.println(String(digital[i]));
  }
  Serial.println("********************");
  delay(1000);
}