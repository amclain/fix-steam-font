require 'fix-steam-font/steam_path'

class FixSteamFont
  class << self
    def run
      @sections_to_change = [
        #'console_text_error',
        #'console_text',
        'friends_chat_text',
        'friends_chat_text_self',
        'friends_chat_history',
        'friends_chat_event',
        'friends_chat_bright_event',
        'friends_chat_url',
        'friends_chat_name_ingame',
        'friends_chat_self',
        'friends_chat_name',
        'friends_chat_accountid',
        'friends_chat_securitylink'
        ]
      
      # Load configuration.
      @path = SteamPath.new
      
      begin
        @path.load
      rescue Errno::ENOENT => e
        # Config file doesn't exist.
        # Do not implement - user will be prompted for path.
      end
      
      # Prompt user for path to Steam.
      if @path.empty?
        puts "Enter path to Steam:"
        user_path = gets
        
        if user_path.strip.empty?
          puts 'Aborted.'
          exit
        end
        
        @path.save user_path.strip
        raise StandardError, 'Could not write config file.' unless @path.exists?
        
        @path.load
      end
      
      # Load Steam style.
      styles_path = "#{@path}/resource/styles/steam.styles"
      
      raise StandardError, "Could not find steam.styles at:\n#{styles_path}" \
        unless File.exists? styles_path
      
      styles = File.open(styles_path).read
      
      new_styles = ''
      processing_section = false
      
      styles.each_line do |line|
        processing_section = line.strip if @sections_to_change.include? line.strip
        processing_section = false if line.strip == '}'
        
        # Only change font-size inside of the target sections.
        unless processing_section and line.include?('font-size')
          new_styles << line
          next
        end
      
        # The console_text sections behave a little differently.
        # If the first font-size line is changed, Steam regenerates the file.
        # It is the font-size line with [$OSX] that should be changed.
        if processing_section.include? 'console_text'
      
          if line.include? 'OSX]'
            # The spaces before \t are required or Steam will replace
            # the .styles file with the default.
            new_styles << "      \tfont-size=14 [$OSX]\n"
          else
            new_styles << line
          end
      
          next
        end
      
        # Handle all other font-size changes.
        new_styles << "\t\tfont-size=14\n"
      end
      
      # Save the changes.
      File.open(styles_path, 'w') do |file|
        new_styles.each_line {|line| file << line}
      end
      
      puts 'Done.'
    end
  end
end