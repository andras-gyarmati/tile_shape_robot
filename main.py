class HexagonalTile:
  def __init__(self):
    self.occupied = False


class TriangularLattice:
  def __init__(self):
    self.tiles = {}
    self.robot_position = (0, 0)
    self.robot_has_tile = False

  def add_tile(self, coordinates):
    if coordinates not in self.tiles:
      self.tiles[coordinates] = HexagonalTile()
      self.tiles[coordinates].occupied = True

  def remove_tile(self, coordinates):
    if coordinates in self.tiles and not self.tiles[coordinates].occupied:
      del self.tiles[coordinates]

  def move_robot(self, direction):
    new_position = self.get_neighbor(self.robot_position, direction)
    if new_position and (new_position not in self.tiles or not self.tiles[new_position].occupied):
      self.robot_position = new_position

  def pick_up_tile(self):
    if self.robot_position in self.tiles and self.tiles[self.robot_position].occupied and not self.robot_has_tile:
      self.tiles[self.robot_position].occupied = False
      self.robot_has_tile = True

  def place_tile(self):
    if self.robot_has_tile:
      if self.robot_position not in self.tiles:
        self.add_tile(self.robot_position)
      else:
        self.tiles[self.robot_position].occupied = True
      self.robot_has_tile = False

  def get_neighbor(self, position, direction):
    x, y = position
    # For even x, the neighbors are higher; for odd x, they are lower.
    offset = 0.5
    if direction == 'N':
      return (x, y + 1)
    elif direction == 'NE':
      return (x + 1, y + offset)
    elif direction == 'SE':
      return (x + 1, y - offset)
    elif direction == 'S':
      return (x, y - 1)
    elif direction == 'SW':
      return (x - 1, y - offset)
    elif direction == 'NW':
      return (x - 1, y + offset)
    return None

  def is_connected(self):
    if not self.tiles:
      return False
    visited = set()
    stack = [next(iter(self.tiles))]  # Start from any tile
    while stack:
      current_position = stack.pop()
      if current_position not in visited:
        visited.add(current_position)
        for direction in ['N', 'NE', 'SE', 'S', 'SW', 'NW']:
          neighbor = self.get_neighbor(current_position, direction)
          if neighbor in self.tiles and self.tiles[neighbor].occupied:
            stack.append(neighbor)
    return len(visited) == len([t for t in self.tiles.values() if t.occupied])

  def display(self):
    """Prints a simple representation of the grid with tiles and the robot's position."""
    # Determine grid bounds
    min_x = min((x for (x, y) in self.tiles), default=0)
    max_x = max((x for (x, y) in self.tiles), default=0)
    min_y = min((y for (x, y) in self.tiles), default=0)
    max_y = max((y for (x, y) in self.tiles), default=0)

    # Display the grid
    for y in range(max_y, min_y - 1, -1):
      offset = " " if y % 2 != 0 else ""  # Shift for every other row
      line = offset
      for x in range(min_x, max_x + 1):
        symbol = " ."  # Space and dot for an empty tile
        if (x, y) in self.tiles:
          if self.tiles[(x, y)].occupied:
            symbol = " X"  # Space and X for an occupied tile
          if (x, y) == self.robot_position:
            symbol = " R" if self.robot_has_tile else " r"  # Space and R or r for the robot
        line += symbol
      print(line)
    print()


def main():
  lattice = TriangularLattice()
  # Add tiles to the lattice
  for x in range(-2, 3):
    for y in range(-2, 3):
      lattice.add_tile((x, y))
  lattice.display()

  # Initial robot position and tile picking
  lattice.move_robot('N')
  lattice.pick_up_tile()
  lattice.display()

  # Robot movement with a tile
  lattice.move_robot('S')
  lattice.place_tile()
  lattice.display()

  # Robot movement with a tile to a new position
  lattice.pick_up_tile()
  lattice.move_robot('NE')
  lattice.place_tile()
  lattice.display()


# Run the main function
if __name__ == "__main__":
  main()
