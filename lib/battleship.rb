require 'pry'

class Battleship
  attr_reader :inputs, :grid_size, :ship_count, :missile_count, :p1_positions, :p2_positions, :p1_moves, :p2_moves, :p1_grid, :p2_grid, :total_hits
  COORDINATE_INPUTS = [:p1_positions, :p2_positions, :p1_moves, :p2_moves]

  def initialize(input_file_path)
    retrieve_inputs_from_file(input_file_path)
    format_inputs
    validate_inputs
  end
  
  def start(print_to_file: false)
    setup_player_grids
    perform_attacks
    print_result if print_to_file
  end

  def print_result(path = './result.txt')
    file = File.open(path, 'w')
    [@p1_grid, @p2_grid].each.with_index(1) do |grid, i|
      file.puts "Player #{i}"
      grid.each do |row|
        file.puts row.join(' ')
      end
    end
    total_hits.each do |player, value|
      file.puts "#{player}:#{value}"
    end

    file.close
  end
  
  private

  def setup_player_grids
    @p1_grid = initialize_grid_with_ships(p1_positions)
    @p2_grid = initialize_grid_with_ships(p2_positions)
  end

  def initialize_grid_with_ships(positions)
    grid = Array.new(grid_size) { Array.new(grid_size) { '-' } }
    positions.each do |position|
      x, y = position.split(':').map(&:to_i)
      grid[x][y] = 'B'
    end
    grid
  end

  def perform_attacks
    @total_hits = {}
    @p1_grid, @total_hits[:p1] = find_hits_and_misses(p1_grid, p2_moves)
    @p2_grid, @total_hits[:p2] = find_hits_and_misses(p2_grid, p1_moves)
  end

  def find_hits_and_misses(grid, moves)
    result = moves.map do |move|
      x, y = move.split(':').map(&:to_i)
      grid[x][y] = grid[x][y].eql?('B') ? 'X' : 'O' 
    end
    total_hits = result.group_by(&:itself).map { |k,v| [k, v.length] }.to_h['X']
    [grid, total_hits]
  end

  def retrieve_inputs_from_file(input_file_path)
    input_text = File.read(input_file_path)
    raise 'Invalid Input' if (input_text.lines.count != 7)
    
    input_keys = [:grid_size, :ship_count, :p1_positions, :p2_positions, :missile_count, :p1_moves, :p2_moves]
    input_text.each_line.with_index(0) do |line, i|
      instance_variable_set("@#{input_keys[i]}", line.strip)
    end
  end

  def format_inputs
    %w[grid_size ship_count missile_count].each do |key|
      instance_variable_set("@#{key}", send(key).to_i)
    end
    format_coordinate_inputs
  end
  
  def format_coordinate_inputs
    COORDINATE_INPUTS.each do |key|
      instance_variable_set("@#{key}", send(key).split(','))
    end
  end

  def validate_inputs
    raise 'Invalid grid size. Should be 0 < grid_size < 10' if grid_size > 9 || grid_size < 1
    raise "Invalid no of ships. Should be 0 < ship_count < #{max_allowed_ships}" if (ship_count < 1 && ship_count > max_allowed_ships)
    COORDINATE_INPUTS.each do |coordinates|
      raise "Invalid no of values for #{coordinates}" if (send(coordinates).count != ship_count)
      # raise "Invalid coordinate format. Should be of the format - x1:y1" if 
    end
  end

  def max_allowed_ships
    (grid_size * grid_size)/2
  end 
end
