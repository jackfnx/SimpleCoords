
-- Globals:
-- ========
-- our big global object:
SCoordsAddon = {
	addon_loaded = false,
	seconds_since_update = 0, -- tick counter
	seconds_since_map_update = 0, -- tick counter

	minimapIcon,
	worldTarget,
	panelOpen = false,
	haveArrived=false,
	dest_x = -1000,
	dest_y = -1000,
	zone_dirty = true,

	-- Constants:
	mini_ref = "SimpleCoords",
	world_ref = "SimpleCoordsW",

	HALF_PI = math.pi / 2,
	ROOT_HALF = math.sqrt(0.5),
	HEARTBEAT_INTERVAL = 0.5; -- how many seconds per heartbeat of our internal timer


}

-- Here Be Dragons stuff:
SCoordsAddon.hbd = LibStub("HereBeDragons-2.0")
SCoordsAddon.pins = LibStub("HereBeDragons-Pins-2.0")

DEFAULT_CHAT_FRAME:AddMessage("HereBeDragons loaded",  0.5, 1.0, 0.5, 1); -- leave for testing

-- boot frame:
local boot_frame = CreateFrame("Frame")
boot_frame:RegisterEvent("ADDON_LOADED")
boot_frame:SetScript(
  "OnEvent", function(frame,event, addon, ...)
		if frame == boot_frame then
	    SCoordsAddon.init(event, addon);
		end
  end
);



---
-- Open or close the coordinate window depending on current state
-- With accompanying sound
--
function SCoordsAddon.TogglePanel()
	if(_G["SimpleCoords_X"]:IsShown()) then
	  PlaySoundFile(567515);
		-- PlaySoundFile("Sound\\interface\\uMiniMapClose.wav");

		_G["SimpleCoords_X"]:Hide();
		_G["SimpleCoords_Y"]:Hide();
		_G["SimpleCoords_X"]:ClearFocus();
		_G["SimpleCoords_Y"]:ClearFocus();
    SCoordsAddon.RemoveIcons()
		panelOpen=false;

	else
		PlaySoundFile(567529); -- ("Sound\\interface\\uMiniMapOpen.wav");

		_G["SimpleCoords_X"]:Show();
		_G["SimpleCoords_Y"]:Show();
		_G["SimpleCoords_X"]:SetFocus();
		panelOpen=true;
	end

end





function SCoordsAddon.AcceptValue()
--
-- Called when ENTERing new values in the coordinate window
-- Reads the values in SimpleCoords_X and SimpleCoords_Y text input frames (Still defined in the XML)
-- This function is attached to the OnEnterPressed handlers for those frames.

    -- clear any existing icon(s), since we have new coords:
    SCoordsAddon.RemoveIcons()

  if (_G["SimpleCoords_X"]:GetText() == "" and _G["SimpleCoords_Y"]:GetText() == "") then
    SCoordsAddon.TogglePanel();
  else
    _G["SimpleCoords_X"]:ClearFocus();
    _G["SimpleCoords_Y"]:ClearFocus();
    if (_G["SimpleCoords_X"]:GetText() == "" or _G["SimpleCoords_Y"]:GetText() == "") then
    -- only one field filled in
    else
      PlaySoundFile(567574);
      -- PlaySoundFile("Sound\\interface\\PickUp\\PutDownGems.wav");
      local x_text, y_text;
      x_text = _G["SimpleCoords_X"]:GetText();
      y_text = _G["SimpleCoords_Y"]:GetText();
      y_text = gsub(y_text, ",", "."); -- swap commas for decimals for those European types
      y_text = gsub(y_text, "[%a%c%-%(%)]", ""); -- %a: letters. %c: control characters %-: -
      x_text = gsub(x_text, ",", ".");
      x_text = gsub(x_text, "[%a%c%-%(%)]", ""); -- %a: letters. %c: control characters %-: -
      dest_x=tonumber(x_text)/100.0; -- revert scale back to 0 - 1.0
      dest_y=tonumber(y_text)/100.0;

      -- add the dots to the map(s)
      -- minimap
      local playerZoneX, playerZoneY, uiMapID = SimpleCoords_GetPlayerZoneCoords();

      SCoordsAddon.AddMinimapIcon(SCoordsAddon.minimapIcon, dest_x, dest_y, uiMapID ) --icon, x, y, uiMapID

      -- add world map
      -- DEFAULT_CHAT_FRAME:AddMessage("mapID: " .. mapID ,  0.8, 1.0, 0.5, 1);
      SCoordsAddon.AddWorldMapIcon(SCoordsAddon.worldTarget, uiMapID, dest_x, dest_y);
      haveArrived=false;

    end

  end
end




---
-- Updates the minimap icon
--
-- Uses HEARTBEAT_INTERVAL to limit how often the display is updated
-- @tab  self (Frame)
-- @number elapsed incrementing timer (second resolution)
--
function SimpleCoords_MapIcon_Update(self, elapsed)
--	DEFAULT_CHAT_FRAME:AddMessage("elapsed" .. elapsed .. "  " .. SCoordsAddon.seconds_since_map_update ,  0.8, 1.0, 0.5, 1);

  SCoordsAddon.seconds_since_map_update = SCoordsAddon.seconds_since_map_update + elapsed;

	if (SCoordsAddon.seconds_since_map_update > SCoordsAddon.HEARTBEAT_INTERVAL) then
	  if haveArrived ~= true then
	  -- if the panel is open, but we "have arrived" don't bother to update hidden things

    local on_edge = SCoordsAddon.IsMinimapIconOnEdge(minimapIcon)  --	local edge = Astrolabe:IsIconOnEdge(self)
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


   local angle,distance = SCoordsAddon.pins:GetVectorToIcon(minimapIcon) --	local angle = Astrolabe:GetDirectionToIcon(minimapIcon)
   if (distance ~= nil) then
    if (distance < 10) then
      if (not haveArrived) then
        DEFAULT_CHAT_FRAME:AddMessage("You have arrived.",  0.8, 1.0, 0.5, 1); -- let them now they have arrived
        -- remove the icons
        SCoordsAddon.RemoveIcons();
        haveArrived = true;
        event_complete = false;
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
    SCoordsAddon.seconds_since_map_update = 0;
	end
end









-- Tooltips:
--------------

function SCoordsAddon.ShowTooltip()
	local tooltipList ={};
	GameTooltip:SetOwner(_G["SimpleCoordsFrame"] , "ANCHOR_CURSOR", -5, 5);
	-- GameTooltip:SetOwner(owner, "anchor"[, +x, +y]);
	--GameTooltip:AddLine("test", .6,1.0,.8); -- GameTooltip:AddLine(name, GameTooltip_UnitColor("player"));\
	GameTooltip:AddLine('SimpleCoords',.6,1.0,.8);
	GameTooltip:AddLine('Click to enter coordinates.');
	GameTooltip:AddLine('Shift-click to move.');
	GameTooltip:AddLine('ENTER to place dot at coordinates.');
	GameTooltip:Show();
end






function SCoordsAddon.HideTooltip()
	GameTooltip:Hide();
end









-- command line parameters: (slash command handler)
----------------------------------------------------
function SimpleCoords_CommandLine(msg)
	cmd=string.lower(msg);
end


-- Move this glue to a separate file?
function SimpleCoords_GetPlayerZoneCoords()
    local x, y, UiMapID, UiMapType = SCoordsAddon.hbd:GetPlayerZonePosition();
    return  x, y, UiMapID, UiMapType;
end


function SCoordsAddon.AddMinimapIcon(icon, x, y, uiMapID)
  SCoordsAddon.pins:AddMinimapIconMap(SCoordsAddon.mini_ref, icon, uiMapID, x, y, true, true) -- showInParentZone, floatOnEdge
end

function SCoordsAddon.AddWorldMapIcon(icon, uiMapID, x, y)
  SCoordsAddon.pins:AddWorldMapIconMap(SCoordsAddon.world_ref, icon, uiMapID, x, y, HBD_PINS_WORLDMAP_SHOW_PARENT); -- ref, icon, uiMapID, x, y, showFlag)
end


function SCoordsAddon.RemoveIcons()
  -- Remove both the minimap and worldmap icons
	-- maybe just hide?
  SCoordsAddon.RemoveMinimapIcon(SCoordsAddon.minimapIcon)
  SCoordsAddon.RemoveWorldMapIcon(SCoordsAddon.worldTarget)
end

function SCoordsAddon.RemoveWorldMapIcon(icon)
  SCoordsAddon.pins:RemoveWorldMapIcon(SCoordsAddon.WORLDMAP_ICON_NAME, icon)
end


function SCoordsAddon.RemoveMinimapIcon(icon)
  SCoordsAddon.pins:RemoveMinimapIcon(SCoordsAddon.MINIMAP_ICON_NAME, icon)
end

function SCoordsAddon.IsMinimapIconOnEdge(icon)
  local t = SCoordsAddon.pins:IsMinimapIconOnEdge(icon)
  return t;
end

function SCoordsAddon.GetVectorToIcon(icon)
  -- return anggle and distance
  local angle, distance = SCoordsAddon.pins:GetVectorToIcon(icon);
  return angle, distance;
end



---
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
function SCoordsAddon.OnUpdate(self, elapsed)

--DEFAULT_CHAT_FRAME:AddMessage("elapsed" .. elapsed .. "  " .. SCoordsAddon.seconds_since_map_update ,  0.8, 1.0, 0.5, 1);

	SCoordsAddon.seconds_since_update = SCoordsAddon.seconds_since_update + elapsed;
	if (SCoordsAddon.seconds_since_update > SCoordsAddon.HEARTBEAT_INTERVAL) then
	  if (zone_dirty) then -- right now, this only happens the first time. This test may no longer be needed.
	    -- SetMapToCurrentZone();
	    zone_dirty = false;
	  end
		-- local x, y = hbd:GetPlayerWorldPosition();
		local x, y, UiMapID, UiMapType = SCoordsAddon.hbd:GetPlayerZonePosition();

		-- if x and y and x > 0 and y > 0 then
		if x and y and x > 0 and y > 0 then
      Simple_CoordsText:SetText(format( "%.1f, %.1f", x * 100, y * 100));
		else
			Simple_CoordsText:SetText("---");
			minimapIcon.dot:Hide();
		end
		SCoordsAddon.seconds_since_update=0;
	end -- if
end




--- Once the addon is loaded, register all our events and create our frames
--
function SCoordsAddon.init(event, addon)
	if event == "ADDON_LOADED" and addon == "SimpleCoords" then
		DEFAULT_CHAT_FRAME:AddMessage("HELLLLLO",  0.5, 1.0, 0.5, 1); -- leave for testing

		if ( false == SCoordsAddon.addon_loaded ) then -- only need to load once
			SCoordsAddon.addon_loaded = true;

			local f = _G["SimpleCoordsFrame"];
			f:HookScript("OnUpdate", SCoordsAddon.OnUpdate);


				-- create the dot: (encapsulated as an obbject in case we want to reuse it
				-- minimapIcon=CreateFrame("Button", nil, Minimap)
				local mini = CreateFrame("Button", "SimpleCoordsDotFrame", Minimap);

				mini:SetHeight(12);
				mini:SetWidth(12);
				local texture = mini:CreateTexture();
				texture:SetTexture("Interface\\AddOns\\SimpleCoords\\images\\redbull");
				texture:SetAllPoints();
				mini.dot = texture;
				--minimapIcon.dot:Hide() -- start  hidden
				--minimapIcon.dot:Show();
				mini:SetScript("OnUpdate", SimpleCoords_MapIcon_Update)


			-- create the arrow:
				mini.arrow = mini:CreateTexture("BACKGROUND")
			 -- minimapIcon.arrow:SetTexture("Interface\\AddOns\\SimpleCoords\\images\\mmarrow")
				mini.arrow:SetTexture("Interface\\Minimap\\Minimap-QuestArrow")
				mini.arrow:SetPoint("CENTER", 0 ,0)
				mini.arrow:SetHeight(40) -- 32?
				mini.arrow:SetWidth(40)
				mini.arrow:Hide()
				SCoordsAddon.minimapIcon = mini;

					local world_dot = CreateFrame("Button", "SimpleCoordsWorldTargetFrame",WorldMapDetailFrame );

					world_dot:SetWidth(16)
					world_dot:SetHeight(16)
					world_dot.icon = world_dot:CreateTexture("ARTWORK")
					world_dot.icon:SetAllPoints()
					world_dot.icon:SetTexture("Interface\\AddOns\\SimpleCoords\\images\\redbull")
					SCoordsAddon.worldTarget= world_dot;


			-- Register all our events:
			SCoordsAddon.eventframe = CreateFrame("Frame" ); -- the frame to listen to all our events
			local ev = SCoordsAddon.eventframe; -- local shortcut

			-- and register our basic events:
			ev:RegisterEvent("PLAYER_ENTERING_WORLD");
			ev:RegisterEvent("CHAT_MSG_CHANNEL");
		--	ev:RegisterEvent("VARIABLES_LOADED");
		--	ev:RegisterEvent("UPDATE_BINDINGS");
		--	ev:RegisterEvent("PLAYER_LEAVE_COMBAT");
		--	ev:RegisterEvent("PLAYER_REGEN_ENABLED");

			-- self:RegisterEvent("CHAT_MSG_TEXT_EMOTE"); -- for listening
			ev:SetScript("OnEvent", SCoordsAddon.HandleEvent);

		end --SCoordsAddon.addon_loaded
	end -- ADDON_LOADED
end


--- Main WoW Event handler
 function SassAddon.HandleEvent(frame, event, ...)
--	DEFAULT_CHAT_FRAME:AddMessage('event ' .. event,  0.5, 1.0, 0.5, 1);
	local eventHandled = false;


-- VARIABLES_LOADED
-- ================

	if ( event == "VARIABLES_LOADED" ) then -- sounds like variables_loaded events should be ADDON_LOADED
		eventHandled = true; -- record that we have been loaded:
	end -- ( event == "VARIABLES_LOADED" )


--	if (eventHandled == false and ((event == "PLAYER_LEAVE_COMBAT") or (event == "PLAYER_REGEN_ENABLED"))) then


-- event handled?


	if (eventHandled == false) then
		-- msgText = string.lower(arg1);
	end




end -- end of function
