class Point {
  int x, y;

  Point(int x, int y) {
    this.x = x;
    this.y = y;
  }

  Point add(Point other) {
    return new Point(this.x + other.x, this.y + other.y);
  }
}

class TriangularLattice {
  int n;
  float radius;
  boolean[][] tiles;
  Point robotPosition;
  boolean robotHasTile;
  int lineBuildState;
  int searchTileDirState;
  String[] searchTileDirs;
  boolean finishedLine;
  boolean robotFinishedLine;

  TriangularLattice(int n, int rx, int ry) {
    this.n = n;
    this.radius = width / (float)this.n;
    this.tiles = new boolean[this.n][this.n];
    this.robotPosition = new Point(rx, ry);
    this.robotHasTile = false;
    this.lineBuildState = 0;
    this.searchTileDirState = 0;
    this.searchTileDirs = new String[]{"N", "NW", "SW"};
    this.finishedLine = false;
    this.robotFinishedLine = false;
  }

  void addTile(int x, int y) {
    if (x % 2 != y % 2) {
      println("x % 2 !== y % 2");
      return;
    }
    this.tiles[x][y] = true;
  }

  void moveRobot(String dir) {
    Point displacement = dirToDisplacement(dir);
    this.robotPosition = this.robotPosition.add(displacement);
  }

  void buildLine() {
    switch (this.lineBuildState) {
    case 0:
      goSouth();
      break;
    case 1:
      searchTile();
      break;
    case 2:
      moveTileSE();
      break;
    case 3:
      moveTileS();
      break;
    }
  }

  void goSouth() {
    Point nextPos = this.robotPosition.add(dirToDisplacement("S"));
    if (tileExists(nextPos)) {
      this.moveRobot("S");
    } else {
      this.lineBuildState = 1;
    }
  }

  void searchTile() {
    boolean movedInThisRound = false;
    int tries = 3;
    while (!movedInThisRound && tries > 0) {
      String currDir = this.searchTileDirs[this.searchTileDirState];
      Point nextPos = this.robotPosition.add(dirToDisplacement(currDir));
      if (tileExists(nextPos)) {
        this.moveRobot(currDir);
        movedInThisRound = true;
      } else {
        tries--;
      }
      this.searchTileDirState = (this.searchTileDirState + 1) % 3;
    }
    if (tries == 0) {
      this.lineBuildState = 2;
    }
  }

  void moveTileSE() {
    // ha van N es N
    Point nextPosE = this.robotPosition.add(dirToDisplacement("SE"));
    Point nextPosNE = this.robotPosition.add(dirToDisplacement("NE"));
    Point nextPosW = this.robotPosition.add(dirToDisplacement("NW"));
    Point nextPosSW = this.robotPosition.add(dirToDisplacement("SW"));
    //Point nextPosN = this.robotPosition.add(dirToDisplacement("N"));
    Point nextPosS = this.robotPosition.add(dirToDisplacement("S"));
    //boolean isEasternmostCol = true;
    this.robotFinishedLine = true;
    for (boolean cell : this.tiles[nextPosE.x]) {
      if (cell) {
        //isEasternmostCol = false;
        this.robotFinishedLine = false;
      }
    }
    if(robotFinishedLine){
      for (boolean cell : this.tiles[nextPosSW.x]) {
        if (cell) {
          this.robotFinishedLine = false;
      }
    }
    }
    /*for (boolean cell : this.tiles[nextPosS.x]) {
      if ((tileExists(nextPosE) || tileExists(nextPosW) || tileExists(nextPosSW) || tileExists(nextPosNE))) {
        this.robotFinishedLine = false;
        this.lineBuildState = 0;
      }
    }*/
    /*if ((tileExists(nextPosE) || tileExists(nextPosW) || tileExists(nextPosSW) || tileExists(nextPosNE))) {
      this.robotFinishedLine = false;
      this.lineBuildState = 0;
    }*/
    /*if ((!tileExists(nextPosE) && !tileExists(nextPosW) && !tileExists(nextPosSW) && !tileExists(nextPosNE))) {
      this.robotFinishedLine = true;
    }
    }*/
    if (this.robotFinishedLine) {
      this.lineBuildState = 4; 
      this.finishedLine = true;
      return;
      }
    this.robotHasTile = true;
    this.tiles[this.robotPosition.x][this.robotPosition.y] = false;
    if (tileExists(nextPosE) || tileExists(nextPosW)) {
      this.moveRobot("SE");
      this.lineBuildState = 3;
    } else {
      this.moveRobot("SE");
      this.robotHasTile = false;
      this.tiles[this.robotPosition.x][this.robotPosition.y] = true;
      this.lineBuildState = 0;
    }
  }

  void moveTileS() {
    Point nextPos = this.robotPosition.add(dirToDisplacement("S"));
    if (tileExists(nextPos)) {
      this.moveRobot("S");
    } else {
      this.moveRobot("S");
      this.robotHasTile = false;
      this.tiles[this.robotPosition.x][this.robotPosition.y] = true;
      this.lineBuildState = 0;
    }
  }
  
boolean tileExists(Point pos) {
    return pos.x >= 0 && pos.x < tiles.length && pos.y >= 0 && pos.y < tiles[0].length && tiles[pos.x][pos.y];
}

void display() {
    stroke(255);
    for (int x = 0; x < tiles.length; x++) {
      for (int y = 0; y < tiles[x].length; y++) {
        if (!tiles[x][y]) continue;
        float pixelX = x * this.radius * 0.758f * 2 + this.radius;
        float pixelY = (y * this.radius * 0.871f);
        if (this.finishedLine) {
          drawHexagon(pixelX, pixelY, this.radius, color(0, 200, 0));
        } else {
          drawHexagon(pixelX, pixelY, this.radius, color(128, 128, 128));
        }
        if (this.robotPosition.x == x && this.robotPosition.y == y) {
          drawRobot(pixelX, pixelY, this.radius / 2);
        }
      }
    }
}

String getRandomDir() {
  return dirs.get(floor(random(dirs.size())));
}

Point dirToDisplacement(String dir) {
  switch (dir) {
  case "N":
    return new Point(0, 2);
  case "NE":
    return new Point(1, 1);
  case "NW":
    return new Point(-1, 1);
  case "S":
    return new Point(0, -2);
  case "SE":
    return new Point(1, -1);
  case "SW":
    return new Point(-1, -1);
  default:
    println("can not go " + dir + ".");
    return new Point(0, 0);
  }
}

void drawRobot(float x, float y, float radius) {
  noStroke();
  fill(0);
  ellipse(x, y, radius, radius);
}

void drawHexagon(float x, float y, float radius, color col) {
  fill(col);
  stroke(255);
  beginShape();
  for (float angle = 0; angle < TWO_PI; angle += TWO_PI / 6) {
    float xVertex = x + cos(angle) * radius;
    float yVertex = y + sin(angle) * radius;
    vertex(xVertex, yVertex);
  }
  endShape(CLOSE);
}

TriangularLattice lattice;
ArrayList<String> dirs = new ArrayList<String>();

void setup() {
  size(1000, 1000);
  int len = 36;
  Point p = new Point(floor(width / len / 3), floor(height / len / 1));

  lattice = new TriangularLattice(len, p.x, p.y);

  dirs.add("N");
  dirs.add("NE");
  dirs.add("SE");
  dirs.add("S");
  dirs.add("SW");
  dirs.add("NW");
  
  lattice.addTile(p.x, p.y);
  for (int i = 0; i < 10; i++) {
    String rd = getRandomDir();
    println(rd); //fajlba
    // writeToFile(filename, rd);
    Point dp = dirToDisplacement(rd);
    println(dp.x, dp.y); //fajlba
    // writeToFile(filename, dp.x, dp.y);
    p = p.add(dp);
    lattice.addTile(p.x, p.y);
    println(p.x, p.y); // fajlba
    // writeToFile(filename, p.x, p.y);
  }

  frameRate(50);
}

void draw() {
  translate(0, height); // moves the origin to bottom left
  scale(1, -1); // flips the y values so y increases "up"
  background(255);
  lattice.buildLine();
  lattice.display();
}

void readFromFile(String fileName){
  String[] lines = loadStrings(fileName);
  println("number of lines:" + lines.length);
  for (int i = 0 ; i < lines.length; i++) {
    println(lines[i]);
  }
  // beolvasas
}

void writeToFile(filename, str1, str2){
  // kiir a setupbol
}