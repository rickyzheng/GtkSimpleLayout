require 'gtk2'
require 'simple_layout'

class MyWin < Gtk
  include SimpleLayout::Base
  def initialize
    add my_layout
    signal_connect('destroy') do
      Gtk.main_quit
    end
  end

  def my_layout
    vbox do
      frame 'frame 1' do
        hbox do
          label 'Label 1'
          button 'This is a fixed button'
          button 'I\'m flexiable', :layout => [true, true]
        end
      end
      frame 'frame 2' do
        vbox do
          label 'Label 2'
          label 'Label 3'
        end
      end
    end
  end
end

MyWin.new.show_all
Gtk.main
