require 'gtk2'
require File.dirname(__FILE__) + '/../lib/simple_layout'

class MyWin < Gtk::Window
  include SimpleLayout::Base
  def initialize
    super
    add my_layout
    signal_connect('destroy') do
      Gtk.main_quit
    end
  end

  def my_layout
    vbox do
      hbox do
        label '-- Hello --'
        button 'Horizontal'
        label '-- World !--'
      end
      vbox do
        label '|| Hello ||'
        button 'Vertical'
        label '|| World !||'
      end
    end
  end
end

MyWin.new.show_all
Gtk.main
