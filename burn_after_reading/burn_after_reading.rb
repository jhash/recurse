## type top secret messages in the terminal ##

STDOUT.sync = true

def move_to(x, y)
  print "\e[#{y};#{x}H"
end

def print_char(x, y, char)
  move_to(x, y)
  print char
end

# █▓▒░
FIRE_FADE_OUT_CHARS = ['█', '▓', '▒', '░'].freeze
FIRE_FADE_IN_CHARS = FIRE_FADE_OUT_CHARS.dup.reverse.freeze
FIRE_CHARS = (FIRE_FADE_IN_CHARS + FIRE_FADE_OUT_CHARS).freeze
# FIRE_CHARS = ['.', ':', '-', '=', '+', '*', '#', '%', '@'].freeze

def burn_char(x, y)
  Thread.new do
    FIRE_CHARS.each do |f_char|
      # minimum of .5 seconds sleep, max of 2
      sleep(0.5 + (rand * 1.5))
      print_char(x, y, f_char)
    end

    sleep 1
    print_char(x, y, ' ')
  end
end

begin
  # Save original stty state
  # Example output: gfmt1:cflag=4b00:iflag=6b02:lflag=200005cb:oflag=3:discard=f:dsusp=19:eof=4:eol=ff:eol2=ff:erase=7f:intr=3:kill=15:lnext=16:min=1:quit=1c:reprint=12:start=11:status=14:stop=13:susp=1a:time=0:werase=17:ispeed=9600:ospeed=9600
  old_state = `stty -g`

  # Allow raw input
  system("stty raw -echo")

  # enter alt screen
  print "\e[?1049h"

  # hide cursor
  print "\e[?25l"

  # clear screen
  print "\e[2J"

  # number of rows, number of columns of terminal window
  t_height, t_width = `stty size`.split.map(&:to_i)

  x = 1
  y = 1

  # get input from the user
  while (char = STDIN.getc)
    # exit if ctrl-c
    break if char == "\u0003"

    # print at location so we can burn at location
    print_char(x, y, char)

    # burn at location
    burn_char(x,y)

    # move our own cursor
    x += 1

    # reset to 1, y + 1 if past number of columns
    if x > t_width
      x = 1
      # go to the next row
      y += 1
      # reset to 1, 1 if past number of rows
      y = 1 if y > t_height
    end
  end

ensure
  # Restore stty state
  system("stty #{old_state}") if old_state

  # show cursor
  print "\e[?25h"

  # leave alt screen
  print "\e[?1049l"
end