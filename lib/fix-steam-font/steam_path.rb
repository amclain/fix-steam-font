require 'yaml'

# Represents a path to the Steam installation.
class SteamPath
  attr_reader :config_path
  
  def initialize
    @path = nil
    @config_path = File.join File.expand_path('~'), 'fix-steam-font.yaml'
  end
  
  def to_s
    @path.to_s
  end
  
  def empty?
    @path.to_s.empty?
  end
  
  def exists?
    File.exists? @path
  end
  
  # Load path from configuration file.
  def load
    config = YAML.load_file @config_path
    @path = config['steam']
  end
  
  def save(path)
    @path = path
    File.open(@config_path, 'w') {|file| file << "steam: #{@path}"}
  end
  
end