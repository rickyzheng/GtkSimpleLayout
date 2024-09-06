require 'gtk2'
require File.dirname(__FILE__) + '/../lib/simple_layout'

class MyWin < Gtk::Window
  include SimpleLayout::Base

  def my_layout
    _box :vertical do
      _box :horizontal do
        _button 'Change group A', :id => :btn_change_a
        _button 'Change group B', :id => :btn_change_b
      end
      _button_box :horizontal do
        group :A do  # set group A
          _button 'A'
          _button 'A'
          _button 'A'
        end
      end
      button_box :horizontal do
        group :B do  # set group B
          _button 'B'
          _button 'B'
          _button 'B'
        end
      end
      _button_box :horizontal do
        group :A do  # you can set group A again !
          _button 'A'
          _button 'A'
        end
        group :B do  # you can set group B again !
          _button 'B'
          _button 'B'
        end
      end
    end
  end

  def initialize
    super
    @count_a = 0
    @count_b = 0
    my_layout

    register_auto_events()

    signal_connect('destroy') do
      Gtk.main_quit
    end
  end

  def btn_change_a_on_clicked(w)
    @count_a += 1
    component_children(:A).each do |g|
      g.label = "A: #{@count_a}"
    end
  end

  def btn_change_b_on_clicked(w)
    @count_b += 1
    component_children(:B).each do |g|
      g.label = "B: #{@count_b}"
    end
  end

end

MyWin.new.show_all
Gtk.main
