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

      # menubar
      _box :horizontal do
        _menubar do
          _menuitem 'File' do
            _menu :id => :main, :accel_group => :main_accel_group do
              _menuitem 'New', :id => :menu_new
              _menuitem 'Open', :id => :menu_open
              _menuitem 'Save', :id => :menu_save
              _menuitem 'Save As', :id => :menu_save_as
              _menuitem 'Quit', :id => :menu_quit, accel: "<cmd>Q"
            end
          end
        end
      end

      # edit area
      _scrolled_window :set_size_request => [300, 200], layout: [expand: true, fill: true] do
        _text_view :layout => [:automatic, :automatic]
      end
    end

    add_accel_group(component(:main_accel_group)) # add the accel group to the window

    register_auto_events()  # enable the auto event map
  end

  def menu_quit_on_activate(w)
    self.destroy
  end

end

MyWin.new.show_all
Gtk.main