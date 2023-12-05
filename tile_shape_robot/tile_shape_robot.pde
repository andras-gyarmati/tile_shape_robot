class Point {
  int x, y;

  Point(int x, int y) {
    this.x = x;
    this.y = y;
  }

  Point add(Point other) {
    return new Point(this.x + other.x, this.y + other.y);
  }

  Point clone() {
    return new Point(this.x, this.y);
  }
}

class TriangularLattice {
  int gridSize;
  float radius;
  boolean[][] tiles;
  Point robotPosition;
  boolean robotHasTile;
  int lineBuildState;
  int searchTileDirState;
  String[] searchTileDirs;
  boolean finishedLine;
  int moveCount = 0;
  int tileCount = 0;

  TriangularLattice(int n, int rx, int ry) {
    this.gridSize = n;
    this.radius = width / (float)this.gridSize;
    this.tiles = new boolean[this.gridSize][this.gridSize];
    this.robotPosition = new Point(rx, ry);
    this.robotHasTile = false;
    this.lineBuildState = 0;
    this.searchTileDirState = 0;
    this.searchTileDirs = new String[]{"N", "NW", "SW"};
    this.finishedLine = false;
  }

  void serializeLatticeState() {
    lattices_output.println(simCount + "," + this.tileCount + "," + this.moveCount);
    lattices_output.flush();
  }

  void addTile(int x, int y) {
    if (x % 2 != y % 2) {
      println("ERROR: x % 2 !== y % 2");
      return;
    }
    if (!this.tiles[x][y]) {
      this.tiles[x][y] = true;
      this.tileCount++;
    }
  }

  void moveRobot(String dir) {
    Point displacement = dirToDisplacement(dir);
    this.robotPosition = this.robotPosition.add(displacement);
    this.moveCount++;
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
    Point nextPos = this.robotPosition.add(dirToDisplacement("SE"));
    boolean isEasternmostCol = true;
    for (boolean cell : this.tiles[nextPos.x]) {
      if (cell) {
        isEasternmostCol = false;
      }
    }
    if (isEasternmostCol) {
      this.lineBuildState = 4;
      this.finishedLine = true;
      return;
    }
    this.robotHasTile = true;
    this.tiles[this.robotPosition.x][this.robotPosition.y] = false;
    if (tileExists(nextPos)) {
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
    println("ERROR: can not go " + dir + ".");
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
int gridSize = 128;
int simCount = 0;
PrintWriter lattices_output;

void setup() {
  size(1024, 1024);

  lattices_output = createWriter("lattices.csv");
  lattices_output.println("id,tile_count,move_count");

  dirs.add("N");
  dirs.add("NE");
  dirs.add("SE");
  dirs.add("S");
  dirs.add("SW");
  dirs.add("NW");

  initLattice(gridSize);

  frameRate(60);
}

void initLattice(int gridSize) {
  Point robotPos = new Point(floor(gridSize / 3), floor(gridSize / 3 * 2));
  lattice = new TriangularLattice(gridSize, robotPos.x, robotPos.y);
  lattice.addTile(robotPos.x, robotPos.y);
  for (int i = 0; i < 10; i++) {
    String rd = getRandomDir();
    Point dp = dirToDisplacement(rd);
    //println(robotPos.x, robotPos.y, rd, dp.x, dp.y);
    robotPos = robotPos.add(dp);
    lattice.addTile(robotPos.x, robotPos.y);
    //println(robotPos.x, robotPos.y);
  }
}

void draw() {
  translate(0, height); // moves the origin to bottom left
  scale(1, -1); // flips the y values so y increases "up"
  background(255);
  lattice.buildLine();
  lattice.display();
  if (lattice.finishedLine) {
    lattice.serializeLatticeState();
    simCount++;
    initLattice(gridSize);
    println("finished");
  }
}
