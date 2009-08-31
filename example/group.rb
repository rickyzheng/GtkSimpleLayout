require 'gtk2'
require File.dirname(__FILE__) + '/../lib/simple_layout'

class MyWin < Gtk::Window
  include SimpleLayout::Base

  def my_layout
    vbox do
      hbox do
        button 'Change group A', :id => :btn_change_a
        button 'Change group B', :id => :btn_change_b
      end
      hbutton_box do
        group :A do  # set group A
          button 'A'
          button 'A'
          button 'A'
        end
      end
      hbutton_box do
        group :B do  # set group B
          button 'B'
          button 'B'
          button 'B'
        end
      end
      hbutton_box do
        group :A do  # you can set group A again !
          button 'A'
          button 'A'
        end
        group :B do  # you can set group B again !
          button 'B'
          button 'B'
        end
      end
    end
  end

  def initialize
    super
    @count_a = 0
    @count_b = 0
    add my_layout

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
