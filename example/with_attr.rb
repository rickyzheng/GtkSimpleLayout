require 'gtk2'
require '../lib/simple_layout'

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
      frame 'default' do
        hbutton_box do
          button 'A'
          button 'B'
          button 'C'
        end
      end
      frame 'set :border_width => 10 for each button' do
        hbutton_box do
          button 'A', :border_width => 10
          button 'B', :border_width => 10
          button 'C', :border_width => 10
        end
      end
      frame 'using with_attr :border_width => 10' do
        hbutton_box do
          with_attr :border_width => 10 do
            button 'A'
            button 'B'
            button 'C'
          end
        end
      end
    end
  end
end

MyWin.new.show_all
Gtk.main
