/* Definições Úteis */
#define LONGEST_PATH 3
#define ROWS 2
#define SLOTS 4
#define PATH_A(x) PARKING_LOT[0][x].path
#define PATH_B(x) PARKING_LOT[1][x].path
#define DIST_A(x) PARKING_LOT[0][x].distance
#define DIST_B(x) PARKING_LOT[1][x].distance
#define BUSY_A(x) PARKING_LOT[0][x].busy
#define BUSY_B(x) PARKING_LOT[1][x].busy
#define STR_A(x,y) strcpy(PARKING_LOT[0][x].str,y) 
#define STR_B(x,y) strcpy(PARKING_LOT[1][x].str,y)
/**********************/

/* Configuração de Mapa */
#define DEFINE_MAP_A0 STR_A(0, "A0"); DIST_A(0) = 255; BUSY_A(0) = FREE_STATE; PATH_A(0).color_list[0] = BLACK; PATH_A(0).color_list[1] = BLACK; PATH_A(0).color_list[2] = BLACK
#define DEFINE_MAP_A1 STR_A(1, "A1"); DIST_A(1) = 255; BUSY_A(1) = FREE_STATE; PATH_A(1).color_list[0] = BLACK; PATH_A(1).color_list[1] = BLACK; PATH_A(1).color_list[2] = BLACK
#define DEFINE_MAP_A2 STR_A(2, "A2"); DIST_A(2) = 255; BUSY_A(2) = FREE_STATE; PATH_A(2).color_list[0] = BLACK; PATH_A(2).color_list[1] = BLACK; PATH_A(2).color_list[2] = BLACK
#define DEFINE_MAP_A3 STR_A(3, "A3"); DIST_A(3) = 255; BUSY_A(3) = FREE_STATE; PATH_A(3).color_list[0] = BLACK; PATH_A(3).color_list[1] = BLACK; PATH_A(3).color_list[2] = BLACK
#define DEFINE_MAP_B0 STR_B(0, "B0"); DIST_B(0) = 255; BUSY_B(0) = FREE_STATE; PATH_B(0).color_list[0] = BLACK; PATH_B(0).color_list[1] = BLACK; PATH_B(0).color_list[2] = BLACK
#define DEFINE_MAP_B1 STR_B(1, "B1"); DIST_B(1) = 255; BUSY_B(1) = FREE_STATE; PATH_B(1).color_list[0] = BLACK; PATH_B(1).color_list[1] = BLACK; PATH_B(1).color_list[2] = BLACK
#define DEFINE_MAP_B2 STR_B(2, "B2"); DIST_B(2) = 255; BUSY_B(2) = FREE_STATE; PATH_B(2).color_list[0] = BLACK; PATH_B(2).color_list[1] = BLACK; PATH_B(2).color_list[2] = BLACK
#define DEFINE_MAP_B3 STR_B(3, "B3"); DIST_B(3) = 255; BUSY_B(3) = FREE_STATE; PATH_B(3).color_list[0] = BLACK; PATH_B(3).color_list[1] = BLACK; PATH_B(3).color_list[2] = BLACK
/**********************/

typedef enum {
  BLACK = 0,
  RED,
  BLUE,
  __COLOR_AMOUNT
} COLOR;

typedef enum {
  FREE_STATE = 0,
  RESERVED_STATE,
  OCCUPIED_STATE,
  __STATE_AMOUNT
} SLOT_STATE;

typedef struct{
  COLOR color_list[LONGEST_PATH];
} PATH_MAP;


typedef struct {
    char str[3];
    uint8_t distance;
    PATH_MAP path;
    SLOT_STATE busy; //TODO: Mudar de boolean para slot state
} AREA;

void sort_parking_lot(AREA PARKING_LOT[ROWS][SLOTS]);

void setup() {
  AREA PARKING_LOT[ROWS][SLOTS] = {};
  DEFINE_MAP_A0;
  DEFINE_MAP_A1;
  DEFINE_MAP_A2;
  DEFINE_MAP_A3;
  DEFINE_MAP_B0;
  DEFINE_MAP_B1;
  DEFINE_MAP_B2;
  DEFINE_MAP_B3;  
  Serial.begin(9600);
  
}

void loop() {
  // put your main code here, to run repeatedly:

}

void sort_parking_lot(AREA PARKING_LOT[ROWS][SLOTS]){
  AREA sorted[ROWS*SLOTS];
  memcpy(sorted, PARKING_LOT, ROWS*sizeof(PARKING_LOT));
  
  for(int i = 0; i<ROWS; i++){
    for (int j = 0; j < SLOTS; j++)
    {
      Serial.print((String)sorted[(i*SLOTS)+j].distance+" ");
    }
    Serial.println("");
  }
  
}

/* As funções devem ser implementadas abaixo desta linha*/