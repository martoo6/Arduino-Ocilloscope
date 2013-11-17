#define ANALOG_IN 0

unsigned int val;
void setup() {
  //Serial.begin(9600); 
  Serial.begin(115200);
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(A3, INPUT);
  pinMode(A4, INPUT);
  pinMode(A5, INPUT);
}

void loop() {
  Serial.write( 0xff );
  for(int i=0;i<6;i++){
    val = analogRead(i);
    Serial.write( (val >> 8) & 0xff );
    Serial.write( val & 0xff );
  }
}
