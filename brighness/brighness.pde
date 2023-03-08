import processing.video.*;
Movie myMovie;
PrintWriter output;
PImage apina;

int vals[];

void setup()
{
  size(132, 120);
  vals = new int[4096*16];
  apina = loadImage("apina.bmp");
  myMovie = new Movie(this, "test.mp4");
  output = createWriter("positions.txt"); 

  frameRate(60);
  myMovie.play();
}

void draw()
{
  image(myMovie, 0, 0);
}

int fra = 0;


int method = 2;

int index = 0;

void movieEvent(Movie m) 
{
  m.read();

  // output.print("0x");
  int bc = 0;
  int nc = 0;
  int by = 0;

  // pack 4 2-bit color values (0-3) into a byte, and print table

  boolean first = true;
  for (int y = 0; y < 132; y+=2) {
    for (int x = 0; x < 120; x+=2) {
      color c1 = myMovie.get(x, y);
      color c2 = myMovie.get(x+1, y);
      color c3 = myMovie.get(x, y+1);
      color c4 = myMovie.get(x+1, y+1);
      int b = (int)(((brightness(c1)+brightness(c2)+brightness(c3)+brightness(c4))/4)/64);
      nc++;
      if (nc == 1) {
        if (!first)
          first = false;
      }
      by = by + (b<<(9-(2*nc-1)));
      if (nc > 4) {
        nc = 0;
        vals[index++] = by & 0xFF;
        by = 0;
      }
    }
  }

  fra++;
  if (fra==63) {
    println("count:" + index);
    // rle pass
    int runlength = 1;
    int current = -1;
    boolean first2 = true;
    output.print("local im4 = {");
    for (int j=0; j<index+1; j++) {
      int val = vals[j];
      if (val == current) {
        runlength++;
      } else {
        if (current != -1 && !first2) {
          output.print(""+runlength);
          output.print(",");

          output.print(""+current);
          output.print(",");
          runlength = 1;
        }
        current = val;
        first2 = false;
      }
    }

    output.print("}");
    output.flush(); // Writes the remaining data to the file
    output.close();



    exit();
  }
}
