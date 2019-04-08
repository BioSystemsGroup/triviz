void usage(String error) {
  println("Error: "+error);
  exit();
}

boolean parseArgs(String[] a) {
  if (a.length < 3) return true;
  showCycle = boolean(a[0]);
  snaps = boolean(a[1]);
  exp = a[2];
  column = int(a[3]);
  useMA = boolean(a[4]);
  data_dir = a[5];
  println("Running with showCycle = "+showCycle+", snaps = "+snaps+", column = "+column+", useMA = "+useMA+", data_dir = "+data_dir);
  return false;
}

/**
 * Function stolen from: https://www.processing.org/examples/directorylist.html
 */
// This function returns all the files in a directory as an array of Strings  
String[] ls(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

void begin(int parameter, int lower) {
  if (parameter < lower) {
    fill(255,0,0);
    text("B", 190, textHeight);
  }
}
void end(int parameter, int upper) {
  if (parameter > upper) {
    fill(255,0,0);
    text("E", 190, textHeight);
  }
}  
