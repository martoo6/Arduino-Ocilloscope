/*
 * Oscilloscope
 * Gives a visual rendering of all analog pins in realtime.
 * 
 * (c) 2013 Martin Silberkasten (martosilber@yahoo.com.ar)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import processing.serial.*;
boolean recording=false;
Serial port;  // Create object from Serial class
int val;      // Data received from the serial port
int[][] values;
float zoom;
int currentPos=0;
float levels=1;
color[] colores = {
  color(255, 0, 0), color(0, 255, 0), color(0, 0, 255), color(255, 255, 0), color(0, 255, 255), color(255, 0, 255)
};

void setup() 
{
  size(1280, 480);
  // Open the port that the board is connected to and use the same speed (9600 bps)
  port = new Serial(this, Serial.list()[0], 115200);
  values = new int[6][width];
  zoom = 1.0f;
  smooth();
}

void getValues() {
  while (port.available () >= 1+(2*6)) {
    if (port.read() == 0xff) {
      for(int i=0;i<levels;i++){
        int value = (port.read() << 8) | (port.read());
        if(value>1023) value=1023/2; //Por laguna razon puedo recibir valores erroneos. Estos deberian de ser filtrados, como workaround les doy el valor medio.
        values[i][currentPos] = value;
      }
      currentPos++;
      if(currentPos==width) currentPos=0; //Antes se utilizaba un push, esto es mas eficiente aunq se ve peor en pantalla
    }
  }
}

void drawLines() {
  int displayWidth = (int) (width / zoom);
  for (int e=0;e<levels;e++) {
    stroke(colores[e]);
    //int k = width - displayWidth;
    int k = currentPos;
    float step = height/levels;
    float scale= step/1023.0f;
    int x0 = 0;
    int y0 = (int) (step*(e+1)-values[e][k] * scale);
    for(int i=1; i<displayWidth; i++) {
      k++;
      if(k==width) k=0;
      int x1 = (int) (i * (width-1) / (displayWidth-1));
      int y1 = (int) (step*(e+1)-values[e][k] * scale);
      line(x0, y0, x1, y1);
      x0 = x1;
      y0 = y1;
    }
  }
}

void drawGrid() {
  float step = height/levels;
  for(int i=1;i<levels+1;i++){
    stroke(255, 255, 255);
    line(0, step*i, width, step*i);
    stroke(100, 100, 100);
    line(0, step*i-step/2, width, step*i-step/2);
  }
}

void keyReleased() {
  switch (key) {
  case '+':
    zoom *= 2.0f;
    println(zoom);
    if ( (int) (width / zoom) <= 1 )
      zoom /= 2.0f;
    break;
  case '-':
    zoom /= 2.0f;
    if (zoom < 1.0f)
      zoom *= 2.0f;
    break;
  case '1':
    levels=1;
    break;
  case '2':
    levels=2;
    break;
  case '3':
    levels=3;
    break;
  case '4':
    levels=4;
    break;
  case '5':
    levels=5;
    break;
  case '6':
    levels=6;
    break;
  }
}

void draw()
{
  background(0);
  getValues();
  drawLines();
  drawGrid();
  if (recording) {
    saveFrame("output/frames####.png");
  }
}

