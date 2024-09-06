require 'gtk3'
require 'simple_layout'

class MyWin < Gtk::Window
  include SimpleLayout::Base

  def my_layout
    _button_box :horizontal do
      _button 'A', :id => :btn_a
      _button 'B', :id => :btn_b
    end
  end

  def initialize
    super
    my_layout

    expose_components()
    # after call expose_components(), btn_a and btn_b become available
    btn_a.signal_connect('clicked') do
      btn_b.sensitive = (not btn_b.sensitive?)
    end
    btn_b.signal_connect('clicked') do
      btn_a.sensitive = (not btn_a.sensitive?)
    end

    signal_connect('destroy') do
      Gtk.main_quit
    end
  end

end

MyWin.new.show_all
Gtk.main
