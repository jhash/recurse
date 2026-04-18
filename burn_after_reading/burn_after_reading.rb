STDOUT.sync = true

def print_char(x, y, char)
  print "\e[#{y};#{x}H#{char}"
end

# █▓▒░
FIRE_FADE_OUT_CHARS = ['█', '▓', '▒', '░'].freeze
FIRE_FADE_IN_CHARS = FIRE_FADE_OUT_CHARS.dup.reverse.freeze
FIRE_CHARS = (FIRE_FADE_IN_CHARS + FIRE_FADE_OUT_CHARS).freeze

def burn_char(x, y)
  Thread.new do
    FIRE_CHARS.each do |f_char|
      sleep 1
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

  system("stty raw -echo")

  # enter alt screen
  print "\e[?1049h"

  # hide cursor
  print "\e[?25l"

  # clear screen
  print "\e[2J"

  t_height, t_width = `stty size`.split.map(&:to_i)

  x = 1
  y = 1

  while (char = STDIN.getc)
    break if char == "\u0003" # ctrl-c

    print_char(x, y, char)
    burn_char(x,y)
    x += 1
    if x > t_width
      x = 1
      y += 1
      y = 1 if y > t_height
    end
    sleep 0.1
  end

ensure
  # Restore stty state
  system("stty #{old_state}") if old_state

  # show cursor
  print "\e[?25h"

  # leave alt screen
  print "\e[?1049l"
end