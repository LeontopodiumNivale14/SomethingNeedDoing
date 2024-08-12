--[[
After AR Done Manager
What does it do?

configure AR to run a script after AR is done and it have it run THIS script.
This script will, aftre AR is done, do various things based on a set of rules you will configure in a separate file (AADMconfig_McVaxius.lua)

It could be ocean fishing, triple triad, inventory cleaning, going for a jog around the housing ward, delivering something to specific person, crafting. or whatever!

Requirements : SND
and maybe more - let's see where we go with it

{"Firstname Lastname@Server", 0},

order of configs
from first ?, to last starting cardinality of 1

1 = full char name with @server, it is case sensitive and spelling sensitive please have a spreadsheet for this stuff folks
2 = return location for any operations that require teleporting and returning. standard locations from robust turnin apply. 0 = fc, 1 = near fc but bell, etc ill document later --*
3 = chance to clean inventory (check _functions.lua for details) - don't ask about this in the punish disc i wont respond and at best ill just block you. you can ask in liza disc if you want
4 = number of minutes of TT to run from 0 to whatever
5 = TT location to run, 1=arena roe, 2=manservant
6 = magitek repair kits to print (it will require you to have a npc in your house with g6dm vendor available. preferrably easily pathable from entrance)
7 = fuel restock safety stock - amount of fuel where we buy some more fuel to refill the coffers. it will check inventory slots free etc to make sure you can do it. maybe output to an "empire log" file if there is an issue
8 = fuel restock refuel amount - how much actual fuel to buy up to 
9 = cuff a curr bonkings expressed in a amount of MGP to acquire each time from 0 to whatever
10 = FC buff 1 to refresh if its down
11 = FC buff 2 to refresh if its down
12 = fisher level. if its >0 and <100 (for now unless level cap changes) it will assume you want this char to go ocean fishing.  it will iterate through the list at certain time of day and do ocean fishing on the lowest level char, and it will also update the table and output it
--]]


--some actual vars
force_fishing = 0 --set to 1 if you want the default indexed char to fish whenever possible
gc_cleaning_safetystock = 50 -- how many inventory units before we do a cleaning

loadfiyel = os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\_functions.lua"
functionsToLoad = loadfile(loadfiyel)
AADM_processors = {
{"Firstname Lastname@Server", 0, 10, 2, 60, 20, 666, 6666, 50, "Helping Hand II", "Make it Rain II", 100},   --your main char for example, 1 hour of manservant every refresh, 15 magitek repair kits every refresh, restock fuel to 6666 at 666 fuel remaining.
{"Firstname Lastname@Server", 0, 10, 0,  0,  0,   0,    0,  0,         "nothing",         "nothing", 92},
{"Firstname Lastname@Server", 0, 10, 0,  0,  0,   0,    0,  0,         "nothing",         "nothing", 92},
{"Firstname Lastname@Server", 0, 10, 0,  0,  0,   0,    0,  0,         "nothing",         "nothing", 92},
{"Firstname Lastname@Server", 0, 10, 0,  0,  0,   0,    0,  0,         "nothing",         "nothing", 32},    --this char will be picked next for ocean fishing
{"Firstname Lastname@Server", 0, 10, 0,  0,  0,   0,    0,  0,         "nothing",         "nothing", 92},
{"Firstname Lastname@Server", 0, 10, 0,  0,  0,   0,    0,  0,         "nothing",         "nothing", 92},
{"Firstname Lastname@Server", 0, 10, 0,  0,  0,   0,    0,  0,         "nothing",         "nothing", 92},
{"Firstname Lastname@Server", 0, 10, 0,  0,  0,   0,    0,  0,         "nothing",         "nothing", 92},
{"Firstname Lastname@Server", 0, 10, 0,  0,  0,   0,    0,  0,         "nothing",         "nothing", 92},
{"Firstname Lastname@Server", 0, 10, 0,  0,  0,   0,    0,  0,         "nothing",         "nothing", 92}
}
loadfiyel2 = os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\AADMconfig_McVaxius.lua"
functionsToLoad = loadfile(loadfiyel2)

function getRandomNumber(min, max)
  return math.random(min,max)
end

ungabungabunga()  --get out of anything safely.

hoo_arr_weeeeee = 1 -- who are we

for i=1,#AADM_processors do
	if GetCharacterName(true) == AADM_processors[i][1] then
		hoo_arr_weeeeee = i
	end
end

--begin to do stuff
------------------------------------

--fishing - always check first since it takes some time sometimes to get it going
--dont do anything else if we are fishing. just return home and resume AR after
--secret variable
wheeequeheeheheheheheehhhee = 0
--The next 2 lines of code copied from https://raw.githubusercontent.com/plottingCreeper/FFXIV-scripts-and-macros/main/SND/FishingRaid.lua
--line 319 to line 320
--thanks botting creeper!
if os.date("!*t").hour%2==0 and os.date("!*t").min<15 then
  if os.date("!*t").min>=1 then
	wheeequeheeheheheheheehhhee = 1
  end
end

--determine who is the lowest level fisher of them all.
--set this to the cardinality you want to force fishing on if thats what you want to do.
lowestID = 1
for i=1,#AADM_processors do
	if AADM_processors[i][12] > 0 and AADM_processors[i][12] < AADM_processors[lowestID][12] then
		lowestID = i
	end
end

--if the lowest guy is max level we aren't fishing yo
if AADM_processors[lowestID] == 100 and force_fishing == 0 then
	wheeequeheeheheheheheehhhee = 0
	yield("/echo Lowest char is max level so we arent fishing")
end

--its fishinging time
if wheeequeheeheheheheheehhhee == 1 then
	if GetCharacterCondition(31)==false then
		if GetCharacterCondition(32)==false then
		 	 ungabungabunga() -- we really really try hard to be safe here
			 
			 --*load fishing functions
			 
			 yield("/waitaddon _ActionBar <maxwait.600><wait.2>")
			 fishing()
			 --drop a log file entry on the charname + Level
			-- Open a file in write mode within the specified folder
			local file = io.open(folderPath .. "FeeshLevels.txt", "a")

			if file then
				-- Write text to the file
				currentTime = os.date("*t")
				formattedTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", currentTime.year, currentTime.month, currentTime.day, currentTime.hour, currentTime.min, currentTime.sec)
				file:write(formattedTime.." - ".."["..lowestID.."] - "..feesh_char.." - Fisher Lv - "..GetLevel().."\n")
				-- Close the file handle
				file:close()
				yield("/echo Text has been written to '" .. folderPath .. "FeeshLevels.txt'")
			else
				yield("/echo Error: Unable to open file for writing")
			end
		end
	end
end

if wheeequeheeheheheheheehhhee == 0 then
-----start of processing things when there is no fishing
	--inventory cleaning
	if AADM_processors[hoo_arr_weeeeee][3] > 0 then
		if getRandomNumber(0,99) < AADM_processors[hoo_arr_weeeeee][3] then
			clean_inventory()
			ungabungabunga()
			--*if [3] was 100, we set it back down to 10 becuase 100 means a onetime guaranteed cleaning. sometimes we want to do this for whatever reason.
		end
	end
	--* if inventory < whatever then we do gc cleaning
		--*gc cleaning if inventory is under ?? units free even after the "cleaning"

-----end of processing things when there is no fishing
end
------------------------------------
--stop beginning to do stuff
	ungabungabunga()
end

