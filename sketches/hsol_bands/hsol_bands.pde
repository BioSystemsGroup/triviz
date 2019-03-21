boolean snaps = true;
Table[] files;
Table hpcs;
FloatList lengths = new FloatList();
IntList lowers = new IntList();
IntList uppers = new IntList();
float[] vals;
float minY; float maxY;
int bar_width = 20;
int bar_offset = 15;
int scrX = 200, scrY = 300;
float max = -1;
int row = 0;
int column = 10;
String columnTitle = "unset";
float size_factor = 25.0;
int snap_interval = 10;
int bg_intensity = 235;

void settings() {
  size(scrX, scrY);
}

void setup() {
  String filename = sketchPath()+"/../../tsa010.rv0x_hcount-bands.csv";
  hpcs = loadTable(filename, "header");
  StringList filenames = new StringList();
  for (int intervalNdx=0 ; intervalNdx<hpcs.getRowCount() ; intervalNdx++) {
    String interval = hpcs.getString(intervalNdx,0);
    String[] s1 = split(interval, ',');
    String[] s2 = split(s1[0], '[');
    int lower = int(s2[1]);
    lowers.append(lower);
    String direction = s2[0];
    String[] s3 = split(s1[1], ')');
    int upper = int(s3[0]);
    uppers.append(upper);
    filenames.append("tsa010.rv0x_hsolute-avg-pHPC-pMC-"+interval+".csv");
  }
  files = new Table[filenames.size()];
  for (int fn=0 ; fn<filenames.size() ; fn++) {
    files[fn] = loadTable("../../"+filenames.get(fn), "header");
    lengths.append(hpcs.getInt(fn,1)/size_factor);
  }
  columnTitle = files[0].getColumnTitle(column);
  minY = min(lengths.values())+20;
  maxY = max(lengths.values())+40;
  
  float filemax = -1;
  for (int fn=0 ; fn<files.length ; fn++ ) {
    vals = new float[files[fn].getRowCount()];
    for (int rndx=0 ; rndx<files[fn].getRowCount() ; rndx++ ) {
      vals[rndx] = files[fn].getFloat(rndx, column);
    }
    filemax = max(vals);
  }
  max = max(max,filemax);
}

void draw() {
  if (row < files[0].getRowCount()-1) {
    if (row % snap_interval == 0) {
      background(bg_intensity);
      stroke(0);
      fill(0);
      text("row = "+row, 0, 10);
      fill(0); 
      text(columnTitle, 0, 25);
      begin(5*snap_interval);
      end(files[0].getRowCount()-5*snap_interval);
      float val = 0;
      for (int fn=0 ; fn<files.length ; fn++) {
        val = files[fn].getFloat(row, column);
        float x = fn*(bar_width+bar_offset);
        float cY = minY+maxY/2;
        float y = cY-(lengths.get(fn)/2);
        //fill(0, 0, val/max * bg_intensity); // set the color blue
        //fill(val/max * bg_intensity, 0, 0); // set color red
        //float redgreen = bg_intensity*(1-val/max);
        float redgreen = 255*(1-val/max);
        //float blue = bg_intensity + (255-bg_intensity)*val/max;
        float blue = 255;
        fill(redgreen, redgreen, blue);
        rect(x, y, bar_width, lengths.get(fn));
        fill(0);
        //text(lowers.get(fn), x, cY);
        text(hpcs.getString(fn,0), x, y-5);
        text("μ(vHPCs) = "+hpcs.getInt(fn,1), x, y+lengths.get(fn)+15);
      }
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
