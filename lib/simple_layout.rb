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

  module ExtClassMethod
    def inspector_opt(opt = nil)
      @insp_opt ||= {
                      :enable => (ENV['INSPECTOR_ENABLE'] == '1'),
                      :border_width => (ENV['INSPECTOR_BORDER_WIDTH'] || 5)
                    }
      @insp_opt.merge! opt if opt
      @insp_opt
    end

    def layout_class_maps
      @layout_class_maps_hash ||= {
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
      }
    end

  end

  module Base
    def Base.included(base)
      base.extend(ExtClassMethod)
      base.layout_class_maps.each do |k, v|
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
    def add_component(w, container, layout_opt = nil)
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
      cnt, misc = @containers.last
      gs = (name ? [name].flatten : [])
      gs.each{|g| @component_children[g] ||= [] }
      m = { :groups => gs,
            :virtual => true,
            :sibling => misc[:sibling],
            :insp => misc[:insp],
            :layout => misc[:layout],
            :options => misc[:options],
            :name => nil,
          }
      @containers.push [cnt, m]
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

    # menu stuff
    def factory_menu_bar(name, options = {}, &block)
      cb = Proc.new do |id, w|
        id = id.gsub('_', '') if id.is_a?(String)
        m = "menu_#{name}_on_active"
        self.send(m, id, Gtk::ItemFactory.path_from_widget(w), w) if self.respond_to?(m)
      end
      @item_factory_stack ||= []
      @item_factory_stack.push [cb, [], []]
      block.call(name) if block
      options[:id] ||= name.to_sym
      _, _, items = @item_factory_stack.pop
      accel_group = Gtk::AccelGroup.new
      add_accel_group(accel_group)
      fact = Gtk::ItemFactory.new(Gtk::ItemFactory::TYPE_MENU_BAR, "<#{name}>", accel_group)
      fact.create_items(items)
      
      # process item attributes
      items.each do |x|
        # TODO: ...
      end
      layout_component(fact.get_widget("<#{name}>"), options, nil)
    end

    def factory_menu_item(name, options = {}, &block)
      cb, stack, items = @item_factory_stack.last
      branch = false
      options[:type] ||= :Item
      case name
      when /^[-]+$/
        options[:type] = :Separator
      when /^<[-]+>$/
        options[:type] = :Tearoff
      when /^>>(.+)>>$/
        name = $1
        branch = true
        options[:type] = :LastBranch
      when /^<(.+)>$/
        name = $1
        branch = true
        options[:type] = :Branch
      end

      image = options.delete(:image)
      if image.is_a?(String)
        options[:type] = :ImageItem
        image = Gdk::Pixbuf.new(image)
      elsif image.is_a?(Gdk::Pixbuf)
        options[:type] = :ImageItem
      elsif image
        options[:type] = :StockItem
      end

      item = [  "#{stack.last}/#{name}",
                  "<#{options[:type].to_s}>",
                  options[:accel],
                  image,
                  cb,
                  options[:id] || name
                ]
      items << item
      if branch
        stack.push "#{stack.last}/#{name}"
        block.call(name) if block
        stack.pop if branch
      end
      item
    end

    private

    def add_singleton_event_map(w)
      class << w
        alias_method :simple_layout_singleton_method_missing, :method_missing
        def method_missing(sym, *args, &block)
          if sym.to_s =~ /^on_([^=]+)(=*)$/
            block ||= args.last
            return EventHandlerProxy.new(self, $1, &block)
          else
            simple_layout_singleton_method_missing(sym, *args, &block)
          end
        end
      end
    end

    # create the inspector eventbox for widget
    def make_inspect_evb(cnt_misc, w, name, layout_opt, options)
      insp_evb = nil
      insp_opt = self.class.inspector_opt
      if insp_opt[:enable]
        rgb = 0xffff - @containers.size * 0x1000
        insp_evb = evb = Gtk::EventBox.new
        sub_evb = Gtk::EventBox.new
        sub_evb.add w
        evb.add sub_evb
        sub_evb.border_width = insp_opt[:border_width]
        evb.modify_bg Gtk::STATE_NORMAL, Gdk::Color.new(rgb, rgb, rgb)
        evbs = []
        tips = ""
        @containers.size.times do |i|
          cnt, m = @containers[i]
          if m[:insp] && (not m[:virtual])
            evbs << m[:insp]
            tips << "<b>container[#{i}]: #{cnt.class}#{m[:name] ? " (#{m[:name]})" : ''}</b>\n"
            tips << "  layout: #{m[:layout].inspect}\n" if m[:layout]
            tips << "  options: #{m[:options].inspect}\n" if m[:options] && m[:options].size > 0
            tips << "  groups: #{m[:groups].inspect}\n" if m[:groups].size > 0
          end
        end
        evbs << evb
        tips << "<b>widget: #{w.class}#{name ? " (#{name})" : ''}</b>\n"
        tips << "  layout: #{layout_opt.inspect}\n" if layout_opt
        tips << "  options: #{options.inspect}\n" if options && options.size > 0
        tips << "  groups: #{cnt_misc[:groups].inspect}\n" if cnt_misc && cnt_misc[:groups].size > 0

        evb.signal_connect('event') do |b, evt|
          b.tooltip_markup = tips
          case evt.event_type
          when Gdk::Event::ENTER_NOTIFY, Gdk::Event::LEAVE_NOTIFY            
            evbs.size.times do |i|
              rgb = 0xffff - i * 0x1000
              if evt.event_type == Gdk::Event::ENTER_NOTIFY
                evbs[i].modify_bg Gtk::STATE_NORMAL, Gdk::Color.new(rgb, rgb - 0x2000, rgb - 0x2000)
              elsif evt.event_type == Gdk::Event::LEAVE_NOTIFY
                evbs[i].modify_bg Gtk::STATE_NORMAL, Gdk::Color.new(rgb, rgb, rgb)
              end
            end
          end
        end
      end
      insp_evb
    end

    # create a new UI component (container or widget)
    def create_component(component_class, args, block)
      @common_attribute ||= []
      options = {}
      options = args.pop if args.last.is_a?(Hash)
      options.merge! @common_attribute.last if @common_attribute.last

      w = component_class.new(*args)
      layout_component(w, options, block)
    end

    # layout the new UI component (container or widget)
    def layout_component(w, options, block)
      @containers ||= []
      @pass_on_stack ||= []
      @components ||= {}
      @common_attribute ||= []
      @component_children ||= {}

      add_singleton_event_map(w) # so that you can use: w.on_clicked{|*args| ... }
      
      name = options.delete(:id)
      group_name = options.delete(:gid) || name
      layout_opt = options.delete(:layout)
      keep_top_cnt = options.delete(:keep_top_container)

      options.each do |k, v|
        if v.is_a?(Array)
          w.send(k.to_s, *v) if w.respond_to?(k.to_s)
        else
          w.send(k.to_s + '=', v) if w.respond_to?(k.to_s + '=')
        end
      end

      @components[name] = w if name
      gs = (group_name ? [group_name].flatten : [])
      gs.each{|g| @component_children[g] ||= [] }

      misc = nil
      if @containers.size > 0
        container, misc = @containers.last
        misc[:groups].each{ |g| @component_children[g].push w }
        misc[:sibling] += 1
      end
      insp_evb = make_inspect_evb(misc, w, name, layout_opt, options)

      if block # if given block, it's a container as well
        m = { :groups => gs,
              :sibling => 0,
              :insp => insp_evb,
              :name => name,
              :layout => layout_opt,
              :options => options,
            }
        @containers.push [w, m]
        @pass_on_stack.push [false, nil]
        @common_attribute.push({})
        block.call(w) if block
        @common_attribute.pop
        @pass_on_stack.pop
        @containers.pop
      end

      if @containers.size > 0
        add_component(insp_evb || w, container, layout_opt) # add myself to parent
      else
        add_component(insp_evb || w, self, layout_opt) unless keep_top_cnt # add top container to host
        @components[:self] = self  # add host as ':self'
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

    alias_method :simple_layout_method_missing_alias, :method_missing

    def method_missing(sym, *args, &block)
      if sym =~ /^(.+)_in_(.+)$/
        maps = self.class.layout_class_maps
        inner, outter = $1, $2
        if maps[inner] && maps[outter]
          if args.last.is_a?(Hash)
            options = {}
            options = args.pop if args.last.is_a?(Hash)

            # default args pass to inner component, execpt:
            #  :layout pass to outter :layout
            #  :inner_layout pass to inner :layout
            #  :outter_args pass to outter args
            outter_args, outter_layout_opt, options[:layout] =
              options.delete(:outter_args), options.delete(:layout), options.delete(:inner_layout)

            outter_args = (outter_args ? [outter_args] : []) unless outter_args.is_a?(Array)
            outter_args << {} unless outter_args.last.is_a?(Hash)
            outter_args.last[:layout] ||= outter_layout_opt
            args.push options # push back inner options
          end

          inner_proc = Proc.new do
            create_component(maps[inner], args, block)
          end
          return create_component(maps[outter], outter_args || [], inner_proc)
        end
      end
      simple_layout_method_missing_alias(sym, *args, &block)
    end

  end
end
