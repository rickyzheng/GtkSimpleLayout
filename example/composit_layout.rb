require 'gtk2'
require File.dirname(__FILE__) + '/../lib/simple_layout'

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
    vbox do
      with_attr :border_width => 10 do
        label_in_hbox "I'm a label, in a hbox"
        button_in_frame "I'm a button, in a frame", :border_width => 10
        label_in_hbox "I'm a label, in a hbox, with inner_layout[:end, false, false]", :inner_layout => [:end, false, false]
      end
    end
  end
end

MyWin.new.show_all
Gtk.main