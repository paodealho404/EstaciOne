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
 * @brief Se estiver setado para 1, o teste de bancada a se fazer é o de entrada digital.
 * 
 */
#define BRINGUP_DIGITAL_INPUT 0
/**
 * @brief Se estiver setado para 1, o teste de bancada a se fazer é o de saída digital.
 * 
 */
#define BRINGUP_DIGITAL_OUTPUT 0
/**
 * @brief Se estiver setado para 1, o teste de bancada a se fazer é o de entrada analógica.
 * 
 */
#define BRINGUP_ANALOG_INPUT 0
/**
 * @brief Se estiver setado para 1, o teste de bancada a se fazer é o de saída analógica.
 * 
 */
#define BRINGUP_ANALOG_OUTPUT 0
/**
 * @brief Se estiver setado para 1, o teste de bancada a se fazer é o de PWM.
 * 
 */
#define BRINGUP_PWM 0
/**
 * @brief Se estiver setado para 1, o teste de bancada a se fazer é o de comunicação serial.
 * 
 */
#define BRINGUP_SERIAL 0

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

/* As funções devem ser implementadas abaixo desta linha*/