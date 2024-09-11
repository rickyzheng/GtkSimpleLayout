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
    _vbox do
      with_attr :border_width => 3 do
        _hbox do
          _entry :id => :ent_input, :layout => [true, true, 5]
        end
        _hbox do
          _frame do
            _label 'M', :set_size_request => [20, 20]
          end
          _hbutton_box do
            _button 'Backspace'
            _button 'CE'
            _button 'C'
          end
        end
        _hbox do
          _vbutton_box do
            _button 'MC'
            _button 'MR'
            _button 'MS'
            _button 'M+'
          end
          with_attr :layout => [true, true] do
            number_and_operators_layout
          end
        end
      end
    end
  end

  def number_and_operators_layout
    _vbox do
      [ ['7', '8', '9', '/', 'sqt'],
        ['4', '5', '6', '*', '%'],
        ['1', '2', '3', '-', '1/x'],
        ['0', '+/-', '.', '+', '=']].each do |cols|
        _hbox :layout => [true, true] do
          cols.each do |txt|
            _button txt, :id => txt.to_sym, :set_size_request => [30, 30], :layout => [true, true]
          end
        end
      end
    end
  end

end

MyWin.new.show_all
Gtk.main
