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
    box :vertical do
      with_attr :border_width => 3 do
        box :horizontal do
          entry :id => :ent_input, :layout => [true, true, 5]
        end
        box :horizontal do
          frame do
            label 'M', :set_size_request => [20, 20]
          end
          hbutton_box do
            button 'Backspace'
            button 'CE'
            button 'C'
          end
        end
        box :horizontal do
          vbutton_box do
            button 'MC'
            button 'MR'
            button 'MS'
            button 'M+'
          end
          with_attr :layout => [true, true] do
            number_and_operators_layout
          end
        end
      end
    end
  end

  def number_and_operators_layout
    box :vertical do
      [ ['7', '8', '9', '/', 'sqt'],
        ['4', '5', '6', '*', '%'],
        ['1', '2', '3', '-', '1/x'],
        ['0', '+/-', '.', '+', '=']].each do |cols|
        box :horizontal, :layout => [true, true] do
          cols.each do |txt|
            button txt, :id => txt.to_sym, :set_size_request => [30, 30], :layout => [true, true]
          end
        end
      end
    end
  end

end

MyWin.new.show_all
Gtk.main
