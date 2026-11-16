local __DARKLUA_BUNDLE_MODULES={cache={}}do do local function __modImpl()local
HttpService=game:GetService('HttpService')local Util={}function Util.New(class,
props,children)local inst=Instance.new(class)local parent if props then for key,
value in props do if key=='Parent'then parent=value else inst[key]=value end end
end if children then for _,child in children do child.Parent=inst end end if
parent then inst.Parent=parent end return inst end function Util.Corner(radius,
parent)return Util.New('UICorner',{CornerRadius=UDim.new(0,radius),Parent=parent
})end function Util.Round(parent)return Util.New('UICorner',{CornerRadius=UDim.
new(1,0),Parent=parent})end function Util.Stroke(parent,color,thickness,
transparency)return Util.New('UIStroke',{Color=color or Color3.new(1,1,1),
Thickness=thickness or 1,Transparency=transparency or 0,ApplyStrokeMode=Enum.
ApplyStrokeMode.Border,Parent=parent})end function Util.Padding(parent,top,right
,bottom,left)right=right or top bottom=bottom or top left=left or right return
Util.New('UIPadding',{PaddingTop=UDim.new(0,top),PaddingRight=UDim.new(0,right),
PaddingBottom=UDim.new(0,bottom),PaddingLeft=UDim.new(0,left),Parent=parent})end
function Util.List(parent,padding,direction,halign,valign)return Util.New(
'UIListLayout',{Padding=UDim.new(0,padding or 0),FillDirection=direction or Enum
.FillDirection.Vertical,HorizontalAlignment=halign or Enum.HorizontalAlignment.
Left,VerticalAlignment=valign or Enum.VerticalAlignment.Top,SortOrder=Enum.
SortOrder.LayoutOrder,Parent=parent})end function Util.Gradient(parent,color,
transparency,rotation)return Util.New('UIGradient',{Color=color or ColorSequence
.new(Color3.new(1,1,1)),Transparency=transparency or NumberSequence.new(0),
Rotation=rotation or 0,Parent=parent})end function Util.Label(props)local base={
BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=
Enum.TextYAlignment.Center,RichText=false,TextSize=13,Size=UDim2.new(1,0,0,16),
BorderSizePixel=0}for k,v in props do base[k]=v end return Util.New('TextLabel',
base)end function Util.Hitbox(parent,zindex)return Util.New('TextButton',{
BackgroundTransparency=1,Text='',Size=UDim2.fromScale(1,1),ZIndex=zindex or 1,
AutoButtonColor=false,Parent=parent})end function Util.Merge(defaults,overrides)
local out=table.clone(defaults)if overrides then for k,v in overrides do out[k]=
v end end return out end function Util.DeepCopy(value)if type(value)~='table'
then return value end local out={}for k,v in value do out[Util.DeepCopy(k)]=Util
.DeepCopy(v)end return out end function Util.Equal(a,b)if a==b then return true
end if type(a)~='table'or type(b)~='table'then return false end for k,v in a do
if not Util.Equal(v,b[k])then return false end end for k in b do if a[k]==nil
then return false end end return true end function Util.Count(t)local n=0 for _
in t do n+=1 end return n end function Util.Find(list,value)return table.find(
list,value)end function Util.Keys(t)local out={}for k in t do table.insert(out,k
)end return out end function Util.Opt(opts,...)for i=1,select('#',...)do local v
=opts[select(i,...)]if v~=nil then return v end end return nil end function Util
.Clamp(n,min,max)if min>max then min,max=max,min end return math.clamp(n,min,max
)end function Util.Snap(n,step,origin)if not step or step<=0 then return n end
origin=origin or 0 local snapped=math.floor((n-origin)/step+0.5)*step+origin
local decimals=Util.Decimals(step)return tonumber(string.format('%.'..decimals..
'f',snapped))end function Util.Decimals(step)local s=tostring(step)local dot=
string.find(s,'%.')if not dot then return 0 end return math.min(#s-dot,6)end
function Util.Lerp(a,b,t)return a+(b-a)*t end function Util.FormatNumber(n,
decimals)decimals=decimals or 0 local s=string.format('%.'..decimals..'f',n)if
decimals>0 then s=string.gsub(s,'%.?0+$','')end if s=='-0'then s='0'end return s
end function Util.Abbreviate(n)local abs=math.abs(n)if abs>=1e9 then return Util
.FormatNumber(n/1e9,1)..'B'elseif abs>=1e6 then return Util.FormatNumber(n/1e6,1
)..'M'elseif abs>=1e3 then return Util.FormatNumber(n/1e3,1)..'K'end return Util
.FormatNumber(n,0)end function Util.ToHex(color)return string.format(
'#%02X%02X%02X',math.round(color.R*255),math.round(color.G*255),math.round(color
.B*255))end function Util.FromHex(hex)hex=string.gsub(tostring(hex),'[#%s]','')
if#hex==3 then hex=string.gsub(hex,'.','%0%0')end if#hex~=6 or string.find(hex,
'[^%x]')then return nil end return Color3.fromRGB(tonumber(string.sub(hex,1,2),
16),tonumber(string.sub(hex,3,4),16),tonumber(string.sub(hex,5,6),16))end
function Util.ToColor(value)local t=typeof(value)if t=='Color3'then return value
elseif t=='string'then return Util.FromHex(value)elseif t=='table'then local r,g
,b=value[1]or value.R or value.r,value[2]or value.G or value.g,value[3]or value.
B or value.b if r and g and b then return Color3.fromRGB(r,g,b)end end return
nil end function Util.Luminance(c)return 0.2126*c.R+0.7152*c.G+0.0722*c.B end
function Util.Mix(a,b,t)return a:Lerp(b,t)end function Util.Trim(s)return(string
.gsub(s,'^%s*(.-)%s*$','%1'))end function Util.Truncate(s,max)if utf8.len(s)and
utf8.len(s)>max then return string.sub(s,1,utf8.offset(s,max)-1)..'\u{2026}'end
return s end function Util.Escape(s)return(string.gsub(s,'[<>&"\']',{['<']=
'&lt;',['>']='&gt;',['&']='&amp;',['"']='&quot;',["'"]='&apos;'}))end function
Util.SafeName(s)s=Util.Trim(tostring(s))s=string.gsub(s,'%.%.','_')s=string.
gsub(s,'[^%w%s%-%_%.]','_')return string.sub(s,1,64)end function Util.Fuzzy(
query,text)query=string.lower(query)text=string.lower(text)if query==''then
return 0 end local direct=string.find(text,query,1,true)if direct then return
1000-direct*2-#text*0.1 end local score,ti,streak,skipped=0,1,0,0 for qi=1,#
query do local ch=string.sub(query,qi,qi)local found=string.find(text,ch,ti,true
)if not found then return nil end if qi>1 then skipped+=found-ti end if found==
ti then streak+=1 score+=5*streak else streak=0 end local prev=string.sub(text,
found-1,found-1)if found==1 or prev==' 'or prev=='-'or prev=='_'or prev=='.'then
score+=8 end ti=found+1 end if skipped>#query*3 then return nil end return score
-skipped*2-#text*0.1 end function Util.Uid()return string.sub(string.gsub(
HttpService:GenerateGUID(false),'-',''),1,12)end local B64=
[[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/]]function
Util.Base64Encode(data)return((string.gsub(data,'.',function(x)local r,b='',
string.byte(x)for i=8,1,-1 do r..=(b%2^i-b%2^(i-1)>0 and'1'or'0')end return r
end)..'0000'):gsub('%d%d%d?%d?%d?%d?',function(x)if#x<6 then return''end local c
=0 for i=1,6 do c+=(string.sub(x,i,i)=='1'and 2^(6-i)or 0)end return string.sub(
B64,c+1,c+1)end)..({'','==','='})[#data%3+1])end function Util.Base64Decode(data
)data=string.gsub(data,'[^'..B64..'=]','')return(string.gsub(data,'.',function(x
)if x=='='then return''end local r,f='',(string.find(B64,x,1,true)-1)for i=6,1,-
1 do r..=(f%2^i-f%2^(i-1)>0 and'1'or'0')end return r end):gsub(
'%d%d%d?%d?%d?%d?%d?%d?',function(x)if#x~=8 then return''end local c=0 for i=1,8
do c+=(string.sub(x,i,i)=='1'and 2^(8-i)or 0)end return string.char(c)end))end
function Util.Checksum(s)local a,b=1,0 for i=1,#s do a=(a+string.byte(s,i))%
65521 b=(b+a)%65521 end return string.format('%08x',b*65536+a)end Util.
ErrorHandler=function(message,trace)warn('[Proximity] callback error: '..
tostring(message)..'\n'..trace)end function Util.SafeCall(fn,...)if type(fn)~=
'function'then return false end return xpcall(fn,function(err)local trace=debug.
traceback(nil,2)task.spawn(Util.ErrorHandler,err,trace)return err end,...)end
function Util.Debounce(seconds,fn)local token=0 return function(...)token+=1
local mine=token local args=table.pack(...)task.delay(seconds,function()if mine
==token then fn(table.unpack(args,1,args.n))end end)end end function Util.
Throttle(seconds,fn)local last=0 return function(...)local now=os.clock()if now-
last>=seconds then last=now fn(...)end end end return Util end function
__DARKLUA_BUNDLE_MODULES.a()local v=__DARKLUA_BUNDLE_MODULES.cache.a if not v
then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.a=v end return v.c end end
do local function __modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local
Connection={}Connection.__index=Connection function Connection:Disconnect()if
not self.Connected then return end self.Connected=false local list=self._signal.
_handlers local index=table.find(list,self)if index then table.remove(list,index
)end end Connection.Destroy=Connection.Disconnect local Signal={}Signal.__index=
Signal function Signal.new()return setmetatable({_handlers={}},Signal)end
function Signal.Is(value)return type(value)=='table'and getmetatable(value)==
Signal end function Signal:Connect(fn)local connection=setmetatable({Connected=
true,_fn=fn,_signal=self},Connection)table.insert(self._handlers,connection)
return connection end function Signal:Once(fn)local connection connection=self:
Connect(function(...)connection:Disconnect()fn(...)end)return connection end
function Signal:Fire(...)local snapshot=table.clone(self._handlers)for _,
connection in snapshot do if connection.Connected then Util.SafeCall(connection.
_fn,...)end end end function Signal:Wait(timeout)local thread=coroutine.running(
)local done=false local connection connection=self:Connect(function(...)if done
then return end done=true connection:Disconnect()task.spawn(thread,...)end)if
timeout then task.delay(timeout,function()if not done then done=true connection:
Disconnect()task.spawn(thread)end end)end return coroutine.yield()end function
Signal:HasConnections()return#self._handlers>0 end function Signal:DisconnectAll
()for _,connection in table.clone(self._handlers)do connection:Disconnect()end
end Signal.Destroy=Signal.DisconnectAll return Signal end function
__DARKLUA_BUNDLE_MODULES.b()local v=__DARKLUA_BUNDLE_MODULES.cache.b if not v
then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.b=v end return v.c end end
do local function __modImpl()local Maid={}Maid.__index=Maid function Maid.new()
return setmetatable({_tasks={}},Maid)end function Maid:Give(task_)if task_~=nil
then table.insert(self._tasks,task_)end return task_ end Maid.Add=Maid.Give
function Maid:Connect(signal,fn)return self:Give(signal:Connect(fn))end local 
function cleanup(item)local kind=typeof(item)if kind=='RBXScriptConnection'then
item:Disconnect()elseif kind=='Instance'then item:Destroy()elseif kind==
'function'then item()elseif kind=='thread'then pcall(task.cancel,item)elseif
kind=='table'then if type(item.Destroy)=='function'then item:Destroy()elseif
type(item.Disconnect)=='function'then item:Disconnect()elseif type(item.Clean)==
'function'then item:Clean()end end end function Maid:Clean()local tasks=self.
_tasks self._tasks={}for i=#tasks,1,-1 do pcall(cleanup,tasks[i])end end Maid.
Destroy=Maid.Clean return Maid end function __DARKLUA_BUNDLE_MODULES.c()local v=
__DARKLUA_BUNDLE_MODULES.cache.c if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.c=v end return v.c end end do local function 
__modImpl()local TweenService=game:GetService('TweenService')local Tween={Speed=
1,Style=Enum.EasingStyle.Quint,Direction=Enum.EasingDirection.Out}function Tween
.Info(time,style,direction,...)return TweenInfo.new((time or 0.2)*Tween.Speed,
style or Tween.Style,direction or Tween.Direction,...)end function Tween.Play(
instance,goal,time,style,direction)if not instance then return nil end local
duration=(time or 0.2)*Tween.Speed if duration<=0 then for k,v in goal do
instance[k]=v end return nil end local tween=TweenService:Create(instance,
TweenInfo.new(duration,style or Tween.Style,direction or Tween.Direction),goal)
tween:Play()return tween end function Tween.Await(instance,goal,time,style,
direction)local tween=Tween.Play(instance,goal,time,style,direction)if tween
then tween.Completed:Wait()end end function Tween.Value(from,to,time,step,style)
local duration=time*Tween.Speed if duration<=0 then step(to)return end local
RunService=game:GetService('RunService')local start=os.clock()local connection
connection=RunService.Heartbeat:Connect(function()local alpha=math.clamp((os.
clock()-start)/duration,0,1)local eased=TweenService:GetValue(alpha,style or
Tween.Style,Enum.EasingDirection.Out)step(from+(to-from)*eased)if alpha>=1 then
connection:Disconnect()end end)return connection end return Tween end function
__DARKLUA_BUNDLE_MODULES.d()local v=__DARKLUA_BUNDLE_MODULES.cache.d if not v
then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.d=v end return v.c end end
do local function __modImpl()local Env={}local function global(name)local ok,
value=pcall(function()local genv=getgenv and getgenv()if genv and genv[name]~=
nil then return genv[name]end return getfenv(0)[name]end)return ok and value or
nil end Env.Global=global local cloneref=global('cloneref')or function(x)return
x end Env.cloneref=cloneref local services={}function Env.Service(name)local svc
=services[name]if not svc then svc=cloneref(game:GetService(name))services[name]
=svc end return svc end local fs={write=global('writefile'),read=global(
'readfile'),isfile=global('isfile'),isfolder=global('isfolder'),makefolder=
global('makefolder'),list=global('listfiles'),delete=global('delfile')}Env.Caps=
{Files=fs.write~=nil and fs.read~=nil and fs.isfile~=nil and fs.makefolder~=nil,
ListFiles=fs.list~=nil,Clipboard=global('setclipboard')~=nil or global(
'toclipboard')~=nil,CustomAsset=global('getcustomasset')~=nil or global(
'getsynasset')~=nil,Request=global('request')~=nil or global('http_request')~=
nil,Hwid=global('gethwid')~=nil,HiddenUi=global('gethui')~=nil,Executor=global(
'identifyexecutor')~=nil,Studio=(function()local ok,studio=pcall(function()
return game:GetService('RunService'):IsStudio()end)return ok and studio or false
end)()}function Env.ExecutorName()local identify=global('identifyexecutor')or
global('getexecutorname')if identify then local ok,name,version=pcall(identify)
if ok and name then return version and(tostring(name)..' '..tostring(version))or
tostring(name)end end return Env.Caps.Studio and'Studio'or'Unknown'end function
Env.GuiParent()local gethui=global('gethui')if gethui then local ok,hui=pcall(
gethui)if ok and hui then return hui end end local ok=pcall(function()local
probe=Instance.new('Folder')probe.Parent=Env.Service('CoreGui')probe:Destroy()
end)if ok then return Env.Service('CoreGui')end local players=Env.Service(
'Players')local player=players.LocalPlayer or players:GetPropertyChangedSignal(
'LocalPlayer'):Wait()return player:WaitForChild('PlayerGui')end function Env.
Protect(gui)pcall(function()local syn=global('syn')if syn and syn.protect_gui
then syn.protect_gui(gui)elseif global('protectgui')then global('protectgui')(
gui)end end)end local memory={}Env.Memory=memory local function norm(path)return
(string.gsub(path,'\\','/'))end function Env.IsFile(path)path=norm(path)if Env.
Caps.Files then local ok,result=pcall(fs.isfile,path)return ok and result==true
end return memory[path]~=nil end function Env.IsFolder(path)path=norm(path)if
Env.Caps.Files and fs.isfolder then local ok,result=pcall(fs.isfolder,path)
return ok and result==true end return true end function Env.MakeFolder(path)path
=norm(path)if not Env.Caps.Files then return end local current=''for part in
string.gmatch(path,'[^/]+')do current=current==''and part or(current..'/'..part)
if not Env.IsFolder(current)then pcall(fs.makefolder,current)end end end
function Env.Write(path,data)path=norm(path)if Env.Caps.Files then local folder=
string.match(path,'^(.*)/[^/]+$')if folder then Env.MakeFolder(folder)end return
(pcall(fs.write,path,data))end memory[path]=data return true end function Env.
Read(path)path=norm(path)if Env.Caps.Files then if not Env.IsFile(path)then
return nil end local ok,data=pcall(fs.read,path)return ok and data or nil end
return memory[path]end function Env.Delete(path)path=norm(path)if Env.Caps.Files
and fs.delete then return(pcall(fs.delete,path))end memory[path]=nil return true
end function Env.List(folder)folder=norm(folder)local out={}if Env.Caps.Files
and fs.list then local ok,items=pcall(fs.list,folder)if ok and type(items)==
'table'then for _,item in items do local name=string.match(norm(item),'([^/]+)$'
)if name then table.insert(out,name)end end end else for path in memory do local
dir,name=string.match(path,'^(.*)/([^/]+)$')if dir==folder then table.insert(out
,name)end end end table.sort(out)return out end function Env.Clipboard(text)
local set=global('setclipboard')or global('toclipboard')if set then return(
pcall(set,tostring(text)))end return false end function Env.HttpGet(url)local ok
,body=pcall(function()return game:HttpGet(url)end)if ok and type(body)=='string'
then return body end local req=global('request')or global('http_request')if req
then local ok2,response=pcall(req,{Url=url,Method='GET'})if ok2 and response and
response.Body then return response.Body end end return nil end function Env.
CustomAsset(path)local get=global('getcustomasset')or global('getsynasset')if
not get then return nil end local ok,asset=pcall(get,path)return ok and asset or
nil end function Env.Hwid()local get=global('gethwid')if get then local ok,id=
pcall(get)if ok and id then return tostring(id)end end local ok,id=pcall(
function()return game:GetService('RbxAnalyticsService'):GetClientId()end)return
ok and tostring(id)or'unknown'end function Env.Shared()local genv=global(
'getgenv')local root=genv and genv()or _G root.__ProximityUI=root.__ProximityUI
or{}return root.__ProximityUI end return Env end function
__DARKLUA_BUNDLE_MODULES.e()local v=__DARKLUA_BUNDLE_MODULES.cache.e if not v
then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.e=v end return v.c end end
do local function __modImpl()local Keys={}local short={LeftShift='LShift',
RightShift='RShift',LeftControl='LCtrl',RightControl='RCtrl',LeftAlt='LAlt',
RightAlt='RAlt',LeftSuper='LWin',RightSuper='RWin',Backspace='Bksp',Return=
'Enter',Escape='Esc',CapsLock='Caps',PageUp='PgUp',PageDown='PgDn',Insert='Ins',
Delete='Del',Zero='0',One='1',Two='2',Three='3',Four='4',Five='5',Six='6',Seven=
'7',Eight='8',Nine='9',KeypadZero='Num0',KeypadOne='Num1',KeypadTwo='Num2',
KeypadThree='Num3',KeypadFour='Num4',KeypadFive='Num5',KeypadSix='Num6',
KeypadSeven='Num7',KeypadEight='Num8',KeypadNine='Num9',KeypadPeriod='Num.',
KeypadDivide='Num/',KeypadMultiply='Num*',KeypadMinus='Num-',KeypadPlus='Num+',
KeypadEnter='NumEnter',KeypadEquals='Num=',Minus='-',Equals='=',LeftBracket='[',
RightBracket=']',BackSlash='\\',Semicolon=';',Quote="'",Comma=',',Period='.',
Slash='/',Backquote='`',Tilde='~'}local mouse={[Enum.UserInputType.MouseButton1]
='MB1',[Enum.UserInputType.MouseButton2]='MB2',[Enum.UserInputType.MouseButton3]
='MB3'}local mouseReverse={}for k,v in mouse do mouseReverse[v]=k end function
Keys.FromInput(input)if mouse[input.UserInputType]then return mouse[input.
UserInputType]end if input.KeyCode~=Enum.KeyCode.Unknown then local t=input.
UserInputType if t==Enum.UserInputType.Keyboard or t==Enum.UserInputType.
Gamepad1 then return input.KeyCode.Name end end return nil end local modifierOf=
{LeftControl='Ctrl',RightControl='Ctrl',LeftShift='Shift',RightShift='Shift',
LeftAlt='Alt',RightAlt='Alt'}local modifierKeys={Ctrl={Enum.KeyCode.LeftControl,
Enum.KeyCode.RightControl},Shift={Enum.KeyCode.LeftShift,Enum.KeyCode.RightShift
},Alt={Enum.KeyCode.LeftAlt,Enum.KeyCode.RightAlt}}local modifierOrder={'Ctrl',
'Shift','Alt'}function Keys.IsModifier(name)return modifierOf[name]~=nil end
local function held(mod)local UIS=game:GetService('UserInputService')for _,code
in modifierKeys[mod]do if UIS:IsKeyDown(code)then return true end end return
false end function Keys.Combo(main)if modifierOf[main]then return main end local
parts={}for _,mod in modifierOrder do if held(mod)then table.insert(parts,mod)
end end table.insert(parts,main)return table.concat(parts,'+')end function Keys.
MainKey(value)return string.match(value or'','([^+]+)$')or'None'end function
Keys.MatchesCombo(value,pressed)if not value or value=='None'then return false
end if Keys.MainKey(value)~=pressed then return false end for mod in string.
gmatch(value,'([^+]+)%+')do if modifierKeys[mod]and not held(mod)then return
false end end return true end function Keys.Normalize(value)if type(value)==
'string'and string.find(value,'+',2,true)then local parts=string.split(value,'+'
)local main=Keys.Normalize(parts[#parts])if main=='None'then return'None'end
local mods={}for i=1,#parts-1 do local m=string.lower(parts[i])if m=='ctrl'or m
=='control'then mods.Ctrl=true elseif m=='shift'then mods.Shift=true elseif m==
'alt'then mods.Alt=true end end local out={}for _,mod in modifierOrder do if
mods[mod]then table.insert(out,mod)end end table.insert(out,main)return table.
concat(out,'+')end return Keys.NormalizeSingle(value)end function Keys.
NormalizeSingle(value)if value==nil or value==false or value==''or value=='None'
or value=='-'then return'None'end if typeof(value)=='EnumItem'then if value.
EnumType==Enum.UserInputType then return mouse[value]or'None'end return value.
Name end value=tostring(value)if mouseReverse[value]then return value end local
ok,code=pcall(function()return Enum.KeyCode[value]end)if ok and code then return
code.Name end for long,s in short do if string.lower(s)==string.lower(value)then
return long end end return'None'end function Keys.Display(name)if not name or
name=='None'then return'None'end if string.find(name,'+',2,true)then local parts
=string.split(name,'+')parts[#parts]=short[parts[#parts] ]or parts[#parts]return
table.concat(parts,'+')end return short[name]or name end function Keys.Matches(
name,input)return name~='None'and Keys.FromInput(input)==name end function Keys.
ToEnum(name)if mouseReverse[name]then return mouseReverse[name]end local ok,code
=pcall(function()return Enum.KeyCode[name]end)return ok and code or nil end
return Keys end function __DARKLUA_BUNDLE_MODULES.f()local v=
__DARKLUA_BUNDLE_MODULES.cache.f if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.f=v end return v.c end end do local function 
__modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Signal=
__DARKLUA_BUNDLE_MODULES.b()local Tween=__DARKLUA_BUNDLE_MODULES.d()local Theme=
{}local rgb=Color3.fromRGB local base={Bg=rgb(6,6,7),Bg2=rgb(9,9,10),Surface=
rgb(12,12,13),Surface2=rgb(17,17,19),Surface3=rgb(23,23,26),Elevated=rgb(20,20,
22),Stroke=rgb(30,30,34),StrokeHi=rgb(48,48,54),Text=rgb(240,240,242),TextDim=
rgb(152,152,160),TextMute=rgb(92,92,100),Accent=rgb(255,255,255),AccentInk=rgb(8
,8,9),Risky=rgb(232,76,84),Success=rgb(120,220,160),Warning=rgb(240,196,110),
Error=rgb(232,76,84),Info=rgb(200,210,230),Shadow=rgb(0,0,0)}Theme.Presets={
Eclipse={},OLED={Bg=rgb(0,0,0),Bg2=rgb(2,2,2),Surface=rgb(6,6,6),Surface2=rgb(12
,12,12),Surface3=rgb(18,18,18),Elevated=rgb(12,12,12),Stroke=rgb(24,24,24)},
Graphite={Bg=rgb(12,12,14),Bg2=rgb(15,15,17),Surface=rgb(18,18,21),Surface2=rgb(
24,24,28),Surface3=rgb(31,31,36),Elevated=rgb(27,27,31),Stroke=rgb(38,38,44),
StrokeHi=rgb(58,58,66),Accent=rgb(214,214,220)},Moon={Accent=rgb(226,236,255),
Text=rgb(236,241,250),TextDim=rgb(146,154,172),Stroke=rgb(28,31,38),StrokeHi=
rgb(46,52,64)},Ash={Accent=rgb(255,244,230),Text=rgb(246,242,236),TextDim=rgb(
160,154,146),Stroke=rgb(34,31,29),StrokeHi=rgb(54,50,46)},Steel={Bg=rgb(7,8,10),
Surface=rgb(12,14,17),Surface2=rgb(17,20,24),Surface3=rgb(23,27,32),Elevated=
rgb(19,22,26),Stroke=rgb(29,34,40),StrokeHi=rgb(46,54,64),Accent=rgb(205,222,240
)}}Theme.Order={'Eclipse','OLED','Graphite','Moon','Ash','Steel'}Theme.Current=
'Eclipse'Theme.Tokens=table.clone(base)Theme.Changed=Signal.new()local SANS=
'rbxasset://fonts/families/BuilderSans.json'local MONO=
'rbxasset://fonts/families/RobotoMono.json'Theme.Fonts={Regular=Font.new(SANS,
Enum.FontWeight.Regular),Medium=Font.new(SANS,Enum.FontWeight.Medium),SemiBold=
Font.new(SANS,Enum.FontWeight.SemiBold),Bold=Font.new(SANS,Enum.FontWeight.Bold)
,Heavy=Font.new(SANS,Enum.FontWeight.ExtraBold),Mono=Font.new(MONO,Enum.
FontWeight.Regular),MonoBold=Font.new(MONO,Enum.FontWeight.Medium)}function
Theme.SetFont(family)for name,font in Theme.Fonts do if not string.find(name,
'Mono')then Theme.Fonts[name]=Font.new(family,font.Weight)end end end Theme.
FontFolder='Proximity/Fonts'Theme.FontBaseUrl=
[[https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/assets/fonts/]]
Theme.CustomFonts={['Minecraft (Monocraft)']={'Monocraft.ttf',
'Monocraft-Bold.ttf'},['VT323 (terminal)']={'VT323-Regular.ttf'},[
'Silkscreen (pixel)']={'Silkscreen-Regular.ttf'},['Russo One']={
'RussoOne-Regular.ttf'},['Space Mono']={'SpaceMono-Regular.ttf'},['Audiowide']={
'Audiowide-Regular.ttf'},['Rajdhani']={'Rajdhani-SemiBold.ttf'},[
'Share Tech Mono']={'ShareTechMono-Regular.ttf'},['Righteous']={
'Righteous-Regular.ttf'}}local builtinFamilies=nil local function scanBuiltins()
if builtinFamilies then return builtinFamilies end builtinFamilies={}for nice,
file in{['Press Start 2P']='PressStart2P',['Builder Sans']='BuilderSans',[
'Builder Mono']='BuilderMono'}do builtinFamilies[nice]=
'rbxasset://fonts/families/'..file..'.json'end for _,item in Enum.Font:
GetEnumItems()do local ok,font=pcall(Font.fromEnum,item)if ok and font then
local family=font.Family local file=string.match(family,'families/(.-)%.json$')
if file and not string.find(file,'Legacy')and file~='Unknown'then local nice=
string.gsub(file,'(%l)(%u)','%1 %2')builtinFamilies[nice]=family end end end
return builtinFamilies end function Theme.FontList()local out={}for name in
scanBuiltins()do table.insert(out,name)end for name in Theme.CustomFonts do
table.insert(out,name)end table.sort(out)return out end local resolved={}
function Theme.ResolveFamily(name)if resolved[name]then return resolved[name]end
local builtin=scanBuiltins()[name]if builtin then resolved[name]=builtin return
builtin end local files=Theme.CustomFonts[name]local Env=
__DARKLUA_BUNDLE_MODULES.e()if not files or not Env.Caps.CustomAsset then return
nil end local faces={}for i,file in files do local path=Theme.FontFolder..'/'..
file if not Env.IsFile(path)then local body for attempt=1,3 do body=Env.HttpGet(
Theme.FontBaseUrl..file)if body and#body>1000 then break end task.wait(attempt)
end if not body or#body<1000 then return nil end Env.Write(path,body)end local
asset=Env.CustomAsset(path)if not asset then return nil end if i==1 then for _,w
in{{'Regular',400},{'Medium',500},{'SemiBold',600}}do table.insert(faces,{name=w
[1],weight=w[2],style='normal',assetId=asset})end if not files[2]then table.
insert(faces,{name='Bold',weight=700,style='normal',assetId=asset})table.insert(
faces,{name='ExtraBold',weight=800,style='normal',assetId=asset})end else table.
insert(faces,{name='Bold',weight=700,style='normal',assetId=asset})table.insert(
faces,{name='ExtraBold',weight=800,style='normal',assetId=asset})end end local
jsonPath=Theme.FontFolder..'/'..string.gsub(name,'[^%w]','')..'.json'Env.Write(
jsonPath,game:GetService('HttpService'):JSONEncode({name=name,faces=faces}))
local family=Env.CustomAsset(jsonPath)resolved[name]=family return family end
Theme.FontName='Builder Sans'function Theme.ApplyFont(name,root)local family=
Theme.ResolveFamily(name)if not family then return false end local old=Theme.
Fonts.Regular.Family Theme.SetFont(family)Theme.FontName=name if root then for _
,d in root:GetDescendants()do if d:IsA('TextLabel')or d:IsA('TextButton')or d:
IsA('TextBox')then local f=d.FontFace if f.Family==old then d.FontFace=Font.new(
family,f.Weight,f.Style)end end end end return true end Theme.Size={Tiny=10,
Small=11,Body=13,Title=14,Header=16,Display=22}local bindings=setmetatable({},{
__mode='k'})function Theme.Get(token)return Theme.Tokens[token]or base[token]or
Color3.new(1,0,1)end function Theme.Paint(instance,map,time)local current=
bindings[instance]if not current then current={}bindings[instance]=current end
local goal={}for prop,token in map do if typeof(token)=='Color3'then current[
prop]=nil goal[prop]=token else current[prop]=token goal[prop]=Theme.Get(token)
end end if time and time>0 then Tween.Play(instance,goal,time)else for prop,
value in goal do instance[prop]=value end end return instance end function Theme
.Unbind(instance)bindings[instance]=nil end local function repaint(time)for
instance,map in bindings do if instance.Parent~=nil then local goal={}for prop,
token in map do goal[prop]=Theme.Get(token)end if time>0 then Tween.Play(
instance,goal,time,Enum.EasingStyle.Sine)else for prop,value in goal do instance
[prop]=value end end end end end function Theme.Set(spec,animate)local tokens=
table.clone(base)if type(spec)=='string'then local preset=Theme.Presets[spec]if
not preset then warn("[Proximity] unknown theme '"..spec.."'")return false end
for k,v in preset do tokens[k]=v end Theme.Current=spec elseif type(spec)==
'table'then for k,v in Theme.Tokens do tokens[k]=v end for k,v in spec do local
color=Util.ToColor(v)if color then tokens[k]=color end end Theme.Current=spec.
Name or'Custom'end Theme.Tokens=tokens repaint(animate==false and 0 or 0.35)
Theme.Changed:Fire(Theme.Current,Theme.Tokens)return true end function Theme.
SetToken(token,color,animate)return Theme.Set({[token]=color,Name=Theme.Current}
,animate)end function Theme.Register(name,tokens)local preset={}for k,v in
tokens do preset[k]=Util.ToColor(v)end Theme.Presets[name]=preset if not table.
find(Theme.Order,name)then table.insert(Theme.Order,name)end end function Theme.
Export()local out={}for k,v in Theme.Tokens do out[k]=Util.ToHex(v)end return
game:GetService('HttpService'):JSONEncode(out)end function Theme.Import(json)
local ok,data=pcall(function()return game:GetService('HttpService'):JSONDecode(
json)end)if not ok or type(data)~='table'then return false end return Theme.Set(
data)end function Theme.List()return table.clone(Theme.Order)end return Theme
end function __DARKLUA_BUNDLE_MODULES.g()local v=__DARKLUA_BUNDLE_MODULES.cache.
g if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.g=v end return v
.c end end do local function __modImpl()return{['accessibility']=10709751939,[
'activity']=10709752035,['air-vent']=10709752131,['airplay']=10709752254,[
'alarm-check']=10709752405,['alarm-clock']=10709752630,['alarm-clock-off']=
10709752508,['alarm-minus']=10709752732,['alarm-plus']=10709752825,['album']=
10709752906,['alert-circle']=10709752996,['alert-octagon']=10709753064,[
'alert-triangle']=10709753149,['align-center']=10709753570,[
'align-center-horizontal']=10709753272,['align-center-vertical']=10709753421,[
'align-end-horizontal']=10709753692,['align-end-vertical']=10709753808,[
'align-horizontal-distribute-center']=10747779791,[
'align-horizontal-distribute-end']=10747784534,[
'align-horizontal-distribute-start']=10709754118,[
'align-horizontal-justify-center']=10709754204,['align-horizontal-justify-end']=
10709754317,['align-horizontal-justify-start']=10709754436,[
'align-horizontal-space-around']=10709754590,['align-horizontal-space-between']=
10709754749,['align-justify']=10709759610,['align-left']=10709759764,[
'align-right']=10709759895,['align-start-horizontal']=10709760051,[
'align-start-vertical']=10709760244,['align-vertical-distribute-center']=
10709760351,['align-vertical-distribute-end']=10709760434,[
'align-vertical-distribute-start']=10709760612,['align-vertical-justify-center']
=10709760814,['align-vertical-justify-end']=10709761003,[
'align-vertical-justify-start']=10709761176,['align-vertical-space-around']=
10709761324,['align-vertical-space-between']=10709761434,['anchor']=10709761530,
['angry']=10709761629,['annoyed']=10709761722,['aperture']=10709761813,['apple']
=10709761889,['archive']=10709762233,['archive-restore']=10709762058,['armchair'
]=10709762327,['arrow-big-down']=10747796644,['arrow-big-left']=10709762574,[
'arrow-big-right']=10709762727,['arrow-big-up']=10709762879,['arrow-down']=
10709767827,['arrow-down-circle']=10709763034,['arrow-down-left']=10709767656,[
'arrow-down-right']=10709767750,['arrow-left']=10709768114,['arrow-left-circle']
=10709767936,['arrow-left-right']=10709768019,['arrow-right']=10709768347,[
'arrow-right-circle']=10709768226,['arrow-up']=10709768939,['arrow-up-circle']=
10709768432,['arrow-up-down']=10709768538,['arrow-up-left']=10709768661,[
'arrow-up-right']=10709768787,['asterisk']=10709769095,['at-sign']=10709769286,[
'award']=10709769406,['axe']=10709769508,['axis-3d']=10709769598,['baby']=
10709769732,['backpack']=10709769841,['baggage-claim']=10709769935,['banana']=
10709770005,['banknote']=10709770178,['bar-chart']=10709773755,['bar-chart-2']=
10709770317,['bar-chart-3']=10709770431,['bar-chart-4']=10709770560,[
'bar-chart-horizontal']=10709773669,['barcode']=10747360675,['baseline']=
10709773863,['bath']=10709773963,['battery']=10709774640,['battery-charging']=
10709774068,['battery-full']=10709774206,['battery-low']=10709774370,[
'battery-medium']=10709774513,['beaker']=10709774756,['bed']=10709775036,[
'bed-double']=10709774864,['bed-single']=10709774968,['beer']=10709775167,[
'bell']=10709775704,['bell-minus']=10709775241,['bell-off']=10709775320,[
'bell-plus']=10709775448,['bell-ring']=10709775560,['bike']=10709775894,[
'binary']=10709776050,['bitcoin']=10709776126,['bluetooth']=10709776655,[
'bluetooth-connected']=10709776240,['bluetooth-off']=10709776344,[
'bluetooth-searching']=10709776501,['bold']=10747813908,['bomb']=10709781460,[
'bone']=10709781605,['book']=10709781824,['book-open']=10709781717,['bookmark']=
10709782154,['bookmark-minus']=10709781919,['bookmark-plus']=10709782044,['bot']
=10709782230,['box']=10709782497,['box-select']=10709782342,['boxes']=
10709782582,['briefcase']=10709782662,['brush']=10709782758,['bug']=10709782845,
['building']=10709783051,['building-2']=10709782939,['bus']=10709783137,['cake']
=10709783217,['calculator']=10709783311,['calendar']=10709789505,[
'calendar-check']=10709783474,['calendar-check-2']=10709783392,['calendar-clock'
]=10709783577,['calendar-days']=10709783673,['calendar-heart']=10709783835,[
'calendar-minus']=10709783959,['calendar-off']=10709788784,['calendar-plus']=
10709788937,['calendar-range']=10709789053,['calendar-search']=10709789200,[
'calendar-x']=10709789407,['calendar-x-2']=10709789329,['camera']=10709789686,[
'camera-off']=10747822677,['car']=10709789810,['carrot']=10709789960,['cast']=
10709790097,['charge']=10709790202,['check']=10709790644,['check-circle']=
10709790387,['check-circle-2']=10709790298,['check-square']=10709790537,[
'chef-hat']=10709790757,['cherry']=10709790875,['chevron-down']=10709790948,[
'chevron-first']=10709791015,['chevron-last']=10709791130,['chevron-left']=
10709791281,['chevron-right']=10709791437,['chevron-up']=10709791523,[
'chevrons-down']=10709796864,['chevrons-down-up']=10709791632,['chevrons-left']=
10709797151,['chevrons-left-right']=10709797006,['chevrons-right']=10709797382,[
'chevrons-right-left']=10709797274,['chevrons-up']=10709797622,[
'chevrons-up-down']=10709797508,['chrome']=10709797725,['circle']=10709798174,[
'circle-dot']=10709797837,['circle-ellipsis']=10709797985,['circle-slashed']=
10709798100,['citrus']=10709798276,['clapperboard']=10709798350,['clipboard']=
10709799288,['clipboard-check']=10709798443,['clipboard-copy']=10709798574,[
'clipboard-edit']=10709798682,['clipboard-list']=10709798792,[
'clipboard-signature']=10709798890,['clipboard-type']=10709798999,['clipboard-x'
]=10709799124,['clock']=10709805144,['clock-1']=10709799535,['clock-10']=
10709799718,['clock-11']=10709799818,['clock-12']=10709799962,['clock-2']=
10709803876,['clock-3']=10709803989,['clock-4']=10709804164,['clock-5']=
10709804291,['clock-6']=10709804435,['clock-7']=10709804599,['clock-8']=
10709804784,['clock-9']=10709804996,['cloud']=10709806740,['cloud-cog']=
10709805262,['cloud-drizzle']=10709805371,['cloud-fog']=10709805477,[
'cloud-hail']=10709805596,['cloud-lightning']=10709805727,['cloud-moon']=
10709805942,['cloud-moon-rain']=10709805838,['cloud-off']=10709806060,[
'cloud-rain']=10709806277,['cloud-rain-wind']=10709806166,['cloud-snow']=
10709806374,['cloud-sun']=10709806631,['cloud-sun-rain']=10709806475,['cloudy']=
10709806859,['clover']=10709806995,['code']=10709810463,['code-2']=10709807111,[
'codepen']=10709810534,['codesandbox']=10709810676,['coffee']=10709810814,['cog'
]=10709810948,['coins']=10709811110,['columns']=10709811261,['command']=
10709811365,['compass']=10709811445,['component']=10709811595,['concierge-bell']
=10709811706,['connection']=10747361219,['contact']=10709811834,['contrast']=
10709811939,['cookie']=10709812067,['copy']=10709812159,['copyleft']=10709812251
,['copyright']=10709812311,['corner-down-left']=10709812396,['corner-down-right'
]=10709812485,['corner-left-down']=10709812632,['corner-left-up']=10709812784,[
'corner-right-down']=10709812939,['corner-right-up']=10709813094,[
'corner-up-left']=10709813185,['corner-up-right']=10709813281,['cpu']=
10709813383,['croissant']=10709818125,['crop']=10709818245,['cross']=10709818399
,['crosshair']=10709818534,['crown']=10709818626,['cup-soda']=10709818763,[
'curly-braces']=10709818847,['currency']=10709818931,['database']=10709818996,[
'delete']=10709819059,['diamond']=10709819149,['dice-1']=10709819266,['dice-2']=
10709819361,['dice-3']=10709819508,['dice-4']=10709819670,['dice-5']=10709819801
,['dice-6']=10709819896,['dices']=10723343321,['diff']=10723343416,['disc']=
10723343537,['divide']=10723343805,['divide-circle']=10723343636,[
'divide-square']=10723343737,['dollar-sign']=10723343958,['download']=
10723344270,['download-cloud']=10723344088,['droplet']=10723344432,['droplets']=
10734883356,['drumstick']=10723344737,['edit']=10734883598,['edit-2']=
10723344885,['edit-3']=10723345088,['egg']=10723345518,['egg-fried']=10723345347
,['electricity']=10723345749,['electricity-off']=10723345643,['equal']=
10723345990,['equal-not']=10723345866,['eraser']=10723346158,['euro']=
10723346372,['expand']=10723346553,['external-link']=10723346684,['eye']=
10723346959,['eye-off']=10723346871,['factory']=10723347051,['fan']=10723354359,
['fast-forward']=10723354521,['feather']=10723354671,['figma']=10723354801,[
'file']=10723374641,['file-archive']=10723354921,['file-audio']=10723355148,[
'file-audio-2']=10723355026,['file-axis-3d']=10723355272,['file-badge']=
10723355622,['file-badge-2']=10723355451,['file-bar-chart']=10723355887,[
'file-bar-chart-2']=10723355746,['file-box']=10723355989,['file-check']=
10723356210,['file-check-2']=10723356100,['file-clock']=10723356329,['file-code'
]=10723356507,['file-cog']=10723356830,['file-cog-2']=10723356676,['file-diff']=
10723357039,['file-digit']=10723357151,['file-down']=10723357322,['file-edit']=
10723357495,['file-heart']=10723357637,['file-image']=10723357790,['file-input']
=10723357933,['file-json']=10723364435,['file-json-2']=10723364361,['file-key']=
10723364605,['file-key-2']=10723364515,['file-line-chart']=10723364725,[
'file-lock']=10723364957,['file-lock-2']=10723364861,['file-minus']=10723365254,
['file-minus-2']=10723365086,['file-output']=10723365457,['file-pie-chart']=
10723365598,['file-plus']=10723365877,['file-plus-2']=10723365766,[
'file-question']=10723365987,['file-scan']=10723366167,['file-search']=
10723366550,['file-search-2']=10723366340,['file-signature']=10723366741,[
'file-spreadsheet']=10723366962,['file-symlink']=10723367098,['file-terminal']=
10723367244,['file-text']=10723367380,['file-type']=10723367606,['file-type-2']=
10723367509,['file-up']=10723367734,['file-video']=10723373884,['file-video-2']=
10723367834,['file-volume']=10723374172,['file-volume-2']=10723374030,[
'file-warning']=10723374276,['file-x']=10723374544,['file-x-2']=10723374378,[
'files']=10723374759,['film']=10723374981,['filter']=10723375128,['fingerprint']
=10723375250,['flag']=10723375890,['flag-off']=10723375443,['flag-triangle-left'
]=10723375608,['flag-triangle-right']=10723375727,['flame']=10723376114,[
'flashlight']=10723376471,['flashlight-off']=10723376365,['flask-conical']=
10734883986,['flask-round']=10723376614,['flip-horizontal']=10723376884,[
'flip-horizontal-2']=10723376745,['flip-vertical']=10723377138,[
'flip-vertical-2']=10723377026,['flower']=10747830374,['flower-2']=10723377305,[
'focus']=10723377537,['folder']=10723387563,['folder-archive']=10723384478,[
'folder-check']=10723384605,['folder-clock']=10723384731,['folder-closed']=
10723384893,['folder-cog']=10723385213,['folder-cog-2']=10723385036,[
'folder-down']=10723385338,['folder-edit']=10723385445,['folder-heart']=
10723385545,['folder-input']=10723385721,['folder-key']=10723385848,[
'folder-lock']=10723386005,['folder-minus']=10723386127,['folder-open']=
10723386277,['folder-output']=10723386386,['folder-plus']=10723386531,[
'folder-search']=10723386787,['folder-search-2']=10723386674,['folder-symlink']=
10723386930,['folder-tree']=10723387085,['folder-up']=10723387265,['folder-x']=
10723387448,['folders']=10723387721,['form-input']=10723387841,['forward']=
10723388016,['frame']=10723394389,['framer']=10723394565,['frown']=10723394681,[
'fuel']=10723394846,['function-square']=10723395041,['gamepad']=10723395457,[
'gamepad-2']=10723395215,['gauge']=10723395708,['gavel']=10723395896,['gem']=
10723396000,['ghost']=10723396107,['gift']=10723396402,['gift-card']=10723396225
,['git-branch']=10723396676,['git-branch-plus']=10723396542,['git-commit']=
10723396812,['git-compare']=10723396954,['git-fork']=10723397049,['git-merge']=
10723397165,['git-pull-request']=10723397431,['git-pull-request-closed']=
10723397268,['git-pull-request-draft']=10734884302,['glass']=10723397788,[
'glass-2']=10723397529,['glass-water']=10723397678,['glasses']=10723397895,[
'globe']=10723404337,['globe-2']=10723398002,['grab']=10723404472,[
'graduation-cap']=10723404691,['grape']=10723404822,['grid']=10723404936,[
'grip-horizontal']=10723405089,['grip-vertical']=10723405236,['hammer']=
10723405360,['hand']=10723405649,['hand-metal']=10723405508,['hard-drive']=
10723405749,['hard-hat']=10723405859,['hash']=10723405975,['haze']=10723406078,[
'headphones']=10723406165,['heart']=10723406885,['heart-crack']=10723406299,[
'heart-handshake']=10723406480,['heart-off']=10723406662,['heart-pulse']=
10723406795,['help-circle']=10723406988,['hexagon']=10723407092,['highlighter']=
10723407192,['history']=10723407335,['home']=10723407389,['hourglass']=
10723407498,['ice-cream']=10723414308,['image']=10723415040,['image-minus']=
10723414487,['image-off']=10723414677,['image-plus']=10723414827,['import']=
10723415205,['inbox']=10723415335,['indent']=10723415494,['indian-rupee']=
10723415642,['infinity']=10723415766,['info']=10723415903,['inspect']=
10723416057,['italic']=10723416195,['japanese-yen']=10723416363,['joystick']=
10723416527,['key']=10723416652,['keyboard']=10723416765,['lamp']=10723417513,[
'lamp-ceiling']=10723416922,['lamp-desk']=10723417016,['lamp-floor']=10723417131
,['lamp-wall-down']=10723417240,['lamp-wall-up']=10723417356,['landmark']=
10723417608,['languages']=10723417703,['laptop']=10723423881,['laptop-2']=
10723417797,['lasso']=10723424235,['lasso-select']=10723424058,['laugh']=
10723424372,['layers']=10723424505,['layout']=10723425376,['layout-dashboard']=
10723424646,['layout-grid']=10723424838,['layout-list']=10723424963,[
'layout-template']=10723425187,['leaf']=10723425539,['library']=10723425615,[
'life-buoy']=10723425685,['lightbulb']=10723425852,['lightbulb-off']=10723425762
,['line-chart']=10723426393,['link']=10723426722,['link-2']=10723426595,[
'link-2-off']=10723426513,['list']=10723433811,['list-checks']=10734884548,[
'list-end']=10723426886,['list-minus']=10723426986,['list-music']=10723427081,[
'list-ordered']=10723427199,['list-plus']=10723427334,['list-start']=10723427494
,['list-video']=10723427619,['list-x']=10723433655,['loader']=10723434070,[
'loader-2']=10723433935,['locate']=10723434557,['locate-fixed']=10723434236,[
'locate-off']=10723434379,['lock']=10723434711,['log-in']=10723434830,['log-out'
]=10723434906,['luggage']=10723434993,['magnet']=10723435069,['mail']=
10734885430,['mail-check']=10723435182,['mail-minus']=10723435261,['mail-open']=
10723435342,['mail-plus']=10723435443,['mail-question']=10723435515,[
'mail-search']=10734884739,['mail-warning']=10734885015,['mail-x']=10734885247,[
'mails']=10734885614,['map']=10734886202,['map-pin']=10734886004,['map-pin-off']
=10734885803,['maximize']=10734886735,['maximize-2']=10734886496,['medal']=
10734887072,['megaphone']=10734887454,['megaphone-off']=10734887311,['meh']=
10734887603,['menu']=10734887784,['message-circle']=10734888000,[
'message-square']=10734888228,['mic']=10734888864,['mic-2']=10734888430,[
'mic-off']=10734888646,['microscope']=10734889106,['microwave']=10734895076,[
'milestone']=10734895310,['minimize']=10734895698,['minimize-2']=10734895530,[
'minus']=10734896206,['minus-circle']=10734895856,['minus-square']=10734896029,[
'monitor']=10734896881,['monitor-off']=10734896360,['monitor-speaker']=
10734896512,['moon']=10734897102,['more-horizontal']=10734897250,[
'more-vertical']=10734897387,['mountain']=10734897956,['mountain-snow']=
10734897665,['mouse']=10734898592,['mouse-pointer']=10734898476,[
'mouse-pointer-2']=10734898194,['mouse-pointer-click']=10734898355,['move']=
10734900011,['move-3d']=10734898756,['move-diagonal']=10734899164,[
'move-diagonal-2']=10734898934,['move-horizontal']=10734899414,['move-vertical']
=10734899821,['music']=10734905958,['music-2']=10734900215,['music-3']=
10734905665,['music-4']=10734905823,['navigation']=10734906744,['navigation-2']=
10734906332,['navigation-2-off']=10734906144,['navigation-off']=10734906580,[
'network']=10734906975,['newspaper']=10734907168,['octagon']=10734907361,[
'option']=10734907649,['outdent']=10734907933,['package']=10734909540,[
'package-2']=10734908151,['package-check']=10734908384,['package-minus']=
10734908626,['package-open']=10734908793,['package-plus']=10734909016,[
'package-search']=10734909196,['package-x']=10734909375,['paint-bucket']=
10734909847,['paintbrush']=10734910187,['paintbrush-2']=10734910030,['palette']=
10734910430,['palmtree']=10734910680,['paperclip']=10734910927,['party-popper']=
10734918735,['pause']=10734919336,['pause-circle']=10735024209,['pause-octagon']
=10734919143,['pen-tool']=10734919503,['pencil']=10734919691,['percent']=
10734919919,['person-standing']=10734920149,['phone']=10734921524,['phone-call']
=10734920305,['phone-forwarded']=10734920508,['phone-incoming']=10734920694,[
'phone-missed']=10734920845,['phone-off']=10734921077,['phone-outgoing']=
10734921288,['pie-chart']=10734921727,['piggy-bank']=10734921935,['pin']=
10734922324,['pin-off']=10734922180,['pipette']=10734922497,['pizza']=
10734922774,['plane']=10734922971,['play']=10734923549,['play-circle']=
10734923214,['plus']=10734924532,['plus-circle']=10734923868,['plus-square']=
10734924219,['podcast']=10734929553,['pointer']=10734929723,['pound-sterling']=
10734929981,['power']=10734930466,['power-off']=10734930257,['printer']=
10734930632,['puzzle']=10734930886,['quote']=10734931234,['radio']=10734931596,[
'radio-receiver']=10734931402,['rectangle-horizontal']=10734931777,[
'rectangle-vertical']=10734932081,['recycle']=10734932295,['redo']=10734932822,[
'redo-2']=10734932586,['refresh-ccw']=10734933056,['refresh-cw']=10734933222,[
'refrigerator']=10734933465,['regex']=10734933655,['repeat']=10734933966,[
'repeat-1']=10734933826,['reply']=10734934252,['reply-all']=10734934132,[
'rewind']=10734934347,['rocket']=10734934585,['rocking-chair']=10734939942,[
'rotate-3d']=10734940107,['rotate-ccw']=10734940376,['rotate-cw']=10734940654,[
'rss']=10734940825,['ruler']=10734941018,['russian-ruble']=10734941199,[
'sailboat']=10734941354,['save']=10734941499,['scale']=10734941912,['scale-3d']=
10734941739,['scaling']=10734942072,['scan']=10734942565,['scan-face']=
10734942198,['scan-line']=10734942351,['scissors']=10734942778,['screen-share']=
10734943193,['screen-share-off']=10734942967,['scroll']=10734943448,['search']=
10734943674,['send']=10734943902,['separator-horizontal']=10734944115,[
'separator-vertical']=10734944326,['server']=10734949856,['server-cog']=
10734944444,['server-crash']=10734944554,['server-off']=10734944668,['settings']
=10734950309,['settings-2']=10734950020,['share']=10734950813,['share-2']=
10734950553,['sheet']=10734951038,['shield']=10734951847,['shield-alert']=
10734951173,['shield-check']=10734951367,['shield-close']=10734951535,[
'shield-off']=10734951684,['shirt']=10734952036,['shopping-bag']=10734952273,[
'shopping-cart']=10734952479,['shovel']=10734952773,['shower-head']=10734952942,
['shrink']=10734953073,['shrub']=10734953241,['shuffle']=10734953451,['sidebar']
=10734954301,['sidebar-close']=10734953715,['sidebar-open']=10734954000,['sigma'
]=10734954538,['signal']=10734961133,['signal-high']=10734954807,['signal-low']=
10734955080,['signal-medium']=10734955336,['signal-zero']=10734960878,['siren']=
10734961284,['skip-back']=10734961526,['skip-forward']=10734961809,['skull']=
10734962068,['slack']=10734962339,['slash']=10734962600,['slice']=10734963024,[
'sliders']=10734963400,['sliders-horizontal']=10734963191,['smartphone']=
10734963940,['smartphone-charging']=10734963671,['smile']=10734964441,[
'smile-plus']=10734964188,['snowflake']=10734964600,['sofa']=10734964852,[
'sort-asc']=10734965115,['sort-desc']=10734965287,['speaker']=10734965419,[
'sprout']=10734965572,['square']=10734965702,['star']=10734966248,['star-half']=
10734965897,['star-off']=10734966097,['stethoscope']=10734966384,['sticker']=
10734972234,['sticky-note']=10734972463,['stop-circle']=10734972621,[
'stretch-horizontal']=10734972862,['stretch-vertical']=10734973130,[
'strikethrough']=10734973290,['subscript']=10734973457,['sun']=10734974297,[
'sun-dim']=10734973645,['sun-medium']=10734973778,['sun-moon']=10734973999,[
'sun-snow']=10734974130,['sunrise']=10734974522,['sunset']=10734974689,[
'superscript']=10734974850,['swiss-franc']=10734975024,['switch-camera']=
10734975214,['sword']=10734975486,['swords']=10734975692,['syringe']=10734975932
,['table']=10734976230,['table-2']=10734976097,['tablet']=10734976394,['tag']=
10734976528,['tags']=10734976739,['target']=10734977012,['tent']=10734981750,[
'terminal']=10734982144,['terminal-square']=10734981995,['text-cursor']=
10734982395,['text-cursor-input']=10734982297,['thermometer']=10734983134,[
'thermometer-snowflake']=10734982571,['thermometer-sun']=10734982771,[
'thumbs-down']=10734983359,['thumbs-up']=10734983629,['ticket']=10734983868,[
'timer']=10734984606,['timer-off']=10734984138,['timer-reset']=10734984355,[
'toggle-left']=10734984834,['toggle-right']=10734985040,['tornado']=10734985247,
['toy-brick']=10747361919,['train']=10747362105,['trash']=10747362393,['trash-2'
]=10747362241,['tree-deciduous']=10747362534,['tree-pine']=10747362748,['trees']
=10747363016,['trending-down']=10747363205,['trending-up']=10747363465,[
'triangle']=10747363621,['trophy']=10747363809,['truck']=10747364031,['tv']=
10747364593,['tv-2']=10747364302,['type']=10747364761,['umbrella']=10747364971,[
'underline']=10747365191,['undo']=10747365484,['undo-2']=10747365359,['unlink']=
10747365771,['unlink-2']=10747397871,['unlock']=10747366027,['upload']=
10747366434,['upload-cloud']=10747366266,['usb']=10747366606,['user']=
10747373176,['user-check']=10747371901,['user-cog']=10747372167,['user-minus']=
10747372346,['user-plus']=10747372702,['user-x']=10747372992,['users']=
10747373426,['utensils']=10747373821,['utensils-crossed']=10747373629,[
'venetian-mask']=10747374003,['verified']=10747374131,['vibrate']=10747374489,[
'vibrate-off']=10747374269,['video']=10747374938,['video-off']=10747374721,[
'view']=10747375132,['voicemail']=10747375281,['volume']=10747376008,['volume-1'
]=10747375450,['volume-2']=10747375679,['volume-x']=10747375880,['wallet']=
10747376205,['wand']=10747376565,['wand-2']=10747376349,['watch']=10747376722,[
'waves']=10747376931,['webcam']=10747381992,['wifi']=10747382504,['wifi-off']=
10747382268,['wind']=10747382750,['wrap-text']=10747383065,['wrench']=
10747383470,['x']=10747384394,['x-circle']=10747383819,['x-octagon']=10747384037
,['x-square']=10747384217,['zoom-in']=10747384552,['zoom-out']=10747384679}end
function __DARKLUA_BUNDLE_MODULES.h()local v=__DARKLUA_BUNDLE_MODULES.cache.h if
not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.h=v end return v.c
end end do local function __modImpl()local Env=__DARKLUA_BUNDLE_MODULES.e()local
Util=__DARKLUA_BUNDLE_MODULES.a()local Lucide=__DARKLUA_BUNDLE_MODULES.h()local
Icons={CacheFolder='Proximity/Cache'}local custom={}local urlCache={}local
aliases={['home']='home',['main']='home',['dashboard']='layout-dashboard',[
'combat']='swords',['aimbot']='crosshair',['aim']='crosshair',['silent']=
'eye-off',['triggerbot']='mouse-pointer-click',['fov']='circle-dot',['target']=
'target',['targeting']='users',['weapon']='sword',['gun']='crosshair',['melee']=
'axe',['knife']='sword',['recoil']='move-vertical',['spread']='focus',['visuals'
]='eye',['visual']='eye',['esp']='scan',['chams']='person-standing',['box']=
'square',['tracer']='move-diagonal',['tracers']='move-diagonal',['skeleton']=
'bone',['name']='type',['health']='heart',['distance']='ruler',['radar']='radio'
,['world']='globe',['lighting']='sun',['fog']='cloud-fog',['time']='clock',[
'weather']='cloud-rain',['fullbright']='sun-medium',['player']='user',['players'
]='users',['movement']='wind',['speed']='gauge',['walkspeed']='gauge',['jump']=
'arrow-up',['fly']='plane',['noclip']='ghost',['teleport']='map-pin',['tp']=
'map-pin',['spectate']='eye',['camera']='video',['freecam']='camera',['godmode']
='shield',['antiafk']='coffee',['respawn']='rotate-ccw',['farm']='sprout',[
'autofarm']='sprout',['auto']='refresh-cw',['loot']='package',['chest']=
'package-open',['items']='boxes',['inventory']='backpack',['shop']=
'shopping-cart',['merchant']='shopping-bag',['quest']='scroll',['quests']=
'scroll',['boss']='skull',['npc']='bot',['pet']='heart',['fishing']='anchor',[
'mining']='hammer',['server']='server',['servers']='server',['rejoin']=
'refresh-ccw',['serverhop']='shuffle',['hop']='shuffle',['friends']='user-plus',
['chat']='message-square',['webhook']='link',['discord']='message-circle',[
'link']='link',['misc']='layers',['utility']='wrench',['tools']='wrench',[
'script']='code',['scripts']='file-code',['console']='terminal',['log']=
'terminal',['debug']='bug',['settings']='settings',['gear']='settings',['cog']=
'settings',['config']='folder',['configs']='folder',['save']='save',['load']=
'folder-open',['theme']='palette',['appearance']='palette',['keyboard']=
'keyboard',['keybind']='keyboard',['keybinds']='keyboard',['language']=
'languages',['about']='info',['info']='info',['credits']='heart-handshake',[
'premium']='crown',['vip']='crown',['key']='key',['lock']='lock',['unlock']=
'unlock',['favorite']='star',['favorites']='star',['search']='search',['close']=
'x',['minimize']='minus',['check']='check',['warning']='alert-triangle',['error'
]='x-circle',['success']='check-circle',['trash']='trash-2',['copy']='copy',[
'paste']='clipboard',['reset']='rotate-ccw',['power']='power',['unload']='power'
,['planet']='globe-2',['proximity']='globe-2',['backdrop']='star',['rim']=
'circle',['motion']='activity',['scale']='scaling',['transparency']='droplet',[
'accent']='pipette',['notifications']='bell',['watermark']='type',['anonymous']=
'venetian-mask',['editor']='paintbrush',['tour']='map',['export']='upload',[
'import']='download'}local function fromUrl(url)if urlCache[url]then return
urlCache[url]end if not Env.Caps.CustomAsset then return nil end local ext=
string.match(url,'%.(%a+)$')or'png'if ext~='png'and ext~='jpg'and ext~='jpeg'
then ext='png'end local path=Icons.CacheFolder..'/'..Util.Checksum(url)..'.'..
ext if not Env.IsFile(path)then local body=Env.HttpGet(url)if not body or#body<
16 then return nil end Env.Write(path,body)end local asset=Env.CustomAsset(path)
urlCache[url]=asset return asset end function Icons.Get(source)if source==nil or
source==false or source==''then return nil end if type(source)=='number'then
return'rbxassetid://'..source end source=tostring(source)if custom[source]then
return Icons.Get(custom[source])end if string.find(source,'^rbxasset')or string.
find(source,'^rbxthumb')or string.find(source,'^http://www.roblox.com')then
return source end if string.find(source,'^%d+$')then return'rbxassetid://'..
source end if string.find(source,'^https?://')then return fromUrl(source)end
local name=string.lower(string.gsub(source,'^lucide%-',''))name=aliases[name]or
name local id=Lucide[name]if id then return'rbxassetid://'..id end return nil
end function Icons.Register(name,source)custom[name]=source end function Icons.
Has(name)return Icons.Get(name)~=nil end function Icons.List()local out=Util.
Keys(Lucide)for k in custom do table.insert(out,k)end table.sort(out)return out
end function Icons.Preload(names)local list={}for _,name in names do local id=
Icons.Get(name)if id then local img=Instance.new('ImageLabel')img.Image=id table
.insert(list,img)end end task.spawn(function()pcall(function()game:GetService(
'ContentProvider'):PreloadAsync(list)end)for _,img in list do img:Destroy()end
end)end return Icons end function __DARKLUA_BUNDLE_MODULES.i()local v=
__DARKLUA_BUNDLE_MODULES.cache.i if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.i=v end return v.c end end do local function 
__modImpl()local Signal=__DARKLUA_BUNDLE_MODULES.b()local Locale={Current='en',
Changed=Signal.new()}local packs={en={Search='Search',SearchHint=
'Find a feature, tab or action',NoResults='Nothing matches that',Settings=
'Settings',Configs='Configs',Appearance='Appearance',Interface='Interface',Theme
='Theme',Accent='Accent color',Transparency='Glass',Scale='Size',Backdrop=
'Background',Planet='Planet in the corner',Language='Language',MenuKey=
'Menu key',Watermark='Watermark',KeybindList='Active keybinds',ReducedMotion=
'Fewer animations',EclipseRim='Glowing edge',Notifications='Notifications',
NotifyPosition='Notifications corner',Anonymous='Anonymous mode',AnonymousHint=
'Hides your name, avatar and IDs',ShownName='Name to show',ThemeEditor=
'Theme editor',About='About',Executor='Executor',ReplayTour=
'Show the tour again',Folder='Folder',ConfigName='Config name',ConfigList=
'Saved configs',Save='Save',Load='Load',Delete='Delete',Refresh='Refresh',Export
='Copy as text',Import='Paste from text',AutoLoad='Load on start',AutoSave=
'Save automatically',Overwrite='A config called %s already exists. Replace it?',
Changes='%d settings will change:',Unload='Unload',UnloadConfirm=
'This turns every feature off and removes the menu.',Cancel='Cancel',Confirm=
'Yes, do it',Ok='Got it',Reset='Reset',Copy='Copy value',Paste='Paste value',
CopyFlag='Copy flag name',BindKey='Bind a key',Loading='Loading',Preparing=
'Getting things ready',Building='Building',ApplyingConfig='Applying your config'
,Ready='Ready',ShowNow='Show now',Risky='Risky',RiskyConfirm=
'This one can get you noticed. Turn it on anyway?',Locked='Locked',None='None',
Selected='selected',Press='Press a key',Saved='Saved',Loaded='Loaded',Deleted=
'Deleted',Copied='Copied',Imported='Imported',InvalidConfig=
"That doesn't look like a Proximity config",Toggle='Toggle',Hold='Hold',Always=
'Always on',Release='On release',Press_='Press',Mode='Mode',Undo='Undo',Redo=
'Redo',Favorites='Favorites',FavoritesHint=
'Right-click any feature and pick Favorites to pin it here',Commands='Action',
Elements='Feature',Tabs='Tab',Hidden='Menu hidden. Press %s to bring it back',
Empty='Nothing here yet',Hide='Hide menu',Home='Home',KeyTitle='Enter your key',
KeySubtitle='One key per player, it is remembered on this device',KeyPlaceholder
='Paste the key here',GetKey='Get a key',CheckKey='Check',Checking='Checking',
JoinDiscord='Join our Discord',LinkCopied='Link copied, open it in your browser'
,KeyWait='Too many tries. Wait %d s',KeyOk='Key accepted, loading',KeyLocked=
'Too many wrong keys. Try again in %d s',KeyBad=
'That key did not work. Tries left: %d',PlayerPanel='Player',Health='Health',
Speed='Speed',State='State',Position='Position',Performance='Performance',Ping=
'Ping',Stopwatch='Stopwatch',InGame='In game',UpdateTitle='%s update',UpdateBody
='You have %s, version %s is out',EconomyTitle='Saving FPS',EconomyBody=
'FPS dropped, so the stars and the planet are off for now',NotificationCenter=
'Notifications',MiniMode='Mini mode',Unsaved='Unsaved changes',UnsavedHint=
'Changes in %s are not saved yet',WhatsNew="What's new in %s",NoNotifications=
'No notifications yet',ClearAll='Clear all',From='From',To='To',ResetFilters=
'Reset filters',Navigation='Navigation',Sidebar='Sidebar',Rail='Icons only',Font
='Font',FontFailed=
[[This font needs getcustomasset, your executor does not have it]],Density=
'Density',Compact='Compact',Normal='Normal',Comfortable='Roomy',Touch='Touch',
ToggleStyle='Toggle style',BackgroundImage='Background image',BackgroundDim=
'Background dim',WatermarkItems='Watermark shows',ShowInactive=
'Show inactive binds',SortBinds='Sort binds',SortActive='Active first',SortName=
'By name',SortKey='By key',Widgets='Widgets',AutoEconomy=
'Save FPS automatically',AutoEconomyHint='Turns effects off when FPS drops',
ShareCode='Share code',ImportCode='Enter code',CodeCopied=
'Code %s is copied. Send it to a friend',CodeFailed=
'Could not upload. Your executor needs the request function',CodeInvalid=
'That code did not work',Restore='Restore',DeletedHint='%s is deleted',
SaveBeforeUnload='Save changes to %s before unloading?',DontSave="Don't save",
Replaced='Replaced the old copy v%s with v%s',OpenAnimation='Menu animation',
OpenAnimationHint='How the menu appears and hides',AnimPlanet=
'Planet - out of the button',AnimRise='Rise',AnimZoom='Zoom',AnimDrop='Drop',
AnimSlide='Slide',AnimSwing='Swing',AnimWipe='Wipe',AnimUnfold='Unfold',AnimScan
='Scan',AnimGlitch='Glitch',AnimFade='Fade',AnimNone='None',LoadingStyle=
'Loading screen',LoadingStyleHint='Applies the next time the script starts',
LoadingPlanet='Planet',LoadingSkeleton='Menu skeleton',LoadingOrbit='Orbit',
LoadingEclipse='Eclipse',LoadingConstellation='Constellation',LoadingTerminal=
'Terminal',LoadingNone='None'},ru={Search='\u{41f}\u{43e}\u{438}\u{441}\u{43a}',
SearchHint=
'\u{41d}\u{430}\u{439}\u{434}\u{438} \u{444}\u{443}\u{43d}\u{43a}\u{446}\u{438}\u{44e}, \u{432}\u{43a}\u{43b}\u{430}\u{434}\u{43a}\u{443} \u{438}\u{43b}\u{438} \u{434}\u{435}\u{439}\u{441}\u{442}\u{432}\u{438}\u{435}'
,NoResults=
'\u{41d}\u{438}\u{447}\u{435}\u{433}\u{43e} \u{43d}\u{435} \u{43d}\u{430}\u{448}\u{43b}\u{43e}\u{441}\u{44c}'
,Settings='\u{41d}\u{430}\u{441}\u{442}\u{440}\u{43e}\u{439}\u{43a}\u{438}',
Configs='\u{41a}\u{43e}\u{43d}\u{444}\u{438}\u{433}\u{438}',Appearance=
'\u{412}\u{43d}\u{435}\u{448}\u{43d}\u{438}\u{439} \u{432}\u{438}\u{434}',
Interface='\u{418}\u{43d}\u{442}\u{435}\u{440}\u{444}\u{435}\u{439}\u{441}',
Theme='\u{422}\u{435}\u{43c}\u{430}',Accent=
'\u{426}\u{432}\u{435}\u{442} \u{430}\u{43a}\u{446}\u{435}\u{43d}\u{442}\u{430}'
,Transparency=
'\u{41f}\u{440}\u{43e}\u{437}\u{440}\u{430}\u{447}\u{43d}\u{43e}\u{441}\u{442}\u{44c}'
,Scale='\u{420}\u{430}\u{437}\u{43c}\u{435}\u{440}',Backdrop=
'\u{424}\u{43e}\u{43d}',Planet=
'\u{41f}\u{43b}\u{430}\u{43d}\u{435}\u{442}\u{430} \u{432} \u{443}\u{433}\u{43b}\u{443}'
,Language='\u{42f}\u{437}\u{44b}\u{43a}',MenuKey=
'\u{41a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{430} \u{43c}\u{435}\u{43d}\u{44e}'
,Watermark=
'\u{412}\u{43e}\u{442}\u{435}\u{440}\u{43c}\u{430}\u{440}\u{43a}\u{430}',
KeybindList=
'\u{410}\u{43a}\u{442}\u{438}\u{432}\u{43d}\u{44b}\u{435} \u{431}\u{438}\u{43d}\u{434}\u{44b}'
,ReducedMotion=
'\u{41c}\u{435}\u{43d}\u{44c}\u{448}\u{435} \u{430}\u{43d}\u{438}\u{43c}\u{430}\u{446}\u{438}\u{439}'
,EclipseRim=
'\u{421}\u{432}\u{435}\u{442}\u{44f}\u{449}\u{438}\u{439}\u{441}\u{44f} \u{43a}\u{440}\u{430}\u{439}'
,Notifications=
'\u{423}\u{432}\u{435}\u{434}\u{43e}\u{43c}\u{43b}\u{435}\u{43d}\u{438}\u{44f}',
NotifyPosition=
'\u{423}\u{433}\u{43e}\u{43b} \u{443}\u{432}\u{435}\u{434}\u{43e}\u{43c}\u{43b}\u{435}\u{43d}\u{438}\u{439}'
,Anonymous=
'\u{410}\u{43d}\u{43e}\u{43d}\u{438}\u{43c}\u{43d}\u{44b}\u{439} \u{440}\u{435}\u{436}\u{438}\u{43c}'
,AnonymousHint=
'\u{41f}\u{440}\u{44f}\u{447}\u{435}\u{442} \u{43d}\u{438}\u{43a}, \u{430}\u{432}\u{430}\u{442}\u{430}\u{440} \u{438} ID'
,ShownName=
'\u{41a}\u{430}\u{43a}\u{43e}\u{435} \u{438}\u{43c}\u{44f} \u{43f}\u{43e}\u{43a}\u{430}\u{437}\u{44b}\u{432}\u{430}\u{442}\u{44c}'
,ThemeEditor=
'\u{420}\u{435}\u{434}\u{430}\u{43a}\u{442}\u{43e}\u{440} \u{442}\u{435}\u{43c}\u{44b}'
,About='\u{41e} \u{441}\u{43a}\u{440}\u{438}\u{43f}\u{442}\u{435}',Executor=
'\u{42d}\u{43a}\u{437}\u{435}\u{43a}\u{443}\u{442}\u{43e}\u{440}',ReplayTour=
'\u{41f}\u{43e}\u{43a}\u{430}\u{437}\u{430}\u{442}\u{44c} \u{43f}\u{43e}\u{434}\u{441}\u{43a}\u{430}\u{437}\u{43a}\u{438} \u{435}\u{449}\u{451} \u{440}\u{430}\u{437}'
,Folder='\u{41f}\u{430}\u{43f}\u{43a}\u{430}',ConfigName=
'\u{41d}\u{430}\u{437}\u{432}\u{430}\u{43d}\u{438}\u{435}',ConfigList=
'\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{451}\u{43d}\u{43d}\u{44b}\u{435}',
Save='\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{438}\u{442}\u{44c}',Load=
'\u{417}\u{430}\u{433}\u{440}\u{443}\u{437}\u{438}\u{442}\u{44c}',Delete=
'\u{423}\u{434}\u{430}\u{43b}\u{438}\u{442}\u{44c}',Refresh=
'\u{41e}\u{431}\u{43d}\u{43e}\u{432}\u{438}\u{442}\u{44c}',Export=
'\u{421}\u{43a}\u{43e}\u{43f}\u{438}\u{440}\u{43e}\u{432}\u{430}\u{442}\u{44c} \u{442}\u{435}\u{43a}\u{441}\u{442}\u{43e}\u{43c}'
,Import=
'\u{412}\u{441}\u{442}\u{430}\u{432}\u{438}\u{442}\u{44c} \u{438}\u{437} \u{442}\u{435}\u{43a}\u{441}\u{442}\u{430}'
,AutoLoad=
'\u{417}\u{430}\u{433}\u{440}\u{443}\u{436}\u{430}\u{442}\u{44c} \u{43f}\u{440}\u{438} \u{437}\u{430}\u{43f}\u{443}\u{441}\u{43a}\u{435}'
,AutoSave=
'\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{44f}\u{442}\u{44c} \u{441}\u{430}\u{43c}'
,Overwrite=
'\u{41a}\u{43e}\u{43d}\u{444}\u{438}\u{433} %s \u{443}\u{436}\u{435} \u{435}\u{441}\u{442}\u{44c}. \u{417}\u{430}\u{43c}\u{435}\u{43d}\u{438}\u{442}\u{44c} \u{435}\u{433}\u{43e}?'
,Changes=
'\u{418}\u{437}\u{43c}\u{435}\u{43d}\u{438}\u{442}\u{441}\u{44f} \u{43d}\u{430}\u{441}\u{442}\u{440}\u{43e}\u{435}\u{43a}: %d'
,Unload='\u{412}\u{44b}\u{433}\u{440}\u{443}\u{437}\u{438}\u{442}\u{44c}',
UnloadConfirm=
'\u{412}\u{441}\u{435} \u{444}\u{443}\u{43d}\u{43a}\u{446}\u{438}\u{438} \u{432}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{430}\u{442}\u{441}\u{44f}, \u{43c}\u{435}\u{43d}\u{44e} \u{437}\u{430}\u{43a}\u{440}\u{43e}\u{435}\u{442}\u{441}\u{44f}.'
,Cancel='\u{41e}\u{442}\u{43c}\u{435}\u{43d}\u{430}',Confirm='\u{414}\u{430}',Ok
='\u{41f}\u{43e}\u{43d}\u{44f}\u{442}\u{43d}\u{43e}',Reset=
'\u{421}\u{431}\u{440}\u{43e}\u{441}\u{438}\u{442}\u{44c}',Copy=
'\u{421}\u{43a}\u{43e}\u{43f}\u{438}\u{440}\u{43e}\u{432}\u{430}\u{442}\u{44c} \u{437}\u{43d}\u{430}\u{447}\u{435}\u{43d}\u{438}\u{435}'
,Paste=
'\u{412}\u{441}\u{442}\u{430}\u{432}\u{438}\u{442}\u{44c} \u{437}\u{43d}\u{430}\u{447}\u{435}\u{43d}\u{438}\u{435}'
,CopyFlag=
'\u{421}\u{43a}\u{43e}\u{43f}\u{438}\u{440}\u{43e}\u{432}\u{430}\u{442}\u{44c} \u{438}\u{43c}\u{44f} \u{444}\u{43b}\u{430}\u{433}\u{430}'
,BindKey=
'\u{41d}\u{430}\u{437}\u{43d}\u{430}\u{447}\u{438}\u{442}\u{44c} \u{43a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{443}'
,Loading='\u{417}\u{430}\u{433}\u{440}\u{443}\u{437}\u{43a}\u{430}',Preparing=
'\u{413}\u{43e}\u{442}\u{43e}\u{432}\u{438}\u{43c} \u{43c}\u{435}\u{43d}\u{44e}'
,Building='\u{421}\u{43e}\u{431}\u{438}\u{440}\u{430}\u{435}\u{43c}',
ApplyingConfig=
'\u{41f}\u{440}\u{438}\u{43c}\u{435}\u{43d}\u{44f}\u{435}\u{43c} \u{43a}\u{43e}\u{43d}\u{444}\u{438}\u{433}'
,Ready='\u{413}\u{43e}\u{442}\u{43e}\u{432}\u{43e}',ShowNow=
'\u{41f}\u{43e}\u{43a}\u{430}\u{437}\u{430}\u{442}\u{44c} \u{441}\u{440}\u{430}\u{437}\u{443}'
,Risky='\u{420}\u{438}\u{441}\u{43a}',RiskyConfirm=
'\u{42d}\u{442}\u{443} \u{444}\u{443}\u{43d}\u{43a}\u{446}\u{438}\u{44e} \u{43c}\u{43e}\u{433}\u{443}\u{442} \u{437}\u{430}\u{43c}\u{435}\u{442}\u{438}\u{442}\u{44c}. \u{412}\u{441}\u{451} \u{440}\u{430}\u{432}\u{43d}\u{43e} \u{432}\u{43a}\u{43b}\u{44e}\u{447}\u{438}\u{442}\u{44c}?'
,Locked='\u{41d}\u{435}\u{434}\u{43e}\u{441}\u{442}\u{443}\u{43f}\u{43d}\u{43e}'
,None='\u{41d}\u{435}\u{442}',Selected=
'\u{432}\u{44b}\u{431}\u{440}\u{430}\u{43d}\u{43e}',Press=
'\u{41d}\u{430}\u{436}\u{43c}\u{438} \u{43a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{443}'
,Saved='\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{435}\u{43d}\u{43e}',Loaded=
'\u{417}\u{430}\u{433}\u{440}\u{443}\u{436}\u{435}\u{43d}\u{43e}',Deleted=
'\u{423}\u{434}\u{430}\u{43b}\u{435}\u{43d}\u{43e}',Copied=
'\u{421}\u{43a}\u{43e}\u{43f}\u{438}\u{440}\u{43e}\u{432}\u{430}\u{43d}\u{43e}',
Imported=
'\u{418}\u{43c}\u{43f}\u{43e}\u{440}\u{442}\u{438}\u{440}\u{43e}\u{432}\u{430}\u{43d}\u{43e}'
,InvalidConfig=
'\u{42d}\u{442}\u{43e} \u{43d}\u{435} \u{43f}\u{43e}\u{445}\u{43e}\u{436}\u{435} \u{43d}\u{430} \u{43a}\u{43e}\u{43d}\u{444}\u{438}\u{433} Proximity'
,Toggle=
'\u{41f}\u{435}\u{440}\u{435}\u{43a}\u{43b}\u{44e}\u{447}\u{435}\u{43d}\u{438}\u{435}'
,Hold='\u{423}\u{434}\u{435}\u{440}\u{436}\u{430}\u{43d}\u{438}\u{435}',Always=
'\u{412}\u{441}\u{435}\u{433}\u{434}\u{430}',Release=
'\u{41f}\u{440}\u{438} \u{43e}\u{442}\u{43f}\u{443}\u{441}\u{43a}\u{430}\u{43d}\u{438}\u{438}'
,Press_='\u{41d}\u{430}\u{436}\u{430}\u{442}\u{438}\u{435}',Mode=
'\u{420}\u{435}\u{436}\u{438}\u{43c}',Undo=
'\u{41e}\u{442}\u{43c}\u{435}\u{43d}\u{438}\u{442}\u{44c}',Redo=
'\u{412}\u{435}\u{440}\u{43d}\u{443}\u{442}\u{44c}',Favorites=
'\u{418}\u{437}\u{431}\u{440}\u{430}\u{43d}\u{43d}\u{43e}\u{435}',FavoritesHint=
'\u{41f}\u{440}\u{430}\u{432}\u{44b}\u{439} \u{43a}\u{43b}\u{438}\u{43a} \u{43f}\u{43e} \u{444}\u{443}\u{43d}\u{43a}\u{446}\u{438}\u{438} \u{438} \u{43f}\u{443}\u{43d}\u{43a}\u{442} \u{ab}\u{418}\u{437}\u{431}\u{440}\u{430}\u{43d}\u{43d}\u{43e}\u{435}\u{bb} - \u{438} \u{43e}\u{43d}\u{430} \u{43f}\u{43e}\u{44f}\u{432}\u{438}\u{442}\u{441}\u{44f} \u{437}\u{434}\u{435}\u{441}\u{44c}'
,Commands='\u{414}\u{435}\u{439}\u{441}\u{442}\u{432}\u{438}\u{435}',Elements=
'\u{424}\u{443}\u{43d}\u{43a}\u{446}\u{438}\u{44f}',Tabs=
'\u{412}\u{43a}\u{43b}\u{430}\u{434}\u{43a}\u{430}',Hidden=
'\u{41c}\u{435}\u{43d}\u{44e} \u{441}\u{43a}\u{440}\u{44b}\u{442}\u{43e}. \u{41d}\u{430}\u{436}\u{43c}\u{438} %s, \u{447}\u{442}\u{43e}\u{431}\u{44b} \u{432}\u{435}\u{440}\u{43d}\u{443}\u{442}\u{44c}'
,Empty=
'\u{422}\u{443}\u{442} \u{43f}\u{43e}\u{43a}\u{430} \u{43f}\u{443}\u{441}\u{442}\u{43e}'
,Hide='\u{421}\u{43a}\u{440}\u{44b}\u{442}\u{44c} \u{43c}\u{435}\u{43d}\u{44e}',
Home='\u{413}\u{43b}\u{430}\u{432}\u{43d}\u{430}\u{44f}',KeyTitle=
'\u{412}\u{432}\u{435}\u{434}\u{438} \u{43a}\u{43b}\u{44e}\u{447}',KeySubtitle=
'\u{41e}\u{434}\u{438}\u{43d} \u{43a}\u{43b}\u{44e}\u{447} \u{43d}\u{430} \u{438}\u{433}\u{440}\u{43e}\u{43a}\u{430}, \u{43e}\u{43d} \u{437}\u{430}\u{43f}\u{43e}\u{43c}\u{43d}\u{438}\u{442}\u{441}\u{44f} \u{43d}\u{430} \u{44d}\u{442}\u{43e}\u{43c} \u{443}\u{441}\u{442}\u{440}\u{43e}\u{439}\u{441}\u{442}\u{432}\u{435}'
,KeyPlaceholder=
'\u{412}\u{441}\u{442}\u{430}\u{432}\u{44c} \u{43a}\u{43b}\u{44e}\u{447} \u{441}\u{44e}\u{434}\u{430}'
,GetKey=
'\u{41f}\u{43e}\u{43b}\u{443}\u{447}\u{438}\u{442}\u{44c} \u{43a}\u{43b}\u{44e}\u{447}'
,CheckKey='\u{41f}\u{440}\u{43e}\u{432}\u{435}\u{440}\u{438}\u{442}\u{44c}',
Checking='\u{41f}\u{440}\u{43e}\u{432}\u{435}\u{440}\u{44f}\u{44e}',JoinDiscord=
'\u{41d}\u{430}\u{448} Discord',LinkCopied=
'\u{421}\u{441}\u{44b}\u{43b}\u{43a}\u{430} \u{441}\u{43a}\u{43e}\u{43f}\u{438}\u{440}\u{43e}\u{432}\u{430}\u{43d}\u{430}, \u{43e}\u{442}\u{43a}\u{440}\u{43e}\u{439} \u{435}\u{451} \u{432} \u{431}\u{440}\u{430}\u{443}\u{437}\u{435}\u{440}\u{435}'
,KeyWait=
'\u{421}\u{43b}\u{438}\u{448}\u{43a}\u{43e}\u{43c} \u{43c}\u{43d}\u{43e}\u{433}\u{43e} \u{43f}\u{43e}\u{43f}\u{44b}\u{442}\u{43e}\u{43a}. \u{41f}\u{43e}\u{434}\u{43e}\u{436}\u{434}\u{438} %d \u{441}'
,KeyOk=
'\u{41a}\u{43b}\u{44e}\u{447} \u{43f}\u{43e}\u{434}\u{43e}\u{448}\u{451}\u{43b}, \u{437}\u{430}\u{433}\u{440}\u{443}\u{436}\u{430}\u{44e}'
,KeyLocked=
'\u{421}\u{43b}\u{438}\u{448}\u{43a}\u{43e}\u{43c} \u{43c}\u{43d}\u{43e}\u{433}\u{43e} \u{43d}\u{435}\u{432}\u{435}\u{440}\u{43d}\u{44b}\u{445} \u{43a}\u{43b}\u{44e}\u{447}\u{435}\u{439}. \u{41f}\u{43e}\u{43f}\u{440}\u{43e}\u{431}\u{443}\u{439} \u{447}\u{435}\u{440}\u{435}\u{437} %d \u{441}'
,KeyBad=
'\u{41a}\u{43b}\u{44e}\u{447} \u{43d}\u{435} \u{43f}\u{43e}\u{434}\u{43e}\u{448}\u{451}\u{43b}. \u{41e}\u{441}\u{442}\u{430}\u{43b}\u{43e}\u{441}\u{44c} \u{43f}\u{43e}\u{43f}\u{44b}\u{442}\u{43e}\u{43a}: %d'
,PlayerPanel='\u{418}\u{433}\u{440}\u{43e}\u{43a}',Health=
'\u{417}\u{434}\u{43e}\u{440}\u{43e}\u{432}\u{44c}\u{435}',Speed=
'\u{421}\u{43a}\u{43e}\u{440}\u{43e}\u{441}\u{442}\u{44c}',State=
'\u{421}\u{43e}\u{441}\u{442}\u{43e}\u{44f}\u{43d}\u{438}\u{435}',Position=
'\u{41f}\u{43e}\u{437}\u{438}\u{446}\u{438}\u{44f}',Performance=
'\u{41f}\u{440}\u{43e}\u{438}\u{437}\u{432}\u{43e}\u{434}\u{438}\u{442}\u{435}\u{43b}\u{44c}\u{43d}\u{43e}\u{441}\u{442}\u{44c}'
,Ping='\u{41f}\u{438}\u{43d}\u{433}',Stopwatch=
'\u{421}\u{435}\u{43a}\u{443}\u{43d}\u{434}\u{43e}\u{43c}\u{435}\u{440}',InGame=
'\u{412} \u{438}\u{433}\u{440}\u{435}',UpdateTitle=
'\u{41e}\u{431}\u{43d}\u{43e}\u{432}\u{43b}\u{435}\u{43d}\u{438}\u{435} %s',
UpdateBody=
'\u{423} \u{442}\u{435}\u{431}\u{44f} %s, \u{432}\u{44b}\u{448}\u{43b}\u{430} \u{432}\u{435}\u{440}\u{441}\u{438}\u{44f} %s'
,EconomyTitle='\u{42d}\u{43a}\u{43e}\u{43d}\u{43e}\u{43c}\u{438}\u{43c} FPS',
EconomyBody=
'FPS \u{43f}\u{440}\u{43e}\u{441}\u{435}\u{43b}, \u{43f}\u{43e}\u{44d}\u{442}\u{43e}\u{43c}\u{443} \u{437}\u{432}\u{451}\u{437}\u{434}\u{44b} \u{438} \u{43f}\u{43b}\u{430}\u{43d}\u{435}\u{442}\u{430} \u{43f}\u{43e}\u{43a}\u{430} \u{432}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{435}\u{43d}\u{44b}'
,NotificationCenter=
'\u{423}\u{432}\u{435}\u{434}\u{43e}\u{43c}\u{43b}\u{435}\u{43d}\u{438}\u{44f}',
MiniMode='\u{41c}\u{438}\u{43d}\u{438}-\u{440}\u{435}\u{436}\u{438}\u{43c}',
Unsaved=
'\u{415}\u{441}\u{442}\u{44c} \u{43d}\u{435}\u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{451}\u{43d}\u{43d}\u{43e}\u{435}'
,UnsavedHint=
'\u{418}\u{437}\u{43c}\u{435}\u{43d}\u{435}\u{43d}\u{438}\u{44f} \u{432} %s \u{435}\u{449}\u{451} \u{43d}\u{435} \u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{435}\u{43d}\u{44b}'
,WhatsNew=
'\u{427}\u{442}\u{43e} \u{43d}\u{43e}\u{432}\u{43e}\u{433}\u{43e} \u{432} %s',
NoNotifications=
'\u{423}\u{432}\u{435}\u{434}\u{43e}\u{43c}\u{43b}\u{435}\u{43d}\u{438}\u{439} \u{43f}\u{43e}\u{43a}\u{430} \u{43d}\u{435}\u{442}'
,ClearAll='\u{41e}\u{447}\u{438}\u{441}\u{442}\u{438}\u{442}\u{44c}',From=
'\u{41e}\u{442}',To='\u{414}\u{43e}',ResetFilters=
'\u{421}\u{431}\u{440}\u{43e}\u{441}\u{438}\u{442}\u{44c} \u{444}\u{438}\u{43b}\u{44c}\u{442}\u{440}\u{44b}'
,Navigation='\u{41d}\u{430}\u{432}\u{438}\u{433}\u{430}\u{446}\u{438}\u{44f}',
Sidebar=
'\u{411}\u{43e}\u{43a}\u{43e}\u{432}\u{430}\u{44f} \u{43f}\u{430}\u{43d}\u{435}\u{43b}\u{44c}'
,Rail=
'\u{422}\u{43e}\u{43b}\u{44c}\u{43a}\u{43e} \u{438}\u{43a}\u{43e}\u{43d}\u{43a}\u{438}'
,Font='\u{428}\u{440}\u{438}\u{444}\u{442}',FontFailed=
'\u{42d}\u{442}\u{43e}\u{43c}\u{443} \u{448}\u{440}\u{438}\u{444}\u{442}\u{443} \u{43d}\u{443}\u{436}\u{435}\u{43d} getcustomasset, \u{432} \u{442}\u{432}\u{43e}\u{451}\u{43c} \u{44d}\u{43a}\u{437}\u{435}\u{43a}\u{443}\u{442}\u{43e}\u{440}\u{435} \u{435}\u{433}\u{43e} \u{43d}\u{435}\u{442}'
,Density='\u{41f}\u{43b}\u{43e}\u{442}\u{43d}\u{43e}\u{441}\u{442}\u{44c}',
Compact='\u{41a}\u{43e}\u{43c}\u{43f}\u{430}\u{43a}\u{442}\u{43d}\u{43e}',Normal
='\u{41e}\u{431}\u{44b}\u{447}\u{43d}\u{43e}',Comfortable=
'\u{41f}\u{440}\u{43e}\u{441}\u{442}\u{43e}\u{440}\u{43d}\u{43e}',Touch=
'\u{414}\u{43b}\u{44f} \u{43f}\u{430}\u{43b}\u{44c}\u{446}\u{435}\u{432}',
ToggleStyle=
'\u{412}\u{438}\u{434} \u{43f}\u{435}\u{440}\u{435}\u{43a}\u{43b}\u{44e}\u{447}\u{430}\u{442}\u{435}\u{43b}\u{435}\u{439}'
,BackgroundImage=
'\u{41a}\u{430}\u{440}\u{442}\u{438}\u{43d}\u{43a}\u{430} \u{444}\u{43e}\u{43d}\u{430}'
,BackgroundDim=
'\u{417}\u{430}\u{442}\u{435}\u{43c}\u{43d}\u{435}\u{43d}\u{438}\u{435} \u{444}\u{43e}\u{43d}\u{430}'
,WatermarkItems=
'\u{427}\u{442}\u{43e} \u{43f}\u{43e}\u{43a}\u{430}\u{437}\u{44b}\u{432}\u{430}\u{442}\u{44c} \u{432} \u{432}\u{43e}\u{442}\u{435}\u{440}\u{43c}\u{430}\u{440}\u{43a}\u{435}'
,ShowInactive=
'\u{41f}\u{43e}\u{43a}\u{430}\u{437}\u{44b}\u{432}\u{430}\u{442}\u{44c} \u{43d}\u{435}\u{430}\u{43a}\u{442}\u{438}\u{432}\u{43d}\u{44b}\u{435} \u{431}\u{438}\u{43d}\u{434}\u{44b}'
,SortBinds=
'\u{41f}\u{43e}\u{440}\u{44f}\u{434}\u{43e}\u{43a} \u{431}\u{438}\u{43d}\u{434}\u{43e}\u{432}'
,SortActive=
'\u{421}\u{43d}\u{430}\u{447}\u{430}\u{43b}\u{430} \u{430}\u{43a}\u{442}\u{438}\u{432}\u{43d}\u{44b}\u{435}'
,SortName=
'\u{41f}\u{43e} \u{43d}\u{430}\u{437}\u{432}\u{430}\u{43d}\u{438}\u{44e}',
SortKey='\u{41f}\u{43e} \u{43a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{435}',
Widgets='\u{412}\u{438}\u{434}\u{436}\u{435}\u{442}\u{44b}',AutoEconomy=
'\u{42d}\u{43a}\u{43e}\u{43d}\u{43e}\u{43c}\u{438}\u{442}\u{44c} FPS \u{441}\u{430}\u{43c}\u{43e}\u{43c}\u{443}'
,AutoEconomyHint=
'\u{412}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{430}\u{435}\u{442} \u{44d}\u{444}\u{444}\u{435}\u{43a}\u{442}\u{44b}, \u{43a}\u{43e}\u{433}\u{434}\u{430} FPS \u{43f}\u{430}\u{434}\u{430}\u{435}\u{442}'
,ShareCode=
'\u{41f}\u{43e}\u{434}\u{435}\u{43b}\u{438}\u{442}\u{44c}\u{441}\u{44f} \u{43a}\u{43e}\u{434}\u{43e}\u{43c}'
,ImportCode='\u{412}\u{432}\u{435}\u{441}\u{442}\u{438} \u{43a}\u{43e}\u{434}',
CodeCopied=
'\u{41a}\u{43e}\u{434} %s \u{441}\u{43a}\u{43e}\u{43f}\u{438}\u{440}\u{43e}\u{432}\u{430}\u{43d}. \u{41e}\u{442}\u{43f}\u{440}\u{430}\u{432}\u{44c} \u{435}\u{433}\u{43e} \u{434}\u{440}\u{443}\u{433}\u{443}'
,CodeFailed=
'\u{41d}\u{435} \u{432}\u{44b}\u{448}\u{43b}\u{43e} \u{437}\u{430}\u{433}\u{440}\u{443}\u{437}\u{438}\u{442}\u{44c}. \u{41d}\u{443}\u{436}\u{43d}\u{430} \u{444}\u{443}\u{43d}\u{43a}\u{446}\u{438}\u{44f} request \u{432} \u{44d}\u{43a}\u{437}\u{435}\u{43a}\u{443}\u{442}\u{43e}\u{440}\u{435}'
,CodeInvalid=
'\u{42d}\u{442}\u{43e}\u{442} \u{43a}\u{43e}\u{434} \u{43d}\u{435} \u{43f}\u{43e}\u{434}\u{43e}\u{448}\u{451}\u{43b}'
,Restore='\u{412}\u{435}\u{440}\u{43d}\u{443}\u{442}\u{44c}',DeletedHint=
'%s \u{443}\u{434}\u{430}\u{43b}\u{451}\u{43d}',SaveBeforeUnload=
'\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{438}\u{442}\u{44c} \u{438}\u{437}\u{43c}\u{435}\u{43d}\u{435}\u{43d}\u{438}\u{44f} \u{432} %s \u{43f}\u{435}\u{440}\u{435}\u{434} \u{432}\u{44b}\u{433}\u{440}\u{443}\u{437}\u{43a}\u{43e}\u{439}?'
,DontSave=
'\u{41d}\u{435} \u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{44f}\u{442}\u{44c}'
,Replaced=
'\u{421}\u{442}\u{430}\u{440}\u{430}\u{44f} \u{43a}\u{43e}\u{43f}\u{438}\u{44f} v%s \u{437}\u{430}\u{43c}\u{435}\u{43d}\u{435}\u{43d}\u{430} \u{43d}\u{430} v%s'
,OpenAnimation=
'\u{410}\u{43d}\u{438}\u{43c}\u{430}\u{446}\u{438}\u{44f} \u{43c}\u{435}\u{43d}\u{44e}'
,OpenAnimationHint=
'\u{41a}\u{430}\u{43a} \u{43c}\u{435}\u{43d}\u{44e} \u{43f}\u{43e}\u{44f}\u{432}\u{43b}\u{44f}\u{435}\u{442}\u{441}\u{44f} \u{438} \u{43f}\u{440}\u{44f}\u{447}\u{435}\u{442}\u{441}\u{44f}'
,AnimPlanet=
'\u{41f}\u{43b}\u{430}\u{43d}\u{435}\u{442}\u{430} - \u{438}\u{437} \u{43a}\u{43d}\u{43e}\u{43f}\u{43a}\u{438}'
,AnimRise='\u{41f}\u{43e}\u{434}\u{44a}\u{451}\u{43c}',AnimZoom=
'\u{417}\u{443}\u{43c}',AnimDrop=
'\u{41f}\u{430}\u{434}\u{435}\u{43d}\u{438}\u{435}',AnimSlide=
'\u{421}\u{434}\u{432}\u{438}\u{433}',AnimSwing=
'\u{412}\u{437}\u{43c}\u{430}\u{445}',AnimWipe=
'\u{428}\u{442}\u{43e}\u{440}\u{43a}\u{430}',AnimUnfold=
'\u{420}\u{430}\u{441}\u{43a}\u{440}\u{44b}\u{442}\u{438}\u{435}',AnimScan=
'\u{421}\u{43a}\u{430}\u{43d}',AnimGlitch='\u{413}\u{43b}\u{438}\u{442}\u{447}',
AnimFade=
'\u{420}\u{430}\u{441}\u{442}\u{432}\u{43e}\u{440}\u{435}\u{43d}\u{438}\u{435}',
AnimNone=
'\u{411}\u{435}\u{437} \u{430}\u{43d}\u{438}\u{43c}\u{430}\u{446}\u{438}\u{438}'
,LoadingStyle=
'\u{42d}\u{43a}\u{440}\u{430}\u{43d} \u{437}\u{430}\u{433}\u{440}\u{443}\u{437}\u{43a}\u{438}'
,LoadingStyleHint=
'\u{41f}\u{440}\u{438}\u{43c}\u{435}\u{43d}\u{438}\u{442}\u{441}\u{44f} \u{43f}\u{440}\u{438} \u{441}\u{43b}\u{435}\u{434}\u{443}\u{44e}\u{449}\u{435}\u{43c} \u{437}\u{430}\u{43f}\u{443}\u{441}\u{43a}\u{435}'
,LoadingPlanet='\u{41f}\u{43b}\u{430}\u{43d}\u{435}\u{442}\u{430}',
LoadingSkeleton=
'\u{421}\u{43a}\u{435}\u{43b}\u{435}\u{442} \u{43c}\u{435}\u{43d}\u{44e}',
LoadingOrbit='\u{41e}\u{440}\u{431}\u{438}\u{442}\u{44b}',LoadingEclipse=
'\u{417}\u{430}\u{442}\u{43c}\u{435}\u{43d}\u{438}\u{435}',LoadingConstellation=
'\u{421}\u{43e}\u{437}\u{432}\u{435}\u{437}\u{434}\u{438}\u{435}',
LoadingTerminal='\u{422}\u{435}\u{440}\u{43c}\u{438}\u{43d}\u{430}\u{43b}',
LoadingNone=
'\u{411}\u{435}\u{437} \u{437}\u{430}\u{433}\u{440}\u{443}\u{437}\u{43a}\u{438}'
}}Locale.Names={en='English',ru=
'\u{420}\u{443}\u{441}\u{441}\u{43a}\u{438}\u{439}'}function Locale.T(key,...)
local pack=packs[Locale.Current]local text=(pack and pack[key])or packs.en[key]
or key if select('#',...)>0 then return string.format(text,...)end return text
end function Locale.Set(code)if not packs[code]then return false end Locale.
Current=code Locale.Changed:Fire(code)return true end function Locale.Add(code,
strings,displayName)packs[code]=packs[code]or{}for k,v in strings do packs[code]
[k]=v end Locale.Names[code]=displayName or Locale.Names[code]or code end
function Locale.List()local out={}for code in packs do table.insert(out,code)end
table.sort(out)return out end return Locale end function
__DARKLUA_BUNDLE_MODULES.j()local v=__DARKLUA_BUNDLE_MODULES.cache.j if not v
then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.j=v end return v.c end end
do local function __modImpl()return{}end function __DARKLUA_BUNDLE_MODULES.k()
local v=__DARKLUA_BUNDLE_MODULES.cache.k if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.k=v end return v.c end end do local function 
__modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Tween=
__DARKLUA_BUNDLE_MODULES.d()local Env=__DARKLUA_BUNDLE_MODULES.e()local Theme=
__DARKLUA_BUNDLE_MODULES.g()local Icons=__DARKLUA_BUNDLE_MODULES.i()local Shared
=__DARKLUA_BUNDLE_MODULES.k()local UIS=Env.Service('UserInputService')local
RunService=Env.Service('RunService')local Overlay={}Overlay.Stack={}local root,
scale function Overlay.Init(parent)root=Util.New('Frame',{Name='Overlay',
BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=50,Parent=parent})
scale=Util.New('UIScale',{Scale=1,Parent=root})Overlay.Root=root Shared.Maid:
Connect(UIS.InputBegan,function(input)if input.UserInputType==Enum.UserInputType
.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then Overlay.
_outside(Vector2.new(input.Position.X,input.Position.Y))elseif input.KeyCode==
Enum.KeyCode.Escape then local top=Overlay.Stack[#Overlay.Stack]if top then top:
Close()end end end)Shared.Maid:Connect(RunService.RenderStepped,function()for _,
popup in Overlay.Stack do if popup.Follow then popup:Reposition()end end Overlay
._tooltipStep()end)Overlay._buildTooltip()end function Overlay.SetScale(value)if
scale then scale.Scale=value root.Size=UDim2.fromScale(1/value,1/value)end end
local function inside(gui,point)if not gui or not gui.Parent or not gui.Visible
then return false end local pos,size=gui.AbsolutePosition,gui.AbsoluteSize
return point.X>=pos.X and point.X<=pos.X+size.X and point.Y>=pos.Y and point.Y<=
pos.Y+size.Y end function Overlay._outside(point)for i=#Overlay.Stack,1,-1 do
local popup=Overlay.Stack[i]if inside(popup.Frame,point)or inside(popup.Anchor,
point)then return end if popup.Sticky then return end popup:Close()end end local
Popup={}Popup.__index=Popup function Overlay.Popup(options)local self=
setmetatable({},Popup)self.Anchor=options.Anchor self.Side=options.Side or
'Bottom'self.Align=options.Align or'Start'self.Gap=options.Gap or 6 self.Width=
options.Width or 220 self.MaxHeight=options.MaxHeight or 320 self.OnClose=
options.OnClose self.Follow=options.Follow~=false self.Open=true local frame=
Util.New('Frame',{Name='Popup',Size=UDim2.fromOffset(self.Width,10),
AutomaticSize=Enum.AutomaticSize.None,ZIndex=60+#Overlay.Stack*5,Active=true,
ClipsDescendants=true,Parent=root})Theme.Paint(frame,{BackgroundColor3=
'Elevated'})Util.Corner(8,frame)local stroke=Util.Stroke(frame)Theme.Paint(
stroke,{Color='StrokeHi'})Overlay.Shadow(frame,0.55)local content=Util.New(
'ScrollingFrame',{Name='Content',BackgroundTransparency=1,BorderSizePixel=0,Size
=UDim2.fromScale(1,1),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.
AutomaticSize.Y,ScrollBarThickness=2,ScrollingDirection=Enum.ScrollingDirection.
Y,ZIndex=frame.ZIndex,Parent=frame})Theme.Paint(content,{ScrollBarImageColor3=
'StrokeHi'})local layout=Util.List(content,options.Spacing or 2)Util.Padding(
content,options.Padding or 6)self.Frame=frame self.Content=content self.Layout=
layout self.Stroke=stroke local function fit()local h=layout.AbsoluteContentSize
.Y+(options.Padding or 6)*2 self.Height=math.min(h,self.MaxHeight)frame.Size=
UDim2.fromOffset(self.Width,self.Height)self:Reposition()end layout:
GetPropertyChangedSignal('AbsoluteContentSize'):Connect(fit)self.Fit=fit table.
insert(Overlay.Stack,self)frame.BackgroundTransparency=1 stroke.Transparency=1
task.defer(function()fit()Tween.Play(frame,{BackgroundTransparency=0},0.16)Tween
.Play(stroke,{Transparency=0},0.16)end)return self end function Popup:Reposition
()if not self.Open or not self.Anchor or not self.Anchor.Parent then return end
local s=scale.Scale local origin=root.AbsolutePosition local view=root.
AbsoluteSize local apos,asize=self.Anchor.AbsolutePosition-origin,self.Anchor.
AbsoluteSize local w,h=self.Width*s,(self.Height or 40)*s local gap=self.Gap*s
local x,y if self.Side=='Right'or self.Side=='Left'then x=self.Side=='Right'and
apos.X+asize.X+gap or apos.X-w-gap y=apos.Y if x+w>view.X-4 then x=apos.X-w-gap
elseif x<4 then x=apos.X+asize.X+gap end else y=self.Side=='Top'and apos.Y-h-gap
or apos.Y+asize.Y+gap if self.Align=='End'then x=apos.X+asize.X-w elseif self.
Align=='Center'then x=apos.X+asize.X/2-w/2 else x=apos.X end if y+h>view.Y-4
then y=apos.Y-h-gap elseif y<4 then y=apos.Y+asize.Y+gap end end x=math.clamp(x,
4,math.max(4,view.X-w-4))y=math.clamp(y,4,math.max(4,view.Y-h-4))self.Frame.
Position=UDim2.fromOffset(x/s,y/s)end function Popup:Close()if not self.Open
then return end self.Open=false local index=table.find(Overlay.Stack,self)if
index then for i=#Overlay.Stack,index+1,-1 do Overlay.Stack[i]:Close()end table.
remove(Overlay.Stack,table.find(Overlay.Stack,self))end local frame=self.Frame
Tween.Play(frame,{BackgroundTransparency=1},0.12)Tween.Play(self.Stroke,{
Transparency=1},0.12)for _,d in frame:GetDescendants()do if d:IsA('GuiObject')
then d.Visible=false end end task.delay(0.13,function()frame:Destroy()end)if
self.OnClose then Util.SafeCall(self.OnClose)end end Popup.Destroy=Popup.Close
function Overlay.CloseAll()for i=#Overlay.Stack,1,-1 do Overlay.Stack[i]:Close()
end end local hasUIShadow=pcall(function()Instance.new('UIShadow'):Destroy()end)
Overlay.HasUIShadow=hasUIShadow function Overlay.Shadow(frame,transparency,size)
if hasUIShadow then local ok,shadow=pcall(function()local s=Instance.new(
'UIShadow')s.Color=Color3.new(0,0,0)pcall(function()s.Transparency=transparency
or 0.5 end)pcall(function()s.BlurRadius=UDim.new(0,size or 18)end)s.Parent=frame
return s end)if ok then return shadow end end local image=Util.New('ImageLabel',
{Name='Shadow',BackgroundTransparency=1,Image='rbxassetid://6015897843',
ImageColor3=Color3.new(0,0,0),ImageTransparency=transparency or 0.5,ScaleType=
Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),AnchorPoint=Vector2.
new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,(size or 18)*2,1
,(size or 18)*2),ZIndex=math.max(0,frame.ZIndex-1),Parent=frame.Parent})local 
function sync()image.Position=UDim2.new(frame.Position.X.Scale,frame.Position.X.
Offset+frame.AbsoluteSize.X*(0.5-frame.AnchorPoint.X)/math.max(scale and scale.
Scale or 1,0.01),frame.Position.Y.Scale,frame.Position.Y.Offset+frame.
AbsoluteSize.Y*(0.5-frame.AnchorPoint.Y)/math.max(scale and scale.Scale or 1,
0.01))image.Size=UDim2.new(frame.Size.X.Scale,frame.Size.X.Offset+(size or 18)*2
,frame.Size.Y.Scale,frame.Size.Y.Offset+(size or 18)*2)image.Visible=frame.
Visible end frame:GetPropertyChangedSignal('Position'):Connect(sync)frame:
GetPropertyChangedSignal('Size'):Connect(sync)frame:GetPropertyChangedSignal(
'Visible'):Connect(sync)frame.Destroying:Connect(function()image:Destroy()end)
sync()return image end function Overlay.Menu(items,options)options=options or{}
local anchor=options.Anchor if not anchor and options.At then anchor=Util.New(
'Frame',{BackgroundTransparency=1,Size=UDim2.fromOffset(1,1),Position=UDim2.
fromOffset((options.At.X-root.AbsolutePosition.X)/scale.Scale,(options.At.Y-root
.AbsolutePosition.Y)/scale.Scale),Parent=root})end local popup=Overlay.Popup({
Anchor=anchor,Width=options.Width or 190,Side=options.Side or'Bottom',Align=
options.Align or'Start',Gap=options.At and 0 or 6,Padding=4,OnClose=function()if
options.At and anchor then anchor:Destroy()end if options.OnClose then options.
OnClose()end end})for i,item in items do if item.Separator then local line=Util.
New('Frame',{Size=UDim2.new(1,-8,0,1),Position=UDim2.fromOffset(4,0),
BorderSizePixel=0,LayoutOrder=i,ZIndex=popup.Frame.ZIndex,Parent=popup.Content})
Theme.Paint(line,{BackgroundColor3='Stroke'})else local button=Util.New(
'TextButton',{Text='',AutoButtonColor=false,Size=UDim2.new(1,0,0,28),
BackgroundTransparency=1,LayoutOrder=i,ZIndex=popup.Frame.ZIndex,Parent=popup.
Content})Theme.Paint(button,{BackgroundColor3='Surface3'})Util.Corner(6,button)
local x=10 local icon=Icons.Get(item.Icon)if icon then local img=Util.New(
'ImageLabel',{BackgroundTransparency=1,Image=icon,Size=UDim2.fromOffset(14,14),
Position=UDim2.new(0,9,0.5,-7),ZIndex=button.ZIndex,Parent=button})Theme.Paint(
img,{ImageColor3=item.Danger and'Risky'or'TextDim'})x=30 end local label=Util.
Label({Text=item.Text or'',FontFace=Theme.Fonts.Medium,TextSize=13,Position=
UDim2.fromOffset(x,0),Size=UDim2.new(1,-x-8,1,0),ZIndex=button.ZIndex,Parent=
button})Theme.Paint(label,{TextColor3=item.Danger and'Risky'or'Text'})if item.
Hint then local hint=Util.Label({Text=item.Hint,FontFace=Theme.Fonts.Mono,
TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,Size=UDim2.new(1,-10,1,0),
ZIndex=button.ZIndex,Parent=button})Theme.Paint(hint,{TextColor3='TextMute'})end
button.MouseEnter:Connect(function()Tween.Play(button,{BackgroundTransparency=0}
,0.1)end)button.MouseLeave:Connect(function()Tween.Play(button,{
BackgroundTransparency=1},0.1)end)button.Activated:Connect(function()popup:
Close()if item.Callback then Util.SafeCall(item.Callback)end end)end end return
popup end local tip={}function Overlay._buildTooltip()tip.Frame=Util.New('Frame'
,{Name='Tooltip',Visible=false,AutomaticSize=Enum.AutomaticSize.XY,ZIndex=200,
Parent=root})Theme.Paint(tip.Frame,{BackgroundColor3='Elevated'})Util.Corner(6,
tip.Frame)Theme.Paint(Util.Stroke(tip.Frame),{Color='StrokeHi'})Util.Padding(tip
.Frame,6,9,6,9)Util.New('UISizeConstraint',{MaxSize=Vector2.new(280,400),Parent=
tip.Frame})tip.Label=Util.Label({AutomaticSize=Enum.AutomaticSize.XY,Size=UDim2.
new(),TextWrapped=true,RichText=true,FontFace=Theme.Fonts.Regular,TextSize=12,
ZIndex=201,Parent=tip.Frame})Theme.Paint(tip.Label,{TextColor3='Text'})end
function Overlay.Hover(gui,getText)local token=0 gui.MouseEnter:Connect(function
()token+=1 local mine=token task.delay(0.45,function()if mine==token and Overlay
.Root then local text=getText()if text and text~=''then tip.Owner=gui tip.Label.
Text=text tip.Frame.Visible=true end end end)end)gui.MouseLeave:Connect(function
()token+=1 if tip.Owner==gui then tip.Frame.Visible=false tip.Owner=nil end end)
end function Overlay.HideTooltip()if tip.Frame then tip.Frame.Visible=false tip.
Owner=nil end end function Overlay._tooltipStep()if tip.Frame and tip.Frame.
Visible then if not tip.Owner or not tip.Owner.Parent or not tip.Owner.Visible
then tip.Frame.Visible=false return end local mouse=UIS:GetMouseLocation()local
s=scale.Scale local view=workspace.CurrentCamera.ViewportSize local size=tip.
Frame.AbsoluteSize local x=math.clamp(mouse.X+14,4,view.X-size.X-4)local y=mouse
.Y+18 if y+size.Y>view.Y-4 then y=mouse.Y-size.Y-8 end tip.Frame.Position=UDim2.
fromOffset(x/s,y/s)end end return Overlay end function __DARKLUA_BUNDLE_MODULES.
l()local v=__DARKLUA_BUNDLE_MODULES.cache.l if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.l=v end return v.c end end do local function 
__modImpl()local HttpService=game:GetService('HttpService')local Util=
__DARKLUA_BUNDLE_MODULES.a()local Env=__DARKLUA_BUNDLE_MODULES.e()local Signal=
__DARKLUA_BUNDLE_MODULES.b()local Locale=__DARKLUA_BUNDLE_MODULES.j()return
function(Lib)Lib.Folder='Proximity'Lib.SchemaVersion=1 Lib.Migrations={}Lib.
ConfigsChanged=Signal.new()Lib.ConfigLoaded=Signal.new()Lib.ConfigSaved=Signal.
new()Lib.Loading=false local settingsCache=nil local function configDir()return
Lib.Folder..'/configs'end local function configPath(name)return configDir()..'/'
..Util.SafeName(name)..'.json'end local function encode(t)return HttpService:
JSONEncode(t)end Lib.EncryptConfigs=true local SECRET='proximity-planet'local 
function xor(data)local out=table.create(#data)local n=#SECRET for i=1,#data do
out[i]=string.char(bit32.bxor(string.byte(data,i),string.byte(SECRET,(i-1)%n+1))
)end return table.concat(out)end local function protect(json)if not Lib.
EncryptConfigs then return json end local body=Util.Base64Encode(xor(json))
return'PRXC1.'..body..'.'..Util.Checksum(body)end local function unprotect(raw)
local body,sum=string.match(raw,'^PRXC1%.([%w%+/=]+)%.(%x+)%s*$')if not body
then return raw end if Util.Checksum(body)~=sum then return nil end return xor(
Util.Base64Decode(body))end local function decode(s)if type(s)~='string'then
return nil end s=unprotect(s)if not s then return nil end local ok,result=pcall(
HttpService.JSONDecode,HttpService,s)if ok and type(result)=='table'then return
result end return nil end local function loadSettings()if settingsCache then
return settingsCache end local raw=Env.Read(Lib.Folder..'/settings.json')
settingsCache=raw and decode(raw)or{}return settingsCache end local
flushSettings=Util.Debounce(0.6,function()if settingsCache then Env.Write(Lib.
Folder..'/settings.json',encode(settingsCache))end end)function Lib:GetSetting(
key,default)local value=loadSettings()[key]if value==nil then return default end
return value end function Lib:SetSetting(key,value)loadSettings()[key]=value
flushSettings()end function Lib:SetFolder(folder)Lib.Folder=Util.SafeName(folder
)settingsCache=nil Env.MakeFolder(configDir())end function Lib:GetState()local
state={}for flag,element in Lib.Elements do if element.Save~=false then local ok
,value=pcall(element._serialize,element)if ok and value~=nil then state[flag]=
value end end end return state end function Lib:ApplyState(state,options)options
=options or{}local budget=options.Budget or 0.002 local items={}for flag,value
in state do local element=Lib.Elements[flag]if element and element.Save~=false
then table.insert(items,{element,value})end end Lib.Loading=true local applied,
start=0,os.clock()for i,item in items do local ok=pcall(item[1]._deserialize,
item[1],item[2],options.Silent)if ok then applied+=1 end if options.OnProgress
then options.OnProgress(i,#items)end if budget>0 and os.clock()-start>budget
then task.wait()start=os.clock()end end Lib.Loading=false return applied,#items
end function Lib:SaveConfig(name,meta)name=Util.SafeName(name or'')if name==''
then return false,'invalid name'end local path=configPath(name)local previous=
Env.Read(path)local created=os.time()if previous then local old=decode(previous)
if old and old.Created then created=old.Created end end local data={Proximity=
Lib.Version,Schema=Lib.SchemaVersion,Name=name,Created=created,Updated=os.time()
,PlaceId=game.PlaceId,Author=meta and meta.Author or nil,Note=meta and meta.Note
or nil,Flags=Lib:GetState()}if previous then Env.Write(path..'.bak',previous)end
local ok=Env.Write(path,protect(encode(data)))if ok then Lib.ConfigSaved:Fire(
name)Lib.ConfigsChanged:Fire()end return ok,ok and name or'write failed'end
local function migrate(data)local schema=tonumber(data.Schema)or 1 while schema<
Lib.SchemaVersion do local step=Lib.Migrations[schema]if step then local ok,
result=pcall(step,data.Flags or{})if ok and type(result)=='table'then data.Flags
=result end end schema+=1 end return data end function Lib:ReadConfig(name)local
raw=Env.Read(configPath(name))if not raw then return nil end local data=decode(
raw)if not data then Env.Write(configPath(name)..'.broken',raw)return nil end
return migrate(data)end function Lib:LoadConfig(name,options)local data=Lib:
ReadConfig(name)if not data then return false,'config not found or broken'end
local applied,total=Lib:ApplyState(data.Flags or{},options)Lib.ConfigLoaded:
Fire(name,applied,total)return true,string.format('%d/%d',applied,total)end
function Lib:RestoreBackup(name)local raw=Env.Read(configPath(name)..'.bak')if
not raw then return false end Env.Write(configPath(name),raw)Lib.ConfigsChanged:
Fire()return true end function Lib:DeleteConfig(name,quiet)local raw=Env.Read(
configPath(name))local ok=Env.Delete(configPath(name))if ok and raw and not
quiet and Lib.Notify then Lib:Notify({Title=Locale.T('Deleted'),Content=Locale.
T('DeletedHint',name),Type='info',Duration=5,Actions={{Text=Locale.T('Restore'),
Callback=function()Env.Write(configPath(name),raw)Lib.ConfigsChanged:Fire()end}}
})end if ok then if Lib:GetAutoLoad()==Util.SafeName(name)then Lib:SetAutoLoad(
nil)end Lib.ConfigsChanged:Fire()end return ok end function Lib:ListConfigs()
local out={}for _,file in Env.List(configDir())do local name=string.match(file,
'^(.+)%.json$')if name then table.insert(out,name)end end return out end
function Lib:ConfigExists(name)return Env.IsFile(configPath(name))end function
Lib:GetConfigInfo(name)local data=Lib:ReadConfig(name)if not data then return
nil end return{Name=data.Name or name,Created=data.Created,Updated=data.Updated,
Author=data.Author,Note=data.Note,Version=data.Proximity,Schema=data.Schema,
Count=Util.Count(data.Flags or{})}end function Lib:RenameConfig(from,to)local
raw=Env.Read(configPath(from))if not raw then return false end local ok=Env.
Write(configPath(to),raw)if ok then Env.Delete(configPath(from))if Lib:
GetAutoLoad()==Util.SafeName(from)then Lib:SetAutoLoad(to)end Lib.ConfigsChanged
:Fire()end return ok end function Lib:DuplicateConfig(from,to)local raw=Env.
Read(configPath(from))if not raw then return false end local ok=Env.Write(
configPath(to),raw)Lib.ConfigsChanged:Fire()return ok end function Lib:
DiffConfig(name)local data=Lib:ReadConfig(name)local out={}if not data then
return out end local current=Lib:GetState()for flag,value in data.Flags or{}do
if Lib.Elements[flag]and not Util.Equal(current[flag],value)then table.insert(
out,{Flag=flag,From=current[flag],To=value})end end table.sort(out,function(a,b)
return a.Flag<b.Flag end)return out end function Lib:ExportConfig(name)local
flags if name then local data=Lib:ReadConfig(name)if not data then return nil
end flags=data.Flags else flags=Lib:GetState()end local body=Util.Base64Encode(
encode({Schema=Lib.SchemaVersion,Flags=flags}))return'PRX1.'..body..'.'..Util.
Checksum(body)end function Lib:ImportConfig(text,saveAs)text=Util.Trim(tostring(
text or''))local body,sum=string.match(text,'^PRX1%.([%w%+/=]+)%.(%x+)$')if not
body then return false,'format'end if Util.Checksum(body)~=sum then return false
,'checksum'end local data=decode(Util.Base64Decode(body))if not data or type(
data.Flags)~='table'then return false,'decode'end data=migrate(data)if saveAs
then local ok=Env.Write(configPath(saveAs),encode({Proximity=Lib.Version,Schema=
Lib.SchemaVersion,Name=Util.SafeName(saveAs),Created=os.time(),Updated=os.time()
,Flags=data.Flags}))Lib.ConfigsChanged:Fire()return ok,saveAs end Lib:
ApplyState(data.Flags)return true end Lib.ShareService={Upload=function(text)
local req=Env.Global('request')or Env.Global('http_request')if not req then
return nil end local ok,res=pcall(req,{Url='https://paste.rs/',Method='POST',
Body=text,Headers={['Content-Type']='text/plain'}})if ok and res and(res.
StatusCode==201 or res.StatusCode==206 or res.StatusCode==200)and res.Body then
return string.match(res.Body,'paste%.rs/([%w]+)')end return nil end,Download=
function(code)return Env.HttpGet('https://paste.rs/'..code)end}function Lib:
ShareConfig(name)local text=Lib:ExportConfig(name)if not text then return nil,
'export'end local code=Lib.ShareService.Upload(text)if not code then return nil,
'upload'end return code end function Lib:ImportCode(code,saveAs)code=Util.Trim(
tostring(code or''))code=string.match(code,'([%w]+)$')or code if code==''then
return false,'empty'end local text=Lib.ShareService.Download(code)if not text
then return false,'download'end return Lib:ImportConfig(text,saveAs)end function
Lib:SetAutoLoad(name)Lib:SetSetting('AutoLoad',name and Util.SafeName(name)or
false)end function Lib:GetAutoLoad()local name=Lib:GetSetting('AutoLoad')return
type(name)=='string'and name or nil end function Lib:SetAutoSave(name)Lib:
SetSetting('AutoSave',name and Util.SafeName(name)or false)end function Lib:
GetAutoSave()local name=Lib:GetSetting('AutoSave')return type(name)=='string'and
name or nil end local autoSave=Util.Debounce(1.5,function()local name=Lib:
GetAutoSave()if name and not Lib.Unloaded then Lib:SaveConfig(name)end end)
function Lib:_scheduleAutoSave()if Lib.Loading or not Lib._autoSaveArmed then
return end if Lib:GetAutoSave()then autoSave()end end function Lib:
LoadAutoConfig(options)local name=Lib:GetAutoLoad()if name and Lib:ConfigExists(
name)then Lib:LoadConfig(name,options)return name end return nil end end end
function __DARKLUA_BUNDLE_MODULES.m()local v=__DARKLUA_BUNDLE_MODULES.cache.m if
not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.m=v end return v.c
end end do local function __modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()
local Signal=__DARKLUA_BUNDLE_MODULES.b()local Maid=__DARKLUA_BUNDLE_MODULES.c()
local Tween=__DARKLUA_BUNDLE_MODULES.d()local Env=__DARKLUA_BUNDLE_MODULES.e()
local Theme=__DARKLUA_BUNDLE_MODULES.g()local Icons=__DARKLUA_BUNDLE_MODULES.i()
local Locale=__DARKLUA_BUNDLE_MODULES.j()local Shared=__DARKLUA_BUNDLE_MODULES.
k()local HttpService=game:GetService('HttpService')local Base={}Base.__index=
Base function Base.extend(kind)local class=setmetatable({},{__index=Base})class.
__index=class class.Kind=kind return class end function Base.new(class,section,
options)options=options or{}local Lib=Shared.Lib local self=setmetatable({},
class)self.Type=class.Kind self.Library=Lib self.Section=section self.Window=
section and section.Window self.Tab=section and section.Tab self.Opts=options
self.Id=Util.Uid()self.Name=Util.Opt(options,'Name','Title','Text')or class.Kind
self.Description=Util.Opt(options,'Description','Desc')self.TooltipText=Util.
Opt(options,'Tooltip','Info')self.Flag=options.Flag self.Save=options.Save self.
Risky=options.Risky==true self.Visible=options.Visible~=false self.Locked=
options.Locked~=nil and options.Locked~=false self.LockReason=type(options.
Locked)=='string'and options.Locked or options.LockReason self.BadgeText=options
.Badge self.Icon=options.Icon self.Changed=Signal.new()self.Destroyed=Signal.
new()self.Maid=Maid.new()self.Links={}self._callbacks={}self._depsOk=true self.
_mounted=false self.Parent=options.__parent local callback=Util.Opt(options,
'Callback','OnChanged')if type(callback)=='function'then table.insert(self.
_callbacks,callback)end return self end function Base:_register()local Lib=self.
Library if self.Flag then if Lib.Elements[self.Flag]and Lib.Debug then warn(
"[Proximity] duplicate flag '"..self.Flag.."' - the newest element wins")end Lib
.Elements[self.Flag]=self Lib.Flags[self.Flag]=self.Value end table.insert(Lib.
AllElements,self)if self.Section and not self.Parent then self.Section:_add(self
)end return self end function Base:Get()return self.Value end Base.GetValue=Base
.Get function Base:_normalize(value)return value end function Base:_callbackArgs
()return self.Value end function Base:Set(value,silent)if self._destroyed then
return self end local normalized=self:_normalize(value)if normalized==nil and
value~=nil then return self end local old=self.Value if Util.Equal(old,
normalized)then return self end self.Value=normalized local Lib=self.Library if
self.Flag then Lib.Flags[self.Flag]=normalized end if self._mounted then self:
_render(true)end if not silent then self:_fireCallbacks()end self.Changed:Fire(
normalized,old)Lib:_onElementChanged(self,normalized,old)return self end Base.
SetValue=Base.Set function Base:_userSet(value)local old=Util.DeepCopy(self.
Value)self:Set(value)if not Util.Equal(old,self.Value)then self.Library:
_pushHistory(self,old,Util.DeepCopy(self.Value))end end function Base:
_fireCallbacks()for _,callback in self._callbacks do Util.SafeCall(callback,self
:_callbackArgs())end end function Base:Fire()self:_fireCallbacks()return self
end function Base:Reset(silent)return self:Set(Util.DeepCopy(self.Default),
silent)end function Base:GetDefault()return Util.DeepCopy(self.Default)end
function Base:SetDefault(value)self.Default=self:_normalize(value)or self.
Default return self end function Base:IsDefault()return Util.Equal(self.Value,
self.Default)end function Base:OnChanged(fn)return self.Changed:Connect(fn)end
function Base:SetCallback(fn)self._callbacks={fn}return self end function Base:
AddCallback(fn)table.insert(self._callbacks,fn)return self end function Base:
_serialize()return self.Value end function Base:_deserialize(value,silent)self:
Set(value,silent)end function Base:GetName()return self.Name end function Base:
SetName(name)self.Name=tostring(name)if self._title then self._title.Text=self.
Name end return self end Base.SetTitle=Base.SetName Base.SetText=Base.SetName
function Base:SetDescription(text)self.Description=text if self._desc then self.
_desc.Text=text or''self._desc.Visible=text~=nil and text~=''end return self end
function Base:SetTooltip(text)self.TooltipText=text return self end function
Base:SetVisible(visible)self.Visible=visible and true or false self:_applyState(
)return self end function Base:Show()return self:SetVisible(true)end function
Base:Hide()return self:SetVisible(false)end function Base:IsVisible()return self
.Visible and self._depsOk~=false end function Base:SetLocked(locked,reason)self.
Locked=locked and true or false self.LockReason=reason or(locked and self.
LockReason)or nil self:_applyState()return self end function Base:Lock(reason)
return self:SetLocked(true,reason)end function Base:Unlock()return self:
SetLocked(false)end function Base:IsLocked()return self.Locked or self.
_depsLocked==true or(self.Section~=nil and self.Section:IsDisabled())or(self.
Parent~=nil and self.Parent:IsLocked())end function Base:SetRisky(risky)self.
Risky=risky and true or false self:_applyState()return self end function Base:
SetBadge(text)self.BadgeText=text if self._badge then self._badge.Visible=text~=
nil and text~=''self._badgeLabel.Text=text or''end return self end function Base
:DependsOn(target,predicate,mode)local Lib=self.Library mode=mode or'Hide'
predicate=predicate or function(v)if type(v)=='table'then return next(v)~=nil
end return v~=nil and v~=false and v~=0 and v~=''and v~='None'end local function 
resolve()if type(target)=='string'then return Lib.Elements[target]end return
target end local function update()local el=resolve()local ok=el==nil or
predicate(el:Get())and true or false if el and el.IsVisible and not el:
IsVisible()then ok=false end if mode=='Lock'then self._depsLocked=not ok else
self._depsOk=ok end self:_applyState()end if type(target)=='table'and target.
Changed then self.Maid:Give(target.Changed:Connect(update))else self.Maid:Give(
Lib.FlagChanged:Connect(function(flag)if flag==target then update()end end))end
task.defer(update)update()return self end function Base:_build()end function
Base:_render(animate)end function Base:_mount(parent,order)if self._mounted or
self._destroyed then return end self._mounted=true self:_build(parent,order)if
self.Frame then self.Frame.LayoutOrder=order or self.Frame.LayoutOrder self:
_wireRow()end for _,link in self.Links do self:_mountLink(link)end self:_render(
false)self:_applyState()end function Base:IsMounted()return self._mounted end
function Base:_row(parent,height)local baseHeight=height or 34 height=math.
floor(baseHeight*(Shared.Density or 1)+0.5)local row=Util.New('Frame',{Name=self
.Type..'_'..self.Name,BackgroundTransparency=1,Size=UDim2.new(1,0,0,height),
Parent=parent})Theme.Paint(row,{BackgroundColor3='Surface2'})Util.Corner(6,row)
row:SetAttribute('BaseH',baseHeight)self.Frame=row local textBox=Util.New(
'Frame',{Name='Text',BackgroundTransparency=1,Size=UDim2.new(1,-110,1,0),
Position=UDim2.fromOffset(8,0),Parent=row})self._textBox=textBox local title=
Util.Label({Name='Title',Text=self.Name,FontFace=Theme.Fonts.Medium,TextSize=
Theme.Size.Body,TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,0,0,16),
Position=UDim2.new(0,0,0.5,-8),Parent=textBox})Theme.Paint(title,{TextColor3=
'Text'})self._title=title local iconId=self.Icon and Icons.Get(self.Icon)if
iconId then Util.New('UIPadding',{PaddingLeft=UDim.new(0,22),Parent=textBox})
local icon=Util.New('ImageLabel',{Name='Icon',BackgroundTransparency=1,Image=
iconId,Size=UDim2.fromOffset(15,15),Parent=textBox})Theme.Paint(icon,{
ImageColor3='TextDim'})local function follow()icon.Position=UDim2.new(0,-22,
title.Position.Y.Scale,title.Position.Y.Offset+1)end title:
GetPropertyChangedSignal('Position'):Connect(follow)follow()self._icon=icon end
if self.Description and self.Description~=''then title.Position=UDim2.new(0,0,
0.5,-15)local desc=Util.Label({Name='Description',Text=self.Description,FontFace
=Theme.Fonts.Regular,TextSize=Theme.Size.Small,TextTruncate=Enum.TextTruncate.
AtEnd,Size=UDim2.new(1,0,0,13),Position=UDim2.new(0,0,0.5,2),Parent=textBox})
Theme.Paint(desc,{TextColor3='TextMute'})self._desc=desc row.Size=UDim2.new(1,0,
0,math.max(height,42))end local badge=Util.New('Frame',{Name='Badge',
AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,14),AnchorPoint=
Vector2.new(0,0.5),Visible=false,Parent=textBox})Theme.Paint(badge,{
BackgroundColor3='Accent'})Util.Corner(4,badge)Util.Padding(badge,0,5,0,5)local
badgeLabel=Util.Label({AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromScale(0
,1),FontFace=Theme.Fonts.Bold,TextSize=9,Text='',Parent=badge})Theme.Paint(
badgeLabel,{TextColor3='AccentInk'})self._badge,self._badgeLabel=badge,
badgeLabel local function placeBadge()badge.Position=UDim2.new(0,math.min(title.
TextBounds.X,title.AbsoluteSize.X)+6,0,title.Position.Y.Offset+title.
AbsoluteSize.Y/2+(title.Position.Y.Scale*textBox.AbsoluteSize.Y))end title:
GetPropertyChangedSignal('TextBounds'):Connect(placeBadge)task.defer(placeBadge)
self:SetBadge(self.BadgeText)local right=Util.New('Frame',{Name='Right',
BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,1
,0),AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,0),Parent=row})Util.
List(right,6,Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Right,Enum.
VerticalAlignment.Center)self._right=right right:GetPropertyChangedSignal(
'AbsoluteSize'):Connect(function()textBox.Size=UDim2.new(1,-(right.AbsoluteSize.
X/math.max(Shared.Scale or 1,0.01))-26,1,0)end)local lock=Util.New('TextButton',
{Name='Lock',Text='',AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.
fromScale(1,1),ZIndex=20,Visible=false,Parent=row})local lockIcon=Util.New(
'ImageLabel',{BackgroundTransparency=1,Image=Icons.Get('lock')or'',Size=UDim2.
fromOffset(12,12),AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),
ZIndex=21,Parent=lock})Theme.Paint(lockIcon,{ImageColor3='TextMute'})self._lock=
lock return row end function Base:_wireRow()local row=self.Frame local Overlay=
Shared.Overlay row.MouseEnter:Connect(function()if not self:IsLocked()then Tween
.Play(row,{BackgroundTransparency=0.55},0.12)end end)row.MouseLeave:Connect(
function()Tween.Play(row,{BackgroundTransparency=1},0.18)end)Overlay.Hover(row,
function()if self:IsLocked()and self.LockReason then return'\u{1f512} '..self.
LockReason end if self.Library.Debug then return(self.TooltipText and(self.
TooltipText..'\n')or'')..'<font color="#8a8a92">'..self.Type..(self.Flag and(
'  \u{b7}  '..self.Flag)or'')..'</font>'end return self.TooltipText end)row.
InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.
MouseButton2 then self:OpenContextMenu(Vector2.new(input.Position.X,input.
Position.Y))end end)end function Base:_applyState()if not self._mounted or not
self.Frame then return end local visible=self.Visible and self._depsOk~=false
self.Frame.Visible=visible local locked=self:IsLocked()if self._lock then self.
_lock.Visible=locked end if self._title then local token=self.Risky and'Risky'or
(locked and'TextMute'or(self._titleToken or'Text'))Theme.Paint(self._title,{
TextColor3=token},0.15)end if self._onState then self:_onState(locked)end end
function Base:_contextItems()local T=Locale.T local items={}if self.Default~=nil
then table.insert(items,{Text=T('Reset'),Icon='rotate-ccw',Callback=function()
self:_userSet(Util.DeepCopy(self.Default))end})end if self.Value~=nil then table
.insert(items,{Text=T('Copy'),Icon='copy',Callback=function()self:Copy()end})
table.insert(items,{Text=T('Paste'),Icon='clipboard',Callback=function()self:
Paste()end})end if self.Flag then table.insert(items,{Text=T('CopyFlag'),Icon=
'hash',Hint=self.Flag,Callback=function()Env.Clipboard(self.Flag)end})end local
Lib=self.Library table.insert(items,{Separator=true})table.insert(items,{Text=
Lib:IsFavorite(self)and'\u{2605} '..T('Favorites')or'\u{2606} '..T('Favorites'),
Icon='star',Callback=function()Lib:ToggleFavorite(self)end})return items end
function Base:OpenContextMenu(at)if self:IsLocked()then return end local items=
self:_contextItems()if#items==0 then return end if not at then at=game:
GetService('UserInputService'):GetMouseLocation()-game:GetService('GuiService'):
GetGuiInset()end Shared.Overlay.Menu(items,{At=at})end local clipboard=nil
function Base:Copy()local ok,encoded=pcall(function()return HttpService:
JSONEncode({t=self.Type,v=self:_serialize()})end)if ok then clipboard=encoded
Env.Clipboard(encoded)return encoded end return''end function Base:Paste(text)
local raw=text or clipboard if not raw then return false end local ok,data=
pcall(function()return HttpService:JSONDecode(raw)end)if ok and type(data)==
'table'and data.t==self.Type then local before=Util.DeepCopy(self.Value)self:
_deserialize(data.v)self.Library:_pushHistory(self,before,Util.DeepCopy(self.
Value))return true end return false end function Base:Highlight()local row=self.
Frame if not row then return self end task.spawn(function()for _=1,2 do Theme.
Paint(row,{BackgroundColor3='Accent'})row.BackgroundTransparency=0.82 Tween.
Await(row,{BackgroundTransparency=1},0.45,Enum.EasingStyle.Sine)end Theme.Paint(
row,{BackgroundColor3='Surface2'})end)return self end function Base:Focus()local
window=self.Window if not window then return self end window:Open()if self.
Section then self.Section:_reveal()end task.delay(0.05,function()if self.Section
and self.Section.Page then self.Section.Page:ScrollTo(self.Frame)end task.delay(
0.12,function()self:Highlight()end)end)return self end Base.ScrollTo=Base.Focus
function Base:GetPath()local parts={}if self.Tab then table.insert(parts,self.
Tab.Name)end if self.Section and self.Section.Page and self.Section.Page.Name~=(
self.Tab and self.Tab.Name)and not self.Section.Page.Implicit then table.insert(
parts,self.Section.Page.Name)end if self.Section and self.Section.ParentSection
then table.insert(parts,self.Section.ParentSection.Name)end if self.Section and
self.Section.Name then table.insert(parts,self.Section.Name)end return table.
concat(parts,' \u{203a} ')end function Base:_mountLink(link)if not self._mounted
or link._mounted then return end local holder=self._right if not holder then
return end link._mounted=true link:_buildInline(holder,#self.Links)link:_render(
false)end function Base:Keybind(options)options=options or{}options.__parent=
self local link=Shared.Lib._classes.Keybind.new(self.Section,options)table.
insert(self.Links,link)self:_mountLink(link)return link end Base.AddKeybind=Base
.Keybind function Base:ColorPicker(options)options=options or{}options.__parent=
self local link=Shared.Lib._classes.ColorPicker.new(self.Section,options)table.
insert(self.Links,link)self:_mountLink(link)return link end Base.AddColorPicker=
Base.ColorPicker Base.Colorpicker=Base.ColorPicker function Base:Options(builder
)if not self._options then local Lib=Shared.Lib local section=Lib._classes.
Section.newFloating(self,type(builder)=='table'and builder or{})self._options=
section local link={_mounted=false,Type='OptionsLink'}function link._buildInline
(_,holder,order)local button=Util.New('ImageButton',{Name='Options',
BackgroundTransparency=1,Image=Icons.Get('sliders-horizontal')or Icons.Get(
'settings')or'',Size=UDim2.fromOffset(16,16),LayoutOrder=order,Parent=holder})
Theme.Paint(button,{ImageColor3='TextDim'})button.MouseEnter:Connect(function()
Theme.Paint(button,{ImageColor3='Text'},0.1)end)button.MouseLeave:Connect(
function()Theme.Paint(button,{ImageColor3='TextDim'},0.1)end)button.Activated:
Connect(function()if self:IsLocked()then return end section:Toggle(button)end)
link.Button=button end function link._render()end table.insert(self.Links,link)
self:_mountLink(link)end if type(builder)=='function'then Util.SafeCall(builder,
self._options)end return self._options end Base.Settings=Base.Options Base.
AddOption=Base.Options function Base:Destroy()if self._destroyed then return end
self._destroyed=true local Lib=self.Library if self.Flag and Lib.Elements[self.
Flag]==self then Lib.Elements[self.Flag]=nil Lib.Flags[self.Flag]=nil end local
index=table.find(Lib.AllElements,self)if index then table.remove(Lib.AllElements
,index)end if self.Section then self.Section:_remove(self)end for _,link in self
.Links do if link.Destroy then link:Destroy()end end if self._options then self.
_options:Destroy()end self.Maid:Clean()if self.Frame then self.Frame:Destroy()
end self.Destroyed:Fire()self.Changed:DisconnectAll()end Base.Remove=Base.
Destroy return Base end function __DARKLUA_BUNDLE_MODULES.n()local v=
__DARKLUA_BUNDLE_MODULES.cache.n if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.n=v end return v.c end end do local function 
__modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Tween=
__DARKLUA_BUNDLE_MODULES.d()local Theme=__DARKLUA_BUNDLE_MODULES.g()local Icons=
__DARKLUA_BUNDLE_MODULES.i()local Locale=__DARKLUA_BUNDLE_MODULES.j()local
Shared=__DARKLUA_BUNDLE_MODULES.k()local Base=__DARKLUA_BUNDLE_MODULES.n()local
classes={}local Toggle=Base.extend('Toggle')classes.Toggle=Toggle Toggle.Styles=
{'Switch','Compact','Checkbox','Chip','Radio','Square','Pill','Dot','Orbit'}
function Toggle.new(section,options)local self=Base.new(Toggle,section,options)
self.Default=Util.Opt(options,'Default','Value','State')==true self.Value=self.
Default self.Style=options.Style self.ConfirmText=options.Confirm return self:
_register()end function Toggle:_normalize(v)if v==nil then return false end
return v==true or v==1 or v=='true'end function Toggle:Toggle()return self:Set(
not self.Value)end function Toggle:On()return self:Set(true)end function Toggle:
Off()return self:Set(false)end function Toggle:IsOn()return self.Value end
function Toggle:_request(value)if value and(self.ConfirmText or self.Risky)and
not self._confirmed and self.Window then task.spawn(function()local text=type(
self.ConfirmText)=='string'and self.ConfirmText or Locale.T('RiskyConfirm')if
self.Window:Confirm({Title=self.Name,Content=text,Danger=true})then self.
_confirmed=true self:_userSet(true)end end)return end self:_userSet(value)end
function Toggle:_navActivate()self:_request(not self.Value)end function Toggle:
_navAdjust(dir)self:_request(dir>0)end function Toggle:GetStyle()return self.
Style or Shared.Lib.ToggleStyle or'Switch'end local styles={}local function 
track(holder,w,h,radius)local f=Util.New('Frame',{Name='Control',Size=UDim2.
fromOffset(w,h),LayoutOrder=100,Parent=holder})if radius then Util.Corner(radius
,f)else Util.Round(f)end local stroke=Util.Stroke(f)return f,stroke end local 
function knob(parent,size,radius)local k=Util.New('Frame',{Name='Knob',Size=
UDim2.fromOffset(size,size),AnchorPoint=Vector2.new(0,0.5),Parent=parent})if
radius then Util.Corner(radius,k)else Util.Round(k)end return k end styles.
Switch={build=function(self,holder)local f,stroke=track(holder,32,18)return{
Frame=f,Stroke=stroke,Knob=knob(f,12)}end,paint=function(r,on,t)Theme.Paint(r.
Frame,{BackgroundColor3=on and'Accent'or'Surface3'},t)Theme.Paint(r.Stroke,{
Color=on and'Accent'or'StrokeHi'},t)Tween.Play(r.Stroke,{Thickness=on and 2.5 or
1,Transparency=on and 0.75 or 0},t)Theme.Paint(r.Knob,{BackgroundColor3=on and
'AccentInk'or'TextDim'},t)Tween.Play(r.Knob,{Position=on and UDim2.new(1,-15,0.5
,0)or UDim2.new(0,3,0.5,0)},t*1.3,Enum.EasingStyle.Back)end}styles.Square={build
=function(self,holder)local f,stroke=track(holder,32,18,4)return{Frame=f,Stroke=
stroke,Knob=knob(f,12,3)}end,paint=styles.Switch.paint}styles.Compact={build=
function(self,holder)local f,stroke=track(holder,16,16)local dot=Util.New(
'Frame',{Size=UDim2.fromOffset(0,0),AnchorPoint=Vector2.new(0.5,0.5),Position=
UDim2.fromScale(0.5,0.5),Parent=f})Util.Round(dot)f.BackgroundTransparency=1
return{Frame=f,Stroke=stroke,Dot=dot}end,paint=function(r,on,t)Theme.Paint(r.
Stroke,{Color=on and'Accent'or'StrokeHi'},t)Theme.Paint(r.Dot,{BackgroundColor3=
'Accent'})Tween.Play(r.Dot,{Size=on and UDim2.fromOffset(10,10)or UDim2.
fromOffset(0,0)},t*1.4,Enum.EasingStyle.Back)end}styles.Radio={build=function(
self,holder)local f,stroke=track(holder,18,18)local dot=Util.New('Frame',{Size=
UDim2.fromOffset(8,8),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(
0.5,0.5),Parent=f})Util.Round(dot)return{Frame=f,Stroke=stroke,Dot=dot}end,paint
=function(r,on,t)Theme.Paint(r.Frame,{BackgroundColor3=on and'Accent'or
'Surface3'},t)Theme.Paint(r.Stroke,{Color=on and'Accent'or'StrokeHi'},t)Theme.
Paint(r.Dot,{BackgroundColor3='AccentInk'})Tween.Play(r.Dot,{Size=on and UDim2.
fromOffset(7,7)or UDim2.fromOffset(0,0)},t,Enum.EasingStyle.Back)end}styles.
Checkbox={build=function(self,holder)local f,stroke=track(holder,18,18,5)local
check=Util.New('ImageLabel',{BackgroundTransparency=1,Image=Icons.Get('check')or
'',Size=UDim2.fromOffset(12,12),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.
fromScale(0.5,0.5),Parent=f})return{Frame=f,Stroke=stroke,Check=check}end,paint=
function(r,on,t,animate)Theme.Paint(r.Frame,{BackgroundColor3=on and'Accent'or
'Surface3'},t)Theme.Paint(r.Stroke,{Color=on and'Accent'or'StrokeHi'},t)Theme.
Paint(r.Check,{ImageColor3='AccentInk'})r.Check.ImageTransparency=on and 0 or 1
r.Check.Size=UDim2.fromOffset(on and 12 or 4,on and 12 or 4)if animate and on
then r.Check.Size=UDim2.fromOffset(4,4)Tween.Play(r.Check,{Size=UDim2.
fromOffset(12,12)},0.22,Enum.EasingStyle.Back)end end}styles.Chip={build=
function(self,holder)local f,stroke=track(holder,40,20,5)local label=Util.Label(
{Text='OFF',FontFace=Theme.Fonts.Bold,TextSize=10,TextXAlignment=Enum.
TextXAlignment.Center,Size=UDim2.fromScale(1,1),Parent=f})return{Frame=f,Stroke=
stroke,Label=label}end,paint=function(r,on,t)Theme.Paint(r.Frame,{
BackgroundColor3=on and'Accent'or'Surface3'},t)Theme.Paint(r.Stroke,{Color=on
and'Accent'or'StrokeHi'},t)Theme.Paint(r.Label,{TextColor3=on and'AccentInk'or
'TextMute'},t)r.Label.Text=on and'ON'or'OFF'end}styles.Pill={build=function(self
,holder)local f,stroke=track(holder,52,20)local k=Util.New('Frame',{Size=UDim2.
fromOffset(24,14),AnchorPoint=Vector2.new(0,0.5),Parent=f})Util.Round(k)local
label=Util.Label({Text='',FontFace=Theme.Fonts.Bold,TextSize=9,TextXAlignment=
Enum.TextXAlignment.Center,Size=UDim2.fromScale(1,1),Parent=k})return{Frame=f,
Stroke=stroke,Knob=k,Label=label}end,paint=function(r,on,t)Theme.Paint(r.Frame,{
BackgroundColor3='Surface3'},t)Theme.Paint(r.Stroke,{Color=on and'Accent'or
'StrokeHi'},t)Theme.Paint(r.Knob,{BackgroundColor3=on and'Accent'or'Surface2'},t
)Theme.Paint(r.Label,{TextColor3=on and'AccentInk'or'TextMute'},t)r.Label.Text=
on and'ON'or'OFF'Tween.Play(r.Knob,{Position=on and UDim2.new(1,-27,0.5,0)or
UDim2.new(0,3,0.5,0)},t*1.3,Enum.EasingStyle.Quint)end}styles.Dot={build=
function(self,holder)local f=Util.New('Frame',{Name='Control',
BackgroundTransparency=1,Size=UDim2.fromOffset(18,18),LayoutOrder=100,Parent=
holder})local dot=Util.New('Frame',{Size=UDim2.fromOffset(8,8),AnchorPoint=
Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Parent=f})Util.Round(dot)
local halo=Util.Stroke(dot,nil,4,1)return{Frame=f,Dot=dot,Halo=halo}end,paint=
function(r,on,t)Theme.Paint(r.Dot,{BackgroundColor3=on and'Accent'or'StrokeHi'},
t)Theme.Paint(r.Halo,{Color='Accent'})Tween.Play(r.Halo,{Transparency=on and
0.75 or 1},t)end}styles.Orbit={build=function(self,holder)local f=Util.New(
'Frame',{Name='Control',BackgroundTransparency=1,Size=UDim2.fromOffset(34,20),
LayoutOrder=100,Parent=holder})local ring=Util.New('Frame',{
BackgroundTransparency=1,Size=UDim2.fromOffset(34,12),AnchorPoint=Vector2.new(
0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Rotation=-12,Parent=f})Util.Round(
ring)local stroke=Util.Stroke(ring)local planet=Util.New('Frame',{Size=UDim2.
fromOffset(10,10),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,
0.5),Parent=f})Util.Round(planet)local moon=Util.New('Frame',{Size=UDim2.
fromOffset(6,6),AnchorPoint=Vector2.new(0.5,0.5),Parent=f})Util.Round(moon)
return{Frame=f,Stroke=stroke,Planet=planet,Moon=moon}end,paint=function(r,on,t)
Theme.Paint(r.Stroke,{Color=on and'Accent'or'StrokeHi'},t)Theme.Paint(r.Planet,{
BackgroundColor3=on and'Accent'or'Surface3'},t)Theme.Paint(r.Moon,{
BackgroundColor3=on and'Accent'or'TextMute'},t)Tween.Play(r.Moon,{Position=on
and UDim2.new(1,-2,0.32,0)or UDim2.new(0,2,0.68,0)},t*1.6,Enum.EasingStyle.Sine)
end}Toggle._styleImpl=styles function Toggle:_buildControl()if self._control and
self._control.Frame then self._control.Frame:Destroy()end local style=styles[
self:GetStyle()]or styles.Switch self._styleImpl=style self._control=style.
build(self,self._right)end function Toggle:_build(parent)local row=self:_row(
parent)self:_buildControl()local hit=Util.Hitbox(row,0)hit.Activated:Connect(
function()if not self:IsLocked()then self:_request(not self.Value)end end)self.
_hit=hit end function Toggle:_render(animate)local t=animate and 0.18 or 0 local
on=self.Value self._titleToken=on and'Text'or'TextDim'if self._title and not
self.Risky and not self:IsLocked()then Theme.Paint(self._title,{TextColor3=self.
_titleToken},t)end if self._icon then Theme.Paint(self._icon,{ImageColor3=on and
'Accent'or'TextMute'},t)end if self._control and self._styleImpl then self.
_styleImpl.paint(self._control,on,t,animate)end end function Toggle:SetStyle(
style)self.Style=style if self._mounted then self:_buildControl()self:_render(
false)end return self end local Button=Base.extend('Button')classes.Button=
Button function Button.new(section,options)local self=Base.new(Button,section,
options)self.Style=options.Style or'Secondary'self.Icon=options.Icon self.Hint=
options.Hint self.ConfirmText=options.Confirm self.DoubleClick=options.
DoubleClick self.Cooldown=options.Cooldown or 0 self._last=0 return self:
_register()end function Button:_callbackArgs()return nil end function Button:
_navActivate()self:_activate()end function Button:Press()if self:IsLocked()then
return self end local now=os.clock()if now-self._last<self.Cooldown then return
self end self._last=now self:_fireCallbacks()return self end Button.Click=Button
.Press function Button:_activate()if self:IsLocked()then return end if self.
DoubleClick and not self._armed then self._armed=true self._label.Text=Locale.T(
'Confirm')..'?'task.delay(2,function()self._armed=false if self._label then self
._label.Text=self.Name end end)return end self._armed=false if self._label then
self._label.Text=self.Name end if self.ConfirmText and self.Window then task.
spawn(function()if self.Window:Confirm({Title=self.Name,Content=type(self.
ConfirmText)=='string'and self.ConfirmText or nil,Danger=self.Style=='Danger'})
then self:Press()end end)return end self:Press()end local buttonStyles={Primary=
{Bg='Accent',Text='AccentInk',Stroke='Accent',BgT=0},Secondary={Bg='Surface3',
Text='Text',Stroke='Stroke',BgT=0},Ghost={Bg='Surface3',Text='TextDim',Stroke=
'Stroke',BgT=1},Danger={Bg='Surface3',Text='Risky',Stroke='Risky',BgT=0}}
function Button:_build(parent)local row=Util.New('Frame',{Name='Button_'..self.
Name,BackgroundTransparency=1,Size=UDim2.new(1,0,0,34),Parent=parent})self.Frame
=row local button=Util.New('TextButton',{Text='',AutoButtonColor=false,Size=
UDim2.new(1,0,0,30),Position=UDim2.fromOffset(0,2),ClipsDescendants=true,Parent=
row})Util.Corner(6,button)local stroke=Util.Stroke(button)local label=Util.
Label({Text=self.Name,FontFace=Theme.Fonts.SemiBold,TextSize=Theme.Size.Body,
TextXAlignment=Enum.TextXAlignment.Center,Size=UDim2.fromScale(1,1),Parent=
button})local icon=Util.New('ImageLabel',{BackgroundTransparency=1,Size=UDim2.
fromOffset(15,15),AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,10,0.5,0),
Parent=button})local hint=Util.Label({FontFace=Theme.Fonts.Mono,TextSize=11,
TextXAlignment=Enum.TextXAlignment.Right,Size=UDim2.new(1,-10,1,0),Parent=button
})local scaleObj=Util.New('UIScale',{Parent=button})self._button,self._stroke,
self._label,self._icon,self._hintLabel,self._title=button,stroke,label,icon,hint
,label self._right=Util.New('Frame',{BackgroundTransparency=1,AutomaticSize=Enum
.AutomaticSize.X,Size=UDim2.new(0,0,1,0),AnchorPoint=Vector2.new(1,0),Position=
UDim2.new(1,-8,0,0),Parent=button})Util.List(self._right,6,Enum.FillDirection.
Horizontal,Enum.HorizontalAlignment.Right,Enum.VerticalAlignment.Center)self.
_lock=Util.New('TextButton',{Text='',BackgroundTransparency=1,Size=UDim2.
fromScale(1,1),ZIndex=20,Visible=false,Parent=row})button.MouseEnter:Connect(
function()Tween.Play(stroke,{Transparency=0},0.1)Theme.Paint(stroke,{Color=self.
Style=='Danger'and'Risky'or'StrokeHi'},0.1)end)button.MouseLeave:Connect(
function()Theme.Paint(stroke,{Color=buttonStyles[self.Style].Stroke},0.15)Tween.
Play(scaleObj,{Scale=1},0.15)end)button.MouseButton1Down:Connect(function()Tween
.Play(scaleObj,{Scale=0.97},0.08)end)button.MouseButton1Up:Connect(function()
Tween.Play(scaleObj,{Scale=1},0.2,Enum.EasingStyle.Back)end)button.Activated:
Connect(function(input)self:_ripple(input)self:_activate()end)end function
Button:_ripple(input)local button=self._button if not button or Tween.Speed==0
then return end local pos=input and input.Position and Vector2.new(input.
Position.X,input.Position.Y)or(button.AbsolutePosition+button.AbsoluteSize/2)
local rel=pos-button.AbsolutePosition local s=Shared.Scale or 1 local circle=
Util.New('Frame',{BackgroundTransparency=0.82,AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.fromOffset(rel.X/s,rel.Y/s),Size=UDim2.fromOffset(0,0),ZIndex=3,
Parent=button})Theme.Paint(circle,{BackgroundColor3=self.Style=='Primary'and
'AccentInk'or'Accent'})Util.Round(circle)local size=math.max(button.AbsoluteSize
.X,button.AbsoluteSize.Y)*2/s Tween.Play(circle,{Size=UDim2.fromOffset(size,size
),BackgroundTransparency=1},0.5)task.delay(0.5,function()circle:Destroy()end)end
function Button:_render()local style=buttonStyles[self.Style]or buttonStyles.
Secondary Theme.Paint(self._button,{BackgroundColor3=style.Bg})self._button.
BackgroundTransparency=style.BgT Theme.Paint(self._stroke,{Color=style.Stroke})
Theme.Paint(self._label,{TextColor3=style.Text})Theme.Paint(self._hintLabel,{
TextColor3=self.Style=='Primary'and'AccentInk'or'TextMute'})local icon=Icons.
Get(self.Icon)self._icon.Image=icon or''self._icon.Visible=icon~=nil Theme.
Paint(self._icon,{ImageColor3=style.Text})self._hintLabel.Text=self.Hint or''
self._label.Text=self.Name end function Button:_onState(locked)if self._button
then self._button.BackgroundTransparency=locked and 0.6 or(buttonStyles[self.
Style]or buttonStyles.Secondary).BgT Theme.Paint(self._label,{TextColor3=locked
and'TextMute'or(buttonStyles[self.Style]or buttonStyles.Secondary).Text})end end
function Button:SetStyle(style)self.Style=buttonStyles[style]and style or
'Secondary'if self._mounted then self:_render()end return self end function
Button:SetIcon(icon)self.Icon=icon if self._mounted then self:_render()end
return self end function Button:SetHint(text)self.Hint=text if self._mounted
then self:_render()end return self end function Button:SetCooldown(seconds)self.
Cooldown=seconds return self end function Button:_applyState()if not self.
_mounted then return end self.Frame.Visible=self.Visible and self._depsOk~=false
self._lock.Visible=self:IsLocked()self:_onState(self:IsLocked())end function
Button:_contextItems()return{}end local ButtonGroup=Base.extend('ButtonGroup')
classes.ButtonGroup=ButtonGroup function ButtonGroup.new(section,options)local
buttons=options.Buttons or options local self=Base.new(ButtonGroup,section,{Name
=options.Name or'Buttons'})self.ButtonsSpec={}for _,spec in buttons do if type(
spec)=='table'then table.insert(self.ButtonsSpec,spec)end end return self:
_register()end function ButtonGroup:_build(parent)local row=Util.New('Frame',{
Name='ButtonGroup',BackgroundTransparency=1,Size=UDim2.new(1,0,0,34),Parent=
parent})self.Frame=row local n=#self.ButtonsSpec for i,spec in self.ButtonsSpec
do local style=buttonStyles[spec.Style or'Secondary']or buttonStyles.Secondary
local b=Util.New('TextButton',{Text=spec.Name or spec[1]or'',FontFace=Theme.
Fonts.SemiBold,TextSize=Theme.Size.Body,AutoButtonColor=false,Size=UDim2.new(1/n
,-(6*(n-1))/n,0,30),Position=UDim2.new((i-1)/n,(i-1)*6/n,0,2),Parent=row})Util.
Corner(6,b)Theme.Paint(b,{BackgroundColor3=style.Bg,TextColor3=style.Text})local
stroke=Util.Stroke(b)Theme.Paint(stroke,{Color=style.Stroke})b.MouseEnter:
Connect(function()Theme.Paint(stroke,{Color='StrokeHi'},0.1)end)b.MouseLeave:
Connect(function()Theme.Paint(stroke,{Color=style.Stroke},0.1)end)b.Activated:
Connect(function()if not self:IsLocked()then Util.SafeCall(spec.Callback or spec
[2])end end)end end function ButtonGroup:_contextItems()return{}end local Label=
Base.extend('Label')classes.Label=Label function Label.new(section,options)if
type(options)~='table'then options={Text=tostring(options)}end local self=Base.
new(Label,section,options)self.Color=options.Color self.Icon=options.Icon self.
Center=options.Center self.Rich=options.RichText return self:_register()end
function Label:_build(parent)local row=self:_row(parent,26)self._title.FontFace=
Theme.Fonts.Regular self._title.RichText=self.Rich==true if self.Center then
self._title.TextXAlignment=Enum.TextXAlignment.Center self._textBox.Size=UDim2.
new(1,-16,1,0)end self._titleToken=type(self.Color)=='string'and self.Color or
'TextDim'if typeof(self.Color)=='Color3'then Theme.Paint(self._title,{TextColor3
=self.Color})end return row end function Label:SetColor(color)self.Color=color
self._titleToken=type(color)=='string'and color or'TextDim'if self._title then
Theme.Paint(self._title,{TextColor3=color})end return self end function Label:
_contextItems()return{}end local Paragraph=Base.extend('Paragraph')classes.
Paragraph=Paragraph function Paragraph.new(section,options)if type(options)~=
'table'then options={Content=tostring(options)}end local self=Base.new(Paragraph
,section,{Name=options.Title or options.Name or'',Visible=options.Visible})self.
Content=Util.Opt(options,'Content','Text','Body')or''self.Rich=options.RichText
~=false return self:_register()end function Paragraph:_build(parent)local row=
Util.New('Frame',{Name='Paragraph',BackgroundTransparency=1,AutomaticSize=Enum.
AutomaticSize.Y,Size=UDim2.new(1,0,0,0),Parent=parent})self.Frame=row Util.
Padding(row,4,8,6,8)Util.List(row,3)local title=Util.Label({Text=self.Name,
FontFace=Theme.Fonts.SemiBold,TextSize=Theme.Size.Body,AutomaticSize=Enum.
AutomaticSize.Y,TextWrapped=true,LayoutOrder=1,Visible=self.Name~='',Parent=row}
)Theme.Paint(title,{TextColor3='Text'})local body=Util.Label({Text=self.Content,
FontFace=Theme.Fonts.Regular,TextSize=12,RichText=self.Rich,TextWrapped=true,
AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),LineHeight=1.1,
LayoutOrder=2,Parent=row})Theme.Paint(body,{TextColor3='TextDim'})self._title,
self._body=title,body end function Paragraph:SetContent(text)self.Content=text
if self._body then self._body.Text=text end return self end Paragraph.Set=
Paragraph.SetContent function Paragraph:Get()return self.Content end function
Paragraph:SetTitle(text)self.Name=text if self._title then self._title.Text=text
self._title.Visible=text~=''end return self end function Paragraph:_applyState()
if self.Frame then self.Frame.Visible=self.Visible and self._depsOk~=false end
end local Divider=Base.extend('Divider')classes.Divider=Divider function Divider
.new(section,options)if type(options)~='table'then options={Text=options}end
local self=Base.new(Divider,section,{Name=options.Text or options.Name or''})
return self:_register()end function Divider:_build(parent)local row=Util.New(
'Frame',{Name='Divider',BackgroundTransparency=1,Size=UDim2.new(1,0,0,self.Name
~=''and 24 or 11),Parent=parent})self.Frame=row local line=Util.New('Frame',{
BorderSizePixel=0,Size=UDim2.new(1,-16,0,1),Position=UDim2.new(0,8,0.5,0),Parent
=row})Theme.Paint(line,{BackgroundColor3='Stroke'})if self.Name~=''then local
label=Util.Label({Text=string.upper(self.Name),FontFace=Theme.Fonts.Bold,
TextSize=10,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,14),
Position=UDim2.new(0,8,0.5,-7),Parent=row})Theme.Paint(label,{TextColor3=
'TextMute'})Util.Padding(label,0,6,0,0)local cover=Util.New('Frame',{
BorderSizePixel=0,Size=UDim2.new(0,0,0,14),AutomaticSize=Enum.AutomaticSize.X,
Position=label.Position,ZIndex=0,Parent=row})cover.BackgroundTransparency=1 line
.Position=UDim2.new(0,0,0.5,0)label:GetPropertyChangedSignal('AbsoluteSize'):
Connect(function()local w=label.AbsoluteSize.X/(Shared.Scale or 1)+14 line.
Position=UDim2.new(0,w,0.5,0)line.Size=UDim2.new(1,-w-8,0,1)end)end end function
Divider:_applyState()if self.Frame then self.Frame.Visible=self.Visible and self
._depsOk~=false end end classes.Separator=Divider local Spacer=Base.extend(
'Spacer')classes.Spacer=Spacer function Spacer.new(section,options)local self=
Base.new(Spacer,section,{Name='Spacer'})self.Height=type(options)=='number'and
options or(type(options)=='table'and options.Height)or 8 return self:_register()
end function Spacer:_build(parent)self.Frame=Util.New('Frame',{
BackgroundTransparency=1,Size=UDim2.new(1,0,0,self.Height),Parent=parent})end
function Spacer:_applyState()end local Navigate=Base.extend('Navigate')classes.
Navigate=Navigate function Navigate.new(section,options)local self=Base.new(
Navigate,section,options)self.Target=options.Page or options.Target self.Icon=
options.Icon self.Value2=options.Value return self:_register()end function
Navigate:_callbackArgs()return nil end function Navigate:_navActivate()if self.
Target and self.Target.Select then self.Target:Select()end self:_fireCallbacks()
end function Navigate:_build(parent)local row=self:_row(parent)local value=Util.
Label({Text=self.Value2 or'',FontFace=Theme.Fonts.Regular,TextSize=12,
AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,16),LayoutOrder=99,
Parent=self._right})Theme.Paint(value,{TextColor3='TextMute'})self._valueLabel=
value local arrow=Util.New('ImageLabel',{BackgroundTransparency=1,Image=Icons.
Get('chevron-right')or'',Size=UDim2.fromOffset(15,15),LayoutOrder=100,Parent=
self._right})Theme.Paint(arrow,{ImageColor3='TextDim'})local hit=Util.Hitbox(row
,0)hit.Activated:Connect(function()if self:IsLocked()then return end if self.
Target and self.Target.Select then self.Target:Select()end self:_fireCallbacks()
end)end function Navigate:SetValue(text)self.Value2=text if self._valueLabel
then self._valueLabel.Text=text or''end return self end function Navigate:
_contextItems()return{}end return classes end function __DARKLUA_BUNDLE_MODULES.
o()local v=__DARKLUA_BUNDLE_MODULES.cache.o if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.o=v end return v.c end end do local function 
__modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Tween=
__DARKLUA_BUNDLE_MODULES.d()local Env=__DARKLUA_BUNDLE_MODULES.e()local Theme=
__DARKLUA_BUNDLE_MODULES.g()__DARKLUA_BUNDLE_MODULES.i()local Shared=
__DARKLUA_BUNDLE_MODULES.k()local Base=__DARKLUA_BUNDLE_MODULES.n()local UIS=Env
.Service('UserInputService')local Slider=Base.extend('Slider')function Slider.
new(section,options)local self=Base.new(Slider,section,options)self.Min=options.
Min or 0 self.Max=options.Max or 100 if self.Min>self.Max then Shared.Lib:
_optionWarning('Slider',self.Name,string.format(
'Min (%s) is bigger than Max (%s), swapped them',tostring(self.Min),tostring(
self.Max)))self.Min,self.Max=self.Max,self.Min end self.Labels=options.Labels or
options.TextProps if self.Labels then self.Min,self.Max,self.Step=1,#self.Labels
,1 else local decimals=options.Decimals or options.Rounding or options.Round
self.Step=options.Step or options.Increment or(decimals and 10^-decimals)or 1
end self.Range=options.Range==true self.Suffix=options.Suffix or''self.Prefix=
options.Prefix or''self.Format=options.Format self.Presets=options.Presets local
default=Util.Opt(options,'Default','Value')if self.Range then default=default or
{self.Min,self.Max}elseif self.Labels and type(default)=='string'then default=
table.find(self.Labels,default)or 1 end self.Default=self:_normalize(default~=
nil and default or self.Min)self.Value=Util.DeepCopy(self.Default)return self:
_register()end function Slider:_snap(v)v=tonumber(v)if not v then return nil end
return Util.Clamp(Util.Snap(v,self.Step,self.Min),self.Min,self.Max)end function
Slider:_normalize(v)if self.Range then if type(v)~='table'then return nil end
local a=self:_snap(v.Min or v[1])local b=self:_snap(v.Max or v[2])if not a or
not b then return nil end if a>b then a,b=b,a end return{Min=a,Max=b}end if self
.Labels and type(v)=='string'then v=table.find(self.Labels,v)end return self:
_snap(v)end function Slider:_callbackArgs()if self.Labels then return self.
Labels[self.Value],self.Value end return self.Value end function Slider:GetText(
)return self:_format(self.Value)end function Slider:_format(v)if self.Range and
type(v)=='table'then return self:_format(v.Min)..' - '..self:_format(v.Max)end
if self.Labels then return tostring(self.Labels[v]or v)end if self.Format then
local ok,text=pcall(self.Format,v)if ok then return tostring(text)end end return
self.Prefix..Util.FormatNumber(v,Util.Decimals(self.Step))..self.Suffix end
function Slider:GetPercent()local v=self.Range and self.Value.Max or self.Value
return(v-self.Min)/math.max(self.Max-self.Min,1e-9)end function Slider:SetMin(
min)self.Min=min self:Set(self.Value,true)if self._mounted then self:_render(
true)end return self end function Slider:SetMax(max)self.Max=max self:Set(self.
Value,true)if self._mounted then self:_render(true)end return self end function
Slider:SetLimits(min,max)self.Min,self.Max=min,max local v=self:_normalize(self.
Value)if v~=nil then self.Value=v end if self._mounted then self:_render(true)
end return self end Slider.SetRange=Slider.SetLimits function Slider:SetStep(
step)self.Step=step return self end function Slider:Increment(n)if self.Range
then return self end return self:Set(self.Value+(n or 1)*self.Step)end function
Slider:Decrement(n)return self:Increment(-(n or 1))end function Slider:
_navActivate()end function Slider:_navAdjust(dir)if not self.Range then self:
_userSet(self.Value+dir*self.Step)end end function Slider:_serialize()if self.
Range then return{self.Value.Min,self.Value.Max}end return self.Value end
function Slider:_build(parent)local row=self:_row(parent,46)row.Size=UDim2.new(1
,0,0,self.Description and 54 or 46)local textBox=self._textBox textBox.Size=
UDim2.new(1,-16,0,22)textBox.Position=UDim2.fromOffset(8,2)self._title.Position=
UDim2.new(0,0,0,4)if self._desc then self._desc.Position=UDim2.new(0,0,0,20)end
self._right.Size=UDim2.new(0,0,0,26)local value=Util.New('TextBox',{Name='Value'
,BackgroundTransparency=1,ClearTextOnFocus=false,TextEditable=false,Text='',
FontFace=Theme.Fonts.Mono,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,
AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,16),LayoutOrder=100,
Parent=self._right})Theme.Paint(value,{TextColor3='Text'})self._valueBox=value
local trackHolder=Util.New('TextButton',{Name='Track',Text='',AutoButtonColor=
false,BackgroundTransparency=1,Size=UDim2.new(1,-16,0,16),Position=UDim2.new(0,8
,1,-20),Parent=row})local track=Util.New('Frame',{Size=UDim2.new(1,0,0,4),
AnchorPoint=Vector2.new(0,0.5),Position=UDim2.fromScale(0,0.5),Parent=
trackHolder})Util.Round(track)Theme.Paint(track,{BackgroundColor3='Surface3'})
local fill=Util.New('Frame',{Size=UDim2.fromScale(0,1),Parent=track})Util.Round(
fill)Theme.Paint(fill,{BackgroundColor3='Accent'})local function knob()local k=
Util.New('Frame',{Size=UDim2.fromOffset(10,10),AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.fromScale(0,0.5),ZIndex=3,Parent=track})Util.Round(k)Theme.Paint(
k,{BackgroundColor3='Accent'})local ring=Util.Stroke(k,nil,2)Theme.Paint(ring,{
Color='Bg'})return k end self._track,self._fill=track,fill self._knobA=knob()if
self.Range then self._knobB=knob()end if self.Labels and#self.Labels<=12 then
for i=1,#self.Labels do local tick=Util.New('Frame',{Size=UDim2.fromOffset(2,2),
AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale((i-1)/math.max(#self.
Labels-1,1),0.5),ZIndex=2,Parent=track})Util.Round(tick)Theme.Paint(tick,{
BackgroundColor3='TextMute'})end end local dragging,which=false,nil local 
function valueAt(x)local rel=math.clamp((x-track.AbsolutePosition.X)/math.max(
track.AbsoluteSize.X,1),0,1)return self.Min+(self.Max-self.Min)*rel end local 
function apply(x)local v=valueAt(x)if self.Range then local cur=self.Value if
which=='A'then self:Set({Min=math.min(v,cur.Max),Max=cur.Max})else self:Set({Min
=cur.Min,Max=math.max(v,cur.Min)})end else self:Set(v)end end trackHolder.
InputBegan:Connect(function(input)if self:IsLocked()then return end if input.
UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.
UserInputType.Touch then dragging=true self._dragStart=Util.DeepCopy(self.Value)
if self.Range then local v=valueAt(input.Position.X)which=math.abs(v-self.Value.
Min)<=math.abs(v-self.Value.Max)and'A'or'B'end Tween.Play(self._knobA,{Size=
UDim2.fromOffset(14,14)},0.12)if self._knobB then Tween.Play(self._knobB,{Size=
UDim2.fromOffset(14,14)},0.12)end apply(input.Position.X)end end)self.Maid:
Connect(UIS.InputChanged,function(input)if dragging and(input.UserInputType==
Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.
Touch)then apply(input.Position.X)end end)self.Maid:Connect(UIS.InputEnded,
function(input)if dragging and(input.UserInputType==Enum.UserInputType.
MouseButton1 or input.UserInputType==Enum.UserInputType.Touch)then dragging=
false Tween.Play(self._knobA,{Size=UDim2.fromOffset(10,10)},0.15)if self._knobB
then Tween.Play(self._knobB,{Size=UDim2.fromOffset(10,10)},0.15)end if not Util.
Equal(self._dragStart,self.Value)then self.Library:_pushHistory(self,self.
_dragStart,Util.DeepCopy(self.Value))end end end)local hovered=false row.
MouseEnter:Connect(function()hovered=true end)row.MouseLeave:Connect(function()
hovered=false end)self.Maid:Connect(UIS.InputBegan,function(input,processed)if
not hovered or processed or self.Range or self:IsLocked()then return end local
mult=(UIS:IsKeyDown(Enum.KeyCode.LeftShift)or UIS:IsKeyDown(Enum.KeyCode.
RightShift))and 10 or 1 if input.KeyCode==Enum.KeyCode.Right or input.KeyCode==
Enum.KeyCode.Up then self:_userSet(self.Value+self.Step*mult)elseif input.
KeyCode==Enum.KeyCode.Left or input.KeyCode==Enum.KeyCode.Down then self:
_userSet(self.Value-self.Step*mult)end end)local lastClick=0 value.InputBegan:
Connect(function(input)if input.UserInputType~=Enum.UserInputType.MouseButton1
or self.Range or self.Labels or self:IsLocked()then return end local now=os.
clock()if now-lastClick<0.35 then value.TextEditable=true value.Text=Util.
FormatNumber(self.Value,Util.Decimals(self.Step))value:CaptureFocus()end
lastClick=now end)value.FocusLost:Connect(function()if value.TextEditable then
value.TextEditable=false local n=tonumber((string.gsub(value.Text,'[^%d%.%-]',''
)))if n then self:_userSet(n)end self:_render(false)end end)if self.Presets then
row.Size=UDim2.new(1,0,0,row.Size.Y.Offset+24)trackHolder.Position=UDim2.new(0,8
,1,-44)local chips=Util.New('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,-
16,0,20),Position=UDim2.new(0,8,1,-22),Parent=row})Util.List(chips,4,Enum.
FillDirection.Horizontal)local names=Util.Keys(self.Presets)table.sort(names,
function(a,b)local va,vb=self.Presets[a],self.Presets[b]if type(va)=='number'and
type(vb)=='number'then return va<vb end return tostring(a)<tostring(b)end)for _,
name in names do local chip=Util.New('TextButton',{Text=tostring(name),FontFace=
Theme.Fonts.Medium,TextSize=11,AutoButtonColor=false,AutomaticSize=Enum.
AutomaticSize.X,Size=UDim2.fromOffset(0,18),Parent=chips})Util.Padding(chip,0,8,
0,8)Util.Corner(4,chip)Theme.Paint(chip,{BackgroundColor3='Surface3',TextColor3=
'TextDim'})chip.Activated:Connect(function()if not self:IsLocked()then self:
_userSet(self.Presets[name])end end)end end end function Slider:_render(animate)
if not self._fill then return end local t=animate and 0.08 or 0 local span=math.
max(self.Max-self.Min,1e-9)if self.Range then local a=(self.Value.Min-self.Min)/
span local b=(self.Value.Max-self.Min)/span Tween.Play(self._fill,{Position=
UDim2.fromScale(a,0),Size=UDim2.fromScale(b-a,1)},t)Tween.Play(self._knobA,{
Position=UDim2.fromScale(a,0.5)},t)Tween.Play(self._knobB,{Position=UDim2.
fromScale(b,0.5)},t)else local p=(self.Value-self.Min)/span self._fill.Visible=p
>0.015 Tween.Play(self._fill,{Size=UDim2.fromScale(p,1)},t)Tween.Play(self.
_knobA,{Position=UDim2.fromScale(p,0.5)},t)end if not self._valueBox.
TextEditable then self._valueBox.Text=self:_format(self.Value)end end function
Slider:_onState(locked)if self._fill then Theme.Paint(self._fill,{
BackgroundColor3=locked and'TextMute'or'Accent'},0.15)Theme.Paint(self._knobA,{
BackgroundColor3=locked and'TextMute'or'Accent'},0.15)if self._knobB then Theme.
Paint(self._knobB,{BackgroundColor3=locked and'TextMute'or'Accent'},0.15)end end
end return{Slider=Slider}end function __DARKLUA_BUNDLE_MODULES.p()local v=
__DARKLUA_BUNDLE_MODULES.cache.p if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.p=v end return v.c end end do local function 
__modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Tween=
__DARKLUA_BUNDLE_MODULES.d()local Env=__DARKLUA_BUNDLE_MODULES.e()local Theme=
__DARKLUA_BUNDLE_MODULES.g()local Icons=__DARKLUA_BUNDLE_MODULES.i()local Locale
=__DARKLUA_BUNDLE_MODULES.j()local Shared=__DARKLUA_BUNDLE_MODULES.k()local Base
=__DARKLUA_BUNDLE_MODULES.n()local Players=Env.Service('Players')local classes={
}local Dropdown=Base.extend('Dropdown')classes.Dropdown=Dropdown function
Dropdown.new(section,options)local self=Base.new(Dropdown,section,options)self.
Values=table.clone(Util.Opt(options,'Values','Options','Items','List')or{})self.
Multi=options.Multi==true self.MaxSelect=options.Max self.MinSelect=options.Min
or 0 self.Placeholder=options.Placeholder or Locale.T('None')self.AllowNone=
options.AllowNone~=false self.SearchEnabled=options.Search self.Deletable=
options.Deletable self.OnDelete=options.OnDelete self.ValueIcons=options.Icons
or{}self.Prefixes=options.Prefixes or options.Flags or{}self.Display=options.
Display local default=Util.Opt(options,'Default','Value')if self.Multi then
default=type(default)=='table'and default or(default~=nil and{default}or{})end
self.Default=self:_normalize(default)or(self.Multi and{}or nil)self.Value=Util.
DeepCopy(self.Default)local default=Util.Opt(options,'Default','Value')if
default~=nil and not self.Multi and self.Value==nil then Shared.Lib:
_optionWarning('Dropdown',self.Name,'default value '..tostring(default)..
' is not in Values')end return self:_register()end function Dropdown:_normalize(
v)if self.Multi then if type(v)~='table'then v=v~=nil and{v}or{}end local out,
seen={},{}local list=v if#v==0 and next(v)~=nil then list={}for k,on in v do if
on then table.insert(list,k)end end end for _,item in list do if table.find(self
.Values,item)and not seen[item]then seen[item]=true table.insert(out,item)end
end table.sort(out,function(a,b)return(table.find(self.Values,a)or 0)<(table.
find(self.Values,b)or 0)end)return out end if v==nil then return nil end if
table.find(self.Values,v)then return v end return nil end function Dropdown:Set(
value,silent)if not self.Multi and value==nil then if self.Value==nil then
return self end local old=self.Value self.Value=nil if self.Flag then self.
Library.Flags[self.Flag]=nil end if self._mounted then self:_render(true)end if
not silent then self:_fireCallbacks()end self.Changed:Fire(nil,old)self.Library:
_onElementChanged(self,nil,old)return self end return Base.Set(self,value,silent
)end function Dropdown:_text(v)if v==nil then return self.Placeholder end local
text=self.Display and self.Display(v)or tostring(v)local prefix=self.Prefixes[v]
return prefix and(prefix..'  '..text)or text end function Dropdown:GetText()if
self.Multi then local n=#self.Value if n==0 then return self.Placeholder elseif
n<=2 then local parts={}for _,v in self.Value do table.insert(parts,self:_text(v
))end return table.concat(parts,', ')end return self:_text(self.Value[1])..', +'
..(n-1)end return self:_text(self.Value)end function Dropdown:IsSelected(v)if
self.Multi then return table.find(self.Value,v)~=nil end return self.Value==v
end function Dropdown:Select(v)if self.Multi then if self:IsSelected(v)then
return self end if self.MaxSelect and#self.Value>=self.MaxSelect then return
self end local nv=table.clone(self.Value)table.insert(nv,v)return self:Set(nv)
end return self:Set(v)end function Dropdown:Deselect(v)if self.Multi then local
nv=table.clone(self.Value)local i=table.find(nv,v)if i and#nv>self.MinSelect
then table.remove(nv,i)return self:Set(nv)end return self end if self.Value==v
and self.AllowNone then return self:Set(nil)end return self end function
Dropdown:_pick(v)local before=Util.DeepCopy(self.Value)if self.Multi then if
self:IsSelected(v)then self:Deselect(v)else self:Select(v)end else if self.Value
==v and self.AllowNone and self.Opts.Toggleable then self:Set(nil)else self:Set(
v)end self:Close()end if not Util.Equal(before,self.Value)then self.Library:
_pushHistory(self,before,Util.DeepCopy(self.Value))end end function Dropdown:
GetValues()return table.clone(self.Values)end function Dropdown:SetValues(values
,keep)self.Values=table.clone(values or{})local current=self.Value if keep~=
false then local nv=self:_normalize(current)if self.Multi then self.Value=nv or{
}else self.Value=nv end else self.Value=self.Multi and{}or nil end if self.Flag
then self.Library.Flags[self.Flag]=self.Value end if self._mounted then self:
_render(false)end if self._popup and self._popup.Open then self:_fillList()end
if not Util.Equal(current,self.Value)then self:_fireCallbacks()self.Changed:
Fire(self.Value,current)end return self end Dropdown.Refresh=Dropdown.SetValues
function Dropdown:AddValue(v)if not table.find(self.Values,v)then local list=
table.clone(self.Values)table.insert(list,v)self:SetValues(list,true)end return
self end Dropdown.Add=Dropdown.AddValue function Dropdown:RemoveValue(v)local
list=table.clone(self.Values)local i=table.find(list,v)if i then table.remove(
list,i)self:SetValues(list,true)end return self end Dropdown.Remove=Dropdown.
RemoveValue function Dropdown:Clear()return self:Set(self.Multi and{}or nil)end
function Dropdown:_serialize()return self.Value end function Dropdown:
_navActivate()if self:IsOpen()then self:Close()else self:Open()end end function
Dropdown:_navAdjust(dir)if self.Multi or#self.Values==0 then return end local i=
table.find(self.Values,self.Value)or 0 i=(i-1+dir)%#self.Values+1 self:_userSet(
self.Values[i])end function Dropdown:_build(parent)local row=self:_row(parent,34
)local box=Util.New('TextButton',{Name='Box',Text='',AutoButtonColor=false,
AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,24),LayoutOrder=100,
Parent=self._right})Util.Corner(5,box)Theme.Paint(box,{BackgroundColor3=
'Surface3'})local stroke=Util.Stroke(box)Theme.Paint(stroke,{Color='Stroke'})
Util.Padding(box,0,26,0,9)Util.New('UISizeConstraint',{MinSize=Vector2.new(70,24
),MaxSize=Vector2.new(190,24),Parent=box})local label=Util.Label({Text='',
FontFace=Theme.Fonts.Medium,TextSize=12,AutomaticSize=Enum.AutomaticSize.X,Size=
UDim2.fromScale(0,1),TextTruncate=Enum.TextTruncate.AtEnd,Parent=box})Util.New(
'UISizeConstraint',{MaxSize=Vector2.new(135,24),Parent=label})local chevron=Util
.New('ImageLabel',{BackgroundTransparency=1,Image=Icons.Get('chevron-down')or'',
Size=UDim2.fromOffset(13,13),AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1
,19,0.5,0),Parent=box})Theme.Paint(chevron,{ImageColor3='TextDim'})self._box,
self._boxStroke,self._label,self._chevron=box,stroke,label,chevron box.Activated
:Connect(function()if self:IsLocked()then return end if self:IsOpen()then self:
Close()else self:Open()end end)local hit=Util.Hitbox(row,0)hit.Activated:
Connect(function()if not self:IsLocked()and not self:IsOpen()then self:Open()end
end)end function Dropdown:_renderChips()local box=self._box if not box then
return end if self._chips then self._chips:Destroy()self._chips=nil end if not
self.Multi or#self.Value==0 then self._label.Visible=true return end self._label
.Visible=false local holder=Util.New('Frame',{Name='Chips',
BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.
fromScale(0,1),Parent=box})Util.List(holder,4,Enum.FillDirection.Horizontal,Enum
.HorizontalAlignment.Left,Enum.VerticalAlignment.Center)self._chips=holder local
shown=0 for _,v in self.Value do if shown>=2 then break end shown+=1 local chip=
Util.New('TextButton',{Text='',AutoButtonColor=false,AutomaticSize=Enum.
AutomaticSize.X,Size=UDim2.fromOffset(0,18),LayoutOrder=shown,Parent=holder})
Util.Corner(4,chip)Util.Padding(chip,0,4,0,6)Theme.Paint(chip,{BackgroundColor3=
'Surface2'})Util.List(chip,3,Enum.FillDirection.Horizontal,Enum.
HorizontalAlignment.Left,Enum.VerticalAlignment.Center)local text=Util.Label({
Text=Util.Truncate(self:_text(v),10),FontFace=Theme.Fonts.Medium,TextSize=11,
AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromScale(0,1),Parent=chip})Theme.
Paint(text,{TextColor3='Text'})local x=Util.New('ImageButton',{
BackgroundTransparency=1,Image=Icons.Get('x')or'',Size=UDim2.fromOffset(10,10),
LayoutOrder=2,Parent=chip})Theme.Paint(x,{ImageColor3='TextMute'})x.Activated:
Connect(function()if not self:IsLocked()then local before=Util.DeepCopy(self.
Value)self:Deselect(v)self.Library:_pushHistory(self,before,Util.DeepCopy(self.
Value))end end)end if#self.Value>shown then local more=Util.Label({Text='+'..(#
self.Value-shown),FontFace=Theme.Fonts.MonoBold,TextSize=11,AutomaticSize=Enum.
AutomaticSize.X,Size=UDim2.fromScale(0,1),LayoutOrder=9,Parent=holder})Theme.
Paint(more,{TextColor3='TextDim'})end end function Dropdown:_render()self:
_renderChips()if self._label then self._label.Text=self:GetText()Theme.Paint(
self._label,{TextColor3=(self.Value==nil or(self.Multi and#self.Value==0))and
'TextMute'or'Text'})end if self._popup and self._popup.Open then self:
_paintRows()end end function Dropdown:IsOpen()return self._popup~=nil and self.
_popup.Open end function Dropdown:Close()if self._popup then self._popup:Close()
end return self end function Dropdown:Open()if not self._box or self:IsOpen()
then return self end local Overlay=Shared.Overlay local popup=Overlay.Popup({
Anchor=self._box,Width=math.max(180,self._box.AbsoluteSize.X/(Shared.Scale or 1)
),MaxHeight=260,Align='End',Padding=4,OnClose=function()Theme.Paint(self.
_boxStroke,{Color='Stroke'},0.15)Tween.Play(self._chevron,{Rotation=0},0.15)end}
)self._popup=popup Theme.Paint(self._boxStroke,{Color='Accent'},0.15)Tween.Play(
self._chevron,{Rotation=180},0.15)self._query=''local useSearch=self.
SearchEnabled if useSearch==nil then useSearch=#self.Values>7 end if useSearch
then local search=Util.New('TextBox',{Name='Search',Text='',PlaceholderText=
Locale.T('Search')..'\u{2026}',ClearTextOnFocus=false,FontFace=Theme.Fonts.
Regular,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,0,0
,26),LayoutOrder=0,ZIndex=popup.Frame.ZIndex,Parent=popup.Content})Util.Corner(5
,search)Util.Padding(search,0,8,0,8)Theme.Paint(search,{BackgroundColor3=
'Surface2',TextColor3='Text',PlaceholderColor3='TextMute'})search:
GetPropertyChangedSignal('Text'):Connect(function()self._query=search.Text self:
_fillList()end)task.defer(function()if not game:GetService('UserInputService').
TouchEnabled then search:CaptureFocus()end end)end self:_fillList()return self
end function Dropdown:_fillList()local popup=self._popup if not popup then
return end for _,child in popup.Content:GetChildren()do if child.Name=='Item'or
child.Name=='Empty'then child:Destroy()end end self._rows={}local list={}for i,v
in self.Values do local score=Util.Fuzzy(self._query or'',self:_text(v))if score
then table.insert(list,{v=v,s=score,i=i})end end if(self._query or'')~=''then
table.sort(list,function(a,b)return a.s>b.s end)end if#list==0 then local empty=
Util.Label({Name='Empty',Text=Locale.T('NoResults'),FontFace=Theme.Fonts.Regular
,TextSize=12,TextXAlignment=Enum.TextXAlignment.Center,Size=UDim2.new(1,0,0,28),
LayoutOrder=1,ZIndex=popup.Frame.ZIndex,Parent=popup.Content})Theme.Paint(empty,
{TextColor3='TextMute'})end for order,item in list do local v=item.v local row=
Util.New('TextButton',{Name='Item',Text='',AutoButtonColor=false,
BackgroundTransparency=1,Size=UDim2.new(1,0,0,26),LayoutOrder=order+1,ZIndex=
popup.Frame.ZIndex,Parent=popup.Content})Util.Corner(5,row)Theme.Paint(row,{
BackgroundColor3='Surface3'})local x=8 local icon=Icons.Get(self.ValueIcons[v])
if icon then local img=Util.New('ImageLabel',{BackgroundTransparency=1,Image=
icon,Size=UDim2.fromOffset(14,14),Position=UDim2.new(0,8,0.5,-7),ZIndex=row.
ZIndex,Parent=row})Theme.Paint(img,{ImageColor3='TextDim'})x=28 end local label=
Util.Label({Text=self:_text(v),FontFace=Theme.Fonts.Medium,TextSize=12,
TextTruncate=Enum.TextTruncate.AtEnd,Position=UDim2.fromOffset(x,0),Size=UDim2.
new(1,-x-30,1,0),ZIndex=row.ZIndex,Parent=row})local check=Util.New('ImageLabel'
,{BackgroundTransparency=1,Image=Icons.Get('check')or'',Size=UDim2.fromOffset(13
,13),AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),ZIndex=row.
ZIndex,Parent=row})Theme.Paint(check,{ImageColor3='Accent'})if self.Deletable
then check.Position=UDim2.new(1,-28,0.5,0)local del=Util.New('ImageButton',{
BackgroundTransparency=1,Image=Icons.Get('trash-2')or'',Size=UDim2.fromOffset(13
,13),AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),ZIndex=row.
ZIndex+1,Parent=row})Theme.Paint(del,{ImageColor3='TextMute'})local armed=false
del.Activated:Connect(function()if not armed then armed=true Theme.Paint(del,{
ImageColor3='Risky'},0.1)task.delay(2,function()armed=false if del.Parent then
Theme.Paint(del,{ImageColor3='TextMute'},0.1)end end)return end if self.OnDelete
then local ok,result=Util.SafeCall(self.OnDelete,v)if ok and result==false then
return end end self:RemoveValue(v)end)end row.MouseEnter:Connect(function()Tween
.Play(row,{BackgroundTransparency=0.4},0.08)end)row.MouseLeave:Connect(function(
)Tween.Play(row,{BackgroundTransparency=1},0.12)end)row.Activated:Connect(
function()self:_pick(v)end)self._rows[v]={Label=label,Check=check}end self:
_paintRows()end function Dropdown:_paintRows()for v,refs in self._rows or{}do
local on=self:IsSelected(v)refs.Check.Visible=on Theme.Paint(refs.Label,{
TextColor3=on and'Text'or'TextDim'})end end function Dropdown:Destroy()self:
Close()Base.Destroy(self)end function classes.PlayerDropdown(section,options)
options=table.clone(options or{})local exclude=options.ExcludeSelf~=false local 
function names()local out={}for _,p in Players:GetPlayers()do if not(exclude and
p==Players.LocalPlayer)then table.insert(out,p.Name)end end table.sort(out,
function(a,b)return string.lower(a)<string.lower(b)end)return out end options.
Values=names()options.Display=options.Display or function(name)local p=Players:
FindFirstChild(name)if p and p.DisplayName~=p.Name then return p.DisplayName..
' (@'..name..')'end return name end local dropdown=Dropdown.new(section,options)
dropdown.Type='PlayerDropdown'local refresh=function()dropdown:SetValues(names()
,true)end dropdown.Maid:Connect(Players.PlayerAdded,refresh)dropdown.Maid:
Connect(Players.PlayerRemoving,function()task.defer(refresh)end)function
dropdown:GetPlayer()if self.Multi then local out={}for _,name in self.Value do
local p=Players:FindFirstChild(name)if p then table.insert(out,p)end end return
out end return self.Value and Players:FindFirstChild(self.Value)or nil end
return dropdown end local Input=Base.extend('Input')classes.Input=Input function
Input.new(section,options)local self=Base.new(Input,section,options)self.
Placeholder=options.Placeholder or''self.Numeric=options.Numeric==true self.Min,
self.Max=options.Min,options.Max self.MaxLength=options.MaxLength self.Finished=
options.Finished==true self.ClearOnFocus=options.ClearOnFocus==true self.
Validate=options.Validate self.Wide=options.Wide self.Default=self:_normalize(
Util.Opt(options,'Default','Value','Text')or(self.Numeric and(self.Min or 0)or''
))or''self.Value=self.Default return self:_register()end function Input:
_normalize(v)if self.Numeric then local n=tonumber(v)if not n then return nil
end if self.Min then n=math.max(n,self.Min)end if self.Max then n=math.min(n,
self.Max)end return n end v=tostring(v==nil and''or v)if self.MaxLength then v=
string.sub(v,1,self.MaxLength)end return v end function Input:_build(parent)
local row=self:_row(parent,self.Wide and 60 or 34)local box=Util.New('TextBox',{
Name='Box',Text=tostring(self.Value),PlaceholderText=self.Placeholder,
ClearTextOnFocus=self.ClearOnFocus,FontFace=Theme.Fonts.Medium,TextSize=12,
TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
Size=UDim2.fromOffset(124,24),LayoutOrder=100,Parent=self._right})if self.Wide
then box.Parent=row box.Size=UDim2.new(1,-16,0,26)box.Position=UDim2.new(0,8,1,-
31)self._textBox.Size=UDim2.new(1,-16,0,30)self._title.Position=UDim2.new(0,0,0,
8)end Util.Corner(5,box)Util.Padding(box,0,8,0,8)Theme.Paint(box,{
BackgroundColor3='Surface3',TextColor3='Text',PlaceholderColor3='TextMute'})
local stroke=Util.Stroke(box)Theme.Paint(stroke,{Color='Stroke'})self._box,self.
_boxStroke=box,stroke box.Focused:Connect(function()Theme.Paint(stroke,{Color=
'Accent'},0.15)end)local function commit()local text=box.Text if self.Validate
then local ok,valid,message=pcall(self.Validate,text)if ok and valid==false then
Theme.Paint(stroke,{Color='Risky'},0.1)if message and self.Library.Notify then
self.Library:Notify({Title=self.Name,Content=tostring(message),Type='warning',
Duration=3})end return false end end local v=self:_normalize(text)if v==nil then
box.Text=tostring(self.Value)return false end self:_userSet(v)return true end
box.FocusLost:Connect(function()Theme.Paint(stroke,{Color='Stroke'},0.15)if self
.Finished or self.Numeric then commit()end box.Text=tostring(self.Value)end)box:
GetPropertyChangedSignal('Text'):Connect(function()if self.Numeric then local
cleaned=string.gsub(box.Text,'[^%d%.%-]','')if cleaned~=box.Text then box.Text=
cleaned return end end if self.MaxLength and#box.Text>self.MaxLength then box.
Text=string.sub(box.Text,1,self.MaxLength)return end if not self.Finished and
not self.Numeric and box:IsFocused()then commit()end end)end function Input:
_render()if self._box and not self._box:IsFocused()then self._box.Text=tostring(
self.Value)end end function Input:_onState(locked)if self._box then self._box.
TextEditable=not locked end end function Input:_navActivate()self:Focus()end
function Input:Focus()if self._box then self._box:CaptureFocus()end return self
end function Input:Blur()if self._box then self._box:ReleaseFocus()end return
self end function Input:Clear()return self:Set(self.Numeric and(self.Min or 0)or
'')end function Input:SetPlaceholder(text)self.Placeholder=text if self._box
then self._box.PlaceholderText=text end return self end classes.TextBox=Input
classes.Textbox=Input return classes end function __DARKLUA_BUNDLE_MODULES.q()
local v=__DARKLUA_BUNDLE_MODULES.cache.q if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.q=v end return v.c end end do local function 
__modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Signal=
__DARKLUA_BUNDLE_MODULES.b()__DARKLUA_BUNDLE_MODULES.d()local Env=
__DARKLUA_BUNDLE_MODULES.e()local Keys=__DARKLUA_BUNDLE_MODULES.f()local Theme=
__DARKLUA_BUNDLE_MODULES.g()__DARKLUA_BUNDLE_MODULES.i()local Locale=
__DARKLUA_BUNDLE_MODULES.j()local Shared=__DARKLUA_BUNDLE_MODULES.k()local Base=
__DARKLUA_BUNDLE_MODULES.n()local UIS=Env.Service('UserInputService')local
RunService=Env.Service('RunService')local classes={}local Keybind=Base.extend(
'Keybind')classes.Keybind=Keybind local registry={}local listening=nil local
dispatcherReady=false local function startDispatcher()if dispatcherReady then
return end dispatcherReady=true local pendingModifier=nil Shared.Maid:Connect(
UIS.InputBegan,function(input,processed)local name=Keys.FromInput(input)if
listening then local kb=listening if input.KeyCode==Enum.KeyCode.Escape then kb:
_stopListening()elseif input.KeyCode==Enum.KeyCode.Backspace then kb:
_stopListening()kb:_userSet('None')elseif name and Keys.IsModifier(name)and kb.
AllowCombos~=false then pendingModifier=name elseif name and not(kb.Blacklist
and table.find(kb.Blacklist,name))then if name=='MB1'and os.clock()-kb._listenAt
<0.2 then return end pendingModifier=nil kb:_stopListening()kb:_userSet(kb.
AllowCombos~=false and Keys.Combo(name)or name)end return end if not name or UIS
:GetFocusedTextBox()then return end if processed and string.sub(name,1,2)=='MB'
then return end for _,kb in table.clone(registry)do if Keys.MatchesCombo(kb.
Value,name)and not kb:IsLocked()then kb:_down()end end end)Shared.Maid:Connect(
UIS.InputEnded,function(input)local name=Keys.FromInput(input)if not name then
return end if listening and pendingModifier==name then local kb=listening
pendingModifier=nil kb:_stopListening()kb:_userSet(name)return end for _,kb in
table.clone(registry)do if Keys.MainKey(kb.Value)==name then kb:_up()end end end
)end function Keybind.new(section,options)local self=Base.new(Keybind,section,
options)self.Default=Keys.Normalize(Util.Opt(options,'Default','Value','Key'))
self.Value=self.Default self.Mode=options.Mode or(self.Parent and self.Parent.
Type=='Toggle'and'Toggle')or'Press'self.Modes=options.Modes or{'Toggle','Hold',
'Always','Release'}self.Blacklist=options.Blacklist self.ShowInList=options.
ShowInList~=false self.OnPress=options.OnPress self.OnRelease=options.OnRelease
self.OnToggle=options.OnToggle self.Active=self.Mode=='Always'self.StateChanged=
Signal.new()if self.Parent and self.Name=='Keybind'then self.Name=self.Parent.
Name end table.insert(registry,self)startDispatcher()return self:_register()end
function Keybind:_normalize(v)return Keys.Normalize(v)end function Keybind:
GetKey()return self.Value end function Keybind:GetKeyCode()return Keys.ToEnum(
self.Value)end function Keybind:SetKey(key)return self:Set(key)end function
Keybind:Clear()return self:Set('None')end function Keybind:GetMode()return self.
Mode end function Keybind:IsActive()return self.Active end function Keybind:
SetMode(mode)if not table.find({'Toggle','Hold','Always','Release','Press'},mode
)then return self end self.Mode=mode if mode=='Always'then self:_setActive(true)
elseif mode~='Toggle'then self:_setActive(false)end if self.Flag then self.
Library:_onElementChanged(self,self.Value,self.Value)end self.Library.
KeybindsChanged:Fire()return self end function Keybind:_setActive(state)if self.
Active==state then return end self.Active=state self.StateChanged:Fire(state)
self.Library.KeybindsChanged:Fire()if self.OnToggle then Util.SafeCall(self.
OnToggle,state)end local parent=self.Parent if parent and parent.Type=='Toggle'
and parent.Value~=state then parent:Set(state)end end function Keybind:_down()
local mode=self.Mode if self.OnPress then Util.SafeCall(self.OnPress)end local
parent=self.Parent if parent and parent.Type=='Button'then parent:Press()end if
mode=='Toggle'then local current=parent and parent.Type=='Toggle'and parent.
Value or self.Active self:_setActive(not current)elseif mode=='Hold'then self:
_setActive(true)elseif mode=='Press'and not parent then self.StateChanged:Fire(
true)end end function Keybind:_up()if self.OnRelease then Util.SafeCall(self.
OnRelease)end if self.Mode=='Hold'then self:_setActive(false)elseif self.Mode==
'Release'then local parent=self.Parent self:_setActive(not(parent and parent.
Type=='Toggle'and parent.Value or self.Active))end end function Keybind:Press()
self:_down()task.defer(function()self:_up()end)return self end function Keybind:
_navActivate()self:Listen()end function Keybind:Listen()if listening and
listening~=self then listening:_stopListening()end listening=self Shared.
KeybindListening=true self._listenAt=os.clock()if self._chipLabel then self.
_chipLabel.Text='\u{2026}'Theme.Paint(self._chipStroke,{Color='Accent'},0.1)end
return self end function Keybind:_stopListening()if listening==self then
listening=nil task.defer(function()Shared.KeybindListening=listening~=nil end)
end if self._chipStroke then Theme.Paint(self._chipStroke,{Color='Stroke'},0.1)
end self:_render()end function Keybind:_serialize()return{self.Value,self.Mode}
end function Keybind:_deserialize(v,silent)if type(v)=='table'then self:Set(v[1]
or v.Key,silent)if v[2]or v.Mode then self:SetMode(v[2]or v.Mode)end else self:
Set(v,silent)end end function Keybind:_chip(holder,order)local chip=Util.New(
'TextButton',{Name='Keybind',Text='',AutoButtonColor=false,AutomaticSize=Enum.
AutomaticSize.X,Size=UDim2.fromOffset(0,20),LayoutOrder=order or 100,Parent=
holder})Util.Corner(5,chip)Util.Padding(chip,0,7,0,7)Util.New('UISizeConstraint'
,{MinSize=Vector2.new(26,20),Parent=chip})Theme.Paint(chip,{BackgroundColor3=
'Surface3'})local stroke=Util.Stroke(chip)Theme.Paint(stroke,{Color='Stroke'})
local label=Util.Label({Text='',FontFace=Theme.Fonts.MonoBold,TextSize=11,
TextXAlignment=Enum.TextXAlignment.Center,AutomaticSize=Enum.AutomaticSize.X,
Size=UDim2.fromScale(0,1),Parent=chip})self._chip,self._chipStroke,self.
_chipLabel=chip,stroke,label chip.Activated:Connect(function()if not self:
IsLocked()then self:Listen()end end)chip.MouseButton2Click:Connect(function()if
not self:IsLocked()then self:OpenModeMenu()end end)Shared.Overlay.Hover(chip,
function()return Locale.T('Mode')..': '..Locale.T(self.Mode=='Press'and'Press_'
or self.Mode)..'  \u{b7}  RMB'end)return chip end function Keybind:OpenModeMenu(
)local items={}for _,mode in self.Modes do table.insert(items,{Text=(self.Mode==
mode and'\u{25cf} 'or'   ')..Locale.T(mode=='Press'and'Press_'or mode),Callback=
function()self:SetMode(mode)end})end table.insert(items,{Separator=true})table.
insert(items,{Text=Locale.T('Reset'),Icon='rotate-ccw',Callback=function()self:
_userSet(self.Default)end})table.insert(items,{Text=Locale.T('None'),Icon='x',
Callback=function()self:_userSet('None')end})Shared.Overlay.Menu(items,{Anchor=
self._chip,Align='End',Width=160})end function Keybind:_buildInline(holder,order
)self:_chip(holder,order)self._mounted=true end function Keybind:_build(parent)
self:_row(parent)self:_chip(self._right,100)end local modeGlyph={Hold=
'\u{2193} ',Always='\u{221e} ',Release='\u{2191} ',Toggle='',Press=''}function
Keybind:_render()if self._chipLabel and listening~=self then self._chipLabel.
Text=(self.Value~='None'and modeGlyph[self.Mode]or'')..Keys.Display(self.Value)
Theme.Paint(self._chipLabel,{TextColor3=self.Value=='None'and'TextMute'or'Text'}
)end end function Keybind:Destroy()local i=table.find(registry,self)if i then
table.remove(registry,i)end if listening==self then listening=nil end if self.
_chip and self.Parent then self._chip:Destroy()end Base.Destroy(self)self.
Library.KeybindsChanged:Fire()end function Keybind.All()return registry end
local ColorPicker=Base.extend('ColorPicker')classes.ColorPicker=ColorPicker
local recent={}local defaultPresets={Color3.fromRGB(255,255,255),Color3.fromRGB(
160,160,168),Color3.fromRGB(60,60,66),Color3.fromRGB(232,76,84),Color3.fromRGB(
240,196,110),Color3.fromRGB(120,220,160),Color3.fromRGB(110,170,255),Color3.
fromRGB(190,130,255)}function ColorPicker.new(section,options)local self=Base.
new(ColorPicker,section,options)self.Default=Util.ToColor(Util.Opt(options,
'Default','Value','Color'))or Color3.new(1,1,1)self.Value=self.Default self.
HasAlpha=options.Alpha~=nil or options.Transparency~=nil self.Alpha=self.
HasAlpha and(options.Alpha or options.Transparency or 0)or 0 self.DefaultAlpha=
self.Alpha self.Presets=options.Presets or defaultPresets self.Rainbow=false if
self.Parent and self.Name=='ColorPicker'then self.Name=self.Parent.Name end
return self:_register()end function ColorPicker:_normalize(v)return Util.
ToColor(v)end function ColorPicker:_callbackArgs()return self.Value,self.Alpha
end function ColorPicker:GetColor()return self.Value end function ColorPicker:
SetColor(c)return self:Set(c)end function ColorPicker:GetAlpha()return self.
Alpha end function ColorPicker:SetAlpha(a,silent)a=math.clamp(tonumber(a)or 0,0,
1)if a==self.Alpha then return self end self.Alpha=a if self._mounted then self:
_render()end if not silent then self:_fireCallbacks()end self.Changed:Fire(self.
Value,self.Value)self.Library:_onElementChanged(self,self.Value,self.Value)
return self end function ColorPicker:GetHex()return Util.ToHex(self.Value)end
function ColorPicker:SetHex(hex)return self:Set(hex)end function ColorPicker:
Reset(silent)self:SetAlpha(self.DefaultAlpha,true)return Base.Reset(self,silent)
end function ColorPicker:SetRainbow(on,speed)self.Rainbow=on if self.
_rainbowConn then self._rainbowConn:Disconnect()self._rainbowConn=nil end if on
then speed=speed or 4 self._rainbowConn=RunService.Heartbeat:Connect(function()
local _,s,v=self.Value:ToHSV()self:Set(Color3.fromHSV((os.clock()/speed)%1,math.
max(s,0.6),math.max(v,0.8)))end)self.Maid:Give(self._rainbowConn)end return self
end function ColorPicker:_serialize()return{Util.ToHex(self.Value),self.Alpha}
end function ColorPicker:_deserialize(v,silent)if type(v)=='table'then self:
SetAlpha(v[2]or v.Alpha or 0,true)self:Set(v[1]or v.Color,silent)else self:Set(v
,silent)end end function ColorPicker:_swatch(holder,order)local swatch=Util.New(
'TextButton',{Name='Swatch',Text='',AutoButtonColor=false,Size=UDim2.fromOffset(
28,16),LayoutOrder=order or 100,Parent=holder})Util.Corner(4,swatch)local stroke
=Util.Stroke(swatch)Theme.Paint(stroke,{Color='StrokeHi'})self._swatch=swatch
swatch.Activated:Connect(function()if self:IsLocked()then return end if self.
_popup and self._popup.Open then self:Close()else self:Open()end end)return
swatch end function ColorPicker:_buildInline(holder,order)self:_swatch(holder,
order)self._mounted=true end function ColorPicker:_build(parent)self:_row(parent
)self:_swatch(self._right,100)end function ColorPicker:_render()if self._swatch
then self._swatch.BackgroundColor3=self.Value self._swatch.
BackgroundTransparency=self.Alpha*0.85 end if self._popupRefs then self:
_paintPopup()end end function ColorPicker:_navActivate()if self._popup and self.
_popup.Open then self:Close()else self:Open()end end function ColorPicker:Close(
)if self._popup then self._popup:Close()end return self end function ColorPicker
:Open()if not self._swatch or(self._popup and self._popup.Open)then return self
end local Overlay=Shared.Overlay local startColor,startAlpha=self.Value,self.
Alpha local popup=Overlay.Popup({Anchor=self._swatch,Width=236,MaxHeight=400,
Align='End',Padding=10,Spacing=8,OnClose=function()self._popupRefs=nil if self.
Value~=startColor then table.insert(recent,1,self.Value)for i=#recent,2,-1 do if
recent[i]==self.Value then table.remove(recent,i)end end while#recent>8 do table
.remove(recent)end self.Library:_pushHistory(self,startColor,self.Value)end end}
)self._popup=popup local z=popup.Frame.ZIndex local content=popup.Content local
h,s,v=self.Value:ToHSV()self._hsv={h,s,v}local refs={}local sv=Util.New(
'TextButton',{Name='SV',Text='',AutoButtonColor=false,Size=UDim2.new(1,0,0,140),
LayoutOrder=1,ZIndex=z,Parent=content})Util.Corner(6,sv)local white=Util.New(
'Frame',{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),ZIndex=z,
Parent=sv})Util.Corner(6,white)Util.Gradient(white,nil,NumberSequence.new(0,1),0
)local black=Util.New('Frame',{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3
.new(0,0,0),ZIndex=z,Parent=sv})Util.Corner(6,black)Util.Gradient(black,nil,
NumberSequence.new(1,0),90)local svKnob=Util.New('Frame',{Size=UDim2.fromOffset(
12,12),AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,ZIndex=z+2,
Parent=sv})Util.Round(svKnob)Util.Stroke(svKnob,Color3.new(1,1,1),2)refs.SV,refs
.SVKnob=sv,svKnob local hue=Util.New('TextButton',{Name='Hue',Text='',
AutoButtonColor=false,Size=UDim2.new(1,0,0,10),BackgroundColor3=Color3.new(1,1,1
),LayoutOrder=2,ZIndex=z,Parent=content})Util.Round(hue)local keys={}for i=0,6
do table.insert(keys,ColorSequenceKeypoint.new(i/6,Color3.fromHSV(i/6%1,1,1)))
end Util.Gradient(hue,ColorSequence.new(keys))local hueKnob=Util.New('Frame',{
Size=UDim2.fromOffset(6,14),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.
fromScale(0,0.5),BackgroundColor3=Color3.new(1,1,1),ZIndex=z+2,Parent=hue})Util.
Corner(3,hueKnob)Util.Stroke(hueKnob,Color3.new(0,0,0),1,0.5)refs.Hue,refs.
HueKnob=hue,hueKnob if self.HasAlpha then local alpha=Util.New('TextButton',{
Name='Alpha',Text='',AutoButtonColor=false,Size=UDim2.new(1,0,0,10),LayoutOrder=
3,ZIndex=z,Parent=content})Util.Round(alpha)local grad=Util.Gradient(alpha,nil,
NumberSequence.new(0,1))local alphaKnob=Util.New('Frame',{Size=UDim2.fromOffset(
6,14),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0,0.5),
BackgroundColor3=Color3.new(1,1,1),ZIndex=z+2,Parent=alpha})Util.Corner(3,
alphaKnob)Util.Stroke(alphaKnob,Color3.new(0,0,0),1,0.5)refs.Alpha,refs.
AlphaKnob,refs.AlphaGrad=alpha,alphaKnob,grad end local line=Util.New('Frame',{
BackgroundTransparency=1,Size=UDim2.new(1,0,0,26),LayoutOrder=4,ZIndex=z,Parent=
content})local hex=Util.New('TextBox',{Text='',ClearTextOnFocus=false,FontFace=
Theme.Fonts.Mono,TextSize=12,Size=UDim2.new(1,-66,1,0),ZIndex=z,Parent=line})
Util.Corner(5,hex)Theme.Paint(hex,{BackgroundColor3='Surface2',TextColor3='Text'
})local old=Util.New('TextButton',{Text='',AutoButtonColor=false,Size=UDim2.
fromOffset(28,26),Position=UDim2.new(1,-60,0,0),BackgroundColor3=startColor,
ZIndex=z,Parent=line})Util.Corner(5,old)local new=Util.New('Frame',{Size=UDim2.
fromOffset(28,26),Position=UDim2.new(1,-28,0,0),ZIndex=z,Parent=line})Util.
Corner(5,new)Shared.Overlay.Hover(old,function()return Locale.T('Reset')end)old.
Activated:Connect(function()self:SetAlpha(startAlpha)self:Set(startColor)self.
_hsv={startColor:ToHSV()}self:_paintPopup()end)hex.FocusLost:Connect(function()
local c=Util.FromHex(hex.Text)if c then self._hsv={c:ToHSV()}self:Set(c)end self
:_paintPopup()end)refs.Hex,refs.New=hex,new local function swatchRow(order,
colors)local row=Util.New('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0
,18),LayoutOrder=order,ZIndex=z,Parent=content})Util.List(row,6,Enum.
FillDirection.Horizontal)for _,c in colors do local b=Util.New('TextButton',{
Text='',AutoButtonColor=false,Size=UDim2.fromOffset(18,18),BackgroundColor3=c,
ZIndex=z,Parent=row})Util.Round(b)Theme.Paint(Util.Stroke(b),{Color='StrokeHi'})
b.Activated:Connect(function()self._hsv={c:ToHSV()}self:Set(c)self:_paintPopup()
end)end end swatchRow(5,self.Presets)if#recent>0 then swatchRow(6,recent)end
local dragging=nil local function update(pos)if dragging=='SV'then local rel=(
pos-sv.AbsolutePosition)/sv.AbsoluteSize self._hsv[2]=math.clamp(rel.X,0,1)self.
_hsv[3]=1-math.clamp(rel.Y,0,1)elseif dragging=='Hue'then self._hsv[1]=math.
clamp((pos.X-hue.AbsolutePosition.X)/hue.AbsoluteSize.X,0,0.999)elseif dragging
=='Alpha'then self:SetAlpha(math.clamp((pos.X-refs.Alpha.AbsolutePosition.X)/
refs.Alpha.AbsoluteSize.X,0,1))self:_paintPopup()return end self:Set(Color3.
fromHSV(self._hsv[1],self._hsv[2],self._hsv[3]))self:_paintPopup()end local 
function hook(gui,name)gui.InputBegan:Connect(function(input)if input.
UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.
UserInputType.Touch then dragging=name update(Vector2.new(input.Position.X,input
.Position.Y))end end)end hook(sv,'SV')hook(hue,'Hue')if refs.Alpha then hook(
refs.Alpha,'Alpha')end local c1=UIS.InputChanged:Connect(function(input)if
dragging and(input.UserInputType==Enum.UserInputType.MouseMovement or input.
UserInputType==Enum.UserInputType.Touch)then update(Vector2.new(input.Position.X
,input.Position.Y))end end)local c2=UIS.InputEnded:Connect(function(input)if
input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==
Enum.UserInputType.Touch then dragging=nil end end)popup.Frame.Destroying:
Connect(function()c1:Disconnect()c2:Disconnect()end)self._popupRefs=refs self:
_paintPopup()return self end function ColorPicker:_paintPopup()local refs=self.
_popupRefs if not refs then return end local hsv=self._hsv or{self.Value:ToHSV()
}refs.SV.BackgroundColor3=Color3.fromHSV(hsv[1],1,1)refs.SVKnob.Position=UDim2.
fromScale(hsv[2],1-hsv[3])refs.HueKnob.Position=UDim2.fromScale(hsv[1],0.5)if
refs.Alpha then refs.Alpha.BackgroundColor3=self.Value refs.AlphaKnob.Position=
UDim2.fromScale(self.Alpha,0.5)end if not refs.Hex:IsFocused()then refs.Hex.Text
=Util.ToHex(self.Value)end refs.New.BackgroundColor3=self.Value refs.New.
BackgroundTransparency=self.Alpha*0.85 end function ColorPicker:Destroy()self:
Close()if self._swatch and self.Parent then self._swatch:Destroy()end Base.
Destroy(self)end classes.Colorpicker=ColorPicker return classes end function
__DARKLUA_BUNDLE_MODULES.r()local v=__DARKLUA_BUNDLE_MODULES.cache.r if not v
then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.r=v end return v.c end end
do local function __modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Tween=
__DARKLUA_BUNDLE_MODULES.d()local Env=__DARKLUA_BUNDLE_MODULES.e()local Theme=
__DARKLUA_BUNDLE_MODULES.g()local Icons=__DARKLUA_BUNDLE_MODULES.i()local Locale
=__DARKLUA_BUNDLE_MODULES.j()local Shared=__DARKLUA_BUNDLE_MODULES.k()local Base
=__DARKLUA_BUNDLE_MODULES.n()Env.Service('RunService')local classes={}local 
function noState(class)function class:_applyState()if self.Frame then self.Frame
.Visible=self.Visible and self._depsOk~=false end end function class:
_contextItems()return{}end end local function poll(self,source,interval,apply)if
type(source)~='function'then return end local thread=task.spawn(function()while
not self._destroyed do local ok,value=pcall(source)if ok then apply(value)end
task.wait(interval or 1)end end)self.Maid:Give(thread)end local Progress=Base.
extend('Progress')classes.Progress=Progress noState(Progress)function Progress.
new(section,options)local self=Base.new(Progress,section,options)self.Max=
options.Max or 100 self.Suffix=options.Suffix or'%'self.ShowValue=options.
ShowValue~=false self.Value=math.clamp(tonumber(Util.Opt(options,'Value',
'Default'))or 0,0,self.Max)self.Default=self.Value return self:_register()end
function Progress:_normalize(v)v=tonumber(v)return v and math.clamp(v,0,self.Max
)or nil end function Progress:SetMax(max)self.Max=max return self:Set(math.min(
self.Value,max))end function Progress:_build(parent)local row=self:_row(parent,
40)self._textBox.Size=UDim2.new(1,-16,0,22)self._title.Position=UDim2.
fromOffset(0,4)local value=Util.Label({FontFace=Theme.Fonts.Mono,TextSize=12,
AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,26),LayoutOrder=100,
Parent=self._right})self._right.Size=UDim2.new(0,0,0,26)Theme.Paint(value,{
TextColor3='TextDim'})local track=Util.New('Frame',{Size=UDim2.new(1,-16,0,4),
Position=UDim2.new(0,8,1,-10),Parent=row})Util.Round(track)Theme.Paint(track,{
BackgroundColor3='Surface3'})local fill=Util.New('Frame',{Size=UDim2.fromScale(0
,1),Parent=track})Util.Round(fill)Theme.Paint(fill,{BackgroundColor3='Accent'})
self._fill,self._value=fill,value end function Progress:_render(animate)if self.
_fill then Tween.Play(self._fill,{Size=UDim2.fromScale(self.Value/math.max(self.
Max,1e-9),1)},animate and 0.3 or 0)self._value.Text=self.ShowValue and(self.
Suffix=='%'and Util.FormatNumber(self.Value/self.Max*100,0)..'%'or Util.
FormatNumber(self.Value,1)..self.Suffix)or''end end local Stat=Base.extend(
'Stat')classes.Stat=Stat noState(Stat)function Stat.new(section,options)local
self=Base.new(Stat,section,options)self.Icon=options.Icon self.Suffix=options.
Suffix or''local v=Util.Opt(options,'Value','Default')self.Value=type(v)==
'function'and'\u{2026}'or v self.Default=self.Value self:_register()poll(self,v,
options.Interval,function(value)self:Set(value)end)return self end function Stat
:_normalize(v)return v end function Stat:_build(parent)self:_row(parent,30)self.
_titleToken='TextDim'Theme.Paint(self._title,{TextColor3='TextDim'})local value=
Util.Label({FontFace=Theme.Fonts.MonoBold,TextSize=12,AutomaticSize=Enum.
AutomaticSize.X,Size=UDim2.fromOffset(0,16),LayoutOrder=100,Parent=self._right})
Theme.Paint(value,{TextColor3='Text'})self._value=value end function Stat:
_render()if self._value then self._value.Text=tostring(self.Value)..self.Suffix
end end local StatGrid=Base.extend('StatGrid')classes.StatGrid=StatGrid noState(
StatGrid)function StatGrid.new(section,options)local self=Base.new(StatGrid,
section,{Name=options.Name or'Stats'})self.Columns=options.Columns or 3 self.
Items={}for i,item in options.Items or{}do self.Items[i]={Name=item.Name or item
[1],Source=item.Value or item[2],Interval=item.Interval or 1,Accent=item.Accent,
Spark=item.Sparkline,History={},Text='\u{2026}'}end self:_register()for _,item
in self.Items do if type(item.Source)=='function'then poll(self,item.Source,item
.Interval,function(value)self:_setItem(item,value)end)else item.Text=tostring(
item.Source)end end return self end function StatGrid:_setItem(item,value)item.
Text=tostring(value)if item.Spark and tonumber(value)then table.insert(item.
History,tonumber(value))if#item.History>30 then table.remove(item.History,1)end
end if item.Label then item.Label.Text=item.Text if item.Spark then Shared.Lib.
_drawSpark(item.SparkFrame,item.History)end end end function StatGrid:SetItem(
key,value)for i,item in self.Items do if i==key or item.Name==key then self:
_setItem(item,value)end end return self end function StatGrid:_build(parent)
local cols=self.Columns local rows=math.ceil(#self.Items/cols)local frame=Util.
New('Frame',{Name='StatGrid',BackgroundTransparency=1,Size=UDim2.new(1,0,0,rows*
48+(rows-1)*6),Parent=parent})self.Frame=frame Util.New('UIGridLayout',{CellSize
=UDim2.new(1/cols,-(6*(cols-1))/cols,0,48),CellPadding=UDim2.fromOffset(6,6),
SortOrder=Enum.SortOrder.LayoutOrder,Parent=frame})for i,item in self.Items do
local tile=Util.New('Frame',{LayoutOrder=i,Parent=frame})Util.Corner(6,tile)
Theme.Paint(tile,{BackgroundColor3='Surface2'})Theme.Paint(Util.Stroke(tile),{
Color='Stroke'})local name=Util.Label({Text=item.Name,FontFace=Theme.Fonts.
Medium,TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,-16,0,
14),Position=UDim2.fromOffset(8,6),Parent=tile})Theme.Paint(name,{TextColor3=
'TextMute'})local value=Util.Label({Text=item.Text,FontFace=Theme.Fonts.MonoBold
,TextSize=14,TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,-16,0,18),
Position=UDim2.fromOffset(8,23),Parent=tile})Theme.Paint(value,{TextColor3=item.
Accent and'Accent'or'Text'})item.Label=value if item.Spark then local spark=Util
.New('Frame',{BackgroundTransparency=1,Size=UDim2.new(0.5,-8,0,16),Position=
UDim2.new(0.5,0,0,5),ClipsDescendants=true,Parent=tile})item.SparkFrame=spark
Shared.Lib._drawSpark(spark,item.History)end Shared.Overlay.Hover(tile,function(
)return item.Name..': '..item.Text end)end end local Graph=Base.extend('Graph')
classes.Graph=Graph noState(Graph)function Graph.new(section,options)local self=
Base.new(Graph,section,options)self.Points=options.Points or options.Max or 40
self.Height=options.Height or 64 self.FixedMin,self.FixedMax=options.Min,options
.MaxValue self.Suffix=options.Suffix or''self.Data={}self.Value=self.Data self:
_register()poll(self,options.Source,options.Interval or 0.5,function(v)self:
Push(v)end)return self end function Graph:Push(v)v=tonumber(v)if not v then
return self end table.insert(self.Data,v)while#self.Data>self.Points do table.
remove(self.Data,1)end if self._mounted then self:_render()end return self end
function Graph:SetData(list)self.Data=table.clone(list or{})self.Value=self.Data
if self._mounted then self:_render()end return self end function Graph:Clear()
return self:SetData({})end function Graph:_build(parent)local row=Util.New(
'Frame',{Name='Graph',BackgroundTransparency=1,Size=UDim2.new(1,0,0,self.Height+
26),Parent=parent})self.Frame=row local title=Util.Label({Text=self.Name,
FontFace=Theme.Fonts.Medium,TextSize=12,Size=UDim2.new(1,-16,0,18),Position=
UDim2.fromOffset(8,2),Parent=row})Theme.Paint(title,{TextColor3='TextDim'})local
last=Util.Label({FontFace=Theme.Fonts.Mono,TextSize=12,TextXAlignment=Enum.
TextXAlignment.Right,Size=UDim2.new(1,-16,0,18),Position=UDim2.fromOffset(8,2),
Parent=row})Theme.Paint(last,{TextColor3='Text'})local area=Util.New('Frame',{
Size=UDim2.new(1,-16,0,self.Height),Position=UDim2.fromOffset(8,22),
ClipsDescendants=true,Parent=row})Util.Corner(6,area)Theme.Paint(area,{
BackgroundColor3='Surface2'})Theme.Paint(Util.Stroke(area),{Color='Stroke'})self
._area,self._last=area,last end function Graph:_render()if not self._area then
return end Shared.Lib._drawSpark(self._area,self.Data,self.FixedMin,self.
FixedMax)local v=self.Data[#self.Data]self._last.Text=v and(Util.FormatNumber(v,
1)..self.Suffix)or''end local Table=Base.extend('Table')classes.Table=Table
noState(Table)function Table.new(section,options)local self=Base.new(Table,
section,options)self.Columns=options.Columns or{{Key=1,Name='Value',Width=1}}
self.Rows=table.clone(options.Rows or{})self.Height=options.Height or 240 self.
RowHeight=options.RowHeight or 30 self.SearchEnabled=options.Search~=false self.
SortKey=options.SortBy self.Descending=options.Descending==true self.Filter=
options.Filter self.Actions=options.Actions or{}self.OnSelect=options.OnSelect
self.Query=''self.Value=nil self.FilterSpecs=options.Filters or{}self.
FilterValues={}return self:_register()end function Table:_passesFilters(row)for
_,spec in self.FilterSpecs do local v=self.FilterValues[spec.Key or spec.Name]if
v~=nil then local cell=row[spec.Key]if spec.Type=='Range'then local n=tonumber(
cell)if n==nil or(v.Min and n<v.Min)or(v.Max and n>v.Max)then return false end
elseif spec.Type=='Select'then if v~='Any'and cell~=v then return false end
elseif spec.Type=='Switch'then if v==true and spec.Test then local ok,keep=
pcall(spec.Test,row)if ok and keep==false then return false end end end end end
return true end function Table:ActiveFilters()local n=0 for _,v in self.
FilterValues do if v~=nil and v~='Any'and v~=false and not(type(v)=='table'and v
.Min==nil and v.Max==nil)then n+=1 end end return n end function Table:
SetFilterValue(key,value)self.FilterValues[key]=value self:_refresh()return self
end function Table:ClearFilters()table.clear(self.FilterValues)self:_refresh()
return self end function Table:OpenFilters(anchor)local popup=Shared.Overlay.
Popup({Anchor=anchor or self._filterButton,Width=250,MaxHeight=360,Align='End',
Padding=10,Spacing=8})local z=popup.Frame.ZIndex for i,spec in self.FilterSpecs
do local key=spec.Key or spec.Name local row=Util.New('Frame',{
BackgroundTransparency=1,Size=UDim2.new(1,0,0,spec.Type=='Range'and 46 or 26),
LayoutOrder=i,ZIndex=z,Parent=popup.Content})local label=Util.Label({Text=spec.
Name or tostring(spec.Key),FontFace=Theme.Fonts.Medium,TextSize=12,Size=UDim2.
new(1,0,0,16),ZIndex=z,Parent=row})Theme.Paint(label,{TextColor3='TextDim'})if
spec.Type=='Range'then local value=self.FilterValues[key]or{}for j,side in{'Min'
,'Max'}do local box=Util.New('TextBox',{Text=value[side]and tostring(value[side]
)or'',PlaceholderText=side=='Min'and Locale.T('From')or Locale.T('To'),
ClearTextOnFocus=false,FontFace=Theme.Fonts.Mono,TextSize=12,Size=UDim2.new(0.5,
-3,0,24),Position=UDim2.new((j-1)*0.5,(j-1)*3,0,20),ZIndex=z,Parent=row})Util.
Corner(5,box)Theme.Paint(box,{BackgroundColor3='Surface2',TextColor3='Text',
PlaceholderColor3='TextMute'})box.FocusLost:Connect(function()local v=self.
FilterValues[key]or{}v[side]=tonumber(box.Text)self.FilterValues[key]=(v.Min or
v.Max)and v or nil self:_refresh()end)end elseif spec.Type=='Select'then local
values={'Any'}for _,v in spec.Values or{}do table.insert(values,v)end local
current=self.FilterValues[key]or'Any'local b=Util.New('TextButton',{Text=
tostring(current),FontFace=Theme.Fonts.Medium,TextSize=12,AutoButtonColor=false,
Size=UDim2.new(0.5,0,0,22),Position=UDim2.new(0.5,0,0,0),ZIndex=z,Parent=row})
Util.Corner(5,b)Theme.Paint(b,{BackgroundColor3='Surface2',TextColor3='Text'})b.
Activated:Connect(function()local idx=(table.find(values,self.FilterValues[key]
or'Any')or 1)%#values+1 self.FilterValues[key]=values[idx]~='Any'and values[idx]
or nil b.Text=tostring(values[idx])self:_refresh()end)elseif spec.Type=='Switch'
then local on=self.FilterValues[key]==true local b=Util.New('TextButton',{Text=
on and'ON'or'OFF',FontFace=Theme.Fonts.Bold,TextSize=10,AutoButtonColor=false,
Size=UDim2.fromOffset(40,20),AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0
,0,0),ZIndex=z,Parent=row})Util.Corner(5,b)Theme.Paint(b,{BackgroundColor3=on
and'Accent'or'Surface3',TextColor3=on and'AccentInk'or'TextMute'})b.Activated:
Connect(function()local now=not(self.FilterValues[key]==true)self.FilterValues[
key]=now or nil b.Text=now and'ON'or'OFF'Theme.Paint(b,{BackgroundColor3=now and
'Accent'or'Surface3',TextColor3=now and'AccentInk'or'TextMute'},0.1)self:
_refresh()end)end end local reset=Util.New('TextButton',{Text=Locale.T(
'ResetFilters'),FontFace=Theme.Fonts.SemiBold,TextSize=12,AutoButtonColor=false,
Size=UDim2.new(1,0,0,26),LayoutOrder=99,ZIndex=z,Parent=popup.Content})Util.
Corner(6,reset)Theme.Paint(reset,{BackgroundColor3='Surface3',TextColor3='Text'}
)reset.Activated:Connect(function()popup:Close()self:ClearFilters()end)return
popup end function Table:_view()local out={}for i,row in self.Rows do local ok=
true if self.Filter then local s,r=pcall(self.Filter,row)ok=s and r~=false end
if ok and#self.FilterSpecs>0 then ok=self:_passesFilters(row)end if ok and self.
Query~=''then local hay={}for _,col in self.Columns do table.insert(hay,
tostring(row[col.Key]or''))end ok=Util.Fuzzy(self.Query,table.concat(hay,' '))~=
nil end if ok then table.insert(out,row)end end if self.SortKey then local key,
desc=self.SortKey,self.Descending table.sort(out,function(a,b)local va,vb=a[key]
,b[key]if type(va)~=type(vb)then va,vb=tostring(va),tostring(vb)end if va==nil
or vb==nil then return vb==nil and va~=nil end if desc then return va>vb end
return va<vb end)end return out end function Table:SetRows(rows)self.Rows=table.
clone(rows or{})self:_refresh()return self end function Table:AddRow(row)table.
insert(self.Rows,row)self:_refresh()return self end function Table:RemoveRow(
which)for i=#self.Rows,1,-1 do if i==which or(type(which)=='function'and which(
self.Rows[i]))or self.Rows[i]==which then table.remove(self.Rows,i)end end self:
_refresh()return self end function Table:Clear()return self:SetRows({})end
function Table:GetRows()return table.clone(self.Rows)end function Table:
GetSelected()return self.Value end function Table:SortBy(key,descending)self.
SortKey,self.Descending=key,descending==true self:_refresh()return self end
function Table:SetFilter(fn)self.Filter=fn self:_refresh()return self end
function Table:SetQuery(text)self.Query=text or''self:_refresh()return self end
function Table:_build(parent)local frame=Util.New('Frame',{Name='Table',
BackgroundTransparency=1,Size=UDim2.new(1,0,0,self.Height),Parent=parent})self.
Frame=frame local y=0 if self.SearchEnabled then local filterW=#self.FilterSpecs
>0 and 34 or 0 local search=Util.New('TextBox',{Text='',PlaceholderText=Locale.
T('Search')..'\u{2026}',ClearTextOnFocus=false,FontFace=Theme.Fonts.Regular,
TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-8-filterW,
0,26),Position=UDim2.fromOffset(4,0),Parent=frame})if filterW>0 then local fb=
Util.New('ImageButton',{AutoButtonColor=false,Size=UDim2.fromOffset(28,26),
AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-4,0,0),Parent=frame})Util.
Corner(6,fb)Theme.Paint(fb,{BackgroundColor3='Surface2'})local fi=Util.New(
'ImageLabel',{BackgroundTransparency=1,Image=Icons.Get('filter')or'',Size=UDim2.
fromOffset(14,14),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,
0.5),Parent=fb})Theme.Paint(fi,{ImageColor3='TextDim'})local count=Util.Label({
Text='',FontFace=Theme.Fonts.Bold,TextSize=9,TextXAlignment=Enum.TextXAlignment.
Center,Size=UDim2.fromOffset(13,13),AnchorPoint=Vector2.new(1,0),Position=UDim2.
new(1,3,0,-3),BackgroundTransparency=0,Visible=false,Parent=fb})Util.Round(count
)Theme.Paint(count,{BackgroundColor3='Accent',TextColor3='AccentInk'})self.
_filterButton,self._filterCount=fb,count fb.Activated:Connect(function()self:
OpenFilters(fb)end)end Util.Corner(5,search)Util.Padding(search,0,8,0,26)Theme.
Paint(search,{BackgroundColor3='Surface2',TextColor3='Text',PlaceholderColor3=
'TextMute'})local icon=Util.New('ImageLabel',{BackgroundTransparency=1,Image=
Icons.Get('search')or'',Size=UDim2.fromOffset(13,13),Position=UDim2.new(0,-19,
0.5,-6),Parent=search})Theme.Paint(icon,{ImageColor3='TextMute'})search:
GetPropertyChangedSignal('Text'):Connect(function()self.Query=search.Text self:
_refresh()end)y=32 end local header=Util.New('Frame',{BackgroundTransparency=1,
Size=UDim2.new(1,-8,0,22),Position=UDim2.fromOffset(4,y),Parent=frame})local x=0
self._headers={}for _,col in self.Columns do local w=col.Width or(1/#self.
Columns)local h=Util.New('TextButton',{Text=col.Name or tostring(col.Key),
FontFace=Theme.Fonts.SemiBold,TextSize=11,AutoButtonColor=false,
BackgroundTransparency=1,TextXAlignment=col.Align=='Center'and Enum.
TextXAlignment.Center or(col.Align=='Right'and Enum.TextXAlignment.Right or Enum
.TextXAlignment.Left),Size=UDim2.new(w,-6,1,0),Position=UDim2.new(x,8,0,0),
Parent=header})Theme.Paint(h,{TextColor3='TextMute'})h.Activated:Connect(
function()if self.SortKey==col.Key then self.Descending=not self.Descending else
self.SortKey,self.Descending=col.Key,false end self:_refresh()end)self._headers[
col.Key]={Button=h,Name=col.Name or tostring(col.Key)}x+=w end y+=24 local list=
Util.New('ScrollingFrame',{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2
.new(1,0,1,-y),Position=UDim2.fromOffset(0,y),CanvasSize=UDim2.new(),
ScrollBarThickness=2,Parent=frame})Theme.Paint(list,{ScrollBarImageColor3=
'StrokeHi'})self._list=list local empty=Util.Label({Text=Locale.T('Empty'),
FontFace=Theme.Fonts.Regular,TextSize=12,TextXAlignment=Enum.TextXAlignment.
Center,Size=UDim2.new(1,0,0,40),Visible=false,Parent=list})Theme.Paint(empty,{
TextColor3='TextMute'})self._empty=empty self._pool={}list:
GetPropertyChangedSignal('CanvasPosition'):Connect(function()self:_drawVisible()
end)list:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()self:
_drawVisible()end)end function Table:_refresh()if not self._list then return end
self._viewRows=self:_view()if self._filterCount then local n=self:ActiveFilters(
)self._filterCount.Visible=n>0 self._filterCount.Text=tostring(n)end self._list.
CanvasSize=UDim2.fromOffset(0,#self._viewRows*(self.RowHeight+4))self._empty.
Visible=#self._viewRows==0 for key,h in self._headers or{}do h.Button.Text=h.
Name..(self.SortKey==key and(self.Descending and'  \u{2193}'or'  \u{2191}')or'')
Theme.Paint(h.Button,{TextColor3=self.SortKey==key and'Text'or'TextMute'})end
self:_drawVisible()end function Table:_drawVisible()local list=self._list local
rows=self._viewRows or{}local s=Shared.Scale or 1 local h=self.RowHeight+4 local
top=list.CanvasPosition.Y local first=math.max(1,math.floor(top/h)+1)local last=
math.min(#rows,first+math.ceil(list.AbsoluteSize.Y/s/h)+1)local used={}for i=
first,last do local row=rows[i]local item=self._pool[#used+1]if not item then
item=self:_newRow()self._pool[#used+1]=item end used[#used+1]=item item.Row=row
item.Frame.Visible=true item.Frame.Position=UDim2.fromOffset(4,(i-1)*h)for c,col
in self.Columns do item.Cells[c].Text=tostring(row[col.Key]==nil and''or row[col
.Key])end Theme.Paint(item.Frame,{BackgroundColor3=self.Value==row and'Surface3'
or'Surface2'})end for i=#used+1,#self._pool do self._pool[i].Frame.Visible=false
end end function Table:_newRow()local item={Cells={}}local frame=Util.New(
'TextButton',{Text='',AutoButtonColor=false,Size=UDim2.new(1,-10,0,self.
RowHeight),Parent=self._list})Util.Corner(5,frame)Theme.Paint(frame,{
BackgroundColor3='Surface2'})local x=0 local actionsWidth=#self.Actions*22 for c
,col in self.Columns do local w=col.Width or(1/#self.Columns)local cell=Util.
Label({FontFace=c==1 and Theme.Fonts.SemiBold or Theme.Fonts.Regular,TextSize=12
,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=col.Align=='Center'and Enum
.TextXAlignment.Center or(col.Align=='Right'and Enum.TextXAlignment.Right or
Enum.TextXAlignment.Left),Size=UDim2.new(w,c==#self.Columns and-actionsWidth-10
or-6,1,0),Position=UDim2.new(x,8,0,0),Parent=frame})Theme.Paint(cell,{TextColor3
=c==1 and'Text'or'TextDim'})item.Cells[c]=cell x+=w end for a,action in self.
Actions do local b=Util.New('ImageButton',{BackgroundTransparency=1,Image=Icons.
Get(action.Icon)or'',Size=UDim2.fromOffset(15,15),AnchorPoint=Vector2.new(1,0.5)
,Position=UDim2.new(1,-8-(a-1)*22,0.5,0),ZIndex=2,Parent=frame})Theme.Paint(b,{
ImageColor3='TextDim'})if action.Tooltip then Shared.Overlay.Hover(b,function()
return action.Tooltip end)end b.Activated:Connect(function()if item.Row then
Util.SafeCall(action.Callback,item.Row)end end)end frame.MouseEnter:Connect(
function()Theme.Paint(frame,{BackgroundColor3='Surface3'},0.08)end)frame.
MouseLeave:Connect(function()Theme.Paint(frame,{BackgroundColor3=self.Value==
item.Row and'Surface3'or'Surface2'},0.12)end)frame.Activated:Connect(function()
self.Value=item.Row self:_drawVisible()self.Changed:Fire(item.Row)if self.
OnSelect then Util.SafeCall(self.OnSelect,item.Row)end self:_fireCallbacks()end)
item.Frame=frame return item end function Table:_render()self:_refresh()end
local Card=Base.extend('Card')classes.Card=Card noState(Card)function Card.new(
section,options)local self=Base.new(Card,section,{Name=options.Title or options.
Name or'',Callback=options.Callback,Visible=options.Visible})self.Subtitle=
options.Subtitle self.Body=options.Body or options.Content self.Image=options.
Image self.Model=options.Model self.ProgressValue=options.Progress self.Badge=
options.Badge self.Height=options.Height or 96 return self:_register()end
function Card:_build(parent)local card=Util.New('TextButton',{Name='Card',Text=
'',AutoButtonColor=false,Size=UDim2.new(1,0,0,self.Height),ClipsDescendants=true
,Parent=parent})self.Frame=card Util.Corner(8,card)Theme.Paint(card,{
BackgroundColor3='Surface2'})local stroke=Util.Stroke(card)Theme.Paint(stroke,{
Color='Stroke'})local left=12 local media=self.Height-16 if self.Model and
typeof(self.Model)=='Instance'then local vp=Util.New('ViewportFrame',{
BackgroundTransparency=1,Size=UDim2.fromOffset(media,media),Position=UDim2.
fromOffset(8,8),Ambient=Color3.fromRGB(200,200,200),LightColor=Color3.new(1,1,1)
,Parent=card})Util.Corner(6,vp)Shared.Lib:_fillViewport(vp,self.Model)left=media
+18 elseif Icons.Get(self.Image)then local img=Util.New('ImageLabel',{
BackgroundTransparency=1,Image=Icons.Get(self.Image),ScaleType=Enum.ScaleType.
Crop,Size=UDim2.fromOffset(media,media),Position=UDim2.fromOffset(8,8),Parent=
card})Util.Corner(6,img)left=media+18 end local title=Util.Label({Text=self.Name
,FontFace=Theme.Fonts.SemiBold,TextSize=14,TextTruncate=Enum.TextTruncate.AtEnd,
Size=UDim2.new(1,-left-10,0,18),Position=UDim2.fromOffset(left,10),Parent=card})
Theme.Paint(title,{TextColor3='Text'})local sub=Util.Label({Text=self.Subtitle
or'',FontFace=Theme.Fonts.Regular,TextSize=11,TextTruncate=Enum.TextTruncate.
AtEnd,Size=UDim2.new(1,-left-10,0,14),Position=UDim2.fromOffset(left,29),Parent=
card})Theme.Paint(sub,{TextColor3='TextMute'})local body=Util.Label({Text=self.
Body or'',FontFace=Theme.Fonts.Regular,TextSize=12,TextWrapped=true,
TextYAlignment=Enum.TextYAlignment.Top,Size=UDim2.new(1,-left-10,1,-64),Position
=UDim2.fromOffset(left,46),Parent=card})Theme.Paint(body,{TextColor3='TextDim'})
if self.ProgressValue then local cur,max=self.ProgressValue[1]or 0,self.
ProgressValue[2]or 1 local track=Util.New('Frame',{Size=UDim2.new(1,-left-60,0,3
),Position=UDim2.new(0,left,1,-12),Parent=card})Util.Round(track)Theme.Paint(
track,{BackgroundColor3='Surface3'})local fill=Util.New('Frame',{Size=UDim2.
fromScale(math.clamp(cur/math.max(max,1),0,1),1),Parent=track})Util.Round(fill)
Theme.Paint(fill,{BackgroundColor3='Accent'})local label=Util.Label({Text=cur..
' / '..max,FontFace=Theme.Fonts.Mono,TextSize=11,TextXAlignment=Enum.
TextXAlignment.Right,Size=UDim2.new(0,50,0,14),Position=UDim2.new(1,-60,1,-19),
Parent=card})Theme.Paint(label,{TextColor3='TextDim'})end if self.Badge then
local badge=Util.Label({Text=self.Badge,FontFace=Theme.Fonts.Bold,TextSize=9,
AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,16),AnchorPoint=
Vector2.new(1,0),Position=UDim2.new(1,-10,0,10),BackgroundTransparency=0,Parent=
card})Util.Padding(badge,0,6,0,6)Util.Corner(4,badge)Theme.Paint(badge,{
BackgroundColor3='Accent',TextColor3='AccentInk'})end card.MouseEnter:Connect(
function()Theme.Paint(stroke,{Color='StrokeHi'},0.12)end)card.MouseLeave:
Connect(function()Theme.Paint(stroke,{Color='Stroke'},0.15)end)card.Activated:
Connect(function()self:_fireCallbacks()end)self._titleLabel,self._subLabel,self.
_bodyLabel=title,sub,body end function Card:_callbackArgs()return self end
function Card:SetTitle(t)self.Name=t if self._titleLabel then self._titleLabel.
Text=t end return self end function Card:SetSubtitle(t)self.Subtitle=t if self.
_subLabel then self._subLabel.Text=t or''end return self end function Card:
SetBody(t)self.Body=t if self._bodyLabel then self._bodyLabel.Text=t or''end
return self end local Image=Base.extend('Image')classes.Image=Image noState(
Image)function Image.new(section,options)local self=Base.new(Image,section,{Name
=options.Caption or'Image'})self.Value=options.Image self.Height=options.Height
or 120 self.ScaleType=options.ScaleType or Enum.ScaleType.Fit self.Caption=
options.Caption return self:_register()end function Image:_build(parent)local
frame=Util.New('Frame',{Name='Image',BackgroundTransparency=1,Size=UDim2.new(1,0
,0,self.Height+(self.Caption and 18 or 0)),Parent=parent})self.Frame=frame local
img=Util.New('ImageLabel',{ScaleType=self.ScaleType,Size=UDim2.new(1,-8,0,self.
Height),Position=UDim2.fromOffset(4,0),Parent=frame})Util.Corner(6,img)Theme.
Paint(img,{BackgroundColor3='Surface2'})self._img=img if self.Caption then local
cap=Util.Label({Text=self.Caption,FontFace=Theme.Fonts.Regular,TextSize=11,
TextXAlignment=Enum.TextXAlignment.Center,Size=UDim2.new(1,0,0,16),Position=
UDim2.new(0,0,0,self.Height+2),Parent=frame})Theme.Paint(cap,{TextColor3=
'TextMute'})end end function Image:_render()if self._img then self._img.Image=
Icons.Get(self.Value)or''end end local Console=Base.extend('Console')classes.
Console=Console noState(Console)local levelTokens={info='TextDim',success=
'Success',warn='Warning',warning='Warning',error='Error',debug='TextMute'}
function Console.new(section,options)local self=Base.new(Console,section,options
)self.Height=options.Height or 160 self.MaxLines=options.MaxLines or 200 self.
Lines={}self.Value=self.Lines return self:_register()end function Console:Log(
text,level)level=level or'info'local line={Text=tostring(text),Level=level,Time=
os.date('%H:%M:%S')}table.insert(self.Lines,line)while#self.Lines>self.MaxLines
do table.remove(self.Lines,1)if self._labels and self._labels[1]then table.
remove(self._labels,1):Destroy()end end if self._list then self:_line(line)end
return self end function Console:Info(t)return self:Log(t,'info')end function
Console:Warn(t)return self:Log(t,'warn')end function Console:Error(t)return self
:Log(t,'error')end function Console:Success(t)return self:Log(t,'success')end
function Console:Clear()table.clear(self.Lines)for _,l in self._labels or{}do l:
Destroy()end self._labels={}return self end function Console:GetLines()return
table.clone(self.Lines)end function Console:_line(line)self._order=(self._order
or 0)+1 local label=Util.Label({Text='<font transparency="0.5">'..line.Time..
'</font>  '..Util.Escape(line.Text),RichText=true,FontFace=Theme.Fonts.Mono,
TextSize=11,TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1
,0,0,0),LayoutOrder=self._order,Parent=self._list})Theme.Paint(label,{TextColor3
=levelTokens[line.Level]or'TextDim'})table.insert(self._labels,label)task.defer(
function()if self._list then self._list.CanvasPosition=Vector2.new(0,1e6)end end
)end function Console:_build(parent)local frame=Util.New('Frame',{Name='Console'
,Size=UDim2.new(1,0,0,self.Height),Parent=parent})self.Frame=frame Util.Corner(6
,frame)Theme.Paint(frame,{BackgroundColor3='Bg'})Theme.Paint(Util.Stroke(frame),
{Color='Stroke'})local list=Util.New('ScrollingFrame',{BackgroundTransparency=1,
BorderSizePixel=0,Size=UDim2.fromScale(1,1),CanvasSize=UDim2.new(),
AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,Parent=frame})
Theme.Paint(list,{ScrollBarImageColor3='StrokeHi'})Util.List(list,1)Util.
Padding(list,6,8,6,8)self._list,self._labels=list,{}for _,line in self.Lines do
self:_line(line)end end local Code=Base.extend('Code')classes.Code=Code noState(
Code)function Code.new(section,options)local self=Base.new(Code,section,{Name=
options.Title or options.Name or''})self.Value=tostring(options.Code or options.
Content or'')return self:_register()end function Code:_build(parent)local frame=
Util.New('Frame',{Name='Code',AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(
1,0,0,0),Parent=parent})self.Frame=frame Util.Corner(6,frame)Theme.Paint(frame,{
BackgroundColor3='Bg'})Theme.Paint(Util.Stroke(frame),{Color='Stroke'})Util.
Padding(frame,8,34,8,10)local text=Util.Label({Text=self.Value,FontFace=Theme.
Fonts.Mono,TextSize=11,TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y,Size=
UDim2.new(1,0,0,0),Parent=frame})Theme.Paint(text,{TextColor3='Text'})local copy
=Util.New('ImageButton',{BackgroundTransparency=1,Image=Icons.Get('copy')or'',
Size=UDim2.fromOffset(14,14),AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,
26,0,0),Parent=frame})Theme.Paint(copy,{ImageColor3='TextDim'})copy.Activated:
Connect(function()Env.Clipboard(self.Value)Theme.Paint(copy,{ImageColor3=
'Success'},0.1)task.delay(1,function()Theme.Paint(copy,{ImageColor3='TextDim'},
0.3)end)if self.Library.Notify then self.Library:Notify({Content=Locale.T(
'Copied'),Type='success',Duration=2})end end)self._text=text end function Code:
_render()if self._text then self._text.Text=self.Value end end return classes
end function __DARKLUA_BUNDLE_MODULES.s()local v=__DARKLUA_BUNDLE_MODULES.cache.
s if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.s=v end return v
.c end end do local function __modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()
local Env=__DARKLUA_BUNDLE_MODULES.e()local Theme=__DARKLUA_BUNDLE_MODULES.g()
local Icons=__DARKLUA_BUNDLE_MODULES.i()local Locale=__DARKLUA_BUNDLE_MODULES.j(
)local Shared=__DARKLUA_BUNDLE_MODULES.k()local Base=__DARKLUA_BUNDLE_MODULES.n(
)local Players=Env.Service('Players')local PlayerList=Base.extend('PlayerList')
local builtIn={Spectate={Icon='eye',Tooltip='Spectate',Callback=function(player,
list)local cam=workspace.CurrentCamera local hum=player.Character and player.
Character:FindFirstChildOfClass('Humanoid')if list._spectating==player then list
:StopSpectating()elseif hum then list._spectating=player cam.CameraSubject=hum
end end},Teleport={Icon='map-pin',Tooltip='Teleport',Callback=function(player)
local me=Players.LocalPlayer.Character local root=me and me:FindFirstChild(
'HumanoidRootPart')local target=player.Character and player.Character:
FindFirstChild('HumanoidRootPart')if root and target then root.CFrame=target.
CFrame*CFrame.new(0,0,3)end end},Copy={Icon='copy',Tooltip='Copy name',Callback=
function(player)Env.Clipboard(player.Name)Shared.Lib:Notify({Content=Locale.T(
'Copied')..': '..player.Name,Type='success',Duration=2})end}}function PlayerList
.new(section,options)local self=Base.new(PlayerList,section,options)self.Height=
options.Height or 260 self.ExcludeSelf=options.ExcludeSelf~=false self.
SearchEnabled=options.Search~=false self.OnSelect=options.OnSelect self.Actions=
{}for _,a in options.Actions or{'Spectate','Teleport','Copy'}do table.insert(
self.Actions,type(a)=='string'and builtIn[a]or a)end self.Query=''self.Value=nil
self:_register()self.Maid:Connect(Players.PlayerAdded,function()self:Refresh()
end)self.Maid:Connect(Players.PlayerRemoving,function(p)if self._spectating==p
then self:StopSpectating()end task.defer(function()self:Refresh()end)end)return
self end function PlayerList:GetSelected()return self.Value end function
PlayerList:StopSpectating()self._spectating=nil local me=Players.LocalPlayer.
Character local hum=me and me:FindFirstChildOfClass('Humanoid')if hum then
workspace.CurrentCamera.CameraSubject=hum end return self end function
PlayerList:_contextItems()return{}end function PlayerList:_applyState()if self.
Frame then self.Frame.Visible=self.Visible and self._depsOk~=false end end
function PlayerList:_build(parent)local frame=Util.New('Frame',{Name=
'PlayerList',BackgroundTransparency=1,Size=UDim2.new(1,0,0,self.Height),Parent=
parent})self.Frame=frame local y=0 if self.SearchEnabled then local search=Util.
New('TextBox',{Text='',PlaceholderText=Locale.T('Search')..'\u{2026}',
ClearTextOnFocus=false,FontFace=Theme.Fonts.Regular,TextSize=12,TextXAlignment=
Enum.TextXAlignment.Left,Size=UDim2.new(1,-8,0,26),Position=UDim2.fromOffset(4,0
),Parent=frame})Util.Corner(6,search)Util.Padding(search,0,8,0,26)Theme.Paint(
search,{BackgroundColor3='Surface2',TextColor3='Text',PlaceholderColor3=
'TextMute'})local icon=Util.New('ImageLabel',{BackgroundTransparency=1,Image=
Icons.Get('search')or'',Size=UDim2.fromOffset(13,13),Position=UDim2.new(0,-19,
0.5,-6),Parent=search})Theme.Paint(icon,{ImageColor3='TextMute'})search:
GetPropertyChangedSignal('Text'):Connect(function()self.Query=search.Text self:
Refresh()end)y=32 end local list=Util.New('ScrollingFrame',{
BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,-y),Position=
UDim2.fromOffset(0,y),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.
AutomaticSize.Y,ScrollBarThickness=2,Parent=frame})Theme.Paint(list,{
ScrollBarImageColor3='StrokeHi'})Util.List(list,4)Util.Padding(list,0,4,0,4)self
._list=list self._rows={}task.spawn(function()while self.Frame and not self.
_destroyed do self:_updateDistances()task.wait(0.5)end end)self:Refresh()end
function PlayerList:_updateDistances()local me=Players.LocalPlayer.Character
local root=me and me:FindFirstChild('HumanoidRootPart')for player,row in self.
_rows or{}do local target=player.Character and player.Character:FindFirstChild(
'HumanoidRootPart')row.Distance.Text=(root and target)and(math.floor((root.
Position-target.Position).Magnitude)..' st')or'-'row.Eye.Visible=self.
_spectating==player end end function PlayerList:Refresh()if not self._list then
return self end for _,row in self._rows do row.Frame:Destroy()end self._rows={}
local players=Players:GetPlayers()table.sort(players,function(a,b)return string.
lower(a.DisplayName)<string.lower(b.DisplayName)end)for i,player in players do
if not(self.ExcludeSelf and player==Players.LocalPlayer)and Util.Fuzzy(self.
Query,player.DisplayName..' '..player.Name)then local row=Util.New('TextButton',
{Text='',AutoButtonColor=false,Size=UDim2.new(1,0,0,40),LayoutOrder=i,Parent=
self._list})Util.Corner(7,row)Theme.Paint(row,{BackgroundColor3=self.Value==
player and'Surface3'or'Surface2'})local avatar=Util.New('ImageLabel',{Image=
Shared.Lib.Anonymous and''or('rbxthumb://type=AvatarHeadShot&id='..player.UserId
..'&w=48&h=48'),Size=UDim2.fromOffset(28,28),Position=UDim2.new(0,7,0.5,-14),
Parent=row})Util.Round(avatar)Theme.Paint(avatar,{BackgroundColor3='Surface3'})
local name=Util.Label({Text=player.DisplayName,FontFace=Theme.Fonts.SemiBold,
TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,-150,0,15),
Position=UDim2.fromOffset(43,5),Parent=row})Theme.Paint(name,{TextColor3='Text'}
)local user=Util.Label({Text='@'..player.Name,FontFace=Theme.Fonts.Regular,
TextSize=10,TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,-150,0,13),
Position=UDim2.fromOffset(43,21),Parent=row})Theme.Paint(user,{TextColor3=
'TextMute'})local eye=Util.New('ImageLabel',{BackgroundTransparency=1,Image=
Icons.Get('eye')or'',Size=UDim2.fromOffset(11,11),Position=UDim2.new(0,27,0,4),
Visible=false,Parent=row})Theme.Paint(eye,{ImageColor3='Accent'})local dist=Util
.Label({Text='',FontFace=Theme.Fonts.Mono,TextSize=11,TextXAlignment=Enum.
TextXAlignment.Right,Size=UDim2.new(0,60,1,0),Position=UDim2.new(1,-60-#self.
Actions*24,0,0),Parent=row})Theme.Paint(dist,{TextColor3='TextDim'})for a,action
in self.Actions do local b=Util.New('ImageButton',{BackgroundTransparency=1,
Image=Icons.Get(action.Icon)or'',Size=UDim2.fromOffset(15,15),AnchorPoint=
Vector2.new(1,0.5),Position=UDim2.new(1,-10-(#self.Actions-a)*24,0.5,0),ZIndex=2
,Parent=row})Theme.Paint(b,{ImageColor3='TextDim'})b.MouseEnter:Connect(function
()Theme.Paint(b,{ImageColor3='Text'},0.1)end)b.MouseLeave:Connect(function()
Theme.Paint(b,{ImageColor3='TextDim'},0.1)end)if action.Tooltip then Shared.
Overlay.Hover(b,function()return action.Tooltip end)end b.Activated:Connect(
function()Util.SafeCall(action.Callback,player,self)self:_updateDistances()end)
end row.Activated:Connect(function()self.Value=player for p,r in self._rows do
Theme.Paint(r.Frame,{BackgroundColor3=p==player and'Surface3'or'Surface2'},0.1)
end self.Changed:Fire(player)if self.OnSelect then Util.SafeCall(self.OnSelect,
player)end self:_fireCallbacks()end)self._rows[player]={Frame=row,Distance=dist,
Eye=eye}end end self:_updateDistances()return self end function PlayerList:
_callbackArgs()return self.Value end return{PlayerList=PlayerList}end function
__DARKLUA_BUNDLE_MODULES.t()local v=__DARKLUA_BUNDLE_MODULES.cache.t if not v
then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.t=v end return v.c end end
do local function __modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Signal
=__DARKLUA_BUNDLE_MODULES.b()local Maid=__DARKLUA_BUNDLE_MODULES.c()local Tween=
__DARKLUA_BUNDLE_MODULES.d()local Theme=__DARKLUA_BUNDLE_MODULES.g()local Icons=
__DARKLUA_BUNDLE_MODULES.i()local Shared=__DARKLUA_BUNDLE_MODULES.k()local
Section={}Section.__index=Section function Section.new(page,options)options=
type(options)=='string'and{Name=options}or(options or{})local self=setmetatable(
{},Section)self.Page=page self.Tab=page and page.Tab self.Window=page and page.
Window self.Name=options.Name or options.Title or''self.Icon=options.Icon self.
Side=Section._side(options.Side or options.Position)self.Collapsible=options.
Collapsible==true self.Collapsed=options.Collapsed==true self.HasToggle=options.
Toggle==true or options.Enabled~=nil and options.Toggle~=false self.Enabled=
options.Enabled~=false self.Flag=options.Flag self.Callback=options.Callback
self.Elements={}self.Children={}self.Maid=Maid.new()self.Changed=Signal.new()
self._counter=0 self.Visible=options.Visible~=false self.Risky=options.Risky==
true if self.HasToggle then Section._registerToggle(self)end return self end
function Section._side(side)if side==2 or side=='Right'or side=='right'then
return'Right'elseif side=='Full'or side=='full'or side==0 then return'Full'end
return'Left'end function Section._registerToggle(self)local Lib=Shared.Lib local
proxy={Type='SectionToggle',Name=self.Name,Flag=self.Flag,Value=self.Enabled,
Default=self.Enabled,Changed=self.Changed,Section=self}function proxy._serialize
()return self.Enabled end function proxy._deserialize(_,v,silent)self:
SetEnabled(v==true,silent)end function proxy.Get()return self.Enabled end
function proxy.Set(_,v)self:SetEnabled(v)end function proxy.IsVisible()return
true end self._proxy=proxy if self.Flag then Lib.Elements[self.Flag]=proxy Lib.
Flags[self.Flag]=self.Enabled end end function Section.newFloating(owner,options
)local self=Section.new(nil,options)self.Owner=owner self.Window=owner.Window
self.Tab=owner.Tab self.Page=owner.Section and owner.Section.Page self.Floating=
true self.Name=options.Name or owner.Name return self end function Section:
IsDisabled()if self.HasToggle and not self.Enabled then return true end if self.
ParentSection then return self.ParentSection:IsDisabled()end if self.Owner and
self.Owner.IsLocked then return self.Owner:IsLocked()end return false end
function Section:_add(element)self._counter+=1 element._order=self._counter
table.insert(self.Elements,element)if element.Risky then self:_markRisky()end if
element.Type=='Toggle'then element.Changed:Connect(function()self:_updateCount()
end)task.defer(function()self:_updateCount()end)end if self.Floating then if
self._mounted then element:_mount(self.Body,element._order)end return end if
self.Window then self.Window:_enqueue(element)end end function Section:_remove(
element)local i=table.find(self.Elements,element)if i then table.remove(self.
Elements,i)end end function Section:GetElements()return table.clone(self.
Elements)end function Section:Find(name)for _,el in self.Elements do if el.Name
==name or el.Flag==name then return el end end for _,child in self.Children do
local found=child:Find(name)if found then return found end end return nil end
function Section:Clear()for _,el in table.clone(self.Elements)do el:Destroy()end
return self end function Section:_ensureMounted()if self._mounted then return
end if self.ParentSection then self.ParentSection:_ensureMounted()self:
_buildChild()return end self.Page:_ensureMounted()self:_build(self.Page:_column(
self.Side))end function Section:_build(parent)self._mounted=true local frame=
Util.New('Frame',{Name='Section_'..self.Name,AutomaticSize=Enum.AutomaticSize.Y,
Size=UDim2.new(1,0,0,0),LayoutOrder=self.Order or 0,Visible=self.Visible,Parent=
parent})Util.Corner(8,frame)Theme.Paint(frame,{BackgroundColor3='Surface'})local
stroke=Util.Stroke(frame)Theme.Paint(stroke,{Color='Stroke'})self.Frame,self.
Stroke=frame,stroke local header=Util.New('TextButton',{Name='Header',Text='',
AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,0,34),Visible=
self.Name~=''or self.HasToggle,Parent=frame})local x=12 local icon=Icons.Get(
self.Icon)if icon then local img=Util.New('ImageLabel',{BackgroundTransparency=1
,Image=icon,Size=UDim2.fromOffset(13,13),Position=UDim2.new(0,12,0.5,-6),Parent=
header})Theme.Paint(img,{ImageColor3='TextDim'})x=31 end local title=Util.Label(
{Text=string.upper(self.Name),FontFace=Theme.Fonts.Bold,TextSize=11,Size=UDim2.
new(1,-x-50,1,0),Position=UDim2.fromOffset(x,0),TextTruncate=Enum.TextTruncate.
AtEnd,Parent=header})Theme.Paint(title,{TextColor3='TextDim'})self._title=title
local count=Util.Label({Text='',FontFace=Theme.Fonts.Mono,TextSize=10,
TextXAlignment=Enum.TextXAlignment.Right,AutomaticSize=Enum.AutomaticSize.X,Size
=UDim2.new(0,0,1,0),AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,(self.
HasToggle and-36 or-12)-(self.Collapsible and 22 or 0),0,0),Parent=header})Theme
.Paint(count,{TextColor3='TextMute'})self._count=count local line=Util.New(
'Frame',{BorderSizePixel=0,Size=UDim2.new(1,-16,0,1),Position=UDim2.new(0,8,1,-1
),Parent=header})Theme.Paint(line,{BackgroundColor3='Stroke'})if self.HasToggle
then local box=Util.New('TextButton',{Text='',AutoButtonColor=false,Size=UDim2.
fromOffset(16,16),AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0)
,Parent=header})Util.Corner(4,box)local boxStroke=Util.Stroke(box)local check=
Util.New('ImageLabel',{BackgroundTransparency=1,Image=Icons.Get('check')or'',
Size=UDim2.fromOffset(11,11),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.
fromScale(0.5,0.5),Parent=box})Theme.Paint(check,{ImageColor3='AccentInk'})self.
_box,self._boxStroke,self._check=box,boxStroke,check box.Activated:Connect(
function()if self.Owner==nil then self:SetEnabled(not self.Enabled)end end)end
if self.Collapsible then local chev=Util.New('ImageLabel',{
BackgroundTransparency=1,Image=Icons.Get('chevron-down')or'',Size=UDim2.
fromOffset(13,13),AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,self.
HasToggle and-36 or-12,0.5,0),Parent=header})Theme.Paint(chev,{ImageColor3=
'TextMute'})self._chevron=chev header.Activated:Connect(function()self:
SetCollapsed(not self.Collapsed)end)end header.LayoutOrder=1 Util.List(frame,0)
local wrap=Util.New('Frame',{Name='Wrap',BackgroundTransparency=1,AutomaticSize=
Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),LayoutOrder=2,Parent=frame})local
body=Util.New('Frame',{Name='Body',BackgroundTransparency=1,AutomaticSize=Enum.
AutomaticSize.Y,Size=UDim2.new(1,0,0,0),Parent=wrap})Util.Padding(body,6,6,8,6)
local list=Util.List(body,2)list:SetAttribute('BaseGap',2)self.Body,self.Wrap=
body,wrap local dim=Util.New('TextButton',{Name='Dimmer',Text='',AutoButtonColor
=false,BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=30,Visible=
false,Parent=wrap})Theme.Paint(dim,{BackgroundColor3='Surface'})Util.Corner(8,
dim)self._dim=dim self:_paintState(false)self:_updateCount()if self.Risky then
self:_markRisky()end if self.Collapsed then self:SetCollapsed(true,true)end end
function Section:_paintState(animate)local t=animate and 0.18 or 0 if self._box
then Theme.Paint(self._box,{BackgroundColor3=self.Enabled and'Accent'or
'Surface3'},t)Theme.Paint(self._boxStroke,{Color=self.Enabled and'Accent'or
'StrokeHi'},t)self._check.ImageTransparency=self.Enabled and 0 or 1 Theme.Paint(
self._title,{TextColor3=self.Enabled and'Text'or'TextDim'},t)end if self._dim
then local off=self.HasToggle and not self.Enabled self._dim.Visible=off Tween.
Play(self._dim,{BackgroundTransparency=off and 0.45 or 1},t)end end function
Section:SetEnabled(enabled,silent)enabled=enabled and true or false if self.
Enabled==enabled then return self end self.Enabled=enabled local Lib=Shared.Lib
if self.Flag then Lib.Flags[self.Flag]=enabled end if self._proxy then self.
_proxy.Value=enabled end self:_paintState(true)for _,el in self:AllElements()do
el:_applyState()end if not silent and self.Callback then Util.SafeCall(self.
Callback,enabled)end self.Changed:Fire(enabled)if self._proxy then Lib:
_onElementChanged(self._proxy,enabled,not enabled)end return self end function
Section:_markRisky()if self.ParentSection then return self.ParentSection:
_markRisky()end self.Risky=true if self.Frame and not self._riskStripe and not
self.Floating then local stripe=Util.New('Frame',{Name='Risky',Size=UDim2.new(0,
2,1,-24),Position=UDim2.fromOffset(0,12),BorderSizePixel=0,ZIndex=5,Parent=self.
Frame})Util.Round(stripe)Theme.Paint(stripe,{BackgroundColor3='Risky'})self.
_riskStripe=stripe end end function Section:_updateCount()if self.ParentSection
then return self.ParentSection:_updateCount()end if not self._count then return
end local on,total=0,0 for _,el in self:AllElements()do if el.Type=='Toggle'then
total+=1 if el.Value then on+=1 end end end self._count.Text=total>=2 and(on..
'/'..total)or''Theme.Paint(self._count,{TextColor3=on>0 and'TextDim'or'TextMute'
})end function Section:IsEnabled()return self.Enabled end function Section:
AllElements()local out=table.clone(self.Elements)for _,child in self.Children do
for _,el in child:AllElements()do table.insert(out,el)end end return out end
function Section:SetCollapsed(collapsed,instant)self.Collapsed=collapsed if not
self.Body then return self end(self.Wrap or self.Body).Visible=not collapsed if
self._chevron then Tween.Play(self._chevron,{Rotation=collapsed and-90 or 0},
instant and 0 or 0.18)end return self end function Section:Collapse()return self
:SetCollapsed(true)end function Section:Expand()return self:SetCollapsed(false)
end function Section:SetName(name)self.Name=name if self._title then self._title
.Text=string.upper(name)end return self end Section.SetTitle=Section.SetName
function Section:SetVisible(visible)self.Visible=visible if self.Frame then self
.Frame.Visible=visible end return self end function Section:_reveal()if self.
ParentSection then self.ParentSection:_reveal()if self.ParentSection._tabs then
self.ParentSection:SelectTab(self)end end if self.Page then self.Page:Select()
end if self.Collapsed then self:SetCollapsed(false)end end function Section:Tabs
(names,options)options=options or{}self._tabs={}self._tabIcons=options.Icons or{
}local out={}for i,name in names do local child=Section.new(nil,{Name=name})
child.ParentSection=self child.Window=self.Window child.Tab=self.Tab child.Page=
self.Page child.Owner=nil child.TabIndex=i child.Floating=self.Floating table.
insert(self._tabs,child)table.insert(self.Children,child)table.insert(out,child)
end self._tabFlag=options.Flag self._activeTab=self._tabs[1]local default=
options.Default for _,t in self._tabs do if t.Name==default then self._activeTab
=t end end if self._tabFlag then local Lib=Shared.Lib local proxy={Type=
'SectionTabs',Name=self.Name,Flag=self._tabFlag,Changed=Signal.new()}function
proxy._serialize()return self._activeTab and self._activeTab.Name end function
proxy._deserialize(_,v)self:SelectTab(v)end function proxy.Get()return self.
_activeTab and self._activeTab.Name end function proxy.Set(_,v)self:SelectTab(v)
end function proxy.IsVisible()return true end self._tabProxy=proxy Lib.Elements[
self._tabFlag]=proxy Lib.Flags[self._tabFlag]=proxy.Get()end if self._mounted
then self:_buildTabBar()end return table.unpack(out)end function Section:
_buildTabBar()if self._tabBar or not self._tabs then return end local bar=Util.
New('Frame',{Name='TabBar',Size=UDim2.new(1,0,0,30),LayoutOrder=-1,Parent=self.
Body})Util.Corner(6,bar)Theme.Paint(bar,{BackgroundColor3='Bg2'})Theme.Paint(
Util.Stroke(bar),{Color='Stroke'})local indicator=Util.New('Frame',{Name=
'Indicator',Size=UDim2.new(1/#self._tabs,-6,1,-6),Position=UDim2.fromOffset(3,3)
,Parent=bar})Util.Corner(5,indicator)Theme.Paint(indicator,{BackgroundColor3=
'Surface3'})Theme.Paint(Util.Stroke(indicator),{Color='StrokeHi'})self._tabBar,
self._tabIndicator,self._tabButtons=bar,indicator,{}for i,child in self._tabs do
local b=Util.New('TextButton',{Text='',AutoButtonColor=false,
BackgroundTransparency=1,Size=UDim2.new(1/#self._tabs,0,1,0),Position=UDim2.
fromScale((i-1)/#self._tabs,0),ZIndex=2,Parent=bar})local holder=Util.New(
'Frame',{BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.
fromScale(0,1),AnchorPoint=Vector2.new(0.5,0),Position=UDim2.fromScale(0.5,0),
ZIndex=2,Parent=b})Util.List(holder,5,Enum.FillDirection.Horizontal,Enum.
HorizontalAlignment.Center,Enum.VerticalAlignment.Center)local iconId=Icons.Get(
self._tabIcons[i])local img if iconId then img=Util.New('ImageLabel',{
BackgroundTransparency=1,Image=iconId,Size=UDim2.fromOffset(13,13),ZIndex=2,
Parent=holder})end local label=Util.Label({Text=child.Name,FontFace=Theme.Fonts.
SemiBold,TextSize=12,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromScale(0,1
),LayoutOrder=2,ZIndex=2,Parent=holder})self._tabButtons[child]={Label=label,
Icon=img}b.Activated:Connect(function()self:SelectTab(child)end)end self:
_paintTabs(false)end function Section:_paintTabs(animate)if not self._tabBar
then return end local index=self._activeTab and self._activeTab.TabIndex or 1
Tween.Play(self._tabIndicator,{Position=UDim2.new((index-1)/#self._tabs,3,0,3)},
animate and 0.25 or 0,Enum.EasingStyle.Back)for child,refs in self._tabButtons
do local on=child==self._activeTab Theme.Paint(refs.Label,{TextColor3=on and
'Text'or'TextMute'},animate and 0.15 or 0)if refs.Icon then Theme.Paint(refs.
Icon,{ImageColor3=on and'Accent'or'TextMute'},animate and 0.15 or 0)end if child
.Body then child.Body.Visible=on end end end function Section:SelectTab(which)if
not self._tabs then return self end for _,child in self._tabs do if child==which
or child.Name==which or child.TabIndex==which then if self._activeTab~=child
then self._activeTab=child self:_paintTabs(true)if self._tabProxy then Shared.
Lib.Flags[self._tabFlag]=child.Name Shared.Lib:_onElementChanged(self._tabProxy,
child.Name,nil)end end end end return self end function Section:GetTab()return
self._activeTab and self._activeTab.Name end function Section:_buildChild()if
self._mounted then return end self._mounted=true local parent=self.ParentSection
parent:_buildTabBar()local body=Util.New('Frame',{Name='Tab_'..self.Name,
BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0
,0),LayoutOrder=self.TabIndex,Visible=parent._activeTab==self,Parent=parent.Body
})Util.Padding(body,4,0,0,0)Util.List(body,2)self.Body=body self.Frame=body end
function Section:Toggle(anchor)if self._popup and self._popup.Open then self.
_popup:Close()return end self:Open(anchor)end function Section:Open(anchor)if
not self.Floating then return self end local Overlay=Shared.Overlay local popup=
Overlay.Popup({Anchor=anchor,Width=260,MaxHeight=380,Side='Right',Padding=6,
Spacing=2,OnClose=function()self._mounted=false self.Body=nil for _,el in self:
AllElements()do el._mounted=false el.Frame=nil for _,link in el.Links do link.
_mounted=false end end for _,child in self.Children do child._mounted=false
child.Body=nil end self._tabBar=nil end})self._popup=popup local z=popup.Frame.
ZIndex local title=Util.Label({Text=string.upper(self.Name),FontFace=Theme.Fonts
.Bold,TextSize=11,Size=UDim2.new(1,0,0,24),LayoutOrder=-2,ZIndex=z,Parent=popup.
Content})Util.Padding(title,0,0,0,6)Theme.Paint(title,{TextColor3='TextDim'})
self.Body=popup.Content self._mounted=true if self._tabs then self:_buildTabBar(
)end for _,el in self.Elements do el:_mount(self.Body,el._order)end for _,child
in self.Children do child:_buildChild()for _,el in child.Elements do el:_mount(
child.Body,el._order)end end self:_paintTabs(false)for _,d in popup.Content:
GetDescendants()do if d:IsA('GuiObject')then d.ZIndex=z+(d.ZIndex>1 and d.ZIndex
-1 or 0)end end return self end function Section:Close()if self._popup then self
._popup:Close()end return self end function Section:Destroy()self:Clear()for _,
child in self.Children do child:Destroy()end if self._popup then self._popup:
Close()end self.Maid:Clean()if self.Frame and not self.Floating then self.Frame:
Destroy()end if self.Page then local i=table.find(self.Page.Sections,self)if i
then table.remove(self.Page.Sections,i)end end end local constructors={Toggle=
'Toggle',Checkbox='Toggle',Button='Button',ButtonGroup='ButtonGroup',Buttons=
'ButtonGroup',Label='Label',Text='Label',Paragraph='Paragraph',Divider='Divider'
,Separator='Divider',Spacer='Spacer',Navigate='Navigate',Link='Navigate',Slider=
'Slider',Dropdown='Dropdown',Input='Input',TextBox='Input',Textbox='Input',
Keybind='Keybind',Bind='Keybind',ColorPicker='ColorPicker',Colorpicker=
'ColorPicker',Color='ColorPicker',Progress='Progress',ProgressBar='Progress',
Stat='Stat',StatGrid='StatGrid',Graph='Graph',Sparkline='Graph',Chart='Graph',
Table='Table',Catalog='Table',List='Table',Card='Card',Image='Image',Console=
'Console',Log='Console',Code='Code',PlayerList='PlayerList',Players='PlayerList'
}for method,className in constructors do local function make(self,options)local
class=Shared.Lib._classes[className]if type(options)~='table'and className~=
'Label'and className~='Divider'and className~='Paragraph'and className~='Spacer'
then options={Name=options}end if className=='Toggle'and method=='Checkbox'then
options.Style=options.Style or'Checkbox'end return class.new(self,options or{})
end if method~='Toggle'then Section[method]=make end Section['Add'..method]=make
Section['Create'..method]=make end local originalToggle=Section.Toggle function
Section:Toggle(arg)if typeof(arg)=='Instance'or(arg==nil and self.Floating)then
return originalToggle(self,arg)end return Shared.Lib._classes.Toggle.new(self,
type(arg)=='table'and arg or{Name=arg})end function Section:RangeSlider(options)
options=options or{}options.Range=true return Shared.Lib._classes.Slider.new(
self,options)end Section.AddRangeSlider=Section.RangeSlider Section.RangedSlider
=Section.RangeSlider function Section:TextSlider(options)options=options or{}
options.Labels=options.Labels or options.Values or options.TextProps return
Shared.Lib._classes.Slider.new(self,options)end Section.AddTextSlider=Section.
TextSlider function Section:MultiDropdown(options)options=options or{}options.
Multi=true return Shared.Lib._classes.Dropdown.new(self,options)end Section.
AddMultiDropdown=Section.MultiDropdown function Section:PlayerDropdown(options)
return Shared.Lib._classes.PlayerDropdown(self,options or{})end Section.
AddPlayerDropdown=Section.PlayerDropdown function Section:Custom(name,options)
local class=Shared.Lib._custom[name]assert(class,
"[Proximity] unknown custom element '"..tostring(name).."'")return class.new(
self,options or{})end return Section end function __DARKLUA_BUNDLE_MODULES.u()
local v=__DARKLUA_BUNDLE_MODULES.cache.u if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.u=v end return v.c end end do local function 
__modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Signal=
__DARKLUA_BUNDLE_MODULES.b()local Tween=__DARKLUA_BUNDLE_MODULES.d()local Theme=
__DARKLUA_BUNDLE_MODULES.g()local Icons=__DARKLUA_BUNDLE_MODULES.i()local Shared
=__DARKLUA_BUNDLE_MODULES.k()local Section=__DARKLUA_BUNDLE_MODULES.u()local
Page={}Page.__index=Page function Page.new(tab,options)options=type(options)==
'string'and{Name=options}or(options or{})local self=setmetatable({},Page)self.
Tab=tab self.Window=tab.Window self.Name=options.Name or tab.Name self.Icon=
options.Icon self.Description=options.Description self.Hidden=options.Hidden==
true self.Implicit=options.Implicit==true self.Columns=options.Columns or 2 self
.Sections={}self.Selected=Signal.new()self._order=0 return self end function
Page:Section(options)local section=Section.new(self,options)self._order+=1
section.Order=self._order table.insert(self.Sections,section)return section end
Page.AddSection=Page.Section Page.DrawSection=Page.Section Page.CreateSection=
Page.Section function Page:LeftSection(options)options=type(options)=='string'
and{Name=options}or(options or{})options.Side='Left'return self:Section(options)
end function Page:RightSection(options)options=type(options)=='string'and{Name=
options}or(options or{})options.Side='Right'return self:Section(options)end
function Page:FullSection(options)options=type(options)=='string'and{Name=
options}or(options or{})options.Side='Full'return self:Section(options)end
function Page:_ensureMounted()if self._mounted then return end self._mounted=
true local window=self.Window local scroller=Util.New('ScrollingFrame',{Name=
'Page_'..self.Name,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.
fromScale(1,1),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,
ScrollBarThickness=3,ScrollingDirection=Enum.ScrollingDirection.Y,
VerticalScrollBarInset=Enum.ScrollBarInset.ScrollBar,Visible=window.CurrentPage
==self,Parent=window.Content})Theme.Paint(scroller,{ScrollBarImageColor3=
'StrokeHi'})local remember=Util.Debounce(0.8,function()if window.State=='Ready'
then Shared.Lib:SetSetting(window:_scrollKey(self),math.floor(scroller.
CanvasPosition.Y))end end)scroller:GetPropertyChangedSignal('CanvasPosition'):
Connect(remember)Util.Padding(scroller,12,12,14,12)Util.List(scroller,10)self.
Frame=scroller local full=Util.New('Frame',{Name='Full',BackgroundTransparency=1
,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),LayoutOrder=1,Parent
=scroller})Util.List(full,10)local row=Util.New('Frame',{Name='Columns',
BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0
,0),LayoutOrder=2,Parent=scroller})local left=Util.New('Frame',{Name='Left',
BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(0.5,-
5,0,0),Parent=row})Util.List(left,10)local right=Util.New('Frame',{Name='Right',
BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(0.5,-
5,0,0),Position=UDim2.new(0.5,5,0,0),Parent=row})Util.List(right,10)self._full,
self._left,self._right,self._row=full,left,right,row self:_layoutColumns()end
function Page:_layoutColumns()if not self._row then return end local holder=self
.Window.Holder local k=holder and holder.Size.X.Offset>0 and holder.AbsoluteSize
.X/holder.Size.X.Offset or(Shared.Scale or 1)if k<0.08 then return end local
width=self.Window.Content.AbsoluteSize.X/k local single=self.Columns==1 or width
<520 if single then self._left.Size=UDim2.new(1,0,0,0)self._right.Size=UDim2.
new(1,0,0,0)self._right.Position=UDim2.new(0,0,0,0)if not self._stack then self.
_stack=Util.List(self._row,10)end self._right.LayoutOrder=2 self._left.
LayoutOrder=1 else if self._stack then self._stack:Destroy()self._stack=nil end
self._left.Size=UDim2.new(0.5,-5,0,0)self._right.Size=UDim2.new(0.5,-5,0,0)self.
_right.Position=UDim2.new(0.5,5,0,0)end end function Page:_column(side)self:
_ensureMounted()if side=='Right'then return self._right elseif side=='Full'then
return self._full end return self._left end function Page:Select()self.Window:
_selectPage(self)return self end Page.Open=Page.Select function Page:IsSelected(
)return self.Window.CurrentPage==self end function Page:ScrollTo(gui)if not self
.Frame or not gui then return end local s=Shared.Scale or 1 local y=(gui.
AbsolutePosition.Y-self.Frame.AbsolutePosition.Y)/s+self.Frame.CanvasPosition.Y-
24 Tween.Play(self.Frame,{CanvasPosition=Vector2.new(0,math.max(0,y))},0.3)end
function Page:GetSections()return table.clone(self.Sections)end local Tab={}Tab.
__index=Tab function Tab.new(window,options)options=type(options)=='string'and{
Name=options}or(options or{})local self=setmetatable({},Tab)self.Window=window
self.Name=options.Name or options.Title or'Tab'self.Icon=options.Icon self.
Description=options.Description or options.Desc self.Badge=options.Badge self.
Visible=options.Visible~=false self.Pages={}self.Selected=Signal.new()self.Order
=options.Order self._total,self._done=0,0 return self end function Tab:
_defaultPage()if not self.Pages[1]then local page=Page.new(self,{Name=self.Name,
Implicit=true,Columns=self.Columns})table.insert(self.Pages,page)end return self
.Pages[1]end function Tab:Section(options)return self:_defaultPage():Section(
options)end Tab.AddSection=Tab.Section Tab.DrawSection=Tab.Section Tab.
CreateSection=Tab.Section function Tab:LeftSection(o)return self:_defaultPage():
LeftSection(o)end function Tab:RightSection(o)return self:_defaultPage():
RightSection(o)end function Tab:FullSection(o)return self:_defaultPage():
FullSection(o)end function Tab:SubTab(options)options=type(options)=='string'and
{Name=options}or(options or{})local first=self.Pages[1]if first and first.
Implicit and#first.Sections==0 and not options.Hidden then table.remove(self.
Pages,1)end local page=Page.new(self,options)table.insert(self.Pages,page)if
self.Window.CurrentTab==self then self.Window:_refreshPills()end return page end
Tab.SubPage=Tab.SubTab Tab.AddSubTab=Tab.SubTab Tab.Page=Tab.SubTab function Tab
:GetPage(name)for _,page in self.Pages do if page.Name==name then return page
end end return nil end function Tab:Select()self.Window:SelectTab(self)return
self end Tab.Open=Tab.Select function Tab:IsSelected()return self.Window.
CurrentTab==self end function Tab:SetName(name)self.Name=name if self._label
then self._label.Text=name end if self:IsSelected()then self.Window:
_refreshHeader()end return self end function Tab:SetIcon(icon)self.Icon=icon if
self._icon then self._icon.Image=Icons.Get(icon)or''end return self end function
Tab:SetDescription(text)self.Description=text if self:IsSelected()then self.
Window:_refreshHeader()end return self end function Tab:SetBadge(text)self.Badge
=text if self._badge then self._badge.Visible=text~=nil and text~=''self._badge.
Text=text and tostring(text)or''end return self end function Tab:SetVisible(
visible)self.Visible=visible if self.Button then self.Button.Visible=visible end
return self end function Tab:GetSections()local out={}for _,page in self.Pages
do for _,s in page.Sections do table.insert(out,s)end end return out end
function Tab:GetElements()local out={}for _,s in self:GetSections()do for _,el
in s:AllElements()do table.insert(out,el)end end return out end function Tab:
Destroy()for _,s in self:GetSections()do s:Destroy()end for _,page in self.Pages
do if page.Frame then page.Frame:Destroy()end end if self.Button then self.
Button:Destroy()end local tabs=self.Window.Tabs local i=table.find(tabs,self)if
i then table.remove(tabs,i)end if self.Window.CurrentTab==self and tabs[1]then
self.Window:SelectTab(tabs[1])end end return{Page=Page,Tab=Tab}end function
__DARKLUA_BUNDLE_MODULES.v()local v=__DARKLUA_BUNDLE_MODULES.cache.v if not v
then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.v=v end return v.c end end
do local function __modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Tween=
__DARKLUA_BUNDLE_MODULES.d()local Env=__DARKLUA_BUNDLE_MODULES.e()local Theme=
__DARKLUA_BUNDLE_MODULES.g()local Locale=__DARKLUA_BUNDLE_MODULES.j()local
RunService=Env.Service('RunService')local Skeleton={}Skeleton.__index=Skeleton
local function ghost(parent,size,position,radius)local frame=Util.New('Frame',{
Size=size,Position=position or UDim2.new(),BorderSizePixel=0,Parent=parent})Util
.Corner(radius or 4,frame)Theme.Paint(frame,{BackgroundColor3='Surface3'})local
shine=Util.Gradient(frame,ColorSequence.new(Color3.new(1,1,1)),NumberSequence.
new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.4,0),
NumberSequenceKeypoint.new(0.5,0.55),NumberSequenceKeypoint.new(0.6,0),
NumberSequenceKeypoint.new(1,0)}))shine.Offset=Vector2.new(-1,0)shine.Rotation=
18 return frame,shine end function Skeleton.new(window)local self=setmetatable({
},Skeleton)self.Window=window self.Rows={}self.Shines={}self.Started=os.clock()
self.Display=0 local root=Util.New('CanvasGroup',{Name='Skeleton',Size=UDim2.
fromScale(1,1),ZIndex=40,Parent=window.Canvas})Theme.Paint(root,{
BackgroundColor3='Bg'})Util.Corner(10,root)self.Root=root local side=Util.New(
'Frame',{Name='Side',Size=UDim2.new(0,window.SidebarWidth,1,0),BorderSizePixel=0
,Parent=root})Theme.Paint(side,{BackgroundColor3='Bg2'})local divider=Util.New(
'Frame',{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BorderSizePixel=0,
Parent=side})Theme.Paint(divider,{BackgroundColor3='Stroke'})local logo=window:
_drawLogo(side,26)logo.Position=UDim2.fromOffset(16,19)local title=Util.Label({
Text=window.Title,FontFace=Theme.Fonts.Bold,TextSize=15,Size=UDim2.new(1,-60,0,
18),Position=UDim2.fromOffset(52,17),TextTruncate=Enum.TextTruncate.AtEnd,Parent
=side})Theme.Paint(title,{TextColor3='Text'})local sub=Util.Label({Text=Locale.
T('Loading')..'\u{2026}',FontFace=Theme.Fonts.Regular,TextSize=11,Size=UDim2.
new(1,-60,0,14),Position=UDim2.fromOffset(52,35),Parent=side})Theme.Paint(sub,{
TextColor3='TextMute'})local list=Util.New('Frame',{BackgroundTransparency=1,
Size=UDim2.new(1,-16,1,-80),Position=UDim2.fromOffset(8,70),Parent=side})Util.
List(list,4)self.List=list local main=Util.New('Frame',{Name='Main',
BackgroundTransparency=1,Size=UDim2.new(1,-window.SidebarWidth,1,0),Position=
UDim2.fromOffset(window.SidebarWidth,0),Parent=root})local orbit=Util.New(
'Frame',{BackgroundTransparency=1,Size=UDim2.fromOffset(30,30),Position=UDim2.
fromOffset(20,18),Parent=main})local orbitRing=Util.New('Frame',{
BackgroundTransparency=1,Size=UDim2.fromOffset(30,12),AnchorPoint=Vector2.new(
0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Rotation=-16,Parent=orbit})Util.
Round(orbitRing)Theme.Paint(Util.Stroke(orbitRing),{Color='StrokeHi'})local core
=Util.New('Frame',{Size=UDim2.fromOffset(12,12),AnchorPoint=Vector2.new(0.5,0.5)
,Position=UDim2.fromScale(0.5,0.5),Parent=orbit})Util.Round(core)Theme.Paint(
core,{BackgroundColor3='Bg'})Theme.Paint(Util.Stroke(core,nil,1.4),{Color=
'Accent'})local moon=Util.New('Frame',{Size=UDim2.fromOffset(5,5),AnchorPoint=
Vector2.new(0.5,0.5),Parent=orbit})Util.Round(moon)Theme.Paint(moon,{
BackgroundColor3='Accent'})self.Moon=moon local percent=Util.Label({Text='0%',
FontFace=Theme.Fonts.MonoBold,TextSize=30,Size=UDim2.new(0,110,0,34),Position=
UDim2.fromOffset(60,16),Parent=main})Theme.Paint(percent,{TextColor3='Text'})
local stage=Util.Label({Text=Locale.T('Preparing'),FontFace=Theme.Fonts.Medium,
TextSize=12,Size=UDim2.new(1,-310,0,16),Position=UDim2.fromOffset(180,20),
TextTruncate=Enum.TextTruncate.AtEnd,Parent=main})Theme.Paint(stage,{TextColor3=
'TextDim'})local elapsed=Util.Label({Text='0.00s',FontFace=Theme.Fonts.Mono,
TextSize=11,Size=UDim2.new(1,-310,0,14),Position=UDim2.fromOffset(180,37),Parent
=main})Theme.Paint(elapsed,{TextColor3='TextMute'})local bar=Util.New('Frame',{
Size=UDim2.new(1,-40,0,3),Position=UDim2.fromOffset(20,60),BorderSizePixel=0,
Parent=main})Util.Round(bar)Theme.Paint(bar,{BackgroundColor3='Surface3'})local
fill=Util.New('Frame',{Size=UDim2.fromScale(0,1),BorderSizePixel=0,Parent=bar})
Util.Round(fill)Theme.Paint(fill,{BackgroundColor3='Accent'})local head=Util.
New('Frame',{Size=UDim2.fromOffset(18,7),AnchorPoint=Vector2.new(1,0.5),Position
=UDim2.fromScale(1,0.5),BackgroundTransparency=0.6,BorderSizePixel=0,Parent=fill
})Util.Round(head)Theme.Paint(head,{BackgroundColor3='Accent'})self.Percent,self
.Stage,self.Elapsed,self.Fill=percent,stage,elapsed,fill local cards=Util.New(
'Frame',{BackgroundTransparency=1,Size=UDim2.new(1,-40,1,-96),Position=UDim2.
fromOffset(20,80),ClipsDescendants=true,Parent=main})local plan={{0,0,150},{0,
160,120},{1,0,110},{1,120,170}}for _,p in plan do local card=Util.New('Frame',{
Size=UDim2.new(0.5,-5,0,p[3]),Position=UDim2.new(p[1]*0.5,p[1]*5,0,p[2]),
BorderSizePixel=0,Parent=cards})Util.Corner(8,card)Theme.Paint(card,{
BackgroundColor3='Surface'})Theme.Paint(Util.Stroke(card),{Color='Stroke'})local
_,s1=ghost(card,UDim2.new(0.35,0,0,8),UDim2.fromOffset(12,13))table.insert(self.
Shines,s1)local y=36 while y+22<p[3]do local _,s2=ghost(card,UDim2.new(0.55,-12,
0,9),UDim2.fromOffset(12,y+4))local _,s3=ghost(card,UDim2.fromOffset(28,14),
UDim2.new(1,-40,0,y+1),7)table.insert(self.Shines,s2)table.insert(self.Shines,s3
)y+=28 end end local skip=Util.New('TextButton',{Text=Locale.T('ShowNow'),
FontFace=Theme.Fonts.SemiBold,TextSize=12,AutoButtonColor=false,AutomaticSize=
Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,26),AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,-20,0,22),Visible=false,Parent=main})Util.Corner(6,skip)
Util.Padding(skip,0,12,0,12)Theme.Paint(skip,{BackgroundColor3='Surface3',
TextColor3='Text'})Theme.Paint(Util.Stroke(skip),{Color='StrokeHi'})skip.
Activated:Connect(function()window:_reveal(true)end)self.Skip=skip self.Conn=
RunService.Heartbeat:Connect(function()local t=os.clock()-self.Started local
offset=(t*0.9)%2.4-1.2 for _,s in self.Shines do s.Offset=Vector2.new(offset,0)
end if self.Moon then local a=t*2.6 local x,y=math.cos(a)*15,math.sin(a)*6 local
r=math.rad(-16)self.Moon.Position=UDim2.new(0.5,x*math.cos(r)-y*math.sin(r),0.5,
x*math.sin(r)+y*math.cos(r))self.Moon.ZIndex=math.sin(a)>0 and 3 or 1 end for _,
row in self.Rows do if row.Spinner.Visible then row.Spinner.Rotation=(t*360)%360
end end local p=self.Display self._samples=self._samples or{}table.insert(self.
_samples,{t,p})while#self._samples>2 and self._samples[1][1]<t-1.5 do table.
remove(self._samples,1)end local first=self._samples[1]local rate=(p-first[2])/
math.max(t-first[1],0.05)local eta=(rate>0.002 and p<0.98)and('  \u{b7}  ~'..
math.max(1,math.ceil((1-p)/rate))..' s left')or''self.Elapsed.Text=string.
format('%.1f s',t)..eta if t>2.5 and not skip.Visible and window.Loading.Skip~=
false then skip.Visible=true end end)return self end function Skeleton:AddTab(
tab)if self.Rows[tab]then return end local row=Util.New('Frame',{
BackgroundTransparency=1,Size=UDim2.new(1,0,0,30),LayoutOrder=#self.List:
GetChildren(),Parent=self.List})local iconGhost,shine=ghost(row,UDim2.
fromOffset(14,14),UDim2.new(0,8,0,4),4)table.insert(self.Shines,shine)local name
=Util.Label({Text=tab.Name,FontFace=Theme.Fonts.Medium,TextSize=12,Size=UDim2.
new(1,-60,0,14),Position=UDim2.fromOffset(30,4),TextTruncate=Enum.TextTruncate.
AtEnd,Parent=row})Theme.Paint(name,{TextColor3='TextMute'})local pct=Util.Label(
{Text='',FontFace=Theme.Fonts.Mono,TextSize=10,TextXAlignment=Enum.
TextXAlignment.Right,Size=UDim2.new(1,-8,0,14),Position=UDim2.fromOffset(0,4),
Parent=row})Theme.Paint(pct,{TextColor3='TextMute'})local track=Util.New('Frame'
,{Size=UDim2.new(1,-38,0,1),Position=UDim2.fromOffset(30,23),BorderSizePixel=0,
Parent=row})Util.Round(track)Theme.Paint(track,{BackgroundColor3='Surface3'})
local fill=Util.New('Frame',{Size=UDim2.fromScale(0,1),BorderSizePixel=0,Parent=
track})Util.Round(fill)Theme.Paint(fill,{BackgroundColor3='Accent'})local
spinner=Util.New('Frame',{BackgroundTransparency=1,Size=UDim2.fromOffset(12,12),
Position=UDim2.fromOffset(9,5),Visible=false,Parent=row})Util.Round(spinner)
local ring=Util.Stroke(spinner,nil,1.5)Theme.Paint(ring,{Color='Accent'})Util.
Gradient(ring,nil,NumberSequence.new({NumberSequenceKeypoint.new(0,0),
NumberSequenceKeypoint.new(0.7,0.2),NumberSequenceKeypoint.new(1,1)}))local
check=Util.New('ImageLabel',{BackgroundTransparency=1,Image=
__DARKLUA_BUNDLE_MODULES.i().Get('check')or'',Size=UDim2.fromOffset(14,14),
Position=UDim2.fromOffset(8,4),Visible=false,Parent=row})Theme.Paint(check,{
ImageColor3='Accent'})self.Rows[tab]={Frame=row,Name=name,Pct=pct,Fill=fill,
Spinner=spinner,Check=check,Ghost=iconGhost}end function Skeleton:Update(stage)
local window=self.Window for tab,row in self.Rows do local total,done=tab._total
,tab._done local p=total>0 and done/total or(window._declaring and 0 or 1)Tween.
Play(row.Fill,{Size=UDim2.fromScale(p,1)},0.15)local building=window.
_buildingTab==tab local finished=total>0 and done>=total row.Spinner.Visible=
building and not finished row.Check.Visible=finished row.Ghost.Visible=not
building and not finished row.Pct.Text=total>0 and(done..'/'..total)or''Theme.
Paint(row.Name,{TextColor3=(building or finished)and'Text'or'TextMute'})end
local actual=window:GetLoadProgress()self.Display=math.max(self.Display,math.
min(actual,window.State=='Ready'and 1 or 0.99))self.Percent.Text=math.floor(self
.Display*100+0.5)..'%'Tween.Play(self.Fill,{Size=UDim2.fromScale(self.Display,1)
},0.2)if stage then self.Stage.Text=stage end end function Skeleton:Finish(
callback)if self._finishing then return end self._finishing=true self.Display=1
self.Percent.Text='100%'self.Stage.Text=Locale.T('Ready')Tween.Play(self.Fill,{
Size=UDim2.fromScale(1,1)},0.15)task.delay(Tween.Speed>0 and 0.22 or 0,function(
)if not self.Root then return end local wipe=Util.New('UIGradient',{Rotation=20,
Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),
NumberSequenceKeypoint.new(0.42,1),NumberSequenceKeypoint.new(0.58,0),
NumberSequenceKeypoint.new(1,0)}),Offset=Vector2.new(-0.6,0),Parent=self.Root})
Tween.Play(wipe,{Offset=Vector2.new(1.1,0)},Tween.Speed>0 and 0.75 or 0,Enum.
EasingStyle.Quint,Enum.EasingDirection.InOut)if callback then callback()end task
.delay(0.8,function()self:Destroy()end)end)end function Skeleton:Destroy()if
self.Conn then self.Conn:Disconnect()self.Conn=nil end if self.Root then self.
Root:Destroy()self.Root=nil end end return Skeleton end function
__DARKLUA_BUNDLE_MODULES.w()local v=__DARKLUA_BUNDLE_MODULES.cache.w if not v
then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.w=v end return v.c end end
do local function __modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Tween=
__DARKLUA_BUNDLE_MODULES.d()local Env=__DARKLUA_BUNDLE_MODULES.e()local
RunService=Env.Service('RunService')local Motion={}Motion.Styles={'Planet',
'Rise','Zoom','Drop','Slide','Swing','Wipe','Unfold','Scan','Glitch','Fade',
'None'}local WHITE=Color3.new(1,1,1)local function clamp01(x)return math.clamp(x
,0,1)end local function sequence(points)table.sort(points,function(a,b)return a[
1]<b[1]end)local out,last={},-1 for _,pt in points do local t=math.clamp(pt[1],0
,1)if t<=last then t=last+0.0005 end if t<=1 and#out<18 then table.insert(out,
NumberSequenceKeypoint.new(t,math.clamp(pt[2],0,1)))last=t end end if#out==0
then return NumberSequence.new(1)end if out[1].Time>0 then table.insert(out,1,
NumberSequenceKeypoint.new(0,out[1].Value))end if out[#out].Time<1 then table.
insert(out,NumberSequenceKeypoint.new(1,out[#out].Value))end return
NumberSequence.new(out)end local function band(e,width,peak)return sequence({{0,
1},{e-width,1},{e,1-peak},{e+width*0.6,1},{1,1}})end local S={}S.Planet={Open={
2.3,0.74},Close={3.4,1},Ripple=true,Map=function(c,p,ctx)local d=ctx.From if d
then local qx,qy=clamp01(p)^0.8,clamp01(p)^1.15 c.Offset=Vector2.new(d.X*(1-qx),
d.Y*(1-qy))c.Scale=0.04+0.96*p c.Rotation=(1-clamp01(p))*(d.X>=0 and 8 or-8)else
c.Scale=0.6+0.4*p c.Offset=Vector2.new(0,(1-p)*16)end c.Alpha=clamp01(p*2.4)c.
Exposure=clamp01(p*1.3)c.Frame=clamp01((p-0.5)/0.5)end}S.Rise={Open={2.1,0.86},
Close={3.2,1},Map=function(c,p)c.Offset=Vector2.new(0,(1-p)*38)c.Scale=0.95+0.05
*p c.Alpha=clamp01(p*1.5)c.Exposure=clamp01(p*1.2)c.ShadowK=clamp01(p)^2 end}S.
Zoom={Open={2.7,0.58},Close={3.6,1},Map=function(c,p)c.Scale=0.8+0.2*p c.Alpha=
clamp01(p*2.2)c.Exposure=clamp01(p*1.5)c.Offset=Vector2.new(0,(1-p)*10)end}S.
Drop={Open={2,0.5},Close={3,1},Map=function(c,p)c.Offset=Vector2.new(0,-(1-p)*
130)c.Rotation=(1-p)*-3.2 c.Scale=0.96+0.04*p c.Alpha=clamp01(p*2.6)c.Exposure=
clamp01(p*1.4)end}S.Slide={Open={2.2,0.8},Close={3.2,1},Trail=true,Map=function(
c,p,ctx)c.Offset=Vector2.new(ctx.Dir*(1-p)*240,0)c.Rotation=ctx.Dir*(1-p)*-1.6 c
.Alpha=clamp01(p*1.9)c.Exposure=clamp01(p*1.3)end}S.Swing={Open={1.7,0.45},Close
={3,1},Map=function(c,p,ctx)local theta=-(1-p)*17 local r=math.rad(theta)local v
=ctx.Size/2 local rv=Vector2.new(v.X*math.cos(r)-v.Y*math.sin(r),v.X*math.sin(r)
+v.Y*math.cos(r))c.Rotation=theta c.Offset=rv-v+Vector2.new(0,(1-p)*18)c.Scale=
0.96+0.04*p c.Alpha=clamp01(p*2.4)c.Exposure=clamp01(p*1.4)end}S.Wipe={Open={
1.45,1},Close={2.3,1},Masked=true,Map=function(c,p)local e=p*1.42-0.21 c.Mask={
Rotation=24,Seq=sequence({{0,0},{e-0.09,0},{e+0.09,1},{1,1}})}c.Fx={Rotation=24,
Seq=band(e+0.05,0.1,0.55),Alpha=math.sin(clamp01(p)*math.pi)}c.Alpha=clamp01(p*4
)c.Exposure=0.7+0.3*clamp01(p)c.Frame=clamp01((p-0.72)/0.28)c.Offset=Vector2.
new((1-p)*-12,0)end}S.Unfold={Open={1.6,1},Close={2.5,1},Masked=true,Map=
function(c,p)local half,soft=clamp01(p)*0.57,0.04 c.Mask={Rotation=90,Seq=
sequence({{0,1},{0.5-half-soft,1},{0.5-half,0},{0.5+half,0},{0.5+half+soft,1},{1
,1}})}local glow=1-clamp01((p-0.8)/0.2)c.Fx={Rotation=90,Seq=sequence({{0,1},{
0.5-half-0.035,1},{0.5-half,0.35},{0.5-half+0.03,1},{0.5+half-0.03,1},{0.5+half,
0.35},{0.5+half+0.035,1},{1,1}}),Alpha=glow*clamp01(p*6)}c.Scale=0.985+0.015*p c
.Alpha=clamp01(p*5)c.Exposure=0.75+0.25*clamp01(p)c.Frame=clamp01((p-0.75)/0.25)
end}S.Scan={Open={1.35,1},Close={2.2,1},Masked=true,Map=function(c,p)local e=p*
1.16-0.08 c.Mask={Rotation=90,Seq=sequence({{0,0},{e,0},{e+0.03,1},{1,1}})}c.Fx=
{Rotation=90,Seq=sequence({{0,1},{e-0.14,1},{e-0.005,0.72},{e+0.004,0.15},{e+
0.02,1},{1,1}}),Alpha=math.sin(clamp01(p)*math.pi)^0.6}c.Alpha=clamp01(p*5)c.
Exposure=0.8+0.2*clamp01(p)c.Frame=clamp01((p-0.82)/0.18)end}local SLICES=9
local SLICE_AT={}do local rng=Random.new(31)for k=1,SLICES do SLICE_AT[k]=rng:
NextNumber(0.02,0.9)end end S.Glitch={Open={1.5,1},Close={2.4,1},Masked=true,Map
=function(c,p)local rng=Random.new(math.floor(os.clock()*22))local calm=clamp01(
p)^2 local pts={}for k=1,SLICES do local on=(p*1.18-0.08)>SLICE_AT[k]if p<0.97
and rng:NextNumber()<0.14*(1-calm)then on=not on end local v=on and 0 or 1 table
.insert(pts,{(k-1)/SLICES,v})table.insert(pts,{k/SLICES-0.001,v})end c.Mask={
Rotation=90,Seq=sequence(pts)}c.Offset=Vector2.new((rng:NextNumber()-0.5)*18*(1-
calm),(rng:NextNumber()-0.5)*4*(1-calm))c.Alpha=clamp01(p*3)c.Exposure=0.65+0.35
*clamp01(p)+(rng:NextNumber()<0.2 and 0.25*(1-calm)or 0)c.Fx={Rotation=0,Seq=
NumberSequence.new(0.4),Alpha=(rng:NextNumber()<0.25 and 0.18 or 0.04)*(1-calm)}
c.Frame=clamp01((p-0.85)/0.15)end}S.Fade={Open={1.8,1},Close={2.8,1},Map=
function(c,p)c.Scale=1.018-0.018*p c.Alpha=clamp01(p)c.Exposure=clamp01(p)end}
function Motion.Has(style)return S[style]~=nil end local function shadowOf(
window)local plate=window.Plate local shadow=plate and(plate:
FindFirstChildOfClass('UIShadow')or plate:FindFirstChild('Shadow'))if shadow and
window._shadowBase==nil then local ok,value=pcall(function()return shadow:IsA(
'ImageLabel')and shadow.ImageTransparency or shadow.Transparency end)window.
_shadowBase=ok and value or 0.35 end return shadow end local function setShadow(
window,k)local shadow=shadowOf(window)if shadow then local value=1-(1-(window.
_shadowBase or 0.35))*clamp01(k)pcall(function()if shadow:IsA('ImageLabel')then
shadow.ImageTransparency=value else shadow.Transparency=value end end)end end
local function fxLayer(window)local fx=window.Holder:FindFirstChild(
'ProximityMotionFx')if not fx then fx=Util.New('CanvasGroup',{Name=
'ProximityMotionFx',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=8,
GroupTransparency=1,Parent=window.Holder})Util.Corner(10,fx)Util.New('Frame',{
BorderSizePixel=0,BackgroundColor3=WHITE,Size=UDim2.fromScale(1,1),Parent=fx})
Util.New('UIGradient',{Name='Shape',Parent=fx})end return fx end local function 
ripple(window,point,size,strong)local parent=window.Holder.Parent if not(parent
and point)then return end local ring=Util.New('Frame',{AnchorPoint=Vector2.new(
0.5,0.5),Position=UDim2.fromOffset(point.X,point.Y),Size=UDim2.fromOffset(8,8),
BackgroundTransparency=1,ZIndex=50,Parent=parent})Util.Round(ring)local stroke=
Util.Stroke(ring,WHITE,strong and 1.6 or 1.1,strong and 0.15 or 0.4)local dot=
Util.New('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,
0.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=WHITE,BackgroundTransparency=
0.3,ZIndex=51,Parent=ring})Util.Round(dot)Tween.Play(ring,{Size=UDim2.
fromOffset(size,size)},0.75,Enum.EasingStyle.Quint)Tween.Play(stroke,{
Transparency=1,Thickness=0.4},0.75,Enum.EasingStyle.Sine)Tween.Play(dot,{
BackgroundTransparency=1,Size=UDim2.fromOffset(2,2)},0.4)task.delay(0.8,function
()ring:Destroy()end)end local function flourish(window)local fx=fxLayer(window)
local shape=fx.Shape shape.Rotation=24 fx.GroupTransparency=0 local token=window
._motionToken Tween.Value(0,1,0.95,function(k)if window._motionToken~=token or
not fx.Parent then return end local e=-0.25+1.5*k shape.Transparency=sequence({{
0,1},{e-0.2,1},{e,0.9},{e+0.06,0.93},{e+0.2,1},{1,1}})if k>=1 then fx:Destroy()
end end,Enum.EasingStyle.Sine)local rim=window._rim if rim and window.RimEnabled
then local base=window._rimThickness or rim.Thickness window._rimThickness=base
Tween.Play(rim,{Thickness=base+1.3},0.18,Enum.EasingStyle.Quad)task.delay(0.18,
function()Tween.Play(rim,{Thickness=base},0.5,Enum.EasingStyle.Sine)end)end end
function Motion.Cascade(window)local page=window.CurrentPage if not(page and
page.Frame)or Tween.Speed<=0 then return end page.Frame.Position=UDim2.
fromOffset(0,12)Tween.Play(page.Frame,{Position=UDim2.fromOffset(0,0)},0.65,Enum
.EasingStyle.Quint)for i,section in page.Sections or{}do local stroke=section.
Stroke if stroke then stroke.Transparency=1 task.delay(0.04*i,function()Tween.
Play(stroke,{Transparency=0},0.45)end)end end end local function pieces(window)
local holder=window.Holder return holder:FindFirstChild('Border'),holder:
FindFirstChild('Rim')end local function cleanup(window)local holder,canvas=
window.Holder,window.Canvas for _,name in{'ProximityMotionMask'}do local m=
canvas:FindFirstChild(name)if m then m:Destroy()end local pm=window.Plate:
FindFirstChild(name)if pm then pm:Destroy()end end local fx=holder:
FindFirstChild('ProximityMotionFx')if fx then fx:Destroy()end if window._ghosts
then for _,g in window._ghosts do g.Frame:Destroy()end window._ghosts=nil end
local border,rimFrame=pieces(window)for _,f in{canvas,window.Plate,border,
rimFrame}do if f then f.Rotation=0 end end canvas.GroupColor3=WHITE end function
Motion.Play(window,style,opening,rest,info,done)info=info or{}local holder,
canvas,plate=window.Holder,window.Canvas,window.Plate local def=S[style]window.
_motionToken=(window._motionToken or 0)+1 local token=window._motionToken local
glass=window.GlassTransparency or 0 local scale=window:GetScale()local target=
opening and 1 or 0 local function finalOpen()cleanup(window)holder.Position=rest
window._uiScale.Scale=scale canvas.GroupTransparency=glass plate.
BackgroundTransparency=glass window._borderStroke.Transparency=0 window._rim.
Transparency=window.RimEnabled and 0 or 1 setShadow(window,1)end if not def or
Tween.Speed<=0 then window._motion=nil if opening then finalOpen()else cleanup(
window)end if done then done()end return end local parent=holder.Parent local
area=parent and parent.AbsoluteSize or Vector2.new(1920,1080)local restPx=
Vector2.new(rest.X.Scale*area.X+rest.X.Offset,rest.Y.Scale*area.Y+rest.Y.Offset)
local ctx={Size=holder.AbsoluteSize.Magnitude>0 and(Vector2.new(holder.Size.X.
Offset,holder.Size.Y.Offset)*scale)or Vector2.new(700,480),Dir=restPx.X<area.X/2
and-1 or 1,From=info.From and(info.From-restPx)or nil}local state=window._motion
if not state or state.Style~=style then state={P=opening and 0 or 1,V=0,Style=
style}if window._motion and window._motion.Style~=style then state.P=window.
_motion.P cleanup(window)end end window._motion=state local spring=opening and
def.Open or def.Close local omega=spring[1]*math.pi*2 local zeta=spring[2]local
border,rimFrame=pieces(window)local masked=def.Masked local mask,plateMask local
history={}if opening and def.Ripple and state.P<0.3 then ripple(window,info.From
or restPx,340,info.From~=nil)end if opening and state.P<0.2 then task.delay(
masked and 0.25 or 0.08,function()if window._motionToken==token then Motion.
Cascade(window)end end)end local function apply(p)local c={Offset=Vector2.zero,
Scale=1,Rotation=0,Alpha=1,Exposure=1}def.Map(c,p,ctx)local alpha=clamp01(c.
Alpha)local frameA=clamp01(c.Frame or alpha)holder.Position=rest+UDim2.
fromOffset(c.Offset.X,c.Offset.Y)window._uiScale.Scale=scale*math.max(c.Scale,
0.01)for _,f in{canvas,plate,border,rimFrame}do if f then f.Rotation=c.Rotation
end end canvas.GroupTransparency=glass+(1-glass)*(1-alpha)local e=0.42+0.58*
clamp01(c.Exposure)canvas.GroupColor3=Color3.new(e,e,e)window._borderStroke.
Transparency=1-frameA window._rim.Transparency=window.RimEnabled and(1-frameA)or
1 if c.Mask then if not mask then mask=canvas:FindFirstChild(
'ProximityMotionMask')or Util.New('UIGradient',{Name='ProximityMotionMask',
Parent=canvas})plateMask=plate:FindFirstChild('ProximityMotionMask')if not
plateMask and not plate:FindFirstChildOfClass('UIGradient')then plateMask=Util.
New('UIGradient',{Name='ProximityMotionMask',Parent=plate})end end mask.Rotation
,mask.Transparency=c.Mask.Rotation,c.Mask.Seq if plateMask then plateMask.
Rotation,plateMask.Transparency=c.Mask.Rotation,c.Mask.Seq plate.
BackgroundTransparency=glass+(1-glass)*(1-alpha)else plate.
BackgroundTransparency=1-frameA*(1-glass)end else plate.BackgroundTransparency=
glass+(1-glass)*(1-alpha)end local tilt=1-clamp01(math.abs(c.Rotation)/2.5)
setShadow(window,(c.ShadowK or(c.Mask and frameA or alpha))*tilt)if c.Fx then
local fx=fxLayer(window)fx.Shape.Rotation=c.Fx.Rotation fx.Shape.Transparency=c.
Fx.Seq fx.GroupTransparency=1-clamp01(c.Fx.Alpha)else local fx=holder:
FindFirstChild('ProximityMotionFx')if fx and not fx:GetAttribute('Shine')then fx
.GroupTransparency=1 end end if def.Trail then table.insert(history,1,c.Offset)
if#history>16 then table.remove(history)end if not window._ghosts then window.
_ghosts={}for i=1,3 do local g=Util.New('Frame',{Name='ProximityMotionGhost',
AnchorPoint=holder.AnchorPoint,Size=holder.Size,BackgroundColor3=canvas.
BackgroundColor3,BackgroundTransparency=1,ZIndex=0,Parent=holder.Parent})Util.
Corner(10,g)local st=Util.Stroke(g,WHITE,1,1)local gs=Util.New('UIScale',{Parent
=g})window._ghosts[i]={Frame=g,Stroke=st,Scale=gs,Lag=i*4}end end for i,g in
window._ghosts do local lagged=history[math.min(g.Lag,#history)]or c.Offset
local gap=(lagged-c.Offset).Magnitude local a=clamp01(gap/90)*(0.16-i*0.04)*
alpha g.Frame.Position=rest+UDim2.fromOffset(lagged.X,lagged.Y)g.Frame.Rotation=
c.Rotation g.Scale.Scale=scale*c.Scale g.Frame.BackgroundTransparency=1-a g.
Stroke.Transparency=1-a*1.6 end end end local finished=false local conn conn=
RunService.RenderStepped:Connect(function(dt)if window._motionToken~=token or
not holder.Parent then conn:Disconnect()return end dt=math.min(dt,5E-2)/math.
max(Tween.Speed,0.05)local steps=math.max(1,math.ceil(dt/(4.166666666666667E-3))
)local h=dt/steps for _=1,steps do local a=-omega*omega*(state.P-target)-2*zeta*
omega*state.V state.V+=a*h state.P+=state.V*h end if not opening then state.P=
math.max(state.P,-2E-2)end if math.abs(state.P-target)<0.0015 and math.abs(state
.V)<0.02 then state.P,state.V=target,0 finished=true end apply(state.P)if
finished then conn:Disconnect()window._motion=nil if opening then finalOpen()
flourish(window)else cleanup(window)if def.Ripple and info.From then ripple(
window,info.From,120,true)end end if done then done()end end end)end function
Motion.Stop(window)window._motionToken=(window._motionToken or 0)+1 window.
_motion=nil cleanup(window)end return Motion end function
__DARKLUA_BUNDLE_MODULES.x()local v=__DARKLUA_BUNDLE_MODULES.cache.x if not v
then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.x=v end return v.c end end
do local function __modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Tween=
__DARKLUA_BUNDLE_MODULES.d()local Env=__DARKLUA_BUNDLE_MODULES.e()local Theme=
__DARKLUA_BUNDLE_MODULES.g()local Locale=__DARKLUA_BUNDLE_MODULES.j()local
Shared=__DARKLUA_BUNDLE_MODULES.k()local RunService=Env.Service('RunService')
local UserInputService=Env.Service('UserInputService')local Loader={}Loader.
__index=Loader local PHONE=UserInputService.TouchEnabled and not
UserInputService.KeyboardEnabled local SPHERE,RING=PHONE and 560 or 900,PHONE
and 380 or 600 local TILES=PHONE and 330 or 520 local RADIUS=92 local RING_IN,
RING_OUT=1.28,1.96 local STAGE=420 local FOV=30 local DIST=(STAGE/2)/(RADIUS*
math.tan(math.rad(FOV/2)))local TILT_Z,TILT_X=math.rad(17),math.rad(15)local
FRAME=CFrame.Angles(0,0,TILT_Z)*CFrame.Angles(TILT_X,0,0)local LIGHT=Vector3.
new(0.72,0.55,0.42).Unit local SPIN=0.3 local BUILD_AT,BUILD_FOR=1.45,1.9 local
TAU=math.pi*2 local SHADES={}for i=0,11 do local v=i/11 SHADES[i]=Color3.new(v,v
,v)end local WHITE=Color3.new(1,1,1)local function rotY(v,a)local c,s=math.cos(a
),math.sin(a)return Vector3.new(v.X*c+v.Z*s,v.Y,-v.X*s+v.Z*c)end local function 
rotX(v,a)local c,s=math.cos(a),math.sin(a)return Vector3.new(v.X,v.Y*c-v.Z*s,v.Y
*s+v.Z*c)end local function rotZ(v,a)local c,s=math.cos(a),math.sin(a)return
Vector3.new(v.X*c-v.Y*s,v.X*s+v.Y*c,v.Z)end local function toView(v,spin)return
rotZ(rotX(rotY(v,spin),TILT_X),TILT_Z)end local function toObject(v,spin)return
rotY(rotX(rotZ(v,-TILT_Z),-TILT_X),-spin)end local function smooth(x)x=math.
clamp(x,0,1)return x*x*(3-2*x)end local function thrSphere(o)return math.clamp(
0.5+0.24*math.sin(3.7*o.X+1.3+2*o.Y)+0.2*math.sin(3.1*o.Y+2.1)*math.cos(2.9*o.Z-
0.6)+0.14*math.sin(5.3*o.Z+1.7*o.X+0.4),0.02,0.98)end local function thrRing(
theta,r)return math.clamp(0.08+0.8*(theta%TAU)/TAU+0.12*(r-RING_IN)/0.6,0,1)end
local function coverAt(x,y,spin,b)local z=math.sqrt(math.max(0,1-x*x-y*y))local
o=toObject(Vector3.new(x,y,z),spin)return math.clamp((b-thrSphere(o))/0.05,0,1)
end local function part(props)local p=Instance.new('Part')p.Anchored=true p.
CanCollide=false p.CastShadow=false p.TopSurface=Enum.SurfaceType.Smooth p.
BottomSurface=Enum.SurfaceType.Smooth p.Material=Enum.Material.SmoothPlastic for
k,v in props do p[k]=v end return p end local STORMS={}do local rng=Random.new(
11)for _=1,6 do table.insert(STORMS,{Vector3.new(rng:NextNumber(-1,1),rng:
NextNumber(-0.6,0.6),rng:NextNumber(-1,1)).Unit,rng:NextNumber(0.14,0.3)})end
end local function surfaceColor(o)local turb=math.sin(3.1*o.X+1.7*o.Z)*0.5+math.
sin(4.3*o.Z-2.1*o.Y)*0.3+math.sin(5.7*o.X+3.3*o.Y)*0.2 local bands=0.5+0.5*math.
sin(o.Y*15+turb*3)local storm=0 for _,st in STORMS do local d=(o-st[1]).
Magnitude storm=math.max(storm,math.exp(-(d/st[2])^2))end local v=10+bands*14*(
0.7+0.3*turb)+storm*34 return Color3.fromRGB(v,v,v+3)end local function 
buildModel(viewport)local rng=Random.new(7)local camera=Instance.new('Camera')
camera.FieldOfView=FOV camera.CFrame=CFrame.new(0,0,DIST)camera.Parent=viewport
viewport.CurrentCamera=camera local model=Instance.new('Model')model.Name=
'Planet'local body=part({Name='Body',Shape=Enum.PartType.Ball,Size=Vector3.one*
1.985,Color=Color3.fromRGB(9,9,11),Transparency=1})body.Parent=model model.
PrimaryPart=body local patches={}for _=1,40 do local dir=Vector3.new(rng:
NextNumber(-1,1),rng:NextNumber(-1,1),rng:NextNumber(-1,1))if dir.Magnitude>0.05
then dir=dir.Unit local sz=rng:NextNumber(0.12,0.34)local shade=rng:NextNumber()
<0.5 and rng:NextInteger(6,8)or rng:NextInteger(14,19)local patch=part({Shape=
Enum.PartType.Cylinder,Size=Vector3.new(0.01,sz,sz),Color=Color3.fromRGB(shade,
shade,shade+2),Transparency=1})patch.CFrame=CFrame.lookAt(dir*0.99,dir*2)*CFrame
.Angles(0,math.rad(90),0)patch.Parent=model table.insert(patches,patch)end end
local belts={{-0.78,0.05,8},{-0.6,0.09,17},{-0.42,0.05,11},{-0.27,0.11,21},{-0.1
,0.06,13},{0.06,0.13,23},{0.24,0.05,10},{0.38,0.09,19},{0.55,0.06,12},{0.7,0.08,
16},{0.84,0.04,9}}for _,belt in belts do local h,thick,shade=belt[1],belt[2],
belt[3]local d=2*math.sqrt(1-h*h)*1.004 local ring=part({Shape=Enum.PartType.
Cylinder,Size=Vector3.new(thick,d,d),Color=Color3.fromRGB(shade,shade,shade+2),
Transparency=1})ring.CFrame=CFrame.new(0,h,0)*CFrame.Angles(0,0,math.rad(90))
ring.Parent=model table.insert(patches,ring)end local tiles={}local golden=math.
pi*(3-math.sqrt(5))local size=0.235*math.sqrt(520/TILES)for i=0,TILES-1 do local
y=1-(i/(TILES-1))*2 local r=math.sqrt(1-y*y)local th=golden*i local dir=Vector3.
new(math.cos(th)*r,y,math.sin(th)*r)local color=surfaceColor(dir)local tile=
part({Shape=Enum.PartType.Cylinder,Size=Vector3.new(0.02,size,size),Color=color,
Transparency=1})tile.CFrame=CFrame.lookAt(dir*0.993,dir*2)*CFrame.Angles(0,math.
rad(90),0)tile.Parent=model table.insert(tiles,{Part=tile,Thr=thrSphere(dir),
Color=color,M=-1})end local segs={}local bands={{1.32,0.08,0.82},{1.45,0.1,0.45}
,{1.56,0.11,0.36},{1.66,0.08,0.42},{1.81,0.1,0.55},{1.92,0.05,0.7}}local count=
96 for _,band in bands do local r,width,base=band[1],band[2],band[3]local length
=(TAU*r)/count*1.005 for i=0,count-1 do local a=(i/count)*TAU local dust=0.5+
0.25*math.sin(a*3+r*4)+0.15*math.sin(a*7+r)+rng:NextNumber(-0.12,0.12)local seg=
part({Size=Vector3.new(width,0.004,length),Color=Color3.fromRGB(235,235,240),
Material=Enum.Material.Neon,Transparency=1})seg.CFrame=CFrame.new(math.cos(a)*r,
0,math.sin(a)*r)*CFrame.Angles(0,-a,0)seg.Parent=model table.insert(segs,{Part=
seg,Thr=thrRing(a,r),Base=math.clamp(base+0.18+(1-dust)*0.4,0.42,0.97),M=-1})end
end model.Parent=viewport return model,body,tiles,segs,patches end function
Loader.new(window,options)options=options or{}local self=setmetatable({},Loader)
self.Window=window self.Started=os.clock()self.Points={}self.Angle=0 self.
Display=0 self.Samples={}self.Solid=1 self.Build=0 local root=Util.New('Frame',{
Name='ProximityLoader',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex
=300,Parent=Shared.Gui.Root})self.Root=root local dim=Util.New('Frame',{
BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,Size=UDim2.
fromScale(1,1),ZIndex=300,Parent=root})Util.Gradient(dim,nil,NumberSequence.new(
{NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(0.5,0),
NumberSequenceKeypoint.new(1,0.2)}),90)Tween.Play(dim,{BackgroundTransparency=
options.Dim or 0.22},0.7,Enum.EasingStyle.Sine)self.Dim=dim local stage=Util.
New('Frame',{BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=
UDim2.fromScale(0.5,0.46),Size=UDim2.fromOffset(STAGE,STAGE),ZIndex=301,Parent=
root})local view=workspace.CurrentCamera.ViewportSize local scale=Util.New(
'UIScale',{Scale=math.clamp(math.min(view.X,view.Y)/820,0.55,1.2),Parent=stage})
self.Stage,self.Scale=stage,scale self.Center=Vector2.new(STAGE/2,STAGE/2)local
c=self.Center local halo=Util.New('Frame',{AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.fromOffset(c.X,c.Y),Size=UDim2.fromOffset(RADIUS*3.6,RADIUS*3.6),
BackgroundColor3=WHITE,BackgroundTransparency=1,ZIndex=301,Parent=stage})Util.
Round(halo)Util.Gradient(halo,nil,NumberSequence.new({NumberSequenceKeypoint.
new(0,1),NumberSequenceKeypoint.new(0.6,0.995),NumberSequenceKeypoint.new(0.85,
0.975),NumberSequenceKeypoint.new(1,0.96)}),-45)self.Halo=halo local crescent=
Util.New('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(c.X
+1.6,c.Y-1.4),Size=UDim2.fromOffset(RADIUS*2+3,RADIUS*2+3),BackgroundColor3=
WHITE,BackgroundTransparency=1,ZIndex=302,Parent=stage})Util.Round(crescent)Util
.Gradient(crescent,nil,NumberSequence.new({NumberSequenceKeypoint.new(0,1),
NumberSequenceKeypoint.new(0.6,1),NumberSequenceKeypoint.new(0.85,0.3),
NumberSequenceKeypoint.new(1,0)}),-40)self.Crescent=crescent local viewport=Util
.New('ViewportFrame',{Name='Model',BackgroundTransparency=1,ImageTransparency=0,
Size=UDim2.fromOffset(STAGE,STAGE),Ambient=Color3.fromRGB(14,14,18),LightColor=
Color3.fromRGB(130,130,138),LightDirection=-LIGHT,ZIndex=303,Parent=stage})self.
Viewport=viewport Util.New('UIGradient',{Rotation=-28,Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Color3.fromRGB(208,208,214)),ColorSequenceKeypoint.
new(0.5,Color3.fromRGB(232,232,236)),ColorSequenceKeypoint.new(1,Color3.new(1,1,
1))}),Parent=viewport})local ok,planet,body,tiles,segs,patches=pcall(buildModel,
viewport)if ok then self.Planet,self.Body,self.Tiles,self.Segs,self.Patches=
planet,body,tiles,segs,patches end local rim=Util.New('Frame',{
BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.
fromOffset(c.X,c.Y),Size=UDim2.fromOffset(RADIUS*2+2,RADIUS*2+2),ZIndex=304,
Parent=stage})Util.Round(rim)local rimStroke=Util.Stroke(rim,WHITE,1.6,1)Util.
Gradient(rimStroke,nil,NumberSequence.new({NumberSequenceKeypoint.new(0,1),
NumberSequenceKeypoint.new(0.6,1),NumberSequenceKeypoint.new(0.82,0.35),
NumberSequenceKeypoint.new(0.93,0),NumberSequenceKeypoint.new(1,0.3)}),-40)self.
RimStroke=rimStroke local rng=Random.new(42)local golden=math.pi*(3-math.sqrt(5)
)for i=0,SPHERE-1 do local y=1-(i/(SPHERE-1))*2 local r=math.sqrt(1-y*y)local
theta=golden*i local base=Vector3.new(math.cos(theta)*r,y,math.sin(theta)*r)
table.insert(self.Points,{Base=base,Kind='Sphere',Thr=thrSphere(base)})end for _
=1,RING do local t=rng:NextNumber()*TAU local rr=RING_IN+(RING_OUT-RING_IN)*(rng
:NextNumber()^1.4)table.insert(self.Points,{Base=Vector3.new(math.cos(t)*rr,0,
math.sin(t)*rr),Kind='Ring',Thr=thrRing(t,rr),Glint=rng:NextNumber()<0.06})end
for _,p in self.Points do local size=(p.Kind=='Ring'and p.Glint)and 3 or 2 p.
Frame=Util.New('Frame',{BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),Size=
UDim2.fromOffset(size,size),BackgroundColor3=WHITE,BackgroundTransparency=1,
ZIndex=305,Parent=stage})p.Curl=(rng:NextNumber()<0.5 and-1 or 1)*(2.2+rng:
NextNumber()*1.6)p.Grow=1.6+rng:NextNumber()*2.2 p.Lift=(rng:NextNumber()-0.5)*
1.8 local tone=rng:NextNumber()p.Tone=tone<0.45 and 1 or tone<0.75 and 0.62 or
0.36 p.Delay=p.Thr*0.6+rng:NextNumber()*0.3 p.Seed=rng:NextNumber()*10 end local
flare=Util.New('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(
10,10),BackgroundColor3=WHITE,BackgroundTransparency=1,ZIndex=307,Parent=stage})
Util.Round(flare)local flareGlow=Util.New('Frame',{AnchorPoint=Vector2.new(0.5,
0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(24,24),
BackgroundColor3=WHITE,BackgroundTransparency=1,ZIndex=306,Parent=flare})Util.
Round(flareGlow)local streak=Util.New('Frame',{AnchorPoint=Vector2.new(0,0.5),
Size=UDim2.fromOffset(190,1),BorderSizePixel=0,BackgroundColor3=WHITE,
BackgroundTransparency=1,ZIndex=307,Parent=stage})Util.Gradient(streak,nil,
NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1
,1)}))local streak2=streak:Clone()streak2.AnchorPoint=Vector2.new(1,0.5)streak2.
Size=UDim2.fromOffset(70,1)streak2.Parent=stage streak2:FindFirstChildOfClass(
'UIGradient').Rotation=180 self.Flare,self.FlareGlow,self.Streak,self.Streak2=
flare,flareGlow,streak,streak2 self:_buildProgress(root,scale.Scale)self.Conn=
RunService.RenderStepped:Connect(function(dt)self:_step(dt)end)return self end
function Loader:_buildProgress(root,s)local info=Util.New('Frame',{
BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0
,0.46,(STAGE/2)*s*0.88),Size=UDim2.fromOffset(300,64),ZIndex=301,Parent=root})
local function label(props)local l=Util.Label(props)l.TextTransparency=1 l.
ZIndex=301 l.Parent=info return l end local title=label({Text=self.Window.Title,
FontFace=Theme.Fonts.SemiBold,TextSize=14,Size=UDim2.new(1,-60,0,18)})title.
TextColor3=WHITE local pct=label({Text='0%',FontFace=Theme.Fonts.MonoBold,
TextSize=13,TextXAlignment=Enum.TextXAlignment.Right,Size=UDim2.new(1,0,0,18)})
pct.TextColor3=WHITE local track=Util.New('Frame',{Size=UDim2.new(1,0,0,3),
Position=UDim2.fromOffset(0,25),BackgroundColor3=WHITE,BackgroundTransparency=1,
BorderSizePixel=0,ZIndex=301,Parent=info})Util.Round(track)local fill=Util.New(
'Frame',{Size=UDim2.fromScale(0,1),BackgroundColor3=WHITE,BorderSizePixel=0,
ZIndex=302,Parent=track})Util.Round(fill)local glow=Util.New('Frame',{
AnchorPoint=Vector2.new(1,0.5),Position=UDim2.fromScale(1,0.5),Size=UDim2.
fromOffset(18,8),BackgroundColor3=WHITE,BackgroundTransparency=0.55,
BorderSizePixel=0,ZIndex=302,Parent=fill})Util.Round(glow)local status=label({
Text=Locale.T('Preparing'),FontFace=Theme.Fonts.Regular,TextSize=12,TextTruncate
=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,-70,0,16),Position=UDim2.fromOffset(0,
36)})status.TextColor3=Color3.fromRGB(170,170,178)local eta=label({Text='',
FontFace=Theme.Fonts.Mono,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,
Size=UDim2.new(1,0,0,16),Position=UDim2.fromOffset(0,36)})eta.TextColor3=Color3.
fromRGB(120,120,128)self.Info,self.Pct,self.Fill,self.Track,self.Status,self.Eta
,self.TitleLabel=info,pct,fill,track,status,eta,title task.delay(0.5,function()
if self.Root then for _,l in{title,pct,status,eta}do Tween.Play(l,{
TextTransparency=0},0.6)end Tween.Play(track,{BackgroundTransparency=0.86},0.6)
end end)end function Loader:_step(dt)self.T=(self.T or 0)+math.min(dt,
3.333333333333333E-2)local t=self.T if t>BUILD_AT then self.Build=math.min(1,
self.Build+dt/BUILD_FOR*(self.Hurry and 2.5 or 1))end local b=-8E-2+1.16*smooth(
self.Build)if self.Exploding then self.Solid=math.max(0,self.Solid-dt/0.12)end
self.Angle+=dt*(self.Exploding and 0.15 or SPIN)local spin=self.Angle local c=
self.Center local settle=self.Exploding and 0 or smooth((b-0.7)/0.35)if self.
Planet then self.Planet:PivotTo(FRAME*CFrame.Angles(0,spin,0))self.Viewport.
ImageTransparency=1-self.Solid if not self.Built then for _,tile in self.Tiles
do local m=math.floor(math.clamp((b-tile.Thr)/0.07,0,1)*10+0.5)/10 if m~=tile.M
then tile.M=m tile.Part.Transparency=1-m tile.Part.Color=WHITE:Lerp(tile.Color,
0.25+0.75*m)end end for _,seg in self.Segs do local m=math.floor(math.clamp((b-
seg.Thr)/0.05,0,1)*10+0.5)/10 if m~=seg.M then seg.M=m seg.Part.Transparency=1-(
1-seg.Base)*m end end local bodyA=smooth((b-0.75)/0.3)self.Body.Transparency=1-
bodyA for _,patch in self.Patches do patch.Transparency=1-bodyA*0.9 end if b>=
1.07 then self.Built=true self.MeltAt=os.clock()end end if self.MeltAt and not
self.Melted then local m=math.clamp((os.clock()-self.MeltAt)/0.7,0,1)for _,tile
in self.Tiles do tile.Part.Transparency=m end if m>=1 then self.Melted=true end
end if not self.Exploding then self.Crescent.BackgroundTransparency=1-settle*
0.95 self.RimStroke.Transparency=1-settle*0.9 self.Halo.BackgroundTransparency=1
-settle*(0.5+0.08*math.sin(t*1.3))end end if not self.PointsGone or self.
Exploding then local any=false local et=self.Exploding and(os.clock()-self.
ExplodeAt)or 0 for _,p in self.Points do local v=toView(p.Base,spin)local s=DIST
/(DIST-v.Z)local screen=c+Vector2.new(v.X,-v.Y)*RADIUS*s local op,shade if p.
Kind=='Sphere'then if v.Z>=-2E-2 then local diffuse=math.max(0,v:Dot(LIGHT))
local rim=(1-math.abs(v.Z))^2.2 local light=math.clamp(diffuse^1.2*0.4+rim*
diffuse*1.6,0,1)local e=(b-p.Thr)/0.035 local flash=math.exp(-e*e)shade=math.
floor(math.clamp(0.3+light*0.7+flash,0,1)*11)op=(0.4+light*0.5+flash*0.4)*(1-
math.clamp((b-p.Thr-0.02)/0.06,0,1))else shade=5 op=0.28*(1-coverAt(v.X,v.Y,spin
,b))end else local lit=math.clamp(0.35+(v.X/RING_OUT)*0.45+(v.Z/RING_OUT)*0.2,0,
1)local e=(b-p.Thr)/0.03 local flash=math.exp(-e*e)shade=math.floor(math.clamp(
0.35+lit*0.65+(p.Glint and 0.3 or 0)+flash,0,1)*11)op=(0.3+lit*0.5+(p.Glint and
0.2 or 0)+flash*0.3)*(1-math.clamp((b-p.Thr-0.02)/0.05,0,1))if v.Z<0 and(v.X*v.X
+v.Y*v.Y)<1 then op*=1-coverAt(v.X,v.Y,spin,b)end end local k=math.clamp((t-p.
Delay)/1.2,0,1)local e=1-(1-k)^4 local pos=screen if e<1 then local left=1-e
local fly=rotY(p.Base,p.Curl*left)*(1+left*left*p.Grow)+Vector3.new(0,p.Lift*
left,0)local fv=toView(fly,spin)local fs=math.clamp(DIST/math.max(DIST-fv.Z,0.5)
,0.5,2)pos=c+Vector2.new(fv.X,-fv.Y)*RADIUS*fs end op=math.min(op,1)*math.min(1,
k*3)if shade<11 or p.Tone<1 then shade=math.max(2,math.floor(shade*(shade>=10
and math.max(p.Tone,0.8)or p.Tone)+0.5))end if self.Exploding then if not p.Dir
then local away=screen-c p.Dir=(away.Magnitude>1 and away.Unit or Vector2.new(1,
0))*(190+p.Seed*75)+Vector2.new((p.Seed-5)*9,(p.Seed%3-1.5)*12)end pos=screen+p.
Dir*(1-(1-math.min(et/0.95,1))^3)*1.6 op=(v.Z>=-2E-2 or p.Kind=='Ring')and math.
clamp(0.75-et/0.9,0,1)or 0 shade=math.max(shade,7)end local f=p.Frame if op>0.01
then any=true f.Position=UDim2.fromOffset(pos.X,pos.Y)f.BackgroundTransparency=1
-op f.BackgroundColor3=SHADES[shade]p.Shown=true elseif p.Shown then p.Shown=
false f.BackgroundTransparency=1 end end if not any and self.Built and not self.
Exploding then self.PointsGone=true end end if not self.Exploding then local dir
=Vector2.new(LIGHT.X,-LIGHT.Y).Unit local fp=c+dir*RADIUS*0.99 self.Flare.
Position=UDim2.fromOffset(fp.X,fp.Y)self.Streak.Position=UDim2.fromOffset(fp.X,
fp.Y)self.Streak2.Position=UDim2.fromOffset(fp.X,fp.Y)local pulse=0.2+0.15*math.
sin(t*2.3)local hide=1-settle self.Flare.BackgroundTransparency=math.min(1,pulse
+hide)self.FlareGlow.BackgroundTransparency=math.min(1,0.8+pulse*0.3+hide)self.
Streak.BackgroundTransparency=math.min(1,0.15+pulse+hide)self.Streak2.
BackgroundTransparency=math.min(1,0.4+pulse+hide)end self:_progress(os.clock()-
self.Started)end function Loader:_progress(t)if self.Exploding then return end
local window=self.Window local actual=window:GetLoadProgress()if window.State~=
'Loading'then actual=math.max(actual,0.98)end self.Display=math.max(self.Display
,math.min(actual,0.99))local shown=self._shown or 0 shown+=(self.Display-shown)*
0.12 self._shown=shown self.Fill.Size=UDim2.fromScale(shown,1)self.Pct.Text=math
.floor(shown*100+0.5)..'%'table.insert(self.Samples,{t,self.Display})while#self.
Samples>2 and self.Samples[1][1]<t-1.5 do table.remove(self.Samples,1)end local
first=self.Samples[1]local rate=(self.Display-first[2])/math.max(t-first[1],0.05
)if rate>0.002 and self.Display<0.98 then local left=(1-self.Display)/rate self.
Eta.Text=left<1 and'<1 s'or('~'..math.ceil(left)..' s')else self.Eta.Text=string
.format('%.1f s',t)end end function Loader:SetStage(text)if self.Status and text
then self.Status.Text=text end end function Loader:Finish(onOpen)if self.
Exploding or self.Finishing then return end self.Finishing=true local function 
burst()if not self.Root then return end self.Exploding=true self.ExplodeAt=os.
clock()self.Fill.Size=UDim2.fromScale(1,1)self.Pct.Text='100%'self.Status.Text=
Locale.T('Ready')self.Eta.Text=''local stage=self.Stage local flash=Util.New(
'Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(self.Center.
X,self.Center.Y),Size=UDim2.fromOffset(RADIUS*2.2,RADIUS*2.2),BackgroundColor3=
WHITE,BackgroundTransparency=0.05,ZIndex=308,Parent=stage})Util.Round(flash)
Tween.Play(flash,{Size=UDim2.fromOffset(30,30),BackgroundTransparency=1},0.5)for
i,size in{1300,900}do local wave=Util.New('Frame',{AnchorPoint=Vector2.new(0.5,
0.5),Position=UDim2.fromOffset(self.Center.X,self.Center.Y),Size=UDim2.
fromOffset(RADIUS*2,RADIUS*2),BackgroundTransparency=1,ZIndex=308,Parent=stage})
Util.Round(wave)local ws=Util.Stroke(wave,WHITE,i==1 and 2 or 1,i==1 and 0 or
0.4)Tween.Play(wave,{Size=UDim2.fromOffset(size,size)},0.9+i*0.15,Enum.
EasingStyle.Quart)Tween.Play(ws,{Transparency=1,Thickness=0.5},0.9+i*0.15)end
for _,o in{self.Flare,self.FlareGlow,self.Streak,self.Streak2,self.Crescent}do
Tween.Play(o,{BackgroundTransparency=1},0.2)end Tween.Play(self.Halo,{
BackgroundTransparency=1},0.4)Tween.Play(self.RimStroke,{Transparency=1},0.15)
for _,l in{self.TitleLabel,self.Pct,self.Status,self.Eta}do Tween.Play(l,{
TextTransparency=1},0.35)end Tween.Play(self.Track,{BackgroundTransparency=1},
0.35)Tween.Play(self.Fill,{BackgroundTransparency=1},0.35)Tween.Play(self.Dim,{
BackgroundTransparency=1},0.95,Enum.EasingStyle.Sine)task.delay(0.24,function()
if onOpen then onOpen(stage.AbsolutePosition+stage.AbsoluteSize/2-Shared.Gui.
Root.AbsolutePosition)end end)task.delay(1.2,function()self:Destroy()end)end
task.spawn(function()local start=os.clock()self.Hurry=true while self.Root and((
self._shown or 0)<0.97 or self.Build<1)and os.clock()-start<2.5 do self.Display=
1 RunService.RenderStepped:Wait()end burst()end)end function Loader:Destroy()if
self.Conn then self.Conn:Disconnect()self.Conn=nil end if self.Root then self.
Root:Destroy()self.Root=nil end end return Loader end function
__DARKLUA_BUNDLE_MODULES.y()local v=__DARKLUA_BUNDLE_MODULES.cache.y if not v
then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.y=v end return v.c end end
do local function __modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Tween=
__DARKLUA_BUNDLE_MODULES.d()local Env=__DARKLUA_BUNDLE_MODULES.e()local Theme=
__DARKLUA_BUNDLE_MODULES.g()local Locale=__DARKLUA_BUNDLE_MODULES.j()local
Shared=__DARKLUA_BUNDLE_MODULES.k()local RunService=Env.Service('RunService')
local Intros={}Intros.__index=Intros Intros.Styles={'Orbit','Eclipse',
'Constellation','Terminal'}local STAGE=420 local WHITE=Color3.new(1,1,1)local
TAU=math.pi*2 local function escape(text)return(string.gsub(string.gsub(string.
gsub(text,'&','&amp;'),'<','&lt;'),'>','&gt;'))end local function smooth(x)x=
math.clamp(x,0,1)return x*x*(3-2*x)end local function frame(parent,props)props.
BorderSizePixel=0 props.Parent=parent if props.BackgroundTransparency==nil then
props.BackgroundTransparency=1 end return Util.New('Frame',props)end local 
function dot(parent,size,z)local d=frame(parent,{AnchorPoint=Vector2.new(0.5,0.5
),Size=UDim2.fromOffset(size,size),BackgroundColor3=WHITE,ZIndex=z or 303})Util.
Round(d)return d end local function ring(parent,diameter,z,thickness)local r=
frame(parent,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(STAGE/2
,STAGE/2),Size=UDim2.fromOffset(diameter,diameter),ZIndex=z or 302})Util.Round(r
)local stroke=Util.Stroke(r,WHITE,thickness or 1,1)return r,stroke end local 
function placeLine(line,a,b)local d=b-a line.Position=UDim2.fromOffset((a.X+b.X)
/2,(a.Y+b.Y)/2)line.Size=UDim2.fromOffset(math.max(d.Magnitude,0.01),line.Size.Y
.Offset)line.Rotation=math.deg(math.atan2(d.Y,d.X))end local Styles={}Styles.
Orbit={Build=function(self)local c=self.Center self.Rings,self.Moons={},{}for i,
spec in{{120,0.9,1.1},{196,-0.55,0.85},{272,0.32,0.7}}do local r,stroke=ring(
self.Stage,spec[1],302)r.Size=UDim2.fromOffset(0,0)table.insert(self.Rings,{
Frame=r,Stroke=stroke,D=spec[1],Speed=spec[2],Delay=(i-1)*0.12})local moon=dot(
self.Stage,i==1 and 7 or 5,304)moon.BackgroundTransparency=1 local trail={}for k
=1,6 do local t=dot(self.Stage,math.max(2,5-k*0.6),303)t.BackgroundTransparency=
1 trail[k]=t end table.insert(self.Moons,{Dot=moon,Trail=trail,R=spec[1]/2,Speed
=spec[2]*1.4,Phase=i*2.1})end self.Ticks={}local n,radius=96,168 for i=0,n-1 do
local a=i/n*TAU-math.pi/2 local tick=frame(self.Stage,{AnchorPoint=Vector2.new(
0.5,0.5),Size=UDim2.fromOffset(i%8==0 and 10 or 6,2),Position=UDim2.fromOffset(c
.X+math.cos(a)*radius,c.Y+math.sin(a)*radius),Rotation=math.deg(a),
BackgroundColor3=WHITE,BackgroundTransparency=1,ZIndex=303})self.Ticks[i+1]=tick
end local logo=self.Window:_drawLogo(self.Stage,30)logo.AnchorPoint=Vector2.new(
0.5,0.5)logo.Position=UDim2.fromOffset(c.X,c.Y-30)logo.ZIndex=305 logo.Visible=
false self.Logo=logo self.BigPct=Util.Label({Text='0',FontFace=Theme.Fonts.
MonoBold,TextSize=30,TextXAlignment=Enum.TextXAlignment.Center,AnchorPoint=
Vector2.new(0.5,0.5),Position=UDim2.fromOffset(c.X,c.Y+12),Size=UDim2.
fromOffset(120,34),ZIndex=305,Parent=self.Stage})self.BigPct.TextColor3=WHITE
self.BigPct.TextTransparency=1 self.HidePct=true end,Step=function(self,t,shown)
local c=self.Center for _,r in self.Rings do local k=smooth((t-0.15-r.Delay)/0.7
)r.Frame.Size=UDim2.fromOffset(r.D*(0.6+0.4*k),r.D*(0.6+0.4*k))r.Stroke.
Transparency=1-k*0.78 end local appear=smooth((t-0.5)/0.6)for _,m in self.Moons
do local a=m.Phase+t*m.Speed m.Dot.Position=UDim2.fromOffset(c.X+math.cos(a)*m.R
,c.Y+math.sin(a)*m.R)m.Dot.BackgroundTransparency=1-appear for k,tr in m.Trail
do local b=a-k*0.07*math.sign(m.Speed)tr.Position=UDim2.fromOffset(c.X+math.cos(
b)*m.R,c.Y+math.sin(b)*m.R)tr.BackgroundTransparency=1-appear*(0.55-k*0.08)end
end local lit=shown*#self.Ticks for i,tick in self.Ticks do local on=math.clamp(
lit-(i-1),0,1)local head=math.max(0,1-math.abs(lit-i)/3)tick.
BackgroundTransparency=1-appear*(0.12+on*0.75+head*0.13)tick.Size=UDim2.
fromOffset(((i-1)%8==0 and 10 or 6)+head*5,2)end self.BigPct.Text=tostring(math.
floor(shown*100+0.5))self.BigPct.TextTransparency=1-appear self.Logo.Visible=t>
0.35 end,Burst=function(self)self.Frozen=true for _,r in self.Rings do Tween.
Play(r.Frame,{Size=UDim2.fromOffset(0,0)},0.35,Enum.EasingStyle.Quint,Enum.
EasingDirection.In)Tween.Play(r.Stroke,{Transparency=1},0.35)end for _,tick in
self.Ticks do Tween.Play(tick,{BackgroundTransparency=1},0.3)end Tween.Play(self
.BigPct,{TextTransparency=1},0.2)self.Logo.Visible=false return 0.3 end}Styles.
Eclipse={Dim=0.12,Build=function(self)local c,R=self.Center,64 self.R=R self.
Corona={}for i=1,18 do local k=1.04+(i-1)^1.3*0.062 local g=frame(self.Stage,{
AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(c.X,c.Y),Size=UDim2.
fromOffset(R*2*k,R*2*k),BackgroundColor3=WHITE,BackgroundTransparency=1,ZIndex=
301})Util.Round(g)self.Corona[i]={Frame=g,K=k}end self.Rays={}for i=1,10 do
local a=i/10*TAU+(i%2)*0.17 local len=R*(1.6+(i%3)*0.55)local ray=frame(self.
Stage,{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(len,1),
BackgroundColor3=WHITE,BackgroundTransparency=1,ZIndex=301})Util.Gradient(ray,
nil,NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.
new(1,1)}))local mid=Vector2.new(math.cos(a),math.sin(a))*(R+len/2)ray.Position=
UDim2.fromOffset(c.X+mid.X,c.Y+mid.Y)ray.Rotation=math.deg(a)self.Rays[i]=ray
end local sun=frame(self.Stage,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.
fromOffset(c.X,c.Y),Size=UDim2.fromOffset(R*2,R*2),BackgroundColor3=WHITE,
BackgroundTransparency=1,ZIndex=302})Util.Round(sun)Util.Gradient(sun,
ColorSequence.new(Color3.fromRGB(255,255,255),Color3.fromRGB(205,205,212)),nil,-
45)self.Sun=sun local moon=frame(self.Stage,{AnchorPoint=Vector2.new(0.5,0.5),
Size=UDim2.fromOffset(R*2+2,R*2+2),BackgroundColor3=Color3.fromRGB(3,3,4),
BackgroundTransparency=1,ZIndex=303})Util.Round(moon)self.MoonStroke=Util.
Stroke(moon,Color3.fromRGB(40,40,46),1,1)self.Moon=moon local diamond=dot(self.
Stage,9,305)diamond.BackgroundTransparency=1 local streak=frame(self.Stage,{
AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(220,1),BackgroundColor3=
WHITE,BackgroundTransparency=1,ZIndex=305})Util.Gradient(streak,nil,
NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(
0.5,0),NumberSequenceKeypoint.new(1,1)}))local a=math.rad(-38)local p=c+Vector2.
new(math.cos(a),math.sin(a))*R diamond.Position=UDim2.fromOffset(p.X,p.Y)streak.
Position=UDim2.fromOffset(p.X,p.Y)self.Diamond,self.Streak=diamond,streak end,
Step=function(self,t,shown)local c,R=self.Center,self.R local appear=smooth((t-
0.1)/0.7)self.Sun.BackgroundTransparency=1-appear local cover=smooth(shown)local
off=(1-cover)*R*2.3 self.Moon.Position=UDim2.fromOffset(c.X-off,c.Y+off*0.35)
self.Moon.BackgroundTransparency=1-appear self.MoonStroke.Transparency=1-appear*
0.6 local total=smooth((cover-0.9)/0.1)local pulse=0.5+0.5*math.sin(t*2.2)for _,
g in self.Corona do local a=(0.006+total*0.024)*appear*(0.92+0.08*pulse)g.Frame.
BackgroundTransparency=1-a end for i,ray in self.Rays do ray.
BackgroundTransparency=1-(0.12+total*0.5)*appear*(0.6+0.4*math.sin(t*1.3+i))end
self.Diamond.BackgroundTransparency=1-total*(0.75+0.25*pulse)self.Streak.
BackgroundTransparency=1-total*0.8 end,Burst=function(self)self.Frozen=true
local flash=dot(self.Stage,12,306)flash.Position=self.Diamond.Position Tween.
Play(flash,{Size=UDim2.fromOffset(900,900),BackgroundTransparency=1},0.7,Enum.
EasingStyle.Quint)for _,o in{self.Sun,self.Moon,self.Diamond,self.Streak}do
Tween.Play(o,{BackgroundTransparency=1},0.35)end Tween.Play(self.MoonStroke,{
Transparency=1},0.3)for _,g in self.Corona do Tween.Play(g.Frame,{
BackgroundTransparency=1,Size=UDim2.fromOffset(g.Frame.Size.X.Offset*1.5,g.Frame
.Size.Y.Offset*1.5)},0.6)end for _,ray in self.Rays do Tween.Play(ray,{
BackgroundTransparency=1},0.3)end return 0.15 end}Styles.Constellation={Build=
function(self)local rng=Random.new(19)local c=self.Center self.Dust={}for i=1,60
do local d=dot(self.Stage,rng:NextNumber()<0.2 and 2 or 1,301)d.Position=UDim2.
fromOffset(rng:NextNumber(0,STAGE),rng:NextNumber(30,STAGE-60))d.
BackgroundTransparency=1 self.Dust[i]={Dot=d,A=0.55+rng:NextNumber()*0.35,Phase=
rng:NextNumber()*TAU}end local stars={}local tries=0 while#stars<22 and tries<
600 do tries+=1 local p=Vector2.new(c.X+rng:NextNumber(-170,170),c.Y-20+rng:
NextNumber(-115,115))local ok=true for _,s in stars do if(s.P-p).Magnitude<46
then ok=false break end end if ok then local big=rng:NextNumber()<0.25 local d=
dot(self.Stage,big and 6 or 4,304)d.Position=UDim2.fromOffset(p.X,p.Y)d.
BackgroundTransparency=1 local glow=dot(self.Stage,big and 16 or 10,303)glow.
Position=d.Position glow.BackgroundTransparency=1 table.insert(stars,{P=p,Dot=d,
Glow=glow,Big=big,Delay=rng:NextNumber()*0.7,Lit=0})end end local edges,used={},
{[1]=true}local current=1 for _=2,#stars do local best,bestD for j,s in stars do
if not used[j]then local d=(s.P-stars[current].P).Magnitude if not bestD or d<
bestD then best,bestD=j,d end end end used[best]=true table.insert(edges,{
current,best})current=best end for _=1,7 do local a=rng:NextInteger(1,#stars)
local best,bestD for j,s in stars do local d=(s.P-stars[a].P).Magnitude if j~=a
and d>1 and(not bestD or d<bestD)then local dup=false for _,e in edges do if(e[1
]==a and e[2]==j)or(e[1]==j and e[2]==a)then dup=true end end if not dup then
best,bestD=j,d end end end if best then table.insert(edges,{a,best})end end for
_,e in edges do e.Line=frame(self.Stage,{AnchorPoint=Vector2.new(0.5,0.5),Size=
UDim2.fromOffset(0,1),BackgroundColor3=WHITE,BackgroundTransparency=1,ZIndex=302
})e.Q=0 end self.Stars,self.Edges=stars,edges end,Step=function(self,t,shown,dt)
for _,d in self.Dust do d.Dot.BackgroundTransparency=1-smooth((t-0.1)/0.8)*(1-d.
A)*(0.7+0.3*math.sin(t*1.7+d.Phase))end for _,s in self.Stars do local k=smooth(
(t-0.2-s.Delay)/0.5)s.Dot.BackgroundTransparency=1-k*(0.55+s.Lit*0.45)s.Glow.
BackgroundTransparency=1-k*(0.05+s.Lit*0.12)*(0.8+0.2*math.sin(t*3+s.P.X))s.Lit=
math.max(0,s.Lit-dt*0.6)end local n=#self.Edges local want=shown*n local prev=1
for i,e in self.Edges do local target=math.clamp(want-(i-1),0,1)if t<0.9 or prev
<0.55 then target=math.min(target,e.Q)end prev=e.Q if e.Q<target then e.Q=math.
min(target,e.Q+dt*7)local a,b=self.Stars[e[1] ],self.Stars[e[2] ]placeLine(e.
Line,a.P,a.P:Lerp(b.P,smooth(e.Q)))e.Line.BackgroundTransparency=e.Q>0 and 0.55
or 1 if e.Q>=1 then a.Lit,b.Lit=1,1 end end end end,Burst=function(self)self.
Frozen=true local c=self.Center for _,e in self.Edges do e.Line.
BackgroundTransparency=0.1 Tween.Play(e.Line,{BackgroundTransparency=1},0.45)end
for _,s in self.Stars do Tween.Play(s.Dot,{Position=UDim2.fromOffset(c.X,c.Y),
BackgroundTransparency=1},0.45,Enum.EasingStyle.Quint,Enum.EasingDirection.In)
Tween.Play(s.Glow,{BackgroundTransparency=1},0.3)end for _,d in self.Dust do
Tween.Play(d.Dot,{BackgroundTransparency=1},0.3)end return 0.35 end}Styles.
Terminal={NoInfo=true,Dim=0.18,Build=function(self)local c=self.Center local
panel=frame(self.Stage,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.
fromOffset(c.X,c.Y),Size=UDim2.fromOffset(470,250),BackgroundColor3=Color3.
fromRGB(9,9,11),BackgroundTransparency=1,ZIndex=302})Util.Corner(10,panel)self.
PanelStroke=Util.Stroke(panel,Color3.fromRGB(46,46,52),1,1)local scale=Util.New(
'UIScale',{Scale=0.97,Parent=panel})self.Panel,self.PanelScale=panel,scale local 
function text(props)local l=Util.Label(props)l.Parent=panel l.ZIndex=303 l.
TextTransparency=1 l.RichText=true return l end self.Head=text({Text=escape(
string.lower(self.Window.Title))..'  \u{b7}  boot',FontFace=Theme.Fonts.Mono,
TextSize=12,Position=UDim2.fromOffset(16,10),Size=UDim2.new(1,-120,0,16)})self.
Head.TextColor3=Color3.fromRGB(150,150,158)self.Ver=text({Text='v'..tostring(
self.Window.Library.Version),FontFace=Theme.Fonts.Mono,TextSize=12,
TextXAlignment=Enum.TextXAlignment.Right,Position=UDim2.new(1,-116,0,10),Size=
UDim2.fromOffset(100,16)})self.Ver.TextColor3=Color3.fromRGB(90,90,98)self.Rule=
frame(panel,{Position=UDim2.fromOffset(0,34),Size=UDim2.new(1,0,0,1),
BackgroundColor3=Color3.fromRGB(32,32,38),BackgroundTransparency=1,ZIndex=303})
self.Body=text({Text='',FontFace=Theme.Fonts.Mono,TextSize=13,TextYAlignment=
Enum.TextYAlignment.Top,TextWrapped=false,Position=UDim2.fromOffset(16,46),Size=
UDim2.new(1,-32,1,-58),LineHeight=1.25})self.Body.TextColor3=Color3.fromRGB(215,
215,222)self.Lines={}self.Typed=0 self:_term(
'<font color="#7a7a84">$</font> proximity load')self:_term(
[[<font color="#7a7a84">resolving theme, fonts, configs</font>]])end,Step=
function(self,t,shown,dt)local appear=smooth(t/0.4)self.Panel.
BackgroundTransparency=1-appear*0.94 self.PanelStroke.Transparency=1-appear self
.PanelScale.Scale=0.97+0.03*appear for _,l in{self.Head,self.Ver,self.Body}do l.
TextTransparency=1-appear end self.Rule.BackgroundTransparency=1-appear self.
Typed+=dt*120 local width=26 local filled=math.floor(shown*width+0.5)local bar=
'['..string.rep('#',filled)..string.rep('.',width-filled)..']'local pct=string.
format('%3d%%',math.floor(shown*100+0.5))local eta=escape(self.EtaText or'')
local caret=(math.floor(t*2.2)%2==0)and'_'or' 'local budget=math.floor(self.
Typed)local out={}for _,line in self.Lines do local plain=line.Plain if budget<=
0 then break end if budget>=#plain then table.insert(out,line.Rich)budget-=#
plain else table.insert(out,escape(string.sub(plain,1,budget)))budget=0 end end
local done=budget>0 while#out>7 do table.remove(out,1)end if done then table.
insert(out,bar..'  '..pct..'  <font color="#7a7a84">'..eta..'</font>')table.
insert(out,'<font color="#7a7a84">'..caret..'</font>')end self.Body.Text=table.
concat(out,'\n')end,Stage=function(self,text)local base=string.match(text,
'^(.-)%s*\u{b7}')or text local rich='<font color="#7a7a84">&gt;</font> '..
escape(text)local last for _,line in self.Lines do if line.Base==base then last=
line end end if last then local plain=string.gsub(rich,'<[^>]+>','')plain=string
.gsub(string.gsub(string.gsub(plain,'&lt;','<'),'&gt;','>'),'&amp;','&')last.
Rich,last.Plain=rich,plain else self:_term(rich)self.Lines[#self.Lines].Base=
base end end,Burst=function(self)self:_term(
'<font color="#ffffff">ready.</font>')self.Typed+=999 task.wait(0.3)self.Frozen=
true Tween.Play(self.PanelScale,{Scale=1.03},0.35,Enum.EasingStyle.Quint)Tween.
Play(self.Panel,{BackgroundTransparency=1},0.3)Tween.Play(self.PanelStroke,{
Transparency=1},0.3)for _,l in{self.Head,self.Ver,self.Body}do Tween.Play(l,{
TextTransparency=1},0.25)end Tween.Play(self.Rule,{BackgroundTransparency=1},
0.25)return 0.1,true end}function Intros.Has(style)return Styles[style]~=nil end
function Intros.new(window,options,style)options=options or{}local def=Styles[
style]local self=setmetatable({},Intros)self.Window=window self.Def=def self.
Started=os.clock()self.T=0 self.Display=0 self.Samples={}local root=frame(Shared
.Gui.Root,{Name='ProximityIntro',Size=UDim2.fromScale(1,1),ZIndex=300})self.Root
=root local dim=frame(root,{BackgroundColor3=Color3.new(0,0,0),Size=UDim2.
fromScale(1,1),ZIndex=300})Util.Gradient(dim,nil,NumberSequence.new({
NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(0.5,0),
NumberSequenceKeypoint.new(1,0.2)}),90)Tween.Play(dim,{BackgroundTransparency=
options.Dim or def.Dim or 0.22},0.6,Enum.EasingStyle.Sine)self.Dim=dim self.
Stars={}local srng=Random.new(5)for i=1,46 do local star=frame(root,{AnchorPoint
=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(srng:NextNumber()<0.2 and 2 or 1,
srng:NextNumber()<0.2 and 2 or 1),BackgroundColor3=WHITE,BackgroundTransparency=
1,ZIndex=300})self.Stars[i]={Frame=star,X=srng:NextNumber(),Y=srng:NextNumber(),
Speed=srng:NextNumber(0.004,0.014),A=srng:NextNumber(0.35,0.8),Phase=srng:
NextNumber()*TAU}end local stage=frame(root,{AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.fromScale(0.5,0.46),Size=UDim2.fromOffset(STAGE,STAGE),ZIndex=301
})local view=workspace.CurrentCamera.ViewportSize local scale=Util.New('UIScale'
,{Scale=math.clamp(math.min(view.X,view.Y)/820,0.55,1.2),Parent=stage})self.
Stage=stage self.Center=Vector2.new(STAGE/2,STAGE/2)def.Build(self)if not def.
NoInfo then self:_buildInfo(root,scale.Scale)end self.Conn=RunService.
RenderStepped:Connect(function(dt)self.T+=math.min(dt,3.333333333333333E-2)local
shown=self:_progress(os.clock()-self.Started)if not self.Frozen then def.Step(
self,self.T,shown,math.min(dt,3.333333333333333E-2))end local fadeIn=smooth(self
.T/1.2)*(self.Exploding and math.max(0,1-(os.clock()-(self.ExplodeAt or os.
clock()))/0.5)or 1)for _,st in self.Stars do st.X=(st.X+st.Speed*math.min(dt,
3.333333333333333E-2))%1 st.Frame.Position=UDim2.fromScale(st.X,st.Y)st.Frame.
BackgroundTransparency=1-fadeIn*st.A*(0.55+0.45*math.sin(self.T*1.6+st.Phase))
end end)return self end function Intros:_term(rich)local plain=string.gsub(rich,
'<[^>]+>','')plain=string.gsub(string.gsub(string.gsub(plain,'&lt;','<'),'&gt;',
'>'),'&amp;','&')table.insert(self.Lines,{Rich=rich,Plain=plain})while#self.
Lines>12 do local first=table.remove(self.Lines,1)self.Typed=math.max(0,self.
Typed-#first.Plain)end end function Intros:_buildInfo(root,s)local info=frame(
root,{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0.46,(STAGE/2)*s*
0.9),Size=UDim2.fromOffset(300,60),ZIndex=301})local function label(props)local
l=Util.Label(props)l.TextTransparency=1 l.ZIndex=301 l.Parent=info return l end
local title=label({Text=self.Window.Title,FontFace=Theme.Fonts.SemiBold,TextSize
=14,Size=UDim2.new(1,-60,0,18)})title.TextColor3=WHITE local pct=label({Text=
'0%',FontFace=Theme.Fonts.MonoBold,TextSize=13,TextXAlignment=Enum.
TextXAlignment.Right,Size=UDim2.new(1,0,0,18)})pct.TextColor3=WHITE local track=
frame(info,{Size=UDim2.new(1,0,0,2),Position=UDim2.fromOffset(0,25),
BackgroundColor3=WHITE,ZIndex=301})local fill=frame(track,{Size=UDim2.fromScale(
0,1),BackgroundColor3=WHITE,BackgroundTransparency=0,ZIndex=302})fill.Visible=
false local head=frame(fill,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.
fromScale(1,0.5),Size=UDim2.fromOffset(16,7),BackgroundColor3=WHITE,
BackgroundTransparency=0.55,ZIndex=302})Util.Round(head)local status=label({Text
=Locale.T('Preparing'),FontFace=Theme.Fonts.Regular,TextSize=12,TextTruncate=
Enum.TextTruncate.AtEnd,Size=UDim2.new(1,-70,0,16),Position=UDim2.fromOffset(0,
34)})status.TextColor3=Color3.fromRGB(170,170,178)local eta=label({Text='',
FontFace=Theme.Fonts.Mono,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,
Size=UDim2.new(1,0,0,16),Position=UDim2.fromOffset(0,34)})eta.TextColor3=Color3.
fromRGB(120,120,128)if self.HidePct then pct.Visible=false end self.Info,self.
Pct,self.Fill,self.Track,self.Status,self.Eta,self.TitleLabel=info,pct,fill,
track,status,eta,title task.delay(0.5,function()if self.Root then for _,l in{
title,pct,status,eta}do Tween.Play(l,{TextTransparency=0},0.6)end Tween.Play(
track,{BackgroundTransparency=0.86},0.6)fill.Visible=true end end)end function
Intros:_progress(t)if self.Exploding then return 1 end local window=self.Window
local actual=window:GetLoadProgress()if window.State~='Loading'then actual=math.
max(actual,0.98)end self.Display=math.max(self.Display,math.min(actual,0.99))
local shown=self._shown or 0 shown+=(self.Display-shown)*0.12 self._shown=shown
table.insert(self.Samples,{t,self.Display})while#self.Samples>2 and self.Samples
[1][1]<t-1.5 do table.remove(self.Samples,1)end local first=self.Samples[1]local
rate=(self.Display-first[2])/math.max(t-first[1],0.05)local etaText if rate>
0.002 and self.Display<0.98 then local left=(1-self.Display)/rate etaText=left<1
and'<1 s'or('~'..math.ceil(left)..' s')else etaText=string.format('%.1f s',t)end
self.EtaText=etaText if self.Fill then self.Fill.Size=UDim2.fromScale(shown,1)
self.Pct.Text=math.floor(shown*100+0.5)..'%'self.Eta.Text=etaText end return
shown end function Intros:SetStage(text)if not text then return end if self.
Status then self.Status.Text=text end if self.Def.Stage then self.Def.Stage(self
,text)end end function Intros:Finish(onOpen)if self.Finishing then return end
self.Finishing=true task.spawn(function()local start=os.clock()while self.Root
and(self._shown or 0)<0.97 and os.clock()-start<1.2 do self.Display=1 RunService
.RenderStepped:Wait()end if not self.Root then return end task.wait(0.25)self.
Exploding=true self.ExplodeAt=os.clock()if self.Fill then self.Fill.Size=UDim2.
fromScale(1,1)self.Pct.Text='100%'self.Status.Text=Locale.T('Ready')self.Eta.
Text=''for _,l in{self.TitleLabel,self.Pct,self.Status,self.Eta}do Tween.Play(l,
{TextTransparency=1},0.35)end Tween.Play(self.Track,{BackgroundTransparency=1},
0.35)Tween.Play(self.Fill,{BackgroundTransparency=1},0.35)end local delay,
ownAnimation=self.Def.Burst(self)Tween.Play(self.Dim,{BackgroundTransparency=1},
0.8,Enum.EasingStyle.Sine)task.delay(delay or 0.2,function()if onOpen then local
stage=self.Stage local point=stage and(stage.AbsolutePosition+stage.AbsoluteSize
/2-Shared.Gui.Root.AbsolutePosition)onOpen((not ownAnimation)and point or nil)
end end)task.delay(1.1,function()self:Destroy()end)end)end function Intros:
Destroy()if self.Conn then self.Conn:Disconnect()self.Conn=nil end if self.Root
then self.Root:Destroy()self.Root=nil end end return Intros end function
__DARKLUA_BUNDLE_MODULES.z()local v=__DARKLUA_BUNDLE_MODULES.cache.z if not v
then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.z=v end return v.c end end
do local function __modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Signal
=__DARKLUA_BUNDLE_MODULES.b()local Maid=__DARKLUA_BUNDLE_MODULES.c()local Tween=
__DARKLUA_BUNDLE_MODULES.d()local Env=__DARKLUA_BUNDLE_MODULES.e()local Keys=
__DARKLUA_BUNDLE_MODULES.f()local Theme=__DARKLUA_BUNDLE_MODULES.g()local Icons=
__DARKLUA_BUNDLE_MODULES.i()local Locale=__DARKLUA_BUNDLE_MODULES.j()local
Shared=__DARKLUA_BUNDLE_MODULES.k()local PageModule=__DARKLUA_BUNDLE_MODULES.v()
local Skeleton=__DARKLUA_BUNDLE_MODULES.w()local Motion=__DARKLUA_BUNDLE_MODULES
.x()local Loader=__DARKLUA_BUNDLE_MODULES.y()local Intros=
__DARKLUA_BUNDLE_MODULES.z()local UIS=Env.Service('UserInputService')local
RunService=Env.Service('RunService')Env.Service('Players')local Tab=PageModule.
Tab local Window={}Window.__index=Window local DEFAULT_SIZE=Vector2.new(740,500)
local MOBILE_SIZE=Vector2.new(600,380)function Window.new(Lib,options)options=
options or{}local self=setmetatable({},Window)self.Library=Lib self.Options=
options self.Title=Util.Opt(options,'Title','Name')or'Proximity'self.Subtitle=
Util.Opt(options,'Subtitle','SubTitle','SubName','Description')or('v'..Lib.
Version)self.Logo=Util.Opt(options,'Logo','Icon')self.Keybind=Keys.Normalize(
Util.Opt(options,'Keybind','MenuKey','Key')or'RightShift')self.SidebarWidth=
options.SidebarWidth or 196 local touch=UIS.TouchEnabled and not UIS.
KeyboardEnabled local size=options.Size if typeof(size)=='UDim2'then size=
Vector2.new(size.X.Offset,size.Y.Offset)end self.BaseSize=size or(touch and
MOBILE_SIZE or DEFAULT_SIZE)self.MinSize=options.MinSize or Vector2.new(560,360)
self.Loading=type(options.Loading)=='table'and options.Loading or{Enabled=
options.Loading~=false}self.Loading.Enabled=self.Loading.Enabled~=false and Lib:
GetSetting('LoadingStyle','Planet')~='None'self.Loading.MinTime=self.Loading.
MinTime or 0.6 self.AutoReady=options.AutoReady~=false self.Tabs={}self.State=
'Loading'self.Maid=Maid.new()self.Ready=Signal.new()self.Opened=Signal.new()self
.Closed=Signal.new()self.TabChanged=Signal.new()self.PageChanged=Signal.new()
self._queue={}self._tasks={}self._declaring=true self._lastDeclare=os.clock()
self._navOrder=0 self._history={}self._isOpen=false self._commands={}self.Touch=
touch self:_build()self.LoadingStyle=self.Loading.Style or Lib:GetSetting(
'LoadingStyle','Planet')self:SetScale(options.Scale or Lib:GetSetting('Scale',
'Auto'))self:_setupToggleButton()if self.Loading.Enabled and self.LoadingStyle==
'Planet'then self.Loader=Loader.new(self,self.Loading)self.Holder.Visible=false
elseif self.Loading.Enabled and Intros.Has(self.LoadingStyle)then self.Loader=
Intros.new(self,self.Loading,self.LoadingStyle)self.Holder.Visible=false else if
self.Loading.Enabled then self.Skeleton=Skeleton.new(self)end self:Open()end
self:SetNavigation(options.Navigation or Lib:GetSetting('Navigation','Sidebar'))
self:_applyEconomy()local bg=Lib:GetSetting('Background')if options.Background
or type(bg)=='table'then self:SetBackground(options.Background or bg)end self:
_bindInput()self:_bindNavigation()task.defer(function()self:_pump()end)return
self end local LOGO_URL=
[[https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/assets/logo-256.png]]
local PLANET_URL=
[[https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/assets/logo-512.png]]
Window.LogoUrl,Window.PlanetUrl=LOGO_URL,PLANET_URL local function loadImage(
source,callback)task.spawn(function()local ok,image=pcall(Icons.Get,source)if ok
and image then callback(image)end end)end function Window:_drawLogo(parent,size)
local holder=Util.New('Frame',{Name='Logo',BackgroundTransparency=1,Size=UDim2.
fromOffset(size,size),Parent=parent})local custom=self.Logo if custom and custom
~=true then local id=Icons.Get(custom)if id then local img=Util.New('ImageLabel'
,{BackgroundTransparency=1,Image=id,Size=UDim2.fromScale(1,1),ScaleType=Enum.
ScaleType.Crop,Parent=holder})Util.Round(img)return holder end end local vector=
Util.New('Frame',{Name='Vector',BackgroundTransparency=1,Size=UDim2.fromScale(1,
1),Parent=holder})local ringW,ringH=1.36,0.3 local back=Util.New('Frame',{
BackgroundTransparency=1,Size=UDim2.fromScale(ringW,ringH),AnchorPoint=Vector2.
new(0.5,0.5),Position=UDim2.fromScale(0.5,0.56),Rotation=-16,ZIndex=1,Parent=
vector})Util.Round(back)local backStroke=Util.Stroke(back,nil,math.max(1,size/26
))Theme.Paint(backStroke,{Color='Accent'})Util.Gradient(backStroke,nil,
NumberSequence.new({NumberSequenceKeypoint.new(0,0.85),NumberSequenceKeypoint.
new(0.5,0.55),NumberSequenceKeypoint.new(1,0.15)}))local disc=Util.New('Frame',{
Size=UDim2.fromScale(0.72,0.72),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.
fromScale(0.5,0.5),ZIndex=2,Parent=vector})Util.Round(disc)Theme.Paint(disc,{
BackgroundColor3='Bg'})local rim=Util.Stroke(disc,nil,math.max(1.2,size/20))
Theme.Paint(rim,{Color='Accent'})Util.Gradient(rim,nil,NumberSequence.new({
NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.35,0.1),
NumberSequenceKeypoint.new(0.62,0.8),NumberSequenceKeypoint.new(1,1)}),-50)local
front=Util.New('Frame',{BackgroundTransparency=1,Size=UDim2.fromScale(ringW,
ringH),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.56),
Rotation=-16,ZIndex=3,Parent=vector})Util.Round(front)local frontStroke=Util.
Stroke(front,nil,math.max(1,size/26))Theme.Paint(frontStroke,{Color='Accent'})
Util.Gradient(frontStroke,nil,NumberSequence.new({NumberSequenceKeypoint.new(0,1
),NumberSequenceKeypoint.new(0.52,1),NumberSequenceKeypoint.new(0.6,0.35),
NumberSequenceKeypoint.new(1,0.1)}),90)local flare=Util.New('Frame',{Size=UDim2.
fromScale(0.16,0.16),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(
0.74,0.23),ZIndex=4,Parent=vector})Util.Round(flare)Theme.Paint(flare,{
BackgroundColor3='Accent'})Util.Gradient(flare,nil,NumberSequence.new({
NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.6)}),45)local
streak=Util.New('Frame',{Size=UDim2.new(0.55,0,0,1),AnchorPoint=Vector2.new(0,
0.5),Position=UDim2.fromScale(0.74,0.23),BorderSizePixel=0,ZIndex=4,Parent=
vector})Theme.Paint(streak,{BackgroundColor3='Accent'})Util.Gradient(streak,nil,
NumberSequence.new({NumberSequenceKeypoint.new(0,0.1),NumberSequenceKeypoint.
new(1,1)}))if custom~=false then loadImage(LOGO_URL,function(image)if not holder
.Parent then return end local img=Util.New('ImageLabel',{BackgroundTransparency=
1,Image=image,ImageTransparency=1,Size=UDim2.fromScale(1.18,1.18),AnchorPoint=
Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),ScaleType=Enum.ScaleType.
Crop,ZIndex=5,Parent=holder})Util.Round(img)Tween.Play(img,{ImageTransparency=0}
,0.4)task.delay(0.4,function()vector.Visible=false end)end)end return holder end
function Window:_buildDecor()local decor=Util.New('ImageLabel',{Name='Planet',
BackgroundTransparency=1,ImageTransparency=1,Size=UDim2.fromOffset(420,420),
AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(1,-40,1,-30),ScaleType=Enum.
ScaleType.Fit,ZIndex=1,Parent=self.Canvas})self._decor=decor self.DecorEnabled=
self.Options.Decoration~=false and self.Library:GetSetting('Decoration',true)if
self.Logo==false then return end loadImage(PLANET_URL,function(image)decor.Image
=image if self.DecorEnabled then Tween.Play(decor,{ImageTransparency=0.72},0.8)
end end)end function Window:SetDecoration(enabled)self.DecorEnabled=enabled and
true or false if self._decor then Tween.Play(self._decor,{ImageTransparency=
enabled and self._decor.Image~=''and 0.72 or 1},0.4)end return self end function
Window:_build()local Lib=self.Library local gui=Shared.Gui local _=workspace.
CurrentCamera.ViewportSize local saved=Lib:GetSetting('Window.'..self.Title)
local size=self.BaseSize if type(saved)=='table'and saved.W then size=Vector2.
new(math.max(saved.W,self.MinSize.X),math.max(saved.H,self.MinSize.Y))end self.
Size=size local holder=Util.New('Frame',{Name='Window_'..self.Title,
BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=(type(saved)
=='table'and saved.X)and UDim2.fromOffset(saved.X,saved.Y)or UDim2.fromScale(0.5
,0.5),Size=UDim2.fromOffset(size.X,size.Y),Active=true,Parent=gui.Windows})self.
Holder=holder self._uiScale=Util.New('UIScale',{Parent=holder})self._openScale=
Util.New('UIScale',{Parent=Util.New('Frame',{BackgroundTransparency=1,Size=UDim2
.new(),Parent=holder})})local plate=Util.New('Frame',{Name='Plate',Size=UDim2.
fromScale(1,1),Parent=holder})Util.Corner(10,plate)Theme.Paint(plate,{
BackgroundColor3='Bg'})Shared.Overlay.Shadow(plate,0.35,28)self.Plate=plate
local canvas=Util.New('CanvasGroup',{Name='Canvas',Size=UDim2.fromScale(1,1),
ZIndex=2,Parent=holder})Util.Corner(10,canvas)Theme.Paint(canvas,{
BackgroundColor3='Bg'})self.Canvas=canvas local border=Util.New('Frame',{Name=
'Border',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=5,Parent=
holder})Util.Corner(10,border)local borderStroke=Util.Stroke(border)Theme.Paint(
borderStroke,{Color='Stroke'})local rimFrame=Util.New('Frame',{Name='Rim',
BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=6,Parent=holder})Util.
Corner(10,rimFrame)local rim=Util.Stroke(rimFrame,nil,1.2)Theme.Paint(rim,{Color
='Accent'})local rimGradient=Util.Gradient(rim,nil,NumberSequence.new({
NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.4,1),
NumberSequenceKeypoint.new(0.5,0.1),NumberSequenceKeypoint.new(0.6,1),
NumberSequenceKeypoint.new(1,1)}))self._border,self._borderStroke,self._rim,self
._rimGradient=border,borderStroke,rim,rimGradient self.RimEnabled=Lib:
GetSetting('Rim',true)self.Maid:Connect(RunService.Heartbeat,function()if self.
_isOpen and self.RimEnabled and Tween.Speed>0 then rimGradient.Rotation=(os.
clock()*24)%360 end end)local top=Util.New('Frame',{Name='TopLine',Size=UDim2.
new(0.6,0,0,1),AnchorPoint=Vector2.new(0.5,0),Position=UDim2.fromScale(0.5,0),
BorderSizePixel=0,ZIndex=7,Parent=canvas})Theme.Paint(top,{BackgroundColor3=
'Accent'})Util.Gradient(top,nil,NumberSequence.new({NumberSequenceKeypoint.new(0
,1),NumberSequenceKeypoint.new(0.5,0.55),NumberSequenceKeypoint.new(1,1)}))self:
_buildBackdrop()self:_buildDecor()self:_buildSidebar()self:_buildMain()self:
_buildResize()self._modal=Util.New('TextButton',{Text='',BackgroundTransparency=
1,Size=UDim2.fromOffset(0,0),Modal=true,Visible=false,Parent=holder})self.Maid:
Connect(workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'),
function()if self._autoScale then self:SetScale('Auto')end self:_clampPosition()
end)self.Maid:Give(holder)end function Window:_buildBackdrop()local layer=Util.
New('Frame',{Name='Backdrop',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),
ZIndex=1,Parent=self.Canvas})self._backdrop=layer self:SetBackdrop(self.Options.
Backdrop or self.Library:GetSetting('Backdrop','Stars'))end function Window:
SetBackdrop(pattern)local spec=type(pattern)=='table'and pattern or{Pattern=
pattern}local layer=self._backdrop for _,c in layer:GetChildren()do c:Destroy()
end if self._backdropConn then self._backdropConn:Disconnect()self._backdropConn
=nil end self.BackdropPattern=spec.Pattern or'None'local alpha=spec.Transparency
or 0.9 local rng=Random.new(7)if spec.Pattern=='Stars'then local stars={}for i=1
,46 do local s=rng:NextNumber()<0.15 and 2 or 1 local star=Util.New('Frame',{
Size=UDim2.fromOffset(s,s),Position=UDim2.fromScale(rng:NextNumber(),rng:
NextNumber()),BorderSizePixel=0,BackgroundTransparency=alpha,ZIndex=1,Parent=
layer})Theme.Paint(star,{BackgroundColor3='Accent'})table.insert(stars,{star,rng
:NextNumber()*6,0.6+rng:NextNumber()*1.4})end self._backdropConn=RunService.
Heartbeat:Connect(function()if not self._isOpen or Tween.Speed==0 then return
end local t=os.clock()for _,item in stars do item[1].BackgroundTransparency=
alpha+(1-alpha)*(0.5+0.5*math.sin(t*item[3]+item[2]))*0.9 end end)self.Maid:
Give(self._backdropConn)elseif spec.Pattern=='Grid'then for i=1,40 do local v=
Util.New('Frame',{Size=UDim2.new(0,1,1,0),Position=UDim2.fromOffset(i*32,0),
BorderSizePixel=0,BackgroundTransparency=0.96,ZIndex=1,Parent=layer})Theme.
Paint(v,{BackgroundColor3='Accent'})end for i=1,30 do local h=Util.New('Frame',{
Size=UDim2.new(1,0,0,1),Position=UDim2.fromOffset(0,i*32),BorderSizePixel=0,
BackgroundTransparency=0.96,ZIndex=1,Parent=layer})Theme.Paint(h,{
BackgroundColor3='Accent'})end elseif spec.Pattern=='Dots'then for x=0,36 do for
y=0,24 do local d=Util.New('Frame',{Size=UDim2.fromOffset(1,1),Position=UDim2.
fromOffset(12+x*26,12+y*26),BorderSizePixel=0,BackgroundTransparency=0.82,ZIndex
=1,Parent=layer})Theme.Paint(d,{BackgroundColor3='TextMute'})end end end return
self end function Window:_buildSidebar()local _=self.Library local side=Util.
New('Frame',{Name='Sidebar',Size=UDim2.new(0,self.SidebarWidth,1,0),
BorderSizePixel=0,ZIndex=2,Parent=self.Canvas})Theme.Paint(side,{
BackgroundColor3='Bg2'})side.BackgroundTransparency=0.15 local divider=Util.New(
'Frame',{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BorderSizePixel=0,
ZIndex=3,Parent=side})Theme.Paint(divider,{BackgroundColor3='Stroke'})self.
Sidebar=side local brand=Util.New('Frame',{Name='Brand',BackgroundTransparency=1
,Size=UDim2.new(1,0,0,62),ZIndex=3,Parent=side})local logo=self:_drawLogo(brand,
26)logo.Position=UDim2.fromOffset(16,18)self._brandLogo=logo local title=Util.
Label({Text=self.Title,FontFace=Theme.Fonts.Bold,TextSize=15,Size=UDim2.new(1,-
60,0,18),Position=UDim2.fromOffset(52,16),TextTruncate=Enum.TextTruncate.AtEnd,
ZIndex=3,Parent=brand})Theme.Paint(title,{TextColor3='Text'})local sub=Util.
Label({Text=self.Subtitle,FontFace=Theme.Fonts.Regular,TextSize=11,Size=UDim2.
new(1,-60,0,14),Position=UDim2.fromOffset(52,34),TextTruncate=Enum.TextTruncate.
AtEnd,ZIndex=3,Parent=brand})Theme.Paint(sub,{TextColor3='TextMute'})self.
_titleLabel,self._subLabel,self._brand=title,sub,brand self:_makeDraggable(brand
)local search=Util.New('TextButton',{Name='Search',Text='',AutoButtonColor=false
,Size=UDim2.new(1,-20,0,30),Position=UDim2.fromOffset(10,64),ZIndex=3,Parent=
side})Util.Corner(6,search)Theme.Paint(search,{BackgroundColor3='Surface'})local
searchStroke=Util.Stroke(search)Theme.Paint(searchStroke,{Color='Stroke'})local
sIcon=Util.New('ImageLabel',{BackgroundTransparency=1,Image=Icons.Get('search')
or'',Size=UDim2.fromOffset(13,13),Position=UDim2.new(0,10,0.5,-6),ZIndex=3,
Parent=search})Theme.Paint(sIcon,{ImageColor3='TextMute'})local sText=Util.
Label({Text=Locale.T('Search'),FontFace=Theme.Fonts.Regular,TextSize=12,Size=
UDim2.new(1,-60,1,0),Position=UDim2.fromOffset(30,0),ZIndex=3,Parent=search})
Theme.Paint(sText,{TextColor3='TextMute'})local kbd=Util.Label({Text='Ctrl K',
FontFace=Theme.Fonts.Mono,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right,
Size=UDim2.new(1,-10,1,0),ZIndex=3,Parent=search})Theme.Paint(kbd,{TextColor3=
'TextMute'})search.MouseEnter:Connect(function()Theme.Paint(searchStroke,{Color=
'StrokeHi'},0.1)end)search.MouseLeave:Connect(function()Theme.Paint(searchStroke
,{Color='Stroke'},0.1)end)search.Activated:Connect(function()self:OpenSearch()
end)self._searchText,self._searchIcon,self._searchKbd,self._searchButton=sText,
sIcon,kbd,search local profileH=self.Options.Profile==false and 0 or 56 local
list=Util.New('ScrollingFrame',{Name='Tabs',BackgroundTransparency=1,
BorderSizePixel=0,Size=UDim2.new(1,0,1,-104-profileH),Position=UDim2.fromOffset(
0,102),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,
ScrollBarThickness=0,ZIndex=3,Parent=side})Util.Padding(list,4,10,8,10)Util.
List(list,2)self.TabList=list if profileH>0 then self:_buildProfile(side)end
Locale.Changed:Connect(function()sText.Text=Locale.T('Search')end)end function
Window:_buildProfile(side)local Lib=self.Library local card=Util.New('Frame',{
Name='Profile',Size=UDim2.new(1,-20,0,44),Position=UDim2.new(0,10,1,-52),ZIndex=
3,Parent=side})Util.Corner(8,card)Theme.Paint(card,{BackgroundColor3='Surface'})
Theme.Paint(Util.Stroke(card),{Color='Stroke'})local avatar=Util.New(
'ImageLabel',{Size=UDim2.fromOffset(28,28),Position=UDim2.new(0,8,0.5,-14),
ZIndex=3,Parent=card})Util.Round(avatar)Theme.Paint(avatar,{BackgroundColor3=
'Surface3'})local q=Util.Label({Text='?',FontFace=Theme.Fonts.Bold,TextSize=14,
TextXAlignment=Enum.TextXAlignment.Center,Size=UDim2.fromScale(1,1),ZIndex=4,
Parent=avatar})Theme.Paint(q,{TextColor3='TextDim'})local name=Util.Label({
FontFace=Theme.Fonts.SemiBold,TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd,
Size=UDim2.new(1,-52,0,15),Position=UDim2.fromOffset(44,7),ZIndex=3,Parent=card}
)Theme.Paint(name,{TextColor3='Text'})local status=Util.Label({FontFace=Theme.
Fonts.Regular,TextSize=10,TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,
-52,0,13),Position=UDim2.fromOffset(44,23),ZIndex=3,Parent=card})Theme.Paint(
status,{TextColor3='TextMute'})self._profile={Card=card,Avatar=avatar,Name=name,
Status=status}local function refresh()local id=Lib:GetIdentity()name.Text=id.
DisplayName status.Text=self.Options.Status or Lib.Status or('@'..id.Name)avatar
.Image=id.Avatar or''q.Visible=id.Avatar==nil end self._refreshProfile=refresh
Lib.IdentityChanged:Connect(refresh)refresh()end function Window:Category(name)
if type(name)=='table'then name=name.Name or name[1]end self._navOrder+=1 local
label=Util.Label({Text=string.upper(tostring(name)),FontFace=Theme.Fonts.Bold,
TextSize=10,Size=UDim2.new(1,0,0,24),LayoutOrder=self._navOrder,ZIndex=3,Parent=
self.TabList})Util.Padding(label,8,0,0,8)Theme.Paint(label,{TextColor3=
'TextMute'})label:SetAttribute('Text',string.upper(tostring(name)))self.
_categories=self._categories or{}table.insert(self._categories,label)if self.
Navigation=='Rail'then label.Text=''label.Size=UDim2.new(1,0,0,10)end return
label end Window.Divider=Window.Category Window.Group=Window.Category Window.
DrawCategory=Window.Category Window.AddTabDivider=Window.Category function
Window:Tab(options)local tab=Tab.new(self,options)table.insert(self.Tabs,tab)
self._navOrder+=1 tab.Order=tab.Order or self._navOrder self:_buildTabButton(tab
)if self.Skeleton and not tab.Hidden then self.Skeleton:AddTab(tab)end if not
self.CurrentTab then self:SelectTab(tab)end self._lastDeclare=os.clock()return
tab end Window.AddTab=Window.Tab Window.DrawTab=Window.Tab Window.CreateTab=
Window.Tab Window.Page=Window.Tab function Window:_buildTabButton(tab)local
button=Util.New('TextButton',{Name='Tab_'..tab.Name,Text='',AutoButtonColor=
false,BackgroundTransparency=1,Size=UDim2.new(1,0,0,32),LayoutOrder=tab.Order,
Visible=tab.Visible,ZIndex=3,Parent=self.TabList})Util.Corner(6,button)Theme.
Paint(button,{BackgroundColor3='Surface2'})local bar=Util.New('Frame',{Size=
UDim2.fromOffset(2,0),AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,
0),BorderSizePixel=0,ZIndex=4,Parent=button})Util.Round(bar)Theme.Paint(bar,{
BackgroundColor3='Accent'})local icon=Util.New('ImageLabel',{
BackgroundTransparency=1,Image=Icons.Get(tab.Icon)or'',Size=UDim2.fromOffset(16,
16),Position=UDim2.new(0,10,0.5,-8),ZIndex=4,Parent=button})local hasIcon=Icons.
Get(tab.Icon)~=nil local label=Util.Label({Text=tab.Name,FontFace=Theme.Fonts.
Medium,TextSize=13,TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,-60,1,0
),Position=UDim2.fromOffset(hasIcon and 34 or 12,0),ZIndex=4,Parent=button})
local badge=Util.Label({Text=tab.Badge and tostring(tab.Badge)or'',FontFace=
Theme.Fonts.Bold,TextSize=9,TextXAlignment=Enum.TextXAlignment.Center,
AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,16),AnchorPoint=
Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),Visible=tab.Badge~=nil,
BackgroundTransparency=0,ZIndex=4,Parent=button})Util.Padding(badge,0,5,0,5)Util
.Corner(4,badge)Theme.Paint(badge,{BackgroundColor3='Accent',TextColor3=
'AccentInk'})local glow=Util.Stroke(button,nil,1,1)Theme.Paint(glow,{Color=
'Accent'})tab.Button,tab._icon,tab._label,tab._bar,tab._badge,tab._glow=button,
icon,label,bar,badge,glow Shared.Overlay.Hover(button,function()return self.
Navigation=='Rail'and tab.Name or nil end)if self.Navigation=='Rail'then self:
_railTab(tab)end button.MouseEnter:Connect(function()if self.CurrentTab~=tab
then Tween.Play(button,{BackgroundTransparency=0.6},0.12)Theme.Paint(label,{
TextColor3='Text'},0.12)end end)button.MouseLeave:Connect(function()if self.
CurrentTab~=tab then Tween.Play(button,{BackgroundTransparency=1},0.15)Theme.
Paint(label,{TextColor3='TextDim'},0.15)end end)button.Activated:Connect(
function()self:SelectTab(tab)end)self:_paintTab(tab,false)end function Window:
_paintTab(tab,animate)local on=self.CurrentTab==tab local t=animate and 0.18 or
0 if not tab.Button then return end Tween.Play(tab.Button,{
BackgroundTransparency=1},t)Theme.Paint(tab._label,{TextColor3=on and'Text'or
'TextDim'},t)Theme.Paint(tab._icon,{ImageColor3=on and'Accent'or'TextMute'},t)
tab._bar.Size=UDim2.fromOffset(2,0)if tab._glow then tab._glow.Transparency=1
end if on then self:_movePill(animate)end end function Window:_tabPill()if self.
_pill then return self._pill end local list=self.TabList local side=list.Parent
local pill=Util.New('Frame',{Name='TabPill',BorderSizePixel=0,Visible=false,
ZIndex=2,Parent=side})Util.Corner(6,pill)Theme.Paint(pill,{BackgroundColor3=
'Surface2'})local stroke=Util.Stroke(pill,nil,1,0.82)Theme.Paint(stroke,{Color=
'Accent'})local bar=Util.New('Frame',{BorderSizePixel=0,AnchorPoint=Vector2.new(
0,0.5),Position=UDim2.fromScale(0,0.5),Size=UDim2.fromOffset(2,16),ZIndex=3,
Parent=pill})Util.Round(bar)Theme.Paint(bar,{BackgroundColor3='Accent'})self.
_pill,self._pillBar=pill,bar local function follow()self:_movePill(false)end
self.Maid:Connect(list:GetPropertyChangedSignal('CanvasPosition'),follow)self.
Maid:Connect(list:GetPropertyChangedSignal('AbsoluteSize'),follow)self.Maid:
Connect(list:GetPropertyChangedSignal('AbsoluteCanvasSize'),follow)return pill
end function Window:_movePill(animate)local pill=self:_tabPill()local tab=self.
CurrentTab local button=tab and tab.Button if not(button and button.Visible and
button.Parent)then pill.Visible=false return end local side=pill.Parent local k=
self.Holder.AbsoluteSize.X/math.max(self.Holder.Size.X.Offset,1)if k<=0.01 then
task.defer(function()self:_movePill(false)end)return end local pos=(button.
AbsolutePosition-side.AbsolutePosition)/k local size=button.AbsoluteSize/k local
list=self.TabList local top=(list.AbsolutePosition.Y-side.AbsolutePosition.Y)/k
local bottom=top+list.AbsoluteSize.Y/k pill.Visible=size.Y>1 and pos.Y+size.Y>
top+2 and pos.Y<bottom-2 local goal={Position=UDim2.fromOffset(pos.X,pos.Y),Size
=UDim2.fromOffset(size.X,size.Y)}if animate and Tween.Speed>0 and pill.Size.Y.
Offset>0 then Tween.Play(pill,goal,0.42,Enum.EasingStyle.Back,Enum.
EasingDirection.Out)self._pillBar.Size=UDim2.fromOffset(2,6)Tween.Play(self.
_pillBar,{Size=UDim2.fromOffset(2,16)},0.5,Enum.EasingStyle.Back)else pill.
Position,pill.Size=goal.Position,goal.Size end end function Window:_buildMain()
local main=Util.New('Frame',{Name='Main',BackgroundTransparency=1,Size=UDim2.
new(1,-self.SidebarWidth,1,0),Position=UDim2.fromOffset(self.SidebarWidth,0),
ZIndex=2,Parent=self.Canvas})self.Main=main local header=Util.New('Frame',{Name=
'Header',BackgroundTransparency=1,Size=UDim2.new(1,0,0,56),ZIndex=3,Parent=main}
)self.Header=header self:_makeDraggable(header)local back=Util.New('ImageButton'
,{BackgroundTransparency=1,Image=Icons.Get('arrow-left')or'',Size=UDim2.
fromOffset(18,18),Position=UDim2.new(0,16,0.5,-9),Visible=false,ZIndex=4,Parent=
header})Theme.Paint(back,{ImageColor3='TextDim'})back.Activated:Connect(function
()self:Back()end)local title=Util.Label({FontFace=Theme.Fonts.SemiBold,TextSize=
17,Size=UDim2.new(1,-260,0,20),Position=UDim2.fromOffset(18,10),TextTruncate=
Enum.TextTruncate.AtEnd,ZIndex=4,Parent=header})Theme.Paint(title,{TextColor3=
'Text'})local desc=Util.Label({FontFace=Theme.Fonts.Regular,TextSize=11,Size=
UDim2.new(1,-260,0,14),Position=UDim2.fromOffset(18,31),TextTruncate=Enum.
TextTruncate.AtEnd,ZIndex=4,Parent=header})Theme.Paint(desc,{TextColor3=
'TextMute'})self._back,self._title,self._desc=back,title,desc local actions=Util
.New('Frame',{BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.X,Size=
UDim2.new(0,0,1,0),AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,0),
ZIndex=4,Parent=header})Util.List(actions,6,Enum.FillDirection.Horizontal,Enum.
HorizontalAlignment.Right,Enum.VerticalAlignment.Center)self._actions=actions if
self.Options.ConfigButton~=false then self:_buildConfigChip(actions)end self.
_homeButton=self:_headerButton('home',10,function()if self.HomeTab then self.
HomeTab:Select()end end,'Home')self._homeButton.Visible=false self.
_settingsButton=self:_headerButton('settings',11,function()if self.
SettingsTabRef then self.SettingsTabRef:Select()end end,'Settings')self.
_settingsButton.Visible=false self._bell=self:_headerButton('bell',12,function()
self:OpenNotifications()end,'NotificationCenter')local badge=Util.Label({Text=''
,FontFace=Theme.Fonts.Bold,TextSize=9,TextXAlignment=Enum.TextXAlignment.Center,
Size=UDim2.fromOffset(14,14),AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,2
,0,-2),BackgroundTransparency=0,Visible=false,ZIndex=6,Parent=self._bell})Util.
Round(badge)Theme.Paint(badge,{BackgroundColor3='Accent',TextColor3='AccentInk'}
)self._bellBadge=badge self.Library.NotificationsChanged:Connect(function()local
n=self.Library.Unread or 0 badge.Visible=n>0 badge.Text=n>9 and'9+'or tostring(n
)end)self:_headerButton('minimize-2',19,function()self:SetMini(true)end,
'MiniMode')self:_headerButton('minus',20,function()self:Close()end,'Hide')local
line=Util.New('Frame',{Size=UDim2.new(1,-24,0,1),Position=UDim2.new(0,12,1,-1),
BorderSizePixel=0,ZIndex=3,Parent=header})Theme.Paint(line,{BackgroundColor3=
'Stroke'})local pills=Util.New('Frame',{Name='Pills',BackgroundTransparency=1,
Size=UDim2.new(1,-24,0,34),Position=UDim2.fromOffset(12,60),Visible=false,ZIndex
=3,Parent=main})Util.List(pills,6,Enum.FillDirection.Horizontal,Enum.
HorizontalAlignment.Left,Enum.VerticalAlignment.Center)self._pills=pills local
content=Util.New('Frame',{Name='Content',BackgroundTransparency=1,Size=UDim2.
new(1,0,1,-58),Position=UDim2.fromOffset(0,58),ClipsDescendants=true,ZIndex=2,
Parent=main})self.Content=content content:GetPropertyChangedSignal(
'AbsoluteSize'):Connect(function()for _,tab in self.Tabs do for _,page in tab.
Pages do page:_layoutColumns()end end end)end function Window:_headerButton(icon
,order,callback,tooltip)local b=Util.New('ImageButton',{BackgroundTransparency=1
,Size=UDim2.fromOffset(30,30),LayoutOrder=order,ZIndex=4,Parent=self._actions})
Util.Corner(6,b)Theme.Paint(b,{BackgroundColor3='Surface2'})local stroke=Util.
Stroke(b)stroke.Transparency=1 Theme.Paint(stroke,{Color='Stroke'})local img=
Util.New('ImageLabel',{BackgroundTransparency=1,Image=Icons.Get(icon)or'',Size=
UDim2.fromOffset(15,15),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.
fromScale(0.5,0.5),ZIndex=5,Parent=b})Theme.Paint(img,{ImageColor3='TextDim'})b.
MouseEnter:Connect(function()Tween.Play(b,{BackgroundTransparency=0},0.1)Tween.
Play(stroke,{Transparency=0},0.1)Theme.Paint(img,{ImageColor3='Text'},0.1)end)b.
MouseLeave:Connect(function()Tween.Play(b,{BackgroundTransparency=1},0.15)Tween.
Play(stroke,{Transparency=1},0.15)Theme.Paint(img,{ImageColor3='TextDim'},0.15)
end)b.Activated:Connect(callback)if tooltip then Shared.Overlay.Hover(b,function
()return Locale.T(tooltip)end)end return b end function Window:_buildConfigChip(
parent)local Lib=self.Library local chip=Util.New('Frame',{Name='Config',
AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,30),LayoutOrder=1,
ZIndex=4,Parent=parent})Util.Corner(6,chip)Theme.Paint(chip,{BackgroundColor3=
'Surface'})Theme.Paint(Util.Stroke(chip),{Color='Stroke'})Util.List(chip,0,Enum.
FillDirection.Horizontal,Enum.HorizontalAlignment.Left,Enum.VerticalAlignment.
Center)local save=Util.New('ImageButton',{BackgroundTransparency=1,Size=UDim2.
fromOffset(30,30),LayoutOrder=1,ZIndex=5,Parent=chip})local saveIcon=Util.New(
'ImageLabel',{BackgroundTransparency=1,Image=Icons.Get('save')or'',Size=UDim2.
fromOffset(14,14),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,
0.5),ZIndex=5,Parent=save})Theme.Paint(saveIcon,{ImageColor3='TextDim'})local
nameButton=Util.New('TextButton',{Text='',FontFace=Theme.Fonts.Medium,TextSize=
12,AutoButtonColor=false,BackgroundTransparency=1,AutomaticSize=Enum.
AutomaticSize.X,Size=UDim2.fromOffset(0,30),LayoutOrder=2,ZIndex=5,Parent=chip})
Util.Padding(nameButton,0,12,0,2)Theme.Paint(nameButton,{TextColor3='Text'})
local dirty=Util.New('Frame',{Size=UDim2.fromOffset(5,5),AnchorPoint=Vector2.
new(0.5,0.5),Position=UDim2.new(1,-5,0,7),Visible=false,ZIndex=6,Parent=save})
Util.Round(dirty)Theme.Paint(dirty,{BackgroundColor3='Accent'})local function 
refresh()nameButton.Text=Lib.CurrentConfig or'default'dirty.Visible=Lib.Dirty==
true end Lib.ConfigsChanged:Connect(refresh)Lib.ConfigLoaded:Connect(refresh)Lib
.DirtyChanged:Connect(refresh)refresh()Shared.Overlay.Hover(save,function()
return Locale.T('Save')..' \u{b7} Ctrl+S'end)save.Activated:Connect(function()
Lib:QuickSave(self)end)nameButton.Activated:Connect(function()local items={}for
_,name in Lib:ListConfigs()do table.insert(items,{Text=name,Icon=name==Lib.
CurrentConfig and'check'or'file',Callback=function()Lib:LoadConfig(name)Lib.
CurrentConfig=name Lib:_setDirty(false)Lib:Notify({Title=Locale.T('Loaded'),
Content=name,Type='success',Duration=2.5})end})end if#items==0 then table.
insert(items,{Text=Locale.T('Empty')})end table.insert(items,{Separator=true})
table.insert(items,{Text=Locale.T('Save')..'\u{2026}',Icon='save',Callback=
function()task.spawn(function()local name=self:Prompt({Title=Locale.T('Save'),
Placeholder=Locale.T('ConfigName'),Default=Lib.CurrentConfig})if name and name~=
''then Lib:SaveConfig(name)Lib.CurrentConfig=Util.SafeName(name)Lib:_setDirty(
false)Lib:Notify({Title=Locale.T('Saved'),Content=Lib.CurrentConfig,Type=
'success',Duration=2.5})end end)end})Shared.Overlay.Menu(items,{Anchor=chip,
Align='End',Width=200})end)end function Window:_buildResize()if self.Options.
Resizable==false then return end local grip=Util.New('TextButton',{Name='Resize'
,Text='',BackgroundTransparency=1,Size=UDim2.fromOffset(16,16),AnchorPoint=
Vector2.new(1,1),Position=UDim2.fromScale(1,1),ZIndex=10,Parent=self.Holder})
local mark=Util.New('ImageLabel',{BackgroundTransparency=1,Image=Icons.Get(
'move-diagonal-2')or'',Size=UDim2.fromOffset(10,10),Position=UDim2.fromOffset(2,
2),ImageTransparency=0.6,ZIndex=10,Parent=grip})Theme.Paint(mark,{ImageColor3=
'TextMute'})local resizing,startMouse,startSize=false,nil,nil grip.InputBegan:
Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1
or input.UserInputType==Enum.UserInputType.Touch then resizing,startMouse,
startSize=true,Vector2.new(input.Position.X,input.Position.Y),self.Size end end)
self.Maid:Connect(UIS.InputChanged,function(input)if resizing and(input.
UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.
UserInputType.Touch)then local delta=(Vector2.new(input.Position.X,input.
Position.Y)-startMouse)/self:GetScale()local w=math.max(self.MinSize.X,math.
floor((startSize.X+delta.X)/8+0.5)*8)local h=math.max(self.MinSize.Y,math.floor(
(startSize.Y+delta.Y)/8+0.5)*8)self:SetSize(Vector2.new(w,h),true)end end)self.
Maid:Connect(UIS.InputEnded,function(input)if resizing and(input.UserInputType==
Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch
)then resizing=false self:_saveState()end end)end function Window:_makeDraggable
(handle)if self.Options.Draggable==false then return end local dragging,start,
startPos=false,nil,nil handle.InputBegan:Connect(function(input)if input.
UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.
UserInputType.Touch then dragging,start=true,Vector2.new(input.Position.X,input.
Position.Y)startPos=self.Holder.AbsolutePosition+self.Holder.AbsoluteSize/2-self
.Holder.Parent.AbsolutePosition end end)self.Maid:Connect(UIS.InputChanged,
function(input)if dragging and(input.UserInputType==Enum.UserInputType.
MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then local p=
startPos+(Vector2.new(input.Position.X,input.Position.Y)-start)self.Holder.
Position=UDim2.fromOffset(p.X,p.Y)self:_clampPosition()end end)self.Maid:
Connect(UIS.InputEnded,function(input)if dragging and(input.UserInputType==Enum.
UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch)then
dragging=false self:_saveState()end end)end function Window:_clampPosition()
local holder=self.Holder if holder.Position.X.Scale~=0 then return end local
view=workspace.CurrentCamera.ViewportSize local half=holder.AbsoluteSize/2 local
x=math.clamp(holder.Position.X.Offset,half.X*0.3,view.X-half.X*0.3)local y=math.
clamp(holder.Position.Y.Offset,half.Y*0.2+4,view.Y-half.Y*0.3)holder.Position=
UDim2.fromOffset(x,y)end function Window:_saveState()local p=self.Holder.
Position self.Library:SetSetting('Window.'..self.Title,{X=p.X.Scale==0 and p.X.
Offset or nil,Y=p.X.Scale==0 and p.Y.Offset or nil,W=self.Size.X,H=self.Size.Y,
Tab=self.CurrentTab and self.CurrentTab.Name})end function Window:_buildBubble(
force)if not force then return end local bubble=Util.New('TextButton',{Name=
'Bubble',Text='',AutoButtonColor=false,Size=UDim2.fromOffset(46,46),Position=
UDim2.new(0,20,0.3,0),Parent=Shared.Gui.Widgets})Util.Round(bubble)Theme.Paint(
bubble,{BackgroundColor3='Bg'})Theme.Paint(Util.Stroke(bubble),{Color='StrokeHi'
})local logo=self:_drawLogo(bubble,26)logo.AnchorPoint=Vector2.new(0.5,0.5)logo.
Position=UDim2.fromScale(0.5,0.5)local moved,start,startPos=false,nil,nil bubble
.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.
MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then moved,start,
startPos=false,Vector2.new(input.Position.X,input.Position.Y),bubble.
AbsolutePosition-bubble.Parent.AbsolutePosition end end)self.Maid:Connect(UIS.
InputChanged,function(input)if start and(input.UserInputType==Enum.UserInputType
.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then local d=
Vector2.new(input.Position.X,input.Position.Y)-start if d.Magnitude>6 then moved
=true end if moved then local view=workspace.CurrentCamera.ViewportSize bubble.
Position=UDim2.fromOffset(math.clamp(startPos.X+d.X,4,view.X-50),math.clamp(
startPos.Y+d.Y,4,view.Y-50))end end end)self.Maid:Connect(UIS.InputEnded,
function(input)if start and(input.UserInputType==Enum.UserInputType.MouseButton1
or input.UserInputType==Enum.UserInputType.Touch)then if not moved then self:
Toggle()end start=nil end end)self.Bubble=bubble self.Maid:Give(bubble)end
function Window:_railTab(tab)local rail=self.Navigation=='Rail'tab._label.
Visible=not rail tab._icon.Position=rail and UDim2.new(0.5,-8,0.5,-8)or UDim2.
new(0,10,0.5,-8)tab._badge.Visible=not rail and tab.Badge~=nil end function
Window:SetNavigation(mode)mode=mode=='Rail'and'Rail'or'Sidebar'self.Navigation=
mode local rail=mode=='Rail'local width=rail and 64 or self.SidebarWidth local t
=self.State=='Ready'and 0.25 or 0 Tween.Play(self.Sidebar,{Size=UDim2.new(0,
width,1,0)},t)Tween.Play(self.Main,{Size=UDim2.new(1,-width,1,0),Position=UDim2.
fromOffset(width,0)},t)self._titleLabel.Visible=not rail self._subLabel.Visible=
not rail if self._brandLogo then Tween.Play(self._brandLogo,{Position=UDim2.
fromOffset(rail and 19 or 16,18)},t)end self._searchText.Visible=not rail self.
_searchKbd.Visible=not rail self._searchIcon.Position=rail and UDim2.new(0.5,-6,
0.5,-6)or UDim2.new(0,10,0.5,-6)for _,label in self._categories or{}do label.
Text=rail and''or(label:GetAttribute('Text')or label.Text)label.Size=UDim2.new(1
,0,0,rail and 10 or 24)end for _,tab in self.Tabs do self:_railTab(tab)end if
self._profile then self._profile.Name.Visible=not rail self._profile.Status.
Visible=not rail self._profile.Avatar.Position=rail and UDim2.new(0.5,-14,0.5,-
14)or UDim2.new(0,8,0.5,-14)end return self end function Window:GetNavigation()
return self.Navigation end function Window:SetMini(on)on=on and true or false if
self.Mini==on then return self end self.Mini=on local holder=self.Holder if not
self._miniBar then local bar=Util.New('TextButton',{Name='MiniBar',Text='',
AutoButtonColor=false,Size=UDim2.fromScale(1,1),Visible=false,ZIndex=70,Parent=
self.Canvas})Theme.Paint(bar,{BackgroundColor3='Bg'})local logo=self:_drawLogo(
bar,26)logo.Position=UDim2.new(0,14,0.5,-13)local title=Util.Label({Text=self.
Title,FontFace=Theme.Fonts.Bold,TextSize=13,Position=UDim2.fromOffset(50,9),Size
=UDim2.new(1,-90,0,16),ZIndex=71,Parent=bar})Theme.Paint(title,{TextColor3=
'Text'})local stats=Util.Label({Text='',FontFace=Theme.Fonts.Mono,TextSize=11,
Position=UDim2.fromOffset(50,27),Size=UDim2.new(1,-90,0,14),ZIndex=71,Parent=bar
})Theme.Paint(stats,{TextColor3='TextMute'})local expand=Util.New('ImageLabel',{
BackgroundTransparency=1,Image=Icons.Get('maximize-2')or'',Size=UDim2.
fromOffset(15,15),AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-16,0.5,0)
,ZIndex=71,Parent=bar})Theme.Paint(expand,{ImageColor3='TextDim'})bar.Activated:
Connect(function()self:SetMini(false)end)self:_makeDraggable(bar)task.spawn(
function()while bar.Parent do if bar.Visible then stats.Text=self.Library.
Providers.FPS()..' fps  \u{b7}  '..self.Library.Providers.Ping()..'  \u{b7}  '..
os.date('%H:%M')end task.wait(0.5)end end)self._miniBar=bar end if on then self.
_fullSize=self.Size self._miniBar.Visible=true self._miniBar.
BackgroundTransparency=1 Tween.Play(self._miniBar,{BackgroundTransparency=0},0.2
)Tween.Play(holder,{Size=UDim2.fromOffset(250,52)},0.35,Enum.EasingStyle.Quint)
Shared.Overlay.CloseAll()else local size=self._fullSize or self.Size Tween.Play(
holder,{Size=UDim2.fromOffset(size.X,size.Y)},0.35,Enum.EasingStyle.Quint)Tween.
Play(self._miniBar,{BackgroundTransparency=1},0.2)task.delay(0.2,function()if
not self.Mini then self._miniBar.Visible=false end end)end return self end
function Window:SetBackground(spec)if self._bgLayer then self._bgLayer:Destroy()
self._bgLayer=nil end if type(spec)~='table'or(not spec.Image and not spec.
Gradient)then return self end local layer=Util.New('Frame',{Name='Background',
BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=0,Parent=self.Canvas})
self._bgLayer=layer if spec.Gradient then local a,b=Util.ToColor(spec.Gradient[1
])or Color3.new(0,0,0),Util.ToColor(spec.Gradient[2])or Color3.new(0,0,0)local g
=Util.New('Frame',{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),
ZIndex=0,Parent=layer})Util.Gradient(g,ColorSequence.new(a,b),nil,spec.Rotation
or 90)end if spec.Image then local img=Util.New('ImageLabel',{
BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ScaleType=Enum.ScaleType.Crop
,ImageTransparency=1,ZIndex=0,Parent=layer})loadImage(spec.Image,function(id)img
.Image=id Tween.Play(img,{ImageTransparency=0},0.5)end)end Util.New('Frame',{
Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),
BackgroundTransparency=1-(spec.Dim or 0.55),ZIndex=0,Parent=layer})return self
end function Window:_setupToggleButton()local mode=self.Options.ToggleButton if
mode==false then return end if mode==nil then if UIS.TouchEnabled and not UIS.
KeyboardEnabled then mode='Bubble'else return end end if mode=='Bubble'then self
:_buildBubble(true)else local ok,button=pcall(self.Library._topbarButton,self.
Library,self)if ok and button then self.TopbarButton=button else self:
_buildBubble(true)end end end function Window:_applyEconomy()local eco=self.
Library.Economy self._economy=eco if eco then self:SetBackdrop('None')if self.
_decor then self._decor.Visible=false end elseif self.BackdropPattern=='None'and
self.Library:GetSetting('Backdrop','Stars')~='None'then self:SetBackdrop(self.
Library:GetSetting('Backdrop','Stars'))if self._decor then self._decor.Visible=
true end end end function Window:_scrollKey(page)return'Scroll.'..self.Title..
'/'..page.Tab.Name..'/'..page.Name end function Window:_restoreScroll()for _,tab
in self.Tabs do for _,page in tab.Pages do local y=self.Library:GetSetting(self:
_scrollKey(page))if y and page.Frame then task.delay(0.15,function()page.Frame.
CanvasPosition=Vector2.new(0,y)end)end end end end function Window:_afterReady()
local Lib=self.Library local log=self.Options.Changelog if type(log)=='table'and
log.Version and Lib:GetSetting('Seen.'..self.Title)~=log.Version then Lib:
SetSetting('Seen.'..self.Title,log.Version)local notes={}for _,line in log.Notes
or log do if type(line)=='string'then table.insert(notes,'\u{2022}  '..line)end
end task.spawn(function()self:Dialog({Title=Locale.T('WhatsNew',log.Version),
Content=table.concat(notes,string.char(10)),Buttons={{Text=Locale.T('Ok'),Style=
'Primary'}}})end)end if self.Options.CheckUpdates~=false and Lib.VersionUrl then
Lib:CheckForUpdates()end if self.Options.Version and self.Options.VersionUrl
then Lib:CheckForUpdates(self.Options.VersionUrl,self.Options.Version,self.Title
)end end function Window:OpenNotifications()local Lib=self.Library Lib.Unread=0
Lib.NotificationsChanged:Fire()local items={}local history=Lib.
NotificationHistory for i=#history,math.max(1,#history-14),-1 do local n=history
[i]local ago=os.time()-n.Time local when=ago<60 and(ago..'s')or(ago<3600 and(ago
//60 ..'m')or(ago//3600 ..'h'))table.insert(items,{Text=(n.Title and(n.Title..
': ')or'')..(n.Content or''),Hint=when,Icon=({success='check-circle',warning=
'alert-triangle',error='x-circle'})[n.Type]or'info'})end if#items==0 then table.
insert(items,{Text=Locale.T('NoNotifications'),Icon='bell'})else table.insert(
items,{Separator=true})table.insert(items,{Text=Locale.T('ClearAll'),Icon=
'trash-2',Callback=function()table.clear(Lib.NotificationHistory)end})end Shared
.Overlay.Menu(items,{Anchor=self._bell,Align='End',Width=300})end function
Window:_focusables()local page=self.CurrentPage local list={}if not page then
return list end for _,section in page.Sections do if not section.Collapsed then
for _,el in section:AllElements()do local sec=el.Section local tabOk=not sec.
ParentSection or sec.ParentSection._activeTab==sec if el.Frame and el.Frame.
Parent and el._navActivate and tabOk and el:IsVisible()and not el:IsLocked()and
el.Frame.AbsoluteSize.Y>0 then table.insert(list,el)end end end end table.sort(
list,function(a,b)local ax,bx=a.Frame.AbsolutePosition.X,b.Frame.
AbsolutePosition.X if math.abs(ax-bx)>40 then return ax<bx end return a.Frame.
AbsolutePosition.Y<b.Frame.AbsolutePosition.Y end)return list end function
Window:_setFocus(el)if self._focusRing then self._focusRing:Destroy()self.
_focusRing=nil end self._focused=el if not el or not el.Frame then return end
local ring=Util.New('Frame',{Name='Focus',BackgroundTransparency=1,Size=UDim2.
new(1,4,1,4),Position=UDim2.fromOffset(-2,-2),ZIndex=40,Parent=el.Frame})Util.
Corner(7,ring)local stroke=Util.Stroke(ring,nil,1.5)Theme.Paint(stroke,{Color=
'Accent'})self._focusRing=ring if el.Section and el.Section.Page then el.Section
.Page:ScrollTo(el.Frame)end end function Window:_bindNavigation()local up={[Enum
.KeyCode.Up]=-1,[Enum.KeyCode.DPadUp]=-1,[Enum.KeyCode.Down]=1,[Enum.KeyCode.
DPadDown]=1}local side={[Enum.KeyCode.Left]=-1,[Enum.KeyCode.DPadLeft]=-1,[Enum.
KeyCode.Right]=1,[Enum.KeyCode.DPadRight]=1}local activate={[Enum.KeyCode.Return
]=true,[Enum.KeyCode.Space]=true,[Enum.KeyCode.ButtonA]=true}self.Maid:Connect(
UIS.InputBegan,function(input)if not self._isOpen or self.Mini or UIS:
GetFocusedTextBox()or Shared.KeybindListening or self._palette then return end
local key=input.KeyCode local list if up[key]then list=self:_focusables()if#list
==0 then return end local i=table.find(list,self._focused)or(up[key]>0 and 0 or#
list+1)i=math.clamp(i+up[key],1,#list)self:_setFocus(list[i])elseif side[key]and
self._focused then if self._focused._navAdjust then self._focused:_navAdjust(
side[key])end elseif activate[key]and self._focused and self._focused.Frame and
self._focused.Frame.Parent then if key==Enum.KeyCode.Space and not self._focused
.Frame then return end self._focused:_navActivate()elseif key==Enum.KeyCode.Tab
or key==Enum.KeyCode.ButtonR1 or key==Enum.KeyCode.ButtonL1 then local back=key
==Enum.KeyCode.ButtonL1 or UIS:IsKeyDown(Enum.KeyCode.LeftShift)local visible={}
for _,tab in self.Tabs do if tab.Visible then table.insert(visible,tab)end end
table.sort(visible,function(a,b)return(a.Order or 0)<(b.Order or 0)end)local i=
table.find(visible,self.CurrentTab)or 1 i=(i-1+(back and-1 or 1))%#visible+1
self:SelectTab(visible[i])self:_setFocus(nil)elseif key==Enum.KeyCode.ButtonB
then if#Shared.Overlay.Stack>0 then Shared.Overlay.Stack[#Shared.Overlay.Stack]:
Close()else self:Close()end end end)self.Maid:Connect(UIS.InputChanged,function(
input)if input.UserInputType==Enum.UserInputType.MouseMovement and self.
_focusRing then self:_setFocus(nil)end end)self.PageChanged:Connect(function()
self:_setFocus(nil)end)end function Window:GetTab(name)for _,tab in self.Tabs do
if tab.Name==name or tab==name then return tab end end return nil end function
Window:GetTabs()return table.clone(self.Tabs)end function Window:SelectTab(which
)local tab=type(which)=='table'and which or self:GetTab(which)if type(which)==
'number'then tab=self.Tabs[which]end if not tab then return self end local page=
tab._lastPage if not page then for _,p in tab.Pages do if not p.Hidden then page
=p break end end end page=page or tab:_defaultPage()self:_selectPage(page)return
self end function Window:_selectPage(page,fromBack)local tab=page.Tab local
previous=self.CurrentPage if previous==page then return end if previous and not
fromBack and page.Hidden then table.insert(self._history,previous)elseif not
page.Hidden then table.clear(self._history)end local oldTab=self.CurrentTab self
.CurrentTab,self.CurrentPage=tab,page tab._lastPage=not page.Hidden and page or
tab._lastPage if previous and previous.Frame then previous.Frame.Visible=false
end page:_ensureMounted()local frame=page.Frame frame.Visible=true if Tween.
Speed>0 and self.State~='Loading'then local dir=1 if oldTab and oldTab~=tab and(
tab.Order or 0)<(oldTab.Order or 0)then dir=-1 end if fromBack then frame.
Position=UDim2.fromOffset(-16,0)else frame.Position=UDim2.fromOffset(0,14*dir)
end Tween.Play(frame,{Position=UDim2.fromOffset(0,0)},0.42,Enum.EasingStyle.
Quint)for i,section in page.Sections or{}do local stroke=section.Stroke if
stroke then stroke.Transparency=1 task.delay(0.035*i,function()Tween.Play(stroke
,{Transparency=0},0.4)end)end end end if oldTab~=tab then if oldTab then self:
_paintTab(oldTab,true)end self:_paintTab(tab,true)self.TabChanged:Fire(tab,
oldTab)tab.Selected:Fire()end page.Selected:Fire()self.PageChanged:Fire(page,
previous)self:_refreshHeader()local title=self._title if title and previous and
Tween.Speed>0 and self.State~='Loading'then local rest=title.Position title.
TextTransparency=1 title.Position=rest+UDim2.fromOffset(10,0)Tween.Play(title,{
TextTransparency=0,Position=rest},0.4,Enum.EasingStyle.Quint)if self._desc then
self._desc.TextTransparency=1 Tween.Play(self._desc,{TextTransparency=0},0.5)end
end if self.State=='Ready'then self:_saveState()end end function Window:Back()
local last=table.remove(self._history)if last then self:_selectPage(last,true)
elseif self.CurrentPage and self.CurrentPage.Hidden then self:SelectTab(self.
CurrentTab)end return self end function Window:_refreshHeader()local tab,page=
self.CurrentTab,self.CurrentPage if not tab then return end local inner=page and
page.Hidden self._back.Visible=inner==true local x=inner and 42 or 18 self.
_title.Position=UDim2.fromOffset(x,(tab.Description or(inner and page.
Description))and 10 or 18)self._desc.Position=UDim2.fromOffset(x,31)self._title.
Text=inner and(tab.Name..'  \u{203a}  '..page.Name)or tab.Name local d=inner and
page.Description or tab.Description self._desc.Text=d or''self._desc.Visible=d~=
nil self:_refreshPills()end function Window:_refreshPills()local tab=self.
CurrentTab for _,c in self._pills:GetChildren()do if c:IsA('GuiObject')then c:
Destroy()end end local visible={}for _,p in tab and tab.Pages or{}do if not p.
Hidden then table.insert(visible,p)end end local show=#visible>1 and not(self.
CurrentPage and self.CurrentPage.Hidden)self._pills.Visible=show self.Content.
Size=UDim2.new(1,0,1,show and-96 or-58)self.Content.Position=UDim2.fromOffset(0,
show and 96 or 58)if not show then return end for i,page in visible do local on=
page==self.CurrentPage local pill=Util.New('TextButton',{Text='',AutoButtonColor
=false,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,26),
LayoutOrder=i,ZIndex=4,Parent=self._pills})Util.Corner(13,pill)Util.Padding(pill
,0,12,0,12)Theme.Paint(pill,{BackgroundColor3=on and'Accent'or'Surface2'})local
stroke=Util.Stroke(pill)Theme.Paint(stroke,{Color=on and'Accent'or'Stroke'})
local holder=Util.New('Frame',{BackgroundTransparency=1,AutomaticSize=Enum.
AutomaticSize.X,Size=UDim2.fromScale(0,1),ZIndex=4,Parent=pill})Util.List(holder
,5,Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Left,Enum.
VerticalAlignment.Center)local iconId=Icons.Get(page.Icon)if iconId then local
img=Util.New('ImageLabel',{BackgroundTransparency=1,Image=iconId,Size=UDim2.
fromOffset(13,13),ZIndex=4,Parent=holder})Theme.Paint(img,{ImageColor3=on and
'AccentInk'or'TextDim'})end local label=Util.Label({Text=page.Name,FontFace=
Theme.Fonts.SemiBold,TextSize=12,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.
fromScale(0,1),LayoutOrder=2,ZIndex=4,Parent=holder})Theme.Paint(label,{
TextColor3=on and'AccentInk'or'TextDim'})pill.Activated:Connect(function()page:
Select()end)end end function Window:_enqueue(element)table.insert(self._queue,
element)local tab=element.Tab if tab then tab._total+=1 if self.Skeleton then
self.Skeleton:AddTab(tab)end end self._lastDeclare=os.clock()if not self.
_pumping then self._pumping=true task.defer(function()self:_pump()end)end end
function Window:_pump()self._pumping=true local budget=self.Loading.Budget or
0.004 while#self._queue>0 and not self._destroyed do local start=os.clock()while
#self._queue>0 and os.clock()-start<budget do local el=table.remove(self._queue,
1)if not el._destroyed then self._buildingTab=el.Tab local ok,err=pcall(function
()local section=el.Section section:_ensureMounted()el:_mount(section.Body,el.
_order)end)if not ok then warn("[Proximity] failed to build '"..tostring(el.Name
).."': "..tostring(err))if el.Tab then el.Tab._errors=(el.Tab._errors or 0)+1
end end end if el.Tab then el.Tab._done+=1 end end if self.Skeleton then local
tab=self._buildingTab self.Skeleton:Update(tab and(Locale.T('Building')..
' \u{b7} '..tab.Name..'  '..tab._done..'/'..tab._total)or nil)end task.wait()end
self._buildingTab=nil self._pumping=false self:_setStage()self:_checkReady()end
function Window:_setStage(text)if self.Skeleton then self.Skeleton:Update(text)
end if self.Loader and text then self.Loader:SetStage(text)end end function
Window:GetLoadProgress()local total,done=0,0 for _,tab in self.Tabs do total+=
tab._total done+=tab._done end local elements=total for _,t in self._tasks do
local weight=math.max(t.Weight,elements/#self._tasks)total+=weight done+=weight*
(t.Finished and 1 or t.Amount)end if total==0 then return 0 end return done/
total end function Window:_checkReady()if self.State~='Loading'or self._checking
then return end local function blocked()if#self._queue>0 then return true end
for _,t in self._tasks do if not t.Finished then return true end end if self.
_explicitReady then return false end if not self.AutoReady then return true end
return os.clock()-self._lastDeclare<0.2 end if blocked()then if self.AutoReady
or self._explicitReady then self._checking=true task.delay(0.1,function()self.
_checking=false self:_checkReady()end)end return end self:_finishLoading()end
function Window:_finishLoading()if self.State~='Loading'then return end self.
State='Finishing'self._declaring=false local Lib=self.Library task.spawn(
function()if self.Options.AutoLoad~=false and Lib:GetAutoLoad()and not Lib.
_autoLoaded then Lib._autoLoaded=true self:_setStage(Locale.T('ApplyingConfig')
..' \u{b7} '..Lib:GetAutoLoad())Lib:LoadAutoConfig()Lib.CurrentConfig=Lib:
GetAutoLoad()end local started=(self.Skeleton and self.Skeleton.Started)or(self.
Loader and self.Loader.Started)local elapsed=started and(os.clock()-started)or 0
local wait=(self.Loading.MinTime or 0)-elapsed if wait>0 and Tween.Speed>0 then
task.wait(wait)end self:_reveal()end)end function Window:_reveal(force)if self.
State=='Ready'then return end self.State='Ready'self._declaring=false local Lib=
self.Library Lib._autoSaveArmed=true local saved=Lib:GetSetting('Window.'..self.
Title)if type(saved)=='table'and saved.Tab and not self._restoredTab then self.
_restoredTab=true local tab=self:GetTab(saved.Tab)if tab then self:SelectTab(tab
)end end local function rise()local page=self.CurrentPage if page and page.Frame
and Tween.Speed>0 then page.Frame.Position=UDim2.fromOffset(0,10)Tween.Play(page
.Frame,{Position=UDim2.fromOffset(0,0)},0.6,Enum.EasingStyle.Quint)for i,section
in page.Sections do local frame=section.Frame if frame then local stroke=section
.Stroke if stroke then stroke.Transparency=1 task.delay(0.05*i,function()Tween.
Play(stroke,{Transparency=0},0.5)end)end end end end end if self.Loader then
local loader=self.Loader self.Loader=nil loader:Finish(function(point)self:Open(
{From=point})rise()end)elseif self.Skeleton then local skeleton=self.Skeleton
self.Skeleton=nil if force then skeleton.Stage.Text=Locale.T('Building')..
'\u{2026}'end skeleton:Finish(rise)else rise()end self:_restoreScroll()self.
Ready:Fire()Lib.WindowReady:Fire(self)task.delay(1.4,function()self:_afterReady(
)end)end function Window:SetReady()self._explicitReady=true self:_checkReady()
return self end Window.Finish=Window.SetReady Window.Init=Window.SetReady
function Window:IsReady()return self.State=='Ready'end function Window:OnReady(
fn)if self.State=='Ready'then task.spawn(fn)return{Disconnect=function()end}end
return self.Ready:Once(fn)end function Window:WaitUntilReady(timeout)if self.
State~='Ready'then self.Ready:Wait(timeout)end return self.State=='Ready'end
function Window:Task(name,weight)local window=self local t={Name=name,Weight=
weight or 10,Amount=0,Finished=false}function t:Progress(p)self.Amount=math.
clamp(p,0,1)window:_setStage(self.Name..' \u{b7} '..math.floor(self.Amount*100)
..'%')return self end t.SetProgress=t.Progress function t:SetText(text)self.Name
=text window:_setStage(text)return self end function t:Done()self.Finished,self.
Amount=true,1 window:_setStage()window:_checkReady()return self end t.Complete=t
.Done function t:Fail(reason)warn("[Proximity] task '"..tostring(self.Name)..
"' failed: "..tostring(reason))self.Failed=reason return self:Done()end table.
insert(self._tasks,t)self:_setStage(name)return t end function Window:Step(name,
fn,weight)local t=self:Task(name,weight)task.spawn(function()local ok,err=pcall(
fn,t)if ok then t:Done()else t:Fail(err)end end)return t end function Window:
_anchorPoint()local target=self.TopbarButton or self.Bubble if target and target
.Parent then return target.AbsolutePosition+target.AbsoluteSize/2-Shared.Gui.
Windows.AbsolutePosition end return nil end function Window:Open(options)if self
._isOpen or self._destroyed then return self end self._isOpen=true local holder=
self.Holder holder.Visible=true self._modal.Visible=self.Options.UnlockMouse~=
false local rest=self._restPosition or holder.Position self._restPosition=rest
local from=options and options.From local style=from and'Planet'or self:
GetAnimation()self._animating=true Motion.Play(self,style,true,rest,{From=from
or self:_anchorPoint()},function()self._animating=false end)self.Opened:Fire()
return self end function Window:Close()if not self._isOpen then return self end
self._isOpen=false self._modal.Visible=false Shared.Overlay.CloseAll()Shared.
Overlay.HideTooltip()local holder=self.Holder if not self._animating then self.
_restPosition=holder.Position end self._animating=true Motion.Play(self,self:
GetAnimation(),false,self._restPosition,{From=self:_anchorPoint()},function()
self._animating=false if not self._isOpen and holder.Parent then holder.Visible=
false holder.Position=self._restPosition or holder.Position end end)self:
_afterClose()return self end Window.Minimize=Window.Close Window.Hide=Window.
Close Window.Show=Window.Open function Window:Toggle()if self._isOpen then
return self:Close()end return self:Open()end function Window:SetOpen(open)return
open and self:Open()or self:Close()end function Window:IsOpen()return self.
_isOpen end function Window:SetAnimation(style)self.Library:SetSetting(
'OpenAnimation',style)return self end function Window:GetAnimation()local style=
self.Library:GetSetting('OpenAnimation',self.Options.Animation or'Planet')if
style~='Planet'and style~='None'and not Motion.Has(style)then style='Planet'end
return style end function Window:_afterClose()self.Closed:Fire()local Lib=self.
Library if Lib.Dirty and Lib.CurrentConfig and not self._dirtyNoticed then self.
_dirtyNoticed=true Lib:Notify({Title=Locale.T('Unsaved'),Content=Locale.T(
'UnsavedHint',Lib.CurrentConfig),Type='warning',Duration=6,Actions={{Text=Locale
.T('Save'),Callback=function()Lib:QuickSave(self)end}}})elseif self.Options.
HiddenHint~=false and not self._hintShown then self._hintShown=true Lib:Notify({
Content=Locale.T('Hidden',Keys.Display(self.Keybind)),Duration=3})end return
self end function Window:SetScale(value)if value=='Auto'or value==nil then self.
_autoScale=true local view=workspace.CurrentCamera.ViewportSize value=math.min(1
,(view.X-40)/self.Size.X,(view.Y-40)/self.Size.Y)value=math.max(value,0.5)else
self._autoScale=false value=math.clamp(tonumber(value)or 1,0.5,2)end self.
_scaleValue=value self._uiScale.Scale=value Shared.Scale=value Shared.Overlay.
SetScale(value)return self end function Window:GetScale()return self._scaleValue
or 1 end function Window:SetSize(size,keepScale)if typeof(size)=='UDim2'then
size=Vector2.new(size.X.Offset,size.Y.Offset)end self.Size=Vector2.new(math.max(
size.X,self.MinSize.X),math.max(size.Y,self.MinSize.Y))self.Holder.Size=UDim2.
fromOffset(self.Size.X,self.Size.Y)if self._autoScale and not keepScale then
self:SetScale('Auto')end return self end function Window:GetSize()return self.
Size end function Window:SetPosition(pos)if typeof(pos)=='Vector2'then pos=UDim2
.fromOffset(pos.X,pos.Y)end self.Holder.Position=pos return self end function
Window:Center()self.Holder.Position=UDim2.fromScale(0.5,0.5)return self end
function Window:SetTitle(text)self.Title=text self._titleLabel.Text=text return
self end function Window:SetSubtitle(text)self.Subtitle=text self._subLabel.Text
=text return self end function Window:SetKeybind(key)self.Keybind=Keys.
Normalize(key)return self end Window.SetMenuKey=Window.SetKeybind function
Window:GetKeybind()return self.Keybind end function Window:SetTransparency(value
)self.GlassTransparency=math.clamp(tonumber(value)or 0,0,0.4)if self._isOpen
then self.Canvas.GroupTransparency=self.GlassTransparency self.Plate.
BackgroundTransparency=self.GlassTransparency end return self end function
Window:SetRim(enabled)self.RimEnabled=enabled and true or false Tween.Play(self.
_rim,{Transparency=(self.RimEnabled and self._isOpen)and 0 or 1},0.3)return self
end function Window:SetDraggable(value)self.Options.Draggable=value return self
end function Window:_bindInput()local Lib=self.Library self.Maid:Connect(UIS.
InputBegan,function(input,processed)if UIS:GetFocusedTextBox()or Shared.
KeybindListening then return end local name=Keys.FromInput(input)if name and
Keys.MatchesCombo(self.Keybind,name)and string.sub(name,1,2)~='MB'then self:
Toggle()return end if not self._isOpen then return end local ctrl=UIS:IsKeyDown(
Enum.KeyCode.LeftControl)or UIS:IsKeyDown(Enum.KeyCode.RightControl)if ctrl and
input.KeyCode==Enum.KeyCode.K then self:OpenSearch()elseif ctrl and input.
KeyCode==Enum.KeyCode.Z then Lib:Undo()elseif ctrl and input.KeyCode==Enum.
KeyCode.Y then Lib:Redo()elseif ctrl and input.KeyCode==Enum.KeyCode.S then Lib:
QuickSave(self)end end)end function Window:Command(options,callback)if type(
options)=='string'then options={Name=options,Callback=callback}end table.insert(
self._commands,options)return options end Window.AddCommand=Window.Command
function Window:Notify(options)return self.Library:Notify(options)end function
Window:GetElements()local out={}for _,tab in self.Tabs do for _,el in tab:
GetElements()do table.insert(out,el)end end return out end function Window:Find(
name)for _,el in self:GetElements()do if el.Name==name or el.Flag==name then
return el end end return nil end function Window:Destroy()if self._destroyed
then return end self._destroyed=true if self.Skeleton then self.Skeleton:
Destroy()end for _,tab in table.clone(self.Tabs)do for _,el in tab:GetElements()
do pcall(el.Destroy,el)end end self.Maid:Clean()local list=self.Library.Windows
local i=table.find(list,self)if i then table.remove(list,i)end end return Window
end function __DARKLUA_BUNDLE_MODULES.A()local v=__DARKLUA_BUNDLE_MODULES.cache.
A if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.A=v end return v
.c end end do local function __modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()
local Tween=__DARKLUA_BUNDLE_MODULES.d()local Env=__DARKLUA_BUNDLE_MODULES.e()
local Theme=__DARKLUA_BUNDLE_MODULES.g()local Icons=__DARKLUA_BUNDLE_MODULES.i()
local Locale=__DARKLUA_BUNDLE_MODULES.j()__DARKLUA_BUNDLE_MODULES.k()local UIS=
Env.Service('UserInputService')return function(Window)local function modal(self,
width,height)local layer=Util.New('TextButton',{Name='Modal',Text='',
AutoButtonColor=false,BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=
1,Size=UDim2.fromScale(1,1),ZIndex=80,Parent=self.Canvas})Tween.Play(layer,{
BackgroundTransparency=0.45},0.18)local box=Util.New('Frame',{AnchorPoint=
Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.52),Size=UDim2.fromOffset(
width,height or 0),AutomaticSize=height and Enum.AutomaticSize.None or Enum.
AutomaticSize.Y,ZIndex=81,Parent=layer})Util.Corner(10,box)Theme.Paint(box,{
BackgroundColor3='Elevated'})Theme.Paint(Util.Stroke(box),{Color='StrokeHi'})
local scale=Util.New('UIScale',{Scale=0.96,Parent=box})Tween.Play(scale,{Scale=1
},0.25,Enum.EasingStyle.Back)Tween.Play(box,{Position=UDim2.fromScale(0.5,0.5)},
0.25)local closed=false local function close()if closed then return end closed=
true Tween.Play(layer,{BackgroundTransparency=1},0.15)Tween.Play(scale,{Scale=
0.97},0.15)box.Visible=false task.delay(0.16,function()layer:Destroy()end)end
return layer,box,close end local function zfix(root,base)for _,d in root:
GetDescendants()do if d:IsA('GuiObject')then d.ZIndex=math.max(d.ZIndex,base)end
end end function Window:Dialog(options)options=options or{}local layer,box,close
=modal(self,options.Width or 340)Util.Padding(box,18,18,16,18)Util.List(box,10)
local title=Util.Label({Text=options.Title or'',FontFace=Theme.Fonts.SemiBold,
TextSize=16,AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,LayoutOrder=1,
Parent=box})Theme.Paint(title,{TextColor3='Text'})if options.Content then local
content=Util.Label({Text=options.Content,FontFace=Theme.Fonts.Regular,TextSize=
13,RichText=true,AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,LineHeight=
1.1,LayoutOrder=2,Parent=box})Theme.Paint(content,{TextColor3='TextDim'})end if
options.Build then Util.SafeCall(options.Build,box)end local row=Util.New(
'Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,32),LayoutOrder=10,Parent
=box})Util.List(row,8,Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.
Right,Enum.VerticalAlignment.Center)local result=nil local thread=coroutine.
running()local buttons=options.Buttons or{{Text=Locale.T('Ok'),Style='Primary'}}
local function finish(i)if result~=nil then return end result=i close()local b=
buttons[i]if b and b.Callback then Util.SafeCall(b.Callback)end if coroutine.
status(thread)=='suspended'then task.spawn(thread,i)end end for i,b in buttons
do local primary=b.Style=='Primary'local danger=b.Style=='Danger'local button=
Util.New('TextButton',{Text=b.Text or b[1]or'',FontFace=Theme.Fonts.SemiBold,
TextSize=13,AutoButtonColor=false,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.
fromOffset(0,30),LayoutOrder=i,Parent=row})Util.Corner(6,button)Util.Padding(
button,0,14,0,14)Theme.Paint(button,{BackgroundColor3=primary and'Accent'or(
danger and'Risky'or'Surface3'),TextColor3=(primary or danger)and'AccentInk'or
'Text'})if danger then Theme.Paint(button,{TextColor3=Color3.new(1,1,1)})end
Theme.Paint(Util.Stroke(button),{Color=primary and'Accent'or(danger and'Risky'or
'Stroke')})button.Activated:Connect(function()finish(i)end)end layer.Activated:
Connect(function()if options.Dismissable~=false then finish(0)end end)local esc=
UIS.InputBegan:Connect(function(input)if input.KeyCode==Enum.KeyCode.Escape then
finish(0)end end)layer.Destroying:Connect(function()esc:Disconnect()end)zfix(
layer,82)if options.Async then return finish end if coroutine.isyieldable()then
return coroutine.yield()end return nil end function Window:Confirm(options)if
type(options)=='string'then options={Title=options}end options=options or{}local
index=self:Dialog({Title=options.Title or Locale.T('Confirm'),Content=options.
Content,Buttons={{Text=options.CancelText or Locale.T('Cancel')},{Text=options.
ConfirmText or Locale.T('Confirm'),Style=options.Danger and'Danger'or'Primary'}}
})return index==2 end function Window:Prompt(options)if type(options)=='string'
then options={Title=options}end options=options or{}local box local index=self:
Dialog({Title=options.Title,Content=options.Content,Build=function(parent)box=
Util.New('TextBox',{Text=options.Default or'',PlaceholderText=options.
Placeholder or'',ClearTextOnFocus=false,FontFace=Theme.Fonts.Medium,TextSize=13,
TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,0,0,32),LayoutOrder=5,
Parent=parent})Util.Corner(6,box)Util.Padding(box,0,10,0,10)Theme.Paint(box,{
BackgroundColor3='Surface2',TextColor3='Text',PlaceholderColor3='TextMute'})
Theme.Paint(Util.Stroke(box),{Color='StrokeHi'})task.defer(function()box:
CaptureFocus()end)end,Buttons={{Text=Locale.T('Cancel')},{Text=options.
ConfirmText or Locale.T('Ok'),Style='Primary'}}})if index==2 and box then return
box.Text end return nil end function Window:OpenSearch(query)if self._palette
then return self end self:Open()local Lib=self.Library local layer,box,close=
modal(self,460,340)box.Position=UDim2.new(0.5,0,0,40)box.AnchorPoint=Vector2.
new(0.5,0)self._palette=true local input=Util.New('TextBox',{Text=query or'',
PlaceholderText=Locale.T('SearchHint'),ClearTextOnFocus=false,FontFace=Theme.
Fonts.Medium,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,
BackgroundTransparency=1,Size=UDim2.new(1,-50,0,46),Position=UDim2.fromOffset(42
,0),Parent=box})Theme.Paint(input,{TextColor3='Text',PlaceholderColor3=
'TextMute'})local icon=Util.New('ImageLabel',{BackgroundTransparency=1,Image=
Icons.Get('search')or'',Size=UDim2.fromOffset(16,16),Position=UDim2.fromOffset(
16,15),Parent=box})Theme.Paint(icon,{ImageColor3='TextDim'})local line=Util.New(
'Frame',{Size=UDim2.new(1,0,0,1),Position=UDim2.fromOffset(0,46),BorderSizePixel
=0,Parent=box})Theme.Paint(line,{BackgroundColor3='Stroke'})local list=Util.New(
'ScrollingFrame',{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,
1,-74),Position=UDim2.fromOffset(0,50),CanvasSize=UDim2.new(),
AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,Parent=box})Util.
Padding(list,4,8,4,8)Util.List(list,2)local foot=Util.Label({Text=
'\u{2191}\u{2193}  '..Locale.T('Elements')..'   \u{23ce}  open   esc  close',
FontFace=Theme.Fonts.Mono,TextSize=10,Size=UDim2.new(1,-24,0,22),Position=UDim2.
new(0,12,1,-24),Parent=box})Theme.Paint(foot,{TextColor3='TextMute'})local
results,selected,rows={},1,{}local function collect(q)local out={}for _,cmd in
self._commands do local s=Util.Fuzzy(q,cmd.Name)if s then table.insert(out,{Kind
=Locale.T('Commands'),Text=cmd.Name,Sub=cmd.Hint,Icon=cmd.Icon or'circle-dot',
Score=s+5,Run=function()Util.SafeCall(cmd.Callback)end})end end for _,tab in
self.Tabs do local s=Util.Fuzzy(q,tab.Name)if s then table.insert(out,{Kind=
Locale.T('Tabs'),Text=tab.Name,Icon=tab.Icon or'layout-grid',Score=s+2,Run=
function()tab:Select()end})end end for _,el in Lib.AllElements do if el.Window==
self and el.Section and not el.Parent and el.Name and el.Name~=''and el.Type~=
'Divider'and el.Type~='Spacer'and el.Type~='Label'and el.Type~='Paragraph'then
local parent=el.Section.ParentSection local hay=el.Name..' '..(el.Description or
'')..' '..(el.Section.Name or'')..' '..(parent and parent.Name or'')local s=Util
.Fuzzy(q,hay)if s then local value=''if el.Type=='Toggle'then value=el.Value and
'ON'or'OFF'elseif el.GetText then value=el:GetText()end table.insert(out,{Kind=
Locale.T('Elements'),Text=el.Name,Sub=el:GetPath(),Value=value,Icon=Lib:
IsFavorite(el)and'star'or'corner-down-right',Score=s,Run=function()el:Focus()end
})end end end table.sort(out,function(a,b)return a.Score>b.Score end)while#out>
40 do table.remove(out)end return out end local function paint()for i,row in
rows do Theme.Paint(row,{BackgroundColor3='Surface3'})row.BackgroundTransparency
=i==selected and 0 or 1 end end local function render()for _,c in list:
GetChildren()do if c:IsA('GuiObject')then c:Destroy()end end rows={}results=
collect(input.Text)selected=1 if#results==0 then local empty=Util.Label({Text=
Locale.T('NoResults'),FontFace=Theme.Fonts.Regular,TextSize=13,TextXAlignment=
Enum.TextXAlignment.Center,Size=UDim2.new(1,0,0,60),Parent=list})Theme.Paint(
empty,{TextColor3='TextMute'})end for i,r in results do local row=Util.New(
'TextButton',{Text='',AutoButtonColor=false,Size=UDim2.new(1,0,0,38),LayoutOrder
=i,Parent=list})Util.Corner(6,row)local img=Util.New('ImageLabel',{
BackgroundTransparency=1,Image=Icons.Get(r.Icon)or'',Size=UDim2.fromOffset(15,15
),Position=UDim2.new(0,10,0.5,-7),Parent=row})Theme.Paint(img,{ImageColor3=
'TextDim'})local t=Util.Label({Text=r.Text,FontFace=Theme.Fonts.Medium,TextSize=
13,Size=UDim2.new(1,-150,0,16),Position=UDim2.fromOffset(34,r.Sub and 4 or 11),
TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})Theme.Paint(t,{TextColor3=
'Text'})if r.Sub then local sub=Util.Label({Text=r.Sub,FontFace=Theme.Fonts.
Regular,TextSize=11,Size=UDim2.new(1,-150,0,13),Position=UDim2.fromOffset(34,21)
,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})Theme.Paint(sub,{TextColor3=
'TextMute'})end local kind=Util.Label({Text=(r.Value and r.Value~=''and(r.Value
..'  \u{b7}  ')or'')..r.Kind,FontFace=Theme.Fonts.Mono,TextSize=10,
TextXAlignment=Enum.TextXAlignment.Right,Size=UDim2.new(0,130,1,0),Position=
UDim2.new(1,-140,0,0),TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})Theme.
Paint(kind,{TextColor3='TextMute'})row.MouseEnter:Connect(function()selected=i
paint()end)row.Activated:Connect(function()close()self._palette=nil r.Run()end)
rows[i]=row end zfix(layer,82)paint()end input:GetPropertyChangedSignal('Text'):
Connect(render)local conn=UIS.InputBegan:Connect(function(io)if io.KeyCode==Enum
.KeyCode.Down then selected=math.min(selected+1,#results)paint()elseif io.
KeyCode==Enum.KeyCode.Up then selected=math.max(selected-1,1)paint()elseif io.
KeyCode==Enum.KeyCode.Return then local r=results[selected]close()self._palette=
nil if r then r.Run()end elseif io.KeyCode==Enum.KeyCode.Escape then close()self
._palette=nil end end)layer.Activated:Connect(function()close()self._palette=nil
end)layer.Destroying:Connect(function()conn:Disconnect()self._palette=nil end)
render()task.defer(function()input:CaptureFocus()end)return self end Window.
Search=Window.OpenSearch function Window:Tour(steps,options)options=options or{}
local Lib=self.Library if options.Key and Lib:GetSetting('Tour.'..options.Key)
and not options.Force then return self end task.spawn(function()self:
WaitUntilReady(15)for i,step in steps do local target=step.Target if type(target
)=='table'and target.Focus then target:Focus()task.wait(0.35)target=target.Frame
elseif target=='search'then target=self.Sidebar and self.Sidebar:FindFirstChild(
'Search')elseif target=='config'then target=self._actions and self._actions:
FindFirstChild('Config')end local ring if typeof(target)=='Instance'and target:
IsA('GuiObject')then ring=Util.New('Frame',{BackgroundTransparency=1,Size=UDim2.
new(1,8,1,8),Position=UDim2.fromOffset(-4,-4),ZIndex=79,Parent=target})Util.
Corner(8,ring)local stroke=Util.Stroke(ring,nil,2)Theme.Paint(stroke,{Color=
'Accent'})task.spawn(function()while ring.Parent do Tween.Await(stroke,{
Transparency=0.7},0.6,Enum.EasingStyle.Sine)Tween.Await(stroke,{Transparency=0},
0.6,Enum.EasingStyle.Sine)end end)end local index=self:Dialog({Title=string.
format('%d/%d  \u{b7}  %s',i,#steps,step.Title or''),Content=step.Text or step.
Content,Buttons={{Text=Locale.T('Cancel')},{Text=i==#steps and Locale.T('Ok')or
'\u{2192}',Style='Primary'}}})if ring then ring:Destroy()end if index~=2 then
break end end if options.Key then Lib:SetSetting('Tour.'..options.Key,true)end
end)return self end end end function __DARKLUA_BUNDLE_MODULES.B()local v=
__DARKLUA_BUNDLE_MODULES.cache.B if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.B=v end return v.c end end do local function 
__modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Env=
__DARKLUA_BUNDLE_MODULES.e()__DARKLUA_BUNDLE_MODULES.f()local Theme=
__DARKLUA_BUNDLE_MODULES.g()local Tween=__DARKLUA_BUNDLE_MODULES.d()local Locale
=__DARKLUA_BUNDLE_MODULES.j()__DARKLUA_BUNDLE_MODULES.k()Env.Service('Players')
Env.Service('Stats')Env.Service('UserInputService')return function(Window)local
T=Locale.T function Window:Home(options)options=options or{}local Lib=self.
Library local tab=self:Tab({Name=options.Name or'Home',Icon=options.Icon or
'home',Description=options.Description,Order=-100})tab.Button.LayoutOrder=-100
self.HomeTab=tab self._homeButton.Visible=true self:SelectTab(tab)local identity
=tab:FullSection({Name=''})local id=Lib:GetIdentity()identity:Card({Title=id.
DisplayName,Subtitle='@'..id.Name..(options.Status and('  \u{b7}  '..options.
Status)or''),Body=options.Welcome or('Proximity '..Lib.Version..'  \u{b7}  '..
Env.ExecutorName()),Image=id.Avatar,Badge=options.Badge,Height=72})local P=Lib.
Providers local session=tab:LeftSection({Name='Session',Icon='activity'})session
:StatGrid({Columns=2,Items={{Name='FPS',Value=P.FPS,Interval=0.5,Sparkline=true,
Accent=true},{Name='Ping',Value=P.Ping,Interval=0.5,Sparkline=true},{Name=
'Session',Value=P.Session,Interval=1},{Name='Players',Value=P.Players,Interval=2
},{Name='Device',Value=P.Device,Interval=30},{Name='Resolution',Value=P.
Resolution,Interval=5}}})local account=tab:RightSection({Name='Account',Icon=
'user'})account:StatGrid({Columns=2,Items={{Name='Account age',Value=P.
AccountAge,Interval=60},{Name='User ID',Value=P.UserId,Interval=60},{Name=
'Executor',Value=P.Executor,Interval=60},{Name='Version',Value=function()return
options.Version or Lib.Version end,Interval=60}}})local server=tab:RightSection(
{Name='Server',Icon='server'})server:StatGrid({Columns=2,Items={{Name='Place',
Value=P.PlaceId,Interval=60},{Name='Uptime',Value=P.ServerUptime,Interval=1}}})
server:Stat({Name='Job ID',Value=P.JobId,Interval=60})return tab end Window.
Dashboard=Window.Home function Window:SettingsTab(options)options=options or{}
local Lib=self.Library local window=self local tab=self:Tab({Name=options.Name
or T('Settings'),Icon=options.Icon or'settings',Description=options.Description,
Order=1000})tab.Button.LayoutOrder=1000 self.SettingsTabRef=tab self.
_settingsButton.Visible=true local look=tab:LeftSection({Name=T('Appearance'),
Icon='palette'})local themeDropdown=look:Dropdown({Name=T('Theme'),Icon='theme',
Values=Theme.List(),Default=Lib:GetSetting('Theme',Theme.Current),Save=false,
Callback=function(v)if v then Lib:SetTheme(v)end end})local accentPicker=look:
ColorPicker({Name=T('Accent'),Icon='accent',Default=Util.FromHex(Lib:GetSetting(
'Accent',''))or Theme.Get('Accent'),Save=false,Presets={Color3.fromRGB(255,255,
255),Color3.fromRGB(226,236,255),Color3.fromRGB(255,244,230),Color3.fromRGB(214,
214,220),Color3.fromRGB(205,222,240),Color3.fromRGB(200,255,230),Color3.fromRGB(
255,220,235),Color3.fromRGB(230,220,255)},Callback=function(c)Lib:SetAccent(c)
end})Theme.Changed:Connect(function(name)if Theme.Presets[name]then
themeDropdown:Set(name,true)end accentPicker:Set(Theme.Get('Accent'),true)end)
look:Slider({Name=T('Transparency'),Icon='transparency',Min=0,Max=40,Default=Lib
:GetSetting('Glass',0),Suffix='%',Save=false,Callback=function(v)Lib:SetSetting(
'Glass',v)window:SetTransparency(v/100)end})look:Dropdown({Name=T('Scale'),Icon=
'scale',Values={'Auto','75%','90%','100%','110%','125%','150%'},Default=(
function()local s=Lib:GetSetting('Scale','Auto')return s=='Auto'and'Auto'or(math
.floor(tonumber(s)*100+0.5)..'%')end)(),Save=false,Callback=function(v)if not v
then return end local value=v=='Auto'and'Auto'or tonumber(string.match(v,'%d+'))
/100 Lib:SetSetting('Scale',value)window:SetScale(value)end})look:Dropdown({Name
=T('Backdrop'),Icon='backdrop',Values={'Stars','Grid','Dots','None'},Default=Lib
:GetSetting('Backdrop','Stars'),Save=false,Callback=function(v)Lib:SetSetting(
'Backdrop',v)window:SetBackdrop(v or'None')end})look:Toggle({Name=T('EclipseRim'
),Icon='rim',Default=Lib:GetSetting('Rim',true),Save=false,Callback=function(v)
Lib:SetSetting('Rim',v)window:SetRim(v)end})look:Toggle({Name=T('Planet'),Icon=
'planet',Default=Lib:GetSetting('Decoration',true),Save=false,Callback=function(
v)Lib:SetSetting('Decoration',v)window:SetDecoration(v)end})look:Toggle({Name=T(
'ReducedMotion'),Icon='motion',Default=Lib:GetSetting('ReducedMotion',false),
Save=false,Callback=function(v)Lib:SetSetting('ReducedMotion',v)Tween.Speed=v
and 0 or 1 end})look:Dropdown({Name=T('OpenAnimation'),Icon='move',Values={
'Planet','Rise','Zoom','Drop','Slide','Swing','Wipe','Unfold','Scan','Glitch',
'Fade','None'},Display=function(v)return T('Anim'..v)end,Default=window:
GetAnimation(),Description=T('OpenAnimationHint'),Save=false,Callback=function(v
)if v and v~=window:GetAnimation()then window:SetAnimation(v)task.spawn(function
()window:Close()task.wait(0.5)window:Open()end)end end})look:Dropdown({Name=T(
'LoadingStyle'),Icon='loader',Values={'Planet','Orbit','Eclipse','Constellation'
,'Terminal','Skeleton','None'},Display=function(v)return T('Loading'..v)end,
Default=Lib:GetSetting('LoadingStyle','Planet'),Description=T('LoadingStyleHint'
),Save=false,Callback=function(v)if v then Lib:SetSetting('LoadingStyle',v)end
end})look:Dropdown({Name=T('Navigation'),Icon='sidebar',Values={'Sidebar','Rail'
},Display=function(v)return T(v)end,Default=window.Navigation,Save=false,
Callback=function(v)if v then Lib:SetSetting('Navigation',v)window:
SetNavigation(v)end end})look:Dropdown({Name=T('Font'),Icon='type',Values=Lib:
GetFonts(),Default=Lib:GetSetting('Font','Builder Sans'),Search=true,Save=false,
Callback=function(v)if v then task.spawn(function()if not Lib:SetFont(v)then Lib
:Notify({Content=T('FontFailed'),Type='warning',Duration=4})end end)end end})
look:Dropdown({Name=T('Density'),Icon='align-justify',Values={'Compact','Normal'
,'Comfortable','Touch'},Display=function(v)return T(v)end,Default=Lib.
DensityName,Save=false,Callback=function(v)if v then Lib:SetDensity(v)end end})
look:Dropdown({Name=T('ToggleStyle'),Icon='toggle-right',Values=Lib._classes.
Toggle.Styles,Default=Lib.ToggleStyle,Save=false,Callback=function(v)if v then
Lib:SetToggleStyle(v)end end})local bgSaved=Lib:GetSetting('Background')local
bgInput=look:Input({Name=T('BackgroundImage'),Icon='image',Placeholder=
'rbxassetid:// or https://',Default=type(bgSaved)=='table'and bgSaved.Image or''
,Finished=true,Save=false})local bgDim=look:Slider({Name=T('BackgroundDim'),Icon
='moon',Min=0,Max=90,Default=type(bgSaved)=='table'and math.floor((bgSaved.Dim
or 0.55)*100)or 55,Suffix='%',Save=false})local function applyBg()local image=
Util.Trim(bgInput:Get()or'')local spec=image~=''and{Image=image,Dim=bgDim:Get()/
100}or nil Lib:SetSetting('Background',spec or false)window:SetBackground(spec)
end bgInput:AddCallback(applyBg)bgDim:AddCallback(Util.Debounce(0.3,applyBg))
bgDim:DependsOn(bgInput,function(v)return v~=nil and v~=''end)local ui=tab:
LeftSection({Name=T('Interface'),Icon='layout-dashboard'})ui:Keybind({Name=T(
'MenuKey'),Icon='keyboard',Default=window.Keybind,Modes={'Press'},Mode='Press',
ShowInList=false,Save=false,Callback=function(key)Lib:SetSetting('MenuKey',key)
window:SetKeybind(key)end})local langs,flags={},{en='\u{1f1ec}\u{1f1e7}',ru=
'\u{1f1f7}\u{1f1fa}',de='\u{1f1e9}\u{1f1ea}',es='\u{1f1ea}\u{1f1f8}',fr=
'\u{1f1eb}\u{1f1f7}',uk='\u{1f1fa}\u{1f1e6}',pt='\u{1f1e7}\u{1f1f7}',tr=
'\u{1f1f9}\u{1f1f7}'}local codeByName={}for _,code in Locale.List()do local name
=Locale.Names[code]or code codeByName[name]=code table.insert(langs,name)end
local prefixes={}for name,code in codeByName do prefixes[name]=flags[code]end ui
:Dropdown({Name=T('Language'),Icon='language',Values=langs,Prefixes=prefixes,
Default=Locale.Names[Locale.Current],Save=false,Callback=function(v)if v and
codeByName[v]then Lib:SetLanguage(codeByName[v])end end})ui:Toggle({Name=T(
'Watermark'),Icon='watermark',Default=Lib:GetSetting('Watermark',true),Save=
false,Callback=function(v)Lib:SetSetting('Watermark',v)if Lib.WatermarkWidget
then Lib.WatermarkWidget:SetVisible(v)end end})ui:Toggle({Name=T('KeybindList'),
Icon='keybinds',Default=Lib:GetSetting('KeybindList',true),Save=false,Callback=
function(v)Lib:SetSetting('KeybindList',v)if Lib.KeybindListWidget then Lib.
KeybindListWidget:SetVisible(v)end end})ui:MultiDropdown({Name=T(
'WatermarkItems'),Icon='list-checks',Values=Lib.WatermarkItemNames,Default=Lib:
GetSetting('WatermarkItems',{'FPS','Ping','Time'}),Save=false,Callback=function(
list)Lib:SetSetting('WatermarkItems',list)if Lib.WatermarkWidget then Lib.
WatermarkWidget:SetItems(list)end end})ui:Toggle({Name=T('ShowInactive'),Icon=
'eye',Default=Lib:GetSetting('BindsInactive',false),Save=false,Callback=function
(v)Lib:SetSetting('BindsInactive',v)if Lib.KeybindListWidget then Lib.
KeybindListWidget:ShowInactive(v)end end})ui:Dropdown({Name=T('SortBinds'),Icon=
'arrow-up-down',Values={'Active','Name','Key'},Display=function(v)return T(
'Sort'..v)end,Default=Lib:GetSetting('BindsSort','Active'),Save=false,Callback=
function(v)if v then Lib:SetSetting('BindsSort',v)if Lib.KeybindListWidget then
Lib.KeybindListWidget.Refresh()end end end})ui:Dropdown({Name=T('NotifyPosition'
),Icon='notifications',Values={'TopRight','BottomRight','TopLeft','BottomLeft',
'TopCenter'},Default=Lib:GetSetting('NotifyPosition','BottomRight'),Save=false,
Callback=function(v)if v then Lib:SetSetting('NotifyPosition',v)Lib:
SetNotifyPosition(v)end end})local anon=ui:Toggle({Name=T('Anonymous'),Icon=
'anonymous',Description=T('AnonymousHint'),Default=Lib:GetSetting('Anonymous',
false),Save=false,Callback=function(v)Lib:SetSetting('Anonymous',v)Lib:
SetAnonymous(v)end})anon:Options(function(o)o:Input({Name=T('ShownName'),Default
=Lib:GetSetting('AnonymousName','Hidden'),Finished=true,Save=false,Callback=
function(v)Lib:SetSetting('AnonymousName',v)Lib:SetAnonymous(Lib.Anonymous,{Name
=v})end})end)local widgets=tab:RightSection({Name=T('Widgets'),Icon=
'layout-grid'})local function widgetToggle(name,icon,key,make)widgets:Toggle({
Name=T(name),Icon=icon,Default=Lib:GetSetting(key,false),Save=false,Callback=
function(v)Lib:SetSetting(key,v)local w=make()if w then w:SetVisible(v)end end})
if Lib:GetSetting(key,false)then task.defer(function()make():SetVisible(true)end
)end end widgetToggle('PlayerPanel','user','Widget.PlayerPanel',function()return
Lib:PlayerPanel()end)widgetToggle('Performance','activity','Widget.Perf',
function()return Lib:PerfGraph()end)widgetToggle('Stopwatch','timer',
'Widget.Stopwatch',function()return Lib:Stopwatch()end)widgets:Toggle({Name=T(
'AutoEconomy'),Icon='leaf',Description=T('AutoEconomyHint'),Default=Lib:
GetSetting('AutoEconomy',true),Save=false,Callback=function(v)Lib:SetSetting(
'AutoEconomy',v)if not v and Lib.Economy then Lib:SetEconomy(false)end end})
local editor=tab:RightSection({Name=T('ThemeEditor'),Icon='editor',Collapsible=
true,Collapsed=true})for _,token in{'Bg','Surface','Surface2','Stroke',
'StrokeHi','Text','TextDim','TextMute','Accent','AccentInk','Risky'}do editor:
ColorPicker({Name=token,Default=Theme.Get(token),Save=false,Callback=function(c)
Theme.SetToken(token,c,false)end})end editor:ButtonGroup({{Name=T('Export'),
Callback=function()Env.Clipboard(Theme.Export())Lib:Notify({Content=T('Copied'),
Type='success',Duration=2})end},{Name=T('Import'),Callback=function()task.spawn(
function()local text=window:Prompt({Title=T('Import'),Placeholder='{ \u{2026} }'
})if text and Theme.Import(text)then Lib:Notify({Content=T('Imported'),Type=
'success',Duration=2})end end)end}})local misc=tab:RightSection({Name=T('About')
,Icon='planet'})misc:Stat({Name='Proximity',Value='v'..Lib.Version,Icon='info'})
misc:Stat({Name=T('Executor'),Value=Env.ExecutorName(),Icon='code'})if options.
Tour then misc:Button({Name=T('ReplayTour'),Icon='tour',Callback=function()
window:Tour(options.Tour,{Force=true})end})end misc:Button({Name=T('Unload'),
Style='Danger',Icon='power',Confirm=T('UnloadConfirm'),Callback=function()Lib:
Unload()end})if options.Configs~=false then self:ConfigTab({Tab=tab})end return
tab end function Window:ConfigTab(options)options=options or{}local Lib=self.
Library local window=self local tab=options.Tab or self:Tab({Name=options.Name
or T('Configs'),Icon=options.Icon or'folder',Order=999})local section=tab:
RightSection({Name=T('Configs'),Icon='folder'})local nameInput=section:Input({
Name=T('ConfigName'),Icon='edit-3',Placeholder='legit',Save=false,Finished=true}
)local list list=section:Dropdown({Name=T('ConfigList'),Icon='configs',Values=
Lib:ListConfigs(),Save=false,Deletable=true,Search=true,OnDelete=function(name)
Lib:DeleteConfig(name)end,Callback=function(v)if v then nameInput:Set(v,true)end
end})local function selected()local n=Util.Trim(nameInput:Get()or'')if n==''then
n=list:Get()end return n end Lib.ConfigsChanged:Connect(function()list:
SetValues(Lib:ListConfigs(),true)end)section:ButtonGroup({{Name=T('Save'),Style=
'Primary',Callback=function()local name=selected()if not name or name==''then
return end task.spawn(function()if Lib:ConfigExists(name)and not window:Confirm(
{Title=T('Save'),Content=T('Overwrite',name)})then return end local ok=Lib:
SaveConfig(name)if ok then Lib.CurrentConfig=Util.SafeName(name)Lib:_setDirty(
false)list:Set(Util.SafeName(name),true)Lib:Notify({Title=T('Saved'),Content=
name,Type='success',Duration=2.5})end end)end},{Name=T('Load'),Callback=function
()local name=selected()if not name or not Lib:ConfigExists(name)then return end
task.spawn(function()local diff=Lib:DiffConfig(name)if#diff>0 then local lines={
}for i=1,math.min(#diff,8)do table.insert(lines,'\u{2022} '..diff[i].Flag)end if
#diff>8 then table.insert(lines,'\u{2026} +'..(#diff-8))end if not window:
Confirm({Title=T('Load')..' '..name,Content=T('Changes',#diff)..string.char(10)
..table.concat(lines,string.char(10))})then return end end Lib:LoadConfig(name)
Lib.CurrentConfig=Util.SafeName(name)Lib:_setDirty(false)Lib:Notify({Title=T(
'Loaded'),Content=name,Type='success',Duration=2.5})end)end}})section:
ButtonGroup({{Name=T('Export'),Callback=function()local text=Lib:ExportConfig(
list:Get())if text then Env.Clipboard(text)Lib:Notify({Content=T('Copied'),Type=
'success',Duration=2})end end},{Name=T('Import'),Callback=function()task.spawn(
function()local text=window:Prompt({Title=T('Import'),Placeholder=
'PRX1.\u{2026}'})if not text then return end local ok=Lib:ImportConfig(text,
selected()~=''and selected()or nil)Lib:Notify({Content=ok and T('Imported')or T(
'InvalidConfig'),Type=ok and'success'or'error',Duration=3})end)end}})section:
ButtonGroup({{Name=T('ShareCode'),Callback=function()task.spawn(function()local
code=Lib:ShareConfig(list:Get())if code then Env.Clipboard(code)Lib:Notify({
Title=T('ShareCode'),Content=T('CodeCopied',code),Type='success',Duration=6})
else Lib:Notify({Content=T('CodeFailed'),Type='error',Duration=4})end end)end},{
Name=T('ImportCode'),Callback=function()task.spawn(function()local code=window:
Prompt({Title=T('ImportCode'),Placeholder='AbC12'})if not code then return end
local ok=Lib:ImportCode(code,selected()~=''and selected()or nil)Lib:Notify({
Content=ok and T('Imported')or T('CodeInvalid'),Type=ok and'success'or'error',
Duration=3})end)end}})section:Toggle({Name=T('AutoLoad'),Icon='load',Default=Lib
:GetAutoLoad()~=nil,Save=false,Callback=function(v)Lib:SetAutoLoad(v and(list:
Get()or Lib.CurrentConfig)or nil)end})section:Toggle({Name=T('AutoSave'),Icon=
'save',Default=Lib:GetAutoSave()~=nil,Save=false,Callback=function(v)Lib:
SetAutoSave(v and(list:Get()or Lib.CurrentConfig)or nil)end})section:Label({Text
=T('Folder')..': '..Lib.Folder..'/configs',Color='TextMute',Icon='folder'})
return tab end end end function __DARKLUA_BUNDLE_MODULES.C()local v=
__DARKLUA_BUNDLE_MODULES.cache.C if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.C=v end return v.c end end do local function 
__modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Tween=
__DARKLUA_BUNDLE_MODULES.d()local Env=__DARKLUA_BUNDLE_MODULES.e()local Keys=
__DARKLUA_BUNDLE_MODULES.f()local Theme=__DARKLUA_BUNDLE_MODULES.g()local Icons=
__DARKLUA_BUNDLE_MODULES.i()local Locale=__DARKLUA_BUNDLE_MODULES.j()local
Shared=__DARKLUA_BUNDLE_MODULES.k()local UIS=Env.Service('UserInputService')
local RunService=Env.Service('RunService')return function(Lib)local function 
dock(frame,key,default)local saved=Lib:GetSetting('Dock.'..key)if type(saved)==
'table'then frame.AnchorPoint=Vector2.new(saved[1],saved[2])frame.Position=UDim2
.new(saved[1],saved[3],saved[2],saved[4])elseif default then frame.AnchorPoint=
default.AnchorPoint frame.Position=default.Position end local dragging,start,
startPos frame.InputBegan:Connect(function(input)if input.UserInputType==Enum.
UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging,start=true,Vector2.new(input.Position.X,input.Position.Y)startPos=frame
.AbsolutePosition-frame.Parent.AbsolutePosition frame.AnchorPoint=Vector2.new(0,
0)frame.Position=UDim2.fromOffset(startPos.X,startPos.Y)end end)Shared.Maid:
Connect(UIS.InputChanged,function(input)if dragging and(input.UserInputType==
Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.
Touch)then local p=startPos+Vector2.new(input.Position.X,input.Position.Y)-start
frame.Position=UDim2.fromOffset(p.X,p.Y)end end)Shared.Maid:Connect(UIS.
InputEnded,function(input)if not dragging or(input.UserInputType~=Enum.
UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch)
then return end dragging=false local view=frame.Parent.AbsoluteSize local pos,
size=frame.AbsolutePosition-frame.Parent.AbsolutePosition,frame.AbsoluteSize
local cx,cy=(pos.X+size.X/2)/view.X,(pos.Y+size.Y/2)/view.Y local ax=cx<0.33 and
0 or(cx>0.66 and 1 or 0.5)local ay=cy<0.33 and 0 or(cy>0.66 and 1 or 0.5)local
ox=ax==0 and 12 or(ax==1 and-12 or 0)local oy=ay==0 and 12 or(ay==1 and-12 or 0)
local nearX=pos.X<60 or pos.X+size.X>view.X-60 or ax==0.5 local nearY=pos.Y<60
or pos.Y+size.Y>view.Y-60 if not nearX then ax,ox=0,pos.X end if not nearY then
ay,oy=0,pos.Y end frame.AnchorPoint=Vector2.new(ax,ay)local target=UDim2.new(ax,
ox,ay,oy)Tween.Play(frame,{Position=target},0.25,Enum.EasingStyle.Back)Lib:
SetSetting('Dock.'..key,{ax,ay,ox,oy})end)end Lib.Dock=function(_,frame,key,
default)dock(frame,key,default)end local function panel(name,parent)local frame=
Util.New('Frame',{Name=name,AutomaticSize=Enum.AutomaticSize.XY,Size=UDim2.new()
,Active=true,Parent=parent or Shared.Gui.Widgets})Util.Corner(8,frame)Theme.
Paint(frame,{BackgroundColor3='Bg'})frame.BackgroundTransparency=0.08 Theme.
Paint(Util.Stroke(frame),{Color='Stroke'})Shared.Overlay.Shadow(frame,0.6,16)
return frame end local holder=Util.New('Frame',{Name='Notifications',
BackgroundTransparency=1,Size=UDim2.new(0,300,1,-24),ZIndex=90,Parent=Shared.Gui
.Root})local layout=Util.List(holder,8)local notifyScale=Util.New('UIScale',{
Parent=holder})Lib.NotificationHistory={}local active={}function Lib:
SetNotifyPosition(position)local map={TopRight={Vector2.new(1,0),UDim2.new(1,-12
,0,12),Enum.VerticalAlignment.Top},BottomRight={Vector2.new(1,1),UDim2.new(1,-12
,1,-12),Enum.VerticalAlignment.Bottom},TopLeft={Vector2.new(0,0),UDim2.new(0,12,
0,12),Enum.VerticalAlignment.Top},BottomLeft={Vector2.new(0,1),UDim2.new(0,12,1,
-12),Enum.VerticalAlignment.Bottom},TopCenter={Vector2.new(0.5,0),UDim2.new(0.5,
0,0,12),Enum.VerticalAlignment.Top}}local spec=map[position]or map.BottomRight
holder.AnchorPoint,holder.Position=spec[1],spec[2]layout.VerticalAlignment=spec[
3]layout.HorizontalAlignment=position:find('Left')and Enum.HorizontalAlignment.
Left or(position:find('Center')and Enum.HorizontalAlignment.Center or Enum.
HorizontalAlignment.Right)Lib.NotifyPosition=position end Lib:SetNotifyPosition(
Lib:GetSetting('NotifyPosition','BottomRight'))local typeIcons={info='info',
success='check-circle',warning='alert-triangle',warn='alert-triangle',error=
'x-circle'}local typeTokens={info='Accent',success='Success',warning='Warning',
warn='Warning',error='Error'}function Lib:Notify(options)if type(options)~=
'table'then options={Content=tostring(options)}end local kind=options.Type or
'info'local duration=options.Duration or options.Time or options.Delay or 4
local handle={Title=options.Title,Content=options.Content or options.Text or
options.Description or''}table.insert(Lib.NotificationHistory,{Title=handle.
Title,Content=handle.Content,Type=kind,Time=os.time()})Lib.Unread=(Lib.Unread or
0)+1 Lib.NotificationsChanged:Fire()while#Lib.NotificationHistory>50 do table.
remove(Lib.NotificationHistory,1)end notifyScale.Scale=Shared.Scale or 1 local
wrap=Util.New('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),
ClipsDescendants=false,LayoutOrder=math.floor((Lib.NotifyPosition:find('Bottom')
and 1 or-1)*(os.clock()*100%1e7)),Parent=holder})local card=Util.New('Frame',{
Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.
fromOffset(Lib.NotifyPosition:find('Left')and-320 or 320,0),Parent=wrap})Util.
Corner(8,card)Theme.Paint(card,{BackgroundColor3='Elevated'})Theme.Paint(Util.
Stroke(card),{Color='StrokeHi'})Shared.Overlay.Shadow(card,0.55,14)Util.Padding(
card,11,12,9,12)Util.List(card,3)local top=Util.New('Frame',{
BackgroundTransparency=1,Size=UDim2.new(1,0,0,16),LayoutOrder=1,Parent=card})
local icon=Util.New('ImageLabel',{BackgroundTransparency=1,Image=Icons.Get(
options.Icon or typeIcons[kind])or'',Size=UDim2.fromOffset(14,14),Position=UDim2
.fromOffset(0,1),Parent=top})Theme.Paint(icon,{ImageColor3=typeTokens[kind]or
'Accent'})local title=Util.Label({Text=handle.Title or(Lib.Windows[1]and Lib.
Windows[1].Title)or'Proximity',FontFace=Theme.Fonts.SemiBold,TextSize=13,Size=
UDim2.new(1,-40,1,0),Position=UDim2.fromOffset(20,0),TextTruncate=Enum.
TextTruncate.AtEnd,Parent=top})Theme.Paint(title,{TextColor3='Text'})local close
=Util.New('ImageButton',{BackgroundTransparency=1,Image=Icons.Get('x')or'',Size=
UDim2.fromOffset(12,12),AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,2)
,Parent=top})Theme.Paint(close,{ImageColor3='TextMute'})local content=Util.
Label({Text=handle.Content,FontFace=Theme.Fonts.Regular,TextSize=12,RichText=
true,TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0)
,LayoutOrder=2,Parent=card})Theme.Paint(content,{TextColor3='TextDim'})content.
Visible=handle.Content~=''if options.Actions then local row=Util.New('Frame',{
BackgroundTransparency=1,Size=UDim2.new(1,0,0,26),LayoutOrder=3,Parent=card})
Util.List(row,6,Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Right,
Enum.VerticalAlignment.Bottom)for i,action in options.Actions do local b=Util.
New('TextButton',{Text=action.Text or action[1],FontFace=Theme.Fonts.SemiBold,
TextSize=12,AutoButtonColor=false,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.
fromOffset(0,22),LayoutOrder=i,Parent=row})Util.Corner(5,b)Util.Padding(b,0,10,0
,10)Theme.Paint(b,{BackgroundColor3=i==1 and'Accent'or'Surface3',TextColor3=i==1
and'AccentInk'or'Text'})b.Activated:Connect(function()Util.SafeCall(action.
Callback or action[2])handle:Close()end)end end local track=Util.New('Frame',{
BackgroundTransparency=1,Size=UDim2.new(1,0,0,6),LayoutOrder=99,Parent=card})
local progress=Util.New('Frame',{Size=UDim2.new(1,0,0,2),Position=UDim2.
fromOffset(0,4),BorderSizePixel=0,BackgroundTransparency=0.6,Parent=track})Util.
Round(progress)Theme.Paint(progress,{BackgroundColor3='Accent'})local closed=
false local expires=os.clock()+duration function handle:Close()if closed then
return end closed=true local i=table.find(active,handle)if i then table.remove(
active,i)end Tween.Play(card,{Position=UDim2.fromOffset(Lib.NotifyPosition:find(
'Left')and-320 or 320,0)},0.25)task.delay(0.22,function()Tween.Play(wrap,{Size=
UDim2.new(1,0,0,0)},0.18)task.delay(0.2,function()wrap:Destroy()end)end)end
function handle:SetTitle(t)title.Text=t return self end function handle:
SetContent(t)content.Text=t content.Visible=t~=''return self end function handle
:SetProgress(p)progress.Size=UDim2.new(math.clamp(p,0,1),0,0,2)return self end
function handle:Extend(seconds)expires+=seconds return self end close.Activated:
Connect(function()handle:Close()end)local function fitWrap()local h=math.floor(
card.AbsoluteSize.Y/notifyScale.Scale+0.5)if not closed and wrap.Size.Y.Offset~=
h then wrap.Size=UDim2.new(1,0,0,h)end end task.defer(function()fitWrap()card:
GetPropertyChangedSignal('AbsoluteSize'):Connect(function()task.defer(fitWrap)
end)Tween.Play(card,{Position=UDim2.fromOffset(0,0)},0.35,Enum.EasingStyle.Back)
end)if not options.Persistent then task.spawn(function()local hovered=false card
.MouseEnter:Connect(function()hovered=true end)card.MouseLeave:Connect(function(
)hovered=false end)local last=os.clock()while not closed do local now=os.clock()
if hovered then expires+=now-last end last=now local left=expires-now progress.
Size=UDim2.new(math.clamp(left/duration,0,1),0,0,2)if left<=0 then handle:Close(
)end RunService.Heartbeat:Wait()end end)end table.insert(active,handle)while#
active>5 do active[1]:Close()end return handle end Lib.Notification=Lib.Notify
Lib.SetNotification=Lib.Notify function Lib:Success(content,title)return Lib:
Notify({Title=title,Content=content,Type='success'})end function Lib:Error(
content,title)return Lib:Notify({Title=title,Content=content,Type='error'})end
function Lib:Warn(content,title)return Lib:Notify({Title=title,Content=content,
Type='warning'})end function Lib:Info(content,title)return Lib:Notify({Title=
title,Content=content,Type='info'})end function Lib:ClearNotifications()for _,h
in table.clone(active)do h:Close()end end function Lib:Watermark(options)options
=options or{}if Lib.WatermarkWidget then return Lib.WatermarkWidget end local
frame=panel('Watermark')Util.Padding(frame,0,12,0,10)Util.List(frame,10,Enum.
FillDirection.Horizontal,Enum.HorizontalAlignment.Left,Enum.VerticalAlignment.
Center)Util.New('UISizeConstraint',{MinSize=Vector2.new(0,30),Parent=frame})
local logoHolder=Util.New('Frame',{BackgroundTransparency=1,Size=UDim2.
fromOffset(16,30),LayoutOrder=0,Parent=frame})local w=Lib.Windows[1]if w then
local logo=w:_drawLogo(logoHolder,16)logo.Position=UDim2.fromOffset(0,7)end
local name=Util.Label({Text=options.Text or(w and w.Title)or'Proximity',FontFace
=Theme.Fonts.Bold,TextSize=12,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.
fromOffset(0,30),LayoutOrder=1,Parent=frame})Theme.Paint(name,{TextColor3='Text'
})local widget={Frame=frame,Items={}}local order=1 function widget:AddItem(spec)
if type(spec)=='string'then spec=Lib.WatermarkPresets[spec]or{Text=spec}end
order+=1 local dot=Util.New('Frame',{Size=UDim2.fromOffset(3,3),LayoutOrder=
order,BorderSizePixel=0,Parent=frame})Util.Round(dot)Theme.Paint(dot,{
BackgroundColor3='TextMute'})order+=1 local label=Util.Label({Text='',FontFace=
Theme.Fonts.Mono,TextSize=11,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.
fromOffset(0,30),LayoutOrder=order,Parent=frame})Theme.Paint(label,{TextColor3=
'TextDim'})local item={Label=label}function item:Set(text)label.Text=tostring(
text)return self end function item:Remove()dot:Destroy()label:Destroy()self.
Removed=true end if type(spec.Text)=='function'then task.spawn(function()while
not item.Removed and not Lib.Unloaded do local ok,v=pcall(spec.Text)if ok then
item:Set(v)end task.wait(spec.Interval or 1)end end)else item:Set(spec.Text or''
)end table.insert(widget.Items,item)return item end function widget:AddGraph()
order+=1 local dot=Util.New('Frame',{Size=UDim2.fromOffset(3,3),LayoutOrder=
order,BorderSizePixel=0,Parent=frame})Util.Round(dot)Theme.Paint(dot,{
BackgroundColor3='TextMute'})order+=1 local area=Util.New('Frame',{
BackgroundTransparency=1,Size=UDim2.fromOffset(46,16),LayoutOrder=order,
ClipsDescendants=true,Parent=frame})local item={Label=area,Data={}}function item
:Remove()dot:Destroy()area:Destroy()self.Removed=true end function item:Set()end
task.spawn(function()while not item.Removed and not Lib.Unloaded do table.
insert(item.Data,Lib.Providers.FPS())if#item.Data>24 then table.remove(item.Data
,1)end if frame.Visible then Lib._drawSpark(area,item.Data)end task.wait(0.5)end
end)table.insert(widget.Items,item)return item end function widget:SetItems(list
)for _,item in widget.Items do item:Remove()end widget.Items={}order=1 for _,it
in list do if it=='Graph'then widget:AddGraph()else widget:AddItem(it)end end
return self end function widget:SetVisible(v)frame.Visible=v return self end
function widget:SetText(t)name.Text=t return self end widget:SetItems(options.
Items or Lib:GetSetting('WatermarkItems',{'FPS','Ping','Time'}))dock(frame,
'Watermark',{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,12)})
frame.Visible=Lib:GetSetting('Watermark',options.Visible~=false)Lib.
WatermarkWidget=widget return widget end Lib.WatermarkPresets={FPS={Text=
function()return Lib.Providers.FPS()..' fps'end,Interval=0.5},Ping={Text=
function()return Lib.Providers.Ping()end,Interval=1},Time={Text=function()return
os.date('%H:%M:%S')end,Interval=1},Game={Text=function()return Lib.Providers.
GameName()end,Interval=60},Player={Text=function()return Lib:GetIdentity().
DisplayName end,Interval=5},Date={Text=function()return os.date('%d.%m.%Y')end,
Interval=30},Players={Text=function()return Lib.Providers.Players()end,Interval=
2},Executor={Text=function()return Lib.Providers.Executor()end,Interval=60},
Session={Text=function()return Lib.Providers.Session()end,Interval=1},Memory={
Text=function()return Lib.Providers.Memory()end,Interval=2},Position={Text=
function()return Lib.Providers.Position()end,Interval=0.5},Speed={Text=function(
)return Lib.Providers.Speed()end,Interval=0.3},Uptime={Text=function()return Lib
.Providers.ServerUptime()end,Interval=1},Version={Text=function()return'v'..Lib.
Version end,Interval=60},Server={Text=function()return Lib.Providers.JobId()end,
Interval=60}}Lib.WatermarkItemNames={'FPS','Graph','Ping','Time','Date','Game',
'Player','Players','Executor','Session','Memory','Position','Speed','Uptime',
'Version','Server'}function Lib:KeybindList(options)options=options or{}if Lib.
KeybindListWidget then return Lib.KeybindListWidget end local frame=panel(
'Keybinds')frame.AutomaticSize=Enum.AutomaticSize.Y frame.Size=UDim2.fromOffset(
options.Width or 230,0)Util.Padding(frame,8,10,8,10)Util.List(frame,3)local head
=Util.New('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),LayoutOrder
=0,Parent=frame})local icon=Util.New('ImageLabel',{BackgroundTransparency=1,
Image=Icons.Get('keyboard')or'',Size=UDim2.fromOffset(13,13),Position=UDim2.
fromOffset(0,2),Parent=head})Theme.Paint(icon,{ImageColor3='TextDim'})local
title=Util.Label({Text=options.Title or Locale.T('KeybindList'),FontFace=Theme.
Fonts.Bold,TextSize=11,Size=UDim2.new(1,-20,1,0),Position=UDim2.fromOffset(19,0)
,Parent=head})Theme.Paint(title,{TextColor3='Text'})local rows={}local showAll=
options.ShowInactive==true or Lib:GetSetting('BindsInactive',false)local 
function rebuild()for _,r in rows do r:Destroy()end rows={}local list={}for _,kb
in Lib._classes.Keybind.All()do if kb.ShowInList and kb.Value~='None'and not kb.
_destroyed and(showAll or kb.Active or kb.Mode=='Always')and kb.Window then
table.insert(list,kb)end end local sort=Lib:GetSetting('BindsSort','Active')
table.sort(list,function(a,b)if sort=='Active'and a.Active~=b.Active then return
a.Active elseif sort=='Key'then return Keys.Display(a.Value)<Keys.Display(b.
Value)end return a.Name<b.Name end)for i,kb in list do local row=Util.New(
'Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),LayoutOrder=i,Parent=
frame})local name=Util.Label({Text=kb.Name,FontFace=Theme.Fonts.Medium,TextSize=
12,Size=UDim2.new(1,-96,1,0),TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
Theme.Paint(name,{TextColor3=kb.Active and'Text'or'TextMute'})local mode=Util.
Label({Text=Locale.T(kb.Mode=='Press'and'Press_'or kb.Mode),FontFace=Theme.Fonts
.Regular,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right,Size=UDim2.new(0,
56,1,0),Position=UDim2.new(1,-96,0,0),Parent=row})Theme.Paint(mode,{TextColor3=
'TextMute'})local key=Util.Label({Text=Keys.Display(kb.Value),FontFace=Theme.
Fonts.MonoBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,Size=UDim2.
new(0,36,1,0),Position=UDim2.new(1,-36,0,0),Parent=row})Theme.Paint(key,{
TextColor3=kb.Active and'Accent'or'TextDim'})table.insert(rows,row)end frame.
Visible=Lib:GetSetting('KeybindList',options.Visible~=false)and(#list>0 or
showAll)end Lib.KeybindsChanged:Connect(function()task.defer(rebuild)end)dock(
frame,'Keybinds',{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,12,0.5,0)}
)local widget={Frame=frame}function widget:SetVisible(v)Lib:SetSetting(
'KeybindList',v)rebuild()return self end function widget:ShowInactive(v)showAll=
v rebuild()return self end widget.Refresh=rebuild rebuild()Lib.KeybindListWidget
=widget return widget end end end function __DARKLUA_BUNDLE_MODULES.D()local v=
__DARKLUA_BUNDLE_MODULES.cache.D if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.D=v end return v.c end end do local function 
__modImpl()local Util=__DARKLUA_BUNDLE_MODULES.a()local Tween=
__DARKLUA_BUNDLE_MODULES.d()local Env=__DARKLUA_BUNDLE_MODULES.e()local Theme=
__DARKLUA_BUNDLE_MODULES.g()local Icons=__DARKLUA_BUNDLE_MODULES.i()local Locale
=__DARKLUA_BUNDLE_MODULES.j()local Shared=__DARKLUA_BUNDLE_MODULES.k()local
Players=Env.Service('Players')local RunService=Env.Service('RunService')local
GuiService=Env.Service('GuiService')return function(Lib)local function panel(
name,width,key,default)local frame=Util.New('Frame',{Name=name,Size=UDim2.
fromOffset(width,0),AutomaticSize=Enum.AutomaticSize.Y,Active=true,Parent=Shared
.Gui.Widgets})Util.Corner(10,frame)Theme.Paint(frame,{BackgroundColor3='Bg'})
frame.BackgroundTransparency=0.06 Theme.Paint(Util.Stroke(frame),{Color='Stroke'
})Shared.Overlay.Shadow(frame,0.55,18)Util.Padding(frame,10,12,12,12)Util.List(
frame,6)Lib:Dock(frame,key,default)return frame end local function header(frame,
title,icon)local head=Util.New('Frame',{BackgroundTransparency=1,Size=UDim2.new(
1,0,0,18),LayoutOrder=0,Parent=frame})local img=Util.New('ImageLabel',{
BackgroundTransparency=1,Image=Icons.Get(icon)or'',Size=UDim2.fromOffset(14,14),
Position=UDim2.fromOffset(0,2),Parent=head})Theme.Paint(img,{ImageColor3=
'TextDim'})local label=Util.Label({Text=title,FontFace=Theme.Fonts.Bold,TextSize
=12,Size=UDim2.new(1,-20,1,0),Position=UDim2.fromOffset(20,0),Parent=head})Theme
.Paint(label,{TextColor3='Text'})return head,label end function Lib:Widget(
options)options=options or{}local frame=panel('Widget_'..(options.Title or'HUD')
,options.Width or 230,'Widget.'..(options.Title or'HUD'),options.Position and{
AnchorPoint=options.AnchorPoint or Vector2.new(0,0),Position=options.Position}or
{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0)})header(frame,
options.Title or'HUD',options.Icon or'layout-dashboard')local body=Util.New(
'Frame',{BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.
new(1,0,0,0),LayoutOrder=1,Parent=frame})Util.List(body,2)local section=Lib.
_classes.Section.new(nil,{Name=options.Title or'HUD'})section.Floating=true
section.Window=Lib.Windows[1]section.Body=body section._mounted=true section.
Frame=frame function section:SetVisible(v)frame.Visible=v return self end
function section:Destroy()self:Clear()frame:Destroy()end return section end Lib.
HUD=Lib.Widget function Lib:PlayerPanel(options)options=options or{}if Lib.
PlayerPanelWidget then return Lib.PlayerPanelWidget end local frame=panel(
'PlayerPanel',190,'PlayerPanel',{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.
new(1,-12,0.5,0)})header(frame,Locale.T('PlayerPanel'),'user')local vp=Util.New(
'ViewportFrame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,170),LayoutOrder=
1,Ambient=Color3.fromRGB(150,150,160),LightColor=Color3.new(1,1,1),
LightDirection=Vector3.new(-1,-1,-1),Parent=frame})Util.Corner(8,vp)local 
function stat(order,name)local row=Util.New('Frame',{BackgroundTransparency=1,
Size=UDim2.new(1,0,0,16),LayoutOrder=order,Parent=frame})local l=Util.Label({
Text=name,FontFace=Theme.Fonts.Medium,TextSize=11,Size=UDim2.fromScale(0.5,1),
Parent=row})Theme.Paint(l,{TextColor3='TextMute'})local v=Util.Label({Text='-',
FontFace=Theme.Fonts.MonoBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.
Right,Size=UDim2.fromScale(1,1),Parent=row})Theme.Paint(v,{TextColor3='Text'})
return v end local barTrack=Util.New('Frame',{Size=UDim2.new(1,0,0,4),
LayoutOrder=2,Parent=frame})Util.Round(barTrack)Theme.Paint(barTrack,{
BackgroundColor3='Surface3'})local bar=Util.New('Frame',{Size=UDim2.fromScale(1,
1),Parent=barTrack})Util.Round(bar)Theme.Paint(bar,{BackgroundColor3='Accent'})
local hp,speed,state,pos=stat(3,Locale.T('Health')),stat(4,Locale.T('Speed')),
stat(5,Locale.T('State')),stat(6,Locale.T('Position'))local model,camera,angle=
nil,nil,0 local function rebuild()vp:ClearAllChildren()Util.Corner(8,vp)local
char=Players.LocalPlayer.Character if not char then return end local ok=Lib:
_fillViewport(vp,char)if ok then camera=vp.CurrentCamera model=vp:
FindFirstChildWhichIsA('WorldModel')and vp:FindFirstChildWhichIsA('WorldModel'):
FindFirstChildWhichIsA('Model')end end rebuild()local conns={}table.insert(conns
,Players.LocalPlayer.CharacterAdded:Connect(function()task.wait(1)rebuild()end))
local last=0 table.insert(conns,RunService.Heartbeat:Connect(function(dt)if not
frame.Visible then return end angle+=dt*0.6 if model and camera then local cf,
size=model:GetBoundingBox()local d=size.Magnitude*1.05 camera.CFrame=CFrame.
lookAt(cf.Position+Vector3.new(math.sin(angle)*d,size.Y*0.05,math.cos(angle)*d),
cf.Position)end if os.clock()-last<0.25 then return end last=os.clock()local
char=Players.LocalPlayer.Character local hum=char and char:
FindFirstChildOfClass('Humanoid')local root=char and char:FindFirstChild(
'HumanoidRootPart')if hum then hp.Text=math.floor(hum.Health)..' / '..math.
floor(hum.MaxHealth)Tween.Play(bar,{Size=UDim2.fromScale(math.clamp(hum.Health/
math.max(hum.MaxHealth,1),0,1),1)},0.2)state.Text=hum:GetState().Name end if
root then speed.Text=string.format('%.1f',root.AssemblyLinearVelocity.Magnitude)
local p=root.Position pos.Text=Lib.Anonymous and'hidden'or string.format(
'%d, %d, %d',p.X,p.Y,p.Z)end end))local widget={Frame=frame}function widget:
SetVisible(v)frame.Visible=v return self end function widget:Destroy()for _,c in
conns do c:Disconnect()end frame:Destroy()Lib.PlayerPanelWidget=nil end Shared.
Maid:Give(widget)Lib.PlayerPanelWidget=widget return widget end function Lib:
PerfGraph(options)options=options or{}if Lib.PerfGraphWidget then return Lib.
PerfGraphWidget end local frame=panel('PerfGraph',210,'PerfGraph',{AnchorPoint=
Vector2.new(1,1),Position=UDim2.new(1,-12,1,-12)})header(frame,Locale.T(
'Performance'),'activity')local function graph(order,name)local row=Util.New(
'Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,40),LayoutOrder=order,
Parent=frame})local l=Util.Label({Text=name,FontFace=Theme.Fonts.Medium,TextSize
=11,Size=UDim2.new(0.4,0,0,14),Parent=row})Theme.Paint(l,{TextColor3='TextMute'}
)local v=Util.Label({Text='',FontFace=Theme.Fonts.MonoBold,TextSize=11,
TextXAlignment=Enum.TextXAlignment.Right,Size=UDim2.new(1,0,0,14),Parent=row})
Theme.Paint(v,{TextColor3='Text'})local area=Util.New('Frame',{Size=UDim2.new(1,
0,0,22),Position=UDim2.fromOffset(0,17),ClipsDescendants=true,Parent=row})Util.
Corner(4,area)Theme.Paint(area,{BackgroundColor3='Surface2'})return v,area end
local fpsLabel,fpsArea=graph(1,'FPS')local pingLabel,pingArea=graph(2,Locale.T(
'Ping'))local fps,ping={},{}local alive=true task.spawn(function()while alive
and not Lib.Unloaded do local f=Lib.Providers.FPS()local p=tonumber(string.
match(Lib.Providers.Ping(),'%d+'))or 0 table.insert(fps,f)table.insert(ping,p)if
#fps>40 then table.remove(fps,1)table.remove(ping,1)end if frame.Visible then
fpsLabel.Text=tostring(f)pingLabel.Text=p..' ms'Lib._drawSpark(fpsArea,fps)Lib.
_drawSpark(pingArea,ping)end task.wait(0.5)end end)local widget={Frame=frame}
function widget:SetVisible(v)frame.Visible=v return self end function widget:
Destroy()alive=false frame:Destroy()Lib.PerfGraphWidget=nil end Shared.Maid:
Give(widget)Lib.PerfGraphWidget=widget return widget end function Lib:Stopwatch(
options)options=options or{}if Lib.StopwatchWidget then return Lib.
StopwatchWidget end local frame=panel('Stopwatch',200,'Stopwatch',{AnchorPoint=
Vector2.new(0,1),Position=UDim2.new(0,12,1,-12)})header(frame,Locale.T(
'Stopwatch'),'timer')local time=Util.Label({Text='00:00.0',FontFace=Theme.Fonts.
MonoBold,TextSize=24,TextXAlignment=Enum.TextXAlignment.Center,Size=UDim2.new(1,
0,0,30),LayoutOrder=1,Parent=frame})Theme.Paint(time,{TextColor3='Text'})local
session=Util.Label({Text='',FontFace=Theme.Fonts.Mono,TextSize=11,TextXAlignment
=Enum.TextXAlignment.Center,Size=UDim2.new(1,0,0,14),LayoutOrder=2,Parent=frame}
)Theme.Paint(session,{TextColor3='TextMute'})local row=Util.New('Frame',{
BackgroundTransparency=1,Size=UDim2.new(1,0,0,28),LayoutOrder=3,Parent=frame})
Util.List(row,6,Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Center)
local running,startAt,acc=false,0,0 local function btn(icon,fn)local b=Util.New(
'ImageButton',{Size=UDim2.fromOffset(40,28),AutoButtonColor=false,Parent=row})
Util.Corner(6,b)Theme.Paint(b,{BackgroundColor3='Surface3'})local img=Util.New(
'ImageLabel',{BackgroundTransparency=1,Image=Icons.Get(icon)or'',Size=UDim2.
fromOffset(14,14),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,
0.5),Parent=b})Theme.Paint(img,{ImageColor3='Text'})b.Activated:Connect(fn)
return img end local playIcon playIcon=btn('play',function()if running then acc
+=os.clock()-startAt running=false else startAt=os.clock()running=true end
playIcon.Image=Icons.Get(running and'pause'or'play')or''end)btn('rotate-ccw',
function()acc,startAt=0,os.clock()end)local alive=true task.spawn(function()
while alive and not Lib.Unloaded do local t=acc+(running and(os.clock()-startAt)
or 0)time.Text=string.format('%02d:%02d.%d',t//60,t%60,(t*10)%10)session.Text=
Locale.T('InGame')..' '..Lib.Providers.Session()task.wait(0.1)end end)local
widget={Frame=frame}function widget:SetVisible(v)frame.Visible=v return self end
function widget:Destroy()alive=false frame:Destroy()Lib.StopwatchWidget=nil end
Shared.Maid:Give(widget)Lib.StopwatchWidget=widget return widget end function
Lib:_topbarButton(window)local button=Util.New('TextButton',{Name=
'ProximityTopbar',Text='',AutoButtonColor=false,Size=UDim2.fromOffset(44,44),
BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.3,ZIndex=250,Parent=
Shared.Gui.Root})Util.Round(button)local stroke=Util.Stroke(button,Color3.new(1,
1,1),1,1)local logo=window:_drawLogo(button,26)logo.AnchorPoint=Vector2.new(0.5,
0.5)logo.Position=UDim2.fromScale(0.5,0.5)local function occupiedUntil(left,top,
bottom)local edge=left local guiInset=0 pcall(function()guiInset=GuiService:
GetGuiInset().Y end)local roots={}local player=Players.LocalPlayer local pg=
player and player:FindFirstChildOfClass('PlayerGui')if pg then table.insert(
roots,pg)end pcall(function()table.insert(roots,game:GetService('CoreGui'))end)
for _,root in roots do for _,gui in root:GetChildren()do if gui:IsA('ScreenGui')
and gui.Enabled and gui~=Shared.Gui.Root and gui.Name~='RobloxGui'and gui.Name~=
'TopBarApp'then local shift=gui.IgnoreGuiInset and 0 or guiInset for _,obj in
gui:GetDescendants()do if obj:IsA('GuiButton')and obj.Visible and obj~=button
then local pos,size=obj.AbsolutePosition,obj.AbsoluteSize local y=pos.Y+shift if
size.X>8 and size.X<260 and size.Y>8 and size.Y<80 and y>=top-4 and y+size.Y<=
bottom+6 and pos.X+size.X>left and pos.X<left+600 then local visible=true local
p=obj.Parent while p and p~=gui do if p:IsA('GuiObject')and not p.Visible then
visible=false break end p=p.Parent end if visible then edge=math.max(edge,pos.X+
size.X)end end end end end end end return edge end local function place()local
inset=GuiService.TopbarInset local x,y=164,4 local left,top,bottom=160,0,52 if
inset and inset.Width>0 then left,top,bottom=inset.Min.X,inset.Min.Y,inset.Max.Y
y=inset.Min.Y+math.max(0,(inset.Height-44)/2)end local ok,edge=pcall(
occupiedUntil,left,top,bottom)x=(ok and edge or left)+8 local origin=Shared.Gui.
Root.AbsolutePosition button.Position=UDim2.fromOffset(x-origin.X,y-origin.Y)end
place()pcall(function()Shared.Maid:Connect(GuiService:GetPropertyChangedSignal(
'TopbarInset'),place)end)task.spawn(function()for i=1,40 do task.wait(i<6 and 1
or 5)if not button.Parent then return end place()end end)button.Activated:
Connect(function()window:Toggle()end)local function paint()Tween.Play(stroke,{
Transparency=window:IsOpen()and 0.55 or 1},0.2)Tween.Play(button,{
BackgroundTransparency=window:IsOpen()and 0.15 or 0.3},0.2)end window.Opened:
Connect(paint)window.Closed:Connect(paint)Shared.Overlay.Hover(button,function()
return window.Title end)window.Maid:Give(button)return button end local function 
newer(a,b)local pa,pb={},{}for n in string.gmatch(a,'%d+')do table.insert(pa,
tonumber(n))end for n in string.gmatch(b,'%d+')do table.insert(pb,tonumber(n))
end for i=1,math.max(#pa,#pb)do if(pa[i]or 0)~=(pb[i]or 0)then return(pa[i]or 0)
>(pb[i]or 0)end end return false end Lib._newer=newer function Lib:
CheckForUpdates(url,current,name)task.spawn(function()local body=Env.HttpGet((
url or Lib.VersionUrl)..'?t='..os.time())local latest=body and string.match(body
,'%d+%.%d+[%.%d]*')current=current or Lib.Version if latest and newer(latest,
current)then Lib:Notify({Title=Locale.T('UpdateTitle',name or'Proximity'),
Content=Locale.T('UpdateBody',current,latest),Type='info',Duration=8})end end)
end function Lib:SetEconomy(on,auto)Lib.Economy=on and true or false for _,w in
Lib.Windows do w:_applyEconomy()end if on and auto and not Lib._economyNoticed
then Lib._economyNoticed=true Lib:Notify({Title=Locale.T('EconomyTitle'),Content
=Locale.T('EconomyBody'),Type='info',Duration=6})end return self end task.spawn(
function()local low=0 while not Lib.Unloaded do task.wait(1)if Lib:GetSetting(
'AutoEconomy',true)and not Lib.Economy and#Lib.Windows>0 then local fps=Lib.
Providers.FPS()low=fps<30 and low+1 or 0 if low>=6 then Lib:SetEconomy(true,true
)end end end end)function Lib:SetDebug(on)Lib.Debug=on and true or false if Lib.
_debugPanel then Lib._debugPanel:Destroy()Lib._debugPanel=nil end if not on then
return self end local frame=panel('Debug',240,'Debug',{AnchorPoint=Vector2.new(0
,0),Position=UDim2.new(0,12,0,70)})header(frame,'Debug','bug')local text=Util.
Label({Text='',FontFace=Theme.Fonts.Mono,TextSize=11,TextWrapped=true,
TextYAlignment=Enum.TextYAlignment.Top,AutomaticSize=Enum.AutomaticSize.Y,Size=
UDim2.new(1,0,0,0),LayoutOrder=1,Parent=frame})Theme.Paint(text,{TextColor3=
'TextDim'})local alive=true task.spawn(function()while alive and not Lib.
Unloaded do local lines={'version   '..Lib.Version,'elements  '..#Lib.
AllElements,'flags     '..Util.Count(Lib.Elements),'instances '..#Shared.Gui.
Root:GetDescendants(),'memory    '..math.floor(gcinfo()/1024*10)/10 ..' MB',
'fps       '..Lib.Providers.FPS()}for _,w in Lib.Windows do table.insert(lines,
'')table.insert(lines,w.Title..' - '..w.State)for _,tab in w.Tabs do table.
insert(lines,string.format('  %-12s %3d el  %4.0f ms',string.sub(tab.Name,1,12),
tab._total,(tab._buildTime or 0)*1000))end end text.Text=table.concat(lines,'\n'
)task.wait(0.5)end end)Lib._debugPanel={Destroy=function()alive=false frame:
Destroy()end}return self end end end function __DARKLUA_BUNDLE_MODULES.E()local
v=__DARKLUA_BUNDLE_MODULES.cache.E if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.E=v end return v.c end end do local function 
__modImpl()local HttpService=game:GetService('HttpService')local Util=
__DARKLUA_BUNDLE_MODULES.a()local Tween=__DARKLUA_BUNDLE_MODULES.d()local Env=
__DARKLUA_BUNDLE_MODULES.e()local Theme=__DARKLUA_BUNDLE_MODULES.g()local Icons=
__DARKLUA_BUNDLE_MODULES.i()local Locale=__DARKLUA_BUNDLE_MODULES.j()local
Shared=__DARKLUA_BUNDLE_MODULES.k()return function(Lib)local function verify(
options,key)key=Util.Trim(key or'')if key==''then return false end if options.
Keys then for _,k in options.Keys do if k==key then return true end end end if
options.Check then local ok,result=pcall(options.Check,key)if ok and result then
return true end end if options.Url then local body=Env.HttpGet(string.format(
options.Url,HttpService:UrlEncode(key)))if body then local b=string.lower(Util.
Trim(body))if b=='true'or b=='valid'or b=='ok'or b=='1'or string.find(b,
'"valid"%s*:%s*true')then return true end end end return false end function Lib:
KeySystem(options)options=options or{}local storeKey='Key.'..Util.SafeName(
options.Title or'default')if options.Remember~=false then local saved=Lib:
GetSetting(storeKey)if type(saved)=='string'and verify(options,saved)then return
true end end local attempts,maxAttempts=0,options.Attempts or 5 local
lockedUntil=0 local result=nil local thread=coroutine.running()local root=Util.
New('Frame',{Name='ProximityKey',BackgroundTransparency=1,Size=UDim2.fromScale(1
,1),ZIndex=400,Parent=Shared.Gui.Root})local dim=Util.New('Frame',{
BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,Size=UDim2.
fromScale(1,1),ZIndex=400,Parent=root})Tween.Play(dim,{BackgroundTransparency=
0.35},0.4)local card=Util.New('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position
=UDim2.fromScale(0.5,0.53),Size=UDim2.fromOffset(380,0),AutomaticSize=Enum.
AutomaticSize.Y,ZIndex=401,Parent=root})Util.Corner(12,card)Theme.Paint(card,{
BackgroundColor3='Bg'})Theme.Paint(Util.Stroke(card),{Color='StrokeHi'})Shared.
Overlay.Shadow(card,0.3,30)Util.Padding(card,22,22,20,22)Util.List(card,12)local
scale=Util.New('UIScale',{Scale=0.94,Parent=card})Tween.Play(scale,{Scale=1},
0.35,Enum.EasingStyle.Back)Tween.Play(card,{Position=UDim2.fromScale(0.5,0.5)},
0.35)local head=Util.New('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,
40),LayoutOrder=1,ZIndex=401,Parent=card})local fakeWindow={Logo=options.Logo,
Title=options.Title}local logo=Lib._drawLogo(fakeWindow,head,36)logo.ZIndex=402
local title=Util.Label({Text=options.Title or(Locale.T('KeyTitle')),FontFace=
Theme.Fonts.Bold,TextSize=17,Position=UDim2.fromOffset(50,2),Size=UDim2.new(1,-
50,0,20),ZIndex=402,Parent=head})Theme.Paint(title,{TextColor3='Text'})local sub
=Util.Label({Text=options.Subtitle or Locale.T('KeySubtitle'),FontFace=Theme.
Fonts.Regular,TextSize=12,Position=UDim2.fromOffset(50,22),Size=UDim2.new(1,-50,
0,16),ZIndex=402,Parent=head})Theme.Paint(sub,{TextColor3='TextMute'})local box=
Util.New('TextBox',{Text='',PlaceholderText=Locale.T('KeyPlaceholder'),
ClearTextOnFocus=false,FontFace=Theme.Fonts.Mono,TextSize=14,TextXAlignment=Enum
.TextXAlignment.Left,Size=UDim2.new(1,0,0,40),LayoutOrder=2,ZIndex=402,Parent=
card})Util.Corner(8,box)Util.Padding(box,0,12,0,40)Theme.Paint(box,{
BackgroundColor3='Surface2',TextColor3='Text',PlaceholderColor3='TextMute'})
local boxStroke=Util.Stroke(box)Theme.Paint(boxStroke,{Color='Stroke'})local
keyIcon=Util.New('ImageLabel',{BackgroundTransparency=1,Image=Icons.Get('key')or
'',Size=UDim2.fromOffset(16,16),Position=UDim2.new(0,-28,0.5,-8),ZIndex=403,
Parent=box})Theme.Paint(keyIcon,{ImageColor3='TextDim'})box.Focused:Connect(
function()Theme.Paint(boxStroke,{Color='Accent'},0.15)end)box.FocusLost:Connect(
function()Theme.Paint(boxStroke,{Color='Stroke'},0.15)end)local status=Util.
Label({Text=options.Note or'',FontFace=Theme.Fonts.Regular,TextSize=12,
TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),
LayoutOrder=3,Visible=options.Note~=nil,ZIndex=402,Parent=card})Theme.Paint(
status,{TextColor3='TextDim'})local row=Util.New('Frame',{BackgroundTransparency
=1,Size=UDim2.new(1,0,0,36),LayoutOrder=4,ZIndex=402,Parent=card})local function 
button(text,icon,primary,x,w)local b=Util.New('TextButton',{Text='',
AutoButtonColor=false,Size=UDim2.new(w,-4,1,0),Position=UDim2.new(x,x>0 and 4 or
0,0,0),ZIndex=402,Parent=row})Util.Corner(8,b)Theme.Paint(b,{BackgroundColor3=
primary and'Accent'or'Surface3'})Theme.Paint(Util.Stroke(b),{Color=primary and
'Accent'or'Stroke'})local inner=Util.New('Frame',{BackgroundTransparency=1,
AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromScale(0,1),AnchorPoint=Vector2
.new(0.5,0),Position=UDim2.fromScale(0.5,0),ZIndex=403,Parent=b})Util.List(inner
,6,Enum.FillDirection.Horizontal,Enum.HorizontalAlignment.Center,Enum.
VerticalAlignment.Center)local img=Util.New('ImageLabel',{BackgroundTransparency
=1,Image=Icons.Get(icon)or'',Size=UDim2.fromOffset(14,14),ZIndex=403,Parent=
inner})Theme.Paint(img,{ImageColor3=primary and'AccentInk'or'Text'})local l=Util
.Label({Text=text,FontFace=Theme.Fonts.SemiBold,TextSize=13,AutomaticSize=Enum.
AutomaticSize.X,Size=UDim2.fromScale(0,1),LayoutOrder=2,ZIndex=403,Parent=inner}
)Theme.Paint(l,{TextColor3=primary and'AccentInk'or'Text'})return b,l end local
hasLink=options.GetKey~=nil local getBtn=hasLink and button(Locale.T('GetKey'),
'link',false,0,0.5)local checkBtn,checkLabel=button(Locale.T('CheckKey'),'check'
,true,hasLink and 0.5 or 0,hasLink and 0.5 or 1)if options.Discord then local d=
Util.New('TextButton',{Text=Locale.T('JoinDiscord'),FontFace=Theme.Fonts.Medium,
TextSize=12,BackgroundTransparency=1,AutoButtonColor=false,Size=UDim2.new(1,0,0,
16),LayoutOrder=5,ZIndex=402,Parent=card})Theme.Paint(d,{TextColor3='TextDim'})d
.Activated:Connect(function()Env.Clipboard(options.Discord)status.Visible=true
status.Text=Locale.T('LinkCopied')end)end local function shake()for _,dx in{8,-8
,5,-5,0}do Tween.Await(card,{Position=UDim2.new(0.5,dx,0.5,0)},0.05,Enum.
EasingStyle.Sine)end end local busy=false local function submit()if busy or
result~=nil then return end if os.clock()<lockedUntil then status.Visible=true
status.Text=Locale.T('KeyWait',math.ceil(lockedUntil-os.clock()))return end busy
=true checkLabel.Text=Locale.T('Checking')local ok=verify(options,box.Text)busy=
false checkLabel.Text=Locale.T('CheckKey')if ok then result=true if options.
Remember~=false then Lib:SetSetting(storeKey,Util.Trim(box.Text))end Theme.
Paint(boxStroke,{Color='Success'},0.15)status.Visible=true status.Text=Locale.T(
'KeyOk')Theme.Paint(status,{TextColor3='Success'})task.wait(0.45)Tween.Play(dim,
{BackgroundTransparency=1},0.3)Tween.Play(scale,{Scale=0.96},0.25)card.Visible=
false task.delay(0.3,function()root:Destroy()end)if coroutine.status(thread)==
'suspended'then task.spawn(thread,true)end return end attempts+=1 Theme.Paint(
boxStroke,{Color='Risky'},0.1)Theme.Paint(status,{TextColor3='Risky'})status.
Visible=true if attempts>=maxAttempts then attempts=0 lockedUntil=os.clock()+(
options.Cooldown or 30)status.Text=Locale.T('KeyLocked',options.Cooldown or 30)
else status.Text=Locale.T('KeyBad',maxAttempts-attempts)end task.spawn(shake)end
checkBtn.Activated:Connect(submit)box.FocusLost:Connect(function(enter)if enter
then submit()end end)if getBtn then getBtn.Activated:Connect(function()local
copied=Env.Clipboard(options.GetKey)status.Visible=true Theme.Paint(status,{
TextColor3='TextDim'})status.Text=copied and Locale.T('LinkCopied')or options.
GetKey end)end return coroutine.yield()end end end function
__DARKLUA_BUNDLE_MODULES.F()local v=__DARKLUA_BUNDLE_MODULES.cache.F if not v
then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.F=v end return v.c end end
end local Util=__DARKLUA_BUNDLE_MODULES.a()local Signal=__DARKLUA_BUNDLE_MODULES
.b()local Maid=__DARKLUA_BUNDLE_MODULES.c()local Tween=__DARKLUA_BUNDLE_MODULES.
d()local Env=__DARKLUA_BUNDLE_MODULES.e()local Keys=__DARKLUA_BUNDLE_MODULES.f()
local Theme=__DARKLUA_BUNDLE_MODULES.g()local Icons=__DARKLUA_BUNDLE_MODULES.i()
local Locale=__DARKLUA_BUNDLE_MODULES.j()local Shared=__DARKLUA_BUNDLE_MODULES.
k()local Overlay=__DARKLUA_BUNDLE_MODULES.l()local shared=Env.Shared()local
previousVersion=nil if shared.Library and shared.Library.Unload then
previousVersion=shared.Library.Version pcall(shared.Library.Unload,shared.
Library,true)end local Library={Version='1.2.8',VersionUrl=
[[https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/VERSION]]
,ToggleStyle='Switch',DensityName='Normal',Flags={},Elements={},AllElements={},
Windows={},Debug=false,Unloaded=false,Anonymous=false,_classes={},_custom={},
_autoSaveArmed=false,FlagChanged=Signal.new(),KeybindsChanged=Signal.new(),
IdentityChanged=Signal.new(),WindowReady=Signal.new(),DirtyChanged=Signal.new(),
Unloading=Signal.new(),FavoritesChanged=Signal.new(),NotificationsChanged=Signal
.new(),ErrorOccurred=Signal.new(),Util=Util,Signal=Signal,Maid=Maid,Tween=Tween,
Theme=Theme,Icons=Icons,Keys=Keys,Env=Env,Locale=Locale}Library.__index=Library
shared.Library=Library Shared.Lib=Library Shared.Maid=Maid.new()Shared.Scale=1
do local root=Util.New('ScreenGui',{Name=Util.Uid(),ResetOnSpawn=false,
IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=9999
})Env.Protect(root)root.Parent=Env.GuiParent()local windows=Util.New('Frame',{
Name='Windows',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=10,
Parent=root})local widgets=Util.New('Frame',{Name='Widgets',
BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=20,Parent=root})Shared
.Gui={Root=root,Windows=windows,Widgets=widgets}Shared.Maid:Give(root)Overlay.
Init(root)Shared.Overlay=Overlay Library.Gui=root end __DARKLUA_BUNDLE_MODULES.
m()(Library)for _,module in{__DARKLUA_BUNDLE_MODULES.o(),
__DARKLUA_BUNDLE_MODULES.p(),__DARKLUA_BUNDLE_MODULES.q(),
__DARKLUA_BUNDLE_MODULES.r(),__DARKLUA_BUNDLE_MODULES.s(),
__DARKLUA_BUNDLE_MODULES.t()}do for name,class in module do Library._classes[
name]=class end end local Section=__DARKLUA_BUNDLE_MODULES.u()Library._classes.
Section=Section Library.Base=__DARKLUA_BUNDLE_MODULES.n()local Window=
__DARKLUA_BUNDLE_MODULES.A()__DARKLUA_BUNDLE_MODULES.B()(Window)
__DARKLUA_BUNDLE_MODULES.C()(Window)__DARKLUA_BUNDLE_MODULES.D()(Library)
__DARKLUA_BUNDLE_MODULES.E()(Library)__DARKLUA_BUNDLE_MODULES.F()(Library)
Library._drawLogo=Window._drawLogo function Library:_setDirty(value)if self.
Dirty~=value then self.Dirty=value self.DirtyChanged:Fire(value)end end function
Library:_onElementChanged(element,new,old)if element.Flag then self.FlagChanged:
Fire(element.Flag,new,old)if not self.Loading and self._autoSaveArmed and
element.Save~=false then self:_setDirty(true)self:_scheduleAutoSave()end end if
element.Type=='Toggle'and#element.Links>0 then self.KeybindsChanged:Fire()end
end function Library:GetFlag(flag)return self.Flags[flag]end function Library:
SetFlag(flag,value)local el=self.Elements[flag]if el then el:Set(value)return
true end return false end function Library:OnFlag(flag,fn)return self.
FlagChanged:Connect(function(f,new,old)if f==flag then fn(new,old)end end)end
function Library:GetElement(flag)return self.Elements[flag]end local undoStack,
redoStack={},{}function Library:_pushHistory(element,old,new)table.insert(
undoStack,{element,old,new})if#undoStack>100 then table.remove(undoStack,1)end
table.clear(redoStack)end function Library:Undo()local step=table.remove(
undoStack)if step and not step[1]._destroyed then step[1]:Set(step[2])table.
insert(redoStack,step)step[1]:Highlight()return true end return false end
function Library:Redo()local step=table.remove(redoStack)if step and not step[1]
._destroyed then step[1]:Set(step[3])table.insert(undoStack,step)step[1]:
Highlight()return true end return false end function Library:ClearHistory()table
.clear(undoStack)table.clear(redoStack)end local function favKey(el)return el.
Flag or(el:GetPath()..'/'..el.Name)end function Library:IsFavorite(el)local list
=self:GetSetting('Favorites',{})return table.find(list,favKey(el))~=nil end
function Library:ToggleFavorite(el)local list=table.clone(self:GetSetting(
'Favorites',{}))local key=favKey(el)local i=table.find(list,key)if i then table.
remove(list,i)else table.insert(list,key)end self:SetSetting('Favorites',list)
self.FavoritesChanged:Fire()return i==nil end function Library:GetFavorites()
local out={}local list=self:GetSetting('Favorites',{})for _,el in self.
AllElements do if el.Section and not el.Parent and table.find(list,favKey(el))
then table.insert(out,el)end end return out end function Window:Favorites(
options)options=options or{}local Lib=self.Library local tab=self:Tab({Name=
options.Name or Locale.T('Favorites'),Icon=options.Icon or'star',Order=options.
Order})local section=tab:FullSection({Name=Locale.T('Favorites')})local rows={}
local function refresh()for _,r in rows do r:Destroy()end rows={}local favs=Lib:
GetFavorites()if#favs==0 then table.insert(rows,section:Label({Text=Locale.T(
'FavoritesHint'),Color='TextMute',Icon='star'}))end for _,el in favs do table.
insert(rows,section:Navigate({Name=el.Name,Value=el:GetPath(),Callback=function(
)el:Focus()end}))end tab:SetBadge(#favs>0 and#favs or nil)end Lib.
FavoritesChanged:Connect(refresh)self:OnReady(refresh)return tab end local
Players=Env.Service('Players')function Library:GetIdentity()local player=Players
.LocalPlayer if self.Anonymous then return{Name='hidden',DisplayName=self.
AnonymousName or'Hidden',UserId=0,Avatar=nil,Anonymous=true}end return{Name=
player and player.Name or'Player',DisplayName=player and player.DisplayName or
'Player',UserId=player and player.UserId or 0,Avatar=player and(
'rbxthumb://type=AvatarHeadShot&id='..player.UserId..'&w=150&h=150')or nil}end
function Library:SetAnonymous(enabled,options)self.Anonymous=enabled and true or
false if options and options.Name then self.AnonymousName=options.Name end self.
IdentityChanged:Fire(self:GetIdentity())return self end do local RunService=Env.
Service('RunService')local Stats=Env.Service('Stats')local UIS=Env.Service(
'UserInputService')local started=os.clock()local frames,fps=0,60 local last=os.
clock()Shared.Maid:Connect(RunService.RenderStepped,function()frames+=1 local
now=os.clock()if now-last>=0.5 then fps=math.floor(frames/(now-last)+0.5)frames,
last=0,now end end)local function duration(seconds)seconds=math.floor(seconds)
local h,m,s=seconds//3600,(seconds%3600)//60,seconds%60 if h>0 then return
string.format('%dh %02dm',h,m)end return string.format('%dm %02ds',m,s)end local
gameName Library.Providers={FPS=function()return fps end,Ping=function()local ok
,ping=pcall(function()return math.floor(Players.LocalPlayer:GetNetworkPing()*
1000+0.5)end)if not ok or not ping or ping==0 then ok,ping=pcall(function()
return math.floor(Stats.Network.ServerStatsItem['Data Ping']:GetValue()+0.5)end)
end return ok and(ping..' ms')or'-'end,Session=function()return duration(os.
clock()-started)end,Players=function()return#Players:GetPlayers()..' / '..
Players.MaxPlayers end,Device=function()if UIS.TouchEnabled and not UIS.
KeyboardEnabled then return'Mobile'elseif UIS.GamepadEnabled and not UIS.
KeyboardEnabled then return'Console'end return'PC'end,Resolution=function()local
v=workspace.CurrentCamera.ViewportSize return math.floor(v.X)..' \u{d7} '..math.
floor(v.Y)end,AccountAge=function()if Library.Anonymous then return'-'end return
Players.LocalPlayer.AccountAge..' d'end,UserId=function()if Library.Anonymous
then return'hidden'end return tostring(Players.LocalPlayer.UserId)end,Executor=
function()return Env.ExecutorName()end,PlaceId=function()return tostring(game.
PlaceId)end,JobId=function()if Library.Anonymous then return'hidden'end return
game.JobId~=''and string.sub(game.JobId,1,18)..'\u{2026}'or'studio'end,
ServerUptime=function()return duration(workspace.DistributedGameTime)end,Memory=
function()local ok,mb=pcall(function()return Stats:GetTotalMemoryUsageMb()end)
return ok and(math.floor(mb)..' MB')or(math.floor(gcinfo()/1024)..' MB')end,
Position=function()if Library.Anonymous then return'hidden'end local root=
Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild(
'HumanoidRootPart')if not root then return'-'end local p=root.Position return
string.format('%d %d %d',p.X,p.Y,p.Z)end,Speed=function()local root=Players.
LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild(
'HumanoidRootPart')return root and string.format('%.1f st/s',root.
AssemblyLinearVelocity.Magnitude)or'-'end,GameName=function()if not gameName
then local ok,info=pcall(function()return game:GetService('MarketplaceService'):
GetProductInfo(game.PlaceId)end)gameName=ok and info and info.Name or'Roblox'end
return gameName end}end function Library._drawSpark(frame,data,fixedMin,fixedMax
)if not frame or not frame.Parent then return end for _,c in frame:GetChildren()
do if c.Name=='Seg'then c:Destroy()end end local n=#data if n<2 then return end
local s=Shared.Scale or 1 local w,h=frame.AbsoluteSize.X/s,frame.AbsoluteSize.Y/
s if w<=0 or h<=0 then task.delay(0.1,function()Library._drawSpark(frame,data,
fixedMin,fixedMax)end)return end local min,max=fixedMin or math.huge,fixedMax or
-math.huge if not fixedMin or not fixedMax then for _,v in data do min=fixedMin
or math.min(min,v)max=fixedMax or math.max(max,v)end end if max-min<1e-6 then
max=min+1 end local pad=3 local function point(i)local x=(i-1)/(n-1)*(w-pad*2)+
pad local y=h-pad-(data[i]-min)/(max-min)*(h-pad*2)return Vector2.new(x,y)end
for i=1,n-1 do local a,b=point(i),point(i+1)local d=b-a local seg=Util.New(
'Frame',{Name='Seg',BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),Size=
UDim2.fromOffset(d.Magnitude+1,1.5),Position=UDim2.fromOffset((a.X+b.X)/2,(a.Y+b
.Y)/2),Rotation=math.deg(math.atan2(d.Y,d.X)),BackgroundTransparency=0.15+0.6*(1
-i/(n-1)),ZIndex=frame.ZIndex+1,Parent=frame})Theme.Paint(seg,{BackgroundColor3=
'Accent'})end end function Library:_fillViewport(viewport,model)local ok=pcall(
function()local archivable=model.Archivable model.Archivable=true local copy=
model:Clone()model.Archivable=archivable if not copy then return end for _,d in
copy:GetDescendants()do if d:IsA('Script')or d:IsA('LocalScript')then d:Destroy(
)end end local world=Instance.new('WorldModel')world.Parent=viewport copy.Parent
=world local cf,size if copy:IsA('Model')then cf,size=copy:GetBoundingBox()else
cf,size=copy.CFrame,copy.Size end local camera=Instance.new('Camera')camera.
FieldOfView=40 local distance=size.Magnitude*1.15 camera.CFrame=CFrame.lookAt(cf
.Position+cf.LookVector*distance+Vector3.new(0,size.Y*0.1,0),cf.Position)camera.
Parent=viewport viewport.CurrentCamera=camera end)return ok end function Library
:Window(options)options=options or{}if options.Folder then self:SetFolder(
options.Folder)end local theme=self:GetSetting('Theme',options.Theme)if theme
and Theme.Presets[theme]then Theme.Set(theme,false)end local accent=Util.
FromHex(self:GetSetting('Accent',''))or Util.ToColor(options.Accent)if accent
then Theme.SetToken('Accent',accent,false)end if self:GetSetting('ReducedMotion'
,options.ReducedMotion==true)then Tween.Speed=0 end local lang=self:GetSetting(
'Language',options.Language)if lang then Locale.Set(lang)end self.AnonymousName=
self:GetSetting('AnonymousName','Hidden')if self:GetSetting('Anonymous',false)
then self.Anonymous=true end local savedKey=self:GetSetting('MenuKey')if
savedKey then options.Keybind=savedKey end local key=options.KeySystem if key
and key~=false then local spec=type(key)=='table'and key or{}spec.Title=spec.
Title or options.Title spec.Logo=spec.Logo or options.Logo if not self:
KeySystem(spec)then return nil end end Shared.Density=self.Densities[self:
GetSetting('Density',options.Density or'Normal')]or 1 self.DensityName=self:
GetSetting('Density',options.Density or'Normal')self.ToggleStyle=self:
GetSetting('ToggleStyle',options.ToggleStyle or'Switch')local font=self:
GetSetting('Font',options.Font)if font then task.spawn(function()self:SetFont(
font)end)end local window=Window.new(self,options)table.insert(self.Windows,
window)if previousVersion and previousVersion~=self.Version then window:OnReady(
function()self:Notify({Title='Proximity',Content=Locale.T('Replaced',
previousVersion,self.Version),Type='info',Duration=5})end)end window:
SetTransparency((self:GetSetting('Glass',0)or 0)/100)if options.Watermark~=false
then self:Watermark(type(options.Watermark)=='table'and options.Watermark or nil
)end if options.KeybindList~=false then self:KeybindList()end return window end
Library.CreateWindow=Library.Window Library.new=function(options)return Library:
Window(options)end function Library:SetTheme(name,animate)local ok=Theme.Set(
name,animate)if ok and type(name)=='string'then self:SetSetting('Theme',name)
local accent=Util.FromHex(self:GetSetting('Accent',''))if accent then Theme.
SetToken('Accent',accent,false)end end return ok end function Library:GetTheme()
return Theme.Current end function Library:GetThemes()return Theme.List()end
function Library:AddTheme(name,tokens)Theme.Register(name,tokens)return self end
Library.RegisterTheme=Library.AddTheme function Library:SetAccent(color)color=
Util.ToColor(color)if not color then return self end self:SetSetting('Accent',
Util.ToHex(color))Theme.SetToken('Accent',color)Theme.SetToken('AccentInk',Util.
Luminance(color)>0.5 and Color3.fromRGB(8,8,9)or Color3.fromRGB(250,250,250),
false)return self end function Library:OnThemeChanged(fn)return Theme.Changed:
Connect(fn)end function Library:SetLanguage(code)local ok=Locale.Set(code)if ok
then self:SetSetting('Language',code)end return ok end function Library:
AddLanguage(code,strings,displayName)Locale.Add(code,strings,displayName)return
self end function Library:T(key,...)return Locale.T(key,...)end function Library
:SetReducedMotion(on)Tween.Speed=on and 0 or 1 self:SetSetting('ReducedMotion',
on and true or false)return self end function Library:GetIcon(name)return Icons.
Get(name)end Library._GetIcon=Library.GetIcon function Library:RegisterIcon(name
,source)Icons.Register(name,source)return self end function Library:
RegisterElement(name,class)self._custom[name]=class self._classes[name]=class if
not Section[name]then Section[name]=function(section,options)return class.new(
section,options or{})end Section['Add'..name]=Section[name]end return self end
function Library:QuickSave(window)local name=self.CurrentConfig if not name then
task.spawn(function()local w=window or self.Windows[1]if not w then return end
local input=w:Prompt({Title=Locale.T('Save'),Placeholder=Locale.T('ConfigName')}
)if input and input~=''then self:SaveConfig(input)self.CurrentConfig=Util.
SafeName(input)self:_setDirty(false)self:Notify({Title=Locale.T('Saved'),Content
=self.CurrentConfig,Type='success',Duration=2.5})end end)return end self:
SaveConfig(name)self:_setDirty(false)self:Notify({Title=Locale.T('Saved'),
Content=name,Type='success',Duration=2})end function Library:OnUnload(fn)return
self.Unloading:Connect(fn)end function Library:Unload(silent)if self.Unloaded
then return end if not silent and self.Dirty and self.CurrentConfig and self.
Windows[1]and coroutine.isyieldable()then local index=self.Windows[1]:Dialog({
Title=Locale.T('Unsaved'),Content=Locale.T('SaveBeforeUnload',self.CurrentConfig
),Buttons={{Text=Locale.T('Cancel')},{Text=Locale.T('DontSave')},{Text=Locale.T(
'Save'),Style='Primary'}}})if index==0 or index==1 then return elseif index==3
then self:SaveConfig(self.CurrentConfig)end end self.Unloading:Fire()for _,el in
table.clone(self.AllElements)do if el.Type=='Toggle'and el.Value==true and el.
Save~=false then pcall(el.Set,el,false)end end for _,w in table.clone(self.
Windows)do pcall(w.Destroy,w)end Overlay.CloseAll()Shared.Maid:Clean()self.
Unloaded=true if shared.Library==self then shared.Library=nil end end Library.
Destroy=Library.Unload function Library:GetVersion()return self.Version end Util
.ErrorHandler=function(message,trace)warn('[Proximity] callback error: '..
tostring(message)..(Library.Debug and('\n'..trace)or''))Library.ErrorOccurred:
Fire(tostring(message),trace)end function Library:OnError(fn)return self.
ErrorOccurred:Connect(fn)end function Library:_optionWarning(kind,name,message)
warn(string.format('[Proximity] %s "%s": %s',tostring(kind),tostring(name),
message))end Library.Densities={Compact=0.86,Normal=1,Comfortable=1.14,Touch=
1.32}function Library:SetDensity(name)local factor=self.Densities[name]or 1 self
.DensityName=self.Densities[name]and name or'Normal'Shared.Density=factor self:
SetSetting('Density',self.DensityName)for _,el in self.AllElements do local
frame=el.Frame local base=frame and frame:GetAttribute('BaseH')if base then
frame.Size=UDim2.new(frame.Size.X.Scale,frame.Size.X.Offset,0,math.floor(base*
factor+0.5))end end for _,d in Shared.Gui.Root:GetDescendants()do if d:IsA(
'UIListLayout')and d:GetAttribute('BaseGap')then d.Padding=UDim.new(0,math.
floor(d:GetAttribute('BaseGap')*factor*2+0.5))end end return self end function
Library:SetToggleStyle(name)self.ToggleStyle=name self:SetSetting('ToggleStyle',
name)for _,el in self.AllElements do if el.Type=='Toggle'and not el.Style and el
._mounted then el:_buildControl()el:_render(false)end end return self end
function Library:SetFont(name)local ok=Theme.ApplyFont(name,Shared.Gui.Root)if
ok then self:SetSetting('Font',name)end return ok end function Library:GetFonts(
)return Theme.FontList()end return Library