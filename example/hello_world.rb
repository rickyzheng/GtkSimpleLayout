require 'gtk3'
require 'simple_layout'

class MyWin < Gtk::Window
  include SimpleLayout::Base
  def initialize
    super
    add my_layout()
    signal_connect('destroy') do
      Gtk.main_quit
    end
  end

  def my_layout
    _box :horizontal do
      _label 'Hello, '
      _button 'World !'
    end
  end
end

MyWin.new.show_all
Gtk.main
