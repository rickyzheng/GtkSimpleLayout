require 'gtk3'
require 'simple_layout'

class MyWin < Gtk::Window
  include SimpleLayout::Base
  def initialize
    super
    vbox = Gtk::Box.new(:vertical, 5)
    vbox.pack_start(Gtk::Label.new('Multiple Layouts'), expand: false, fill: false, padding: 10)
    vbox.pack_start(my_layout1(), expand: true, fill: true, padding: 0)
    vbox.pack_start(my_layout2(), expand: true, fill: true, padding: 0)
    add vbox

    register_auto_events()  # enable the auto event map
    expose_components()     # expose the components to the methods access

    signal_connect('destroy') do
      Gtk.main_quit
    end
  end

  def btn_a1_on_clicked(w)
    @btn_a1_click_count ||= 0
    @btn_a1_click_count += 1
    lbl_a.text = "Button A1 clicked #{@btn_a1_click_count}"
  end

  def btn_b2_on_clicked(w)
    @btn_b2_click_count ||= 0
    @btn_b2_click_count += 1
    lbl_b.text = "Button B2 clicked #{@btn_b2_click_count}"
  end


  def my_layout1
    _frame 'layout 1', border_width: 5 do
      _box :horizontal do
        _label 'Label A', id: :lbl_a
        _button 'Button A, fixed'
        _button "Button A1, I'm flexiable", layout: [padding: 15], id: :btn_a1
        _button 'Button A2, fixed, at the end', layout: [:end, false, false] 
      end
    end
  end

  def my_layout2
    _frame 'layout 2', border_width: 5 do
      _box :vertical do
        _label 'Label B', id: :lbl_b
        _button 'Button B, fixed'
        _button "Button B1, I'm flexiable", layout: [padding: 15]
        _button 'Button B2, fixed, at the end', layout: [:end, false, false], id: :btn_b2
      end
    end
  end  
end

MyWin.new.show_all
Gtk.main
