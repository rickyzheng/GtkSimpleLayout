require 'gtk2'
require File.dirname(__FILE__) + '/../lib/simple_layout'

class MyWin < Gtk::Window
  include SimpleLayout::Base
  def initialize
    super
    add my_layout
    signal_connect('destroy') do
      Gtk.main_quit
    end
  end

  def my_layout
    vbox do
      menu_bar "main", :type => :menu do
        sub_menu "_File" do
          menu_item "_Open"
          menu_item "_Close"
          menu_item "_Quit", :accel => "<control>X"
        end
        sub_menu "Tools" do
          sub_menu "Edit" do
            menu_item "Copy"
            menu_item "Cut"
            menu_item "Paste"
          end
          menu_item "Option"
        end
      end
      scrolled_window :layout => [true, true] do
        text_view :set_size_request => [300, 200]
      end
    end
  end

  def menu_main_on_active(id, path, w)
    puts "menu: #{id}, path: #{path}"
  end

end

MyWin.new.show_all
Gtk.main