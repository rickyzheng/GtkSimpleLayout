require 'gtk2'
require '../lib/simple_layout'

class MyWin < Gtk::Window
  include SimpleLayout::Base

  def my_layout
    hbutton_box do
      button 'Click me !', :id => :btn_test
      button 'Quit', :id => :btn_quit
    end
  end

  def initialize
    super
    @click_count = 0
    add my_layout

    register_auto_events()  # enable the auto event map

    signal_connect('destroy') do
      Gtk.main_quit
    end
  end

  def btn_test_on_clicked(w)
    @click_count += 1
    w.label = "Clicked: #{@click_count}"
  end

  def btn_quit_on_clicked(w)
    self.destroy
  end

end

MyWin.new.show_all
Gtk.main
