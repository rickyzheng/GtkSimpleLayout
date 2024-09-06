require 'gtk3'
require 'simple_layout'

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
    _box :vertical do
      _frame 'frame 1' do
        _box :horizontal do
          _label 'Label 1'
          _button 'Button 1, fixed'
          _button "Button 2, I'm flexiable", layout: [true, true]
        end
      end
      _frame 'frame 2' do
        _box :vertical do
          _label 'Label 2'
          _label 'Label 3'
          _button 'Button 3'
          _button 'Button 4'
        end
      end
    end
  end
end

MyWin.new.show_all
Gtk.main
