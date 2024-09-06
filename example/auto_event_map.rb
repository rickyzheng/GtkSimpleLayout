require 'gtk3'
require 'simple_layout'

class MyWin < Gtk::Window
  include SimpleLayout::Base

  def my_layout
    _button_box :horizontal do
      _button 'Click me !', :id => :btn_test
      _button 'Hi !', :id => :btn_hi
      _button 'Quit', :id => :btn_quit
    end
  end

  def initialize
    super
    @click_count = 0
    my_layout

    register_auto_events()  # enable the auto event map

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

  def self_on_destroy(*_)
    puts "program quit"
    Gtk.main_quit
  end

end

MyWin.new.show_all
Gtk.main
