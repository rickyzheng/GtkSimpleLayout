require 'gtk3'
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
    box :horizontal do
      label 'Hello, '
      button 'World !'
    end
  end
end

MyWin.new.show_all
Gtk.main
