#include <Adafruit_NeoPixel.h>

#define D_MAX_BTN 4

int nLED_pin = 6;
int nRes_pin = A0;

int button_pin[D_MAX_BTN];
bool bIsBtn[D_MAX_BTN];
bool bIsBtnCheck[D_MAX_BTN];
int nIsBtnCheck[D_MAX_BTN];

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(nLED_pin, OUTPUT);

  button_pin[0] = 5;
  button_pin[1] = 4;
  button_pin[2] = 3;
  button_pin[3] = 2;
  
  for(int i=0; i<D_MAX_BTN; i++)
  {
    bIsBtn[i] = false;
    bIsBtnCheck[i] = false;
    nIsBtnCheck[i] = 0;
    pinMode(button_pin[i], INPUT);
  }
  //pinMode(nRes_pin, INPUT);
}

void loop() {
  int analogInput = analogRead(A0);//가변저항을 아날로그 0번핀에 연결하고 이를 입력으로 설정합니다.
  int brightness = analogInput / 4;  // 가변저항의 입력값(0-1023사이의 값)을 LED의밝기값(0-255)의 값으로 변경해줍니다.
  int btnIndex = -1;
  analogWrite(nLED_pin, brightness);//가변저항의 값을 LED로 보내 출력합니다.
  
  
  for(int i=0; i<D_MAX_BTN; i++)
  {
    if (digitalRead(button_pin[i]) == LOW && bIsBtnCheck[i] == true)
    {
      if( nIsBtnCheck[i] >= 3 )
      {
        bIsBtn[i] = false;
        nIsBtnCheck[i] = 0;
      }
      
      digitalWrite(nLED_pin, HIGH);
      
      bIsBtnCheck[i] = false;
      if( nIsBtnCheck[i] == 1 ) {
        bIsBtn[i] = true;
        btnIndex = i;
        nIsBtnCheck[i]++;
      }
      btnIndex = i;
    }
    else if (digitalRead(button_pin[i]) == HIGH && bIsBtnCheck[i] == false)
    {
      digitalWrite(nLED_pin, LOW);
      
      bIsBtnCheck[i] = true;
      nIsBtnCheck[i]++;
    }
  }
  Serial.print(brightness);
  Serial.print(",");
  Serial.print(btnIndex);
  Serial.println(".");
}

