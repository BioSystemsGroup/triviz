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
