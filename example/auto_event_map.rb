require 'gtk2'
require File.dirname(__FILE__) + '/../lib/simple_layout'

class MyWin < Gtk::Window
  include SimpleLayout::Base

  def my_layout
    hbutton_box do
      button 'Click me !', :id => :btn_test
      button 'Hi !', :id => :btn_hi
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

    # normal event handler
    component(:btn_hi).on_clicked do
      puts "hi clicked 1"
    end

    # or like this
    p = Proc.new do puts "hi clicked 2" end
    component(:btn_hi).on_clicked(p)

    # or like this
    component(:btn_hi).on_clicked << Proc.new do
      puts "hi clicked 3"
    end

    # use Gtk way
    component(:btn_hi).signal_connect('clicked') do
      puts 'hi clicked 4'
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
