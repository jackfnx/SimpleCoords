local HEARTBEAT_INTERVAL = 0.5; -- how many seconds per heartbeat of our internal timer
Simple_Coords_SecondsSinceUpdate=0; -- globalish tick counter
Simple_Coords_Map_SecondsSinceUpdate=0; -- globalish tick counter


local minimapIcon;
local worldTarget;
local panelOpen = false;
local haveArrived=false;
local dest_x = -1000;
local dest_y = -1000;
local showWorldMapIcon = true;
local zone_dirty = true;

-- Constants:
local MINIMAP_ICON_NAME = "SimpleCoords";
local WORLDMAP_ICON_NAME = "SimpleCoordsW";

local HALF_PI = math.pi / 2;
local ROOT_HALF = math.sqrt(0.5)
-- Bring in HereBeDragons
local hbd = LibStub("HereBeDragons-2.0")
local pins = LibStub("HereBeDragons-Pins-2.0")

--

function SimpleCoords_OnLoad()
	-- create the dot: (encapsulated as an obbject in case we want to reuse it
	-- minimapIcon=CreateFrame("Button", nil, Minimap)
	minimapIcon=CreateFrame("Button", "SimpleCoordsDotFrame", Minimap)
	minimapIcon:SetHeight(12)
	minimapIcon:SetWidth(12)
	local texture = minimapIcon:CreateTexture()
	texture:SetTexture("Interface\\AddOns\\SimpleCoords\\images\\redbull")
	texture:SetAllPoints()
	minimapIcon.dot = texture
	--minimapIcon.dot:Hide() -- start  hidden
	--minimapIcon.dot:Show();
	minimapIcon:SetScript("OnUpdate", SimpleCoords_MapIcon_Update)

	if (showWorldMapIcon) then
		worldTarget=CreateFrame("Button", "SimpleCoordsWorldTargetFrame",WorldMapDetailFrame )-- WorldMapDetailFrame
		worldTarget:SetWidth(16)
		worldTarget:SetHeight(16)

		worldTarget.icon = worldTarget:CreateTexture("ARTWORK")
		worldTarget.icon:SetAllPoints()
		worldTarget.icon:SetTexture("Interface\\AddOns\\SimpleCoords\\images\\redbull")

	end
	-- create the arrow:
    minimapIcon.arrow = minimapIcon:CreateTexture("BACKGROUND")
   -- minimapIcon.arrow:SetTexture("Interface\\AddOns\\SimpleCoords\\images\\mmarrow")
    minimapIcon.arrow:SetTexture("Interface\\Minimap\\Minimap-QuestArrow")
    minimapIcon.arrow:SetPoint("CENTER", 0 ,0)
    minimapIcon.arrow:SetHeight(40) -- 32?
    minimapIcon.arrow:SetWidth(40)
    minimapIcon.arrow:Hide()

	-- Register the slash command
	SLASH_SIMPLECOORDS1 = "/dest";
	SlashCmdList["SIMPLECOORDS"] = SimpleCoords_CommandLine;
	-- make a global for testing:
	--SimpleCoordsMapIcon=minimapIcon;

DEFAULT_CHAT_FRAME:AddMessage("SimpleCoords loaded. Shift-drag to move the window. Click window to toggle panel. ENTER to set new value.",  0.5, 1.0, 0.5, 1);

end






-- ----------------------------------
function Simple_Coords_OnUpdate(self, elapsed)
--
-- Updates the coordinate display
--
-- Uses HEARTBEAT_INTERVAL to limit how often the display is updated
-- params:
-- self
-- elapsed incrementing timer (second resolution)
--
-- globals:
-- zone_dirty bool need to refresh location information (after a login or zone change)
--

	Simple_Coords_SecondsSinceUpdate = Simple_Coords_SecondsSinceUpdate + elapsed;
	if (Simple_Coords_SecondsSinceUpdate > HEARTBEAT_INTERVAL) then
	  if (zone_dirty) then -- right now, this only happens the first time. This test may no longer be needed.
	    -- SetMapToCurrentZone();
	    zone_dirty = false;
	  end
		-- local x, y = hbd:GetPlayerWorldPosition();
		local x, y, UiMapID, UiMapType = hbd:GetPlayerZonePosition();

		-- if x and y and x > 0 and y > 0 then
		if x and y and x > 0 and y > 0 then
      Simple_CoordsText:SetText(format( "%.1f, %.1f", x * 100, y * 100));
		else
			Simple_CoordsText:SetText("---");
			minimapIcon.dot:Hide();
		end
		Simple_Coords_SecondsSinceUpdate=0;
	end -- if
end








-- ----------------------------------
function SimpleCoords_AcceptValue()
--
-- Called when ENTERing new values in the coordinate window
-- Reads the values in SimpleCoords_X and SimpleCoords_Y text input frames (Still defined in the XML)
-- This function is attached to the OnEnterPressed handlers for those frames.

    -- clear any existing icon(s), since we have new coords:
    SimpleCoordsRemoveIcons()

  if (getglobal("SimpleCoords_X"):GetText() == "" and getglobal("SimpleCoords_Y"):GetText() == "") then
    SimpleCoords_TogglePanel();
  else
    getglobal("SimpleCoords_X"):ClearFocus();
    getglobal("SimpleCoords_Y"):ClearFocus();
    if (getglobal("SimpleCoords_X"):GetText() == "" or getglobal("SimpleCoords_Y"):GetText() == "") then
    -- only one field filled in
    else
      PlaySoundFile(567574);
      -- PlaySoundFile("Sound\\interface\\PickUp\\PutDownGems.wav");
      local x_text, y_text;
      x_text = getglobal("SimpleCoords_X"):GetText();
      y_text = getglobal("SimpleCoords_Y"):GetText();
      y_text = gsub(y_text, ",", "."); -- swap commas for decimals for those European types
      y_text = gsub(y_text, "[%a%c%-%(%)]", ""); -- %a: letters. %c: control characters %-: -
      x_text = gsub(x_text, ",", ".");
      x_text = gsub(x_text, "[%a%c%-%(%)]", ""); -- %a: letters. %c: control characters %-: -
      dest_x=tonumber(x_text)/100.0; -- revert scale back to 0 - 1.0
      dest_y=tonumber(y_text)/100.0;

      -- add the dots to the map(s)
      -- minimap
      local playerZoneX, playerZoneY, uiMapID = SimpleCoords_GetPlayerZoneCoords();

      AddMinimapIcon(minimapIcon, dest_x, dest_y, uiMapID ) --icon, x, y, uiMapID

      -- add world map
      -- DEFAULT_CHAT_FRAME:AddMessage("mapID: " .. mapID ,  0.8, 1.0, 0.5, 1);
      AddWorldMapIcon(worldTarget, uiMapID, dest_x, dest_y);
      haveArrived=false;

    end

  end
end





-- ----------------------------------
function SimpleCoords_TogglePanel()
--
-- Open or close the coordinate window depending on current state
-- With accompanying sound
--
	if(getglobal("SimpleCoords_X"):IsShown()) then
	  PlaySoundFile(567515);
		-- PlaySoundFile("Sound\\interface\\uMiniMapClose.wav");

		getglobal("SimpleCoords_X"):Hide();
		getglobal("SimpleCoords_Y"):Hide();
		getglobal("SimpleCoords_X"):ClearFocus();
		getglobal("SimpleCoords_Y"):ClearFocus();
    SimpleCoordsRemoveIcons()
		panelOpen=false;

	else
		PlaySoundFile(567529); -- ("Sound\\interface\\uMiniMapOpen.wav");

		getglobal("SimpleCoords_X"):Show();
		getglobal("SimpleCoords_Y"):Show();
		getglobal("SimpleCoords_X"):SetFocus();
		panelOpen=true;
	end

end





function SimpleCoords_MapIcon_Update(self, elapsed)
--
-- Updates the minimap icon
--
-- Uses HEARTBEAT_INTERVAL to limit how often the display is updated
-- params:
-- self
-- elapsed incrementing timer (second resolution)
--

  Simple_Coords_Map_SecondsSinceUpdate = Simple_Coords_Map_SecondsSinceUpdate + elapsed;

	if (Simple_Coords_Map_SecondsSinceUpdate > HEARTBEAT_INTERVAL) then
	  if haveArrived ~= true then
	  -- if the panel is open, but we "have arrived" don't bother to update hidden things

    local on_edge = IsMinimapIconOnEdge(minimapIcon)  --	local edge = Astrolabe:IsIconOnEdge(self)
    local showing_dot = self.dot:IsShown()
    local showing_arrow = self.arrow:IsShown()

    if on_edge then
     -- DEFAULT_CHAT_FRAME:AddMessage("EDGE",  0.8, 1.0, 0.5, 1);
    else
     -- DEFAULT_CHAT_FRAME:AddMessage("UPDATE",  0.8, 1.0, 0.5, 1);
    end

      if (on_edge and not showing_arrow) then
        self.arrow:Show()
        self.dot:Hide()
        -- DEFAULT_CHAT_FRAME:AddMessage("TO ARROW",  0.8, 1.0, 0.5, 1);
      elseif not on_edge and not showing_dot then
        self.dot:Show()
        self.arrow:Hide()
        -- DEFAULT_CHAT_FRAME:AddMessage("TO DOT",  0.8, 1.0, 0.5, 1);
      end


   local angle,distance = pins:GetVectorToIcon(minimapIcon) --	local angle = Astrolabe:GetDirectionToIcon(minimapIcon)
   if (distance ~= nil) then
    if (distance < 10) then
      if (not haveArrived) then
        DEFAULT_CHAT_FRAME:AddMessage("You have arrived.",  0.8, 1.0, 0.5, 1); -- let them now they have arrived
        -- remove the icons
        SimpleCoordsRemoveIcons()
        haveArrived = true
        event_complete = false
      end -- haveArrived
    end -- distance < 10)
   end


      if showing_arrow then
        if (angle ~= nil) then
        angle = angle + math.rad(135) -- math.rad converts degrees to radians 45 past 90 in this case
        -- if they have the rotating minimap enabled, we have to adjust our angle:
          if GetCVar("rotateMinimap") == "1" then
                local minimap_rot = GetPlayerFacing()
                angle = angle - minimap_rot
            end

          local sin,cos = math.sin(angle) * ROOT_HALF, math.cos(angle) * ROOT_HALF
          self.arrow:SetTexCoord(0.5-sin, 0.5+cos, 0.5+cos, 0.5+sin, 0.5-cos, 0.5-sin, 0.5+sin, 0.5-cos)

        else
          self:Hide() -- an error getting the angle to the icon. so just hide it?
        end
      end -- showing_arrow
    end  -- haveArrived
    Simple_Coords_Map_SecondsSinceUpdate = 0;
	end
end









-- Tooltips:
--------------

function SimpleCoords_ShowTooltip()
	local tooltipList ={};
	GameTooltip:SetOwner(getglobal("SimpleCoordsFrame") , "ANCHOR_CURSOR", -5, 5);
	-- GameTooltip:SetOwner(owner, "anchor"[, +x, +y]);
	--GameTooltip:AddLine("test", .6,1.0,.8); -- GameTooltip:AddLine(name, GameTooltip_UnitColor("player"));\
	GameTooltip:AddLine('SimpleCoords',.6,1.0,.8);
	GameTooltip:AddLine('Click to enter coordinates.');
	GameTooltip:AddLine('Shift-click to move.');
	GameTooltip:AddLine('ENTER to place dot at coordinates.');
	GameTooltip:Show();
end






function SimpleCoords_HideTooltip()
	GameTooltip:Hide();
end





function SimpleCoordsEnter_ShowTooltip()
	local tooltipList ={};
	GameTooltip:SetOwner(getglobal("SimpleCoordsFrame") , "ANCHOR_CURSOR", -5, 5);
	-- GameTooltip:SetOwner(owner, "anchor"[, +x, +y]);
	--GameTooltip:AddLine("test", .6,1.0,.8); -- GameTooltip:AddLine(name, GameTooltip_UnitColor("player"));\
	GameTooltip:AddLine('SimpleCoords',.6,1.0,.8);
	GameTooltip:AddLine('TAB to switch fields.');
	GameTooltip:AddLine('Click current coordinates to close edit.');
	GameTooltip:AddLine('ENTER to place dot at coordinates.');
	GameTooltip:Show();
end




-- command line parameters: (slash command handler)
----------------------------------------------------
function SimpleCoords_CommandLine(msg)
	cmd=string.lower(msg);
end


-- Move this glue to a separate file?
function SimpleCoords_GetPlayerZoneCoords()
    local x, y, UiMapID, UiMapType = hbd:GetPlayerZonePosition();
    return  x, y, UiMapID, UiMapType;
end


function AddMinimapIcon(icon, x, y, uiMapID)
  pins:AddMinimapIconMap(MINIMAP_ICON_NAME, icon, uiMapID, x, y, true, true) -- showInParentZone, floatOnEdge
end

function AddWorldMapIcon(icon, uiMapID, x, y)
  pins:AddWorldMapIconMap(WORLDMAP_ICON_NAME, icon, uiMapID, x, y, HBD_PINS_WORLDMAP_SHOW_PARENT); -- ref, icon, uiMapID, x, y, showFlag)
end


function SimpleCoordsRemoveIcons()
  -- Remove both the minimap and worldmap icons
  RemoveMinimapIcon(minimapIcon)
  RemoveWorldMapIcon(worldTarget)
end

function RemoveWorldMapIcon(icon)
  pins:RemoveWorldMapIcon(WORLDMAP_ICON_NAME, icon)
end


function RemoveMinimapIcon(icon)
  pins:RemoveMinimapIcon(MINIMAP_ICON_NAME, icon)
end

function IsMinimapIconOnEdge(icon)
  local t = pins:IsMinimapIconOnEdge(icon)
  return t;
end

function GetVectorToIcon(icon)
  -- return anggle and distance
  local angle, distance = pins:GetVectorToIcon(icon);
  return angle, distance;
end
