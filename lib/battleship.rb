class Battleship
  attr_reader :inputs, :grid_size, :ship_count, :missile_count, :p1_positions, :p2_positions, :p1_moves, :p2_moves
  COORDINATE_INPUTS = [:p1_positions, :p2_positions, :p1_moves, :p2_moves]

  def initialize(input_file_path)
    retrieve_inputs_from_file(input_file_path)
    format_coordinate_inputs
    validate_inputs
  end

  def retrieve_inputs_from_file(input_file_path)
    input_text = File.read(input_file_path)
    raise 'Invalid Input' if (input_text.lines != 7)
    
    input_keys = [:grid_size, :ship_count, :missile_count, :p1_positions, :p2_positions, :p1_moves, :p2_moves]
    c.each_line.with_index(0) do |line, i|
      instance_variable_set("@#{input_keys[i]}", line.strip)
    end
  end

  def format_coordinate_inputs
    COORDINATE_INPUTS.each do |key|
      instance_variable_set("@#{key}", send(key).split(','))
    end
  end

  def validate_inputs
    raise 'Invalid grid size. Should be 0 < grid_size < 10' if grid_size > 9 || grid_size < 1
    raise "Invalid no of ships. Should be 0 < ship_count < #{max_allowed_ships}" if ship_count <= max_allowed_ships
    COORDINATE_INPUTS.each do |coordinates|
      raise "Invalid no of values for #{coordinates}" if (send(coordinates).count != ship_count)
      # raise "Invalid coordinate format. Should be of the format - x1:y1" if 
    end
  end

  private

  def max_allowed_ships
    (grid_size * grid_size)/2
  end
  
end
