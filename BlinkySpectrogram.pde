/*
* A simple one-line Spectrogram-type visualizer for BlinkyTape
*/

import processing.serial.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

//BlinkyTape bt = null;
ArrayList<BlinkyTape> bts = new ArrayList<BlinkyTape>();
Minim minim;
AudioInput in;
AudioPlayer song;
FFT fft;
PFont font;
SerialSelector s;


boolean beat, mp3, randomAnim;

float amp;
float falloff = 0.99;
float fftmax;
int num_leds;
float[] last_fft;


void setup() {
  fftmax = 0.001;
  num_leds = 60;
  last_fft = new float[num_leds];

  for (int i = 0 ; i < num_leds; i++) {
    last_fft[i] = 0.0;
  }
  
  s = new SerialSelector();
  
  frameRate(60);
  size(800, 500, P2D); //window size

  colorMode(HSB, 100);
  background(10);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 2048);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.logAverages(num_leds, 20);
  //rectMode(CORNERS);
  
  //Initiate variables
  
}


void draw()
{
  fft.forward(in.mix);
  //float[] leds = new float[fft.avgSize()];
  //Take the selected serial and create a BlinkyTape object out of it
  if(s != null && s.m_chosen){
    s.m_chosen = false; //So there aren't multiple BlinkyTapes of the same serial
    bts.add(new BlinkyTape(this, s.m_port, num_leds));
    s = null; //So there aren't multiple BlinkyTapes of the same serial
  }
      
  for(int j = 0; j < bts.size(); j++) {
    for(int i = 0; i < num_leds; i++) {
      float fftout = fft.getAvg(i);
      //print("fftbin ",i,"=",fftout,"\n");
      if (fftout > last_fft[i]) {
        bts.get(j).pushPixel(map(fftout));
        last_fft[i] = fftout;
      } else {
        last_fft[i] = ((last_fft[i] + fftout) / 2) * falloff;
        bts.get(j).pushPixel(map(last_fft[i]));
      }
    }
    bts.get(j).update();
  }
}

color map(float fftinput) {
  color colorout;
  //print("fftmax=",fftmax,"\n");
  
  if (fftinput > fftmax) {
    fftmax = fftinput;
  } else {
    fftmax = fftmax * 0.999;
  }
  
  int hue = floor((fftinput / fftmax) * 100);
  int sat = 100;
  int brite = floor(pow(((fftinput / fftmax) + 1), 6.7));
  
  colorout = color(hue, sat, brite);
  
  return colorout;
}

