require 'gtk3'
require 'simple_layout'

class MyWin < Gtk::Window
  include SimpleLayout::Base
  def initialize
    super
    my_layout
    signal_connect('destroy') do
      Gtk.main_quit
    end
  end

  def my_layout
    _box :vertical do
      _label 'Label'
    end
  end
end

# def fun(*arg, **karg)
#   puts "arg: #{arg}"
#   puts "karg: #{karg}"
# end

# # fun(1, "hello", :syn, r1: 1, r2: 2)

# #fun(1, "hello", :syn, layout: {:name => "hello", :age => 20, ka1: 1, ka2: 2})
# a = [1, "hello", :syn, {:name => "hello", :age => 20, ka1: 1, ka2: 2}]

# fun(*a)


MyWin.new.show_all
Gtk.main
