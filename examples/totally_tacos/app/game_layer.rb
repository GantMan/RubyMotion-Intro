class GameLayer < Joybox::Core::Layer

  @max_tacos = 0
  @cur_size = 1.0

  scene

  def on_enter
    SimpleAudioEngine.sharedEngine.playBackgroundMusic "MexicanFiesta.mp3"

    background = Sprite.new file_name: 'background.png', position: Screen.center
    self << background

    @face = Sprite.new file_name: 'normal.png', position: Screen.center, alive: true
    @face.run_action Fade.out
    self << @face

    show_menu
  end

  def show_menu
    p "Menu shown"
    MenuLabel.default_font_size = 60

    start_label = MenuLabel.new text: "Start Game", color: '#000000'.to_color, do |menu_item|
      start_game
    end

    @menu = Menu.new items: [start_label], position: [Screen.half_width, Screen.half_height]
    @menu.align_items_vertically
    self.add_child(@menu, z: 1)
  end

  def start_game
    p "Game Start"

    @cur_size = 1.0
    @max_tacos = 10
    @menu.run_action Visibility.hide
    @face.run_action Fade.in
    @face.position = Screen.center
    @face.scale = @cur_size
    @face.rotation = 0

    on_touches_began do |touches, event|
      touch = touches.any_object
      @face.run_action Move.to position: touch.location
    end

    on_touches_moved do |touches, event|
      touch = touches.any_object
      @face.position = touch.location
    end

    schedule_update do |dt|
      launch_tacos
      check_for_collisions if @face[:alive]
    end   

  end

  def lose_game
    p "Ya lost"
    @max_tacos = 0
    @face.stop_all_actions
    @face.run_action Fade.out
    @menu.run_action Visibility.show
  end

  def launch_tacos
    @tacos ||= Array.new

    if @tacos.size <= @max_tacos
      missing_tacos = @max_tacos - @tacos.size

      missing_tacos.times do
        taco = TacoSprite.new

        move_action = Move.to position: taco.end_position, duration: 4.0
        callback_action = Callback.with do |taco| 
          @tacos.delete taco
          self.removeChild(taco)
        end
        taco.run_action Rotate.by angle: rand(360), duration: 4.0
        taco.run_action Sequence.with actions: [move_action, callback_action]

        self << taco
        @tacos << taco
        @face[:alive] = true
        @face.file_name = 'normal.png'
      end
    end
  end

  def check_for_collisions
    if @face[:alive]
      @tacos.each do |taco|
        if CGRectIntersectsRect(taco.bounding_box, @face.bounding_box)

          @face[:alive] = false
          @cur_size += 1
          @face.file_name = "eat.png"
          @face.run_action Wiggle.with times: 5, duration: 2.0
          #@face.run_action Blink.with times: 20, duration: 3.0
          @face.run_action Scale.to scale: @cur_size

          lose_game if @cur_size > 3
          break
        end
      end #each
    end #if
  end

end