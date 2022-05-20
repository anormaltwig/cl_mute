local menu = {
	muted = {}
}

hook.Add("OnPlayerChat", "ClientsideChatMute", function(ply)
	if menu.muted[ply:SteamID()] then
		return false
	end
end)

surface.CreateFont("clmutemenu", {
	font = "Verdana",
	size = 20,
	weight = 500,
	antialias = true,
	additive = false,
})
local backgroundColor = Color(0, 0, 0, 100)
local entryColor = Color(150, 150, 150, 255)

function menu.create()
	local frame = vgui.Create("DFrame")
	frame:SetSize(500, 700)
	frame:SetTitle("Mute Menu")
	frame:Center()
	frame:MakePopup()

	function frame:Paint(w, h)
		draw.RoundedBox(4, 0, 0, w, h, backgroundColor)
	end

	local scroll = vgui.Create("DScrollPanel", frame)
	scroll:Dock(FILL)

	for k, ply in pairs(player.GetHumans()) do
		local plyPanel = vgui.Create("DPanel", scroll)
		plyPanel:DockMargin(0, 0, 0, 4)
		plyPanel:Dock(TOP)
		
		function plyPanel:Paint(w, h)
			draw.RoundedBox(4, 0, 0, w, h, entryColor)
		end

		local name = vgui.Create("DLabel", plyPanel)
		name:SetWidth(200)
		name:SetText(" " .. ply:Name())
		name:SetTextColor(team.GetColor(ply:Team()))
		name:SetFont("clmutemenu")
		name:Dock(LEFT)

		if ply ~= LocalPlayer() then
			if not ply:IsAdmin() then
				local textMute = vgui.Create("DButton", plyPanel)
				textMute:SetText("")
				textMute:SetSize(24, 24)
				textMute:Dock(RIGHT)

				textMute:SetIcon(menu.muted[ply:SteamID()] and "icon16/cross.png" or "icon16/comments.png")
				function textMute.DoClick()
					if not IsValid(ply) then
						plyPanel:Remove()
						return
					end

					if menu.muted[ply:SteamID()] then
						menu.muted[ply:SteamID()] = nil
						textMute:SetIcon("icon16/comments.png")
					else
						menu.muted[ply:SteamID()] = true
						textMute:SetIcon("icon16/cross.png")
					end
				end
			end

			local vcMute = vgui.Create("DButton", plyPanel)
			vcMute:SetText("")
			vcMute:SetSize(24, 24)
			vcMute:Dock(RIGHT)

			vcMute:SetIcon(ply:IsMuted() and "icon16/sound_mute.png" or "icon16/sound.png")

			function vcMute.DoClick()
				if not IsValid(ply) then
					plyPanel:Remove()
					return
				end
				
				ply:SetMuted(not ply:IsMuted())
				if ply:IsMuted() then
					vcMute:SetIcon("icon16/sound_mute.png")
				else
					vcMute:SetIcon("icon16/sound.png")
				end
			end

			local vcSlider = vgui.Create("DNumSlider", plyPanel)
			vcSlider:SetWidth(300)
			vcSlider:SetMinMax(0, 100)
			vcSlider:SetDecimals(0)
			vcSlider:SetValue(ply:GetVoiceVolumeScale() * 100)
			vcSlider:Dock(RIGHT)

			function vcSlider.OnValueChanged(self, value)
				ply:SetVoiceVolumeScale(value / 100)
			end
		end
	end
end

concommand.Add("clmute_menu", function()
	menu.create()
end, nil, "Opens a menu to mute specific players in text or voice chat.")

hook.Add("Initialize", "annouce_mute_menu", function()
	chat.AddText(Color(0, 255, 0), "This server has a mute menu! Type ", Color(255, 255, 255), "clmute_menu", Color(0, 255, 0), " in console to open it.")
end)