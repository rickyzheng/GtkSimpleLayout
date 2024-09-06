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
      with_attr :border_width => 10 do
        _frame 'default' do
          _button_box :horizontal do
            _button 'A'
            _button 'B'
            _button 'C'
          end
        end
        _frame 'set :border_width => 10 for each button' do
          _button_box :horizontal do
            _button 'A', :border_width => 10
            _button 'B', :border_width => 10
            _button 'C', :border_width => 10
          end
        end
        _frame 'using with_attr :border_width => 10' do
          _button_box :horizontal do
            with_attr :border_width => 10 do
              _button 'A'
              _button 'B'
              _button 'C'
            end
          end
        end
      end
    end
  end
end

MyWin.new.show_all
Gtk.main
