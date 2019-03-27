import java.util.Arrays;

boolean showCycle;
boolean snaps;
int maxCycle; // maximum cycles to snap
String event_type; // "nectrig" or "stressed"

int column = 8;       // hard-coded to the Cumulative result

int scrX = 200, scrY = 250;
int yOffset = 10;
int textHeight = 10;

Table[] files;
StringList filenames;
int[] row;
int referenceFileNumber = 0;
Table hpcs;
FloatList lengths = new FloatList();
IntList lowers = new IntList();
IntList uppers = new IntList();
float[] vals;
float[] lastVals;
float minY; float maxY;
int bar_width = 20;
int bar_offset = 15;
float max = -1;
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
    filenames = new StringList();
    for (int intervalNdx=0 ; intervalNdx<hpcs.getRowCount() ; intervalNdx++) {
      String interval = hpcs.getString(intervalNdx,0);
      String[] s1 = split(interval, ',');
      String[] s2 = split(s1[0], '[');
      int lower = int(s2[1]);
      lowers.append(lower);
      String[] s3 = split(s1[1], ')');
      int upper = int(s3[0]);
      uppers.append(upper);
      filenames.append("tsa010.rv0x_"+event_type+"-"+interval+".csv");
    }
    int longestFile = 0;
    files = new Table[filenames.size()];
    for (int fn=0 ; fn<filenames.size() ; fn++) {
      files[fn] = loadTable("../../../data/"+filenames.get(fn), "header");
      if (files[fn] != null && files[fn].getRowCount() > longestFile) {
        referenceFileNumber = fn;
        longestFile = files[fn].getRowCount();
      }
      lengths.append(hpcs.getInt(fn,1)/size_factor);
    }
  
    columnTitle = files[referenceFileNumber].getColumnTitle(column);
    minY = min(lengths.values());
    maxY = max(lengths.values())+2*yOffset;
  
    float filemax = -1;
    for (int fn=0 ; fn<files.length ; fn++ ) {
      if (files[fn] == null) continue;
      vals = new float[files[fn].getRowCount()];
      for (int rndx=0 ; rndx<files[fn].getRowCount() ; rndx++ ) {
        vals[rndx] = files[fn].getFloat(rndx, column);
      }
      filemax = max(vals);
    }
    max = max(max,filemax);
    lastVals = new float[files.length];
    Arrays.fill(lastVals, 0);
    row = new int[files.length];
    Arrays.fill(row, 0);
  } //if (parseArgs(args))
}

int cycle = 0;
void draw() {
  if (cycle < maxCycle-1) {
    if (cycle % snap_interval == 0) {
      textAlign(CENTER);
      background(bg_intensity);
      stroke(0);
      if (showCycle) {
        fill(0); 
        text("cycle = "+cycle, scrX-50, scrY-3*textHeight);
      }
      fill(0);
      text(columnTitle, scrX/2, textHeight);
      begin(cycle, 5*snap_interval);
      end(cycle, maxCycle-5*snap_interval);
    } // end if (cycle % snap_interval == 0) {
    float val = 0;
    for (int fn=0 ; fn<files.length ; fn++) {
      if (files[fn] == null) {
        val = 0; // no events for that band
      } else if (files[fn].getRowCount() < cycle || cycle < files[fn].getFloat(row[fn],1)) { // use the last available number
        val = lastVals[fn];
      } else {
        val = files[fn].getFloat(row[fn], column); // use current row number
        lastVals[fn] = val;
        row[fn]++;
      }
      if (cycle % snap_interval == 0) {
        float x = fn*(bar_width+bar_offset);
        float cY = minY+maxY/2;
        float y = cY-(lengths.get(fn)/2);
        float redgreen = 255*(1-val/max);
        float blue = 255;
        fill(redgreen, redgreen, blue);
        rect(x, y, bar_width, lengths.get(fn));
        fill(0);
        textAlign(LEFT);
        text(hpcs.getString(fn,0), x, y-5);
        text("μ(vHPCs) = "+hpcs.getInt(fn,1), x, y+lengths.get(fn)+15);
        if (snaps) saveFrame("tsa010.rv0x-"+event_type+"-######.png");
      }
    } // end for (int fn=0 ; fn<files.length ; fn++) {
    cycle++;
  } else exit();
}
