PShape mouse;

boolean snaps = true;
int column = 1;       // hard-coded to the Solute type 1 = APAP, 6 = ALT

Table body_file;
float[] vals;
int scrX = 200, scrY = 300;
float max = -1;
int row = 0;
String columnTitle = "unset";
float size_factor = 100.0;
int snap_interval = 10;
int bg_intensity = 235;

void settings() {
  size(scrX, scrY);
}

void setup() {
  mouse = setupMouse();
  String body_fn = "tsa010.rv0x_body-avg.csv";
  Table body_file = loadTable("../../../data/"+body_fn, "header");
  columnTitle = body_file.getColumnTitle(column);
  print(columnTitle);
  vals = new float[body_file.getRowCount()];
  for (int rndx=0 ; rndx<body_file.getRowCount() ; rndx++) {
    vals[rndx] = body_file.getFloat(rndx, column);
  }
  max = max(vals);
}

void draw() {
  if (row < vals.length-1) {
    if (row % snap_interval == 0) {
      background(bg_intensity);
      stroke(0);
      fill(0);
      text("row = "+row, 0, 10);
      fill(0); 
      text(columnTitle, 0, 25);
      begin(5*snap_interval);
      end(vals.length-5*snap_interval);
      float val = vals[row];
      float redgreen = 255*(1-val/max);
      float blue = 255;
      fill(redgreen, redgreen, blue);
 shape(mouse, scrX/2-size_factor/2, scrY/2-size_factor/2, size_factor, size_factor);
      fill(0);
      if (snaps) saveFrame("tsa010.rv0x-"+columnTitle+"-######.png");
    }
    row++;
  }
}

void begin(int lower) {
  if (row < lower) {
    fill(255,0,0);
    text("B", 190, 10);
  }
}
void end(int upper) {
  if (row > upper) {
    fill(255,0,0);
    text("E", 190, 10);
  }
}  
