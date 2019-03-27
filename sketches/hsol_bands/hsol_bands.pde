boolean showCycle;
boolean snaps;
int column;

int scrX = 200, scrY = 250;
int yOffset = 10;
int textHeight = 10;

Table[] files;
int referenceFileNumber = 0;
Table hpcs;
FloatList lengths = new FloatList();
IntList lowers = new IntList();
IntList uppers = new IntList();
float[] vals;
float minY; float maxY;
int bar_width = 20;
int bar_offset = 15;
float max = -1;
int row = 0;
String columnTitle = "unset";
float size_factor = 25.0;
int snap_interval = 10;
int bg_intensity = 235;

void settings() {
  size(scrX, scrY);
}

void setup() {
  if (parseArgs(args)) usage("Could not parse arguments.");
  else {
    String filename = sketchPath()+"/../../../data/tsa010.rv0x_hcount-bands.csv";
    hpcs = loadTable(filename, "header");
    StringList filenames = new StringList();
    for (int intervalNdx=0 ; intervalNdx<hpcs.getRowCount() ; intervalNdx++) {
      String interval = hpcs.getString(intervalNdx,0);
      String[] s1 = split(interval, ',');
      String[] s2 = split(s1[0], '[');
      int lower = int(s2[1]);
      lowers.append(lower);
      String[] s3 = split(s1[1], ')');
      int upper = int(s3[0]);
      uppers.append(upper);
      filenames.append("tsa010.rv0x_hsolute-avg-pHPC-pMC-"+interval+"-ma.csv");
    }
    files = new Table[filenames.size()];
    for (int fn=0 ; fn<filenames.size() ; fn++) {
      files[fn] = loadTable("../../../data/"+filenames.get(fn), "header");
      lengths.append(hpcs.getInt(fn,1)/size_factor);
    }
    if (column <= 0 || column >= files[referenceFileNumber].getColumnCount()) usage("Column "+column+" invalid.");
    columnTitle = files[referenceFileNumber].getColumnTitle(column);
    minY = min(lengths.values());
    maxY = max(lengths.values())+2*yOffset;
  
    float filemax = -1;
    for (int fn=0 ; fn<files.length ; fn++ ) {
      vals = new float[files[fn].getRowCount()];
      for (int rndx=0 ; rndx<files[fn].getRowCount() ; rndx++ ) {
        vals[rndx] = files[fn].getFloat(rndx, column);
      }
      filemax = max(vals);
    }
    max = max(max,filemax);
  } // end if (args.length < 3) {
}

void draw() {
  if (row < files[referenceFileNumber].getRowCount()-1) {
    if (row % snap_interval == 0) {
      textAlign(CENTER);
      background(bg_intensity);
      stroke(0);
      if (showCycle) {
        fill(0);
        text("cycle = "+row, scrX-50, scrY-3*textHeight);
      }
      fill(0); 
      text(columnTitle, scrX/2, textHeight);
      begin(row, 5*snap_interval);
      end(row, files[referenceFileNumber].getRowCount()-5*snap_interval);
      float val = 0;
      for (int fn=0 ; fn<files.length ; fn++) {
        val = files[fn].getFloat(row, column);
        float x = fn*(bar_width+bar_offset);
        float cY = minY+maxY/2;
        float y = cY-(lengths.get(fn)/2);
        float redgreen = 255*(1-val/max);
        float blue = 255;
        fill(redgreen, redgreen, blue);
        rect(x, y, bar_width, lengths.get(fn));
        fill(0);
        textAlign(LEFT);
        text(hpcs.getString(fn,0), x, y-textHeight/2);
        text("μ(vHPCs) = "+hpcs.getInt(fn,1), x, y+lengths.get(fn)+1.5*textHeight);
      }
      if (snaps) saveFrame("tsa010.rv0x-"+columnTitle+"-######.png");
    }
    row++;
  } else exit();
}
