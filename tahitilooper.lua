-- tahiti looper - fifo circular looper
-- up to 6 synchronized loopers of different length
-- first in first out type of looper
-- audio input required
-- E1 overall loopers volume
-- E2 select looper
-- E3 select action
-- K2 rec/play
-- K3 apply action
-- K1 + K2 reset
-- K1 + K3 change mode (manual/auto)

-- parameters
params:add{type = "number", id = "numberOfLoopers", name = "number of loopers", min = 1, max = 6, default = 6}
params:add{type = "number", id = "numberOfBeats", name = "number of beats", min = 1, max = 16, default = 8}
local bufferLength = 30 -- maximum recording time per looper
local action = 1 -- selected action
local rate = {} -- loopers rate
local beats = {} -- loopers length in beats
local state = {"empty", "empty", "empty", "empty", "empty", "empty"}
local rec = 0
local recordLength = 0.0
local looper = 1 -- looper armed
local beatLength = 0
local volume = 40
local auto = false
local randomness = 50
local iconpos = 20
-- local selectedLooper = 1

function init()
  rate = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0} -- loopers rate
	beats = {1, 1, 1, 1, 1, 1} -- loopers number of beats
  rec = 0 -- record state
  recordLength = 0.0
  looper = 1 -- looper id (1 to 6)
  firstLoop = 0
  beatLength = 0.0
  auto = false
  randomness = 50
  -- send audio input to softcut input
	audio.level_adc_cut(1)
  softcut.buffer_clear()
	-- initialize all 6 loopers
	for i = 1,6 do
	  print (i)
	  -- softcut setup
    -- audio.level_cut(1)
    audio.level_adc_cut(1)
    softcut.level_input_cut (1, i, 0) -- stereo into softcut
    softcut.level_input_cut (2, i, 0)
    audio.level_eng_cut(1)
    softcut.level_slew_time(i,0.1)
	  softcut.enable(i,1)
	  softcut.buffer(i,1) -- each voice uses buffer 1
	  softcut.level(i,0.5)
	  softcut.loop(i,1)
	  softcut.rate(i,1)
	  softcut.loop_start(i,(i-1)*bufferLength)
	  softcut.loop_end(i,i*bufferLength)
	  softcut.position(i,(i-1)*bufferLength)
	  softcut.play(i,0)
	  softcut.rec(i,0)
	  -- set input rec level: input channel, voice, level
	  -- softcut.level_input_cut(1,i,1.0)
	  softcut.level_input_cut(2,i,1.0)
	  -- set voice 1 record level
	  softcut.rec_level(i,1.0)
	  -- set voice 1 pre level
	  softcut.pre_level(i,0)
	  -- slewtime
	  softcut.level_slew_time (i, 0.0001)
	  softcut.recpre_slew_time (i, 0.0001)
	  softcut.rate_slew_time(i,0.1)
	  softcut.fade_time(i, 0.001)
	  softcut.filter_dry(i, 1)
	  softcut.pan(i, 0)
	  state = {"stop", "stop", "stop", "stop", "stop", "stop"}
	end


-- metro for auto mode
  metro.free_all()
  press = metro.init()
  press.time = 1
  press.count = -1
  press.event = randomAction
  press:stop()
  print("init")
  
end -- end init

-- functions on looper
function rev() rate[looper]=-rate[looper]; softcut.rate(looper, rate[looper]) end
-- function forward() softcut.rate(looper, rate[looper]); state[looper]="playing" end
function halfSpeed()
  if rate[looper]>0 then
    rate[looper]=util.clamp(rate[looper]/2, 0.5, 2)
  else
    rate[looper]=util.clamp(rate[looper]/2, -2, -0.5)
  end  
  softcut.rate(looper, rate[looper]) 
end
function doubleSpeed() 
  if rate[looper]>0 then
    rate[looper]=util.clamp(rate[looper]*2, 0.5, 2)  
  else
    rate[looper]=util.clamp(rate[looper]*2, -2, -0.5)
  end
  softcut.rate(looper, rate[looper])
end
-- function doubleSpeed() softcut.rate(looper, rate[looper]*2); state[looper]="double" end
function stop() softcut.play(looper,0); state[looper]="stop" end
function play() softcut.play(looper,rate[looper]); state[looper]="playing" end
function offset() softcut.position(looper, looper * bufferLength) end
-- function shorter() softcut.loop_start(looper, looper * bufferLength + beatLength) end
local labels = {"<>", "-", "+", "[]", ">", ">>"}
local actions = {rev, halfSpeed, doubleSpeed, stop, play, offset}

function draw_stop(i)
  screen.rect((i-1)*20 + 10, 20, 10, 10)
  screen.stroke()
end
function draw_play(i)
  screen.move((i-1)*20 + 10, iconpos)
  screen.line_rel(10,5)
  screen.line_rel(-10,5)
  screen.line_rel(0,-10)
  screen.stroke()
end
function draw_record(i)
  screen.circle((i-1)*20+15,iconpos+5,5)
  screen.stroke()
end
function draw_rev(i)
  screen.move((i-1)*20 + 10, iconpos+5)
  screen.line_rel(10,-5)
  screen.line_rel(0,10)
  screen.line_rel(-10,-5)
  screen.stroke() 
end
function draw_double(i)
  screen.move((i-1)*20 + 10, iconpos)
  screen.line_rel(5,5)
  screen.line_rel(-5,5)
  screen.line_rel(0,-10)
  screen.stroke()
  screen.move((i-1)*20 + 15, iconpos)
  screen.line_rel(5,5)
  screen.line_rel(-5,5)
  screen.line_rel(0,-10)
  screen.stroke()
end
function draw_half(i)
  screen.move((i-1)*20 + 10, iconpos)
  screen.line_rel(5,5)
  screen.line_rel(-5,5)
  screen.line_rel(0,-10)
  screen.stroke()
end
function draw_rev_double(i)
  screen.move((i-1)*20+20, iconpos)
  screen.line_rel(0,10)
  screen.line_rel(-5,-5)
  screen.line_rel(5,-5)
  screen.stroke()
  screen.move((i-1)*20+15, iconpos)
  screen.line_rel(0,10)
  screen.line_rel(-5,-5)
  screen.line_rel(5,-5)
  screen.stroke()
end
function draw_rev_half(i)
  screen.move((i-1)*20+20, iconpos)
  screen.line_rel(0,10)
  screen.line_rel(-5,-5)
  screen.line_rel(5,-5)
  screen.stroke()
end

function randomAction()
  if rec == 0 then
    l = looper
    looper = math.random(params:get("numberOfLoopers"))
    actions[math.random(#actions)]()
    looper = l
    redraw()
    print("random action")
  end
end


function recPlay ()
	if rec==0 then
		-- start recording with the looper armed
		rec = 1
		start_time = util.time()
		softcut.loop_end(looper, looper*bufferLength) -- set maximum recording time
		softcut.position(looper,(looper-1)*bufferLength)
		softcut.play(looper,0)
		softcut.rec(looper,1)
		state[looper]="recording"
	else
		-- stop recording
		rec = 0
		recordLength = util.time() - start_time
		if firstLoop == 0 then
			beatLength = recordLength / params:get("numberOfBeats")
			firstLoop = 1
			print ("beat length : " .. (beatLength))
		else
			-- change the loop length to the closest beat subdivision
			recordLength = util.round(recordLength/beatLength, 1) * beatLength
		end
		-- set to actual recording time
		softcut.loop_end(looper,(looper-1)*bufferLength+recordLength)
		-- start playing
		softcut.rec(looper,0)
		softcut.position(looper,(looper-1)*bufferLength)
		softcut.play(looper,1)
		state[looper]="playing"
		beats[looper] = recordLength/beatLength
		-- arm next looper
		looper = looper + 1
		if looper > params:get("numberOfLoopers") then looper = 1 end
	end
end

function key(n,z)
    if n == 1 then
      alt = z == 1 and true or false
    end
  	if n==2 and z==1 then
  	  if alt then
		    -- stop and reset all the loopers
	  	  init()
	  	else
		    -- Rec/Play button
		    recPlay()
		  end
  elseif n==3 and z==1 then
      if alt then
        auto = not auto
        print (auto)
        if auto then
          press:start() 
          print("auto")
        else
          press:stop()
          print("manual")
        end
      else
	      actions[action]()
	    end
	end
  redraw()
end

function enc(n,d)
  if n==1 then
  -- adjust loopers output volume (0 to 100)
	-- volume = math.min(1.0, (math.max(volume+d/10, 0))
  -- volume = util.clamp(volume + d / 10, 0, 100)
	for voice = 1,6 do
		softcut.level(voice, volume / 100)
  end
  elseif n==2 then
      -- select looper
  looper = util.clamp (looper + d, 1, params:get("numberOfLoopers"))
  elseif n==3 then
    if not auto then
      -- choose action to perform
      action = util.clamp (action + d, 1, #labels)
    else
    -- auomatic mode frequency
      randomness = util.clamp(randomness + d, 0, 100)
      press.time = 100/randomness
    end
  end
  redraw()
end

function redraw()
  screen.clear()
  for i = 1, params:get("numberOfLoopers") do
    if i == looper then 
      -- highlight slected looper
      screen.level (15)
    else
      screen.level (3)
    end
    if state[i]=="recording" then
      draw_record(i)
    elseif state[i]=="playing" and rate[i]==1 then
      draw_play(i)
    elseif state[i]=="playing" and rate[i]==2 then
      draw_double(i)
    elseif state[i]=="playing" and rate[i]==0.5 then
      draw_half(i)
    elseif state[i]=="playing" and rate[i]==-1 then
      draw_rev(i)
    elseif state[i]=="playing" and rate[i]==-2 then
      draw_rev_double(i)
    elseif state[i]=="playing" and rate[i]==-0.5 then
      draw_rev_half(i)
    else
      draw_stop(i)
    end
  end
  --screen.level(6)
  if not auto then
    -- auto mode control
    for i = 1, #labels do
      if i == action then
        screen.level(15)
      else
        screen.level(3)
      end
      screen.move (i*21-10, 50)
      screen.text_center (labels[i])
    end
    screen.stroke()
  else
    -- automatic mode control
    screen.level(5)
    screen.rect (15,45,randomness,10)
    screen.stroke()
  end
  -- screen.level(5)
	screen.update()
end



