import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;

public class Main {
    public static void main(String[] args) throws IOException {
        TriangularLattice lattice = null;
        ArrayList<String> dirs = new ArrayList<String>();
        int gridSize = 128;
        int simCount = 0;
        String filename = "lattices.csv";
        Writer lattices_output = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(filename, false), StandardCharsets.UTF_8));
        lattices_output.append("id,tile_count,move_count\n");
        lattices_output.flush();
        lattices_output.close();
        dirs.add("N");
        dirs.add("NE");
        dirs.add("SE");
        dirs.add("S");
        dirs.add("SW");
        dirs.add("NW");
        for (int i = 0; i < 1000; i++) {
            lattice = initLattice(gridSize, dirs);
            while (!lattice.finishedLine) {
                lattice.buildLine();
            }
            lattice.serializeLatticeState(simCount);
            simCount++;
            lattice = initLattice(gridSize, dirs);
        }
    }

    static TriangularLattice initLattice(int gridSize, ArrayList<String> dirs) {
        Point robotPos = new Point((int) Math.floor(gridSize / 3.0), (int) Math.floor(gridSize / 3.0 * 2));
        // make sure robotPos coordinates each are divisible by 2 for the other parts of the algorithm to work
        robotPos.x = robotPos.x % 2 == 0 ? robotPos.x : robotPos.x + 1;
        robotPos.y = robotPos.y % 2 == 0 ? robotPos.y : robotPos.y + 1;
        TriangularLattice lattice = new TriangularLattice(gridSize, robotPos.x, robotPos.y);
        lattice.addTile(robotPos.x, robotPos.y);
        for (int i = 0; i < 10; i++) {
            String rd = getRandomDir(dirs);
            Point dp = lattice.dirToDisplacement(rd);
            robotPos = robotPos.add(dp);
            lattice.addTile(robotPos.x, robotPos.y);
        }
        return lattice;
    }

    static String getRandomDir(ArrayList<String> dirs) {
        return dirs.get((int) Math.floor(Math.random() * dirs.size()));
    }
}

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
    int gridSize;
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
        this.tiles = new boolean[this.gridSize][this.gridSize];
        this.robotPosition = new Point(rx, ry);
        this.robotHasTile = false;
        this.lineBuildState = 0;
        this.searchTileDirState = 0;
        this.searchTileDirs = new String[]{"N", "NW", "SW"};
        this.finishedLine = false;
    }

    void serializeLatticeState(int simCount) throws IOException {
        Writer lattices_output = new BufferedWriter(new OutputStreamWriter(new FileOutputStream("lattices.csv", true), StandardCharsets.UTF_8));
        String line = "%d,%d,%d\n".formatted(simCount, this.tileCount, this.moveCount);
//        System.out.println(line);
        lattices_output.append(line);
        lattices_output.flush();
        lattices_output.close();
    }

    void addTile(int x, int y) {
        if (x % 2 != y % 2) {
            System.out.printf("Invalid tile position (%d, %d)%n", x, y);
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
            case 0 -> goSouth();
            case 1 -> searchTile();
            case 2 -> moveTileSE();
            case 3 -> moveTileS();
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
                break;
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

    Point dirToDisplacement(String dir) {
        return switch (dir) {
            case "N" -> new Point(0, 2);
            case "NE" -> new Point(1, 1);
            case "NW" -> new Point(-1, 1);
            case "S" -> new Point(0, -2);
            case "SE" -> new Point(1, -1);
            case "SW" -> new Point(-1, -1);
            default -> {
                System.out.printf("Invalid direction %s%n", dir);
                yield new Point(0, 0);
            }
        };
    }
}
