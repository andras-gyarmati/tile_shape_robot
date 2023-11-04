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
          tile = HexagonalTile()
          self.tiles[coordinates] = tile

  def remove_tile(self, coordinates):
      if coordinates in self.tiles:
          del self.tiles[coordinates]

  def move_robot(self, new_position):
      if new_position in self.tiles or new_position == self.robot_position:
          self.robot_position = new_position

  def pick_up_tile(self):
      if self.robot_position in self.tiles and not self.robot_has_tile:
          self.tiles[self.robot_position].occupied = False
          self.robot_has_tile = True

  def place_tile(self):
      if self.robot_has_tile:
          self.tiles[self.robot_position].occupied = True
          self.robot_has_tile = False

  def move_robot_with_tile(self, direction):
      if self.robot_has_tile:
          new_position = self.get_neighbor(self.robot_position, direction)
          if new_position:
              if new_position in self.tiles:
                  self.tiles[new_position].occupied = True
              self.tiles[self.robot_position].occupied = False
              self.robot_position = new_position

  def get_neighbor(self, position, direction):
          x, y = position
          if direction == 'N':
              return (x, y - 1)
          elif direction == 'NE':
              return (x + 1, y - 1)
          elif direction == 'SE':
              return (x + 1, y)
          elif direction == 'S':
              return (x, y + 1)
          elif direction == 'SW':
              return (x - 1, y + 1)
          elif direction == 'NW':
              return (x - 1, y)
          return None

  def is_connected(self):
      visited = set()
      stack = [self.robot_position]
      while stack:
          current_position = stack.pop()
          if current_position not in visited:
              visited.add(current_position)
              # check for the six neighbors
              for direction in ['N', 'NE', 'SE', 'S', 'SW', 'NW']:
                  neighbor = self.get_neighbor(current_position, direction)
                  if neighbor and neighbor in self.tiles and self.tiles[neighbor].occupied:
                      stack.append(neighbor)
      return len(visited) == len(self.tiles) + 1


lattice = TriangularLattice()
lattice.add_tile((0, 0))
lattice.add_tile((1, 0))
lattice.add_tile((0, 1))
lattice.add_tile((1, 1))

lattice.move_robot((0, 0))
lattice.pick_up_tile()
lattice.move_robot((1, 0))
lattice.place_tile()
lattice.move_robot_with_tile("N")
