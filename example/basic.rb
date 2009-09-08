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
      frame 'frame 1' do
        hbox do
          label 'Label 1'
          button 'Button 1, fixed'
          button "Button 2, I'm flexiable", :layout => [true, true]
        end
      end
      frame 'frame 2' do
        vbox do
          label 'Label 2'
          label 'Label 3'
          button 'Button 3'
          button 'Button 4'
        end
      end
    end
  end
end

MyWin.new.show_all
Gtk.main
