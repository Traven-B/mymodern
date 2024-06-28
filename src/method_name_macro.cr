# Macros for seeing where and when things are happening in a concurrent framwork.
#
# Example program:
#
# ```
# require "./method_name_macro"
# # extend T # extend or include at the top level is possible
#
# T.trace = true
#
# module Foo
#   include T
#
#   def self.foo
#     d # just method name prints
#     dt "no parentheses seems neatest"
#     dt "before sleep"
#     sleep 750.milliseconds
#     dt("after three quarter second sleep")
#     d "bottom" # just method name and message, no time
#   end
# end
#
# Foo.foo
# T.dtt("at top level (no method name available)")
# ```
#
# At the prompt:
#
# ```terminal
# $ crystal try_name_macros.cr
#          :  foo :
#   0.000  :  foo : no parentheses seems neatest
#   0.000  :  foo : before sleep
#   0.750  :  foo : after three quarter second sleep
#          :  foo : bottom
#   0.751  :  at top level (no method name available)
# ```
#
# The module has global like class variables start and trace. start is set to the
# time the program started, and trace should be set to true if trace statements
# placed in the program text should actually print something. By using macro
# instead of def, the macro is inlined so we get the method name the macro is in.
module T
  @@start = Time.local
  @@trace = false

  def self.trace=(do_debug_messages)
    @@trace = do_debug_messages
  end

  def self.trace?
    @@trace
  end

  def self.start
    @@start
  end

  # A macro that prints the name of the method it was called in and an optional
  # message.
  macro d(msg = "")
    if T.trace?
      puts "         :  #{{{ @def.name.stringify }}} : #{{{msg}}}".rstrip
    end
  end

  # A macro that prints the time interval since the program started and current
  # time, the name of the method it was called in and an optional message.
  macro dt(msg = "")
    if T.trace?
      delta_t = Time.local - T.start
      tdiff = sprintf("% 3i.%03i  :  ", delta_t.seconds, delta_t.milliseconds)
      puts "#{tdiff}#{{{ @def.name.stringify }}} : #{{{msg}}}".rstrip
    end
  end

  # A macro that prints the time interval since the program started and current
  # time and an optional message. For when you're at the top level outside of a
  # method with a name.
  macro dtt(msg = "")
    if T.trace?
      delta_t = Time.local - T.start
      tdiff = sprintf("% 3i.%03i  :  ", delta_t.seconds, delta_t.milliseconds)
      puts "#{tdiff}#{{{msg}}}".rstrip
    end
  end
end
