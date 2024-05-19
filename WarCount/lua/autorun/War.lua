AddCSLuaFile()

local War = {Frag = {}}
local myarray = {}

if SERVER then
    util.AddNetworkString("War_Start")
    util.AddNetworkString("War_End")
    resource.AddFile("sound/warsound/warsounds.mp3")

    concommand.Add("war_start", function(ply, cmd, args)
        if not ply:IsSuperAdmin() then return end
        local args = args[1] or 1
        War.Frag = {}
        War.Begun = true
        for k,v in pairs(player.GetAll()) do
            v:SetFrags(0)
        end
        args = args * 60
        War:Start(args)
        
        timer.Create("WarEnd", args, 1, function()
            for k,v in pairs(player.GetAll()) do
                War["Frag"][v:GetName()] = v:Frags()
            end
            net.Start("War_End")
            net.WriteTable(War.Frag)
            net.Broadcast()
        end)

    end)

    function War:Start(time)
        net.Start("War_Start")
        net.WriteUInt(time, 32)
        net.WriteBool(War.Begun)
        net.Broadcast() 
    end

end


if CLIENT then
    net.Receive("War_Start", function()
        War.Time = net.ReadUInt(32)
        War.Begun = net.ReadBool()
   
        surface.PlaySound("warsound/warsounds.mp3")
        timer.Create("WarTimer", 1, War.Time, function()
            if not War.Begun then return end
            War.Time = War.Time - 1
            if War.Time <= 0 then
                War.Begun = false
                War.Time = 0
            end
        end)
    end)
    


    hook.Add("HUDPaint","WarHud",function()
        if not War.Begun then return end
        surface.SetDrawColor(75,71,71,110)
        surface.DrawRect(ScrW()-ScrW()*0.2,0,ScrW()*0.2,ScrH()*0.2)
        surface.SetFont("Trebuchet24")
        surface.SetTextColor(255,255,255)
        surface.SetTextPos(ScrW()-ScrW()*0.125,ScrH()*0.12)
        surface.DrawText("WAR HAS BEGUN!")
        surface.SetTextPos(ScrW()-ScrW()*0.125,ScrH()*0.07)
        surface.DrawText("Time Left: " .. War.Time .. "s")
        

        net.Receive("War_End", function()
            local tbl = net.ReadTable()
            myarray = {}
            for k,v in pairs(tbl) do
                table.insert(myarray,{name = k, frags = v})
            end

            table.SortByMember(myarray, "frags", false)
            
            

            if myarray[1] == nil then return end
            chat.AddText(Color(255,215,0),"First place: ", myarray[1].name, " carried the war with ",tostring(myarray[1].frags) , " frags!")
            if myarray[2] == nil then return end
            chat.AddText(Color(192,192,192), "Second place: ", myarray[2].name, " with ", tostring(myarray[2].frags), " frags!")
            if myarray[3] == nil then return end
            chat.AddText(Color(205,127,50), "Third place: ", myarray[3].name, " with ", tostring(myarray[3].frags), " frags!")
            

        end)

    
    end)
end