PFont font;
int ypos;
//for making a white background on first turn (subsequent steps layer alphas - messy if you start that way)
boolean init = true;
//number of random walk steps in one go
int numRand = 2;
//number of times to repeat in one draw (so not throttled by framerate)
int drawNum = 1;
//cumulative record of outcomes for showing distribution
int[][] dist;
//number of points to take distribution values. Will be split over screen
int samplePoints = 16;
int samplePointIndex = 0;
//top and bottom line of `bridge', in normalised values, to mark edge
//top is zero, bottom is 1.
double bottom = 0.55, top = 0.45;
//used for finding odds of being inside the lines at each sample point
int[] numInsideAtThisSamplePoint;
int[] totalNumAtThisSamplePoint;

//For lerping a range of colours for the distributions
//Takes advantage of the fact that lerping past 1 reaches new colours (see below)
color from = color(61, 152, 48);
color to = color(0, 102, 153);

void setup() {

  size(800, 400);

  stroke(0);

  font = loadFont("Gautami-14.vlw");
  textFont(font, 14);

  //one index for each pixel on y axis. 
  dist = new int[samplePoints][height];
  numInsideAtThisSamplePoint = new int[samplePoints];
  totalNumAtThisSamplePoint = new int[samplePoints];

  randomSeed(1);
}

void draw() {

  if (init) {
    background(255);
    init = false;
  }

  for (int r = 0; r < drawNum; r++) {

    stroke(100);
    fill(255, 2);

    rect(0, 0, width, height);

    noFill();

    ypos = 0;
    samplePointIndex = 0;

    for (int x = 0; x < width - 1; x++) {

      //draw random walk points themselves
      //Colour differently if it's off the the edge of the bridge
      if (onTheBridge(ypos)) {
        stroke(100);
      } 
      else {
        stroke(200, 150, 150);
      }


      ellipse(x, ((float) ypos) + (height / 2), 3, 3);

      //random-walk the y position
      //number of random steps per turn set by numRand
      for (int n = 0; n < numRand; n++) {
        if (random(1) > 0.5) {
          ypos -= 1;
        } 
        else {
          ypos += 1;
        }
      }//end for int n

      //record values for each point along the width, set by samplePoint
      if (x % (width / samplePoints) == 0) {

        //record both total number of random walkers passing through
        totalNumAtThisSamplePoint[samplePointIndex]++;

        //and how many fall inside the top/bottom range        
        //Compensate for ypos being negative as well as positive: ypos + (height / 2)
        //if (ypos + (height / 2) > ((double) height * top)
        //  && ypos + (height / 2) < ((double) height * bottom)) {
        //  numInsideAtThisSamplePoint[samplePointIndex]++;
        //}

        if (onTheBridge(ypos)) {
          numInsideAtThisSamplePoint[samplePointIndex]++;
        }

        //increment the distribution record for the last value
        //only record those that can be displayed, i.e. that fit into
        //the height of the window
        //Also, compensate for negative values
        if (ypos > (0 - (height / 2)) && ypos < (height / 2)) {
          dist[samplePointIndex][ypos + (height / 2)]++;
        }

        //increment samplePointIndex
        samplePointIndex++;
      }//end if x%samplePoint
    }//end for int x
  }//end for drawNum



  //used to set percent values of people falling off bridge
  double val;

  //*******
  //DRAW IT
  //*******

  //numValsToAdd will sum this number of y-axis bin neighbours, rather than draw them all. 
  int numValsToAdd = 4;

  //loop through each samplePoint - each index of recorded random walk values along the width
  for (int samplePointLoop = 0; samplePointLoop < samplePoints; samplePointLoop++) {

    strokeWeight(2);


    //loop across the recorded values for each index. Total a certain number at once
    //use numValsToAdd to set that.
    for (int h = 0; h < height; h += numValsToAdd) {

      //make drawing total: sum up a number of neighbournig vals
      int numValsTot = 0;

      //totalling a single bin
      for (int i = 0; i < numValsToAdd; i++) {
        numValsTot += dist[samplePointLoop][h + i];
      }

      //test for division by zero
      //don't draw these first-line values.                         
      if (width / (samplePointLoop + 1) != width) {

        //Different colour for each distribution
        if (onTheBridge(h - (height/2))) {
          stroke(lerpColor(from, to, ((float) samplePointLoop/(float) samplePoints)*11));
        } 
        else {
          stroke(lerpColor(from, to, ((float) samplePointLoop/(float) samplePoints)*10));
        }    


        line((width / (samplePoints) * samplePointLoop), h, 
        ((width / (samplePoints) * samplePointLoop)) - (numValsTot), h);
      }
    }//end int h

      //Write odds of being inside the line...
    //need to clear a white space since we're using alphas to fade the background
    stroke(255);
    fill(255);
    rect(1 + ((width / (samplePoints) * samplePointLoop)), height - 30, 55, 40);

    stroke(0);
    fill(0);

    val = (double) (1 - (numInsideAtThisSamplePoint[samplePointLoop])
      / (double) totalNumAtThisSamplePoint[samplePointLoop]);

    //percentage
    val *= 100;

    text("" + (int) val + "%", 4 + (width / (samplePoints) * samplePointLoop), height - 20);
  }//end int samplePointLoop

  //draw division lines for inside, outside
  stroke(0);
  strokeWeight(1);

  //top
  line(0, (float) top * height, width, (float) top * height);
  //bottom
  line(0, (float) bottom * height, width, (float) bottom * height);
}

boolean onTheBridge(int ypos) {

  if (ypos + (height / 2) > ((double) height * top)
    && ypos + (height / 2) < ((double) height * bottom)) {
    return true;
  } 
  else {
    return false;
  }
}

void keyPressed() {

  dist = new int[samplePoints][height];
  numInsideAtThisSamplePoint = new int[samplePoints];
  totalNumAtThisSamplePoint = new int[samplePoints];
  
  init = true;
  
}

