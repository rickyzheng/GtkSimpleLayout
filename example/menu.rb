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
      factory_menu_bar "main", :type => :menu do
        factory_menu_item "<_File>" do
          factory_menu_item "_Open"
          factory_menu_item "_Close"
          factory_menu_item "---"
          factory_menu_item "_Quit", :id => :quit, :accel => "<control>Q"
        end
        factory_menu_item "<_Edit>" do
          factory_menu_item "<--->"
          factory_menu_item "Copy", :accel => "<control>C"
          factory_menu_item "Cut", :accel => "<control>X"
          factory_menu_item "Paste", :accel => "<control>V"
          factory_menu_item "<Advanced>", :accel => "<control>S" do
            factory_menu_item "<--->", :accel => "<control>A"
            # factory_menu_item "Zoom In", :image => Gtk::Stock::ZOOM_IN, :accel => "<control>plus"
            # factory_menu_item "Zoom Out", :image => Gtk::Stock::ZOOM_OUT, :accel => "<control>minus"
          end
        end
        factory_menu_item ">>Help>>" do
          factory_menu_item "About"
        end
      end
      _scrolled_window :layout => [true, true] do
        _text_view :set_size_request => [300, 200]
      end
    end
  end

  def menu_main_on_active(id, path, w)
    puts "menu: #{id}, path: #{path}"
    if id == :quit
      self.destroy
    end
  end

end

MyWin.new.show_all
Gtk.main