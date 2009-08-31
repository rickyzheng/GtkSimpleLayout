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
      with_attr :border_width => 3 do
        hbox do
          entry :id => :ent_input, :layout => [true, true, 5]
        end
        hbox do
          frame do
            label 'M', :set_size_request => [20, 20]
          end
          hbutton_box do
            button 'Backspace'
            button 'CE'
            button 'C'
          end
        end
        hbox do
          vbutton_box do
            button 'MC'
            button 'MR'
            button 'MS'
            button 'M+'
          end
          table 5, 4, :layout => [true, true] do
            row_idx = 0
            [ ['7', '8', '9', '/', 'sqt'],
              ['4', '5', '6', '*', '%'],
              ['1', '2', '3', '-', '1/x'],
              ['0', '+/=', '.', '+', '=']].each do |cols|
              col_idx = 0
              cols.each do |txt|
                grid col_idx, row_idx do
                  button txt, :set_size_request => [20, 20]
                end
                col_idx += 1
              end
              row_idx += 1
            end
          end
        end
      end
    end
  end
end

MyWin.new.show_all
Gtk.main
