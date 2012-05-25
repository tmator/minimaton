//Minimaton
//by Fabrice,  Phil, tmator
//Inspired from Video2ledwallHarpSerial V1.0 by Fabrice Fourc
// http://www.tetalab.org


// import processing.video.*;
import processing.net.*;
import codeanticode.gsvideo.*;

//GSCapture video;
boolean cheatScreen;


int plage=44;//256;
int MINITEL_CHAR_WIDTH = 40;//*2;
int MINITEL_CHAR_HEIGHT = 24;//*4;
// en fait ce n'est pas vraiment un pixel par pixel char...
int PIXEL_CHAR_WIDTH = 2;
int PIXEL_CHAR_HEIGHT = 3;

// Size of each cell in the grid, ratio of window size to video size
int videoScale = 10;
int videoScalex = 1;//8;
int videoScaley = 1;//6;

int count = 0;

// Number of columns and rows in our system
int cols, rows;
// Variable to hold onto Capture object
public int s = 140;
import processing.serial.*;

// The serial port:
Serial myPort;

//luminosite globale de la colone pour le son
int colValue;
String ledCol;
String ledWallMsg;

//Client myClient;
GSCapture video;

void setup() 
{
  //size(MINITEL_CHAR_WIDTH*PIXEL_CHAR_WIDTH*videoScalex, MINITEL_CHAR_HEIGHT*PIXEL_CHAR_HEIGHT*videoScaley);
  size(640,480);
  frameRate(25);
  
   //frame.setResizable(true);


  // List all the available serial ports:
  println(Serial.list());

  // I know that the first port in the serial list on my mac
  // is always my  Keyspan adaptor, so I open Serial.list()[0].
  // Open whatever port is the one you're using.
  myPort = new Serial(this, Serial.list()[0], 1200);

  //myClient = new Client(this, "127.0.0.1", 5204);
  // Initialize columns and rows
  cols = 640/videoScalex;
  rows = 480/videoScaley;
  video = new GSCapture(this, 640, 480, "/dev/video0");

  video.start();
}


//----------------------------------------------------------

void displayPixelChar2(int x, int y)
{
  x= x *2;
  y = y * 3;
  byte carac=0; // caractÃ¨re pixel
  carac+=(Math.pow(2, 0))*getG2(x+0, y+0);
  carac+=(Math.pow(2, 1))*getG2(x+1, y+0);
  carac+=(Math.pow(2, 2))*getG2(x+0, y+1);
  carac+=(Math.pow(2, 3))*getG2(x+1, y+1);
  carac+=(Math.pow(2, 4))*getG2(x+0, y+2);
  carac+=(Math.pow(2, 5))*1;
  carac+=(Math.pow(2, 6))*getG2(x+1, y+2);
  myPort.write(carac);
 // println("carac= "+carac);
}

int getG2(int x, int y)
{
  //println("x + y*video.width" + (x + y*video.width));
  color c = video.pixels[x + y*video.width];
  int value = (int)brightness(c);  // get the brightness
  if (value<s)
  {
    return(0);
  }
  else 
  {
    return(1);
  }
}

void draw() {
  // Read image from the camera
  noStroke();

  if (video.available()) 
  {
    video.read();
  }
  //scale(0.5);
  //frame.resize(160,120);
  video.loadPixels();

  if (!mousePressed) //si je ne clique pas, j'affiche le preview
  {
    //image(video, 0, 0);
    // Begin loop for columns
    for (int i = 0; i < cols; i+=8) 
    {
      // Begin loop for rows
      for (int j = 0; j < rows; j+=6) 
      {
        // Where are we, pixel-wise?
        int x = i;
        int y = j;
        // Looking up the appropriate color in the pixel array
        color c = video.pixels[i + j*video.width];
        int value = (int)brightness(c);  // get the brightness
        if (value<s)
        {
          fill(0);
        }
        else
        {
          fill(255);
        }
        rect(x, y,8,6);// ,6);// 8,6);//,6);// videoScaley);
      }
      ledWallMsg += ledCol;
    }
  }
  else //si je clique sur l'image j'envoi sur le port serie
  {
    //myPort.write(12);
    //myPort.write(14);
/*    for (int y=0;y<MINITEL_CHAR_HEIGHT;y++) 
    {
      for (int x=0;x<MINITEL_CHAR_WIDTH;x++) 
      {
        displayPixelChar2(x, y);
        //println("x= "+x+"y= "+y);
      }
    }*/
    

    
  }


//  if (count%4 == 0) {
//    s+=1;
//  }
}

void keyPressed() //reglage du seuil (a-, z+)
{
  if ( key == 'a') 
  {
    s = s - 1;
    println("s " + s);
  }
  if ( key == 'z')
  {
    s = s + 1;
    println("s " + s);
  }
  if ( key == ' ')
  {
    //on save et on imprime
    saveFrame("/tmp/img.png");
    try {
      String[] command = new String[1];
      command[0]="/folder/print.sh";
    Process p = exec(command); 
    BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));
    String line = null;
    while ((line = in.readLine()) != null) {
      System.out.println(line);
    }//fin while
  } // fin try
  catch (IOException e) { // gestion exception
    e.printStackTrace();
  } // fin catch 
  }
}

