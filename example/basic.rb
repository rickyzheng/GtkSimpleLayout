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
          _button "Button 2, I'm flexiable", layout: [padding: 15]
          _button 'Button 3, fixed, at the end', layout: [:end, false, false] 
        end
      end
      _frame 'frame 2', layout: [expand: true, fill: true, padding: 20] do
        _box :vertical do
          _label 'Label 2'
          _label 'Label 3'
          _button 'Button 4, extend: true', layout: [:end, extend: true, fill: true]
        end
      end
    end
  end
end

MyWin.new.show_all
Gtk.main
