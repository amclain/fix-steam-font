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
      
      styles = File.open('steam.styles').read
      
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
      File.open('steam.styles', 'w') do |file|
        new_styles.each_line {|line| file << line}
      end
      
      puts 'Done.'
    end
  end
end