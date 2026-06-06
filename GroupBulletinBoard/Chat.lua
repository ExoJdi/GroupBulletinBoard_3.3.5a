local _, GBB = GroupBulletinBoard_Loader.Main()
if not GBB then
  GBB = GroupBulletinBoard_Addon or {}
end

function GBB.SendMessage(ChannelName, Msg)
  local index = GetChannelName(ChannelName)
  if (index ~= nil) then
    SendChatMessage(Msg, "CHANNEL", nil, index);
  end
end

function GBB.AnnounceInit()
  if GBB.api.client.version > GBB.api.client.TBC then
    GroupBulletinBoardFrameSelectChannel:SetNormalFontObject("GameFontNormal")
    GroupBulletinBoardFrameAnnounce:SetNormalFontObject("GameFontNormal")
  else
    GroupBulletinBoardFrameSelectChannel:SetTextFontObject("GameFontNormal")
    GroupBulletinBoardFrameAnnounce:SetTextFontObject("GameFontNormal")
  end

  local msg_request = GBB.DBChar.msg_request

  if msg_request and msg_request ~= "" then
    GroupBulletinBoardFrameAnnounceMsg:SetTextColor(1, 1, 1)
    GroupBulletinBoardFrameAnnounceMsg:SetText(msg_request)
  else
    GroupBulletinBoardFrameAnnounceMsg:SetTextColor(0.6, 0.6, 0.6)
    GroupBulletinBoardFrameAnnounceMsg:SetText(GBB.L["msgRequestHere"])
  end

  GroupBulletinBoardFrameAnnounce:SetText(GBB.L["BtnPostMsg"])
  GroupBulletinBoardFrameAnnounceMsg:HighlightText(0, 0)
  GroupBulletinBoardFrameAnnounceMsg:SetCursorPosition(0)
  GroupBulletinBoardFrameAnnounce:Disable()
  GroupBulletinBoardFrameAnnounceMsg:SetWidth(GroupBulletinBoardFrame:GetWidth() / 2 - 65)
end

function GBB.FocusLost()
  local t = GroupBulletinBoardFrameAnnounceMsg:GetText()

  if t == "" then
    GroupBulletinBoardFrameAnnounceMsg:SetTextColor(0.6, 0.6, 0.6)
    GroupBulletinBoardFrameAnnounceMsg:SetText(GBB.L["msgRequestHere"])
  end
end

function GBB.GetFocus()
  local t = GroupBulletinBoardFrameAnnounceMsg:GetText()
  if t == GBB.L["msgRequestHere"] then
    GroupBulletinBoardFrameAnnounceMsg:SetTextColor(1, 1, 1)
    GroupBulletinBoardFrameAnnounceMsg:SetText("")
  end
end

function GBB.EditAnnounceMessage_Changed()
  local t = GroupBulletinBoardFrameAnnounceMsg:GetText()
  if t == nil or t == "" or t == GBB.L["msgRequestHere"] then
    GBB.DBChar.msg_request = nil
    GroupBulletinBoardFrameAnnounce:Disable()
  else
    GroupBulletinBoardFrameAnnounce:Enable()
    GBB.DBChar.msg_request = t
  end
end

function GBB.Announce()
  local msg = GroupBulletinBoardFrameAnnounceMsg:GetText()

  if msg ~= nil and msg ~= "" and msg ~= GBB.L["msgRequestHere"] then
    GBB.SendMessage(GBB.DB.AnnounceChannel, msg)
    GroupBulletinBoardFrameAnnounceMsg:ClearFocus()
  end
end

function GBB.CreateChannelPulldown(frame, level, menuList)
  if level ~= 1 then return end
  local t = GBB.PhraseChannelList(GetChannelList())

  local info = UIDropDownMenu_CreateInfo()

  for i, channel in pairs(t) do
    local displayName = channel.name
    if displayName == "LookingForGroup" then
      displayName = "LFG"
    elseif displayName == "Guild Channel" then
      displayName = "Guild"
    elseif displayName == "GuildRecruitment" then
      displayName = "GR"
    elseif displayName == "LocalDefense" then
      displayName = "LD"
    end

    info.text = i .. ". " .. displayName
    info.checked = (channel.name == GBB.DB.AnnounceChannel)
    info.disabled = channel.hidden
    info.arg1 = i
    info.arg2 = channel.name
    info.func = function(self, arg1, arg2, checked)
      GBB.DB.AnnounceChannel = arg2
      local short = arg2
      if short == "LookingForGroup" then
        short = "LFG"
      elseif short == "Guild Channel" then
        short = "Guild"
      elseif short == "GuildRecruitment" then
        short = "GR"
      elseif short == "LocalDefense" then
        short = "LD"
      end
      GroupBulletinBoardFrameSelectChannel:SetText(short)
    end
    UIDropDownMenu_AddButton(info)
  end
end
