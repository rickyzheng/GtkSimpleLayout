require 'gtk3'

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
        '_image' => Gtk::Image,
        '_label' => Gtk::Label,
        '_progress_bar' => Gtk::ProgressBar,
        '_status_bar' => Gtk::Statusbar,
        '_button' => Gtk::Button,
        '_check_button' => Gtk::CheckButton,
        '_radio_button' => Gtk::RadioButton,
        '_toggle_button' => Gtk::ToggleButton,
        '_link_button' => Gtk::LinkButton,
        '_entry' => Gtk::Entry,
        '_scale' => Gtk::Scale,
        '_hscale' => [Gtk::Scale, :horizontal],
        '_vscale' => [Gtk::Scale, :vertical],
        '_spin_button' => Gtk::SpinButton,
        '_text_view' => Gtk::TextView,
        '_tree_view' => Gtk::TreeView,
        '_cell_view' => Gtk::CellView,
        '_icon_view' => Gtk::IconView,
        '_combobox' => Gtk::ComboBoxText,
        #'combobox_entry' => Gtk::ComboBoxEntry,
        '_menu' => Gtk::Menu,
        '_menubar' => Gtk::MenuBar,
        '_menuitem' => Gtk::MenuItem,
        '_menuitem_radio' => Gtk::RadioMenuItem,
        '_menuitem_check' => Gtk::CheckMenuItem,
        '_menuitem_separator' => Gtk::SeparatorMenuItem,
        '_menuitem_teoroff' => Gtk::TearoffMenuItem,
        '_toolbar' => Gtk::Toolbar,
        '_toolitem' => Gtk::ToolItem,
        '_separator_toolitem' => Gtk::SeparatorToolItem,
        '_tool_button' => Gtk::ToolButton,
        '_toggle_tool_button' => Gtk::ToggleToolButton,
        '_radio_tool_button' => Gtk::RadioToolButton,
        '_color_button' => Gtk::ColorButton,
        '_color_chooser' => Gtk::ColorChooserWidget,
        '_file_chooser_button' => Gtk::FileChooserButton,
        '_file_chooser_widget' => Gtk::FileChooserWidget,
        '_font_button' => Gtk::FontButton,
        '_font_selection' => Gtk::FontSelection,
        '_alignment' => Gtk::Alignment,
        '_aspect_frame' => Gtk::AspectFrame,
        '_box' => Gtk::Box,
        '_vbox' => [Gtk::Box, :vertical],
        '_hbox' => [Gtk::Box, :horizontal],
        '_button_box' => Gtk::ButtonBox,
        '_vbutton_box' => [Gtk::ButtonBox, :vertical],
        '_hbutton_box' => [Gtk::ButtonBox, :horizontal],
        '_paned' => Gtk::Paned,
        '_hpaned' => [Gtk::Paned, :horizontal],
        '_vpaned' => [Gtk::Paned, :vertical],
        '_layout' => Gtk::Layout,
        '_notebook' => Gtk::Notebook,
        '_table' => Gtk::Table,
        '_expander' => Gtk::Expander,
        '_frame' => Gtk::Frame,
        '_separator' => Gtk::Separator,
        '_hseparator' => [Gtk::Separator, :horizontal],
        '_vseparator' => [Gtk::Separator, :vertical],
        '_scrollbar' => Gtk::Scrollbar,
        '_hscrollbar' => [Gtk::Scrollbar, :horizontal],
        '_vscrollbar' => [Gtk::Scrollbar, :vertical],
        '_scrolled_window' => Gtk::ScrolledWindow,
        '_arrow' => Gtk::Arrow,
        '_calendar' => Gtk::Calendar,
        '_drawing_area' => Gtk::DrawingArea,
        '_event_box' => Gtk::EventBox,
        '_handle_box' => Gtk::HandleBox,
        '_viewport' => Gtk::Viewport,
        '_fixed' => Gtk::Fixed,
        #'curve' => Gtk::Curve,
        #'gamma_curve' => Gtk::GammaCurve,
        #'hruler' => Gtk::HRuler,
        #'vruler' => Gtk::VRuler,
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
    def add_component(w, container, layout_opt)
      if @pass_on_stack.last.nil? || @pass_on_stack.last[0] == false
        if container.is_a?(Gtk::Box)
          layout_opt ||= [expand: false, fill: false, padding: 0]
          pack_method = 'pack_start'
          railse LayoutError, "layout_opt should be an Array" unless layout_opt.is_a?(Array)
          if layout_opt.first.is_a?(Symbol) && layout_opt[0] == :end
            layout_opt.shift  # remove the first ':end'
            pack_method = 'pack_end'
          end
          if layout_opt.size == 1 && layout_opt.last.is_a?(Hash)
            # if there is only one Hash in layout_opt, it's the keyword arguments for pack_start or pack_end
            container.send(pack_method, w, **layout_opt.last)
          else
            # else it's the position arguments, old style, we need to conver to keyword arguments
            opt = {expand: layout_opt[0], fill: layout_opt[1], padding: layout_opt[2]}
            container.send(pack_method, w, **opt)
          end
        elsif container.is_a?(Gtk::Fixed) || container.is_a?(Gtk::Layout)
          layout_opt ||= [0, 0]
          container.put w, *layout_opt
        elsif container.is_a?(Gtk::MenuShell) || container.is_a?(Gtk::MenuBar) || container.is_a?(Gtk::Menu)
          container.append w
        elsif container.is_a?(Gtk::MenuItem)
          container.submenu = w
        elsif container.is_a?(Gtk::Toolbar)
          container.insert(container.n_items, w)
        elsif container.is_a?(Gtk::MenuToolButton)
          container.menu = w
        elsif container.is_a?(Gtk::ScrolledWindow)
          container.add_with_viewport(w)
          if layout_opt && layout_opt.size > 0
            if layout_opt.size == 1 && layout_opt.first.is_a?(Hash)
              container.set_policy(**layout_opt.first)
            else
              container.set_policy(*layout_opt)
            end
          end
        elsif container.is_a?(Gtk::Table)
          # should use #grid or #grid_flx to add a child to Table
        elsif container.is_a?(Gtk::Notebook)
          # should use #page to add a child to Notebook
        elsif container.is_a?(Gtk::Paned)
          # should use #area_first or #area_second to add child to Paned
        elsif container.is_a?(Gtk::Container) || container.respond_to?(:add)
          # lastly, if it's a general container or respond to 'add', use #add to add child
          args = [w, *layout_opt].flatten
          container.add(*args)
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
            :accel_group => misc[:accel_group],
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
      container_pass_on(Gtk::Notebook, 'append_page', Gtk::Label.new(text), block)
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
      layout_component(fact.get_widget("<#{name}>"), [], options)
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

    # layout the new UI component (container or widget)
    # w: the widget
    # args: the arguments for creating the widget (just for inspection purpose)
    # options: the options for layout the widget
    # block: the block for creating the children
    def layout_component(w, args, options = {}, &block)
      @containers ||= []
      @pass_on_stack ||= []
      @components ||= {}
      @common_attribute ||= []
      @component_children ||= {}

      add_singleton_event_map(w) # so that you can use: w.on_clicked{|*args| ... }

      # there are some special options: :id, :gid, :layout
      # :id is the name of the component, :gid is the group name of the component, if :gid is not given, use :id as group name
      # :layout is the layout options for the component
      name = options.delete(:id)
      group_name = options.delete(:gid) || name
      layout_opt = options.delete(:layout)
      accel_group = options.delete(:accel_group)
      accel = options.delete(:accel)

      # the rest of the key-value pairs are turn into the function calls if the widget response to the key
      options.each do |k, v|
        if v.is_a?(Array)   # e.g. :set_size_request => [100, 100] turn into w.set_size_request(100, 100)
          w.send(k.to_s, *v) if w.respond_to?(k.to_s)
        else                # e.g. :size => 10 turn into w.size = 10
          w.send(k.to_s + '=', v) if w.respond_to?(k.to_s + '=')
        end
      end

      @components[name] = w if name   # add the widget to the components hash, if 'name' is given

      # if :gid is given, create the group if the group is not exist
      gs = (group_name ? [group_name].flatten : [])
      gs.each{|g| @component_children[g] ||= [] }

      parent, param = nil, nil
      if @containers.size > 0
        parent, param = @containers.last
        param[:groups].each{ |g| @component_children[g].push w }   # add the widget to the parent's children group
        param[:sibling] += 1    # record the sibling count

        # if the widget is a menuitem, add the accelerator to the menuitem
        menuitem_add_accel_group(w, accel, param[:accel_group]) if accel && param[:accel_group]

      end

      # if parent is a ScrolledWindow, create the inspector eventbox around the widget
      insp_evb = nil
      unless parent and parent.is_a?(Gtk::ScrolledWindow)
        insp_evb = make_inspect_evb(param, w, name, args, layout_opt, options)
      end

      if block # if given block, it's a container

        # if the widget options has :accel_group (a menu widget), create a new accelerator group to the container(menu)
        @components[accel_group] = Gtk::AccelGroup.new if accel_group
        m = { :groups => gs,
              :sibling => 0,
              :insp => insp_evb,
              :name => name,
              :layout => layout_opt,
              :options => options,
              :args => args,
              :accel_group => accel_group,
            }
        @containers.push [w, m] # push the new container to the stack
        @pass_on_stack.push [false, nil]
        @common_attribute.push({})
        block.call(w) # create the children
        @common_attribute.pop
        @pass_on_stack.pop
        @containers.pop
      end

      if @containers.size > 0
        add_component(insp_evb || w, parent, layout_opt) # add myself to parent
      else
        @components[:self] = self  # add host as ':self'
      end
      insp_evb || w
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

    # add accelerator to the munuitem
    # w: the menuitem widget
    # accel: the accelerator string
    # accel_group: the accelerator group id
    def menuitem_add_accel_group(w, accel, accel_group)
      # if accel is given, the widget is a menuitem, parse the accel string and add the accelerator to the widget
      if w && @components[accel_group] && accel && w.is_a?(Gtk::MenuItem) #w.respond_to?(:add_accelerator)
        if accel.to_s =~ /^<(.+)>(.*)$/
          ctl, key = $1, $2
          mask, kc = nil, nil
          case ctl.downcase
          when 'ctrl', 'control'
            mask = Gdk::ModifierType::CONTROL_MASK
          when 'alt'
            mask = Gdk::ModifierType::MOD1_MASK
          when 'meta', 'cmd', 'command'
            if RUBY_PLATFORM =~ /darwin/
              mask = Gdk::ModifierType::META_MASK
            else
              mask = Gdk::ModifierType::MOD1_MASK # for non-Mac, use Alt
            end
          when 'shift'
            mask = Gdk::ModifierType::SHIFT_MASK
          else
            mask = nil
          end

          case key.downcase
          when 'f1'..'f12'
            kc = Gdk::Keyval.const_get("GDK_KEY_#{key}")
          when 'a'..'z'
            kc = Gdk::Keyval.const_get("KEY_#{key.upcase}")
          when 'plus'
            kc = Gdk::Keyval::GDK_PLUS
          when 'minus'
            kc = Gdk::Keyval::GDK_MINUS
          else
            kc = nil
          end
    
          if mask && kc
            w.add_accelerator('activate', @components[accel_group], kc, mask, Gtk::AccelFlags::VISIBLE)
          end
        end
      end

    end

    # create the inspector eventbox color
    # level: the level of the container stack
    # mode: :enter or :leave
    def inspect_box_color(level:, mode:)
      @evb_colors ||= {}  # color cache
      rgb = 1 - (level+2) / 12.0
      case mode
      when :enter
        @evb_colors["#{level}_#{mode}"] ||= Gdk::RGBA.new(rgb, rgb + 0.2, rgb + 0.2, 1)
      when :leave
        @evb_colors["#{level}_#{mode}"] ||= Gdk::RGBA.new(rgb, rgb, rgb, 0.6)
      end
    end

    # create the inspector eventbox for widget
    def make_inspect_evb(cnt_misc, w, name, args, layout_opt, options)
      insp_evb = nil
      insp_opt = self.class.inspector_opt
      if insp_opt[:enable]
        insp_evb = evb = Gtk::EventBox.new
        sub_evb = Gtk::EventBox.new
        sub_evb.add w
        evb.add sub_evb
        sub_evb.border_width = insp_opt[:border_width].to_i
        evb.override_background_color :normal, inspect_box_color(level: @containers.size, mode: :leave)
        evbs = []
        tips = ""
        @containers.size.times do |i|
          cnt, m = @containers[i]
          if m[:insp] && (not m[:virtual])
            evbs << m[:insp]
            tips << "<b>container[#{i}]: #{cnt.class}#{m[:name] ? " (#{m[:name]})" : ''}</b>\n"
            tips << "  args: #{m[:args].inspect}\n" if m[:args] && m[:args].size > 0
            tips << "  layout: #{m[:layout].inspect}\n" if m[:layout]
            tips << "  options: #{m[:options].inspect}\n" if m[:options] && m[:options].size > 0
            tips << "  groups: #{m[:groups].inspect}\n" if m[:groups].size > 0
          end
        end
        evbs << evb
        tips << "<b>widget: #{w.class}#{name ? " (#{name})" : ''}</b>\n"
        tips << "  args: #{args.inspect}\n" if args && args.size > 0
        tips << "  layout: #{layout_opt.inspect}\n" if layout_opt
        tips << "  options: #{options.inspect}\n" if options && options.size > 0
        tips << "  groups: #{cnt_misc[:groups].inspect}\n" if cnt_misc && cnt_misc[:groups].size > 0

        evb.signal_connect('enter-notify-event') do |b, _|
          b.tooltip_markup = tips
          evbs.size.times do |i|
            evbs[i].override_background_color :normal, inspect_box_color(level: i, mode: :enter)
          end
        end

        evb.signal_connect('leave-notify-event') do |b, _|
          b.tooltip_markup = nil
          evbs.size.times do |i|
            evbs[i].override_background_color :normal, inspect_box_color(level: i, mode: :leave)
          end
        end

      end
      insp_evb
    end

    # create a new UI component (container or widget)
    def create_component(class_desc, args, block)
      @common_attribute ||= []
      options = {}
      if class_desc.is_a?(Array) # for virtual widget that use existing widget with specific args, e.g [Gtk::Box, :vertical]
        component_class = class_desc[0]
        args = class_desc[1..-1] + args
      else
        component_class = class_desc
      end
      options = args.pop if args.last.is_a?(Hash)
      options.merge! @common_attribute.last if @common_attribute.last

      if args.size == 1 && args.first.is_a?(Array) && args.first.size == 1 && args.first.first.is_a?(Hash)
        w = component_class.new(**args.first.first)
      else
        case component_class.to_s
        when /(Button)$/
          w = component_class.new(label: args[0])
        when /(MenuItem)$/
          w = component_class.new(label: args[0])
        else
          w = component_class.new(*args)
        end
      end
      layout_component(w, args, options, &block)
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
      if sym.to_s =~ /^(.+)_in(_.+)$/
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
