-- foot controller
-- midi notes from 60 to 69
-- tahiti looper config 

m = midi.connect() -- midi input

m.event = function (data)
  local d = midi.to_msg(data)
  if (d.note == 60) and (d.type == "note_on") then sw1_on() end
  if (d.note == 60) and (d.type == "note_off") then sw1_off() end
  if (d.note == 61) and (d.type == "note_on") then sw2_on() end
  if (d.note == 61) and (d.type == "note_off") then sw2_off() end
  if (d.note == 62) and (d.type == "note_on") then sw3_on() end
  if (d.note == 62) and (d.type == "note_off") then sw3_off() end
  if (d.note == 63) and (d.type == "note_on") then sw4_on() end
  if (d.note == 63) and (d.type == "note_off") then sw4_off() end
  if (d.note == 64) and (d.type == "note_on") then sw5_on() end
  if (d.note == 64) and (d.type == "note_off") then sw5_off() end
  if (d.note == 65) and (d.type == "note_on") then sw6_on() end
  if (d.note == 65) and (d.type == "note_off") then sw6_off() end
  if (d.note == 66) and (d.type == "note_on") then sw7_on() end
  if (d.note == 66) and (d.type == "note_off") then sw7_off() end
  if (d.note == 67) and (d.type == "note_on") then sw8_on() end
  if (d.note == 67) and (d.type == "note_off") then sw8_off() end
end 

-- PARAMETERS
-- switch assignation
functions = {"record", "recordN"}
params:add_option("switch 1", "sw1", functions, 1)
params:add_option("switch 2", "sw2", functions, 2)

function sw1_on()
  print"switch1_on" 
  -- call function asign to switch1
  if params:get("switch 1") == 1 then record() end
  -- params:get("switch 1")()
  -- func[params:get("switch 1")]()
end
function sw2_on()
  print"switch2_on" 
  if params:get("switch 2") == 2 then overdub() end
end
function sw3_on()
  print"switch3_on" 
  if params:get("switch 3") == 3 then replace() end
end
function sw4_on()
  print"switch4_on" 
  if params:get("switch 4") == 4 then substitute() end
end
function sw5_on()
  print"switch5_on" 
  if params:get("switch 5") == 5 then undo() end
end
function sw6_on()
  print"switch6_on" 
  if params:get("switch 6") == 6 then insert() end
end
function sw7_on()
  print"switch7_on" 
  if params:get("switch 7") == 7 then instut() end
end
function sw8_on()
  print"switch8_on" 
  if params:get("switch 8") == 8 then multiply() end
end

function sw1_off()
end
function sw2_off()
end
function sw3_off()
end
function sw4_off()
end
function sw5_off()
end
function sw6_off()
end
function sw7_off()
end
function sw8_off()
end
