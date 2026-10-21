-- GH HUB v1.01 | UI rebuild
-- Interface only: farm, boss, teleport, server-hop and movement are placeholders.
-- Roblox Studio: run as a LocalScript in an experience you own/control.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
if not player then warn("[GH HUB] Run as a LocalScript."); return end

local old = player:WaitForChild("PlayerGui"):FindFirstChild("GHHUB")
if old then old:Destroy() end

local C = {
    bg=Color3.fromRGB(14,15,22), panel=Color3.fromRGB(23,25,36),
    card=Color3.fromRGB(30,32,46), card2=Color3.fromRGB(40,42,59),
    text=Color3.fromRGB(245,245,252), muted=Color3.fromRGB(164,168,188),
    accent=Color3.fromRGB(151,91,255), green=Color3.fromRGB(74,200,139)
}
local function make(class, props, parent)
    local o=Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    o.Parent=parent
    return o
end
local function round(o, r)
    make("UICorner",{CornerRadius=UDim.new(0,r or 10)},o)
end
local function label(parent, text, h, color, font, align)
    return make("TextLabel",{
        BackgroundTransparency=1,Size=UDim2.new(1,0,0,h or 24),
        Font=font or Enum.Font.Gotham,Text=text,TextColor3=color or C.text,
        TextSize=13,TextWrapped=true,TextXAlignment=align or Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center
    },parent)
end
local gui=make("ScreenGui",{Name="GHHUB",ResetOnSpawn=false,IgnoreGuiInset=true,
    DisplayOrder=999999,ZIndexBehavior=Enum.ZIndexBehavior.Global},player.PlayerGui)
local win=make("Frame",{Name="Window",AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(660,440),
    BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true,Active=true,ZIndex=10},gui)
round(win,15)
local outline=make("UIStroke",{Color=C.accent,Transparency=.15,Thickness=1.5},win)
local header=make("Frame",{Size=UDim2.new(1,0,0,58),BackgroundColor3=C.panel,
    BorderSizePixel=0,Active=true,ZIndex=11},win)
round(header,15)
make("Frame",{Position=UDim2.new(0,0,1,-14),Size=UDim2.new(1,0,0,14),
    BackgroundColor3=C.panel,BorderSizePixel=0,ZIndex=11},header)
local mark=make("Frame",{Position=UDim2.fromOffset(14,12),Size=UDim2.fromOffset(34,34),
    BackgroundColor3=C.accent,BorderSizePixel=0,ZIndex=12},header); round(mark,10)
label(mark,"GH",34,C.text,Enum.Font.GothamBlack,Enum.TextXAlignment.Center).ZIndex=13
local title=label(header,"GH HUB",24,C.text,Enum.Font.GothamBold); title.Position=UDim2.fromOffset(58,6); title.Size=UDim2.new(0,180,0,25); title.ZIndex=12
local sub=label(header,"COMMUNITY INTERFACE  •  v1.01",16,C.muted,Enum.Font.GothamMedium); sub.Position=UDim2.fromOffset(59,31); sub.Size=UDim2.new(0,270,0,15); sub.TextSize=10; sub.ZIndex=12
local close=make("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),
    Size=UDim2.fromOffset(34,34),BackgroundColor3=Color3.fromRGB(68,40,70),
    Text="×",TextColor3=C.text,TextSize=23,Font=Enum.Font.GothamBold,ZIndex=13},header); round(close,9)
close.Activated:Connect(function() gui:Destroy() end)

-- Drag with mouse or touch
local dragging, dragStart, startPos, dragInput=false,nil,nil,nil
header.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dragStart=i.Position; startPos=win.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
    end
end)
header.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then dragInput=i end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i==dragInput or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dragStart
        win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

local side=make("Frame",{Position=UDim2.fromOffset(12,70),Size=UDim2.new(0,158,1,-82),
    BackgroundColor3=C.panel,BorderSizePixel=0,ZIndex=11},win); round(side,12)
make("UIPadding",{PaddingTop=UDim.new(0,12),PaddingLeft=UDim.new(0,9),PaddingRight=UDim.new(0,9)},side)
make("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},side)
local body=make("Frame",{Position=UDim2.fromOffset(182,70),Size=UDim2.new(1,-194,1,-82),
    BackgroundTransparency=1,ClipsDescendants=true,ZIndex=11},win)
local pages,nav={},{}
local active="Người dùng"
local function page(name)
    local p=make("ScrollingFrame",{Name=name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.accent,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=false,ZIndex=12},body)
    make("UIPadding",{PaddingTop=UDim.new(0,2),PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},p)
    make("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},p)
    pages[name]=p; return p
end
local function heading(p,t)
    local l=label(p,t,26,C.accent,Enum.Font.GothamBold); l.TextSize=15; return l
end
local function card(p,h)
    local f=make("Frame",{Size=UDim2.new(1,0,0,h or 60),BackgroundColor3=C.card,
        BorderSizePixel=0,ZIndex=13},p); round(f,11); return f
end
local function info(p,k,v)
    local r=card(p,38)
    local a=label(r,k,30,C.muted,Enum.Font.GothamMedium); a.Position=UDim2.fromOffset(12,4); a.Size=UDim2.new(.43,-12,1,-8); a.ZIndex=14
    local b=label(r,v,30,C.text,Enum.Font.GothamSemibold,Enum.TextXAlignment.Right); b.Position=UDim2.new(.43,0,0,4); b.Size=UDim2.new(.57,-12,1,-8); b.ZIndex=14
    return b
end
local function addNav(name,n,symbol)
    local b=make("TextButton",{Name="Nav_"..name,LayoutOrder=n,Size=UDim2.new(1,0,0,42),
        BackgroundColor3=name==active and C.accent or C.panel,Text=symbol.."   "..name,
        TextColor3=C.text,TextSize=12,Font=Enum.Font.GothamSemibold,
        TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,ZIndex=12},side)
    round(b,9); make("UIPadding",{PaddingLeft=UDim.new(0,10)},b); nav[name]=b
    b.Activated:Connect(function()
        active=name
        for n,p in pairs(pages) do p.Visible=n==name end
        for n,button in pairs(nav) do button.BackgroundColor3=n==name and C.accent or C.panel end
    end)
end
local users=page("Người dùng")
local main=page("Main")
local team=page("Đội Ngũ Xây Dựng")
local settings=page("Settings")
addNav("Người dùng",1,"◉"); addNav("Main",2,"✦"); addNav("Đội Ngũ Xây Dựng",3,"♙"); addNav("Settings",4,"⚙")
users.Visible=true

heading(users,"HỒ SƠ NGƯỜI DÙNG")
local prof=card(users,118)
local avatar=make("ImageLabel",{Position=UDim2.fromOffset(13,13),Size=UDim2.fromOffset(88,88),
    BackgroundColor3=C.card2,BorderSizePixel=0,Image="",ZIndex=14},prof); round(avatar,44)
local disp=label(prof,player.DisplayName,26,C.text,Enum.Font.GothamBold); disp.Position=UDim2.fromOffset(115,18); disp.Size=UDim2.new(1,-130,0,27); disp.ZIndex=14
local uname=label(prof,"@"..player.Name,22,C.muted,Enum.Font.GothamMedium); uname.Position=UDim2.fromOffset(115,47); uname.Size=UDim2.new(1,-130,0,22); uname.ZIndex=14
local uid=label(prof,"Roblox ID: "..player.UserId,20,C.muted); uid.Position=UDim2.fromOffset(115,73); uid.Size=UDim2.new(1,-130,0,20); uid.TextSize=11; uid.ZIndex=14
task.spawn(function()
    local ok,url=pcall(function() return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end)
    if ok and avatar.Parent then avatar.Image=url end
end)
heading(users,"THÔNG TIN TRONG GAME")
local levelLabel=info(users,"Level hiện tại","Đang kiểm tra…")
info(users,"Trạng thái","Đã kết nối")
local function getLevel()
    local containers={}
    local ls=player:FindFirstChild("leaderstats"); if ls then table.insert(containers,ls) end
    local data=player:FindFirstChild("Data"); if data then table.insert(containers,data) end
    for _,container in ipairs(containers) do
        for _,n in ipairs({"Level","level","Lv","LV"}) do
            local v=container:FindFirstChild(n)
            if v and (v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue")) then return v end
        end
    end
end
local function refreshLevel()
    local v=getLevel()
    if v then levelLabel.Text=tostring(v.Value); levelLabel.TextColor3=C.green
    else levelLabel.Text="Không tìm thấy dữ liệu Level"; levelLabel.TextColor3=C.muted end
end
refreshLevel()
task.spawn(function()
    for _=1,20 do
        task.wait(1); refreshLevel()
        local v=getLevel()
        if v then v:GetPropertyChangedSignal("Value"):Connect(refreshLevel); return end
    end
end)
label(users,"GH HUB • Giao diện v1.01",22,C.muted,Enum.Font.GothamMedium)

heading(main,"TÍNH NĂNG CƠ BẢN")
label(main,"Các nút hiện là công tắc giao diện mẫu, chưa tự động thao tác trong Blox Fruits.",40,C.muted)
local function toggle(p,name,desc)
    local r=card(p,62)
    local a=label(r,name,23,C.text,Enum.Font.GothamSemibold); a.Position=UDim2.fromOffset(12,7); a.Size=UDim2.new(1,-94,0,22); a.TextSize=12; a.ZIndex=14
    local d=label(r,desc,18,C.muted); d.Position=UDim2.fromOffset(12,31); d.Size=UDim2.new(1,-94,0,18); d.TextSize=10; d.ZIndex=14
    local b=make("TextButton",{Position=UDim2.new(1,-69,.5,-14),Size=UDim2.fromOffset(56,28),
        BackgroundColor3=C.card2,Text="OFF",TextColor3=C.text,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=14},r); round(b,8)
    local on=false
    b.Activated:Connect(function() on=not on; b.Text=on and "ON" or "OFF"; b.BackgroundColor3=on and C.accent or C.card2 end)
end
toggle(main,"Auto Farm Level","Chưa kết nối logic farm")
toggle(main,"Auto Farm Boss","Chưa kết nối logic boss")
toggle(main,"Server Hop","Chưa kết nối logic đổi server")
toggle(main,"Teleporter","Chưa kết nối logic dịch chuyển")
toggle(main,"Auto Quest","Chưa kết nối logic nhiệm vụ")

heading(team,"STUDIO XÂY DỰNG SCRIPT GH HUB")
local owner=card(team,74)
local badge=make("Frame",{Position=UDim2.fromOffset(12,12),Size=UDim2.fromOffset(48,48),
    BackgroundColor3=C.accent,BorderSizePixel=0,ZIndex=14},owner); round(badge,12)
label(badge,"TN",48,C.text,Enum.Font.GothamBlack,Enum.TextXAlignment.Center).ZIndex=15
local ownerTitle=label(owner,"Owner : Thiện Nhân  ↓",25,C.text,Enum.Font.GothamBold); ownerTitle.Position=UDim2.fromOffset(72,7); ownerTitle.Size=UDim2.new(1,-84,0,28); ownerTitle.ZIndex=14
local ownerSub=label(owner,"Nhấn để xem thông tin",20,C.muted); ownerSub.Position=UDim2.fromOffset(72,36); ownerSub.Size=UDim2.new(1,-84,0,20); ownerSub.TextSize=11; ownerSub.ZIndex=14
local ownerClick=make("TextButton",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Text="",ZIndex=16},owner)
local details=card(team,20); details.AutomaticSize=Enum.AutomaticSize.Y; details.Visible=false; details.BackgroundColor3=C.card2
make("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},details)
make("UIPadding",{PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)},details)
for _,txt in ipairs({
    "Username Roblox : @conluoo2","Tuổi : 19","Giới tính : Nam",
    "Telegram : @DTN_207","Discord : Chưa Xác Định",
    "Tiktok : @ Chưa Xác Định","YouTube : Chưa Xác Định"
}) do local l=label(details,txt,22,C.text,Enum.Font.GothamMedium); l.TextSize=12; l.ZIndex=14 end
ownerClick.Activated:Connect(function() details.Visible=not details.Visible; ownerTitle.Text=details.Visible and "Owner : Thiện Nhân  ↑" or "Owner : Thiện Nhân  ↓" end)
label(team,"Thông tin do chủ dự án cung cấp.",22,C.muted)

heading(settings,"CÀI ĐẶT GIAO DIỆN")
label(settings,"Kích thước menu",22,C.text,Enum.Font.GothamSemibold)
local function settingButton(txt,fn)
    local b=make("TextButton",{Size=UDim2.new(1,0,0,38),BackgroundColor3=C.card,Text=txt,
        TextColor3=C.text,TextSize=12,Font=Enum.Font.GothamSemibold,ZIndex=14},settings); round(b,9); b.Activated:Connect(fn); return b
end
for name,size in pairs({Nhỏ=Vector2.new(560,390),Vừa=Vector2.new(660,440),Lớn=Vector2.new(760,510)}) do
    settingButton(name,function() win.Size=UDim2.fromOffset(size.X,size.Y); win.Position=UDim2.fromScale(.5,.5) end)
end
label(settings,"Màu chủ đạo",22,C.text,Enum.Font.GothamSemibold)
local colors={Tím=Color3.fromRGB(151,91,255),["Xanh dương"]=Color3.fromRGB(70,140,255),Hồng=Color3.fromRGB(245,90,180),Đỏ=Color3.fromRGB(245,82,100),["Xanh lá"]=Color3.fromRGB(65,190,125)}
local function setAccent(color)
    C.accent=color; outline.Color=color; mark.BackgroundColor3=color; badge.BackgroundColor3=color
    for n,b in pairs(nav) do b.BackgroundColor3=n==active and color or C.panel end
    for _,p in pairs(pages) do
        p.ScrollBarImageColor3=color
        for _,child in ipairs(p:GetChildren()) do
            if child:IsA("TextLabel") and child.TextColor3==C.accent then child.TextColor3=color end
        end
    end
    for _,b in ipairs(settings:GetChildren()) do
        if b:IsA("TextButton") then b.BackgroundColor3=(colors[b.Text]==color) and color or C.card end
    end
end
for name,color in pairs(colors) do settingButton(name,function() setAccent(color) end) end

local footer=label(win,"GH HUB  •  UI READY",16,C.muted,Enum.Font.GothamMedium)
footer.Position=UDim2.new(0,13,1,-19); footer.Size=UDim2.new(0,155,0,14); footer.TextSize=9; footer.ZIndex=20
print("[GH HUB v1.01] Interface loaded. Gameplay controls are placeholders.")
