require 'gtk2'
require '../lib/simple_layout'

class MyWin < Gtk::Window
	include SimpleLayout::Base

	def my_layout
		frame 'Serial Port Setup', :border_width => 5 do
			vbox :border_width => 5 do
        with_attr :border_width => 3, :layout => [true, true] do
          hbox do
            label 'Port name: '
            combobox :id => :comb_port, :layout => [true, true]
          end
          hbox do
            label 'Baud rate: '
            combobox :id => :comb_baudrate, :layout => [true, true]
          end
          hbutton_box do
            button 'Open', :id => :btn_open, :sensitive => false
            button 'Close', :id => :btn_close, :sensitive => false
          end
        end
			end
		end
	end

	def initialize
		super

		add my_layout

		register_auto_events()
    expose_components()

		init_ui

		signal_connect('destroy') do
			Gtk.main_quit
		end
	end

	def init_ui
		if RUBY_PLATFORM =~ /(mswin|mingw)/
			(1..10).each do |n|
				comb_port.append_text "COM#{n}"
			end
		else
			Dir.glob("/dev/ttyS*").each do |name|
				comb_port.append_text name
			end
			Dir.glob("/dev/ttyUSB*").each do |name|
				comb_port.append_text name
			end
		end
		[9600, 19200, 57600, 115200].each do |speed|
			comb_baudrate.append_text speed.to_s
		end
	end
  
  def comb_port_on_changed(*_)
		btn_open.sensitive = true if comb_baudrate.active >= 0
  end
  
  def comb_baudrate_on_changed(*_)
    btn_open.sensitive = true if comb_port.active >= 0
  end

  def btn_open_on_clicked(*_)
			[comb_baudrate, comb_port, btn_open].each {|w| w.sensitive = false}
			btn_close.sensitive = true
  end

  def btn_close_on_clicked(*_)
			[comb_baudrate, comb_port, btn_open].each {|w| w.sensitive = true}
			btn_close.sensitive = false
  end

end


MyWin.new.show_all
Gtk.main

