--[[
Generally Ordered Optimized Navigation.lua  (thanks for the idea fifi)
or "Something need Gooning"
thanks to @Akasha and @Ritsuko for some of the ideas/code

purpose: help autoduty with farming duties.

Plugins/configs (ill update as people realize i forgot instructions)
Automaton
Some form of bossmod
Rotation Solver Reborn
Vnavmesh
Pandora -> actually have this disabled it causes problems.
Something Need doing (SND)
Simpletweaks
and more (?)
Simpletweaks -> targeting fix
SND -> disable snd targeting
SND -> disable addon errors

Yesalready configs (maybe only the first one is needed since the rest are done via callbacks w ya off) also make sure yesalready is on :p ad turns it off sometimes (???)
	"YesNo"
		Return to the starting point for the Praetorium?   ※You may be unable to re-enter ongoing battles.
		/Repair all displayed items for.*/
		/Exit.*/
	"Lists"
		/Retire to an inn room.*/

Enhanced Duty start/end
	duty start -> /pcraft run start_gooning
	duty end -> /ad stop
	leave duty -> 10 seconds
Use whatever path you want. but i reccommend the included path file for tank and others. Credit to @Akasha and @Ritsuko for the path files.  tank tries to w2w, tank2 does not.

todo:
duty specific stuff like only do the phantom targetioong for gaeuis in prae

known issues:
I SAW AN UNKNOWN LUA ERROR so i might add debug lines everywhere until i catch it.

recommended party:
war dps dps sch
for sch in RSR turn off adloquim, succor and physick

--]]
yield("/echo please get ready for G.O.O.N ing time")

jigglecounter = 0
x1 = GetPlayerRawXPos()
y1 = GetPlayerRawYPos()
z1 = GetPlayerRawZPos()

stopcuckingme = 0    --counter for checking whento pop duty

--if its a cross world party everyoner will make a queue attempt
function isLeader()
    return (GetCharacterName() == GetPartyMemberName(GetPartyLeadIndex()))
end

imthecaptainnow = 0  --set this to 1 if its the party leader

if isLeader() then 
	imthecaptainnow = 1 
	yield("/echo I am the party leader i guess")
end

--------EDITABLE SETTINGS!---------
duty_counter = 0 --change this if you want to restart a "run" at a higher counter level becuase you were alreaday running it.
			     --just set it to whatever the last "current duty count" was from echos
				 --i.e. if you saw "This is duty # -> 17"  from the echo window , then set it to 17 before you resume your run for the day
echo_level = 3 --3 only show important stuff, 2 show the progress messages, 1 show more, 0 show all
----------------------------------

maxjiggle = 15 -- = how much time before we jiggle
entered_duty = 0


while 1 == 1 do
--safe check ifs
if IsPlayerAvailable() then
if type(GetCharacterCondition(34)) == "boolean" and type(GetCharacterCondition(26)) == "boolean" and type(GetCharacterCondition(4)) == "boolean" then
--
	--is there some bullshit and yesalready was disabled?
	yield("/callback SelectYesno true 0")
	--Do we need repairs?
	--check every 0.3 seconds 8 times so total looop is 2.4 seconds
	goat = 0
	while goat < 9 do
		goat = goat + 1
		yield("/wait 0.3")
		if GetCharacterCondition(34) == false then
			--SELF REPAIR
			local minicounter = 0
			--check if we even have g8dm, otherwise dont waste time, 10386 is g6dm if you wanna change it, 17837 is g7, 33916 is g8
			if GetItemCount(33916) > 0 then
				if NeedsRepair(99) then
					yield("/wait 10")
					while not IsAddonVisible("Repair") do
					  yield("/generalaction repair")
					  yield("/wait 1")
					  minicounter = minicounter + 1
					  if minicounter > 20 then
						minicounter = 0
						break
					  end
					end
					yield("/callback Repair true 0")
					yield("/wait 0.1")
					if IsAddonVisible("SelectYesno") then
					  yield("/callback SelectYesno true 0")
					  yield("/wait 1")
					end
					while GetCharacterCondition(39) do yield("/wait 1")
					yield("/wait 1")
					yield("/callback Repair true -1")
					  minicounter = minicounter + 1
					  if minicounter > 20 then
						minicounter = 0
						break
					  end
					end
				end
			end
			--JUST OUTSIDE THE INN REPAIR
			if NeedsRepair(50) and GetItemCount(1) > 4999 and GetCharacterCondition(34) == false and GetCharacterCondition(56) == false then --only do this outside of a duty yo
				yield("/ad repair")
				goatcounter = 0
				for goatcounter=1,30 do
					yield("/wait 0.5")
					yield("/callback _Notification true 0 17")
					yield("/callback ContentsFinderConfirm true 9")
				end
				yield("/ad stop")
			end
		end
		--reenter the inn room
		--if (GetZoneID() ~= 177 and GetZoneID() ~= 178) and GetCharacterCondition(34) == false and NeedsRepair(50) == false then
		if (GetZoneID() ~= 177 and GetZoneID() ~= 178) and GetCharacterCondition(34) == false then
			yield("/send ESCAPE")
			yield("/ad stop") --seems to be needed or we get stuck in repair genjutsu
			yield("/target Antoinaut") --gridania
			yield("/target Mytesyn")   --limsa
			yield("/target Otopa")     --uldah
			yield("/wait 1")
			yield("/lockon on")
			yield("/automove")
			yield("/wait 2")
			yield("/wait 0.5")
			yield("/callback _Notification true 0 17")
			yield("/callback ContentsFinderConfirm true 9")
			yield("/interact")
			yield("/wait 1")
			yield("/callback _Notification true 0 17")
			yield("/callback ContentsFinderConfirm true 9")
			yield("/callback SelectIconString true 0")
			yield("/callback _Notification true 0 17")
			yield("/callback ContentsFinderConfirm true 9")
			yield("/callback SelectString true 0")
			yield("/wait 1")
			--yield("/wait 8")
			--RestoreYesAlready()
		end
	end
	--end safe check one
	end
	end
	--
	--safe check ifs part 2
	if IsPlayerAvailable() then
	if type(GetCharacterCondition(34)) == "boolean" and type(GetCharacterCondition(26)) == "boolean" and type(GetCharacterCondition(4)) == "boolean" then
	--

	--yield("/echo x diff"..math.abs(x1 - GetPlayerRawXPos()))
	--check if we are stuck somewhere.
	--first ensure we are in the duty and not in combat

	if GetZoneID() == 1044 and GetCharacterCondition(26) == false then --Praetorium
		maxjiggle = 6
		flurb = "????"
		for flurby = 1,30 do
			if GetNodeText("_ToDoList", flurby, 3) == "Arrive at the command chamber: 0/1" then flurb = "Arrive at the command chamber: 0/1" end
			if GetNodeText("_ToDoList", flurby, 3) == "Clear the command chamber: 0/1" then flurb = "Clear the command chamber: 0/1" end
			if GetNodeText("_ToDoList", flurby, 3) == "Arrive at the Laboratorium Primum: 0/1" then flurb = "Arrive at the Laboratorium Primum: 0/1" end
			if GetNodeText("_ToDoList", flurby, 3) == "Clear the Laboratorium Primum: 0/1" then flurb = "Clear the Laboratorium Primum: 0/1" end
			if GetNodeText("_ToDoList", flurby, 3) == "Arrive on the Echelon: 0/1" then flurb = "Arrive on the Echelon: 0/1" end
			if GetNodeText("_ToDoList", flurby, 3) == "Defeat Gaius van Baelsar: 0/1" then flurb = "Defeat Gaius van Baelsar: 0/1" end
			yield("/wait 0.3")
		end
		if flurb == "Clear the Laboratorium Primum: 0/1"  and GetCharacterCondition(26) == false then
			flurb = GetNodeText("_ToDoList", 25, 3)
--this doesnt work the way i intended so removing it for now.
			--[[yield("/target Shortcut")
			yield("/wait 0.5")
			yield("/target Nero")
			yield("/wait 0.5")
			if type(GetTargetName()) == "string" and GetTargetName() == "Shortcut" then
				yield("/ad stop")
				yield("/interact")
				yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos())
				yield("/wait 10")
				yield("/interact")
				yield("/bmrai on")
				yield("/rotation auto")
			end
			if type(GetTargetName()) == "string" and GetCharacterCondition(26) == false then
				yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos())
			end
			--]]
		end
		if flurb == "Arrive on the Echelon: 0/1"  and GetCharacterCondition(26) == false then
			maxjiggle = 20
		end
		if flurb == "Defeat Gaius van Baelsar: 0/1" and GetCharacterCondition(26) == false then
			maxjiggle = 20
			yield("/target Magitek")
			yield("/wait 0.5")
			yield("/target Shortcut")
			yield("/wait 0.5")
			yield("/interact")
			yield("/hold W <wait.2.0>")
			yield("/release W")
			yield("/interact")
			if type(GetTargetName()) == "string" and GetTargetName() == "Shortcut" then
				--yield("/ad stop")
				yield("/interact")
				yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos())
				yield("/wait 10")
				yield("/interact")
				yield("/bmrai on")
				yield("/rotation auto")
			end
			if type(GetTargetName()) == "string" and GetCharacterCondition(26) == false then
				yield("/interact")
				yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos())
			end
			yield("/target Gauis")
			yield("/wait 0.5")
		end
		if echo_level < 3 then yield("/echo Prae Duty Progress -> "..flurb) end
	end

	--1044 is prae we only need this there atm
	if GetZoneID() == 1044 then --Praetorium
	--if GetZoneID() == 1044 and not HasTarget() then
	--	TargetClosestEnemy(30)
	--end
	if GetCharacterCondition(34) == true and GetCharacterCondition(26) == false then
		if math.abs(x1 - GetPlayerRawXPos()) < 3 and math.abs(y1 - GetPlayerRawYPos()) < 3 and math.abs(z1 - GetPlayerRawZPos()) < 3 then
			if echo_level < 4 then yield("/echo we havent moved very much something is up ") end
			jigglecounter = jigglecounter + 1
		end
		if jigglecounter > maxjiggle then --we stuck for 30+ seconds somewhere
			if echo_level < 4 then yield("/echo attempting to restart AD and hope for the best") end
			jigglecounter = 0
			--yield("/ad stop")
			yield("/wait 2")
			yield("/return")
			yield("/wait 1")
			yield("/callback SelectYesno true 0")
			yield("/wait 12")
			--yield("/ad start")
			yield("/wait 2")
		end
	end

		local mytarget = GetTargetName()
		if type(mytarget) == "string" and mytarget ~= "Phantom Gaius" then
			local ndist = GetDistanceToObject(null)
			local gdist = GetDistanceToObject("Phantom Gaius")
			local deltadist = ndist - gdist
			if (deltadist > 1 or deltadist < -1) and gdist < 100 then
				if echo_level < 1 then yield("/echo targeting nearby enemy!") end
				TargetClosestEnemy()
				yield("/vnav stop")
			end
		end
	end
	--if GetCharacterCondition(34) == false then --fix autoqueue just shitting out
		--yield("/send U")
	--end
	
	if GetCharacterCondition(34) == true and GetCharacterCondition(26) == false then
		yield("/equiprecommended")
		--TargetClosestEnemy()
		yield("/ac \"Fester\"")
	end
	
	if GetCharacterCondition(4) == false and GetCharacterCondition(26) == true then
		if type(GetTargetName()) ~= "string" then
			TargetClosestEnemy()
			yield("/vnav stop")
			yield("/ad pause")
			yield("/wait 0.5")
			jigglecounter = 0 -- we reset the jiggle counter while we are in combat. combat is good means we are doing something productive
			if echo_level < 1 then yield("/echo stopping vnav for combat") end
			if echo_level < 1 then yield("/echo pausing AD for combat") end
			yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos())
			yield("/wait 5")
			yield("/vnav stop")
			yield("/wait 0.5")
			yield("/ad resume")
			if echo_level < 1 then yield("/echo resuming AD") end
		end
	end
	
	if GetCharacterCondition(34) == true then
		x1 = GetPlayerRawXPos()
		y1 = GetPlayerRawYPos()
		z1 = GetPlayerRawZPos()
	end
    yield("/wait 0.5")

	stopcuckingme = stopcuckingme + 1
	--autoqueue at the end because its least important thing
	if not (GetZoneID() == 1044 or GetZoneID() == 1048) then
		entered_duty = 0
	end
	if (GetZoneID() == 1044 or GetZoneID() == 1048) and entered_duty == 0 then
		entered_duty = 1
		duty_counter = duty_counter + 1
		if echo_level < 4 then yield("/echo This is duty # -> "..duty_counter) end
	end
	if os.date("!*t").hour > 8 and os.date("!*t").hour < 10 and duty_counter > 20 then --theres no way we can do 20 prae in 1 hour so this should cover rollover from the previous day
		duty_counter = 1
		if echo_level < 4 then yield("/echo We are starting over the duty counter, we passed daily reset time!") end
	end--]]
	if stopcuckingme > 2 and GetCharacterCondition(34) == false and imthecaptainnow == 1 then
		yield("/finder")
		yield("/wait 0.5")
		whoops = 0
		boops = 0
		did_we_clear_it = 0
        while not IsAddonVisible("ContentsFinder") and whoops == 0 do
            yield("/waitaddon ContentsFinder")
            yield("/wait 1")
			boops = boops + 1
			if boops > 15 then whoops = 1 end
		end -- safety check before callback
		if IsAddonVisible("ContentsFinder") then did_we_clear_it = 1 end
        yield("/wait 1")
		yield("/callback ContentsFinder true 12 1")
		yield("/send ESCAPE")
		--[[
		--first we must unselect the duty that is selected. juuust in case
		if GetNodeText("ContentsFinder", 14) == "The Praetorium" then
			yield("/callback ContentsFinder true 3 15")
		end
		if GetNodeText("ContentsFinder", 14) == "Porta Decumana" then
			yield("/callback ContentsFinder true 3 4")
		end
		--]]
		if echo_level < 2 then yield("/echo attempting to trigger duty finder") end
	    --yield("/callback ContentsFinder true 12 1")
		if did_we_clear_it == 1 then  --we need to make sure we cleared CF before we try to queue for something.
		whoops = 0
		boops = 0
			if duty_counter < 99 then
				--OpenRegularDuty(1044) --Praetorium	
				if echo_level < 3 then yield("/echo Trying to start Praetorium") end
				while not IsAddonVisible("ContentsFinder") and whoops == 0 do
					OpenRegularDuty(16) --Praetorium	
					yield("/waitaddon ContentsFinder")
					yield("/wait 1")
					boops = boops + 1
					if boops > 15 then whoops = 1 end
				end -- safety check before callback
				yield("/wait 3")
				yield("/callback ContentsFinder true 3 15")
			end
			if duty_counter > 98 then
				if echo_level < 3 then yield("/echo Trying to start Porta") end
				while not IsAddonVisible("ContentsFinder") and whoops == 0 do
					OpenRegularDuty(830) --Decumana
					yield("/waitaddon ContentsFinder")
					yield("/wait 1")
					boops = boops + 1
					if boops > 15 then whoops = 1 end
				end -- safety check before callback
				yield("/wait 3")
				--OpenRegularDuty(1048) --Decumana
				yield("/callback ContentsFinder true 3 4")
			end
			yield("/callback ContentsFinder true 12 0")
			stopcuckingme = 0
		end
	end
	

--safe check ends
end
end
---
end