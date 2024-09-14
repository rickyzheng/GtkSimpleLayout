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
    _vbox_in_hbox inner_layout: [padding: 10] do
      with_attr :border_width => 5 do
        _frame layout: [padding: 10] do
          _label_in_vbox 'Label 1', inner_layout: [padding: 10]
        end
        _button 'Button 1'
        _entry_in_vbox :id => :ent_input
      end
    end
  end
end

MyWin.new.show_all
Gtk.main
