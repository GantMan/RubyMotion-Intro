class GameLayer < Joybox::Core::Layer

  MaximumTacos = 10
  @cur_size = 1.0

  scene

  def on_enter
    @cur_size = 1.0

    background = Sprite.new file_name: 'background.png', position: Screen.center
    self << background

    @face = Sprite.new file_name: 'normal.png', position: Screen.center, alive: true
    self << @face

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

  def launch_tacos
    @tacos ||= Array.new

    if @tacos.size <= MaximumTacos
      missing_tacos = MaximumTacos - @tacos.size

      missing_tacos.times do
        taco = TacoSprite.new

        move_action = Move.to position: taco.end_position, duration: 4.0
        callback_action = Callback.with { |taco| @tacos.delete taco }
        taco.run_action Rotate.by angle: rand(360)
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
          @tacos.each(&:stop_all_actions) if @cur_size > 3 # end game

          @face[:alive] = false
          @cur_size += 1
          @face.file_name = "eat.png"
          @face.run_action Blink.with times: 20, duration: 3.0
          @face.run_action Scale.to scale: @cur_size
          break
        end
      end
    end
  end

end