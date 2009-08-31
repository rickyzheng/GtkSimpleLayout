require 'gtk2'

module SimpleLayout

  class LayoutError < Exception; end

  class EventHandlerProxy
    def initialize(host, evt, &block)
      @host = host
      @evt = evt
      self << block if block
    end
    def <<(v)
      if v && v.respond_to?('call')
        @host.signal_connect(@evt) do |*args|
          v.call(*args)
        end
      end
      self
    end
  end

  module Base
    def Base.included(base)
      {
        'image' => Gtk::Image,
        'label' => Gtk::Label,
        'progress_bar' => Gtk::ProgressBar,
        'status_bar' => Gtk::Statusbar,
        'button' => Gtk::Button,
        'check_button' => Gtk::CheckButton,
        'radio_button' => Gtk::RadioButton,
        'toggle_button' => Gtk::ToggleButton,
        'link_button' => Gtk::LinkButton,
        'entry' => Gtk::Entry,
        'hscale' => Gtk::HScale,
        'vscale' => Gtk::VScale,
        'spin_button' => Gtk::SpinButton,
        'text_view' => Gtk::TextView,
        'tree_view' => Gtk::TreeView,
        'cell_view' => Gtk::CellView,
        'icon_view' => Gtk::IconView,
        'combobox' => Gtk::ComboBox,
        'combobox_entry' => Gtk::ComboBoxEntry,
        #'menu' => Gtk::Menu,
        #'menubar' => Gtk::MenuBar,
        'toolbar' => Gtk::Toolbar,
        'toolitem' => Gtk::ToolItem,
        'separator_toolitem' => Gtk::SeparatorToolItem,
        'tool_button' => Gtk::ToolButton,
        'toggle_tool_button' => Gtk::ToggleToolButton,
        'radio_tool_button' => Gtk::RadioToolButton,
        'color_button' => Gtk::ColorButton,
        'color_selection' => Gtk::ColorSelection,
        'file_chooser_button' => Gtk::FileChooserButton,
        'file_chooser_widget' => Gtk::FileChooserWidget,
        'font_button' => Gtk::FontButton,
        'font_selection' => Gtk::FontSelection,
        'alignment' => Gtk::Alignment,
        'aspect_frame' => Gtk::AspectFrame,
        'hbox' => Gtk::HBox,
        'vbox' => Gtk::VBox,
        'hbutton_box' => Gtk::HButtonBox,
        'vbutton_box' => Gtk::VButtonBox,
        'hpaned' => Gtk::HPaned,
        'vpaned' => Gtk::VPaned,
        'layout' => Gtk::Layout,
        'notebook' => Gtk::Notebook,
        'table' => Gtk::Table,
        'expander' => Gtk::Expander,
        'frame' => Gtk::Frame,
        'hseparator' => Gtk::HSeparator,
        'vseparator' => Gtk::VSeparator,
        'hscrollbar' => Gtk::HScrollbar,
        'vscrollbar' => Gtk::VScrollbar,
        'scrolled_window' => Gtk::ScrolledWindow,
        'arrow' => Gtk::Arrow,
        'calendar' => Gtk::Calendar,
        'drawing_area' => Gtk::DrawingArea,
        'event_box' => Gtk::EventBox,
        'handle_box' => Gtk::HandleBox,
        'viewport' => Gtk::Viewport,
        'curve' => Gtk::Curve,
        'gamma_curve' => Gtk::GammaCurve,
        'hruler' => Gtk::HRuler,
        'vruner' => Gtk::VRuler,
      }.each do |k, v|
        define_method(k) do |*args, &block|
          create_component(v, args, block)
        end
      end
    end

    public

    # register automatic event handlers
    def register_auto_events()
      self.methods.each do |name|
        if name =~ /^(.+)_on_(.+)$/
          w, evt = $1, $2
          w = component(w.to_sym)
          w.signal_connect(evt) do |*args| self.send(name, *args) end if w
        end
      end
    end

    # expose the components as instance variables
    def expose_components()
      @components.each_key do |k|
        unless self.respond_to?(k.to_s, true)
          self.instance_eval("def #{k.to_s}; component(:#{k.to_s}) end")
        else
          raise LayoutError, "#{k} is conflit with method, please redifine component id"
        end
      end
    end

    # add a widget to container (and/or become a new container as well).
    # do not call this function directly unless knowing what you are doing
    def add_component(w, layout_opt = nil)
      container, g = @containers.last
      g.push w if g
      if @pass_on_stack.last.nil? || @pass_on_stack.last[0] == false
        if container.is_a?(Gtk::Box)
          layout_opt ||= [false, false, 0]
          pack_method = 'pack_start'
          if layout_opt.first.is_a?(Symbol)
            pack_method = 'pack_end' if layout_opt.shift == :end
          end
          container.send(pack_method, w, *layout_opt)
        elsif container.is_a?(Gtk::Fixed) || container.is_a?(Gtk::Layout)
          layout_opt ||= [0, 0]
          container.put w, *layout_opt
        elsif container.is_a?(Gtk::MenuShell)
          container.append w
        elsif container.is_a?(Gtk::Toolbar)
          container.insert(container.n_items, w)
        elsif container.is_a?(Gtk::MenuToolButton)
          container.menu = w
        elsif container.is_a?(Gtk::Table)
          # should use #grid or #grid_flx to add a child to Table
        elsif container.is_a?(Gtk::Notebook)
          # should use #page to add a child to Notebook
        elsif container.is_a?(Gtk::Paned)
          # should use #area_first or #area_second to add child to Paned
        elsif container.is_a?(Gtk::Container)
          layout_opt ||= []
          container.add(w, *layout_opt)
        end
      else
        fun_name, args = *(@pass_on_stack.last[1])
        container.send(fun_name, w, *args)
      end
    end

    # create a "with block" for setup common attributes
    def with_attr(options = {}, &block)
      if block
        @common_attribute ||= []
        @common_attribute.push options
        cnt, _ = @containers.last
        block.call(cnt)
        @common_attribute.pop
      end
    end

    # get component with given name
    def component(name)
      @components[name]
    end

    # return children array of a component or group
    def component_children(name)
      @component_children ||= {}
      @component_children[name]
    end

    # group the children
    def group(name)
      cnt, _ = @containers.last
      @component_children[name] ||= []
      @containers.push [cnt, @component_children[name]]
      yield cnt if block_given?
      @containers.pop
    end

    # for HPaned and VPaned container
    def area_first(resize = true, shrink = true, &block)
      container_pass_on(Gtk::Paned, 'pack1', resize, shrink, block)
    end
    def area_second(resize = true, shrink = true, &block)
      container_pass_on(Gtk::Paned, 'pack2', resize, shrink, block)
    end

    # for Notebook container
    def page(text = nil, &block)
      container_pass_on(Gtk::Notebook, 'append_page', text, block)
    end

    # for Table container
    def grid_flx(left, right, top, bottom, *args, &block)
      args.push block
      container_pass_on(Gtk::Table, 'attach', left, right, top, bottom, *args)
    end
    def grid(left, top, *args, &block)
      args.push block
      container_pass_on(Gtk::Table, 'attach', left, left + 1, top, top + 1, *args)
    end

    private

    def add_singleton_event_map(w)
      def w.method_missing(sym, *args, &block)
        if sym.to_s =~ /^on_([^=]+)(=*)$/
          block ||= args.last
          return EventHandlerProxy.new(self, $1, &block)
        else
          raise NoMethodError
        end
      end
    end

    def create_component(component_class, args, block)

      @containers ||= []
      @pass_on_stack ||= []
      @components ||= {}
      @common_attribute ||= []
      @component_children ||= {}

      options = {}
      options = args.pop if args.last.is_a?(Hash)
      options.merge! @common_attribute.last if @common_attribute.last

      w = component_class.new(*args)
      add_singleton_event_map(w) # so that you can use: w.on_clicked{|*args| ... }
      
      name = options.delete(:id)
      group_name = options.delete(:gid) || name
      layout_opt = options.delete(:layout)

      options.each do |k, v|
        if v.is_a?(Array)
          w.send(k.to_s, *v) if w.respond_to?(k.to_s)
        else
          w.send(k.to_s + '=', v) if w.respond_to?(k.to_s + '=')
        end
      end

      @components[name] = w if name
      @component_children[group_name] ||= [] if group_name

      if block # if given block, it's a container as well
        @containers.push [w, @component_children[group_name]]
        @pass_on_stack.push [false, nil]
        @common_attribute.push({})
        block.call(w) if block
        @common_attribute.pop
        @pass_on_stack.pop
        @containers.pop
      end

      if @containers.size > 0
        add_component(w, layout_opt) # add myself to parent
      end
      w
    end

    def container_pass_on(container_class, fun_name, *args)
      block = args.pop # the last arg is Proc or nil
      cnt, _ = @containers.last
      if cnt.is_a?(container_class)
        @pass_on_stack.push [true, [fun_name, args]]
        block.call(cnt) if block
        @pass_on_stack.pop
      else
        raise LayoutError, "class #{container_class} expected"
      end
    end
  end
end
