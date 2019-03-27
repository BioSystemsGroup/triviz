PShape mouse;

boolean showCycle;
boolean snaps;
int column;

int scrX = 200, scrY = 250;
int xOffset = 20;
int textOffset = 10;

Table body_file;
float[] vals;
float max = -1;
int row = 0;
String columnTitle = "unset";
float size_factor = 120.0;
int snap_interval = 10;
int bg_intensity = 235;

void settings() {
  size(scrX, scrY);
}

void setup() {
  if (parseArgs(args)) usage("Could not parse arguents.");
  else {
    mouse = setupMouse();
    String body_fn = "tsa010.rv0x_body-avg.csv";
    Table body_file = loadTable("../../../data/"+body_fn, "header");
    if (column <= 0 || column >= body_file.getColumnCount()) usage("Column "+column+" invalid.");
    columnTitle = body_file.getColumnTitle(column);
    vals = new float[body_file.getRowCount()];
    for (int rndx=0 ; rndx<body_file.getRowCount() ; rndx++) {
      vals[rndx] = body_file.getFloat(rndx, column);
    }
    max = max(vals);
  } // end if (parseArgs(args))
}

void draw() {
  if (row < vals.length-1) {
    if (row % snap_interval == 0) {
      background(bg_intensity);
      textAlign(CENTER);
      textSize(12);
      stroke(0);
      fill(0); 
      text(columnTitle, scrX/2, textOffset);
      begin(row, 5*snap_interval);
      end(row, vals.length-5*snap_interval);
      float val = vals[row];
      float redgreen = 255*(1-val/max);
      float blue = 255;
      fill(redgreen, redgreen, blue);
 shape(mouse, scrX/2-size_factor/2-xOffset, scrY/2-size_factor/2, size_factor, size_factor);
      fill(0);
      if (snaps) saveFrame("tsa010.rv0x-"+columnTitle+"-######.png");
      
      fill(0);
      if (showCycle) {
        textSize(20);
        textAlign(LEFT);
        text("cycle = ", scrX/2-75, scrY-textOffset);
        textAlign(RIGHT);
        text(row, scrX/2+75, scrY-textOffset);
        noFill();
        rect(scrX/2-80, scrY-30, 160, 25);
      }
      
    }
    row++;
  } else exit();
}
