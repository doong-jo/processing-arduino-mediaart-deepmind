/* //<>// //<>//
 * Decompiled with CFR 0_115.
 */
import processing.core.PApplet;
import ddf.minim.analysis.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
//import processing.video.*;
import processing.serial.*;
import java.io.IOException;

Serial myPort;
String myString = null;

//Movie myMovie;

Minim minim;
AudioPlayer g_bgm;
AudioSample []g_effect;

FFT fft;
//Gain       gain;

boolean g_bIsLoadingScene = true;
boolean g_bIsFadeOut = false;
boolean g_bIsFadeDir = false;

int g_nTimer;

final int D_MAX_PARTICLE = 150;
final int D_IMAGE_WIDTH = 450;
final int D_IMAGE_HEIGHT = 450;
float g_sphereSpeed = 20.0f;
float g_sphereRemvSpeed = 10;
int g_sphereAppCnt = 0;

PImage g_Loading_bkgImg;
PImage g_Game_bkgImg;

float []fParticle_X;
float []fParticle_Y;
float []fParticle_Z;
float []fParticle_Fill;
float []fParticle_Opa;

float fZ = 0.0f;

void Init_LoadingScene(){
  g_Loading_bkgImg = loadImage("challeng_match.jpg");
}

void Loop_LoadingScene(){
  if(!g_bIsLoadingScene) { return; }
  int base_w = 90;
  int base_h = 90;
  
  int nTimer = millis() - g_nTimer;
  
  if( nTimer/1000 > 8 ){
    g_nTimer = millis();
    g_bIsFadeOut = true;
   return;
  }
  pushMatrix();
    translate(-125.0f, -125.0f, -200.0f);
    image(g_Loading_bkgImg, 0, 0, width+250, height+250);
  popMatrix();
  
  noStroke();
  
  for(float j=height/2+height/5 - 10; j<height; j+=base_h+10){
    for(int i=base_w/2; i<fft.specSize(); i+=fft.specSize()/10)
    {
     pushMatrix();
       //line(i, height, i, height - fft.getBand(i) * 8);
       float fheight = height;
       float div = (j/fheight);
       fill(39, 75 + i / 10, 140, div * (div *(255-(height-j)) + 100));
       
       ellipse(i, j, 
       base_w,
       base_h
       );
       
       fill(2, 20, 53);
       ellipse(i, j, 
       base_w / 3 + fft.getFreq(i) %  base_w,
       base_h / 3 + fft.getFreq(i) %  base_h
       );
     popMatrix();
    }
  }
}

void Init_GameScene(){
  g_sphereSpeed = 20.0f;
  g_sphereRemvSpeed = 1;
  g_sphereAppCnt = 0;
  
  g_Game_bkgImg = loadImage("bkgimg.jpg");
  
  fParticle_X = new float[D_MAX_PARTICLE];
  fParticle_Y = new float[D_MAX_PARTICLE];
  fParticle_Z = new float[D_MAX_PARTICLE];
  fParticle_Fill = new float[D_MAX_PARTICLE];
  fParticle_Opa = new float[D_MAX_PARTICLE];
  
  int halfwidth = width / 2;
  int halfheight = height / 2;
  for(int i=0; i<D_MAX_PARTICLE; i++){
    fParticle_X[i] = random(0, D_IMAGE_WIDTH-50) + halfwidth - D_IMAGE_WIDTH / 2 + 20;
    fParticle_Y[i] = random(0, D_IMAGE_HEIGHT-50) + halfheight - D_IMAGE_HEIGHT / 2 + 20;
    fParticle_Z[i] = - 201.0f;
    fParticle_Fill[i] = random(0, 1);
    fParticle_Opa[i] = 0;
    if( fParticle_Fill[i] > 0.5 ){
      fParticle_Fill[i] = 255;
    }else{
      fParticle_Fill[i] = 80;
    }
  }       
}

void Loop_GameScene(){
  if( g_bIsLoadingScene ) { return; }
  
  g_sphereSpeed = fft.getFreq(fft.specSize()-200);
  g_sphereAppCnt = (int)(fft.getFreq(  fft.specSize()/2));
  
  if( g_bgm.isPlaying() == false ){
    g_sphereSpeed = 10;
    g_sphereAppCnt = D_MAX_PARTICLE;
  }
      
  pushMatrix();
    translate(-125.0f, -125.0f, -200.0f);
    image(g_Game_bkgImg, 0, 0, width+250, height+250);
  popMatrix();
  
  stroke(255);
  float startY = height / 5;
  float beforeX = 0;
  float beforeY = startY;
  float lineWidLen = fft.specSize()/200;
  float halflineWidLen =lineWidLen/2;
  for(int i=0; i<width; i++)
  {
   float Freq = fft.getFreq(i*30) % (height / 10);
   float Fx = i*lineWidLen*3;
   float Fy = startY;
   float Tx = Fx+halflineWidLen;
   float Ty = Fy + Freq;
   
   pushMatrix();
     translate(0.0f, 0.0f, 0.0f);
     line(Fx, Fy,
     Tx, Ty );
     
     line(Tx, Ty,
     Fx + lineWidLen, Fy );
     
     line(Fx + lineWidLen, Fy,
     Fx + lineWidLen*2, Fy - Freq*2);
     
     line(Fx + lineWidLen*2, Fy - Freq*2,
     Fx + lineWidLen*3, Fy);
   popMatrix();
  }
  
  stroke(0);
  lights();
  
  noStroke();
  
  int halfwidth = width / 2;
  int halfheight = height / 2;
  int halfImgW = D_IMAGE_WIDTH / 2;
  int halfImgH = D_IMAGE_HEIGHT / 2;
  
  for(int i=0; i<D_MAX_PARTICLE; i++)
  {
    pushMatrix();
      translate(fParticle_X[i], fParticle_Y[i], fParticle_Z[i]);
        
      fill(fParticle_Fill[i], fParticle_Fill[i], fParticle_Fill[i], fParticle_Opa[i]);
      sphere(15.0f);
      
      if( fParticle_Z[i] < -200.0f )
      {
        fParticle_Opa[i] -= g_sphereRemvSpeed;
        fParticle_Z[i] = - 201.0f;
        if( g_bgm.isPlaying() && fParticle_Opa[i] <= 0 && i<g_sphereAppCnt){
          fParticle_X[i] = random(0, D_IMAGE_WIDTH-50) + halfwidth - halfImgW + 50;
          fParticle_Y[i] = random(0, D_IMAGE_HEIGHT-50) + halfheight - halfImgH + 20;
          fParticle_Z[i] = random(0, 1000);
          fParticle_Opa[i] = 255;
          }
        }
        else{
          fParticle_Z[i] -= g_sphereSpeed;
      }
    popMatrix();
  }
  noLights();
}

void Loop_FadeOut(){
 if(!g_bIsFadeOut) { return; } 
 int nTimer = millis() - g_nTimer;
 float OutOpacity, InOpacity;
 if(g_bIsFadeDir == false){
   OutOpacity = (nTimer/20) * 10;
   fill(255, 255, 255, OutOpacity );
   if( OutOpacity >= 255 ){
     g_bIsFadeDir = true;
     g_bIsLoadingScene = false;
     g_nTimer = millis();
     AudioPlayer narr = minim.loadFile("start_game.wav", 2048);
     narr.play();
   }
 }
 else{
   InOpacity = 255 - (nTimer/20) * 10;
   if( InOpacity <= 0 ){
     g_bIsFadeOut = false;
     return;
   }
   println(InOpacity);
   fill(255, 255, 255, InOpacity);
   
 }
 
 rect(0, 0, width, height);
 
 //g_bIsFadeDir
}
void setup() {
  size(800, 800, P3D);
  //fullScreen(P3D, 2);
  minim = new Minim(this);
  g_bgm = minim.loadFile("fight.wav", 2048);
  g_bgm.play();
  
  g_effect = new AudioSample[4];
  
  g_effect[0] = minim.loadSample("1.wav");
  g_effect[1] = minim.loadSample("2.wav");
  g_effect[2] = minim.loadSample("3.wav");
  g_effect[3] = minim.loadSample("4.wav");
  
  g_nTimer = millis();
  
  //gain = new Gain(0.f);
  
  //g_bgm.setGain(100);
  //g_bgm.setVolume(0.5); not supported
  //g_bgm.setBalance(-1);
  //g_bgm.setPan(-1);
  
  fft = new FFT(g_bgm.bufferSize(), g_bgm.sampleRate());
  fft.setFreq(600, 300);
  
   //<>//
  
  
  String portName = Serial.list()[0];
  print(portName);
  //myPort = new Serial(this, portName, 9600); 
  
  Init_GameScene();
  Init_LoadingScene();
}
void serialEvent(Serial p){
    if(myPort.available() > 0){
    try{
        myString = p.readStringUntil('.');
        if( myString != null){
          String[] list = split(myString, ',');
          float Poival = float(list[0])/122 - 1;
          println(Poival);
          g_bgm.setBalance(Poival);
          
          int Btnval = int(list[1]);
          if(Btnval != -1)
          {
            println(Btnval);
            g_effect[Btnval].trigger();
            
          }
          
        }
    }catch(Exception e){
      
    }
  }
}

void draw() {
      fft.forward(g_bgm.mix);
      
      //fft.setFreq(100, 200);
      
      
      Loop_LoadingScene();
      
      Loop_GameScene();
      Loop_FadeOut();
      
      delay(5);
}

void keyPressed()
{
  switch(key) {
    //case '1': gain.setSampleRate(gain.sampleRate() - 10000);; break; //<>//
    case '2': fft.setFreq(600, 300);; break;
    case '3': fft.setBand(20, 150);break;
    case '4': g_effect[0].trigger();break;
    case '5': g_effect[1].trigger();break;
    case '6': g_effect[2].trigger();break;
    case '7': g_effect[3].trigger();break;
  }
}