--来自脑洞包的催更
-- day1 = {["year"]=2020,["month"]=6,["day"]=1}
-- numDay1 = os.time(day1)
-- numDay2 = os.time()
-- datex = math.ceil((numDay2-numDay1)/(3600*24))
-- sgs.Alert("今天是2020年6月"..datex.."日\n新神杀客户端终于发布")

extension = sgs.Package("brainhole",sgs.Package_GeneralPack)
extension2 = sgs.Package("brainholejy",sgs.Package_GeneralPack)
extension3 = sgs.Package("brainholeqy",sgs.Package_GeneralPack)
extension4 = sgs.Package("brainholedm",sgs.Package_GeneralPack)	
extension5 = sgs.Package("brainholemd",sgs.Package_SpecialPack)	--不想被模式打扰就取消注释
extension6 = sgs.Package("brainholegod",sgs.Package_GeneralPack)
extension7 = sgs.Package("brainholecd",sgs.Package_CardPack)

do
	require("lua.config")
	local cfg = config
	--table.insert(cfg.kingdoms,"n_qun")
	--cfg.kingdom_colors["n_qun"] = "#8A807A"
	table.insert(cfg.kingdoms,"n_pigeon")
	cfg.kingdom_colors["n_pigeon"] = "#BCBCBC"
	table.insert(cfg.kingdoms,"n_n")
	cfg.kingdom_colors["n_n"] = "#D1EA31"
	table.insert(cfg.kingdoms,"n_web")
	cfg.kingdom_colors["n_web"] = "#66CCCC"
end
sgs.LoadTranslationTable{
	["brainhole"] = "脑洞包",	
	["brainholejy"] = "脑洞·研",
	["brainholedm"] = "脑洞·浪",
	["brainholeqy"] = "脑洞·鸽",
	["brainholegod"] = "脑洞·神",
	["brainholecd"] = "脑洞卡牌",
	["n_pigeon"] = "鸽",
	["n_n"] = "N",
	["n_web"] = "网",
	["#doChoice"] = "%from 选择了 %arg",
}

N_AUDIO_DELAY_ENABLED = false

function n_CompulsorySkill(room,player,skill_name)
	room:notifySkillInvoked(player,skill_name)
	room:broadcastSkillInvoke(skill_name)
	room:sendCompulsoryTriggerLog(player,skill_name)
end

function n_gainMhp(player,int)
	local room = player:getRoom()
	local msg = sgs.LogMessage()
	local mhp = sgs.QVariant()		
	room:setPlayerProperty(player, "maxhp", sgs.QVariant(player:getMaxHp() + int))
	msg.type = "#GainMaxHp"
	msg.from = player
	msg.arg = int
	room:sendLog(msg)
end

function n_askForGiveCardTo(from,to,skill_name,pattern,prompt,compulsory)
    local room = from:getRoom()
    local card = room:askForCard(from, pattern, prompt, sgs.QVariant(), sgs.Card_MethodNone)
    if (card == nil) and compulsory and not from:isNude() then
        local cards = from:getCards("he")
        local cs = {}
        for _,c in sgs.qlist(cards) do
            if sgs.Sanguosha:matchExpPattern(pattern,nil,c) then
                table.insert(cs,c)
            end
        end
        math.randomseed(tostring(os.time()):reverse():sub(1, 7))
        if #cs ~= 0 then card = cs[math.floor(math.random(1,#cs))] end
    end
    if card then
        room:obtainCard(to,card,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, 
           to:objectName(), from:objectName(), skill_name, ""),room:getCardPlace(card:getId()) ~= sgs.Player_PlaceHand)
    end
    return card
end

function findPlayerByObjectName(room,str)
    for _,p in sgs.qlist(room:getAllPlayers(true)) do
        if p:objectName() == str then return p end
    end
    return nil
end

-- 网上抄的，用来得到字符串真实长度（不论中英文）
function getStringLength(inputstr)
    if not inputstr or type(inputstr) ~= "string" or #inputstr <= 0 then
        return nil
    end
    local length = 0
    local i = 1
    while true do
        local curByte = string.byte(inputstr, i)
        local byteCount = 1
        if curByte > 239 then
            byteCount = 4  -- 4字节字符
        elseif curByte > 223 then
            byteCount = 3  -- 汉字
        elseif curByte > 128 then
            byteCount = 2  -- 双字节字符
        else
            byteCount = 1  -- 单字节字符
        end
        i = i + byteCount
        length = length + 1
        if i > #inputstr then
            break
        end
    end
    return length
end

function playConversation(room, general_name, log, audio_type)
	if type(audio_type) ~= "string" then audio_type = "dun" end
	room:doAnimate(2,"skill=Conversation:" .. general_name, log)
	local thread = room:getThread()
	thread:delay(295)
	local i = getStringLength(sgs.Sanguosha:translate(log))
	for a = 1, i do
		room:broadcastSkillInvoke(audio_type, "system")
		thread:delay(80)
	end
	thread:delay(1100)
end

trick_patterns = {
	"amazing_grace",
	"archery_attack",
	"collateral",
	"dismantlement",
	"duel",
	"ex_nihilo",
	"fire_attack",
	"god_salvation",
	"iron_chain",
	"snatch",
	"savage_assault",
}

local function generateAllCardObjectNameTablePatterns()
	local patterns = {}
	for i = 0, 10000 do
		local card = sgs.Sanguosha:getEngineCard(i)
		if card == nil then break end
		if (card:isKindOf("BasicCard") or card:isKindOf("TrickCard")) and not table.contains(patterns, card:objectName()) then
			table.insert(patterns, card:objectName())
		end
	end
	return patterns
end
patterns = generateAllCardObjectNameTablePatterns()

function getPos(table, value)
	for i, v in ipairs(table) do
		if v == value then
			return i
		end
	end
	return 0
end

function table2IntList(table)
	local list = sgs.IntList()
	for _,e in ipairs(table) do
	    list:append(e)
	end
	return list
end

function table2BoolList(table)
    local list = sgs.BoolList()
    for _,e in ipairs(table) do
        list:append(e)
    end
    return list
end

function table2CardList(table)
    local list = sgs.CardList()
    for _,e in ipairs(table) do
        list:append(e)
    end
    return list
end

function table2PlayerList(table)
    local list = sgs.PlayerList()
    for _,e in ipairs(table) do
        list:append(e)
    end
    return list
end

function getACardRamdomly(room, player)
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
	local card = room:getDrawPile():at(math.random(0, room:getDrawPile():length() - 1))
	room:obtainCard(player,card)
	return card
end

function isValidTarget(from,to,card)
	if card:targetFixed() then return false end
	local targets = sgs.PlayerList()
	return card:targetFilter(targets,to,from) and not from:isProhibited(to, card)
	and not from:isCardLimited(card,sgs.Card_MethodUse)
end

n_anjiang = sgs.General(extension,"n_anjiang","god",5,true,true)
n_mark = sgs.CreateTriggerSkill{
	name = "n_mark",
	events = sgs.EventPhaseStart,
	can_trigger = function(self,target)
		return target
	end,
	global = true,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Finish then
			if (player:getMark("@n_poison") > 0) then
				local n = player:getMark("@n_poison")
				player:loseAllMarks("@n_poison")
				room:loseHp(player,n)
			end
			if player:hasSkill("n_guici") then
				room:setPlayerMark(player,"n_guicisuit",0)
			end
		end
	end
}
n_anjiang:addSkill(n_mark)

n_trig = sgs.CreateTriggerSkill{
	name = "n_trig",
	global = true,
	events = {sgs.TurnStart,sgs.PreCardUsed,sgs.CardsMoveOneTime,sgs.FinishJudge
	,sgs.EventPhaseStart,sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TurnStart then
			local n = 15
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				n = math.min(p:getSeat(), n)
			end
			if player:getSeat() == n and not room:getTag("ExtraTurn"):toBool() then
				if player:getMark("Global_TurnCount") == 0 then 
					room:broadcastSkillInvoke("gamestart", "system")
					room:doAnimate(2,"skill=StartAnim:rule","rule")
					for _, p in sgs.qlist(room:getAlivePlayers()) do
						room:addPlayerMark(p, "mvpexp", 1)
					end
				end
				room:setPlayerMark(player, "@clock_time", player:getMark("Global_TurnCount")+1)
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					for _, mark in sgs.list(p:getMarkNames()) do
						if string.find(mark, "_lun") and p:getMark(mark) > 0 then
							room:setPlayerMark(p, mark, 0)
						end
					end
				end
				--shiye
				if not room:getTag("n_shiyenot"):toBool() then
					for _,p in sgs.qlist(room:getAlivePlayers()) do
						if p:hasSkill("n_shiye") and p:getMark("n_xingshangusd")>0 then
							n_CompulsorySkill(room,p,"n_shiye")
							room:loseMaxHp(p,1)
						end
					end
				end
				room:setTag("n_shiyenot",sgs.QVariant(false))
				--wall
				for _,p in sgs.qlist(room:getAlivePlayers()) do
					if p:hasSkill("n_budong") and p:faceUp() then
						p:turnOver()
					end
					if p:hasSkill("n_buji") then
						n_CompulsorySkill(room, p, "n_buji")
						for _, pp in sgs.qlist(room:getOtherPlayers(p)) do
							if p:getRole() == pp:getRole() and (pp:distanceTo(p) <= 1 or pp:isAdjacentTo(p)) then
								room:recover(pp, sgs.RecoverStruct())
							end
						end
					end
				end
			end
			
		elseif event == sgs.FinishJudge then
			local judge = data:toJudge()
			local shadiao = judge.who
			if judge:isGood() then return end
			if judge.reason == "indulgence" then
				room:setEmotion(shadiao,"indulgence")
			elseif judge.reason == "supply_shortage"  then
				room:setEmotion(shadiao,"supply_shortage")
			elseif judge.reason == "lightning"  then
				room:setEmotion(shadiao,"lightning")
			end
		elseif event == sgs.GameOverJudge then
			local current = room:getCurrent()
			room:addPlayerMark(current,"havekilled",1)
			local x = current:getMark("havekilled")
			if room:getAllPlayers(true):length()-room:alivePlayerCount() == 1 then
				sgs.Sanguosha:playSystemAudioEffect("yipo")
			end
			if (x>1) and (x<8) then
				sgs.Sanguosha:playSystemAudioEffect("lianpo"..x)
				room:setEmotion(current,"lianpo\\"..x)
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_NotActive then
				room:setPlayerMark(player,"havekilled",0)
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					room:setPlayerMark(p,"healed",0)
					room:setPlayerMark(p,"rescued",0)
				end
				if player:getMark("n_butingused") > 0 then
					room:killPlayer(player)
				end
			elseif player:getPhase() == sgs.Player_RoundStart then
				local jsonValue = {
					player:objectName(),
					"turnstart",
				}
				for _,p in sgs.qlist(room:getOtherPlayers(player,true)) do
					room:doNotify(p,sgs.CommandType.S_COMMAND_SET_EMOTION,json.encode(jsonValue))
				end	
			end
		elseif event == sgs.PreCardUsed then
			local use = data:toCardUse()
			local mute_patterns = {"n_liyou","n_huoxincard","n_tiaoxincard","n_qiaofancard"}
			if table.contains(mute_patterns,use.card:objectName()) then return true end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if (move.from and move.from:objectName() == player:objectName()) and(bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_RECAST) then
				if move.reason.m_skillName == "n_chaoxi" then
					room:broadcastSkillInvoke("n_chaoxi")
					room:notifySkillInvoked(player,"n_chaoxi")
					room:addPlayerMark(player,"chaoxiusd")
				end
			--elseif bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DRAW then
			--	sgs.Sanguosha:playSystemAudioEffect("card")
			end
		elseif event == sgs.Death then
			local damage = data:toDeath().damage
			local who = data:toDeath().who
			if who:objectName() ~= player:objectName() then return end
			local killer = ""
			if damage and damage.from then killer = damage.from:getGeneralName() else killer = "unknown" end
			room:doAnimate(2, "skill=KillAnim:"..killer.."+"..who:getGeneralName(), "~"..who:getGeneralName())
			room:getThread():delay(2500)
		end
		return false
	end
}
n_anjiang:addSkill(n_trig)

n_mobile_effect = sgs.CreateTriggerSkill{
    name = "n_mobile_effect",
    priority = 9,
    events = {sgs.Damage, sgs.DamageComplete, sgs.EnterDying, sgs.GameOverJudge, sgs.HpRecover, sgs.QuitDying},
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
		local function damage_effect(n)
			if n == 3 then
				room:doAnimate(2, "skill=Rampage:mbjs", "")
				room:broadcastSkillInvoke(self:objectName(), 1)
				room:getThread():delay(3325)
            elseif n >= 4 then
                room:doAnimate(2, "skill=Violence:mbjs", "")
				room:broadcastSkillInvoke(self:objectName(), 2)
				room:getThread():delay(4000)
			end
		end
        if event == sgs.Damage then
            local damage = data:toDamage()
            if damage.from and damage.from:getMark("mobile_damage") == 0 then
				damage_effect(damage.damage)
			end
		elseif event == sgs.EnterDying then
			local damage = data:toDying().damage
            if damage and damage.from and damage.to:isAlive() then
				if damage.damage >= 3 then
					damage_effect(damage.damage)
					room:addPlayerMark(damage.from, "mobile_damage")
				end
			end
		elseif event == sgs.DamageComplete then
			local damage = data:toDamage()
			if damage.from then room:setPlayerMark(damage.from, "mobile_damage", 0) end
        elseif event == sgs.GameOverJudge then
            local current = room:getCurrent()
			room:addPlayerMark(current,"havekilled",1)
			local x = current:getMark("havekilled")
			if not room:getTag("FirstBlood"):toBool() then
                room:setTag("FirstBlood", sgs.QVariant(true))
				room:doAnimate(2, "skill=FirstBlood:mbjs", "")
				room:broadcastSkillInvoke(self:objectName(), 3)
				room:getThread():delay(2500)
			end
			if x == 2 then
                room:doAnimate(2, "skill=DoubleKill:mbjs", "")
				room:broadcastSkillInvoke(self:objectName(), x + 2)
				room:getThread():delay(2800)
            elseif x == 3 then
                room:doAnimate(2, "skill=TripleKill:mbjs", "")
				room:broadcastSkillInvoke(self:objectName(), x + 2)
				room:getThread():delay(2800)
            elseif x == 4 then
                room:doAnimate(2, "skill=QuadraKill:mbjs", "")
				room:broadcastSkillInvoke(self:objectName(), x + 2)
				room:getThread():delay(3500)
            elseif x > 4 and x <= 7 then
                room:doAnimate(2, "skill=MoreKill:" .. x, "")
				room:broadcastSkillInvoke(self:objectName(), x + 2)
				room:getThread():delay(4000)
            end
		elseif event == sgs.HpRecover then
			local recover = data:toRecover()
			-- 如果没有体力回复来源，或者是自己让自己回血，那么触发医术高超
			if recover.who and recover.who:objectName() == player:objectName() or 
			(room:getCurrent():objectName() == player:objectName() and not recover.who) then
				room:addPlayerMark(player, "healed", recover.recover)
				if player:getMark("healed") >= 3 then
					room:setPlayerMark(player, "healed", 0)
					room:doAnimate(2, "skill=Heal:mbjs", "")
					room:broadcastSkillInvoke(self:objectName(), 10)
					room:getThread():delay(2000)
				end
			end

			if recover.who and player:objectName() ~= room:getCurrent():objectName() 
				and recover.who:objectName() ~= player:objectName() then
				room:addPlayerMark(recover.who, "rescued", recover.recover)
				if recover.who:getMark("rescued") >= 3 and player:isAlive() then
					room:setPlayerMark(recover.who, "rescued", 0)
					room:doAnimate(2, "skill=Rescue:mbjs", "")
					room:broadcastSkillInvoke(self:objectName(), 11)
					room:getThread():delay(2000)
				end
			end
		end
    end,
    global = true,
}
n_anjiang:addSkill(n_mobile_effect)

n_dis = sgs.CreateDistanceSkill{
	name = "n_dis",
	correct_func = function(self, from, to)
		local n = 0
		if to:hasSkill("n_qiantao") and not to:faceUp() then
			n = n+1
		end
		if to:hasSkill("n_sizui") and not to:getPile("n_crime"):isEmpty() then
			n = n+1
		end
		if to:hasSkill("n_budong") and from:getRole() ~= to:getRole() then
			for _,p in sgs.qlist(from:getAliveSiblings()) do
				if p:getRole() ~= from:getRole() then
					n = n + 1
				end
			end
		end
		return n
	end,
}
n_anjiang:addSkill(n_dis)

function getWinner(room,victim)    
	--if not string.find(room:getMode(),"p") then return nil end
	local function contains(plist,role)
		for _,p in sgs.qlist(plist) do
			if p:getRoleEnum() == role then return true end
		end
		return false
	end
	local r = victim:getRoleEnum() 
    local sp = room:getOtherPlayers(victim)					
    if r == sgs.Player_Lord then
        if(sp:length() == 1 and sp:first():getRole() == "renegade") then                    
			return "renegade"
        else                   
			return "rebel"
        end
    else
        if(not contains(sp,sgs.Player_Rebel) and not contains(sp,sgs.Player_Renegade))then               
			return "lord+loyalist"
		else return nil end							
    end 	
end

n_mvpexperience = sgs.CreateTriggerSkill {
	name = "#n_mvpexperience",
	events = { sgs.PreCardUsed, sgs.CardResponded, sgs.CardsMoveOneTime, sgs.PreDamageDone,
				sgs.HpLost, sgs.GameOverJudge,sgs.GameFinished },
	global = true,
	priority = 3,
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, triggerEvent, player, data)
		local room = player:getRoom()
		if not string.find(room:getMode(), "p") then return end
		if room:getTag("DisableMVP"):toBool() then return end
		local x = 1
		local conv = false --(math.random() < 0.2)
		if triggerEvent == sgs.PreCardUsed or triggerEvent == sgs.CardResponded then
			local card = nil
			if triggerEvent == sgs.PreCardUsed then
				card = data:toCardUse().card
			else
				card = data:toCardResponse().m_card
			end
			local typeid = card:getTypeId()
			if typeid == sgs.Card_TypeBasic then
				room:addPlayerMark(player, "mvpexp", x)
			elseif typeid == sgs.Card_TypeTrick then
				room:addPlayerMark(player, "mvpexp", 3 * x)
			elseif typeid == sgs.Card_TypeEquip then
				room:addPlayerMark(player, "mvpexp", 2 * x)
			end
			if conv and math.random() < 0.1 then
				playConversation(room, player:getGeneralName(), "#mvpuse"..math.floor(math.random(6)))
			end
		elseif triggerEvent == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if not move.to or player:objectName() ~= move.to:objectName()
				or (move.from and move.from:objectName() == move.to:objectName())
				or (move.to_place ~= sgs.Player_PlaceHand and move.to_place ~= sgs.Player_PlaceEquip)
				or room:getTag("FirstRound"):toBool() then
				return false
			end
			room:addPlayerMark(player, "mvpexp", move.card_ids:length() * x)
		elseif triggerEvent == sgs.PreDamageDone then
			local damage = data:toDamage()
			if damage.from then
				room:addPlayerMark(damage.from, "mvpexp", damage.damage * 5 * x)
				room:addPlayerMark(damage.to, "mvpexp", damage.damage * 2 * x)
				if conv then
					playConversation(room, damage.from:getGeneralName(), "#mvpdamage"..math.floor(math.random(6)))
				end
			end
		elseif triggerEvent == sgs.HpLost then
			local lose = data:toInt()
			room:addPlayerMark(player, "mvpexp", lose * x)
			if conv and math.random() < 0.3 then
				playConversation(room, player:getGeneralName(), "#mvplose"..math.floor(math.random(6)))
			end
		elseif triggerEvent == sgs.GameOverJudge then
			local death = data:toDeath()
			--death.who:speak("skillinvoke")
			if not death.who:isLord() then
				room:removePlayerMark(death.who, "mvpexp", 100)
			else
				for _, p in sgs.qlist(room:getOtherPlayers(death.who)) do
					room:addPlayerMark(p, "mvpexp", 10 * x)
				end
				local damage = death.damage
				if damage and damage.from and damage.from:isAlive() and not damage.from:isLord() then
					room:addPlayerMark(damage.from, "mvpexp", 5 * x)
				end
			end
			local t = getWinner(room, death.who)
			if not t then return end
			--room:getLord():speak(t)
			local players = sgs.QList2Table(room:getAlivePlayers())
			local function loser(p)
				local tt = t:split("+")
				if not table.contains(tt, p:getRole()) then return true end
				return false
			end
			for _, p in ipairs(players) do
				if loser(p) then 
					table.removeOne(players, p)
				end
			end
			local comp = function(a,b)
				return a:getMark("mvpexp") > b:getMark("mvpexp")
			end
			if #players > 1 then
				-- for _, p in ipairs(players) do
				-- 	if (swig_type(p) ~= "ServerPlayer *") then
				-- 		table.removeOne(players, p)
				-- 	end
				-- end
                table.sort(players,comp)
			end
			local str = players[1]:getGeneralName()
			local str2 = players[1]:screenName()
			--room:doAnimate(2,"skill=MvpAnim:"..str,str)
			local skills = players[1]:getGeneral():getVisibleSkillList()
			local skill = nil
			local word = ""
			local index = -1
			if not skills:isEmpty() then
				skill = skills:at(math.random(1,skills:length())-1)
				local sources = skill:getSources()
				if #sources > 1 then index = math.random(1, #sources) end
				word = "$" .. skill:objectName() .. (index == -1 and "" or tostring(index))
			end
			room:doAnimate(2,"skill=MobileMvp:"..str..":"..str2..":"..math.random(0,11), word)
			room:broadcastSkillInvoke("n_mobile_effect", 12)
			local thread = room:getThread()
			--thread:delay(1080)
			thread:delay(1100)
			--local skills = players[1]:getGeneral():getVisibleSkillList()
			if skill then room:broadcastSkillInvoke(skill:objectName(), index) end
			thread:delay(2900)
		end
		return false
	end
}
n_anjiang:addSkill(n_mvpexperience)

sgs.LoadTranslationTable{
	["n_dis"] = "脑洞包距离修正",
	["n_anjiang"] = "技能暗将",
	["#mvpuse1"] = "今日之战场甚为喧嚣啊。",
	["#mvpuse2"] = "经验+3，告辞",
	["#mvpuse3"] = "很喜欢许攸的一句话：“阿瞒有我良计，取冀州便是易如反掌”",
	["#mvpuse4"] = "谁出的牌多，谁就胜了！",
	["#mvpuse5"] = "期待脑洞包即将推出的剧情模式~",
	["#mvpuse6"] = "剧情模式做好了，就不用时不时这么说话了",
	["#mvpdamage1"] = "与我为敌，便是与天为敌。",
	["#mvpdamage2"] = "站累了？给你机会跪下。",
	["#mvpdamage3"] = "崩坏吧！为这个世界增添更多的乐趣！",
	["#mvpdamage4"] = "在这个错误的时间，出现在错误的地点，无关乎敌对与否，你必须要死。",
	["#mvpdamage5"] = "期待脑洞包即将推出的剧情模式~",
	["#mvpdamage6"] = "剧情模式做好了，就不用时不时这么说话了",
	["#mvplose1"] = "错的不是我，是这个世界",
	["#mvplose2"] = "痛苦，造就强者。",
	["#mvplose3"] = "哦洗海带哟~洗海带哟~",
	["#mvplose4"] = "我这把老骨头，不算什么。",
	["#mvplose5"] = "期待脑洞包即将推出的剧情模式~",
	["#mvplose6"] = "剧情模式做好了，就不用时不时这么说话了",
	--------------------------------
	["n_mobile_effect"] = "手杀特效",
	[":n_mobile_effect"] = "鬼晓得这些特效是怎么触发的",
	["$n_mobile_effect1"] = "癫狂屠戮！",
	["$n_mobile_effect2"] = "无双！万军取首！",
	["$n_mobile_effect3"] = "一破！卧龙出山！",
	["$n_mobile_effect4"] = "双连！一战成名！",
	["$n_mobile_effect5"] = "三连！下次一定！",
	["$n_mobile_effect6"] = "四连！天下无敌！",
	["$n_mobile_effect7"] = "五连！诛天灭地！",
	["$n_mobile_effect8"] = "六连！诛天灭地！",
	["$n_mobile_effect9"] = "七连！诛天灭地！",
	["$n_mobile_effect10"] = "医术高超~",
	["$n_mobile_effect11"] = "妙手回春~",
}
--============================--

n_debugger = sgs.General(extension,"n_debugger","god",5,true,true)
n_democard = sgs.CreateSkillCard{
	name = "n_democard",
	target_fixed = true,
	--filter = function(self, targets, to_select) 
	--	return to_select:objectName() ~= sgs.Self:objectName()
	--end, 
	--feasible = function(self, targets)
	--	return #targets == 1
	--end,
	on_use = function(self, room, source, targets)
		--for _, p in sgs.qlist(room:getOtherPlayers(source)) do
		--	room:killPlayer(p)
		--end
		--room:doAnimate(2,"skill=eatdumpling:sunce","$jiang1")
		--playConversation(room, "sunce", "$yingzi2")
		--playConversation(room, "n_lubenweiex", "~n_lubenweiex")
		--room:doAnimate(2, "skill=Rampage:sunce+yuji", "~n_lubenweiex")
		--room:setPlayerMark(recover.who, "rescued", 0)
		room:doAnimate(2, "skill=MoreKill:" .. 8, "")
	end
}
n_demo = sgs.CreateZeroCardViewAsSkill{
	name = "n_demo", 
	--n = 1,
	--filter_pattern = "thunder_slash,fire_slash",
	view_as = function(self, card) 
		--local demo = n_democard:clone()
		return n_democard:clone()
	end, 
	--enabled_at_response = function(self,pattern)
	--	return true
	--end
}
n_debugger:addSkill(n_demo)
sgs.LoadTranslationTable{
	["n_debugger"] = "说明书",
	["n_demo"] = "一键清场",
	[":n_demo"] = "1.本拓展中技能涉及的拼点没有平局，平局视为发起者输。\
	2.“毒”标记：结束阶段，失去全部毒和等量体力。\
	3.弹窗之战：使用卡牌后有几率出现弹窗，根据选择执行不同效果。\
	4.随机之战：一轮开始时，除主公外所有其他角色随机交换身份和座位。\
	5.ZY禁止视为重铸，学渣抄袭重铸会计入使用次数。",
}
--============================--
n_caixukun = sgs.General(extension,"n_caixukun","n_web",3,false)
n_qiuwuCard = sgs.CreateSkillCard{
	name = "n_qiuwuCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, player, targets)
		local drawed = 0
		local x = room:getAlivePlayers():length()
		while true do
			local judge = sgs.JudgeStruct()
			judge.reason = "n_qiuwu"
			judge.who = player
			room:judge(judge)
			player:drawCards(2)
			drawed = drawed + 2
			if drawed == x*4 then break end
			local judgeNum = room:getTag("n_qiuwuCount"):toInt()
			local pattern = ""
			if judgeNum == 1 then break
			elseif judgeNum == 2 then pattern = ".|.|A|."
			else pattern = ".|.|A~"..tostring(judgeNum-1).."|."
			end
			local dscd = room:askForDiscard(player, "n_qiuwu", 1, 1, true, false, nil, pattern)
			if not dscd then break end
		end
		room:loseHp(player)
		if drawed >= x*2 and player:hasSkill("n_zhimo") then
			local allPlayer = room:getOtherPlayers(player)
			room:acquireSkill(player, "qingguo")
			room:broadcastSkillInvoke("n_zhimo")
			for _,p in sgs.qlist(allPlayer) do
				if not player:isAlive() then break end
				local choice = room:askForChoice(p, "n_qiuwu", "cxkm1+killcxk",sgs.QVariant())
				if choice == "cxkm1" then
					local recover = sgs.RecoverStruct()
					recover.who = p
					recover.recover = 1
					room:recover(player, recover, true)
				elseif choice == "killcxk" then
					local slash = sgs.Sanguosha:cloneCard("thunder_slash", sgs.Card_NoSuit, 0)
					--slash:setSkillName("n_zhimo")
					local card_use = sgs.CardUseStruct()
					card_use.card = slash
					card_use.from = p
					card_use.to:append(player)
					local x = p:getHp()
					for i=1 ,x do
						room:broadcastSkillInvoke("paoxiao")
						room:useCard(card_use, false)
						if not player:isAlive() then break end
					end
				end
			end
			room:detachSkillFromPlayer(player, "qingguo")
		end
	end
}
n_qiuwuvs = sgs.CreateViewAsSkill{
	name = "n_qiuwu",
	n = 0,
	view_as = function(self, cards) 
		return n_qiuwuCard:clone()
	end, 
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_qiuwuCard")
	end
}
n_qiuwu = sgs.CreateTriggerSkill{
	name = "n_qiuwu",
	view_as_skill = n_qiuwuvs,
	events = {sgs.GameStart, sgs.FinishJudge},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			room:setTag("n_qiuwuCount",sgs.QVariant(0))
		end
		if event == sgs.FinishJudge then
			local judge = data:toJudge()
			if judge.reason == "n_qiuwu" then
				local num = judge.card:getNumber()
				room:setTag("n_qiuwuCount",sgs.QVariant(num))
			end
			return false
		end
	end
}
n_caixukun:addSkill(n_qiuwu)
n_zhimo = sgs.CreateTriggerSkill{
	name = "n_zhimo",
	frequency = sgs.Skill_Compulsory,
	event = sgs.NonTrigger,
	on_trigger = function() end
}
n_caixukun:addSkill(n_zhimo)
sgs.LoadTranslationTable{
	["n_caixukun"] = "蔡徐坤",
	["#n_caixukun"] = "球舞奇雉", 
	["designer:n_caixukun"] = "Notify",
	["illustrator:n_caixukun"] = "来自网络",
	["~n_caixukun"] = "怎能如此对我...",
	["n_qiuwu"] = "球舞",
	[":n_qiuwu"] = "阶段技。你可以进行一次判定并摸两张牌，然后若你弃置一张点数小于判定牌的手牌，则重复此流程直到摸牌数量达到4X张(X为存活人数)；否则你失去一点体力。",
	["$n_qiuwu"] = "(某音乐)",
	["n_zhimo"] = "雉魔",
	[":n_zhimo"] = "锁定技。“球舞”发动之后，若你以此法获得了不少于2X张牌，则你获得“倾国”，然后场上所有其它角色需选择: 1. 令你回复一点体力: 2.视为连续对你使用等同于其体力值张【雷杀】 。之后，你失去倾国。",
	["$n_zhimo1"] = "鸡你太美！",
	["$n_zhimo2"] = "鸡你太美",
	["cxkm1"] = "令其回复一点体力",
	["killcxk"] = "视为对其使用等同自己体力值张雷杀",
}

n_wangjingze = sgs.General(extension,"n_wangjingze","n_web")
n_liejieBuff = sgs.CreateTriggerSkill{
	name = "#n_liejieBuff",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreHpRecover,sgs.DamageInflicted,sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke("n_liejie")
		local msg = sgs.LogMessage()
		if event == sgs.PreHpRecover then
			local recover = data:toRecover()
			if recover.who:objectName() ~= player:objectName() then
				msg.type = "#SkillNullify"
				msg.from = player
				msg.arg = "n_liejie"
				msg.arg2 = "peach"
				room:sendLog(msg)
				player:drawCards(2)
				return true
			end
		else
			local damage = data:toDamage()
			msg.type = "#liejiedamage"
			msg.from = player
			msg.arg = damage.damage
			msg.arg2 = damage.damage + 1
			room:sendLog(msg)
			damage.damage = damage.damage + 1
			data:setValue(damage)
			return false
		end
	end,
	priority = 3,
}
n_anjiang:addSkill(n_liejieBuff)
n_liejie = sgs.CreateTriggerSkill{
	name = "n_liejie",
	limit_mark = "@n_lj",
	frequency = sgs.Skill_Limited,
	events = sgs.Damaged,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if not room:askForSkillInvoke(player,self:objectName()) then return end
		room:broadcastSkillInvoke("n_liejie")
		room:removePlayerMark(player, "@n_lj")
		player:drawCards(2)
		room:acquireSkill(player,n_liejieBuff)
		return false
	end,
	can_trigger = function(self, target)
		if target then
			if target:hasSkill(self:objectName()) then
				if target:isAlive() then
					return target:getMark("@n_lj") > 0
				end
			end
		end
		return false
	end
}
n_wangjingze:addSkill(n_liejie)
n_zhenxiang = sgs.CreateTriggerSkill{
	name = "n_zhenxiang",
	events = {sgs.PreHpRecover},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local rec = data:toRecover()
		if rec.card and (rec.card:isKindOf("Peach")) then
			room:broadcastSkillInvoke("n_zhenxiang")
			rec.recover = rec.recover + 1
			data:setValue(rec)
			if player:getMark("@n_lj") == 0 then
				room:setPlayerMark(player,"@n_lj",1)
				room:detachSkillFromPlayer(player,"#n_liejieBuff")
			end
		end
	end,
}
n_wangjingze:addSkill(n_zhenxiang)
sgs.LoadTranslationTable{
	["n_wangjingze"] = "王境泽",
	["#n_wangjingze"] = "铮铮铁骨",
	["~n_wangjingze"] = "你的东西我一口也不会吃。",
	["n_liejie"] = "烈节",
	[":n_liejie"] = "限定技。你受到伤害后，你可以摸两张牌。"..
	"若如此做，此后你造成或受到的伤害+1，且"..
	"你即将回复体力时，若令你回复体力者不为你自己，"..
	"则改为你摸两张牌。",
	["#liejiedamage"] = "%from 的 \"<font color=\"yellow\"><b>烈节</b></font>\" 效果被触发，伤害由 %arg 点增加至 %arg2 点",
	["$n_liejie"] = "（誓言）",
	["n_zhenxiang"] = "真香",
	[":n_zhenxiang"] = "你因【桃】回复的体力+1。当你因【桃】回复体力后，视为你没有发动过“烈节”。",
	["$n_zhenxiang"] = "真香~",
	--["cv:n_wangjingze"] = "Audition",
	["designer:n_wangjingze"] = "Notify",
	["illustrator:n_wangjingze"] = "来自网络",
	["~n_wangjingze"] = "我一口都不会吃。",
}

n_qiegewala = sgs.General(extension,"n_qiegewala","n_web",3)
n_qiecheCard = sgs.CreateSkillCard{
	name = "n_qiecheCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, selected, to_select)
		return (#selected == 0) and
		(to_select:objectName() ~= sgs.Self:objectName()) and
		to_select:getHandcardNum() > sgs.Self:getHandcardNum()
	end,
	on_effect = function(self,effect)
		local target = effect.to
		local room = target:getRoom()
		local zhoumou = effect.from
		local allplayer = room:getOtherPlayers(player)
		local truePlayers = sgs.SPlayerList()
		for _,p in sgs.qlist(allplayer) do
			if p:inMyAttackRange(zhoumou) then
				truePlayers:append(p)
			end
		end
		local isSeen = false
		repeat
			local card = room:askForCardChosen(zhoumou,target,"hej","n_qieche")
			room:obtainCard(zhoumou,card,false)
			for _,witness in sgs.qlist(truePlayers) do
				room:setPlayerMark(witness,"qiechewitness",1)
				local theSlash = room:askForUseSlashTo(witness,zhoumou,"@tiaoxin-slash:" .. zhoumou:objectName())
				if theSlash then
					isSeen = true
					break
				end
			end
		until(zhoumou:getHandcardNum() >= zhoumou:getMaxHp() or isSeen == true or target:isAllNude())
		for _,wis in sgs.qlist(truePlayers) do
			room:setPlayerMark(wis,"qiechewitness",0)
		end
	end
}
n_qiechevs = sgs.CreateViewAsSkill{
	name = "n_qieche",
	n = 0,
	view_as = function(self, cards)
		return n_qiecheCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getHandcardNum() < player:getMaxHp() and 
		not player:hasUsed("#n_qiecheCard")
	end
}
n_qieche = sgs.CreateTriggerSkill{
	name = "n_qieche",
	events = {sgs.DamageInflicted},
	view_as_skill = n_qiechevs,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dmg = data:toDamage()
		if dmg.from:getMark("qiechewitness") > 0 then
			room:setPlayerMark(dmg.from,"qiechewitness",0)
			player:turnOver()
			return true
		end
	end,
}
n_qiegewala:addSkill(n_qieche)
n_leyu = sgs.CreateTriggerSkill{
	name = "n_leyu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TurnedOver},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		n_CompulsorySkill(room,player,self:objectName())
		local recover = sgs.RecoverStruct()
		recover.who = player
		room:recover(player, recover)
		room:setEmotion(player,"recover")
	end,
}
n_qiegewala:addSkill(n_leyu)
sgs.LoadTranslationTable{
	["n_qiegewala"] = "窃格瓦拉",
	["#n_qiegewala"] = "电瓶杀手",
	["&n_qiegewala"] = "周某",
	["~n_qiegewala"] = "打工是不可能打工的，这辈子不可能打工的啦",
	["designer:n_qiegewala"] = "Notify",
	["illustrator:n_qiegewala"] = "来自网络",
	--["cv:n_qiegewala"] = "周某",
	["n_qieche"] = "窃车",
	[":n_qieche"] = "阶段技。若你的手牌数小于体力上限，"..
	"你可以指定一名手牌数多于你的角色，获得其一张牌，"..
	"然后场上所有攻击范围含有你的其它角色可以对你使用一张【杀】。若没有角色使用【杀】，你可"..
	"重复此流程直到你的手牌数达到体力上限；若以此法使用的【杀】生效，防止【杀】的伤害，改为你翻面。",
	["$n_qieche1"] = "没钱了，肯定要做呀",
	["$n_qieche2"] = "就是偷这种东西，才能维持住生活的样子嘛",
	["n_leyu"] = "乐狱",
	[":n_leyu"] = "锁定技。你翻面时回复一点体力。",
	["$n_leyu1"] = "进看守所就跟回家一样啦",
	["$n_leyu2"] = "里面个个都是人才，说话又好听",
}

n_meiguoge = sgs.General(extension,"n_meiguoge","n_web",3)
n_quanjia = sgs.CreateTriggerSkill{
	name = "n_quanjia",
	events = sgs.CardUsed,
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local mgg = room:findPlayerBySkillName("n_quanjia")
		if not mgg then return end
		local use = data:toCardUse()
		if use.from:objectName() ~= mgg:objectName() and not use.to:contains(mgg) 
		and (use.card:isKindOf("Slash") or use.card:isKindOf("Duel"))then
			local card = room:askForCard(mgg,".|black|.|.","#quanjiaDisCard:"..use.from:getGeneralName() ,data, sgs.Card_MethodDiscard)
			if card then
				local msg = sgs.LogMessage()
				msg.type = "#InvokeSkill"
				msg.from = mgg
				msg.arg = self:objectName()
				room:sendLog(msg)
				room:broadcastSkillInvoke("n_quanjia")
				use.from:drawCards(1)
				for _,to in sgs.qlist(use.to) do
					to:drawCards(1)
					room:setEmotion(to,"skill_nullify")
				end
				return true
			end
		end
	end
}
n_meiguoge:addSkill(n_quanjia)
n_liyouCard = sgs.CreateSkillCard{
	name = "n_liyou", 
	will_throw = false, 
	mute = true,
	filter = function(self, targets, to_select) 
		return #targets < 2 and to_select:objectName() ~= sgs.Self:objectName()
		and not to_select:isKongcheng()
	end, 
	feasible = function(self, targets)
		return #targets == 2
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("n_liyou", 1)
		local thread = room:getThread()
		if N_AUDIO_DELAY_ENABLED then thread:delay(4000) end
		local success = targets[1]:pindian(targets[2], "n_liyou")
		local winner,loser
		local mgg = source
		if success then
			winner = targets[1]
			loser = targets[2]
		else
			winner = targets[2]
			loser = targets[1]
		end
		if winner then
			local card = room:askForCard(mgg,".|red|.|.","#liyouGive:"..winner:getGeneralName() ,sgs.QVariant(), sgs.Card_MethodNone)
			if card then
				room:broadcastSkillInvoke("n_liyou", 2)
				if N_AUDIO_DELAY_ENABLED then thread:delay(3000) end
				room:obtainCard(winner, card, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, 
				mgg:objectName(), winner:objectName(), self:objectName(), ""))
				if N_AUDIO_DELAY_ENABLED then thread:delay(2200) end
				local damage = sgs.DamageStruct()
				damage.from = mgg
				damage.to = loser
				damage.damage = 1
				room:damage(damage)
			else
				room:broadcastSkillInvoke("n_liyou", 3)
				if N_AUDIO_DELAY_ENABLED then thread:delay(2000) end
			end
		end
	end
}
n_liyou = sgs.CreateViewAsSkill{
	name = "n_liyou", 
	n = 0,
	view_as = function(self, card) 
		local cards = n_liyouCard:clone()
		return cards
	end, 
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_liyou")
	end
}
n_meiguoge:addSkill(n_liyou)
sgs.LoadTranslationTable{
	["n_meiguoge"] = "美国哥",
	["#n_meiguoge"] = "坷拉诱敌",
	["~n_meiguoge"] = "小鬼子，真不傻！",
	["designer:n_meiguoge"] = "Notify",
	["illustrator:n_meiguoge"] = "来自网络",
	["n_quanjia"] = "劝架",
	["$n_quanjia1"] = "你们想干什么？！",
	["$n_quanjia2"] = "不能打架、不能打架！",
	["#quanjiaDisCard"] = "你可以弃置一张黑色牌，令 %src 使用的牌无效",
	[":n_quanjia"] = "每当【杀】或【决斗】指定目标后，若你既不是使用者也不是目标，你可以弃置一张黑色牌，令使用者与目标各摸一张牌，然后此牌无效。",
	["n_liyou"] = "利诱",
	["$n_liyou1"] = "金坷垃好处都有啥，谁说对了就给他！",
	["$n_liyou2"] = "非洲农业不发达，我们都要支援他！金坷垃，你们日本别想啦！",
	["$n_liyou3"] = "金坷垃，别想啦！",
	[":n_liyou"] = "阶段技。你可以指定两名其他角色拼点，然后你可以交给赢家一张红色牌并对没赢的角色造成一点伤害。",
	["n_liyouCard"] = "利诱",
	["#liyouGive"] = "你可以交给 %src 一张红色牌，对另一方造成一点伤害",
}

n_boyinyuan = sgs.General(extension,"n_boyinyuan","n_web",5)
n_yuyincard = sgs.CreateSkillCard{
	name = "n_yuyincard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, selected, to_select)
		return (#selected == 0) and (to_select:objectName() ~= sgs.Self:objectName())
	end,
	on_effect = function(self, effect)
	    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
		local from = effect.from
		local to = effect.to
		local room = from:getRoom()
		to:drawCards(1)
		room:obtainCard(to,self,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, 
					from:objectName(), to:objectName(), "n_yuyin", ""))
		local x = 0
		if from:getMark("n_dedao") > 0 then x = 1 end
		if from:getMark("n_mohua") > 0 then x = 2 end
		if x == 0 then
			room:broadcastSkillInvoke("n_yuyin",math.random(1,2))
		elseif x == 1 then
			room:broadcastSkillInvoke("n_yuyin",math.random(3,4))
		elseif x == 2 then
			room:broadcastSkillInvoke("n_yuyin",math.random(5,6))
		end
		
		if x ~= 0 then
			for i = 1,x do
				if to:isAllNude() then break end
				room:obtainCard(from,room:askForCardChosen(from,to,"hej","n_yuyin"),false)
			end
		end
	end
}
n_yuyinvs = sgs.CreateViewAsSkill{
	name = "n_yuyin",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self,cards)
		if #cards == 0 then return nil end
		local card = n_yuyincard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_yuyincard")
	end,
}
n_yuyin = sgs.CreateTriggerSkill{
	name = "n_yuyin",
	events = {sgs.PreCardUsed},
	view_as_skill = n_yuyinvs,
	on_trigger = function(self,event,player,data)
		if data:toCardUse().card:objectName() == "n_yuyincard" then return true end
	end
}
n_boyinyuan:addSkill(n_yuyin)
n_dedao = sgs.CreateTriggerSkill{
	name = "n_dedao",
	events = {sgs.Damaged},
	frequency = sgs.Skill_Wake,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:addPlayerMark(player, "n_dedao")
		room:broadcastSkillInvoke("n_dedao")
		room:doSuperLightbox("n_boyinyuan", "n_dedao")
		if room:changeMaxHpForAwakenSkill(player) then
			player:drawCards(1)
			room:handleAcquireDetachSkills(player, "n_mohua")
		end
		return false
	end ,
	can_trigger = function(self, target)
		return (target and target:isAlive() and target:hasSkill(self:objectName()))
				and (target:getMark("n_dedao") == 0)
	end
}
n_boyinyuan:addSkill(n_dedao)
n_mohua = sgs.CreateTriggerSkill{
	name = "n_mohua" ,
	events = {sgs.EventPhaseStart} ,
	frequency = sgs.Skill_Wake ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:addPlayerMark(player, "n_mohua")
		room:broadcastSkillInvoke("n_mohua")
		room:doSuperLightbox("n_boyinyuan", "n_mohua")
		if room:changeMaxHpForAwakenSkill(player) then
			room:handleAcquireDetachSkills(player, "n_yindao")
		end
		return false
	end ,
	can_trigger = function(self, target)
		return (target and target:isAlive() and target:hasSkill(self:objectName()))
				and (target:getMark("n_mohua") == 0)
				and (target:getHandcardNum() <= target:getLostHp())
				and (target:getPhase() == sgs.Player_Start)
	end
}
n_anjiang:addSkill(n_mohua)
n_boyinyuan:addRelateSkill("n_mohua")
n_yindaocard = sgs.CreateSkillCard{
	name = "n_yindaocard",
	target_fixed = false,
	filter = function(self, selected, to_select)
		return (#selected == 0) and to_select:isWounded() and not to_select:isKongcheng()
	end,
	on_effect = function(self, effect)
		local from = effect.from
		local to = effect.to
		local room = to:getRoom()
		
		local card
		if from:objectName() == to:objectName() then
			card = room:askForCardShow(to, from, "n_yindao")
		else
			local id = room:askForCardChosen(from, to, "h", "n_yindao")
			card = sgs.Sanguosha:getCard(id)
		end
		room:showCard(to, card:getEffectiveId())
		if card:getSuit() == sgs.Card_Diamond then
			room:broadcastSkillInvoke("n_yindao",2)
			if not to:isJilei(card) then
				room:throwCard(card, to)
			end
			local recover = sgs.RecoverStruct()
			recover.who = from
			room:recover(to, recover)
		else
			room:broadcastSkillInvoke("n_yindao",1)
		end
	end
}
n_yindaovs = sgs.CreateViewAsSkill{
	name = "n_yindao",
	n = 0,
	view_as = function(self,card)
		return n_yindaocard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_yindaocard")
	end,
}
n_yindao = sgs.CreateTriggerSkill{
	name = "n_yindao", 
	view_as_skill = n_yindaovs, 
	events = {sgs.PreCardUsed}, 
	on_trigger = function(self, event, player, data)
		if data:toCardUse().card:objectName() == "n_yindaocard" then return true end
	end, 
}
n_anjiang:addSkill(n_yindao)
n_boyinyuan:addRelateSkill("n_yindao")
sgs.LoadTranslationTable{
	["n_boyinyuan"] = "神秘播音员",
	["#n_boyinyuan"] = "圣战始终焉",
	["&n_boyinyuan"] = "播音员",
	["designer:n_boyinyuan"] = "Notify",
	["illustrator:n_boyinyuan"] = "来自网络",
	["n_yuyin"] = "玉音",
	["@yuyin"] = "玉音：可以选择一张牌和一名其他角色发动“玉音”",
	[":n_yuyin"] = "阶段技。你可以令一名其他角色摸一张牌，然后你交给其一张手牌。\
	修改1：..交给其一张手牌并获得其一张牌。\
	修改2：..交给其一张手牌并获得其两张牌。",
	["$n_yuyin1"] = "注意，回答听力部分时，请先将答案标在试卷上。",
	["$n_yuyin2"] = "现在是听力试音时间。",
	["$n_yuyin3"] = "每段对话仅读一遍。",
	["$n_yuyin4"] = "现在，你有五秒钟的时间看试卷上的例题。",
	["$n_yuyin5"] = "每段对话或独白读两遍。",
	["$n_yuyin6"] = "听下面五段对话或独白。",
	["n_dedao"] = "得道",
	[":n_dedao"] = "觉醒技。你受到伤害后，失去一点体力上限并摸一张牌，获得“魔化”，并修改“玉音”。",
	["$n_dedao"] = "试音到此结束。听力考试正式开始。",
	["n_mohua"] = "魔化",
	[":n_mohua"] = "觉醒技。准备阶段，若你的手牌数不超过已损失体力值，你失去一点体力上限并获得“引导”，然后修改“玉音”。",
	["$n_mohua"] = "第一节到此结束。第二节...",
	["n_yindao"] = "引导",
	[":n_yindao"] = "阶段技。你可以展示一名角色的一张牌，若为方块，其弃置之并回复一点体力。",
	["$n_yindao1"] = "衬衫的价格为九磅十五便士！",
	["$n_yindao2"] = "所以，你选择C项，并将其标在试卷上。",
	["~n_boyinyuan"] = "听力考试...到此结束...",
}

n_gaoyinge = sgs.General(extension,"n_gaoyinge","n_web")
n_gaoyin = sgs.CreateTriggerSkill{
	name = "n_gaoyin",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local use = data:toCardUse()
		local x = use.card:getNumber()
		if (not use.card:isKindOf("SkillCard") and x > 9) then
			if room:askForSkillInvoke(player,self:objectName()) then
				room:broadcastSkillInvoke(self:objectName(),math.max(1, x-10))
				player:drawCards(x == 13 and 2 or 1)
			end
		end
		return false
	end
}

n_gaoyinge:addSkill(n_gaoyin)
sgs.LoadTranslationTable{
	["n_gaoyinge"] = "高音哥",
	["#n_gaoyinge"] = "灭掉世界",
	["~n_gaoyinge"] = "其实我心里知道，我已经赢了",
	--["cv:n_zeroona"] = "zeroOna",
	["designer:n_gaoyinge"] = "Notify",
	["illustrator:n_gaoyinge"] = "来自网络",
	["n_gaoyin"] = "高音",
	["$n_gaoyin1"] = "我的高音在这个世界上，比任何人都高",
	["$n_gaoyin2"] = "我会用自己的音乐，去成为这个世界所认可的音乐神话",
	["$n_gaoyin3"] = "三天三夜~三更半夜~",
	[":n_gaoyin"] = "你使用点数>=10的牌后，可以摸一张牌；若点数为K，改为摸两张。",--
}

n_shenyi = sgs.General(extension,"n_shenyi","n_web",3)
n_laofangcard = sgs.CreateSkillCard{
	name = "n_laofangcard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, selected, to_select)
		return (#selected == 0) and (to_select:objectName() ~= sgs.Self:objectName()) and (to_select:isWounded())
	end,
	on_effect = function(self,effect)
		local from = effect.from
		local to = effect.to
		local recover = sgs.RecoverStruct()
		recover.who = from
		recover.recover = to:getLostHp()
		local room = to:getRoom()
		room:recover(to,recover)
		to:gainMark("@n_poison",recover.recover+1)
	end
}
n_laofang = sgs.CreateViewAsSkill{
	name = "n_laofang",
	n = 2,
	view_filter = function(self, selected, to_select)
		return to_select:isBlack()
	end ,
	view_as = function(self, cards)
		if #cards ~= 2 then return nil end
		local card = n_laofangcard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end ,
}
n_shenyi:addSkill(n_laofang)
n_moucai = sgs.CreateTriggerSkill{
	name = "n_moucai",
	frequency = sgs.Skill_Compulsory,
	events = sgs.HpRecover,
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local recover = data:toRecover()
		if recover.who and recover.who:hasSkill(self:objectName()) 
		and player:objectName() ~= recover.who:objectName() and not player:isKongcheng() then
			n_CompulsorySkill(room,recover.who,self:objectName())
			n_askForGiveCardTo(player,recover.who,self:objectName(),".|.|.|hand!","#moucaigive:"..recover.who:getGeneralName(),true)
			return false
		end
	end
}
n_shenyi:addSkill(n_moucai)
sgs.LoadTranslationTable{
	["n_shenyi"] = "雄凤山",
	["#n_shenyi"] = "治死方休",
	["~n_shenyi"] = "服药三十天，少活两百年。",
	["@n_poison"] = "毒",
	["designer:n_shenyi"] = "Notify",
	["illustrator:n_shenyi"] = "来自网络",
	["n_laofang"] = "老方",
	[":n_laofang"] = "出牌阶段，你可以弃两张黑色牌，令一名其他角色恢复x点体力（x为其损失体力值）并获得x+1枚“毒”。",
	["$n_laofang1"] = "用上我的药，保证你去世！",
	["$n_laofang2"] = "就没有我治不死的风湿病！！",
	["n_moucai"] = "谋财",
	[":n_moucai"] = "锁定技。你令其他角色恢复体力后，其必须交给你一张手牌。",
	["#moucaigive"] = "%src 治了你的病，给张手牌表示一下！",
	["$n_moucai1"] = "我们雄家三百多年不赚诚信钱！",
	["$n_moucai2"] = "穷人辛苦攒点钱，我就是累死也要赚！",
}

n_lubenwei = sgs.General(extension,"n_lubenwei","n_web",3,true,true)
n_kaigua = sgs.CreateTriggerSkill{
	name = "n_kaigua",
	events = {sgs.EventPhaseStart},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if player:getMark("@n_gua") < 3 and player:getPhase() == sgs.Player_Start and player:askForSkillInvoke(self:objectName()) then
			room:addPlayerMark(player,"@n_gua",1)
			room:broadcastSkillInvoke(self:objectName())
			local allplayers = room:getPlayers() 
			local allnames = sgs.Sanguosha:getLimitedGeneralNames() 
			for _,player in sgs.qlist(allplayers) do
				local name = player:getGeneralName()
				allnames[name] = nil
			end

            math.randomseed(tostring(os.time()):reverse():sub(1, 7))
			local targets = {}
			for i=1, 5, 1 do
				local count = #allnames
				local index = math.random(1, count)  
				local selected = allnames[index] 
				table.insert(targets, selected) 
				allnames[selected] = nil 
			end
			local generals = table.concat(targets, "+")
			local general = room:askForGeneral(player, generals) 
			room:changeHero(player,general,true)
			room:setPlayerProperty(player,"maxhp",sgs.QVariant(2))
		end
	end
}
n_lubenwei:addSkill(n_kaigua)
n_kaiguatrig = sgs.CreateTriggerSkill{
	name = "#n_kaiguatrig",
	global = true,
	events = {sgs.EnterDying},
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if (player:getMark("@n_gua") > 0) and not player:hasSkill("n_kaigua") then
			room:changeHero(player,"n_lubenwei",true)
			if player:getMark("@n_gua") < 3 and player:askForSkillInvoke("n_kaigua") then
				room:addPlayerMark(player,"@n_gua",1)
				room:broadcastSkillInvoke("n_kaigua")
			local allplayers = room:getPlayers() 
			local allnames = sgs.Sanguosha:getLimitedGeneralNames() 
			for _,player in sgs.qlist(allplayers) do
				local name = player:getGeneralName()
				allnames[name] = nil
			end

			local targets = {}
			for i=1, 5, 1 do
				local count = #allnames
				local index = math.random(1, count)  
				local selected = allnames[index] 
				table.insert(targets, selected) 
				allnames[selected] = nil 
			end
			local generals = table.concat(targets, "+")
			local general = room:askForGeneral(player, generals) 
			room:changeHero(player,general,true)
			room:setPlayerProperty(player,"maxhp",sgs.QVariant(2))
			end
			return true
		end
	end
}
n_anjiang:addSkill(n_kaiguatrig)
n_bianjie = sgs.CreateTriggerSkill{
	name = "n_bianjie" ,
	events = {sgs.CardUsed, sgs.EventPhaseChanging} ,
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed and player:getPhase() == sgs.Player_Play then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") and not use.card:isNDTrick() then return false end
			local first = sgs.SPlayerList()
			for _,to in sgs.qlist(use.to) do
				if to:objectName() ~= player:objectName() and not to:hasFlag("n_bianjieEffect") then
					first:append(to)
					to:setFlags("n_bianjieEffect")
				end
			end
			for _,p in sgs.qlist(room:getOtherPlayers(use.from)) do
				if use.to:contains(p) and not first:contains(p) and p:canDiscard(use.from, "he") and  p:hasFlag("n_bianjieEffect") and p:isAlive() and p:hasSkill(self:objectName()) and p:getMark("@n_gua")>=3 then
					if not room:askForSkillInvoke(p, self:objectName(), data) then return false end
					p:drawCards(1)
					room:broadcastSkillInvoke(self:objectName())
					room:throwCard(room:askForCardChosen(p, use.from, "he", self:objectName(), false, sgs.Card_MethodDiscard), use.from, p)
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				for _,to in sgs.qlist(room:getAlivePlayers()) do
					if to:hasFlag("n_bianjieEffect") then
						to:setFlags("-n_bianjieEffect")
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end
}
n_lubenwei:addSkill(n_bianjie)
sgs.LoadTranslationTable{
	["n_lubenwei"] = "卢本伟-旧",
	["&n_lubenwei"] = "卢本伟",
	["designer:n_lubenwei"] = "Notify",
	["illustrator:n_lubenwei"] = "网络",
	["~n_lubenwei"] = "你今天十七张牌能把卢本伟秒了，我当场，就把这个电脑屏幕吃掉！！（飞机~~）（啊真香）",
	["#n_lubenwei"] = "绝地科学家",
	["n_kaigua"] = "开挂",
	[":n_kaigua"] = "开始阶段，你可以随机获得五名未上场的武将，变身（2上限）。开挂武将进濒死时你回到本体然后可再次开挂。整局游戏只能开3次。",
	["$n_kaigua1"] = "你们可能不知道，只用20W，赢到578W，是什么概念。我们一般只会用两个字来形容这种人：土块。",
	["$n_kaigua2"] = "我经常说一句话，当年陈刀仔，他能用20块赢到3700W，我卢本伟用20W赢到500W，不是问题。",
	["n_bianjie"] = "辩解",
	[":n_bianjie"] = "3次开挂后，对手于其出牌阶段内对包括你的角色使用第二张及以上【杀】或非延时锦囊牌时，你可以摸一弃置其一张牌。",
	["$n_bianjie"] = "LBWNB！",
}

n_yangyongxin = sgs.General(extension,"n_yangyongxin","n_web",3)
n_dianliao = sgs.CreateTriggerSkill{
	name = "n_dianliao" ,
	events = {sgs.DamageCaused} ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		if damage.nature == sgs.DamageStruct_Thunder and player:askForSkillInvoke(self:objectName(),data) then
			room:broadcastSkillInvoke(self:objectName())
			local judge = sgs.JudgeStruct()
			judge.pattern = ".|spade"
			judge.good = true
			judge.reason = self:objectName()
			judge.who = damage.from
			room:judge(judge)
			if judge:isGood() and damage.to:isAlive() then
				local shaoying_damage = sgs.DamageStruct()
				shaoying_damage.nature = sgs.DamageStruct_Thunder
				shaoying_damage.from = damage.from
				shaoying_damage.to = damage.to
				room:damage(shaoying_damage)
			end
		end
	end ,
}
n_dianliaovs = sgs.CreateFilterSkill{
	name = "#n_dianliaovs",	
	view_filter = function(self,to_select)
		return (to_select:isBlack()) and (to_select:isKindOf("Slash"))
	end,	
	view_as = function(self, card)
		local slash = sgs.Sanguosha:cloneCard("thunder_slash", card:getSuit(), card:getNumber())
		slash:setSkillName(self:objectName())
		local _card = sgs.Sanguosha:getWrappedCard(card:getId())
		_card:takeOver(slash)
		return _card
	end
}
n_yangyongxin:addSkill(n_dianliaovs)
n_yangyongxin:addSkill(n_dianliao)
n_heiyan = sgs.CreateFilterSkill{
	name = "n_heiyan",
	view_filter = function(self, to_select)
		return to_select:getSuit() == sgs.Card_Heart
	end,
	view_as = function(self, card)
		local id = card:getEffectiveId()
		local new_card = sgs.Sanguosha:getWrappedCard(id)
		new_card:setSkillName(self:objectName())
		new_card:setSuit(sgs.Card_Spade)
		new_card:setModified(true)
		return new_card
	end
}
n_anjiang:addSkill(n_heiyan)
n_yangyongxin:addRelateSkill("n_heiyan")
n_quyin = sgs.CreateTriggerSkill{
	name = "n_quyin" ,
	events = {sgs.Damage} ,
	frequency = sgs.Skill_Frequent,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		if damage.nature == sgs.DamageStruct_Thunder and player:getMark("n_quyins")<3 and not damage.to:isNude() and player:askForSkillInvoke(self:objectName()) then
			room:broadcastSkillInvoke(self:objectName())
			room:obtainCard(player,room:askForCardChosen(player,damage.to,"hej","n_quyin"),false)
			room:addPlayerMark(player,"n_quyins",1)
			if player:getMark("n_quyins")>=3 then
				room:handleAcquireDetachSkills(player, "-n_quyin|n_heiyan")
			end
		end
	end ,
}
n_yangyongxin:addSkill(n_quyin)
sgs.LoadTranslationTable{
	["n_yangyongxin"] = "杨永信",
	["designer:n_yangyongxin"] = "Notify",
	["cv:n_yangyongxin"] = "ChongMei Xu",
	["illustrator:n_yangyongxin"] = "网络",
	["#n_yangyongxin"] = "磁暴步兵",
	["~n_yangyongxin"] = "吴军豹，剩下的就看你了……",
	["n_dianliao"] = "电疗",
	[":n_dianliao"] = "你造成雷电伤害时可进行一次判定，若为黑桃则对对方造成一点雷电伤害。你的黑色杀视为雷杀。",
	["$n_dianliao1"] = "让这电流，净化你的心灵！",
	["$n_dianliao2"] = "来吧！直面来自电流的恐惧！",
	["#n_dianliaovs"] = "电疗",
	["n_quyin"] = "去瘾",
	[":n_quyin"] = "你造成雷电伤害后可获得对方一张牌，获得第三张牌时本技能改为“黑颜”。",
	["$n_quyin1"] = "网瘾多大点事，电电就好了。",
	["$n_quyin2"] = "孩子，我这是在救你。",
	["n_heiyan"] = "黑颜",
	[":n_heiyan"] = "锁定技。你的红桃牌视为黑桃牌。",
}

n_huanghe = sgs.General(extension,"n_huanghe","n_web",3)
n_juankuan = sgs.CreateTriggerSkill{
	name = "n_juankuan",
	events = {sgs.EventPhaseStart},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local players = room:getOtherPlayers(player)
		if player:getPhase() == sgs.Player_Draw then
			local can_invoke = false
			for _, p in sgs.qlist(players) do
				if not p:isAllNude() then
					can_invoke = true
					break
				end
			end
			if not can_invoke then return end
			if player:askForSkillInvoke(self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName())
				for _, _player in sgs.qlist(players) do
					if _player:isAlive() and (not _player:isAllNude()) then
						local card_id = room:askForCardChosen(player, _player, "hej", self:objectName())
						room:obtainCard(player, sgs.Sanguosha:getCard(card_id), room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
						room:addPlayerMark(_player,"n_juankuantar")
					end
				end
				return true
			end
		else
			if player:getPhase() == sgs.Player_Discard then
				for _, p in sgs.qlist(players) do
					if p:getMark("n_juankuantar")>0 and not player:isAllNude() then
						local card_id = room:askForCardChosen(p,player, "hej", self:objectName())
						room:obtainCard(p, sgs.Sanguosha:getCard(card_id), room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
					end
				end
			elseif player:getPhase() == sgs.Player_Finish then
				for _, p in sgs.qlist(players) do
					room:setPlayerMark(p,"n_juankuantar",0)
				end
			end
		end
	end
}
n_huanghe:addSkill(n_juankuan)
n_qiantao = sgs.CreateTriggerSkill{
	name = "n_qiantao",
	events = sgs.EventPhaseChanging,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to == sgs.Player_Discard and player:askForSkillInvoke(self:objectName()) then
			room:broadcastSkillInvoke(self:objectName())
			player:skip(change.to)
			player:turnOver()
		end
	end
}
n_huanghe:addSkill(n_qiantao)
n_zhongchou = sgs.CreateTriggerSkill{
	name = "n_zhongchou",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local x = damage.from:getHandcardNum()+damage.from:getHp()
		if damage.card and damage.card:isKindOf("Slash") and x<=player:getHandcardNum() then
			room:broadcastSkillInvoke(self:objectName())
			local msg = sgs.LogMessage()
			msg.type = "#zhongchoudamage"
			msg.from = player
			msg.arg = damage.damage
			msg.arg2 = damage.damage + 1
			damage.damage = damage.damage + 1
			room:sendLog(msg)
			data:setValue(damage)
		end
		return
	end,
}
n_huanghe:addSkill(n_zhongchou)
sgs.LoadTranslationTable{
	["n_huanghe"] = "黄鹤",
	["designer:n_huanghe"] = "Notify",
	["illustrator:n_huanghe"] = "网络",
	["#n_huanghe"] = "王八蛋老板",
	["~n_huanghe"] = "江南皮革厂倒闭了！",
	["n_juankuan"] = "卷款",
	["$n_juankuan"] = "黄鹤欠下了3.5个亿！",
	[":n_juankuan"] = "摸牌阶段，你可以改为获得所有其他角色各一张牌，若如此，弃牌阶段开始时，所有本回合被“卷款”的角色依次获得你一张牌。",
	["n_qiantao"] = "潜逃",
	["$n_qiantao"] = "黄鹤带着他的小姨子跑了！",
	[":n_qiantao"] = "你可以跳过弃牌阶段并翻面。你背面向上时其他角色与你计算距离时+1。",
	["#n_qiantaodis"] = "潜逃",
	["n_zhongchou"] = "众仇",
	["$n_zhongchou"] = "黄鹤王八蛋，你不是人！",
	[":n_zhongchou"] = "锁定技。手牌数与体力值之和低于你手牌数的角色使用【杀】对你造成的伤害+1。",
	["#zhongchoudamage"] = "%from 的 \"<font color=\"yellow\"><b>众仇</b></font>\" 效果被触发，伤害由 %arg 点增加至 %arg2 点",
}

n_dongyongguaige = sgs.General(extension,"n_dongyongguaige","n_web")
n_zhenli = sgs.CreateTriggerSkill{
	name = "n_zhenli",
	events = sgs.Damaged,
	can_trigger = function(self,target)
		return target and target:isAlive()
	end,
	on_trigger = function(self,event,player,data)	
		local room = player:getRoom()
		local _data = sgs.QVariant()
		_data:setValue(player)
		if player:isDead() then return end
		for _,olf in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if olf:askForSkillInvoke(self:objectName(),_data) then
				room:broadcastSkillInvoke(self:objectName())
				local lx = true
				local others = room:getOtherPlayers(player)
				for _,p in sgs.qlist(others) do
					if p:getHandcardNum() <= player:getHandcardNum() then
						lx = false
						break
					end
				end
				-- if not lx then
				--	lx = (player:getHp() == 1)
				-- end
				player:drawCards(lx and 2 or 1)
			end
		end
	end,
}
n_dongyongguaige:addSkill(n_zhenli)
sgs.LoadTranslationTable{
	["n_dongyongguaige"] = "冬泳怪鸽",
	["designer:n_dongyongguaige"] = "Notify",
	["illustrator:n_dongyongguaige"] = "网络",
	["#n_dongyongguaige"] = "巨魔战将",
	["&n_dongyongguaige"] = "巨魔",
	["n_zhenli"] = "振励",
	["$n_zhenli1"] = "我们遇到什么困难，也不要怕！",
	["$n_zhenli2"] = "微笑着面对他！",
	["$n_zhenli3"] = "消除恐惧的最好办法就是面对恐惧！",
	["$n_zhenli4"] = "坚持，才是胜利！",
	["$n_zhenli5"] = "加油！奥利给！",
	["~n_dongyongguaige"] = "我愿把双眼化作灯塔，照亮你们远大的前程！",
	[":n_zhenli"] = "一名角色受到伤害后，你可以令其摸一张牌；如果他手牌唯一最少，改为摸2张。",
}

n_huanong = sgs.General(extension,"n_huanong","n_web")
n_xicun = sgs.CreateViewAsSkill{
    name = "n_xicun",
    n = 996,
	view_filter = function()
		return true
	end,
    view_as = function(self,cards)
		local need = 2
		if sgs.Self:usedTimes("Snatch") == 0 then need = 1 end
        if #cards == need then
            local snatch = sgs.Sanguosha:cloneCard("snatch",sgs.Card_SuitToBeDecided,0)
            for _,c in ipairs(cards) do snatch:addSubcard(c) end
            snatch:setSkillName(self:objectName())
            return snatch
        end
    end,
}
n_huanong:addSkill(n_xicun)
sgs.LoadTranslationTable{
    ["n_huanong"] = "华农兄弟",
    ["#n_huanong"] = "村霸",
    ["designer:n_huanong"] = "Notify",
    ["illustrator:n_huanong"] = "来自网络",
    ["~n_huanong"] = "好，今天上火了，在这样下去的话肯定吃不消的",
    ["n_xicun"] = "袭村",
    [":n_xicun"] = "你可以将两张牌当顺手牵羊使用。如果本回合未使用过顺手牵羊，则只需要一张牌。",
    ["$n_xicun1"] = "来兄弟家的菜地里摘点兄弟家的菜叶子",
    ["$n_xicun2"] = "大家好，现在兄弟不在家，他家的茶叶园没人管。你看都长辣么长了，再不摘的话可能会老掉，我们来摘一点来泡茶",
}

n_dingding = sgs.General(extension,"n_dingding","n_web",3,false)
n_jiding = sgs.CreateTriggerSkill{
    name = "n_jiding",
    view_as_skill = n_jidingvs,
    events = sgs.CardUsed,
    can_trigger = function(self,target)
        return target
    end,
    on_trigger = function(self,event,playerr,data)
        local room = playerr:getRoom()
		local player = data:toCardUse().from
        math.randomseed(tostring(os.time()):reverse():sub(1, 7))
        for _,dd in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
            if math.random()<0.1 then
                local slash = sgs.Sanguosha:cloneCard("slash")
                slash:setSkillName(self:objectName())
                if dd:canSlash(player,slash,false) then
                    local d = sgs.QVariant()
                    d:setValue(player)
                    if room:askForSkillInvoke(dd,self:objectName(),d) then
                        local use = sgs.CardUseStruct()
                        use.from = dd
                        use.to:append(player)
                        use.card = slash
                        room:useCard(use)
                    end
                end
            end
        end
    end
}
n_dingding:addSkill(n_jiding)
sgs.LoadTranslationTable{
    ["n_dingding"] = "钉钉",
    ["#n_dingding"] = "恐惧",
    ["designer:n_dingding"] = "Notify",
    ["illustrator:n_dingding"] = "钉钉Dingtalk",
    ["~n_dingding"] = "（钉三下）",
    ["n_jiding"] = "急钉",
    [":n_jiding"] = "某时，你可以视为对该时机承受者使用【杀】。",
    ["$n_jiding"] = "（钉一下）",
}

n_jiege = sgs.General(extension,"n_jiege","n_web")
n_yaoqingcard = sgs.CreateSkillCard{
    name = "n_yaoqingcard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select) 
		return to_select:objectName() ~= sgs.Self:objectName() and not to_select:isAdjacentTo(sgs.Self)
	end,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_effect = function(self,effect)
	    local from,to = effect.from,effect.to
		local room = from:getRoom()
		room:obtainCard(to,self,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, 
           to:objectName(), from:objectName(), "n_yaoqing", ""),false)
		to:turnOver()
		local nxt = from:getNextAlive()
		room:swapSeat(to,nxt)
		local wine = sgs.Sanguosha:cloneCard("analeptic")
		wine:setSkillName("n_yaoqing")
		if not room:isProhibited(from,to,wine) then
		    local use = sgs.CardUseStruct()
			use.from = from
			use.to:append(to)
			use.card = wine
			room:useCard(use)
		end
	end,
}
n_yaoqing = sgs.CreateViewAsSkill{
    name = "n_yaoqing",
	n = 2,
	view_filter = function() return true end,
	view_as = function(self,cards)
	    if #cards == 2 then
		    local card = n_yaoqingcard:clone()
			for _,c in ipairs(cards) do
			    card:addSubcard(c)
	        end
			card:setSkillName(self:objectName())
			return card
		end
	end,
	enabled_at_play = function(self,player)
	    return not player:hasUsed("#n_yaoqingcard")
	end,
}
n_jiege:addSkill(n_yaoqing)
n_kangkang = sgs.CreateTriggerSkill{
    name = "n_kangkang",
	events = sgs.DamageCaused,
	on_trigger = function(self,event,player,data)
	    local room = player:getRoom()
		local to = data:toDamage().to
		if to:isAdjacentTo(player) and to:faceUp() and not to:isKongcheng() then
		    local d = sgs.QVariant()
			d:setValue(to)
			if room:askForSkillInvoke(player,self:objectName(),d) then
			    room:broadcastSkillInvoke(self:objectName())
			    local handcards = to:handCards()
				room:fillAG(handcards,player)
			    local card_id = room:askForAG(player,handcards,false,self:objectName())
				room:obtainCard(player,card_id,false)
				room:clearAG(player)
			end
		end
	end,
}
n_jiege:addSkill(n_kangkang)
sgs.LoadTranslationTable{
    ["n_jiege"] = "杰哥",
	["#n_jiege"] = "转大人指导",
	["designer:n_jiege"] = "zyc12241252",
	["illustrator:n_jiege"] = "网络",
	["~n_jiege"] = "阿伟，..你要干嘛、，，对不起",
	["n_yaoqing"] = "邀请",
	[":n_yaoqing"] = "阶段技。你可以交给一名与你不相邻的角色两张牌，然后其翻面并与你的下家交换座次，视为对其使用【酒】。",
	["$n_yaoqing1"] = "我一个住，我的房子还蛮大的，欢迎你们来我家玩，",
	["$n_yaoqing2"] = "如果要来的话，我可以带你们去超商，买一些好吃的哦。",
	["n_kangkang"] = "康康",
	[":n_kangkang"] = "你对与你座次相邻且正面向上的角色造成伤害时，你可以观看其手牌并获得其中一张。",
    ["$n_kangkang1"] = "哎呦，你脸红了，来，让我康康。",
    ["$n_kangkang2"] = "让我康康！",
}

n_awei = sgs.General(extension,"n_awei","n_web",3)
suijie_patterns = {
    "peach",
	"analeptic",
	"amazing_grace",
	"god_salvation",
}
n_suijie = sgs.CreateTriggerSkill{
    name = "n_suijie",
	events = sgs.TargetConfirmed,
	on_trigger = function(self,event,player,data)
	    local room = player:getRoom()
		local use = data:toCardUse()
		if table.contains(suijie_patterns,use.card:objectName())
		and use.to:contains(player) and use.from:objectName() ~= player:objectName() then
		    local d = sgs.QVariant()
			d:setValue(use.from)
			if room:askForSkillInvoke(player,self:objectName(),d) then
			    room:broadcastSkillInvoke(self:objectName())
			    use.from:drawCards(1)
			    
				local a,b = use.from:getHandcardNum(),player:getHandcardNum()
				if a>b then player:drawCards(a-b) end
			end
		end
	end,
}
n_awei:addSkill(n_suijie)
jujie_patterns = {
	"slash",
	"fire_slash",
	"thunder_slash",
	"archery_attack",
	"duel",
	"fire_attack",
	"savage_assault",
	"n_brick",
}
n_jujie = sgs.CreateTriggerSkill{
    name = "n_jujie",
	events = {sgs.TargetConfirmed,sgs.Damaged},
	on_trigger = function(self,event,player,data)
	    local room = player:getRoom()
		if event == sgs.TargetConfirmed then
	        local use = data:toCardUse()
			if table.contains(jujie_patterns,use.card:objectName())
			and use.to:contains(player) and use.from:objectName() ~= player:objectName() then
				local d = sgs.QVariant()
				d:setValue(use.from)
				if room:askForSkillInvoke(player,self:objectName(),d) then
				    room:broadcastSkillInvoke(self:objectName())
					room:askForDiscard(player,self:objectName(),1,1,false,true)
					room:setTag("n_jujieing",data)
				end
			end
		elseif event == sgs.Damaged then
		    local damage = data:toDamage()
			local tag = room:getTag("n_jujieing")
			local use = nil
			if tag and tag:toCardUse() then use = tag:toCardUse() else return end
			if damage.card and damage.card:getEffectiveId() == use.card:getEffectiveId()
			and damage.from:objectName() == use.from:objectName()
			and use.to:contains(player) then
			    local a,b = use.from:getHandcardNum(),player:getHandcardNum()
				if a>b then room:askForDiscard(use.from,self:objectName(),a-b,a-b) end
			end
		end
	end,
}
n_awei:addSkill(n_jujie)
sgs.LoadTranslationTable{
    ["n_awei"] = "阿伟",
	["#n_awei"] = "在杰难逃",
	["designer:n_awei"] = "Notify",
	["illustrator:n_awei"] = "网络",
	["~n_awei"] = "透，死了啦，都是你害的啦，拜托！",
	["n_suijie"] = "随杰",
	[":n_suijie"] = "其他角色对你使用【桃】【酒】【五谷丰登】【桃园结义】后，你可以令其摸一张牌并将手牌数摸至与其相等",
	["$n_suijie1"] = "杰哥，那我和我朋友先去住你家哦。",
	["$n_suijie2"] = "谢杰哥。",
	["n_jujie"] = "拒杰",
	[":n_jujie"] = "其他角色对你使用会造成伤害的牌后，你可以弃一张牌，然后若此牌对你造成伤害，伤害来源将手牌数弃置至与你相等",
    ["$n_jujie"] = "不要啦，杰哥，你干嘛。",
}

n_zhangsan = sgs.General(extension,"n_zhangsan","n_web",3,true,true)
n_kuanglang = sgs.CreateTriggerSkill{
    name = "n_kuanglang",
    events = {sgs.Damaged},
    can_trigger = function(self,target) return target end,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local damage = data:toDamage()
        local card = damage.card
        if card then
            local id = card:getEffectiveId()
            for _,p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
                if p:objectName() ~= damage.to:objectName() and room:getCardPlace(id) == sgs.Player_PlaceTable then
                    local card_data = sgs.QVariant()
                    card_data:setValue(card)
                    if room:askForSkillInvoke(p, self:objectName(), card_data) then
                        room:broadcastSkillInvoke(self:objectName())
                        p:obtainCard(card)
                        if p:objectName() == damage.from:objectName() then
                            room:askForDiscard(p,self:objectName(),2,2,false,true)
                        end
                    end
                else break end
            end
        end
    end
}
n_zhangsan:addSkill(n_kuanglang)
sgs.LoadTranslationTable{
    ["n_zhangsan"] = "张三",
    ["#n_zhangsan"] = "法外狂徒",
    ["designer:n_zhangsan"] = "发烟碳酸",
    ["illustrator:n_zhangsan"] = "网络",
    ["n_kuanglang"] = "狂浪",
    [":n_kuanglang"] = "你可以获得对其他角色造成伤害的牌，若你是伤害来源则你需弃两张牌。",
}

n_liangyifeng = sgs.General(extension,"n_liangyifeng","n_web",3)
n_songshicard = sgs.CreateSkillCard{
    name = "n_songshicard",
    target_fixed = true,
	on_use = function(self,room,source,targets)
		room:showAllCards(source)
		local blacks = sgs.IntList()
		local reds = sgs.IntList()
		for _,c in sgs.qlist(source:getHandcards()) do
			if c:isRed() then
				reds:append(c:getId())
			else
				blacks:append(c:getId())
			end
		end
		if (reds:isEmpty() or blacks:isEmpty()) then return end
		local to_discard = room:askForChoice(source, "n_songshi", "black+red")
		if (to_discard == "black") then pile = blacks
		else pile = reds end
		local n = pile:length()
		local dm = sgs.Sanguosha:cloneCard("slash")
		for _,c in sgs.qlist(pile) do
			dm:addSubcard(c)
		end
		room:throwCard(dm, source)
		local todraw = sgs.IntList()
		local drawpile = room:getDrawPile()
		for _,c in sgs.qlist(drawpile) do
			if sgs.Sanguosha:getCard(c):isRed() ~= sgs.Sanguosha:getCard(pile:first()):isRed() then
				todraw:append(c)
				if todraw:length() == n then break end
			end
		end
		if todraw:length() < n then
			room:swapPile()
			todraw = sgs.IntList()
			for _,c in sgs.qlist(drawpile) do
				if sgs.Sanguosha:getCard(c):isRed() ~= sgs.Sanguosha:getCard(pile:first()):isRed() then
					todraw:append(c)
					if todraw:length() == n then break end
				end
			end
		end
		local draw = sgs.Sanguosha:cloneCard("slash")
		for _,c in sgs.qlist(todraw) do
			draw:addSubcard(c)
		end
		room:obtainCard(source,draw,false)
	end
}
n_songshi = sgs.CreateViewAsSkill{
    name = "n_songshi",
    n = 0,
	view_as = function(self,cards)
		return n_songshicard:clone()
	end,
	enabled_at_play = function(self,player)
		local blacks = sgs.IntList()
		local reds = sgs.IntList()
		for _,c in sgs.qlist(player:getHandcards()) do
			if c:isRed() then
				reds:append(c:getId())
			else
				blacks:append(c:getId())
			end
		end
		if (reds:isEmpty() or blacks:isEmpty()) then return false end
		return player:usedTimes("#n_songshicard") < 1
	end,
}
n_liangyifeng:addSkill(n_songshi)
n_yicai = sgs.CreateTriggerSkill{
	name = "n_yicai" ,
	events = {sgs.CardsMoveOneTime} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		if (move.from and move.from:objectName() == player:objectName()) and (move.reason ~= self:objectName())
			and (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD) then
			n_CompulsorySkill(player:getRoom(),player,self:objectName())
			player:drawCards(1)
		end
	end
}
n_liangyifeng:addSkill(n_yicai)
sgs.LoadTranslationTable{
    ["n_liangyifeng"] = "梁逸峰",
    ["#n_liangyifeng"] = "朗诵带诗人",
	["~n_liangyifeng"] = "我有特别的朗洪gay巧。",
	["designer:n_liangyifeng"] = "Notify",
    ["illustrator:n_liangyifeng"] = "网络",
    ["n_songshi"] = "诵诗",
    [":n_songshi"] = "阶段技。若你有不同颜色的牌，你可以展示手牌并弃置其中一种颜色的牌，然后摸等量不同颜色的牌。",
	["$n_songshi1"] = "（空耳）基友都上嘞。",
	["$n_songshi2"] = "（空耳）旷课上E妹。",
	["n_yicai"] = "逸才",
    [":n_yicai"] = "锁定技。你的牌因弃置进入弃牌堆后，你摸一张牌。",
    ["$n_yicai"] = "（空耳）满喉液。",
}

n_wurenji = sgs.General(extension,"n_wurenji","n_web",3)
n_aguli = sgs.General(extension,"n_aguli","n_web",3)
n_moucaiex = sgs.CreateTriggerSkill{
	name = "n_moucaiex",
	frequency = sgs.Skill_Compulsory,
	events = sgs.HpRecover,
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local recover = data:toRecover()
		if recover.who and recover.who:hasSkill(self:objectName()) 
		and player:objectName() ~= recover.who:objectName() and not player:isKongcheng() then
			n_CompulsorySkill(room,recover.who,self:objectName())
			for i = 1,recover.recover do
			n_askForGiveCardTo(player,recover.who,self:objectName(),".|.|.|hand!","#moucaigive:"..recover.who:getGeneralName(),true)
			end
			return false
		end
	end
}
n_wurenji:addSkill(n_moucaiex)
n_dingchuancard = sgs.CreateSkillCard{
	name = "n_dingchuancard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, selected, to_select)
		return (#selected == 0) and (to_select:objectName() ~= sgs.Self:objectName()) and (to_select:isWounded())
	end,
	on_effect = function(self,effect)
		local from = effect.from
		local to = effect.to
		local recover = sgs.RecoverStruct()
		recover.who = from
		recover.recover = to:getLostHp()
		local room = to:getRoom()
		room:recover(to,recover)
		to:gainMark("@n_poison",recover.recover+1)
	end
}
n_dingchuanvs = sgs.CreateViewAsSkill{
	name = "n_dingchuan",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isBlack()
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local card = n_dingchuancard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end ,
	enabled_at_play = function() return false end
}
n_dingchuan = sgs.CreateTriggerSkill{
	name = "n_dingchuan",
	view_as_skill = n_dingchuanvs,
	events = {sgs.Damaged,sgs.HpLost,sgs.HpRecover,sgs.EventPhaseStart},
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.HpLost or event == sgs.Damaged then
			if math.fmod(player:getMark("@n_cough"),2) == 0 then
				player:gainMark("@n_cough",1)
			end
		elseif event == sgs.HpRecover then
			if math.fmod(player:getMark("@n_cough"),2) > 0 then
				player:gainMark("@n_cough",1)
			end
		else	
			local wrjs = room:findPlayersBySkillName(self:objectName())
			for _,wrj in sgs.qlist(wrjs) do
				local hp,lhp = player:getHp(),player:getLostHp()
				local n = 3 --math.max(hp*2,lhp*2)
				if player:getMark("@n_cough") < n or player:getPhase() ~= sgs.Player_Start then break end
				if player:objectName() ~= wrj:objectName() then
					local card = room:askForCard(wrj,".|black|.|.","#dingchuanDisCard:"..player:getGeneralName() ,data, sgs.Card_MethodNone)
					if card then
						room:broadcastSkillInvoke(self:objectName())
						player:loseAllMarks("@n_cough")
						local lf = n_dingchuancard:clone()
						lf:addSubcard(card)
						lf:setSkillName(self:objectName())
						local use = sgs.CardUseStruct()
						use.from = wrj
						use.to:append(player)
						use.card = lf
						room:useCard(use)
					end
				end
			end
		end
	end
}
n_wurenji:addSkill(n_dingchuan)
sgs.LoadTranslationTable{
	["n_wurenji"] = "乌仁吉",
	["#n_wurenji"] = "雄凤山之子",
	["@n_cough"] = "喘",
	["~n_wurenji"] = "服药三十天，少活两百年。",
	["designer:n_wurenji"] = "Notify",
	["illustrator:n_wurenji"] = "来自网络",
	["n_dingchuan"] = "定喘",
	[":n_dingchuan"] = "每当有角色回复/损失体力后，若其拥有奇数/偶数枚“喘”标记，其获得一枚“喘”标记。" .. 
	"其他角色的准备阶段，若其“喘”标记数量不小于3，你可以弃置一张黑色牌，令其失去所有“喘”并恢复x点体力（x为其损失体力值）并获得x+1枚“毒”。",
	["$n_dingchuan1"] = "祖传老蒙方。",
	["$n_dingchuan2"] = "就治老咳喘一种病。",
	["n_moucaiex"] = "谋财",
	[":n_moucaiex"] = "锁定技。你每令其他角色恢复一点体力，其必须交给你一张手牌。",
	["#moucaigive"] = "%src 治了你的病，给张手牌表示一下！",
	["#dingchuanDisCard"] = "你可以弃置一张黑色牌，对 %src 发动“定喘”",
    ["$n_moucaiex1"] = "冬天给他浇冷水，阴天给他塞冰块。",
    ["$n_moucaiex2"] = "冷天就扣他家窗户，雨天就关羊圈。",
}
n_aguli:addSkill(n_dingchuan)
n_shenfangcard = sgs.CreateSkillCard{
	name = "n_shenfangcard", 
	will_throw = true, 
	filter = function(self, targets, to_select) 
		return #targets < self:getSubcards():length() and to_select:objectName() ~= sgs.Self:objectName()
		and to_select:isWounded()
	end, 
	feasible = function(self, targets)
		return #targets == self:getSubcards():length()
	end,
	on_use = function(self, room, source, targets)
		for _,p in ipairs(targets) do
			local recover = sgs.RecoverStruct()
			recover.who = source
			room:recover(p,recover)
			p:gainMark("@n_poison",1)
		end
		source:drawCards(self:getSubcards():length())
	end
}
n_shenfang = sgs.CreateViewAsSkill{
	name = "n_shenfang", 
	n = 999,
	view_filter = function(self, selected, to_select)
		return to_select:isBlack()
	end ,
	view_as = function(self, cards) 
		local card = n_shenfangcard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end, 
	enabled_at_play = function(self, player)
		return true --not player:hasUsed("#n_shenfangcard")
	end
}
n_aguli:addSkill(n_shenfang)
sgs.LoadTranslationTable{
	["n_aguli"] = "阿古力",
	["#n_aguli"] = "乌仁吉之子",
	["~n_aguli"] = "服药三十天，少活两百年。",
	["designer:n_aguli"] = "Notify",
	["illustrator:n_aguli"] = "来自网络",
	["n_shenfang"] = "神方",
	[":n_shenfang"] = "出牌阶段，你可以弃置任意张黑色牌并指定等量其他受伤角色，令所有目标各回复一点体力并获得一枚“毒”，然后你摸等量的牌。",
    ["$n_shenfang1"] = "这个老方子，凡是跟咳喘有关的病都能治。",
    ["$n_shenfang2"] = "用过的患者，因为过于惊叹，都夸他是神仙妙药。",
}

n_mianjinge = sgs.General(extension,"n_mianjinge","n_web",3, true, true)
n_tongyou = sgs.CreateTriggerSkill{
	name = "n_tongyou",
	events = {sgs.Death,sgs.EventPhaseStart},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.Death then
			local who = data:toDeath().who
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				local targets = p:property("n_cp"):toString():split("+")
				if table.contains(targets,who:objectName()) then
					table.remove(targets,table.indexOf(targets,who:objectName()))
					if #targets == 0 and p:hasSkill(self:objectName())then
						local target = room:askForPlayerChosen(p, room:getOtherPlayers(p), self:objectName(), "tongyou_invoke", false, true)
						if target:property("n_cp"):toString() ~= "" then
							room:setPlayerProperty(target,"n_cp",sgs.QVariant(target:property("n_cp"):toString().."+"..p:objectName()))
						else
							room:setPlayerProperty(target,"n_cp",sgs.QVariant(p:objectName()))
						end
						room:setPlayerProperty(p,"n_cp",sgs.QVariant(target:objectName()))
					else
						room:setPlayerProperty(p,"n_cp",sgs.QVariant(table.concat(targets,"+")))
					end
				end
			end
		else	
			if player:getPhase() == sgs.Player_Start then
				if player:hasSkill(self:objectName()) and player:property("n_cp"):toString() == "" then
					local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "tongyou_invoke", false, true)
					if target:property("n_cp"):toString() ~= "" then
						room:setPlayerProperty(target,"n_cp",sgs.QVariant(target:property("n_cp"):toString().."+"..player:objectName()))
					else
						room:setPlayerProperty(target,"n_cp",sgs.QVariant(player:objectName()))
					end
					room:setPlayerProperty(player,"n_cp",sgs.QVariant(target:objectName()))
				end
				if player:property("n_cp"):toString() ~= "" then
					local targets = player:property("n_cp"):toString():split("+")
					local tos = {}
					for _,str in ipairs(targets) do
						table.insert(tos,findPlayerByObjectName(room,str))
					end
					for _,p in ipairs(tos) do
						n_CompulsorySkill(room,player,self:objectName())
						room:notifySkillInvoked(p,self:objectName())
						room:askForGuanxing(p,room:getNCards(5))
					end
				end
			end
		end
	end
}
n_mianjinge:addSkill(n_tongyou)
n_mianjingivecard = sgs.CreateSkillCard{
    name = "n_mianjingivecard",
	target_fixed = false,
	filter = function(self, targets, to_select) 
		return #targets < sgs.Self:getMark("n_mianjingives") and to_select:getMark("n_mianjinsrc") == 0
		and to_select:getHandcardNum() < to_select:getMaxHp()
	end,
	feasible = function(self, targets)
		return #targets <= sgs.Self:getMark("n_mianjingives") and #targets > 0 
	end,
	on_use = function(self,room,source,targets)
		local cards = room:getTag("n_mianjins"):toIntList()
		room:fillAG(cards)
		for _,p in ipairs(targets) do
			if cards:isEmpty() then break end
			local id = room:askForAG(p, cards, false, "n_mianjin")
			room:takeAG(p, id, false)
			cards:removeOne(id)
			p:obtainCard(sgs.Sanguosha:getCard(id))
		end
		room:clearAG()
		
		local target
		for _,p in sgs.qlist(room:getAllPlayers()) do
			if p:getMark("n_mianjinsrc") > 0 then target = p;break end
		end
		if not target then return end
		local x = 0 - target:getHandcardNum() + source:getMark("n_mianjingives")
		if x >= 2 then
			local recover = sgs.RecoverStruct()
			recover.who = source
			room:recover(target,recover)
		end
	end,
}
n_mianjincard = sgs.CreateSkillCard{
    name = "n_mianjincard",
	target_fixed = false,
	filter = function(self, targets, to_select) 
		return to_select:objectName() ~= sgs.Self:objectName() and not to_select:isKongcheng() and #targets == 0
		and to_select:isWounded()
	end,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_use = function(self,room,source,targets)
		local target = targets[1]
		local cards = target:handCards()
		local n = cards:length()
		local data = sgs.QVariant()
		data:setValue(cards)
		room:setTag("n_mianjins",data)
		room:setPlayerMark(source,"n_mianjingives",cards:length())
		room:setPlayerMark(target,"n_mianjinsrc",1)
		room:askForUseCard(source, "@@n_mianjin", "@mianjin")
		room:setTag("n_mianjins",sgs.QVariant())
		room:setPlayerMark(source,"n_mianjingives",0)
		room:setPlayerMark(target,"n_mianjinsrc",0)
		
	end,
}
n_mianjin = sgs.CreateViewAsSkill{
    name = "n_mianjin",
	n = 0,
	view_as = function(self,cards)
		if sgs.Sanguosha:getCurrentCardUsePattern() == "@@n_mianjin" then
			return n_mianjingivecard:clone()
		else
			return n_mianjincard:clone()
		end
	end,
	enabled_at_play = function(self,player)
	    return not player:hasUsed("#n_mianjincard")
	end,
	enabled_at_response = function(self,player,pattern)
	    return pattern == "@@n_mianjin"
	end,
}
n_mianjinge:addSkill(n_mianjin)
sgs.LoadTranslationTable{
	["n_mianjinge"] = "面筋哥",
	["#n_mianjinge"] = "流浪歌手",
	["~n_mianjinge"] = "吃过没，尝过没，这香香的口味。",
	["designer:n_mianjinge"] = "Notify",
	["illustrator:n_mianjinge"] = "来自网络",
	["n_tongyou"] = "同游",
	["tongyou_invoke"] = "请选择“同游”的目标角色作为伴侣",
	[":n_tongyou"] = "锁定技。准备阶段若你没有伴侣或伴侣死亡时，选择一名伴侣；伴侣中一方在对方的准备阶段观星牌堆顶5张牌。",
	["$n_tongyou1"] = "香香口味你吃过没辣辣的感觉尝过没，网吧红人的歌声、你听过没。",
    ["$n_tongyou2"] = "真正的烤面筋让你每天开心，每个清晨，每个黄昏，都精神。",
	["n_mianjin"] = "面筋",
	["@mianjin"] = "面筋：选择拿牌的角色",
	["~n_mianjin"] = "选择任意名手牌数小于体力上限的角色->点确定",
	["n_mianjingive"] = "面筋",
	[":n_mianjin"] = "阶段技。你可以选择其他受伤角色A和任意名手牌数小于体力上限的角色，这些角色观看并获得A的一张手牌。若A以此法失去至少两张牌，你令A回复一点体力。",
    ["$n_mianjin1"] = "网吧红人每天都开心，因为吃了我的烤面筋。",
    ["$n_mianjin2"] = "我的面筋每天都精神，因为听了红人歌声。",
}

n_liuhongbin = sgs.General(extension,"n_liuhongbin","n_web",3,false)
n_xinliaocard = sgs.CreateSkillCard{
	name = "n_xinliaocard", 
	will_throw = true, 
	filter = function(self, targets, to_select) 
		return #targets < self:getSubcards():length() and to_select:objectName() ~= sgs.Self:objectName()
	end, 
	feasible = function(self, targets)
		return #targets == self:getSubcards():length()
	end,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@n_heartcure")
		room:doSuperLightbox("n_liuhongbin", "n_xinliao")
		for _,p in ipairs(targets) do
			room:loseMaxHp(p,1)
		end
	end
}
n_xinliaovs = sgs.CreateViewAsSkill{
	name = "n_xinliao", 
	n = 999,
	view_filter = function(self, selected, to_select)
		for _,card in ipairs(selected) do
			if card:getSuit() == to_select:getSuit() then return false end
		end
		return true
	end ,
	view_as = function(self, cards) 
		local card = n_xinliaocard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end, 
	enabled_at_play = function(self, player)
		return player:getMark("@n_heartcure") > 0
	end
}
n_xinliao = sgs.CreateTriggerSkill{
	name = "n_xinliao",
	frequency = sgs.Skill_Limited,
	limit_mark = "@n_heartcure",
	events = {sgs.NonTrigger},
	view_as_skill = n_xinliaovs,
	on_trigger = function()	end
}
n_liuhongbin:addSkill(n_xinliao)
n_gaiguan = sgs.CreateTriggerSkill{
	name = "n_gaiguan",
	events = sgs.QuitDying,
	can_trigger = function(self,target)
		return target and target:isAlive()
	end,
	on_trigger = function(self,event,player,data)	
		local room = player:getRoom()
		local _data = sgs.QVariant()
		_data:setValue(player)
		if player:isDead() then return end
		for _,olf in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if olf:objectName() ~= player:objectName() and olf:getMark("n_gaiguan_lun") == 0 and olf:askForSkillInvoke(self:objectName(),_data) then
				room:broadcastSkillInvoke(self:objectName())
				room:addPlayerMark(olf,"n_gaiguan_lun")
				room:damage(sgs.DamageStruct(self:objectName(),olf,player))
				olf:drawCards(1)
			end
		end
	end,
}
n_liuhongbin:addSkill(n_gaiguan)
sgs.LoadTranslationTable{
	["n_liuhongbin"] = "刘洪斌",
	["#n_liuhongbin"] = "巾帼神医",
	["~n_liuhongbin"] = "您一百天就给我治死了，您真是个神医呀！",
	["designer:n_liuhongbin"] = "Notify",
	["illustrator:n_liuhongbin"] = "来自网络",
	["n_xinliao"] = "心疗",
	["@n_heartcure"] = "心疗",
	["$n_xinliao1"] = "治不死的心脏病可以来找我！",
	["$n_xinliao2"] = "世界上的患者只要吃我的药就一个字，死！",
	[":n_xinliao"] = "限定技。你可以弃置任意张不同花色牌并令等量其他角色失去一点体力上限。",
	["n_gaiguan"] = "盖棺",
	["$n_gaiguan1"] = "按我的方法吃我的药，猝死在意大利。",
	["$n_gaiguan2"] = "三重疗法吃药当他当天下地狱！",
	[":n_gaiguan"] = "轮次技。你可以对脱离濒死的其他角色造成一点伤害，然后你摸一张牌。",
}

n_italy_artillery_trig = sgs.CreateTriggerSkill{
	name = "#n_italy_artillery_trig",
	events = sgs.DamageCaused,
	on_trigger=function(self,event,player,data)
		local weapon = player:getWeapon()
		if weapon and weapon:objectName() == "n_italy_artillery" then
			local room = player:getRoom()
			local damage = data:toDamage()

			if (damage.card and damage.card:objectName() == "fire_slash" and damage.by_user and not damage.chain and not damage.transfer
				and damage.to:getMark("Equips_of_Others_Nullified_to_You") == 0) then
				if (player == nil) then return false end
				local all = room:getAlivePlayers()
				local tars = sgs.SPlayerList()
				for _,p in sgs.qlist(all) do
					if p:distanceTo(damage.to) <= 1 then tars:append(p) end
				end
				if (tars:isEmpty() or not player:askForSkillInvoke("n_italy_artillery", data)) then return false end
				room:setEmotion(player, "weapon/n_italy_artillery")
				sgs.Sanguosha:playAudioEffect("audio/equip/n_italy_artillery.ogg")
				local _damage = sgs.DamageStruct()
				_damage.reason = "n_italy_artillery"
				_damage.nature = sgs.DamageStruct_Fire
				_damage.from = player
				for _,p in sgs.qlist(tars) do
					_damage.to = p
					room:damage(_damage)
				end
			end
	
			return false
		end
	end,
}
n_anjiang:addSkill(n_italy_artillery_trig)
n_italy_artillery = sgs.CreateWeapon{
	name = "n_italy_artillery",
	class_name = "NItalyArtillary",
	subtype = "weapon",
	range = 99,
	--suit = sgs.Card_Spade,
	--number = 13,
	on_install = function(self,player) 
		local room = player:getRoom()
		room:acquireSkill(player,n_italy_artillery_trig)
	end,
    on_uninstall = function(self,player)
		local room = player:getRoom()
		room:detachSkillFromPlayer(player, "n_italy_artillery_trig")
	end,
}
n_italy_artillery:clone(sgs.Card_Spade,13):setParent(extension)
n_liyunlong = sgs.General(extension, "n_liyunlong", "n_web")
n_paolve = sgs.CreateTriggerSkill{
	name = "n_paolve",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart,sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			for _, id in sgs.qlist(room:getDrawPile()) do
				if sgs.Sanguosha:getCard(id):objectName() == "n_italy_artillery" then
					room:setTag("YDLP_ID", sgs.QVariant(id))
				end
			end
		else
			if player:getPhase() == sgs.Player_Start then
				local lx = true
				local others = room:getOtherPlayers(player)
				for _,p in sgs.qlist(others) do
					if p:getHandcardNum() < player:getHandcardNum() then
						lx = false
						break
					end
				end
				if not lx then
					lx = true
					for _,p in sgs.qlist(others) do
						if p:getHp() < player:getHp() then
							lx = false
							break
						end
					end
				end
				if lx then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					room:broadcastSkillInvoke(self:objectName())
					if not (player:getWeapon() and player:getWeapon():objectName() == "n_italy_artillery") and room:getTag("YDLP_ID"):toInt() > 0 then
						local card = sgs.Sanguosha:getCard(room:getTag("YDLP_ID"):toInt())
						room:useCard(sgs.CardUseStruct(card, player, player))
					end
					for _, id in sgs.qlist(room:getDrawPile()) do
						if sgs.Sanguosha:getCard(id):objectName() == "fire_slash" then
							player:obtainCard(sgs.Sanguosha:getCard(id));break
						end
					end
				end
				
			end
		end
		return false
	end
}
n_liyunlong:addSkill(n_paolve)
sgs.LoadTranslationTable{
	["n_italy_artillery"]="意大利炮",
	[":n_italy_artillery"]=" 装备牌·武器\
	<b>攻击范围</b>：99\
    <b>武器技能</b>：你使用火杀命中时，可以先对所有到目标距离为1的角色造成一点火焰伤害。\
	（附：虽然李云龙可以直接使用，但这并不是李云龙的专属装备。）",
	["#n_italy_artillery_trig"]="意大利炮",
	["n_liyunlong"] = "李云龙",
	["~n_liyunlong"] = "不报此仇，我李云龙誓不为人！",
	["#n_liyunlong"] = "独立团团长",
	["designer:n_liyunlong"] = "Notify",
	["illustrator:n_liyunlong"] = "来自网络",
	["n_paolve"] = "炮略",
	[":n_paolve"] = "锁定技。准备阶段，若你的体力最低或手牌最少，你使用【意大利炮】并获得一张火杀。", 
    ["$n_paolve"] = "二营长！！你他娘的意大利炮呢？！",
}

n_lubenweiex = sgs.General(extension,"n_lubenweiex","n_web")
n_leyou = sgs.CreateTriggerSkill{
	name = "n_leyou",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged,sgs.Damage},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			local invoke = self:getFrequency(player) == sgs.Skill_Compulsory and true or player:askForSkillInvoke(self:objectName(),data)
			if invoke then
				room:broadcastSkillInvoke(self:objectName(),1)
				room:addPlayerMark(player,"leyounodamage")
				player:drawCards(1)
				local current = room:getCurrent()
				local log1 = sgs.LogMessage()
				log1.type ="#n_leyouextra"
				log1.from = player
				room:sendLog(log1)
				local phase = current:getPhase()--保存阶段
				current:setPhase(sgs.Player_NotActive)--角色设置回合外
				room:broadcastProperty(current,"phase")
				room:setCurrent(player)--设置目标为当前回合
				player:setPhase(sgs.Player_Play)		--设置目标出牌阶段
				room:broadcastProperty(player, "phase")
				local thread = room:getThread()
				if not thread:trigger(sgs.EventPhaseStart,room,player,sgs.QVariant()) then			
					thread:trigger(sgs.EventPhaseProceeding,room,player,sgs.QVariant())
				end		
				thread:trigger(sgs.EventPhaseEnd,room,player,sgs.QVariant())		
				player:setPhase(sgs.Player_NotActive)	--设置目标回合外	
				room:broadcastProperty(player,"phase")
				room:setCurrent(current) --设置当前回合为玩家
				current:setPhase(phase) --设置玩家保存的阶段
				room:broadcastProperty(current,"phase")		
				if player:getMark("leyounodamage")>0 then
					room:broadcastSkillInvoke(self:objectName(),2)
					room:loseHp(player,1)
				end
			end
		else
			room:setPlayerMark(player,"leyounodamage",0)
		end
	end
}
n_lubenweiex:addSkill(n_leyou)
n_leyoux = sgs.CreateTriggerSkill{
	name = "n_leyoux",
	--frequency == sgs.Skill_Compulsory,
	events = {sgs.Damaged,sgs.Damage},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			local invoke = self:getFrequency(player) == sgs.Skill_Compulsory and true or player:askForSkillInvoke("n_leyou",data)
			if invoke then
				room:broadcastSkillInvoke("n_leyou",1)
				room:addPlayerMark(player,"leyounodamage")
				player:drawCards(1)
				local current = room:getCurrent()
				local log1 = sgs.LogMessage()
				log1.type ="#n_leyouextra"
				log1.from = player
				room:sendLog(log1)
				local phase = current:getPhase()--保存阶段
				current:setPhase(sgs.Player_NotActive)--角色设置回合外
				room:broadcastProperty(current,"phase")
				room:setCurrent(player)--设置目标为当前回合
				player:setPhase(sgs.Player_Play)		--设置目标出牌阶段
				room:broadcastProperty(player, "phase")
				local thread = room:getThread()
				if not thread:trigger(sgs.EventPhaseStart,room,player,sgs.QVariant()) then			
					thread:trigger(sgs.EventPhaseProceeding,room,player,sgs.QVariant())
				end		
				thread:trigger(sgs.EventPhaseEnd,room,player,sgs.QVariant())		
				player:setPhase(sgs.Player_NotActive)	--设置目标回合外	
				room:broadcastProperty(player,"phase")
				room:setCurrent(current) --设置当前回合为玩家
				current:setPhase(phase) --设置玩家保存的阶段
				room:broadcastProperty(current,"phase")		
				if player:getMark("leyounodamage")>0 then
					room:broadcastSkillInvoke("n_leyou",2)
					room:loseHp(player,1)
				end
			end
		else
			room:setPlayerMark(player,"leyounodamage",0)
		end
	end
}
n_anjiang:addSkill(n_leyoux)
n_kaiguaex = sgs.CreateTriggerSkill{
	name = "n_kaiguaex",
	events = {sgs.Dying},
	frequency = sgs.Skill_Wake,
	can_trigger = function(self,target)
		return target and target:hasSkill(self:objectName()) and target:getMark(self:objectName()) == 0 
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local dying = data:toDying()
        if (dying.who:objectName() ~= player:objectName()) then 
            return false
		end

        room:broadcastSkillInvoke(self:objectName())
        room:doSuperLightbox("n_lubenweiex", self:objectName())

        room:addPlayerMark(player, self:objectName(), 1)
        if (room:changeMaxHpForAwakenSkill(player) and player:getMark(self:objectName()) > 0) then
            local recover = 2 - player:getHp()
            room:recover(player, sgs.RecoverStruct(nil, nil, recover))
            room:handleAcquireDetachSkills(player, "n_zimiao|n_leyoux|-n_leyou")
			
        end

        return false
	end
}
n_lubenweiex:addSkill(n_kaiguaex)
n_zimiao = sgs.CreateTriggerSkill{
	name = "n_zimiao" ,
	events = {sgs.TargetConfirmed} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if (player:objectName() ~= use.from:objectName()) or (not use.card:isKindOf("Slash")) or (use.card:getNumber()<=6) then return false end
		local jink_table = sgs.QList2Table(player:getTag("Jink_" .. use.card:toString()):toIntList())
		local index = 1
		for _, p in sgs.qlist(use.to) do
			local _data = sgs.QVariant()
			_data:setValue(p)
			if player:askForSkillInvoke(self:objectName(), _data) then
				room:broadcastSkillInvoke(self:objectName())
				jink_table[index] = 0
			end
			index = index + 1
		end
		local jink_data = sgs.QVariant()
		jink_data:setValue(table2IntList(jink_table))
		player:setTag("Jink_" .. use.card:toString(), jink_data)
		return false
	end
}
n_anjiang:addSkill(n_zimiao)
n_lubenweiex:addRelateSkill("n_zimiao")
sgs.LoadTranslationTable{
	["n_lubenweiex"] = "卢本伟",
	["designer:n_lubenweiex"] = "Notify",
	["illustrator:n_lubenweiex"] = "网络",
	["~n_lubenweiex"] = "你今天十七张牌能把卢本伟秒了，我当场，就把这个电脑屏幕吃掉！！（飞机~~）（啊真香）",
	["#n_lubenweiex"] = "绝地科学家",
	["n_leyou"] = "乐游",
	["$n_leyou1"] = "就，玩游戏一定要笑，不要，愁眉苦脸的",
	["$n_leyou2"] = "玩NM！！！",
	[":n_leyou"] = "锁定技。当你受到伤害后，你摸一张牌并执行一个额外的出牌阶段，若你未于此阶段内造成过伤害，你失去一点体力。",
	["n_leyoux"] = "乐游",
	[":n_leyoux"] = "当你受到伤害后，你可以摸一张牌并执行一个额外的出牌阶段，若你未于此阶段内造成过伤害，你失去一点体力。",
	["n_kaiguaex"] = "开挂",
	["$n_kaiguaex1"] = "你们可能不知道，只用20W，赢到578W，是什么概念。我们一般只会用两个字来形容这种人：土块。",
	["$n_kaiguaex2"] = "我经常说一句话，当年陈刀仔，他能用20块赢到3700W，我卢本伟用20W赢到500W，不是问题。",
	[":n_kaiguaex"] = "觉醒技。当你进入濒死状态时，你减1点体力上限并将体力值恢复至2点，然后获得技能“自瞄”（你可以令自己使用的点数大于6的【杀】不可被闪避。），再将技能“乐游”改为非锁定技。",
	["n_zimiao"] = "自瞄",
	["$n_zimiao"] = "LBWNB！",
	[":n_zimiao"] = "你可以令自己使用的点数大于6的【杀】不可被闪避。",
	["#n_leyouextra"] = "%from 进入一个额外的出牌阶段",
}

n_sunxiaochuan = sgs.General(extension,"n_sunxiaochuan$","n_web", 4, true, true)
n_baotu = sgs.CreateTriggerSkill{
	name = "n_baotu",
	events = {sgs.DamageCaused},
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local from,to = damage.from,damage.to
		for _,th in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if from:objectName() ~= th:objectName() and to:objectName() ~= th:objectName() and th:inMyAttackRange(to)
			and th:getHandcardNum() >= to:getHandcardNum() and room:askForCard(th, '.|.|.|.', '#n_baotu',data,sgs.Card_MethodDiscard,to,false,self:objectName()) then
				damage.from = th
				data:setValue(damage)
			end
		end
	end
}
n_sunxiaochuan:addSkill(n_baotu)
n_ruya = sgs.CreateTriggerSkill{
	name = "n_ruya",
	events = {sgs.DamageCaused},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local to = damage.to
		if to:isNude() then return false end
		if player:getHandcardNum() > to:getHandcardNum() then return false end
		local _data = sgs.QVariant()
		_data:setValue(to)
		if not player:askForSkillInvoke(self:objectName(),_data) then return false end
		local card = room:askForExchange(to, self:objectName(), 999, 1, true, "#n_ruya:"..player:getGeneralName())
		if card then
			room:obtainCard(player,card,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE,player:objectName(), to:objectName(), self:objectName(), ""),false)
		    if card:getSubcards():length() >= 2 then
				return true
			end
		end
	end,
}
n_sunxiaochuan:addSkill(n_ruya)
n_tianhuang = sgs.CreateTriggerSkill{
	name = "n_tianhuang$",
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		if player:getKingdom() ~= "n_web" then return end
		local sxcs = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:hasLordSkill(self:objectName()) then
				sxcs:append(p)
			end
		end
		local sxc = room:askForPlayerChosen(player, sxcs, self:objectName(), "@tianhuang-to", true)
		if sxc then
			damage.from = sxc
			data:setValue(damage)
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
n_sunxiaochuan:addSkill(n_tianhuang)
sgs.LoadTranslationTable{
	["n_sunxiaochuan"] = "孙笑川",
	["designer:n_sunxiaochuan"] = "诺多战士",
	["illustrator:n_sunxiaochuan"] = "网络",
	["~n_sunxiaochuan"] = "",
	["#n_sunxiaochuan"] = "恶事做尽",
	["n_baotu"] = "暴徒",
	["$n_baotu3"] = "那你去物管啊！",
	["$n_baotu2"] = "我才是网络暴力！",
	["$n_baotu1"] = "所有的事情都是我干的！",
	[":n_baotu"] = "其他角色对你你攻击范围内的角色造成伤害时，若你的手牌不小于受伤害者，你可以弃置一张牌并成为伤害来源。",
	["n_ruya"] = "儒雅",
	["$n_ruya1"] = "我这个人吧是个非常儒雅随和的一个人",
	["$n_ruya2"] = "要，要吃饭的嘛",
	["$n_ruya3"] = "你把你闪现给我交了",
	[":n_ruya"] = "你对其他角色造成伤害时，若你的手牌不大于其，你可以令其交给你至少一张牌，若其交给你两张或更多牌，防止此伤害。",
	["#n_baotu"] = "暴徒：你可以弃一张牌并成为本次伤害的伤害来源",
	["#n_ruya"] = "儒雅：请交给 %src 至少一张牌",
	["n_tianhuang"] = "天皇",
	["@tianhuang-to"] = "天皇：可以选择转移伤害来源",
	["$n_tianhuang1"] = "（家乡の话）",
	["$n_tianhuang2"] = "（更多家乡の话）",
	["$n_tianhuang3"] = "（相当多的家乡の话）",
	[":n_tianhuang"] = "主公技。其他同势力角色造成伤害时，其可令伤害来源视为你。",
}

n_zhuanyetuandui = sgs.General(extension,"n_zhuanyetuandui","n_web",7)
n_nanliao = sgs.CreateTriggerSkill{
	name = "n_nanliao",
	events = {sgs.CardUsed,sgs.EventPhaseStart},
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Start then
			room:setPlayerMark(player,"n_cdusd",0)
		elseif event == sgs.CardUsed then
			if room:getCurrent():objectName() ~= player:objectName() then return end
			room:addPlayerMark(player,"n_cdusd")
			local use = data:toCardUse()
			if player:getMark("n_cdusd") ~= 1 then return end
			if use.card:isKindOf("Duel") or not use.card:isNDTrick() then return end
			local isnl = false
			local _data = sgs.QVariant()
			_data:setValue(player)
			for _,p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if isnl then return end
				if p:objectName() ~= player:objectName() and p:askForSkillInvoke(self:objectName(),_data) then
					local duel = sgs.Sanguosha:cloneCard("duel")
					local _use = use
					duel:setSkillName('_'..self:objectName())
					_use.card = duel
					room:useCard(_use)
					isnl = true
					return true
				end
			end
		end
	end,
}
n_zhuanyetuandui:addSkill(n_nanliao)
n_xingshang = sgs.CreateTriggerSkill{
	name = "n_xingshang",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		if player:isDead() and not player:isNude() then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,caopi in sgs.qlist(alives) do
				if caopi:isAlive() and caopi:hasSkill(self:objectName()) then
					if room:askForSkillInvoke(caopi, self:objectName(), data) then
						room:broadcastSkillInvoke(self:objectName())
						local cards = player:getCards("he")
						if cards:length() > 0 then
							local allcard = sgs.DummyCard()
							for _,card in sgs.qlist(cards) do
								allcard:addSubcard(card)
							end
							room:obtainCard(caopi, allcard)
							room:setPlayerMark(caopi,"n_xingshangusd",1)
						end
						break
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target then
			return not target:hasSkill(self:objectName())
		end
		return false
	end
}
n_zhuanyetuandui:addSkill(n_xingshang)
n_shiye = sgs.CreateTriggerSkill{
	name = "n_shiye",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		player:getRoom():setTag("n_shiyenot",sgs.QVariant(true))
	end,
}
n_zhuanyetuandui:addSkill(n_shiye)
sgs.LoadTranslationTable{
	["n_zhuanyetuandui"] = "专业团队",
	["designer:n_zhuanyetuandui"] = "诺多战士",
	["illustrator:n_zhuanyetuandui"] = "网络",
	["~n_zhuanyetuandui"] = "",
	["#n_zhuanyetuandui"] = "生死难料",
	["n_nanliao"] = "难料",
	["$n_nanliao"] = "",
	[":n_nanliao"] = "其他角色于出牌阶段使用第一张牌后，若此牌为不为【决斗】的锦囊牌时，你可令使用者视为对所有目标依次使用一张【决斗】，再令此牌失效。",
	["n_xingshang"] = "行殇",
	["$n_xingshang"] = "",
	[":n_xingshang"] = "你可以获得死亡角色的所有牌。",
	["n_shiye"] = "失业",
	[":n_shiye"] = "锁定技。一轮结束时，若你已发动过“行殇”且本轮没有角色死亡，你失去一点体力上限。",
}

n_fulafu = sgs.General(extension,"n_fulafu","n_web",3)
n_kuangkua = sgs.CreateTriggerSkill{
	name = "n_kuangkua",
	events = sgs.CardFinished,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local use = data:toCardUse()
		local card = use.card
		if not card:isVirtualCard() then
			room:setTag("n_kuangkua_data",data)
			local p = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(),"n_kuangkuachoose",true,true)
			room:removeTag("n_kuangkua_data")
            if p then
				room:broadcastSkillInvoke(self:objectName())
                p:obtainCard(card)
                room:askForDiscard(p,self:objectName(),1,1)
            end
		end
	end,
}
n_fulafu:addSkill(n_kuangkua)
n_qiafan = sgs.CreateTriggerSkill{
	name = "n_qiafan",
	events = {sgs.DamageCaused},
	can_trigger = function(self,target)	return target end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if player:isWounded() and player:hasSkill(self:objectName()) and player:askForSkillInvoke(self:objectName(),data) then
			room:broadcastSkillInvoke(self:objectName())
			room:recover(player,sgs.RecoverStruct(nil,nil,data:toDamage().damage))
			return true
		end
	end,
}
n_fulafu:addSkill(n_qiafan)
sgs.LoadTranslationTable{
	["n_fulafu"] = "伏拉夫",
	["designer:n_fulafu"] = "Notify",
	["cv:n_fulafu"] = "伏拉夫",
	["illustrator:n_fulafu"] = "网络",
	["#n_fulafu"] = "甲亢",
	["~n_fulafu"] = "很快就到你家门口！",
	["n_kuangkuachoose"] = "你可以选择一名其他角色发动“狂夸”",
	["n_kuangkua"] = "狂夸",
	["$n_kuangkua1"] = "我们中国真的太厉害了！",
	["$n_kuangkua2"] = "厉害了我的中国！",
	[":n_kuangkua"] = "你可以把你使用结算完成的非转化牌交给一名其他角色，然后该角色弃一张手牌。",
	["n_qiafan"] = "恰饭",
	["$n_qiafan1"] = "今天我要吃变态辣火锅",
	["$n_qiafan2"] = "今天我要吃芥末火锅",
	["$n_qiafan3"] = "今天我要吃三国争霸火锅",
	["$n_qiafan4"] = "今天我要吃西瓜火锅",
	[":n_qiafan"] = "你可以将造成的伤害改为令自己回复体力。",
}

n_bolange = sgs.General(extension,"n_bolange","n_web",3)
n_polan = sgs.CreateTriggerSkill{
	name = "n_polan",
	events = {sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if (player:objectName() ~= use.from:objectName()) or (not use.card:isKindOf("Slash")) then return false end
		room:setTag("n_polan_ai",sgs.QVariant(use.card:getTypeId()))
		for _, p in sgs.qlist(use.to) do
			local _data = sgs.QVariant()
			_data:setValue(p)
			if (not p:isKongcheng()) and player:askForSkillInvoke(self:objectName(), _data) then
				room:broadcastSkillInvoke(self:objectName())
				local card = room:askForCardShow(p, player, self:objectName())
				room:showCard(p, card:getEffectiveId())
				if card:getTypeId() ~= use.card:getTypeId() then
					room:throwCard(card:getEffectiveId(),p)
				end
			end
		end
		return false
	end
}
n_bolange:addSkill(n_polan)
n_luandiao = sgs.CreateTriggerSkill{
	name = "n_luandiao",
	events = {sgs.CardUsed,sgs.CardResponded},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local card
		if event == sgs.CardUsed then card = data:toCardUse().card
		else card = data:toCardResponse().m_card end
		local prev = player:getMark("@n_ldprev")
		local x = card:getNumber() - prev
		local y = player:getMark("n_ldprevx")
		if x*y<0 then
			n_CompulsorySkill(room,player,self:objectName())
			player:drawCards(1)
		else	
			n_CompulsorySkill(room,player,self:objectName())
			room:askForDiscard(player, self:objectName(), 1, 1, false, true)
		end
		room:setPlayerMark(player,"@n_ldprev",card:getNumber())
		room:setPlayerMark(player,"n_ldprevx",x)
	end
}
n_bolange:addSkill(n_luandiao)
sgs.LoadTranslationTable{
	["n_bolange"] = "波澜哥",
	["#n_bolange"] = "我嫌弃破烂",
	["~n_bolange"] = "太古公丕~",
	["designer:n_bolange"] = "百合アレルギー",
	["illustrator:n_bolange"] = "来自网络",
	["n_luandiao"] = "乱调",
	["$n_luandiao1"] = "...",
	["$n_luandiao2"] = "...",
	[":n_luandiao"] = "锁定技。你使用或打出牌后，若x与y正负号不同，你摸一张牌，否则你须弃一张牌。（x为此牌与你上一次使用或打出的牌的点数差，y为你上一次计算的x）\n◆<font color=\"blue\"><b>操作提示：大点小点交替出牌</b></font>",
	["n_polan"] = "破澜",
	["$n_polan1"] = "你嫌弃破烂~",
	["$n_polan2"] = "炮击了我~",
	[":n_polan"] = "你使用杀指定目标后，你可以令目标展示一张手牌，若此牌为非基本牌，弃置之。",
}

n_senxiaxiashi = sgs.General(extension,"n_senxiaxiashi","n_web",4)
n_jijiang = sgs.CreateTriggerSkill{
	name = "n_jijiang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.card and damage.card:isKindOf("Slash") and damage.from and not damage.transfer and not damage.chain then
			n_CompulsorySkill(room,player,self:objectName())
			damage.from:drawCards(1)
			if not room:askForUseSlashTo(damage.from,player,"@senxia-slash:" .. player:objectName(),false) then
				room:recover(player,sgs.RecoverStruct())
			end
		end
	end
}
n_senxiaxiashi:addSkill(n_jijiang)
n_tiaoxincard = sgs.CreateSkillCard{
	name = "n_tiaoxincard" ,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:inMyAttackRange(sgs.Self) and to_select:objectName() ~= sgs.Self:objectName()
	end ,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		room:notifySkillInvoked(effect.from,"n_tiaoxin")
		room:broadcastSkillInvoke("n_tiaoxin",1)
		local use_slash = false
		if effect.to:canSlash(effect.from, nil, false) then
			use_slash = room:askForUseSlashTo(effect.to,effect.from, "@tiaoxin-slash:" .. effect.from:objectName())
		end
		if (not use_slash) and effect.from:canDiscard(effect.to, "he") then
			room:broadcastSkillInvoke("n_tiaoxin",2)
			room:throwCard(room:askForCardChosen(effect.from,effect.to, "he", "n_tiaoxin", false, sgs.Card_MethodDiscard), effect.to, effect.from)
		end
	end
}
n_tiaoxin = sgs.CreateViewAsSkill{
	name = "n_tiaoxin",
	n = 0 ,
	view_as = function()
		return n_tiaoxincard:clone()
	end ,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_tiaoxincard")
	end
}
n_senxiaxiashi:addSkill(n_tiaoxin)
sgs.LoadTranslationTable {
	["n_senxiaxiashi"] = "森下下士",
	["&n_senxiaxiashi"] = "森下",
	["#n_senxiaxiashi"] = "万聋会议",
	["designer:n_senxiaxiashi"] = "Notify",
	["cv:n_senxiaxiashi"] = "森下下士",
	["illustrator:n_senxiaxiashi"] = "来自网络",
	["n_jijiang"] = "激将",
	[":n_jijiang"] = "锁定技。你受到【杀】的伤害后，伤害来源摸一张牌，然后除非其对你使用一张【杀】，否则你回复一点体力。",
	["@senxia-slash"] = "请对 %src 使用一张杀，否则其将会回复一点体力",
	["$n_jijiang1"] = "没有劲儿！！重来！！！",
	["$n_jijiang2"] = "听不见！！重来！！！",
	["~n_senxiaxiashi"] = "好！很有精神！！",
	["n_tiaoxin"] = "挑衅",
	[":n_tiaoxin"] = "阶段技。你可以令攻击范围内包含你的一名角色对你使用一张【杀】，否则你弃置其一张牌。 ",
	["$n_tiaoxin1"] = "下面！请大家做自我介绍！",
	["$n_tiaoxin2"] = "怎么！你没听见吗！！",
}

n_aoerjia = sgs.General(extension, "n_aoerjia", "n_web")
n_jingshe = sgs.CreateTriggerSkill{
	name = "n_jingshe",
	events = {sgs.TargetConfirmed, sgs.SlashMissed, sgs.SlashHit},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.SlashMissed then
			local effect = data:toSlashEffect()
			player:drawCards(1)
			room:setPlayerMark(effect.to, "jingshe_missed", 1)
		elseif event == sgs.SlashHit then
			local effect = data:toSlashEffect()
			room:setPlayerMark(effect.to, "jingshe_missed", 0)
		else
			local use = data:toCardUse()
			if (player:objectName() ~= use.from:objectName()) or (not use.card:isKindOf("Slash")) then return false end
			local jink_table = sgs.QList2Table(player:getTag("Jink_" .. use.card:toString()):toIntList())
			local index = 1
			for _, p in sgs.qlist(use.to) do
				local _data = sgs.QVariant()
				_data:setValue(p)
				if p:getMark("jingshe_missed") > 0 and player:askForSkillInvoke(self:objectName(), _data) then
					room:broadcastSkillInvoke(self:objectName())
					player:drawCards(1)
					jink_table[index] = 0
				end
				index = index + 1
			end
			local jink_data = sgs.QVariant()
			jink_data:setValue(table2IntList(jink_table))
			player:setTag("Jink_" .. use.card:toString(), jink_data)
			return false
		end
	end
}
n_aoerjia:addSkill(n_jingshe)
n_buting = sgs.CreateTriggerSkill{
	name = "n_buting",
	frequency = sgs.Skill_Limited,
	events = sgs.AskForPeachesDone,
	limit_mark = "@n_buting",
	can_trigger = function(self, target)
		return target and target:hasSkill(self:objectName())
			   and target:getMark("@n_buting") > 0 
			   and target:getHp() <= 0
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:askForSkillInvoke(self:objectName()) then
			room:broadcastSkillInvoke(self:objectName())
			room:doSuperLightbox("n_aoerjia", self:objectName())
			player:loseMark("@n_buting", 1)
			room:recover(player, sgs.RecoverStruct(nil, nil, player:getMaxHp() - player:getHp()))
			player:drawCards(3)
			room:addPlayerMark(player, "n_butingused")
		end
	end
}
n_aoerjia:addSkill(n_buting)
sgs.LoadTranslationTable{
	["n_aoerjia"] = "奥尔加",
	["#n_aoerjia"] = "铁华团团长",
	["designer:n_aoerjia"] = "Notify",
	["~n_aoerjia"] = "所以说...不要停下来啊...",
	["n_jingshe"] = "精射",
	[":n_jingshe"] = "你的【杀】被闪避后，你摸一张牌，然后你对其使用下一张【杀】时，你可摸一张牌且令此【杀】不可被闪避。",
	["$n_jingshe1"] = "（开枪时）喝啊！",
	["$n_jingshe2"] = "嗟乎，吾射不亦精乎？",
	["n_buting"] = "不停",
	[":n_buting"] = "限定技。濒死求桃结束时，若你体力值不超过0，你可以回复体力值至上限并摸3张牌。若如此做，你在自己的回合结束时死亡。",
	["$n_buting1"] = "我可是铁华团团长奥尔加一直卡大佐，几颗子弹不要紧的",
	["$n_buting2"] = "只要不停止...道路就会不断延伸...",
}

n_anyanzhizhu = sgs.General(extension, "n_anyanzhizhu", "n_web", 3, false)
n_xushui = sgs.CreateTriggerSkill{
    name = "n_xushui",
    frequency = sgs.Skill_Frequent,
	events = {sgs.CardFinished, sgs.EventPhaseStart},
    on_trigger = function(self, event, player, data)
   		local room = player:getRoom()
		local use = data:toCardUse()
		if event == sgs.EventPhaseStart then
			for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				room:setPlayerMark(p, "n_xushuiused", 0)
			end
			return
		end
		if use.card and use.card:getSuit() == sgs.Card_Spade and use.card:isKindOf("BasicCard") then
			for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if p:objectName() ~= use.from:objectName() and p:getMark("n_xushuiused") == 0 and p:askForSkillInvoke(self:objectName()) then
					room:broadcastSkillInvoke(self:objectName())
					room:setPlayerMark(p, "n_xushuiused", 1)
					room:obtainCard(p, use.card)
					break	
				end
			end
		end
    end,
	can_trigger = function(self,target)
		return target
	end,
}
n_anyanzhizhu:addSkill(n_xushui)
n_juedi = sgs.CreateTriggerSkill{
	name = "n_juedi",
	events = sgs.Damage,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
        if not data:toDamage().to:isAlive() then return end
		local card = room:askForCard(player,".|spade|.|.","#n_juedi" ,sgs.QVariant(), sgs.Card_MethodNone)
		if card then
			local use = sgs.CardUseStruct()
			local juedi_card = sgs.Sanguosha:cloneCard("drowning")
			juedi_card:addSubcard(card)
            juedi_card:setSkillName(self:objectName())
			use.from = player
			use.to:append(data:toDamage().to)
			use.card = juedi_card
			room:useCard(use)
		end
	end,
}
n_anyanzhizhu:addSkill(n_juedi)
--[[do
	local drowing = sgs.Sanguosha:cloneCard("drowning")
	drowing:setSuit(sgs.Card_Spade)
	drowing:setNumber(7)
	drowing:setParent(extension)
end]]--
sgs.LoadTranslationTable{
    ["n_anyanzhizhu"] = "暗炎之主",
    ["#n_anyanzhizhu"] = "滗",
	["~n_anyanzhizhu"] = "谨言慎行，拒绝水贴！",
	["designer:n_anyanzhizhu"] = "Notify",
	["cv:n_anyanzhizhu"] = "穆小橘",
    ["illustrator:n_anyanzhizhu"] = "来自网络",
    ["n_xushui"] = "蓄水",
    [":n_xushui"] = "每名角色的回合限一次，你可以获得其他角色使用的黑桃基本牌。",
	["$n_xushui1"] = "广纳全网之言，以备水贴之需。",
	["$n_xushui2"] = "此图甚妙，我当存而水之。",
    ["n_juedi"] = "决堤",
	["$n_juedi1"] = "给你500元买你一天寿命你会同意吗？",
	["$n_juedi2"] = "人可以自卑到什么程度？",
	["$n_juedi3"] = "酒后真的会吐真言吗？",
	["$n_juedi4"] = "你认为小时候最尴尬的事情是什么？",
	["$n_juedi5"] = "如果穿越到古代，你能一统天下吗？",
	["$n_juedi6"] = "你有过差点死掉的经历吗？",
	["#n_juedi"] = "你现在可以将一张黑桃牌当做【水淹七军】对对方使用",
    [":n_juedi"] = "当你造成伤害后，可以将一张黑桃牌当【水淹七军】对其使用。",
}

n_mabaoguo = sgs.General(extension,"n_mabaoguo","n_web")
n_hunyuan = sgs.CreateTriggerSkill{
	name = "n_hunyuan",
	events = {sgs.DamageCaused,sgs.Damage},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if event == sgs.DamageCaused then
			local clist = {"n_toNormal","n_toFire","n_toThunder"}
			local choice = room:askForChoice(player,"n_hunyuan",table.concat(clist,"+"),data)
			damage.nature = table.indexOf(clist,choice)-1
			room:broadcastSkillInvoke("n_hunyuan", damage.nature + 1)
			data:setValue(damage)
		else
			room:addPlayerMark(player,"@n_hydamage"..damage.nature, damage.damage)
			local a,b,c = player:getMark("@n_hydamage0"),
						  player:getMark("@n_hydamage1"),
						  player:getMark("@n_hydamage2")
			if a==b and b==c then
				local to = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "hunyuan-invoke", true, true)
				if to then
					room:broadcastSkillInvoke("n_hunyuan",math.random(4,5))
					room:damage(sgs.DamageStruct(self:objectName(),player,to))
				end
			end
		end
	end,
}
n_mabaoguo:addSkill(n_hunyuan)
sgs.LoadTranslationTable{
	["n_mabaoguo"] = "马保国",
	["#n_mabaoguo"] = "掌门人",
	["n_hunyuan"] = "浑元",
	[":n_hunyuan"] = "你造成伤害时，可改变伤害属性。你造成伤害后，若你造成过的各属性伤害值都相等，你可以对一名角色造成一点伤害。",
	["hunyuan-invoke"] = "浑元：你可以对一名角色造成一点伤害",
	["n_toFire"] = "转换成火属性伤害",
	["n_toThunder"] = "转换成雷属性伤害",
	["n_toNormal"] = "转换成无属性伤害",
	["$n_hunyuan1"] = "一个左正蹬~（吭）",
	["$n_hunyuan2"] = "一个右鞭腿！",
	["$n_hunyuan3"] = "一个左刺拳。",
	["$n_hunyuan4"] = "三维立体浑元劲，打出松果糖豆闪电鞭",
	["$n_hunyuan5"] = "耗子尾汁。",
	["~n_mabaoguo"] = "这两个年轻人不讲武德，...这好吗这不好。",
}


n_xusheng = sgs.General(extension, "n_xusheng", "wu", 4, false)
sgs.LoadTranslationTable{
	["n_xusheng"] = "界徐盛",
	["#n_xusheng"] = "整军经武",
    ["cv:n_xusheng"] = "穆小橘",
    ["illustrator:n_xusheng"] = "来自网络",
	["~n_xusheng"] = "盛只恨……不能再为主公……破敌制胜了……",
}

n_pojun = sgs.CreateTriggerSkill{
	name = "n_pojun",
	events = {sgs.TargetSpecified, sgs.DamageCaused},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.card and use.card:isKindOf("Slash") then
				for _, t in sgs.qlist(use.to) do
					local n = math.min(t:getCards("he"):length(), t:getHp())
					local _data = sgs.QVariant()
					_data:setValue(t)
					if n > 0 and player:askForSkillInvoke(self:objectName(), _data) then
						room:broadcastSkillInvoke(self:objectName())
						room:doAnimate(1, player:objectName(), t:objectName())
						local dis_num = {}
						for i = 1, n do
							table.insert(dis_num, tostring(i))
						end
						local discard_n = tonumber(room:askForChoice(player, self:objectName() .. "_num", table.concat(dis_num, "+"))) - 1
						local orig_places = sgs.PlaceList()
						local cards = sgs.IntList()
						t:setFlags("n_pojun_InTempMoving")
						for i = 0, discard_n do
							local id = room:askForCardChosen(player, t, "he", self:objectName() .. "_dis", false, sgs.Card_MethodNone)
							local place = room:getCardPlace(id)
							orig_places:append(place)
							cards:append(id)
							t:addToPile("#n_pojun", id, false)
						end
						for i = 0, discard_n do
							room:moveCardTo(sgs.Sanguosha:getCard(cards:at(i)), t, orig_places:at(i), false)
						end
						t:setFlags("-n_pojun_InTempMoving")
						local dummy = sgs.Sanguosha:cloneCard("slash")
						dummy:addSubcards(cards)
						local tt = sgs.SPlayerList()
						tt:append(t)
						t:addToPile("n_pojun", dummy, false, tt)
					end
				end
			end
		else
			local damage = data:toDamage()
			local to = damage.to
			if damage.card and damage.card:isKindOf("Slash") and to and to:isAlive() and not damage.chain then
				if to:getHandcardNum() > player:getHandcardNum() or to:getEquips():length() > player:getEquips():length() then return false end
				room:sendCompulsoryTriggerLog(player, self:objectName())
				room:doAnimate(1, player:objectName(), to:objectName())
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		end
		return false
	end
}

n_pojunReturn = sgs.CreateTriggerSkill{
	name = "#n_pojun-return",
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data, room)
		if data:toPhaseChange().to == sgs.Player_NotActive then
			for _, p in sgs.qlist(room:getAllPlayers()) do
				if not p:getPile("n_pojun"):isEmpty() then
					local dummy = sgs.Sanguosha:cloneCard("slash")
					dummy:addSubcards(p:getPile("n_pojun"))
					room:obtainCard(p, dummy, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE, p:objectName(), self:objectName(), ""), false)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}

n_pojunFakeMove = sgs.CreateTriggerSkill{
	name = "#n_pojun-fake_move",
	events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime},
	priority = 10,
	on_trigger = function(self, event, player, data, room)
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("n_pojun_InTempMoving") then return true end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}

n_xusheng:addSkill(n_pojun)
n_xusheng:addSkill(n_pojunReturn)
n_xusheng:addSkill(n_pojunFakeMove)
extension:insertRelatedSkills("n_pojun", "#n_pojun-return")
extension:insertRelatedSkills("n_pojun", "#n_pojun-fake_move")
sgs.LoadTranslationTable{
	["n_pojun"] = "破军",
	[":n_pojun"] = "当你使用【杀】指定一个目标后，你可以将其一至X张牌扣置于其武将牌旁（X为其体力值），若如此做，当前回合结束时，其获得这些牌；当你使用【杀】对手牌数与装备区牌数均不大于的角色造成伤害时，此伤害+1。",
	["n_pojun_num"] = "移除数",
	["n_pojun_dis"] = "选择牌",
	["$n_pojun1"] = "犯大吴疆土者，盛必击而破之！",
	["$n_pojun2"] = "若敢来犯，必教你大败而归！",
	
}

n_haoge = sgs.General(extension, "n_haoge", "n_web")
n_qiaofancard = sgs.CreateSkillCard{
	name = "n_qiaofancard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, selected, to_select)
		return (#selected == 0) and
		(to_select:objectName() ~= sgs.Self:objectName())
	end,
	on_effect = function(self, effect)
		local from = effect.from
		local to = effect.to
		local room = effect.from:getRoom()
		room:broadcastSkillInvoke("n_qiaofan", math.random(1, 2))
		from:drawCards(1)
		room:obtainCard(to, room:askForCardChosen(to, from, "he", "n_qiaofan"),false)
	end,
}
n_qiaofanvs = sgs.CreateViewAsSkill{
	name = "n_qiaofan",
	n = 0,
	view_as = function(self, cards)
		return n_qiaofancard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_qiaofancard") and not player:isNude()
	end
}
n_qiaofan = sgs.CreateTriggerSkill{
	name = "n_qiaofan",
	view_as_skill = n_qiaofanvs,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		local room = player:getRoom()
		if (not move.from) or (not move.to) or (move.from:objectName() == move.to:objectName()) then return end
		local from = findPlayerByObjectName(room, move.from:objectName())
		local to = findPlayerByObjectName(room, move.to:objectName())

		if -- move.from_places:contains(sgs.Player_PlaceHand)
			from:hasSkill(self:objectName()) 
			and player:objectName() == from:objectName()
			and (not from:isKongcheng())
			and (not to:isKongcheng())
			and bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_REASON_GOTCARD) ==
				sgs.CardMoveReason_S_REASON_GOTCARD
			and move.reason.m_reason ~= sgs.CardMoveReason_S_REASON_GIVE then

				--from:speak(move.card_ids:first())
			local from_card = room:askForCard(from, ".|.|.|hand!", "qiaofan_show", sgs.QVariant(), sgs.Card_MethodNone)
			local to_card = room:askForCard(to, ".|.|.|hand!", "qiaofan_show", sgs.QVariant(), sgs.Card_MethodNone)

			if not from_card then
				from_card = from:getRandomHandCard()
			end
			if not to_card then
				to_card = to:getRandomHandCard()
			end

			room:showCard(from, from_card:getId())
			room:showCard(to, to_card:getId())

			if from_card:getNumber() > to_card:getNumber() then
				room:broadcastSkillInvoke("n_qiaofan", math.random(3, 4))
				local choice = room:askForChoice(to, self:objectName(), "qiaofan_slash+qiaofan_duel")
				if choice == "qiaofan_slash" then
					n_askForGiveCardTo(to, from, self:objectName(), ".|.|.|.!", 
						"#ShenshouGive:"..from:getGeneralName(), true)
					local slash = sgs.Sanguosha:cloneCard("slash")
					--slash:setSkillName(self:objectName())
                    local card_use = sgs.CardUseStruct()
                    card_use.card = slash
                    card_use.from = to
                    card_use.to:append(from)
                    room:useCard(card_use, false)
				else
					local duel = sgs.Sanguosha:cloneCard("duel")
					--duel:setSkillName(self:objectName())
                    local card_use = sgs.CardUseStruct()
                    card_use.card = duel
                    card_use.from = from
                    card_use.to:append(to)
                    room:useCard(card_use, false)
				end
			else
				room:broadcastSkillInvoke("n_qiaofan", math.random(5, 6))
				local choice = room:askForChoice(to, self:objectName(), "qiaofan_give+qiaofan_draw")
				if choice == "qiaofan_give" then
					n_askForGiveCardTo(to, from, self:objectName(), ".|.|.|.!", 
						"#ShenshouGive:"..from:getGeneralName(), true)
				else
					from:drawCards(2)
				end
			end
		end
	end, 
	can_trigger = function(self, target)
		return target
	end,
}
n_haoge:addSkill(n_qiaofan)
n_cili = sgs.CreateFilterSkill{
	name = "n_cili",
	view_filter = function(self, to_select)
		return true
	end,
	view_as = function(self, card)
		local id = card:getEffectiveId()
		local new_card = sgs.Sanguosha:getWrappedCard(id)
		new_card:setSkillName(self:objectName())
		new_card:setNumber(math.min(card:getNumber() + 1, 13))
		new_card:setModified(true)
		return new_card
	end
}
n_haoge:addSkill(n_cili)
sgs.LoadTranslationTable{
	["n_haoge"] = "郝哥",
	["#n_haoge"] = "瓜老板",
	["~n_haoge"] = "你TM劈我瓜是吧！我——哎！——（杀人啦！杀人啦！）",
	["n_qiaofan"] = "巧贩",
	[":n_qiaofan"] = "出牌阶段限一次，你可摸一张牌，然后令一名其他角色获得你一张牌。"..
		"每当其他角色获得你的牌后，你与其依次展示一张手牌，"..
		"若你展示牌的点数大于其，其选择：1.交给你一张牌并视为对你使用一张杀；2.你视为对其使用一张决斗；"..
		"若你展示牌的点数不大于其的，其选择：1.交给你一张牌；2.你摸两张牌。",
	["qiaofan_show"] = "“巧贩”被触发，请选择一张手牌展示",
	["qiaofan_slash"] = "交给其一张牌并视为对其使用一张杀",
	["qiaofan_duel"] = "其视为对你使用一张决斗",
	["qiaofan_give"] = "交给其一张牌",
	["qiaofan_draw"] = "其摸两张牌",
	["$n_qiaofan1"] = "我开水果摊的",
	["$n_qiaofan2"] = "这都是大棚的瓜",
	["$n_qiaofan5"] = "两块钱一斤",
	["$n_qiaofan6"] = "你嫌贵我还嫌贵呢",
	["$n_qiaofan3"] = "你TM故意找茬是不是",
	["$n_qiaofan4"] = "你要不要吧！——你要不要？",
	["n_cili"] = "磁力",
	-- ["$n_cili"] = "吸铁石",
	[":n_cili"] = "锁定技，你的所有牌视为点数+1的同名牌。",
}

n_heran = sgs.General(extension, "n_heran", "n_web")
n_wochao = sgs.CreateTriggerSkill{
	name = "n_wochao",
	events = {sgs.CardUsed, sgs.CardResponded, sgs.Damage},
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damage then 
			local damage = data:toDamage()
			if damage.card and damage.card:getSkillName() == "n_wocao" and not damage.chain then
				player:drawCards(1)
				damage.to:drawCards(1)
			end
			return 
		end

		local card
		if event == sgs.CardUsed then
			card = data:toCardUse().card
		elseif event == sgs.CardResponded then
			card = data:toCardResponse().m_card
		end

		if player:getPhase() == sgs.Player_NotActive and card and card:isBlack() and not card:isKindOf("Skill") then
			if player:askForSkillInvoke(self:objectName(), data) then
				local analeptic = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_SuitToBeDecided, -1)
				analeptic:setSkillName("n_wocao")
				local use = sgs.CardUseStruct(analeptic, player, player)
				room:broadcastSkillInvoke(self:objectName(), 1)
				room:useCard(use)

				local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
                slash:setSkillName("n_wocao")
                local targets = room:getOtherPlayers(player)
                for _,p in sgs.qlist(targets) do
            	    if not player:canSlash(p, slash, false) then targets:removeOne(p) end
                end
				if targets:isEmpty() then return end
                local target = room:askForPlayerChosen(player, targets, "wochao_slash")
				room:broadcastSkillInvoke(self:objectName(), 2)
                local card_use = sgs.CardUseStruct()
                card_use.card = slash
                card_use.from = player
                card_use.to:append(target)
                room:useCard(card_use, false)
			end
		end

	end,
	can_trigger = function(self, target)
		return target and target:hasSkill(self:objectName())
	end,
}
n_heran:addSkill(n_wochao)
n_kongguan = sgs.CreateTriggerSkill{
	name = "n_kongguan",
	events = {sgs.CardUsed, sgs.EventPhaseStart},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			if data:toCardUse().card:isKindOf("Analeptic") then
				player:gainMark("@n_chao", 1)
			end
		else 
			if player:getPhase() == sgs.Player_Draw and player:getMark("@n_chao") > 0 then
				n_CompulsorySkill(room, player, self:objectName())
				local x = player:getMark("@n_chao")
				player:loseAllMarks("@n_chao")
				player:drawCards(x)
			end
		end
	end,
	can_trigger = function(self, target)
		return target and target:hasSkill(self:objectName())
	end,
}
n_kongguanbuff = sgs.CreateProhibitSkill{
	name = "#n_kongguanbuff",
	is_prohibited = function(self, from, to, card)
		return card:isKindOf("Analeptic") and from:hasSkill("n_kongguan")
			and from:getPhase() ~= sgs.Player_NotActive
	end,
}
n_anjiang:addSkill(n_kongguanbuff)
extension:insertRelatedSkills("n_kongguan", "#n_kongguanbuff")
n_heran:addSkill(n_kongguan)
sgs.LoadTranslationTable{
	["n_heran"] = "赫然",
	["#n_heran"] = "哥谭噩梦",
	["~n_heran"] = "（我们的关系进一步没资格~）",
	["designer:n_heran"] = "睡懒觉の月离",
	["n_wochao"] = "我焯",
	["n_wocao"] = "我焯",
	["$n_wochao1"] = "哈哈哈哈哈哈……",
	["$n_wochao2"] = "焯！",
	["@n_chao"] = "焯",
	["wochao_slash"]="我焯：现在请选择砸出罐子（出杀）的目标",
	[":n_wochao"] = "当你于回合外使用或者打出黑色牌时，你可以视为使用了【酒】，然后视为对一名" ..
		"其他角色使用了【杀】（无视距离）。以此法使用的【杀】造成了伤害后，你和目标各摸一张牌。",
	["n_kongguan"] = "空罐",
	["$n_kongguan1"] = "我好不容易心动一次，",
	["$n_kongguan2"] = "你却让我输的那么彻底",
	[":n_kongguan"] = "锁定技。你在回合内不能使用【酒】。每当你使用【酒】后，你获得一枚“焯”；摸牌阶段开始时，你失去所有“焯”，摸等量的牌。",
}

-- 厨师徐嘉乐 4
-- 烹鸡：当你不因此法摸牌后，你可以弃置任意张类型不同的牌，然后摸等量的牌。
-- 颂鸡：当你因烹鸡而摸牌后，若摸的牌中有牌名和你弃置的牌中的一张相同，你可以弃置之，然后视为使用了【杀】（不计入次数）/【桃】
n_xujiale = sgs.General(extension, "n_xujiale", "n_web", 4, true, false, false)	
n_pengjicard = sgs.CreateSkillCard{
	name = "n_pengjicard",
	will_throw = true,
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local subcards = self:getSubcards()
		local x = subcards:length()
		local to_draws = room:getNCards(x)	-- For songji use
		room:returnToTopDrawPile(to_draws)

		source:drawCards(x, "n_pengji")
		
		if source:hasSkill("n_songji") then
			local sames = -1
			for _, cid in sgs.qlist(subcards) do
				for _, id in sgs.qlist(to_draws) do
					if sgs.Sanguosha:getCard(cid):objectName() == 
					sgs.Sanguosha:getCard(id):objectName() then
						sames = id
					end
				end
			end

			if sames ~= -1 then
				-- First, check if we can use peach
				local canPeach = source:isWounded()
				-- Then check if we can slash
				local targets = room:getOtherPlayers(source)
                for _,p in sgs.qlist(targets) do
            	    if not source:canSlash(p, slash, true) then targets:removeOne(p) end
                end
				local choices = {}
				if canPeach then table.insert(choices, "usePeach") end
				if not targets:isEmpty() then table.insert(choices, "useSlash") end
				if #choices > 0 then 
					table.insert(choices, "cancel")
					local invoke = room:askForDiscard(source, "n_songji", 1, 1, 
							true, false, "@n_songji", tostring(sames))
					if invoke then
						local choice = room:askForChoice(source, "n_songji", table.concat(choices, "+"), sgs.QVariant())
						if choice == "usePeach" then
							local _card = sgs.Sanguosha:cloneCard("peach")
							_card:setSkillName("n_songji")
							local use = sgs.CardUseStruct()
							use.from = source
							use.card = _card
							room:useCard(use)
						elseif choice == "useSlash" then
							local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
                			slash:setSkillName("n_songji")
							local target = room:askForPlayerChosen(source, targets, "songji_slash")
							local card_use = sgs.CardUseStruct()
							card_use.card = slash
							card_use.from = source
							card_use.to:append(target)
							room:useCard(card_use, false)
						end
						source:drawCards(1)
					end
				end
			end
		end
	end
}
n_pengjivs = sgs.CreateViewAsSkill{
	name = "n_pengji",
	n = 996,
	view_filter = function(self, selected, to_select)
		for _, c in ipairs(selected) do
			if to_select:getTypeId() == c:getTypeId() then
				return false
			end
		end
		return true
	end,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local c = n_pengjicard:clone()
		for _,cd in ipairs(cards) do
			c:addSubcard(cd)
		end
		return c
	end,
	enabled_at_play = function(self,player)
	    return false
	end,
	enabled_at_response = function(self,player,pattern)
	    return pattern == "@@n_pengji"
	end,
}
n_pengji = sgs.CreateTriggerSkill{
	name = "n_pengji",
	view_as_skill = n_pengjivs,
	events = {sgs.CardsMoveOneTime},
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if (not move.to) or move.to:objectName() ~= player:objectName() then return end
		local reason = move.reason
		if reason.m_skillName == self:objectName() or 
			bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_REASON_DRAW)
			~= sgs.CardMoveReason_S_REASON_DRAW 
			or (not move.from_places:contains(sgs.Player_DrawPile))
			or room:getTag("FirstRound"):toBool() then
			return
		end
		room:askForUseCard(player, "@@n_pengji", "@pengji")
	end,
}
n_xujiale:addSkill(n_pengji)
n_songji = sgs.CreateTriggerSkill{
	name = "n_songji",
	events = {sgs.NonTrigger},
	on_trigger = function()	end,
}
n_xujiale:addSkill(n_songji)
sgs.LoadTranslationTable{
	["n_xujiale"] = "徐嘉乐",
	["~n_xujiale"] = "最后一次啊，注意看啊",
	["#n_xujiale"] = "厨邦大师",
	["n_pengji"] = "烹鸡",
	["designer:n_xujiale"] = "穈穈哒的招来",
	["cv:n_xujiale"] = "徐嘉乐",
	["illustrator:n_xujiale"] = "视频截图",
	["@pengji"] = "烹鸡：请弃置任意张不同类型的牌，然后摸等量的牌",
	["~n_pengji"] = "选择要弃置的牌->点击确定",
	[":n_pengji"] = "当你不因此法摸牌后，你可以弃置任意张类型不同的牌，然后摸等量的牌。",
	["$n_pengji1"] = "先用油把这个鸡淋一下啊",
	["$n_pengji2"] = "基本上很均匀了这个皮",
	["n_songji"] = "颂鸡",
	[":n_songji"] = "当你因烹鸡而摸牌后，若摸的牌中有牌名和你弃置的牌中的一张相同，" ..
		"你可以弃置这些相同的牌中的一张，然后可以视为使用了【杀】（不计入次数）/【桃】，最后摸一张牌。",
	["$n_songji1"] = "这个烧鸡，皮酥脆，肉滑有汁，骨都带味",
	["$n_songji2"] = "所以是数一数二的烧鸡！",
	["usePeach"] = "视为使用【桃】",
	["useSlash"] = "视为使用【杀】",
	["@n_songji"] = "颂鸡：你可以弃置刚才摸到的牌中的一张，发动该技能",
	["songji_slash"] = "颂鸡：你已经做出了数一数二的烧鸡，现在请使用一张【杀】",
}

NCuiShiYuan = sgs.General(extension, "n_cuishiyuan", "n_web")
sgs.LoadTranslationTable{
	["n_cuishiyuan"] = "催逝员",
	["#n_cuishiyuan"] = "双料高级特工",
	["~n_cuishiyuan"] = "nnd，给我玩阴的是吧！直接来吧！",
	["designer:n_cuishiyuan"] = "Ho-spair",
}

NDuanTangDrinkCard = sgs.CreateSkillCard{
	name = "n_duantang_drink",
	filter = function(self, selected, to_select)
		return to_select:getPile("n_jitang"):length() > 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		room:fillAG(effect.to:getPile("n_jitang"), effect.from)
		local id = room:askForAG(effect.from, effect.to:getPile("n_jitang"), false, "n_duantang")
		room:clearAG(effect.from)
		room:obtainCard(effect.from, id)
	end
}
NDuanTangDrink = sgs.CreateZeroCardViewAsSkill{
	name = "n_duantang_drink&",
	view_as = function(self)
		return NDuanTangDrinkCard:clone()
	end,
	enabled_at_play = function(self, player)
		if player:hasUsed("#n_duantang_drink") then
			return false
		end

		local canPlay = false
		for _, p in sgs.qlist(player:getSiblings()) do
			if p:getPile("n_jitang"):length() > 0 then
				canPlay = true
				break
			end
		end

		return canPlay
	end,
}
sgs.LoadTranslationTable{
	["n_duantang_drink"] = "端汤",
	[":n_duantang_drink"] = "出牌阶段限一次，你可以获得场上一张“鸡汤”。",
}

n_anjiang:addSkill(NDuanTangDrink)

NDuanTangCard = sgs.CreateSkillCard{
	name = "n_duantang",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source)
		local originalPoisons = source:getTag("n_jitang"):toIntList()
		for _, id in sgs.qlist(self:getSubcards()) do
			originalPoisons:append(id)
		end

		local data = sgs.QVariant()
		data:setValue(originalPoisons)
		source:setTag("n_jitang", data)
	end
}
NDuanTangVS = sgs.CreateViewAsSkill{
	name = "n_duantang",
	n = 2,
	expand_pile = 'n_jitang',
	response_pattern = "@@n_duantang",
	view_filter = function(self, selected, to_select)
		local cardsRecorded = sgs.Self:property("n_duantang"):toString()
		return cardsRecorded ~= "" and table.contains(cardsRecorded:split("+"), tostring(to_select:getEffectiveId()))
	end,
	view_as = function(self, cards)
		if #cards < 1 then
			return nil
		end

		local skillCard = NDuanTangCard:clone()
		for _, id in ipairs(cards) do
			skillCard:addSubcard(id)
		end

		return skillCard
	end
}
NDuanTang = sgs.CreateTriggerSkill{
	name = "n_duantang",
	view_as_skill = NDuanTangVS,
	events = {sgs.EventPhaseStart, sgs.CardsMoveOneTime, sgs.GameStart, sgs.EventAcquireSkill},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start and player:getPile("n_jitang"):length() > 0 then
				local cardPack = sgs.Sanguosha:cloneCard("slash")
				cardPack:addSubcards(player:getPile("n_jitang"))
				room:obtainCard(player, cardPack)
				cardPack:deleteLater()
			elseif player:getPhase() == sgs.Player_Finish and room:askForSkillInvoke(player, self:objectName()) then
				room:broadcastSkillInvoke(self:objectName())
				local topCards = room:getNCards(3)
				player:addToPile("n_jitang", topCards)

				local idsStr = {}
				for _, id in sgs.qlist(topCards) do
					table.insert(idsStr, tostring(id))
				end

				room:setPlayerProperty(player, "n_duantang", sgs.QVariant(table.concat(idsStr, "+")))
				room:askForUseCard(player, "@@n_duantang", "@n_duantang", -1, sgs.Card_MethodNone)
				room:setPlayerProperty(player, "n_duantang", sgs.QVariant())
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() and table.contains(move.from_pile_names, "n_jitang") then
				local poisons = player:getTag("n_jitang"):toIntList()
				if poisons:length() < 1 then
					return false
				end

				local foundPoison = false
				for _, id in sgs.qlist(move.card_ids) do
					if poisons:contains(id) then
						foundPoison = true
						poisons:removeOne(id)
					end
				end

				local _data = sgs.QVariant()
				_data:setValue(poisons)
				player:setTag("n_jitang", _data)

				if foundPoison and move.to and move.to:isAlive() and move.to_place == sgs.Player_PlaceHand then
					for _, p in sgs.qlist(room:getAlivePlayers()) do
						if p:objectName() == move.to:objectName() then
							p:setTag("n_poisoned", sgs.QVariant(true))
							room:loseHp(p)
							break
						end
					end
				end
			end
		else
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				room:attachSkillToPlayer(p, "n_duantang_drink")
			end
		end

		return false
	end
}
sgs.LoadTranslationTable{
	["n_duantang"] = "端汤",
	["$n_duantang1"] = "啊哈哈哈~鸡汤来咯~",
	["$n_duantang2"] = "这，这都菜都齐了怎么还不吃啊？",
	[":n_duantang"] = "结束阶段开始时，你可以将牌堆顶三张牌置于你的武将牌上，称为“鸡汤”，然后你可选择其中至多两张牌下毒（其他角色不可见）；" ..
	"准备阶段开始时，你获得你的所有“鸡汤”；当一名角色获得你的“鸡汤”后，若其中有牌被下毒，其失去1点体力；其他角色的出牌阶段限一次，其可以获得" ..
	"你的一张“鸡汤”。",
	["n_jitang"] = "鸡汤",
	["@n_duantang"] = "你可以选择其中至多两张牌下毒",
	["~n_duantang"] = "选择其中至多两张牌→点击确定 或 点击取消",
}

NCuiShiYuan:addSkill(NDuanTang)

NZiYin = sgs.CreateTriggerSkill{
	name = "n_ziyin",
	events = {sgs.Dying},
	frequency = sgs.Skill_Wake,
	on_trigger = function(self, event, player, data, room)
		if data:toDying().who:objectName() == player:objectName() and player:getTag("n_poisoned"):toBool() and
			player:getMark(self:objectName()) == 0 then
			room:setPlayerMark(player, self:objectName(), 1)
			room:broadcastSkillInvoke(self:objectName())
			room:doSuperLightbox("n_cuishiyuan", self:objectName())
			room:changeMaxHpForAwakenSkill(player)
			room:recover(player, sgs.RecoverStruct(player))
			room:handleAcquireDetachSkills(player, "-n_duantang|n_zaochi")
		end

		return false
	end
}
sgs.LoadTranslationTable{
	["n_ziyin"] = "自饮",
	["$n_ziyin1"] = "行，喝，我喝",
	["$n_ziyin2"] = "这喝汤，多睡一件美逝啊",
	[":n_ziyin"] = "觉醒技，当你进入濒死状态时，若你因“端汤”而失去过体力，你减1点体力上限，回复1点体力，失去技能“端汤”，获得技能“躁斥”。",
}

NCuiShiYuan:addSkill(NZiYin)

NZaoChiCard = sgs.CreateSkillCard{
	name = "n_zaochi",
	filter = function(self, targets, to_select)
		return #targets < 1 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isKongcheng()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local topCards = room:getNCards(4)
		local move = sgs.CardsMoveStruct(topCards, nil, effect.from, sgs.Player_DrawPile, sgs.Player_PlaceHand,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_UNKNOWN, effect.from:objectName(), self:objectName() , ""))
		local moves = sgs.CardsMoveList()
		moves:append(move)
		local players = sgs.SPlayerList()
		players:append(effect.from)
		room:notifyMoveCards(true, moves, false, players)
		room:notifyMoveCards(false, moves, false, players)

		local idsStr = ""
		for _, id in sgs.qlist(topCards) do
			if idsStr == "" then
				idsStr = idsStr .. tostring(id)
			else
				idsStr = idsStr .. "," .. tostring(id)
			end
		end

		local chosenCards = room:askForExchange(effect.from, self:objectName(), 4, 1, false, "@n_zaochi-put", true, idsStr)
		local secMove = sgs.CardsMoveStruct(topCards, effect.from, nil, sgs.Player_PlaceHand, sgs.Player_DrawPile,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_UNKNOWN, effect.from:objectName(), self:objectName() , ""))
		local secMoves = sgs.CardsMoveList()
		secMoves:append(secMove)
		room:notifyMoveCards(true, secMoves, false, players)
		room:notifyMoveCards(false, secMoves, false, players)
		if chosenCards then
			room:askForGuanxing(effect.from, chosenCards:getSubcards(), sgs.Room_GuanxingDownOnly)
			for _, id in sgs.qlist(chosenCards:getSubcards()) do
				topCards:removeOne(id)
			end
		end

		room:returnToTopDrawPile(topCards)

		local handCards = effect.to:handCards()
		local newTopCards = room:getNCards(handCards:length())
		local toHand = sgs.CardsMoveStruct(newTopCards, nil, effect.to, sgs.Player_DrawPile, sgs.Player_PlaceHand,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, effect.to:objectName(), self:objectName() , ""))
		local toDrawPile = sgs.CardsMoveStruct(handCards, effect.to, nil, sgs.Player_PlaceHand, sgs.Player_DrawPile,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, effect.to:objectName(), self:objectName() , ""))
		local swap = sgs.CardsMoveList()
		swap:append(toHand)
		swap:append(toDrawPile)
		room:moveCardsAtomic(swap, false)

		if not effect.to:isKongcheng() then
			local targetsHandCards = effect.to:handCards()

			room:fillAG(targetsHandCards, effect.from)
			local id = room:askForAG(effect.from, targetsHandCards, false, self:objectName())
			if targetsHandCards:length() == 1 then
				room:getThread():delay(2000)
			end
			room:clearAG(effect.from)
			local poisons = effect.to:getTag("n_poisons"):toIntList()

			if not poisons:contains(id) then
				poisons:append(id)
			end

			local _data = sgs.QVariant()
			_data:setValue(poisons)
			effect.to:setTag("n_poisons", _data)
		end
	end
}
NZaoChi = sgs.CreateZeroCardViewAsSkill{
	name = "n_zaochi",
	view_as = function(self)
		return NZaoChiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_zaochi")
	end
}
NZaoChiPoison = sgs.CreateTriggerSkill{
	name = "#n_zaochi_poison",
	events = {sgs.CardsMoveOneTime, sgs.CardFinished},
	on_trigger = function(self, event, player, data, room)
		local poisons = player:getTag("n_poisons"):toIntList()
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceHand) and
				bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) ~= sgs.CardMoveReason_S_REASON_USE then
				for _, id in sgs.qlist(move.card_ids) do
					if poisons:contains(id) then
						poisons:removeOne(id)
					end
				end

				local _data = sgs.QVariant()
				_data:setValue(poisons)
				player:setTag("n_poisons", _data)
			end
		else
			local use = data:toCardUse()
			if use.from:objectName() == player:objectName() then
				local hasPoison = false
				if use.card:isVirtualCard() and use.card:getSubcards():length() > 0 then
					for _, id in sgs.qlist(use.card:getSubcards()) do
						if poisons:contains(id) then
							hasPoison = true
							poisons:removeOne(id)
						end
					end
				else
					hasPoison = poisons:contains(use.card:getEffectiveId())
					if hasPoison then
						poisons:removeOne(use.card:getEffectiveId())
					end
				end

				if hasPoison then
					local _data = sgs.QVariant()
					_data:setValue(poisons)
					player:setTag("n_poisons", _data)
					room:broadcastSkillInvoke(self:objectName())
					room:loseHp(player)
				end
			end
		end

		return false
	end,
	can_trigger = function(self, target)
		return target and target:getTag("n_poisons"):toIntList():length() > 0 and target:isAlive()
	end
}
sgs.LoadTranslationTable{
	["n_zaochi"] = "躁斥",
	[":n_zaochi"] = "出牌阶段限一次，你可以选择一名有手牌的其他角色，并观看牌堆顶四张牌，且可将其中至少一张牌以任意顺序置于牌堆底。" ..
	"然后你令将所有手牌与牌堆顶等量的牌交换，最后你观看其手牌并选择其中一张牌下毒（其他角色不可见）。若此牌离开其手牌前被其使用，" ..
	"则使用结算结束后，其失去1点体力。",
	["$n_zaochi1"] = "诶TNND，为什么不喝！喝，喝啊！",
	["$n_zaochi2"] = "不喝是吧，不喝...不喝我就炸死你！",
	["@n_zaochi-put"] = "躁斥：你可以将其中至少一张牌以任意顺序置于牌堆底",
}

n_anjiang:addSkill(NZaoChi)
n_anjiang:addSkill(NZaoChiPoison)
extension:insertRelatedSkills("n_zaochi", "#n_zaochi_poison")
NCuiShiYuan:addRelateSkill("n_zaochi")

n_qiangbi = sgs.General(extension2,"n_qiangbi","n_n",1023,true,true)
n_jishang = sgs.CreateTriggerSkill{
	name = "n_jishang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged, sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
        
		local damage = data:toDamage()
		
		if event == sgs.DamageInflicted and player:getMark("@n_shang") > 0 then
			room:broadcastSkillInvoke(self:objectName())
			local msg = sgs.LogMessage()
			msg.type = "#jishangdamage"
			msg.from = player
			msg.arg = damage.damage
			msg.arg2 = damage.damage + player:getMark("@n_shang")
			room:sendLog(msg)
			damage.damage = damage.damage + player:getMark("@n_shang")
			data:setValue(damage)
		elseif event == sgs.Damaged then
			room:sendCompulsoryTriggerLog(player, self:objectName(), true)
			player:gainMark("@n_shang", damage.damage)
		end
		
		return false
	end,
	--priority = -2,
}
n_qiangbi:addSkill(n_jishang)
n_tiebi = sgs.CreateMaxCardsSkill{
	name = "n_tiebi",
	fixed_func = function(self,target)
		if target:hasSkill(self:objectName()) then 
			return 9 
		else
			return -1
		end
	end
}
n_qiangbi:addSkill(n_tiebi)
sgs.LoadTranslationTable{
	["n_qiangbi"] = "壁垒",
	["#n_qiangbi"] = "物莫能陷",
	["~n_qiangbi"] = "已经、尽力了...",
	["designer:n_qiangbi"] = "Notify",
	["illustrator:n_qiangbi"] = "来自网络",
	["n_jishang"] = "积伤",
	["$n_jishang1"] = "好大的力气...",
	["$n_jishang2"] = "哼，这点小伤，算什么！",
	[":n_jishang"] = "锁定技。你受到伤害后，获得等同于伤害值数量的“伤”标记；你受到的伤害+X（X为“伤”标记数量）",
	["#jishangdamage"] = "%from 的 \"<font color=\"yellow\"><b>积伤</b></font>\" 效果被触发，伤害由 %arg 点增加至 %arg2 点",
	["@n_shang"] = "伤",
	["n_tiebi"] = "铁壁",
	[":n_tiebi"] = "锁定技。你的手牌上限为9.",
}

n_xueba = sgs.General(extension2,"n_xueba","n_n",3)
n_jingyan = sgs.CreateTriggerSkill{
	name = "n_jingyan",
	events = {sgs.EventPhaseStart, sgs.CardFinished,sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		math.randomseed(tostring(os.time()):reverse():sub(1, 7))
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Finish then
				room:removeTag("n_exuse")
				if not player:askForSkillInvoke(self:objectName()) then return end
				local cards = room:askForExchange(player, self:objectName(), 1, 1, false, "@n_jingyan")
				player:addToPile("n_timu", cards:getSubcards())
				room:broadcastSkillInvoke("n_jingyan",math.random(1,2))
			elseif player:getPhase() == sgs.Player_Play then
				if not player:getPile("n_timu"):isEmpty() then
					room:broadcastSkillInvoke("n_jingyan",math.random(3,4))
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					local ids = sgs.IntList()
					for _, id in sgs.qlist(player:getPile("n_timu")) do
						if sgs.Sanguosha:getCard(id):isKindOf("BasicCard")
						or sgs.Sanguosha:getCard(id):isNDTrick() then
							ids:append(id)
						end
						dummy:addSubcard(id)
					end
					local tagdata = sgs.QVariant()
					tagdata:setValue(ids)
					room:setTag("n_exuse",tagdata)
					room:obtainCard(player, dummy, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE, player:objectName()))
				end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			local ids = room:getTag("n_exuse"):toIntList()
			if ids:contains(use.card:getId()) then
				ids:removeOne(use.card:getId())
				local tgdt = sgs.QVariant()
				tgdt:setValue(ids)
				room:setTag("n_exuse",tgdt)
				room:broadcastSkillInvoke("n_jingyan",math.random(5,6))
				use.card = sgs.Sanguosha:cloneCard(use.card:objectName(),use.card:getSuit(),use.card:getNumber())
				use.card:setSkillName("n_jingyanmute")
				room:useCard(use)
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == self:objectName() then
				player:removePileByName("n_timu")
			end
		end
	end
}
n_xueba:addSkill(n_jingyan)
n_tihai = sgs.CreateTriggerSkill{
	name = "n_tihai",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damaged,sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			local damage = data:toDamage()
			if not (damage.card and (room:getCardPlace(damage.card:getEffectiveId()) == sgs.Player_PlaceTable)) then return end
			if not room:askForSkillInvoke(player,self:objectName()) then return end
			room:broadcastSkillInvoke("n_tihai")
			player:addToPile("n_timu", damage.card, false)
		elseif event == sgs.EventLoseSkill then
			if data:toString() == self:objectName() then
				player:removePileByName("n_timu")
			end
		end
		return false
	end,
}
n_xueba:addSkill(n_tihai)
sgs.LoadTranslationTable{
	["n_xueba"] = "学霸",
	["#n_xueba"] = "好题清如许",
	["~n_xueba"] = "朝闻好题，夕死可矣~~",
	["designer:n_xueba"] = "Notify",
	["illustrator:n_xueba"] = "来自网络",
	["cv:n_xueba"] = "Notify",
	["n_jingyan"] = "精研",
	["n_jingyanmute"] = "精研",
	["n_timu"] = "好题",
	["@n_jingyan"] = "请选择一张手牌",
	["@n_tihai"] = "请选择一张好题",
	[":n_jingyan"] = "结束阶段，你可以将一张手牌置于武将牌上，称为“好题”。出牌阶段开始时，你获得所有“好题”，且本回合使用“好题”中的基本牌和普通锦囊牌时结算次数+1。",
	["n_tihai"] = "题海",
	[":n_tihai"] = "当你受到伤害后，你可以将造成伤害的牌置于“好题”中。",
	["$n_jingyan1"] = "虽有好题，弗做，不知其妙也。",
	["$n_jingyan2"] = "好题难觅，当细细钻研。",
	["$n_jingyan3"] = "好题融会贯通，方能举一反三。",
	["$n_jingyan4"] = "好题熟读，了然于胸。",
	["$n_jingyan5"] = "见识一下好题的威力！",
	["$n_jingyan6"] = "如此好题，只做一次，是不够的。",
	["$n_tihai1"] = "错题才是真正的好题。",
	["$n_tihai2"] = "题好，量大，方为题海之道。",
}

n_xuezha_testing = sgs.General(extension2,"n_xuezha_testing","n_n",3)
n_jiyan = sgs.CreateTriggerSkill{
	name = "n_jiyan" ,
	events = {sgs.AskForPeaches} ,
	frequency = sgs.Skill_Frequent ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
        local dying_data = data:toDying()
		if dying_data.who:objectName() ~= player:objectName() then
        	return false
		end
    	if player:getHp() > 0 then return false end
    	if not player:askForSkillInvoke(self:objectName()) then return false end
		room:broadcastSkillInvoke(self:objectName())
    	local others = room:getOtherPlayers(player)
		local plist = sgs.SPlayerList()
		for _,p in sgs.qlist(others) do
			if not p:isKongcheng() then plist:append(p) end
		end
		if plist:isEmpty() then return end
		local thecard = sgs.Sanguosha:getCard(room:askForCardChosen(player,room:askForPlayerChosen(player, plist, self:objectName(), "@jiyanTarget", true),"h","n_jiyan"))
		local aglist = sgs.IntList();aglist:append(thecard:getId())
		room:fillAG(aglist,player)
		local pattern_str = ".|"..thecard:getSuitString().."|.|."
		local savecard = room:askForCard(player,pattern_str,"#jiyandisc:"..thecard:getSuitString(),sgs.QVariant(thecard:getSuit()),sgs.Card_MethodDiscard)
		if savecard then
    		local recover = sgs.RecoverStruct()
    		recover.who = player
    		recover.recover = 1 - player:getHp()
    		room:recover(player, recover)
    	end
		room:clearAG(player)
    	return false
    end
}
n_xuezha_testing:addSkill(n_jiyan)
n_xiamengCard = sgs.CreateSkillCard{
	name = "n_xiamengCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local suit = room:askForSuit(source,"n_xiameng")
		local log = sgs.LogMessage()
		log.type = "#ChooseSuit"
		log.from = source
		log.arg = sgs.Card_Suit2String(suit)
		room:sendLog(log)
		local card = sgs.Sanguosha:getCard(getACardRamdomly(room,source))
		if card:getSuit() ~= suit then
			room:loseHp(source)
		else
			if source:isWounded() then
				local recover = sgs.RecoverStruct()
				recover.who = source
				room:recover(source, recover)
			end
		end
	end
}
n_xiameng = sgs.CreateViewAsSkill{
	name = "n_xiameng", 
	n = 0,
	view_as = function(self, card) 
		return n_xiamengCard:clone()
	end, 
	enabled_at_play = function(self, player)
		return player:usedTimes("#n_xiamengCard") <= player:getMaxHp() * 2
	end
}
n_xuezha_testing:addSkill(n_xiameng)
sgs.LoadTranslationTable{
	["n_xuezha_testing"] = "学渣-考试版",
	["#n_xuezha_testing"] = "平时不烧香",
	["designer:n_xuezha_testing"] = "Notify",
	["cv:n_xuezha_testing"] = "Notify",
	["illustrator:n_xuezha_testing"] = "来自网络",
	["&n_xuezha_testing"] = "学渣",
	["~n_xuezha_testing"] = "什么？原来出的题目都不一样？",
	["n_jiyan"] = "急眼",
	["$n_jiyan1"] = "考试考试，考的就是视力",
	["$n_jiyan2"] = "最后一分钟，只能尽力一瞟了",
	[":n_jiyan"] = "每当你进入濒死状态时，你可以观看一名其他角色的一张手牌，若你弃置一张与之同花色的牌，你将体力回复值1点。",
	["@jiyanTarget"] = "请选择一名角色，观看其一张手牌",
	["#jiyandisc"] = "请弃置一张 %src 花色的牌",
	["n_xiameng"] = "瞎蒙",
	["$n_xiameng1"] = "成败与否，全看人品",
	["$n_xiameng2"] = "反正不会写，随便猜",
	[":n_xiameng"] = "出牌阶段限X次（X为你的体力上限的两倍），你可以声明一种花色并从牌堆随机正面向上获得一张牌。若此牌与你声明花色不同，你失去一点体力，否则你回复一点体力。",
}

n_miaosha = sgs.General(extension2,"n_miaosha","n_n")
n_miaoshaskill = sgs.CreateTriggerSkill{
	name = "n_miaoshaskill",
	events = {sgs.Damage},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local vict = damage.to
		local killer = damage.from
		if vict:getHp() >= killer:getHp() then
		if room:askForSkillInvoke(player,self:objectName(),data) then
			if player:getHp()>1	then 
				room:broadcastSkillInvoke("n_miaoshaskill",1)
			else
				room:broadcastSkillInvoke("n_miaoshaskill",2)
			end
			local damagek = sgs.DamageStruct()	
			damagek.from = killer
			damagek.to = vict
			room:damage(damagek)
		end
		end
	end,
}
n_miaosha:addSkill(n_miaoshaskill)
sgs.LoadTranslationTable{
	["n_miaosha"] = "秒杀",
	["#n_miaosha"] = "突然没了",
	["designer:n_miaosha"] = "Notify",
	["illustrator:n_miaosha"] = "来自网络",
	["n_miaoshaskill"] = "秒杀",
	[":n_miaoshaskill"] = "你对一名角色造成伤害后，若其体力值不小于你，则你可再对其造成一点伤害。",
	["$n_miaoshaskill1"] = "索命于须臾之间",
	["$n_miaoshaskill2"] = "拿命来！！",
	["~n_miaosha"] = "实在是杀不动了...",
}

n_shuaibeiwh = sgs.General(extension2,"n_shuaibeiwh","n_n")
n_yaoyin = sgs.CreateTriggerSkill{
	name = "n_yaoyin" ,
	events = {sgs.PreCardUsed} ,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		if use.card:isKindOf("Analeptic") then
			local room = player:getRoom()
			local available_targets = room:getOtherPlayers(player)
			local extra = room:askForPlayerChosen(player, available_targets, "n_yaoyin", "@qiaoshui-add:::" .. use.card:objectName())
			use.to:append(extra)
			room:sortByActionOrder(use.to)
		end
		data:setValue(use)
		return false
	end ,
}
n_shuaibeiwh:addSkill(n_yaoyin)
n_shuaibei = sgs.CreateTriggerSkill{
	name = "n_shuaibei" ,
	events = {sgs.CardFinished} ,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		if use.card:isKindOf("Analeptic") then
			local room = player:getRoom()
			if not room:askForSkillInvoke(player,self:objectName(),data) then return end
			if not room:askForDiscard(player, "n_shuaibei", 1, 1, false, true) then return end
			local available_targets = room:getOtherPlayers(player)
			local victim = room:askForPlayerChosen(player, available_targets, "n_shuaibei", "@shuaibeichose")
			available_targets:removeOne(victim)
			available_targets:append(player)
			for _,p in sgs.qlist(available_targets) do
				room:askForUseSlashTo(p,victim,"@shuaibei-slash:" .. victim:objectName(),false,true)
			end
		end
		return false
	end ,
}
n_shuaibeiwh:addSkill(n_shuaibei)
n_yaoyintmd = sgs.CreateTargetModSkill{
	name = "#n_yaoyintmd",
	frequency = sgs.Skill_NotFrequent,
	pattern = "NBrick",
	extra_target_func = function(self, player)
		if player:hasSkill(self:objectName())then
			return 10
		else
			return 0
		end
	end,
}
n_shuaibeiwh:addSkill(n_yaoyintmd)
n_shuaibeiwh:addSkill("jiuchi")
sgs.LoadTranslationTable{
	["n_shuaibeiwh"] = "摔杯",
	["#n_shuaibeiwh"] = "摔盏为号",
	["designer:n_shuaibeiwh"] = "Notify",
	["illustrator:n_shuaibeiwh"] = "来自网络",
	["n_yaoyin"] = "邀饮",
	[":n_yaoyin"] = "你使用【酒】须多指定一名角色为目标。",
	["n_shuaibei"] = "摔杯",
	[":n_shuaibei"] = "你使用【酒】后，可弃一张牌并指定一名其他角色，所有其他角色可以对其使用一张无距离限制的【杀】。",
	["@shuaibeichose"] = "请选择集火目标！",
	["@shuaibei-slash"] = "%src 被摔杯为号，请对其使用一张【杀】",
}

n_kuanggong = sgs.General(extension2,"n_kuanggong","n_n")
n_kaishan = sgs.CreateTriggerSkill{
	name = "n_kaishan",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		n_CompulsorySkill(room,player,self:objectName())
		local damage = data:toDamage()
		local to = damage.to
		local x = to:getMaxHp() / 6
		if x < 1 then
			local msg = sgs.LogMessage()
			msg.type = "#kaishanFail"
			msg.to:append(to)
			msg.from = player
			room:sendLog(msg)
			player:drawCards(1)
		else
			--x = (math.ceil(x) == x and math.ceil(x) or math.ceil(x) - 1)
			--local log = sgs.LogMessage()
			--log.type = "#kaishandamage"
			--log.from = player
			--log.arg = damage
			--log.arg2 = damage.damage + x
			--room:sendLog(log)
			damage.damage = damage.damage + x
			data:setValue(damage)
		end
		--return false
	end,
}
n_kuanggong:addSkill(n_kaishan)
sgs.LoadTranslationTable{
	["n_kuanggong"] = "矿工",
	["#n_kuanggong"] = "开山之力",
	["designer:n_kuanggong"] = "Notify",
	["illustrator:n_kuanggong"] = "来自网络",
	["n_kaishan"] = "开山",
	[":n_kaishan"] = "锁定技。你造成伤害时，伤害+X（X为目标体力上限的六分之一，向下取整）；若X=0，你摸一张牌。",
	["#kaishanFail"] = "%to 的体力上限小于6，因此 %from 的\"<font color=\"yellow\"><b>开山</b></font>\"没有产生效果，%from 因此将摸一张牌",
	["#kaishandamage"] = "%from 的 \"<font color=\"yellow\"><b>开山</b></font>\" 效果被触发，伤害由 %arg 点增加至 %arg2 点",
}

n_huokonglong = sgs.General(extension2,"n_huokonglong","n_n")
n_menghuo = sgs.CreateTriggerSkill{
	name = "n_menghuo",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local to = damage.to
		if damage.nature == sgs.DamageStruct_Fire then
			n_CompulsorySkill(room,player,self:objectName())
			damage.damage = damage.damage + 1
			data:setValue(damage)
		end
		return false
	end,
}
n_huokonglong:addSkill(n_menghuo)
n_yanshao = sgs.CreateTriggerSkill{
	name = "n_yanshao",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused,sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if event == sgs.DamageInflicted then
			if damage.nature == sgs.DamageStruct_Fire then
				n_CompulsorySkill(room,player,self:objectName())
				damage.damage = damage.damage - 1
				room:loseHp(player,1)
				player:gainMark("@n_fire",1)
				if damage.damage < 1 then
					return true
				end
				data:setValue(damage)
				return false
			end
		elseif event == sgs.DamageCaused then
			if damage.nature == sgs.DamageStruct_Fire then
				n_CompulsorySkill(room,player,self:objectName())
				damage.damage = damage.damage + player:getMark("@n_fire")
				player:loseAllMarks("@n_fire")
				data:setValue(damage)
			end
			return false
		end
	end,
}
n_huokonglong:addSkill(n_yanshao)
n_huokonglong:addSkill("huoji")
sgs.LoadTranslationTable{
	["n_huokonglong"] = "火恐龙",
	["#n_huokonglong"] = "求别吐槽",
	["designer:n_huokonglong"] = "Notify",
	["illustrator:n_huokonglong"] = "来自网络",
	["n_menghuo"] = "猛火",
	[":n_menghuo"] = "锁定技。你造成的火焰伤害+1。",
	["n_yanshao"] = "延烧",
	[":n_yanshao"] = "锁定技。你受到火焰伤害时，你失去一点体力并获得一个“炎”标记，然后此伤害-1；你造成火焰伤害时，你失去全部“炎”标记，令此伤害+X（X为失去“炎”标记的数量）。",
	["@n_fire"] = "炎",
}

n_duliu = sgs.General(extension2,"n_duliu","n_n",0,true,true)
n_youhun = sgs.CreateTriggerSkill{
	name = "n_youhun",
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if data:toDeath().who:objectName() == player:objectName() then
			local target = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "youhun_invoke", true, true)
			if target then
				room:broadcastSkillInvoke(self:objectName())
				local soul = player:getGeneralName()
				local to_soul = target:getGeneralName()
				room:setPlayerProperty(target,"kingdom",sgs.QVariant("n_n"))
				room:changeHero(player,to_soul,false)
				room:changeHero(target,soul,false)
			end
		end
	end,
	can_trigger = function(self, target)
		return target and target:hasSkill(self:objectName())
	end
}
n_duliu:addSkill(n_youhun)
n_duliu:addSkill("kunfen")
sgs.LoadTranslationTable{
	["n_duliu"] = "毒瘤",
	["#n_duliu"] = "不死之身",
	["designer:n_duliu"] = "Notify",
	["illustrator:n_duliu"] = "nil",
	["n_youhun"] = "游魂",
	[":n_youhun"] = "你死亡时，可与一名其他角色交换武将牌。",
	["youhun_invoke"] = "选择一名角色与之交换武将牌",
}

n_shitang = sgs.General(extension2,"n_shitang","n_n",3,false)
n_dafan = sgs.CreateTriggerSkill{
	name = "n_dafan",
	events = {sgs.GameStart,sgs.EventLoseSkill},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			room:broadcastSkillInvoke("n_dafan", 1)
			local drawpile = room:getDrawPile()
			local dummy = sgs.Sanguosha:cloneCard("slash",sgs.Card_NoSuit,0)
			for _,card in sgs.qlist(drawpile) do
				if sgs.Sanguosha:getCard(card):isKindOf("Peach") then
					dummy:addSubcard(card)
				end
			end
			player:addToPile("n_food",dummy)
		end
		if event == sgs.EventLoseSkill then
			if data:toString() == self:objectName() then
				player:removePileByName("n_food")
			end
		end
	end
}
n_dafan_buycard = sgs.CreateSkillCard{
	name = "n_dafan_buycard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, selected, to_select)
		return (not to_select:getPile("n_food"):isEmpty())
	end,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_effect = function(self, effect)
		local from = effect.from
		local to = effect.to
		local room = from:getRoom()
		room:obtainCard(to,self,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE,from:objectName(), to:objectName(), "n_dafan_buy", ""))
		room:broadcastSkillInvoke("n_dafan",math.random(2,3))
		local food = to:getPile("n_food")
		if not food:isEmpty() then
		    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
			local x = from:getLostHp()
			local dummy = sgs.Sanguosha:cloneCard("slash",sgs.Card_NoSuit,0)
			if x > food:length() then
				for _,id in sgs.qlist(food) do
					dummy:addSubcard(id)
				end
			else
				local xi = math.random(1,x)
				for i = 0,xi - 1  do
					dummy:addSubcard(food:at(i))
				end
			end
			room:broadcastSkillInvoke(self:objectName())
			room:obtainCard(from,dummy)
		end
	end
}
n_dafan_buy = sgs.CreateViewAsSkill{
	name = "n_dafan_buy&",
	n = 3,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards < 3 then return nil end
		local buy = n_dafan_buycard:clone()
		for _,cd in ipairs(cards) do
			buy:addSubcard(cd)
		end
		return buy
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_dafan_buycard") and player:isWounded()
	end,
}
n_anjiang:addSkill(n_dafan_buy)
n_dafan_buy_attach = sgs.CreateTriggerSkill{
	name = "#n_dafan_buy_attach",
	events = {sgs.GameStart,sgs.EventAcquireSkill,sgs.EventLoseSkill},
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if (event == sgs.GameStart) or (event == sgs.EventAcquireSkill and data:toString() == "n_dafan") then
            for _,p in sgs.qlist(room:getAllPlayers()) do
                if (not p:hasSkill("n_dafan_buy")) then
                    room:attachSkillToPlayer(p, "n_dafan_buy")
				end
            end
        elseif (event == sgs.EventLoseSkill and data:toString() == "n_dafan") then
            for _,p in sgs.qlist(room:getAllPlayers()) do
                if (p:hasSkill("n_dafan_buy")) then
                    room:detachSkillFromPlayer(p, "n_dafan_buy", true)
				end
            end
		end
        return false
	end
}
n_anjiang:addSkill(n_dafan_buy_attach)
extension2:insertRelatedSkills("n_dafan","#n_dafan_buy_attach")
n_shitang:addSkill(n_dafan)
sgs.LoadTranslationTable{
	["n_shitang"] = "食堂阿姨",
	["#n_shitang"] = "控制粮食",
	["designer:n_shitang"] = "Notify",
	["~n_shitang"] = "嘿，（惊叹）我打响的？！是口号啊，砸！！（碗碎）",
	["illustrator:n_shitang"] = "来自网络",
	["n_dafan"] = "打饭",
	["$n_dafan1"] = "时——辰——已——到——！",
	["$n_dafan2"] = "哼，吓唬我呢，我什么场面没见过，我看你们谁敢砸食堂！事后谁就得被开除！",
	["$n_dafan3"] = "我看，谁敢打响食堂起义的第一枪？！",
	[":n_dafan"] = "游戏开始时，你将牌堆中所有【桃】置于你的武将牌上。一名角色出牌阶段限一次，其可以交给你3张手牌并获得你武将牌上随机张不大于其损失体力值的【桃】。",
	["n_dafan_buy"] = "打饭",
	[":n_dafan_buy"] = "",
	["n_food"] = "饭",
}

n_xuezha = sgs.General(extension2,"n_xuezha","n_n",3)
n_tuoyan = sgs.CreateTriggerSkill{
	name = "n_tuoyan",
	events = sgs.Damaged,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.from:isWounded() then
			if room:askForSkillInvoke(player,self:objectName(),data) then
			    room:broadcastSkillInvoke(self:objectName())
				local recover = sgs.RecoverStruct()
				recover.who = player
				room:recover(damage.from,recover)
				room:recover(player,recover)
			end
		end
	end
}
n_xuezha:addSkill(n_tuoyan)
n_chaoxivs = sgs.CreateViewAsSkill{
	name = "n_chaoxi",
	n = 1,
	view_filter = function(self, selected, to_select)
		return true
	end ,
	view_as = function(self,card)
		if #card == 0 then return nil end
		local ocd = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(sgs.Self:getMark("chaoxiid")):objectName())
		for _, c in ipairs(card) do
			ocd:addSubcard(c)
		end
		ocd:setSkillName("n_chaoxi")
		return ocd
	end,
	enabled_at_response = function(self, player, pattern)
		local ocd = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(sgs.Self:getMark("chaoxiid")):objectName())
		return pattern == ocd:objectName() and player:getMark("chaoxienable") == 1 and (player:getMark("chaoxiusd")<3) and not player:isNude()
	end,
	enabled_at_play = function(self, player)
		local ocd = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(sgs.Self:getMark("chaoxiid")):objectName())
		return ocd:isAvailable(player) and not player:isNude() and (player:getMark("chaoxiusd")<3) and player:getMark("chaoxienable") == 1
	end,
	enabled_at_nullification = function(self, player)
		local ocd = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(player:getMark("chaoxiid")):objectName())
		return ocd:objectName() == "nullification" and not player:isNude() and (player:getMark("chaoxiusd")<3) and player:getMark("chaoxienable") == 1
	end
	
}
n_chaoxi = sgs.CreateTriggerSkill{
	name = "n_chaoxi",
	events = {sgs.EventPhaseStart,sgs.CardUsed,sgs.CardResponded},
	view_as_skill = n_chaoxivs,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
		if player:getPhase() == sgs.Player_Start then
			local other_players = room:getOtherPlayers(player)
			local targets = sgs.SPlayerList()
			for _, p in sgs.qlist(other_players) do
				if player:canDiscard(p, "h") then
					targets:append(p)
				end
			end
			if targets:isEmpty() then
				room:setPlayerMark(player,"chaoxienable",0)
				return false
			end
			local to = room:askForPlayerChosen(player, targets, self:objectName(), "chaoxi-invoke", true, true)
			if to then
				local card_id = room:askForCardChosen(player, to, "h", self:objectName(), false)
				room:showCard(to, card_id)
				local card = sgs.Sanguosha:getCard(card_id)
				if not card:isKindOf("EquipCard") then
					room:setPlayerMark(player,"chaoxienable",1)
					room:setPlayerMark(player,"chaoxiid",card:getId())
					room:setPlayerMark(player,"chaoxiusd",0)
				else
					room:setPlayerMark(player,"chaoxienable",0)
					room:setPlayerMark(player,"chaoxiusd",6)
					room:setPlayerMark(player,"chaoxienable",0)
				end
			end
		end
		elseif event == sgs.CardUsed then
			if data:toCardUse().card:getSkillName() == "n_chaoxi" then
				room:setPlayerMark(player,"chaoxiusd",player:getMark("chaoxiusd")+1)
			end
		elseif event == sgs.CardResponded then
			if data:toCardResponse().m_card:getSkillName() == "n_chaoxi" then
				room:setPlayerMark(player,"chaoxiusd",player:getMark("chaoxiusd")+1)
			end
		end
	end
}
n_xuezha:addSkill(n_chaoxi)
sgs.LoadTranslationTable{
	["n_xuezha"] = "学渣",
	["#n_xuezha"] = "源头活水来",
	["~n_xuezha"] = "人在河边走，哪能不湿鞋。",
	["cv:n_xuezha"] = "TL天狼",
	["designer:n_xuezha"] = "Notify",
	["illustrator:n_xuezha"] = "来自网络",
	["n_tuoyan"] = "拖延",
	["$n_tuoyan1"] = "别着急，欲速不达",
	["$n_tuoyan2"] = "再等会，作业马上就写完",
	[":n_tuoyan"] = "你受到伤害后，若伤害来源已受伤，你可以和对方各回复一点体力。",
	["n_chaoxi"] = "抄袭",
	["$n_chaoxi1"] = "这不叫抄，叫借鉴",
	["$n_chaoxi2"] = "抄的真过瘾",
	[":n_chaoxi"] = "出牌阶段开始时，你可以展示一名其他角色一张手牌，直到你下个出牌阶段开始，你有3次机会将一张手牌当做那张展示的牌使用。",
	["chaoxi-invoke"] = "请选择一名角色，展示其一张手牌",
}

n_xiaozuzhang = sgs.General(extension2,"n_xiaozuzhang","n_n",3)
n_baobi = sgs.CreateTriggerSkill{
	name = "n_baobi",
	events = {sgs.DamageCaused,sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if event == sgs.DamageCaused then
			if damage.from:hasSkill(self:objectName()) and damage.from:askForSkillInvoke(self:objectName(),data) then
				room:broadcastSkillInvoke(self:objectName())
				damage.from:drawCards(1)
				damage.to:drawCards(1)
				damage.to:gainMark("@n_harbor",1)
				return true
			end
		else
			local x = damage.to:getMark("@n_harbor")
			damage.to:loseAllMarks("@n_harbor")
			damage.damage = damage.damage + x
			data:setValue(damage)
		end
	end,
	can_trigger = function(self,target)
		return target
	end,
}
n_xiaozuzhang:addSkill(n_baobi)
n_huyin = sgs.CreateTriggerSkill{
	name = "n_huyin",
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.from:getMark("@n_harbor")>0 and damage.to:hasSkill(self:objectName()) and damage.from:askForSkillInvoke(self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName())
			damage.from:drawCards(1)
			damage.to:drawCards(1)
			damage.from:loseMark("@n_harbor",1)
			return true
		end
	end,
	can_trigger = function(self,target)
		return target
	end,
}
n_xiaozuzhang:addSkill(n_huyin)
n_shenweicard = sgs.CreateSkillCard{
	name = "n_shenweicard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@n_force")
		room:doSuperLightbox("n_xiaozuzhang", "n_shenwei")
		local all = room:getOtherPlayers(source)
		for _,p in sgs.qlist(all) do
			room:damage(sgs.DamageStruct("n_shenwei", source, p))
		end
		for _,p in sgs.qlist(all) do
			room:recover(p,sgs.RecoverStruct(source))
		end
	end
}
n_shenweivs = sgs.CreateViewAsSkill{
	name = "n_shenwei",
	n = 0,
	view_as = function(self, cards)
		return n_shenweicard:clone()
	end,
	enabled_at_play=function(self, player)
		return player:getMark("@n_force") >= 1
	end
}
n_shenwei = sgs.CreateTriggerSkill{
	name = "n_shenwei",
	frequency = sgs.Skill_Limited,
	limit_mark = "@n_force",
	events = {sgs.NonTrigger},
	view_as_skill = n_shenweivs,
	on_trigger = function()	end
}
n_xiaozuzhang:addSkill(n_shenwei)
sgs.LoadTranslationTable{
	["n_xiaozuzhang"] = "小组长",
	["#n_xiaozuzhang"] = "形式主义",
	["~n_xiaozuzhang"] = "真没想到...",
	["designer:n_xiaozuzhang"] = "Notify",
	["illustrator:n_xiaozuzhang"] = "来自网络",
	["@n_harbor"] = "庇",
	["@n_force"] = "威",
	["n_baobi"] = "包庇",
	[":n_baobi"] = "你造成伤害时，可与对方各摸一张牌，令其获得一枚“庇”标记，防止本次伤害。有“庇”标记的角色受到伤害时，移除所有“庇”标记令伤害+X。",
	["$n_baobi"] = "收人钱财，替人消灾",
	["n_huyin"] = "互荫",
	[":n_huyin"] = "其他角色对你造成伤害时，若其有“庇”标记，其可以与你各摸一张牌并移除一枚“庇”标记，防止本次伤害。",
	["$n_huyin"] = "滴水之恩，涌泉以报",
	["n_shenwei"] = "伸威",
	["$n_shenwei"] = "是可忍，孰不可忍",
	[":n_shenwei"] = "限定技。出牌阶段，你可以对所有其他角色造成一点伤害，再令所有其他角色回复一点体力。",
}

n_xiaoyaoge = sgs.General(extension3,"n_xiaoyaoge","n_pigeon")
n_shenshouCard = sgs.CreateSkillCard{
	name = "n_shenshouCard", 
	target_fixed = false, 
	will_throw = true, 
	filter = function(self, targets, to_select) 
		return to_select:objectName() ~= sgs.Self:objectName() and not to_select:isAllNude()
	end,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_effect = function(self, effect) 
		local player = effect.from
		local target = effect.to
		local room = player:getRoom()
		local _data1 = sgs.QVariant()
		_data1:setValue(target)
		local typeChoice = room:askForChoice(player,"n_shenshou","basic+trick+equip",
		_data1)
		
		local msg = sgs.LogMessage()
		msg.type = "#BroadcastShenshou"
		msg.from = player
		msg.arg = typeChoice
		room:sendLog(msg)
		
		_data1:setValue(player)
		local card = n_askForGiveCardTo(target,player,"n_shenshou",".|.|.|.!","#ShenshouGive:"..player:getGeneralName(),true)
		if card:getType() ~= typeChoice then
			msg.type = "#shenshoudifferent"
			msg.from = target
			msg.arg = card:getType()
			room:sendLog(msg)
			player:drawCards(1)
		else
			msg.type = "#shenshousame"
			msg.from = target
			msg.arg = card:getType()
			room:sendLog(msg)
		end
	end
}
n_shenshou = sgs.CreateViewAsSkill{
	name = "n_shenshou",
	n = 0,
	view_as = function(self, cards) 
		return n_shenshouCard:clone()
	end, 
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_shenshouCard")
	end,
}
n_xiaoyaoge:addSkill(n_shenshou)
sgs.LoadTranslationTable{
	["n_xiaoyaoge"] = "逍遥哥",
	["#n_xiaoyaoge"] = "大佬求写",
	["designer:n_xiaoyaoge"] = "Notify",
	["illustrator:n_xiaoyaoge"] = "来自网络",
	["~n_xiaoyaoge"] = "怎能如此对我...",
	["n_shenshou"] = "伸手",
	[":n_shenshou"] = "阶段技。你可声明一种类型并令一名其他角色交给你一张牌，若此牌类型与你指定类型不同，你摸一张牌。",
	["#ShenshouGive"] = "请交给 %src 一张牌",
	["#BroadcastShenshou"] = "%from 声明了 %arg",
	["#shenshousame"] = "%from 交出的是 %arg ,符合伸手需求",
	["#shenshoudifferent"] = "%from 交出的是 %arg ,不符合伸手需求",
	["$n_shenshou1"] = "还望先生救我！",
	["$n_shenshou2"] = "言出子口，入于吾耳，可以言未？",
}

n_wch = sgs.General(extension3,"n_wch","n_pigeon",3)
n_zhuangben = sgs.CreateTriggerSkill{
	name = "n_zhuangben",
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local room = player:getRoom()
		if (use.card:getTypeId() == sgs.Card_TypeTrick) then
			if not room:askForSkillInvoke(player, self:objectName()) then return false end
			local dscd = room:askForDiscard(player, "n_zhuangben", 1, 1, true, true)
			if not dscd then return end
			room:broadcastSkillInvoke("n_zhuangben")
			player:gainMark("@n_jiao",1)
		end
	end
}
n_wch:addSkill(n_zhuangben)
n_shenjiaoCard = sgs.CreateSkillCard{
	name = "n_shenjiaoCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, player, targets)
		player:loseMark("@n_jiao",1)
		player:drawCards(2)
	end
}
n_shenjiaovs = sgs.CreateViewAsSkill{
	name = "n_shenjiao",
	n = 0,
	view_as = function(self, cards) 
		return n_shenjiaoCard:clone()
	end, 
	enabled_at_play = function(self, player)
		return player:getMark("@n_jiao") > 0
	end
}
n_shenjiao = sgs.CreateTriggerSkill{
	name = "n_shenjiao",
	events = {sgs.Dying},
	view_as_skill = n_shenjiaovs,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getMark("@n_jiao") == 0 then return end
		local dying = data:toDying()
		local _player = dying.who
		if _player:objectName() == player:objectName() then return end
		if _player:getHp() < 1 then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:broadcastSkillInvoke("jijiu")
				player:loseMark("@n_jiao",1)
				local recover = sgs.RecoverStruct()
				recover.who = player
				room:recover(_player, recover)
				room:setEmotion(_player,"recover")
			end
		end
		return false
	end,
	can_trigger = function(self,target)
		return target
	end
}
n_wch:addSkill(n_shenjiao)
sgs.LoadTranslationTable{
	["n_wch"] = "水饺wch哥",
	["#n_wch"] = "高达杀作者",
	["&n_wch"] = "饺神",
	["designer:n_wch"] = "Notify",
	["illustrator:n_wch"] = "来自网络",
	["~n_wch"] = "怎能如此对我...",
	["n_zhuangben"] = "装笨",
	["$n_zhuangben"] = "孩儿愚钝",
	[":n_zhuangben"] = "每当你使用锦囊牌后，你可以弃置一张牌获得一个“饺”标记。",
	["@n_jiao"] = "饺",
	["n_shenjiao"] = "神饺",
	["$n_shenjiao"] = "看我的厉害！",
	[":n_shenjiao"] = "出牌阶段，你可以弃置一枚“饺”标记并摸两张牌；一名其他角色处于濒死状态时，你可以弃置一枚“饺”标记，令其回复一点体力。",
}

n_notify = sgs.General(extension3,"n_notify","n_pigeon",3)
n_shouhuoCard = sgs.CreateSkillCard{
	name = "n_shouhuoCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, selected, to_select)
		return (#selected == 0) and
		(to_select:objectName() ~= sgs.Self:objectName()) and not (to_select:hasSkill("wumou"))
	end ,
	on_effect = function(self,effect)
		local target = effect.to
		local room = target:getRoom()
		effect.from:setTag("shouhuo_user", sgs.QVariant(true))	
		room:obtainCard(target, self,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, 
					effect.from:objectName(), target:objectName(), "n_shouhuo", ""))
		target:gainMark("@n_confused",1)
		room:acquireSkill(target,"wumou")
	end
}
n_shouhuovs = sgs.CreateViewAsSkill{
	name = "n_shouhuo",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isRed()
	end ,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local card = n_shouhuoCard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end ,
}
n_shouhuo = sgs.CreateTriggerSkill{
	name = "n_shouhuo",
	events = {sgs.Death,sgs.EventPhaseStart},
	view_as_skill = n_shouhuovs,
	can_trigger = function(self,target)
		return target and target:getTag("shouhuo_user"):toBool()
	end,
	on_trigger = function(self,event,player,data)	
		local room = player:getRoom()
		if event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then return false end
			local all = room:getAllPlayers()
			for _,p in sgs.qlist(all) do
				if p:getMark("@n_confused") > 0 then
					p:loseAllMarks("@n_confused")
					room:detachSkillFromPlayer(p,"wumou")
				end
			end
		else	
			if player:getPhase() == sgs.Player_Start then
				local all = room:getAllPlayers()
				for _,p in sgs.qlist(all) do
					if p:getMark("@n_confused") > 0 then
						p:loseAllMarks("@n_confused")
						room:detachSkillFromPlayer(p,"wumou")
					end
				end
			end
		end
	end
}
n_notify:addSkill(n_shouhuo)
n_jieye = sgs.CreateTriggerSkill{
	name = "n_jieye",
	events = {sgs.EventPhaseStart},
	on_trigger = function(self,event,player,data)	
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Finish then
			for _,ntify in sgs.qlist(room:findPlayersBySkillName("n_jieye")) do
			local equips = player:getEquips()
			if not equips:isEmpty() then
				if room:getCurrent():objectName() ~= ntify:objectName() and ntify:askForSkillInvoke("n_jieye", data) then
					local card = room:askForCardChosen(ntify, player, "e", self:objectName(), false, sgs.Card_MethodNone)
					room:obtainCard(player,card)
					room:broadcastSkillInvoke(self:objectName())
				end
			end
			end
		end			
	end,
	can_trigger = function(self ,target)
		return target
	end,
}
n_notify:addSkill(n_jieye)
n_kuailiu = sgs.CreateTriggerSkill{
	name = "n_kuailiu",
	events = {sgs.SlashEffected},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if not player:faceUp() then return false end
		if player:askForSkillInvoke(self:objectName()) then
			room:broadcastSkillInvoke(self:objectName())
			player:drawCards(1)
			player:turnOver()
			return true
		end
	end,
}
n_notify:addSkill(n_kuailiu)
sgs.LoadTranslationTable{
	["n_notify"] = "Notify",
	["&n_notify"] = "N新",
	["#n_notify"] = "授惑解业",
	["designer:n_notify"] = "Notify",
	["illustrator:n_notify"] = "来自网络",
	["~n_notify"] = "被看穿了么...",
	["n_shouhuo"] = "授惑",
	[":n_shouhuo"] = "出牌阶段，你可以交给一名没有“无谋”的其他角色一张红色牌，令其获得“无谋”直到你下个回合开始。",
	["@n_confused"] = "惑",
	["$n_shouhuo1"] = "如此如此，我军自破！",
	["$n_shouhuo2"] = "如此，我军将败，岂不美哉？",
	["n_jieye"] = "解业",
	[":n_jieye"] = "其他角色的结束阶段，你可选择其装备区内的一张牌令其收回。",
	["$n_jieye1"] = "你用不了这么多了！",
	["$n_jieye2"] = "众将听令，准备动手！",
	["n_kuailiu"] = "快溜",
	[":n_kuailiu"] = "当你成为【杀】的目标后，若你武将牌正面朝上，你可以摸一张牌并翻面，令此【杀】无效。",
	["$n_kuailiu1"] = "撤！快撤！",
	["$n_kuailiu2"] = "哼哼哼哼...我先走一步！",
}

n_zy = sgs.General(extension3,"n_zy","n_pigeon",3)
n_juanlaovs = sgs.CreateViewAsSkill{
	name = "n_juanlao",
	n = 0,
	view_as = function(self, card) 
		local cards = sgs.Sanguosha:cloneCard(sgs.Sanguosha:getCard(sgs.Self:getMark("n_juanlao")):objectName())
		cards:setSkillName("n_juanlao")
		cards:setCanRecast(false)
		return cards
	end, 
	enabled_at_play = function(self, player)
		return sgs.Self:getMark("n_juanlaoused") == 0 and sgs.Self:getMark("n_juanlao") > 0
	end
}
n_juanlao = sgs.CreateTriggerSkill{
	name = "n_juanlao",
	view_as_skill = n_juanlaovs,
	events = {sgs.CardFinished,sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card:isNDTrick() and not use.card:isVirtualCard() then
				room:setPlayerMark(player,"n_juanlao",0)
				room:setPlayerMark(player,"n_juanlao",use.card:getId())
			end
			if use.card:getSkillName() == "n_juanlao" then 
				room:setPlayerMark(player,"n_juanlaoused",1)
			end
		elseif event == sgs.EventPhaseStart then
			room:setPlayerMark(player,"n_juanlaoused",0)
			room:setPlayerMark(player,"n_juanlao",0)
		end
	end,
}
n_zy:addSkill(n_juanlao)
n_yegeng = sgs.CreateTriggerSkill{
	name = "n_yegeng",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardFinished,sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card:isNDTrick() then
				room:setPlayerMark(player,"n_yegeng",player:getMark("n_yegeng")+1)
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				room:setPlayerMark(player,"n_yegeng",0)
			elseif player:getPhase() == sgs.Player_Finish then
				if player:getMark("n_yegeng") >= 3 then
					n_CompulsorySkill(room,player,self:objectName())
					player:gainAnExtraTurn()
				end
				room:setPlayerMark(player,"n_yegeng",0)
			end
		end
	end,
}
n_zy:addSkill(n_yegeng)
sgs.LoadTranslationTable{
	["n_zy"] = "ZY",
	["&n_zy"] = "ＺＹ",
	["#n_zy"] = "大大大大佬",
	["~n_zy"] = "可恶！就差一步了...",
	["designer:n_zy"] = "Notify",
	["illustrator:n_zy"] = "来自网络",
	["n_juanlao"] = "奆佬",
	[":n_juanlao"] = "阶段技。你可以视为使用了本回合你使用过的上一张非转化普通锦囊牌。",
	["$n_juanlao"] = "物尽其用，真正耐用！",
	["n_yegeng"] = "夜更",
	[":n_yegeng"] = "锁定技。结束阶段，若你本回合使用普通锦囊牌数量不小于3，你进行一个额外的回合。",
	["$n_yegeng"] = "（键盘）",
}

n_zeroona = sgs.General(extension3,"n_zeroona","n_pigeon",3,false)
n_jiyi = sgs.CreateTriggerSkill{
	name = "n_jiyi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.AfterDrawInitialCards,sgs.EventPhaseStart,sgs.DrawInitialCards},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.AfterDrawInitialCards then
			n_CompulsorySkill(room,player,self:objectName())
			local god_card = room:askForCard(player,".|.|.|hand","njiyi",sgs.QVariant(),sgs.Card_MethodDiscard)
			if (god_card==nil) then
				god_card = player:getRandomHandCard() 
				player:speak("234234")
				room:throwCard(god_card,player)
			end
			room:setPlayerMark(player,"n_gdcdid",god_card:getId())
		elseif event == sgs.DrawInitialCards then
			data:setValue(data:toInt()+3)
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				n_CompulsorySkill(room,player,self:objectName())
				room:obtainCard(player,sgs.Sanguosha:getCard(player:getMark("n_gdcdid")))
			end
		end
	end
}
n_zeroona:addSkill(n_jiyi)
sgs.LoadTranslationTable{
	["n_zeroona"] = "zeroOna",
	["#n_zeroona"] = "神杀再兴",
	["&n_zeroona"] = "空神",
	["~n_zeroona"] = "删武将，谢谢..",
	["njiyi"] = "请弃置一张手牌，以后每个准备阶段你都会得到这张牌",
	["cv:n_zeroona"] = "zeroOna",
	["designer:n_zeroona"] = "Notify",
	["illustrator:n_zeroona"] = "来自网络",
	["n_jiyi"] = "记忆",
	["$n_jiyi1"] = "今日默书，方恨千卷诗书未能全记。",
	["$n_jiyi2"] = "博闻强识，不辱才女之名。",
	[":n_jiyi"] = "锁定技。你多摸三张起始手牌，分发起始手牌后，你弃一张牌；准备阶段，你从任意区域获得那张弃置的牌。",
}

n_hospair = sgs.General(extension3,"n_hospair","n_pigeon",3,false)
n_fudu = sgs.CreateTriggerSkill{
	name = "n_fudu",
	events = sgs.CardFinished,
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if not (use.to:length() == 1 and (use.card:isNDTrick() or use.card:isKindOf("BasicCard"))) or (use.card:isKindOf("Collateral") or use.card:isKindOf("Jink") or use.card:isKindOf("Nullification")) then return false end
		for _,hs in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if use.from:objectName() ~= hs:objectName() then
				local fd_use = sgs.CardUseStruct()
				fd_use.card = sgs.Sanguosha:cloneCard(use.card:objectName())
				fd_use.card:setSkillName("n_fudu")
				local target
				if use.to:at(0):objectName() ~= hs:objectName() then
					target = use.to:at(0)
				else
					target = use.from
				end
				fd_use.to:append(target)
				fd_use.from = hs
				local valid = true
				if use.card:isKindOf("Snatch") or use.card:isKindOf("Dismantlement") or use.card:isKindOf("FireAttack")then
					valid = (not target:isAllNude()) and target:isAlive()
				elseif use.card:isKindOf("Peach") then
					valid = target:isAlive() and target:isWounded()
				else
					valid = target:isAlive()
				end
				if not hs:isKongcheng() and valid then
					local new_card = room:askForCard(hs,".|.|.|hand","#n_fuduuse::"..fd_use.to:at(0):getGeneralName()..":"..use.card:objectName(),data,sgs.Card_MethodNone)
					if new_card then
						fd_use.card:addSubcard(new_card)
						if use.card:getSkillName() ~= "" then
							room:broadcastSkillInvoke(use.card:getSkillName())
						end
						room:useCard(fd_use)
					end
				end
			end
		end
	end
}
n_hospair:addSkill(n_fudu)
n_hospair:addSkill("mingzhe")
sgs.LoadTranslationTable{
	["n_hospair"] = "Ho-spair",
	["~n_hospair"] = "就这样...结束了...",
	["&n_hospair"] = "惑神",
	["#n_hospair"] = "复读机",
	["cv:n_hospair"] = "西西里Evanism",
	["designer:n_hospair"] = "Notify",
	["illustrator:n_hospair"] = "来自网络",
	["n_fudu"] = "复读",
	["$n_fudu"] = "+1",
	[":n_fudu"] = "其他角色使用牌指定唯一目标后，若你是此目标，你可以将一张手牌当做此牌对使用者使用，否则你可以将一张手牌当做此牌对目标使用。\
	<font color=\"grey\">（【借刀杀人】除外）</font>",
	["#n_fuduuse"] = "你现在可以将一张手牌当做【%arg】对 %dest 使用",
	["mingzhe1"] = "明以洞察，哲以保身。",
	["mingzhe2"] = "塞翁失马，焉知非福。",
}

n_qunlingdao = sgs.General(extension3,"n_qunlingdao","n_pigeon",3)
n_lingxiu = sgs.CreateTriggerSkill{
	name = "n_lingxiu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		local lx = false
		local room = player:getRoom()
		local others = room:getOtherPlayers(player)
		for _,p in sgs.qlist(others) do
			if p:getHandcardNum() > player:getHandcardNum() then
				lx = true
				break
			end
		end
		if move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceHand and not room:getTag("FirstRound"):toBool() and lx then -- and bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DRAW then
			n_CompulsorySkill(room,player,self:objectName())
			room:getThread():delay(300)
			player:drawCards(1)
		end
		return false
	end, 
}
n_qunlingdao:addSkill(n_lingxiu)
n_qunzhi_select = sgs.CreateSkillCard{
	name = "n_qunzhi", 
	will_throw = false, 
	target_fixed = true, 
	handling_method = sgs.Card_MethodNone, 
	on_use = function(self, room, source, targets)
		local choices = {}
		for _, name in ipairs(trick_patterns) do
			local poi = sgs.Sanguosha:cloneCard(name, sgs.Card_NoSuit, -1)
			poi:setSkillName("n_qunzhi")
			for _,cd in sgs.qlist(self:getSubcards()) do
				poi:addSubcard(cd)
			end
			if poi:isAvailable(source) and source:getMark("n_qunzhi"..name) == 0 and not table.contains(sgs.Sanguosha:getBanPackages(), poi:getPackage()) then
				table.insert(choices, name)
			end
		end
		if next(choices) ~= nil then
			table.insert(choices, "cancel")
			local pattern = room:askForChoice(source, "n_qunzhi", table.concat(choices, "+"))
			if pattern and pattern ~= "cancel" then			
				pos = getPos(trick_patterns, pattern)
				room:setPlayerMark(source, "n_qunzhipos", pos)
				room:askForUseCard(source, "@@n_qunzhi", "@n_qunzhi:"..pattern)--%src
			end
		end
	end, 
}
n_qunzhiCard = sgs.CreateSkillCard{
	name = "n_qunzhiCard", 
	will_throw = false, 
	filter = function(self, targets, to_select)
		local name = ""
		local card
		local plist = sgs.PlayerList()
		for i = 1, #targets do plist:append(targets[i]) end
		local aocaistring = self:getUserString()
		if aocaistring ~= "" then 
			local uses = aocaistring:split("+")
			name = uses[1]
			card = sgs.Sanguosha:cloneCard(name, sgs.Card_NoSuit, -1)
			if card and card:targetFixed() then
				return false
			else
				return card and card:targetFilter(plist, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, plist)
			end
		end
		return true
	end, 
	target_fixed = function(self)		
		local name = ""
		local card
		local aocaistring = self:getUserString()
		if aocaistring ~= "" then 
			local uses = aocaistring:split("+")
			name = uses[1]
			card = sgs.Sanguosha:cloneCard(name, sgs.Card_NoSuit, -1)
		end	
		return card and card:targetFixed()
	end, 	
	feasible = function(self, targets)
		local name = ""
		local card
		local plist = sgs.PlayerList()
		for i = 1, #targets do plist:append(targets[i]) end
		local aocaistring = self:getUserString()
		if aocaistring ~= "" then
			local uses = aocaistring:split("+")
			name = uses[1]
			card = sgs.Sanguosha:cloneCard(name, sgs.Card_NoSuit, -1)
		end
		return card and card:targetsFeasible(plist, sgs.Self)
	end, 
	on_validate_in_response = function(self, user)
		local room = user:getRoom()
		local aocaistring = self:getUserString()
		local use_card = sgs.Sanguosha:cloneCard(self:getUserString(), sgs.Card_NoSuit, -1)
		if string.find(aocaistring, "+")  then
			local uses = {}
			for _, name in pairs(aocaistring:split("+"))do
				if user:getMark("n_qunzhi"..name) == 0 then 
				table.insert(uses, name)
				end
			end
			local name = room:askForChoice(user, "n_qunzhi", table.concat(uses, "+"))
			use_card = sgs.Sanguosha:cloneCard(name, sgs.Card_NoSuit, -1)
		end
		use_card:setSkillName("n_qunzhi")
		for _,id in sgs.qlist(self:getSubcards()) do				
			use_card:addSubcard(id)
		end	
		return use_card	
	end, 
	on_validate = function(self, card_use)
		local room = card_use.from:getRoom()
		local aocaistring = self:getUserString()
		local use_card = sgs.Sanguosha:cloneCard(self:getUserString(), sgs.Card_NoSuit, -1)
		if string.find(aocaistring, "+")  then
			local uses = {}
			for _, name in pairs(aocaistring:split("+"))do
				if card_use.from:getMark("n_qunzhi"..name) == 0 then 
				table.insert(uses, name)
				end
			end
			local name = room:askForChoice(card_use.from, "n_qunzhi", table.concat(uses, "+"))
			use_card = sgs.Sanguosha:cloneCard(name, sgs.Card_NoSuit, -1)
		end
		if use_card == nil then return false end
		use_card:setSkillName("n_qunzhi")
		local available = true
		for _, p in sgs.qlist(card_use.to) do
			if card_use.from:isProhibited(p, use_card)	then
				available = false
				break
			end
		end
		if not available then return nil end
		for _,id in sgs.qlist(self:getSubcards()) do				
			use_card:addSubcard(id)
		end	
		return use_card	
	end, 
}
n_qunzhiVS = sgs.CreateViewAsSkill{
	name = "n_qunzhi",
	n = 199,
	view_filter = function(self, selected, to_select)
		if #selected < tonumber(sgs.Self:getHandcardNum()/2) then
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern and pattern == "@@n_qunzhi" then
			return true
		else return false end
		else return false end
	end,
	view_as = function(self, cards)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			if #cards == 0 then
				local acard = n_qunzhi_select:clone()
				return acard
			end
		else
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			local acard = n_qunzhiCard:clone()
			if pattern and pattern == "@@n_qunzhi" then
				if #cards >= sgs.Self:getHandcardNum() / 2 then
				pattern = trick_patterns[sgs.Self:getMark("n_qunzhipos")]
				for _,cid in ipairs(cards) do
					acard:addSubcard(cid)
				end
				end
			end
			acard:setUserString(pattern)
			return acard
		end
	end, 
	enabled_at_play = function(self, player)
		return player:getHp() <= player:getHandcardNum() and not player:hasUsed("#n_qunzhiCard")
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@n_qunzhi"
	end, 
} 
n_qunzhi = sgs.CreateTriggerSkill{
	name = "n_qunzhi", 
	view_as_skill = n_qunzhiVS, 
	events = {sgs.PreCardUsed, sgs.CardResponded}, 
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.PreCardUsed or event == sgs.CardResponded then
			local card
			if event == sgs.PreCardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse then
				if card:getSkillName() == "n_qunzhi" and player:getMark("n_qunzhi"..card:objectName()) == 0 then
					room:addPlayerMark(player, "n_qunzhi"..card:objectName())
					local reset = false
					local n = 0
					for _,str in ipairs(trick_patterns) do
						for _, mark in sgs.list(player:getMarkNames()) do
							if string.find(mark, str) and player:getMark(mark) > 0 then
								n = n+1
								break
							end
						end
					end
					if n == #trick_patterns then reset = true end
					if reset then
						for _,str in ipairs(trick_patterns) do
							room:setPlayerMark(player,"n_qunzhi"..str,0)
						end
					end
				end
			end
		end
	end
}
n_qunlingdao:addSkill(n_qunzhi)
sgs.LoadTranslationTable{
	["n_qunlingdao"] = "群领导",
	["#n_qunlingdao"] = "间歇性观群",
	["cv:n_qunlingdao"] = "ChongMei Xu",
	["~n_qunlingdao"] = "我还会继续看群的...",
	["designer:n_qunlingdao"] = "Notify",
	["illustrator:n_qunlingdao"] = "来自网络",
	["n_lingxiu"] = "领袖",
	[":n_lingxiu"] = "锁定技。你获得手牌后，若你的手牌数不为场上最多，你摸一张牌。",
	["$n_lingxiu1"] = "我才是领导！",
	["$n_lingxiu2"] = "都听我的！",
	["n_qunzhi"] = "群智",
	[":n_qunzhi"] = "阶段技。若你的体力值不超过你的手牌数，你可以将一半的手牌当一张普通锦囊牌使用。（每种限用一次，你因本技能使用过全部普通锦囊牌后技能状态刷新。）",
	["@n_qunzhi"] = "请将一半的手牌当 %src 使用",
	["~n_qunzhi"] = "选中一半的手牌->选目标->确定",
	["$n_qunzhi1"] = "集思广益！",
	["$n_qunzhi2"] = "群众的智慧是无穷的！",
}

n_wyw = sgs.General(extension3,"n_wyw","n_pigeon")
n_junengcard = sgs.CreateSkillCard{
	name = "n_junengcard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room,source,target)
		room:showCard(source, self:getEffectiveId())
		local id = self:getSubcards():first()
		room:setPlayerMark(source,"n_junengid",id)
		room:setPlayerMark(source,"n_junengenable",1)
		local cards = source:handCards()
		local todis = sgs.Sanguosha:cloneCard("slash")
		for _,cd in sgs.qlist(cards) do
			if cd ~= id then
				todis:addSubcard(cd)
			end
		end
		room:throwCard(todis,source,source)
		room:setPlayerMark(source,"n_junengtimes",todis:getSubcards():length())
	end
}
n_junengvs = sgs.CreateViewAsSkill{
	name = "n_juneng",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isAvailable(sgs.Self) and not to_select:isKindOf("EquipCard") and not to_select:isKindOf("DelayedTrick")
	end,
	view_as = function(self,cards)
		if #cards == 0 then return nil end
		local card = n_junengcard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end,
	enabled_at_play = function(self, player)
		return player:usedTimes("#n_junengcard") == 0
	end,
}
n_juneng = sgs.CreateTriggerSkill{
	name = "n_juneng",
	events = {sgs.EventPhaseStart,sgs.CardFinished},
	view_as_skill = n_junengvs,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase()==sgs.Player_Finish then
				room:setPlayerMark(player,"n_junengenable",0)
			end
		else
			local use = data:toCardUse()
			if player:getMark("n_junengenable") <= 0 or use.card:getId()~=player:getMark("n_junengid") then return end
			local cd = sgs.Sanguosha:cloneCard(use.card:objectName())
			cd:setSkillName("_"..self:objectName())
			local jn_use = sgs.CardUseStruct()
			jn_use.from =  use.from
			jn_use.to = use.to
			jn_use.card = cd
			for i=1,player:getMark("n_junengtimes") do
				room:useCard(jn_use)
			end
		end
	end
}
n_wyw:addSkill(n_juneng)
sgs.LoadTranslationTable{
	["n_wyw"] = "wyw",
	["#n_wyw"] = "娱乐包作者",
	["&n_wyw"] = "妹神",
	["~n_wyw"] = "不可能...",
	["designer:n_wyw"] = "Notify",
	["illustrator:n_wyw"] = "宫崎骏",
	["n_juneng"] = "聚能",
	["$n_juneng"] = "这，就是绝对的力量！",
	[":n_juneng"] = "阶段技。你可以展示一张可用的基本牌或普通锦囊牌并弃置其他手牌令此牌本回合内结算次数+X（X为本回合内以此法弃置的手牌数）",
}

n_qiongjige = sgs.General(extension3,"n_qiongjige","n_pigeon",3)
n_aoqiucard = sgs.CreateSkillCard{
	name = "n_aoqiucard", 
	will_throw = false, 
	mute = true,
	filter = function(self, targets, to_select) 
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
		and not to_select:isKongcheng()
	end, 
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_use = function(self, room, source, targets)
		local success = source:pindian(targets[1], "n_aoqiu")
		
		local winner,loser
		if success then
			winner = source
			loser = targets[1]
		else
			winner = targets[1]
			loser = source
		end
		if winner and winner:hasSkill("n_aoqiu") then
			local card = room:askForCard(loser,".|.|.|.","#ShenshouGive:"..winner:getGeneralName() ,sgs.QVariant(), sgs.Card_MethodNone)
			if card then
				room:obtainCard(winner, card, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, 
				loser:objectName(), winner:objectName(), self:objectName(), ""))
			else
				local x = 1
				if not (loser:getGeneral():getPackage()=="brainholeqy") then x = 2 end
				winner:drawCards(x)
			end
		end
		return false
	end
}
n_aoqiu = sgs.CreateViewAsSkill{
	name = "n_aoqiu", 
	n = 0,
	view_as = function(self, card) 
		local cards = n_aoqiucard:clone()
		return cards
	end, 
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_aoqiucard") and not player:isKongcheng()
	end
}
n_qiongjige:addSkill(n_aoqiu)
n_qianglun = sgs.CreateTriggerSkill{
	name = "n_qianglun",
	--frequency = sgs.Skill_Compulsory,
	dynamic_frequency = function(self, target)
	ghjgj:ghkg()
	return sgs.Skill_Compulsory end,
	events = {sgs.Pindian, sgs.Damaged, sgs.Damage}, 
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local caninvoke = false
		local source, target = player, nil
		if event == sgs.Damaged then 
			caninvoke = true
			target = data:toDamage().from
		end
		if event == sgs.Pindian then
			local pindian = data:toPindian()
			local winner = pindian.from
			local loser = pindian.to
			if pindian.from_card:getNumber() <= pindian.to_card:getNumber() then
				winner = pindian.to
				loser = pindian.from
			end
			if loser:hasSkill(self:objectName()) then
				caninvoke = true
				source = loser
				target = winner
			end
		end
			
		if caninvoke and target then
			room:broadcastSkillInvoke(self:objectName())
			room:sendCompulsoryTriggerLog(source, self:objectName())
			--source:drawCards(1, self:objectName())
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:setSkillName(self:objectName())
			if source:canSlash(target, slash, false) and not source:isProhibited(target, slash) then
				room:useCard(sgs.CardUseStruct(slash, source, target))
				if source:getMark("qianglunSlashDamaged") > 0 then
					room:removePlayerMark(source, "qianglunSlashDamaged")
				else
					room:askForDiscard(source, self:objectName(), 1, 1, false, true)
				end
			end
		end
		if event == sgs.Damage then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and damage.card:getSkillName() == self:objectName() then
				room:addPlayerMark(player, "qianglunSlashDamaged")
				if not (damage.to and damage.to:isAlive()) then return false end
				damage.from:drawCards(1, self:objectName())
				local log = sgs.LogMessage()
				log.type = "#InvokeSkill"
				log.from = damage.to
				log.arg = "nosganglie"
				room:sendLog(log)
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|heart"
				judge.good = false
				judge.reason = "nosganglie"
				judge.who = damage.to
				room:broadcastSkillInvoke("nosganglie")
				room:judge(judge)
				if damage.from:isDead() then return false end
				if judge:isGood() then
					if damage.from:getHandcardNum() < 2 then
						room:damage(sgs.DamageStruct("nosganglie", damage.to, damage.from))
					else
						if not room:askForDiscard(damage.from, "nosganglie", 2, 2, true) then
							room:damage(sgs.DamageStruct("nosganglie", damage.to, damage.from))
						end
					end
				end
			end
		end
		return false
	end,
}
n_qiongjige:addSkill(n_qianglun)
sgs.LoadTranslationTable{
	["n_qiongjige"] = "穷极哥",
	["#n_qiongjige"] = "自我沉浸",
	["n_aoqiu"] = "傲求",
	[":n_aoqiu"] = "阶段技。你可以与一名其他角色拼点，若你赢，则其选择一项：1.交给你一张手牌；2.令你摸2张牌，若其属于脑洞•鸽包，则改为令你摸一张牌。",
	["$n_aoqiu1"] = "大佬帮忙整个app呗！",
	["$n_aoqiu2"] = "高大上一点，最起码也要像十周年那样。",
	["n_qianglun"] = "强论",
	[":n_qianglun"] = "锁定技。你拼点没赢/受到伤害后，视为对对方/来源使用一张【杀】。当其受到此【杀】造成的伤害后，你摸一张牌且视为其对你发动旧“刚烈”；若此【杀】未造成伤害，你弃置一张牌。",
	["$n_qianglun1"] = "我要学的会，还会来低三下四地问吗？",
	["$n_qianglun2"] = "别人一天能学会，我要学一年。",
	["~n_qiongjige"] = "行了，这件事就算过去了！",
	["designer:n_qiongjige"] = "Notify",
	["cv:n_qiongjige"] = "ChongMei Xu",
	["illustrator:n_qiongjige"] = "来自网络",
}

n_daotuwang = sgs.General(extension3,"n_daotuwang","n_pigeon",3)
n_daotu = sgs.CreateTriggerSkill{
	name = "n_daotu",
	events = {sgs.CardFinished},
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local dts = room:findPlayersBySkillName(self:objectName())
		local card,from
		local use = data:toCardUse()
		card = use.card
		from = use.from
		local current = room:getCurrent()
		if not (card:isVirtualCard() or card:isKindOf("SkillCard")) then
			for _,p in sgs.qlist(dts) do
				local candt = true
				if current:hasFlag("n_daotud"..p:objectName()) then candt = false end
				for _,mark in sgs.list(p:getMarkNames()) do
					if string.find(mark,self:objectName()) and string.find(mark,card:objectName()) then
						candt = false
						break
					end
				end
				if from:objectName() == p:objectName() then candt = false end
				for _,cd in sgs.qlist(p:getHandcards()) do
					if cd:objectName() == card:objectName() then
						candt = false
						break
					end
				end
				if room:getCardPlace(card:getEffectiveId()) ~= sgs.Player_PlaceTable and room:getCardPlace(card:getEffectiveId()) ~= sgs.Player_DiscardPile and room:getCardPlace(card:getEffectiveId()) ~= sgs.Player_PlaceJudge then candt = false end
				if candt and p:askForSkillInvoke(self:objectName(),data) then
					room:broadcastSkillInvoke(self:objectName())
					room:addPlayerMark(p,self:objectName()..card:objectName())
					current:setFlags("n_daotud"..p:objectName())
					room:obtainCard(p,card)
				end
			end
		end
	end,

}
n_daotuwang:addSkill(n_daotu)
sgs.LoadTranslationTable{
	["n_daotuwang"] = "盗图王",
	["designer:n_daotuwang"] = "Notify",
	["~n_daotuwang"] = "盗图王，你.....",
	["illustrator:n_daotuwang"] = "网络",
	["#n_daotuwang"] = "人畜无害",
	["n_daotu"] = "盗图",
	["$n_daotu1"] = "此图，我怎么会错失。",
	["$n_daotu2"] = "你的图，现在是我的了！",
	[":n_daotu"] = "每名角色回合内限一次，其他角色使用非转化牌结算完成后，若你手中没有与之同名的牌，你可以获得之（每种牌名只能获得一次）",
}

n_abeeabee = sgs.General(extension3,"n_abeeabee","n_pigeon",3)

n_jibian = sgs.CreateTriggerSkill{
	name = "n_jibian",
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Play then
				if player:askForSkillInvoke(self:objectName()) then
					room:broadcastSkillInvoke(self:objectName())
					local targets = room:getOtherPlayers(player)
					for _,target in sgs.qlist(targets) do
						if target:getCardCount(true,false) >= 2 then
							choice = room:askForChoice(target, self:objectName(), "jibiandiscard+jibiannotdiscard")
							if choice == "jibiandiscard" then
								room:setPlayerFlag(target, "jibiandisFlag")
							end
						end
					end
					local flag = true
					for _,target in sgs.qlist(targets) do
						if target:hasFlag("jibiandisFlag") then
							room:askForDiscard(target, self:objectName(), 2, 2, false, true)
							room:setPlayerFlag(target, "-jibiandisFlag")
							flag = false
						end
					end
					if flag == true then
						player:drawCards(2)
						room:setPlayerFlag(player, "jibianBuff")
					end
				end
			end
		end
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Finish then
				if player:hasFlag("jibianBuff") then
					room:setPlayerFlag(player, "-jibianBuff")
				end
			end
		end
	end
}

n_jibianBuff = sgs.CreateTargetModSkill{
	name = "#n_jibianBuff",
	frequency = sgs.Skill_Compulsory,
	pattern = "Slash",
	residue_func = function(self, player)
		if player:hasFlag("jibianBuff") then
			return 2
		end
		return 0
	end
}

n_duoce = sgs.CreateTriggerSkill{
	name = "n_duoce",
	events = {sgs.SlashMissed, sgs.CardResponded, sgs.TargetSpecified, sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetSpecified or event == sgs.CardResponded then
			local card
			if event == sgs.TargetSpecified then
				card = data:toCardUse().card
			else
				if data:toCardResponse().m_isUse then
					card = data:toCardResponse().m_card
				end
			end
			if card:isKindOf("Slash") or card:isKindOf("Jink") then
				player:setTag("duoceTag", sgs.QVariant(card:getEffectiveId()))
			end
		end
		if event == sgs.CardUsed then
			card = data:toCardUse().card
			if card:isKindOf("Slash") or card:isKindOf("Jink") then
				player:setTag("duoceTag", sgs.QVariant(nil))
			end
		end
		if event == sgs.SlashMissed then
			local effect = data:toSlashEffect()
			if effect.from:hasSkill(self:objectName()) then
				local fromcard = sgs.Sanguosha:getCard(effect.from:getTag("duoceTag"):toInt())
				local tocard = sgs.Sanguosha:getCard(effect.to:getTag("duoceTag"):toInt())
				if fromcard and tocard then
					if effect.from:askForSkillInvoke(self:objectName()) then
						effect.to:obtainCard(fromcard)
						effect.from:obtainCard(tocard)
					end
				end
			end
			if effect.to:hasSkill(self:objectName()) then
				if effect.to:askForSkillInvoke(self:objectName()) then
					room:broadcastSkillInvoke(self:objectName())
					effect.to:drawCards(2)
				end
			end
		end
	end,
	can_trigger = function(self,target)
		return target
	end
}

n_abeeabee:addSkill(n_jibian)
n_abeeabee:addSkill(n_jibianBuff)
n_abeeabee:addSkill(n_duoce)

sgs.LoadTranslationTable{
	["n_abeeabee"] = "abeeabee",
	["designer:n_abeeabee"] = "abeeabee",
	["illustrator:n_abeeabee"] = "网络",
	["&n_abeeabee"] = "ab神",
	["cv:n_abeeabee"] = "发烟碳酸",
	["~n_abeeabee"] = "一着不慎、满盘皆输...",
	["#n_abeeabee"] = "盗图之王",
	["n_jibian"] = "机变",
	["$n_jibian1"] = "机巧谋略，我皆不输于你。",
	["$n_jibian2"] = "机变百出，锋锐无匹。",
	["jibiandiscard"] = "弃置两张牌",
	["jibiannotdiscard"] = "取消",
	[":n_jibian"] = "出牌阶段开始时，你可以令其他角色同时选择是否弃置两张牌；若均选择否，你摸两张牌且你本回合可以额外使用两张【杀】。",
	["n_duoce"] = "度策",
	["$n_duoce1"] = "策度敌情，观其施为。",
	["$n_duoce2"] = "彼得失之计，我以算策而知。",
	[":n_duoce"] = "其他角色使用【闪】抵消你使用的【杀】后，你可以交换两者；你使用【闪】抵消其他角色使用的【杀】后，你可以摸两张牌。",
}

n_guiling = sgs.General(extension3,"n_guiling","n_pigeon",3)
n_bianchengvs = sgs.CreateZeroCardViewAsSkill{
	name = "n_biancheng",
	view_as = function()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_nullification = function(self, player)
		local room = sgs.Sanguosha:currentRoom()
		local top_card = sgs.Sanguosha:getCard(room:getDrawPile():first())
		return top_card:isKindOf("Nullification") and top_card:isRed()
	end
}
n_biancheng = sgs.CreateTriggerSkill{
	name = "n_biancheng",
	view_as_skill = n_bianchengvs,
	events = {sgs.CardsMoveOneTime,sgs.BeforeCardsMove,sgs.PreCardUsed},
	on_trigger = function(self, event, player, data)
	    local room = player:getRoom()
		local pile = room:getDrawPile()
		if pile:isEmpty() then room:swapPile()	end
		local id = pile:first()
		if event == sgs.BeforeCardsMove then
		    local dmove = data:toMoveOneTime()
		    for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			    if (dmove.from_places:contains(sgs.Player_DrawPile) and dmove.card_ids:contains(p:getMark("n_bcid")))
				or dmove.to_place == sgs.Player_DrawPile then					
		                local move = sgs.CardsMoveStruct(p:getMark("n_bcid"), p, nil, sgs.Player_PlaceSpecial, sgs.Player_PlaceTable,
		                sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, p:objectName(),self:objectName() , ""))
		                move.from_pile_name = "&n_code"
		                local moves = sgs.CardsMoveList()
		                moves:append(move)
		                local gls = sgs.SPlayerList()
		                gls:append(p)
		                room:notifyMoveCards(true, moves, false, gls)
		                room:notifyMoveCards(false, moves, false, gls)	
		                if sgs.Sanguosha:getCard(p:getMark("n_bcid")):isBlack() then
		                	room:removePlayerCardLimitation(player, "use,response", "" .. p:getMark("n_bcid"))	
		                end			
		    		    room:setPlayerMark(p,"n_bc1st", 0)
		    	end
			end
		elseif event == sgs.CardsMoveOneTime then
			for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if p:getMark("n_bc1st")==0 then
					
					local move = sgs.CardsMoveStruct(id, nil, p, sgs.Player_PlaceTable, sgs.Player_PlaceSpecial,
					sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, p:objectName(),self:objectName() , ""))
		            move.to_pile_name = "&n_code"
		            local moves = sgs.CardsMoveList()
		            moves:append(move)
		            local gls = sgs.SPlayerList()
		            gls:append(p)
		            room:notifyMoveCards(true, moves, false, gls)
		            room:notifyMoveCards(false, moves, false, gls)
		            if sgs.Sanguosha:getCard(id):isBlack() then
		            	room:setPlayerCardLimitation(player, "use,response", "" .. id, false)
		            end
					room:addPlayerMark(p,"n_bc1st")
					room:setPlayerMark(p,"n_bcid",id)
				end
			end
		else
			if data:toCardUse().card:getId() == player:getMark("n_bcid") and player:hasSkill(self:objectName())then
				room:broadcastSkillInvoke(self:objectName())
				room:notifySkillInvoked(player,self:objectName())
				local msg = sgs.LogMessage()
				msg.type = '#InvokeSkill'
				msg.from = player
				msg.arg = self:objectName()
				room:sendLog(msg)
			end
		end
		return false
	end
}
n_guiling:addSkill(n_biancheng)
n_tiaoshicard = sgs.CreateSkillCard{
	name = "n_tiaoshicard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, player, targets)
		player:drawCards(1)
	end
}
n_tiaoshi = sgs.CreateViewAsSkill{
	name = "n_tiaoshi",
	n = 0,
	view_as = function(self, cards) 
		return n_tiaoshicard:clone()
	end, 
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_tiaoshicard")
	end
}
n_guiling:addSkill(n_tiaoshi)
sgs.LoadTranslationTable{
	["n_guiling"] = "归零",
	["~n_guiling"] = "本想混点项目经验，奈何咩有一个自己做网杀的大佬...",
	["designer:n_guiling"] = "Notify",
	["cv:n_guiling"] = "Notify",
	["illustrator:n_guiling"] = "网络",
	["&n_guiling"] = "归零神",
	["#n_guiling"] = "大展宏图",
	["n_biancheng"] = "编程",
	["$n_biancheng1"] = "我们的bug没有游戏。",
	["$n_biancheng2"] = "解锁了新大佬！",
	[":n_biancheng"] = "你可以将牌堆顶的一张红色牌如手牌般使用或打出。",
	["&n_code"] = "代码",
	["n_tiaoshi"] = "调试",
	["$n_tiaoshi"] = "不如让zy来调教调教。",
	[":n_tiaoshi"] = "阶段技。你可以摸一张牌。",
}

n_siguningshang = sgs.General(extension3,"n_siguningshang","n_pigeon",3)
n_gongji = sgs.CreateTriggerSkill{
    name = "n_gongji",
    frequency = sgs.Skill_Compulsory,
    events = {sgs.TargetConfirming, sgs.Damaged, sgs.CardFinished}, 
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.TargetConfirming then 
            local use = data:toCardUse()
            if (not use.to:contains(player)) or (not player:hasSkill(self:objectName())) then return false end
            if use.card and use.card:isKindOf("Slash") then
                local nxt,prev = player:getNextAlive(),player:getNextAlive(room:getAlivePlayers():length()-1)
                local msg = sgs.LogMessage()
				msg.type = "#ngongjiadd"
				msg.from = player
				if not use.to:contains(nxt) and use.from:canSlash(nxt,use.card,false) then
					use.to:append(nxt)
				end
                if not use.to:contains(prev) and use.from:canSlash(prev,use.card,false) then
					use.to:append(prev)
				end
                room:sortByActionOrder(use.to)
				msg.to = use.to
				msg.arg = self:objectName()
				room:broadcastSkillInvoke(self:objectName())
				room:notifySkillInvoked(player,self:objectName())
                room:sendLog(msg)
                data:setValue(use)
				local new = sgs.QVariant()
				new:setValue(player)
				use.from:setTag("n_gongji",new)
				room:setCardFlag(use.card,"n_gongji")
			end
        end
       
        if event == sgs.Damaged then
            local damage = data:toDamage()
            if damage.card and damage.card:isKindOf("Slash") and damage.card:hasFlag("n_gongji") then
			   --player:speak("doidoidoid")
               room:setCardFlag(damage.card,"-n_gongji")
            end
        end
        
        if event == sgs.CardFinished then
            local use = data:toCardUse()
            if not use.card:isKindOf("Slash") then return end
			local p = use.from:getTag("n_gongji"):toPlayer()
			if not p or p:isDead() then return false end
			use.from:removeTag("n_gongji")
			if not use.card:hasFlag("n_gongji") then return false end
            local nxt,prev = p:getNextAlive(),p:getNextAlive(room:getAlivePlayers():length()-1)
            n_CompulsorySkill(room,p,self:objectName())
            p:drawCards(3)
			local sp = sgs.SPlayerList()
			sp:append(prev)
			sp:append(nxt)
			room:sortByActionOrder(sp)
			for _, d in sgs.qlist(sp) do
				if not p:isNude() then
				    n_askForGiveCardTo(p,d,self:objectName(),".|.|.|.!","#ShenshouGive:"..d:getGeneralName(),true)
				end
			end
		end
    end,
    can_trigger = function(self,target)
        return target
    end,
    priority = 3,
}
n_siguningshang:addSkill(n_gongji)
n_menghun = sgs.CreateTriggerSkill{
    name = "n_menghun" ,
    frequency = sgs.Skill_Compulsory,
    events = {sgs.TargetConfirmed, sgs.Damage,sgs.CardEffected} ,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if event == sgs.TargetConfirmed then
            local use = data:toCardUse()
            if (use.to:length() <= 1) or (not use.to:contains(player)) or (not player:hasSkill(self:objectName())) then
                return false
            end
            use.to:removeOne(player)
			use.to:append(player)
            room:broadcastSkillInvoke(self:objectName())
			room:notifySkillInvoked(player,self:objectName())
			local msg = sgs.LogMessage()
			msg.type = "#nmenghunchange"
			msg.from = player
			msg.to = use.to
			msg.arg = self:objectName()
			room:sendLog(msg)
            data:setValue(use)
            player:setTag("n_menghuning", sgs.QVariant(use.card:toString()))
        end
        if event == sgs.Damage then
            local damage = data:toDamage()
            if damage.card == nil then return end
            local str = damage.card:toString()
            for _,p in sgs.qlist(room:getAlivePlayers()) do
                if p:getTag("n_menghuning"):toString() == str then
                    p:setTag("n_menghuning", sgs.QVariant(""))
                end
            end
        end
        if event == sgs.CardEffected then
            if (not player:isAlive()) or (not player:hasSkill(self:objectName())) then return false end
            local effect = data:toCardEffect()
            if player:getTag("n_menghuning") == nil or (player:getTag("n_menghuning"):toString() ~= effect.card:toString()) then return false end
            player:setTag("n_menghuning", sgs.QVariant(""))
			room:broadcastSkillInvoke(self:objectName())
			room:notifySkillInvoked(player,self:objectName())
			local msg = sgs.LogMessage()
			msg.type = "#SkillNullify"
			msg.from = player
			msg.arg = self:objectName()
			msg.arg2 = effect.card:objectName()
			room:sendLog(msg)
            player:drawCards(1)
            return true
        end
        return false
    end,
	priority = 1,
    can_trigger = function(self,target)
        return target
    end,
}
n_siguningshang:addSkill(n_menghun)
sgs.LoadTranslationTable{
    ["n_siguningshang"] = "思故凝殇",
	["designer:n_siguningshang"] = "思故凝殇",
	["cv:n_siguningshang"] = "思故凝殇",
	["illustrator:n_siguningshang"] = "网络",
	["~n_siguningshang"] = "情，终究敌不过利.....",
    ["&n_siguningshang"] = "思故",
    ["#n_siguningshang"] = "sp郭嘉",
    ["n_gongji"] = "共济",
	["#ngongjiadd"] = "%from 的“%arg”被触发，【杀】的目标变成了 %to",
    [":n_gongji"] = "锁定技。你成为杀的目标时，你的上下家成为额外目标，"..
    "该杀结算后，若该杀未造成伤害，则你摸3张牌并交给上下家各一张牌。",
    ["$n_gongji1"] = "一起死，或者，一起活。",
	["$n_gongji2"] = "我的命，在你手上。",
	["n_menghun"] = "萌混",
    [":n_menghun"] = "锁定技。一张牌指定你为目标时，若该牌有多个目标，"..
    "则你最后进行结算，然后当你结算时，若该牌此前没有造成过伤害，则你摸一张牌且此牌对你失效。",
	["$n_menghun1"] = "你抓不住我。",
	["$n_menghun2"] = "当做，没看到我行不行。",
	["#nmenghunchange"] = "%from 的“%arg”被触发，本次结算顺序变成了 %to",
}

n_haoxuesheng = sgs.General(extension3,"n_haoxuesheng","n_pigeon",3,false)
n_jiejian = sgs.CreateTriggerSkill{
	name = "n_jiejian",
	events = {sgs.EventPhaseStart,sgs.EventPhaseEnd},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_Play then return end
			local all = room:getOtherPlayers(player)
			local validtargets = sgs.SPlayerList()
			for _,p in sgs.qlist(all) do
				local cards = p:getCards("hej")
				if cards:length() >= 2 then
					validtargets:append(p)
				end
			end

			if validtargets:length() > 0 then
				local to = room:askForPlayerChosen(player,validtargets,"n_jiejian","jiejian_invoke",true,true)
				if to ~= nil then
					if to:isNude() then return true end
					room:broadcastSkillInvoke(self:objectName())
					room:setPlayerFlag(to, "xuanhuo_InTempMoving")
					local first_id = room:askForCardChosen(player, to, "hej", self:objectName())
					local original_place = room:getCardPlace(first_id)
					local dummy = sgs.DummyCard()
					dummy:addSubcard(first_id)
					to:addToPile("#xuanhuo", dummy, false)
					if not to:isNude() then
						local second_id = room:askForCardChosen(player, to, "hej", self:objectName())
						dummy:addSubcard(second_id)
					end
					room:moveCardTo(sgs.Sanguosha:getCard(first_id), to, original_place, false)
					room:setPlayerFlag(to, "-xuanhuo_InTempMoving")
					room:moveCardTo(dummy, player, sgs.Player_PlaceHand, false)
					
					room:setPlayerMark(to,"n_jiejianto",1)
				end
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() ~= sgs.Player_Play then return end
			local all = room:getOtherPlayers(player)
			for _,p in sgs.qlist(all) do
				if player:isNude() then break end
				if p:getMark("n_jiejianto") > 0 then
					local card = room:askForExchange(player,self:objectName(),2,2,true,"#n_jiejianreturn:"..p:objectName(),false)
					room:obtainCard(p,card,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE,p:objectName(), player:objectName(), self:objectName(), ""),false)
					room:setPlayerMark(p,"n_jiejianto",0)
				end
			end
		end
	end
}
n_haoxuesheng:addSkill(n_jiejian)
n_qiuxuecard = sgs.CreateSkillCard{
	name = "n_qiuxuecard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets < 2 and not to_select:isKongcheng()
	end ,
	feasible = function(self, targets)
		return #targets == 2
	end ,
	on_use = function(self, room,source,targets)
		local from,to = targets[1],targets[2]
		local choice = room:askForChoice(source, "n_qiuxue", "black+red")
		local log = sgs.LogMessage()
		log.type = "#doChoice"
		log.from = source
		log.arg = choice
		room:sendLog(log)
		
		local tbl = {
			["black"] = true,
			["red"] = false
		}
		local list = from:handCards()
		local _list = to:handCards()
		local cards = sgs.IntList()
		for _,id in sgs.qlist(list) do cards:append(id)	end
		for _,id in sgs.qlist(_list) do cards:append(id)	end
		room:fillAG(cards)
		for _,id in sgs.qlist(cards) do
			local take = false
			if sgs.Sanguosha:getCard(id):isBlack() == tbl[choice] then take = true end
			if take then room:takeAG(room:getCardOwner(id),id,false) end
		end
		room:getThread():delay(3000)
		local f = 0
		local t = 0
		for _,id in sgs.qlist(list) do
			if sgs.Sanguosha:getCard(id):isBlack() == tbl[choice] then f = f + 1 end
		end
		for _,id in sgs.qlist(_list) do
			if sgs.Sanguosha:getCard(id):isBlack() == tbl[choice] then t = t + 1 end
		end
		room:clearAG()
		if f == t then
			source:drawCards(1);from:drawCards(1);to:drawCards(1)
		else
			local damager,obtainer = nil,nil
			if f > t then damager = from;obtainer = to else damager = to;obtainer = from end
			room:damage(sgs.DamageStruct("n_qiuxue",damager,obtainer))
			if damager:isAllNude() or obtainer:isDead() then return end
			room:obtainCard(obtainer,room:askForCardChosen(obtainer, damager, "hej", "n_qiuxue", false, sgs.Card_MethodNone),false)
		end
	end
}
n_qiuxuevs = sgs.CreateViewAsSkill{
	name = "n_qiuxue",
	n = 0,
	view_as = function(self,cards)
		return n_qiuxuecard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self,player,pattern)
	    return pattern == "@@n_qiuxue"
	end,
}
n_qiuxue = sgs.CreateTriggerSkill{
	name = "n_qiuxue",
	events = {sgs.EventPhaseStart},
	view_as_skill = n_qiuxuevs,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Finish then
			room:askForUseCard(player, "@@n_qiuxue", "@n_qiuxue", -1,sgs.Card_MethodUse)
		end
	end
}
n_haoxuesheng:addSkill(n_qiuxue)
sgs.LoadTranslationTable{
	["n_haoxuesheng"] = "好学生",
	["~n_haoxuesheng"] = "分考的还没有自己学号多学个屁啊？！",
	["#n_haoxuesheng"] = "窝瓜",
	["designer:n_haoxuesheng"] = "far side",
	["illustrator:n_haoxuesheng"] = "来自网络",
	["n_jiejian"] = "借鉴",
	["jiejian_invoke"] = "你可以对一名其他角色发动“借鉴”",
	["#n_jiejianreturn"] = "借鉴：请还给 %src 2张牌",
	["$n_jiejian1"] = "我也要做好学生。",
	["$n_jiejian2"] = "这道题我不会做，教我怎么做可以吗。",
	[":n_jiejian"] = "出牌阶段开始时，你可以获得一名角色区域内的两张牌，若如此做，出牌阶段结束时你还给其两张牌。",
	["n_qiuxue"] = "求学",
	["~n_qiuxue"] = "选择两名角色->点确定",
	["@n_qiuxue"] = "你可以发动“求学”",
	["$n_qiuxue1"] = "沉迷在学习才能使我快乐~~~~",
	["$n_qiuxue2"] = "平常老师讲课的时候呢，一般呢会抓住老师讲课中的重点。",
	[":n_qiuxue"] = "回合结束阶段，你可以声明一种颜色，然后展示两名角色全部手牌，颜色多的对颜色少的玩家造成一点伤害，颜色少的玩家获得颜色多的玩家区域内的一张牌，若两名角色颜色数量相同，你可以与他们各摸一张牌。",
}

n_eshen = sgs.General(extension3,"n_eshen","n_pigeon",3)
n_zhuiwencard = sgs.CreateSkillCard{
	name = "n_zhuiwencard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return to_select:objectName() ~= sgs.Self:objectName()
	end ,
	feasible = function(self, targets)
		return #targets == 1
	end ,
	on_use = function(self, room,player,targets)
		local target = targets[1]
		local typeChoice = room:askForChoice(player,"n_zhuiwen","basic+trick+equip")
		local responseChoice = ""
		if player:isKongcheng() or target:isKongcheng() then
			responseChoice = "n_zwtk"
		else
			responseChoice = room:askForChoice(target,"n_zhuiwent","n_zwtk+n_zwpd")
		end
		if responseChoice == "n_zwtk" then
			local pile = room:getDrawPile()
			for _,id in sgs.qlist(pile) do
				if sgs.Sanguosha:getCard(id):getType() == typeChoice then room:obtainCard(player,id);break end
			end
		else
			local success = target:pindian(player,"n_zhuiwen")
			local klr,vtm
			if success then klr = target;vtm = player else klr = player;vtm = target end
			room:damage(sgs.DamageStruct("n_zhuiwen",klr,vtm))
			klr:drawCards(1)
		end
	end
}
n_zhuiwen = sgs.CreateViewAsSkill{
	name = "n_zhuiwen",
	n = 0,
	view_as = function(self,cards)
		return n_zhuiwencard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_zhuiwencard")
	end,
}
n_eshen:addSkill(n_zhuiwen)
n_sizui = sgs.CreateTriggerSkill{
	name = "n_sizui",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		n_CompulsorySkill(room,player,self:objectName())
		room:drawCards(player, 2)
		if not player:isNude() then
			local card_id = room:askForExchange(player, self:objectName(), 1,1, true, "#n_sizuipush"):getSubcards():first()
			player:addToPile("n_crime", card_id)
		end
	end
}
n_eshen:addSkill(n_sizui)
n_xiaoshicard = sgs.CreateSkillCard{
	name = "n_xiaoshicard",
    will_throw = false,
    handling_method = sgs.Card_MethodNone,
	filter = function(self,targets,to_select)
		targets = table2PlayerList(targets)
		if (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE) then
			local card
			if (self:getUserString() ~= "") then
				card = sgs.Sanguosha:cloneCard(self:getUserString():split("+")[1])
			end
			return card and card:targetFilter(targets, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, targets)
		elseif (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE) then
			return false
		end
	
		local _card = sgs.Self:getTag("n_xiaoshi"):toCard()
		if (_card == nil) then
			return false
		end
	
		local card = sgs.Sanguosha:cloneCard(_card)
		card:setCanRecast(false)
		card:deleteLater()
		return card and card:targetFilter(targets, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, targets)
	end,
	target_fixed = function(self)
		if (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE) then
			local card
			if (self:getUserString() ~= "") then
				card = sgs.Sanguosha:cloneCard(self:getUserString():split("+")[1])
			end
			return card and card:targetFixed()
		elseif (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE) then
			return false
		end
	
		local _card = sgs.Self:getTag("n_xiaoshi"):toCard()
		if (_card == nil) then
			return false
		end
	
		local card = sgs.Sanguosha:cloneCard(_card)
		card:setCanRecast(false)
		card:deleteLater()
		return card and card:targetFixed()
	end,
	feasible = function(self,targets)
		targets = table2PlayerList(targets)
		if (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE) then
			local card
			if (self:getUserString() ~= "") then
				card = sgs.Sanguosha:cloneCard(self:getUserString():split("+")[1])
			end
			return card and card:targetsFeasible(targets, sgs.Self)
		elseif (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE) then
			return false
		end
	
		local _card = sgs.Self:getTag("n_xiaoshi"):toCard()
		if (_card == nil) then
			return false
		end
	
		local card = sgs.Sanguosha:cloneCard(_card)
		card:setCanRecast(false)
		card:deleteLater()
		return card and card:targetsFeasible(targets, sgs.Self)
	end,	
	on_validate = function(self,card_use)
		local eshen = card_use.from
		local room = eshen:getRoom()
	
		local to_guhuo = self:getUserString()
		if (self:getUserString() == "slash" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE) then
			local guhuo_list = {"slash","normal_slash","thunder_slash","fire_slash"}
			to_guhuo = room:askForChoice(eshen, "guhuo_saveself", table.concat(guhuo_list,"+"))
			eshen:setTag("GuhuoSlash",sgs.QVariant(to_guhuo))
		end
		room:broadcastSkillInvoke("n_xiaoshi")
	
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		local user_str = ""
		if (to_guhuo == "slash") then
			if (card:isKindOf("Slash")) then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		elseif (to_guhuo == "normal_slash") then
			user_str = "slash"
		else
			user_str = to_guhuo
		end
		
		local use_card = sgs.Sanguosha:cloneCard(user_str, card:getSuit(), card:getNumber())
		use_card:setSkillName("n_xiaoshi")
		use_card:addSubcards(self:getSubcards())
		use_card:deleteLater()
	
		return use_card
		
	end,
	on_validate_in_response = function(self,eshen)
		local room = eshen:getRoom()
		room:broadcastSkillInvoke("n_xiaoshi")
	
		local to_guhuo = ""
		if (self:getUserString() == "peach+analeptic") then
			local guhuo_list = {"peach","analeptic"}
			to_guhuo = room:askForChoice(eshen, "guhuo_saveself", table.concat(guhuo_list,"+"))
			--eshen:setTag("GuhuoSaveSelf",sgs.QVariant(to_guhuo))
		elseif (self:getUserString() == "slash") then
			local guhuo_list = {"slash","normal_slash","thunder_slash","fire_slash"}
			to_guhuo = room:askForChoice(eshen, "guhuo_saveself", table.concat(guhuo_list,"+"))
			--eshen:setTag("GuhuoSlash",sgs.QVariant(to_guhuo))
		else
			to_guhuo = self:getUserString()
		end
	
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		local user_str = ""
		if (to_guhuo == "slash") then
			if (card:isKindOf("Slash")) then
				user_str = card:objectName()
			else
				user_str = "slash"
			end
		elseif (to_guhuo == "normal_slash") then
			user_str = "slash"
		else
			user_str = to_guhuo
		end
		
		local use_card = sgs.Sanguosha:cloneCard(user_str, card:getSuit(), card:getNumber())
		use_card:setSkillName("n_xiaoshi")
		use_card:addSubcards(self:getSubcards())
		use_card:deleteLater()
	
		return use_card
	end,

}
n_xiaoshi = sgs.CreateViewAsSkill{
	name = "n_xiaoshi",
	n = 2,
	expand_pile = "n_crime",
	enabled_at_response = function(self, player, pattern)
		local current = false
		local players = player:getSiblings()
		players:append(player)
		for _, p in sgs.qlist(players) do
			if p:isAlive() and p:getPhase() ~= sgs.Player_NotActive then
				current = true
				break
			end
		end
		if not current then return false end
		
		if player:getPile("n_crime"):length()<2 or string.sub(pattern, 1, 1) == "." or string.sub(pattern, 1, 1) == "@" then
			return false
		end
		if pattern == "peach" and player:hasFlag("Global_PreventPeach") then return false end
		return true
	end,
	enabled_at_nullification = function(self, player)
		local current = player:getRoom():getCurrent()
		if not current or current:isDead() or current:getPhase() == sgs.Player_NotActive then return false end
		return player:getPile("n_crime"):length()>=2
	end,
	enabled_at_play = function(self, player)
		local current = false
		local players = player:getAliveSiblings()
		players:append(player)
		for _, p in sgs.qlist(players) do
			if p:getPhase() ~= sgs.Player_NotActive then
				current = true
				break
			end
		end
		if not current then return false end
		return player:getPile("n_crime"):length()>=2
	end,
	view_filter = function(self, selected, to_select)
		return sgs.Sanguosha:matchExpPattern(".|.|.|n_crime",sgs.Self,to_select)
	end,
	view_as = function(self,cards)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			if #cards < 2 then return nil end
			local card = n_xiaoshicard:clone()
			card:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			for _,cd in ipairs(cards) do
				card:addSubcard(cd)
			end
			return card
		end

		local c = sgs.Self:getTag("n_xiaoshi"):toCard()
        if c and #cards==2 then
            local card = n_xiaoshicard:clone()
            card:setUserString(c:objectName())
			for _,cd in ipairs(cards) do
				card:addSubcard(cd)
			end
			return card
        else
			return nil
		end
	end
}
n_xiaoshi:setGuhuoDialog("lr")
n_eshen:addSkill(n_xiaoshi)
sgs.LoadTranslationTable{
	["n_eshen"] = "鄂神",
	["#n_eshen"] = "天语倦人",
	["designer:n_eshen"] = "鄂木斯克特派员",
	["cv:n_eshen"] = "鄂木斯克特派员",
	["illustrator:n_eshen"] = "南极",
	["~n_eshen"] = "终是，引祸上身了么？咳，咳，咳。。。",
	["n_zhuiwen"] = "追问",
	["n_zhuiwent"] = "追问",
	[":n_zhuiwen"] = "阶段技。你可声明一种牌并令一名其他角色选择：1，令你从牌堆中获得一张该类型的牌；2，与你进行拼点，赢的角色摸一张牌对输的角色造成一点伤害",
	["$n_zhuiwen1"] = "我想问一下你这件事。",
	["$n_zhuiwen2"] = "能不能快一点啊？",
	["n_sizui"] = "思罪",
	[":n_sizui"] = "锁定技。你受到伤害后，摸两张牌并将一张牌置于你的武将牌上，称为“罪”；只要你有“罪”，其他角色与你的距离+1",
	["$n_sizui1"] = "你为何如此对我？",
	["$n_sizui2"] = "我到底做了什么？",
	["n_xiaoshi"] = "消释",
	[":n_xiaoshi"] = "你可以将两张“罪”当作任意一张基本牌或非延时锦囊牌使用。",
	["$n_xiaoshi1"] = "时日已长，释怀也罢。",
	["$n_xiaoshi2"] = "那些事，忘了他罢。",
	["n_crime"] = "罪",
	["#n_sizuipush"] = "思罪：将一张牌置入“罪”中",
	["n_zwtk"] = "令对方获得一张该类型的牌",
	["n_zwpd"] = "和对方拼点",
}

n_nuoduozhanshi = sgs.General(extension3,"n_nuoduozhanshi","n_pigeon") 
n_beishui = sgs.CreateTriggerSkill{	
	name = "n_beishui",
	events = {sgs.DamageCaused},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local source = damage.from
		if room:askForSkillInvoke(player,"n_beishui",data) then
			room:broadcastSkillInvoke("n_beishui")
			local judge = sgs.JudgeStruct()
			judge.pattern = ".|red"
			judge.good = true
			judge.reason = self:objectName()
			judge.who = source
			room:judge(judge)
			if judge:isGood() then
				room:drawCards(source,damage.damage)
			else
				damage.damage = damage.damage*2
				data:setValue(damage)
				local msg = sgs.LogMessage()
				msg.type = "#bsdamage"	
				msg.arg = damage.damage/2
				msg.arg2 = damage.damage
				--msg.from = "n_beishui"
				room:sendLog(msg)
			end
		end
	end,
}
n_nuoduozhanshi:addSkill(n_beishui)
sgs.LoadTranslationTable{
	["n_nuoduozhanshi"] = "诺多战士",
	["#n_nuoduozhanshi"] = "西楚霸王",
	["designer:n_nuoduozhanshi"] = "Notify",
	["illustrator:n_nuoduozhanshi"] = "网络",
	["n_beishui"] = "背水",
	[":n_beishui"] = "你造成伤害时可进行判定。若结果为<font color=\"red\"><b>红色</b></font>，你摸X张牌，否则X翻倍。（X为伤害值）",
	["$n_beishui"] = "冲啊！！",
	["#bsdamage"] = "由于技能“背水”的影响，伤害从 %arg 点升至 %arg2 点！",
	["~n_nuoduozhanshi"] = "不可能...",
}

n_fayantansuan = sgs.General(extension3,"n_fayantansuan","n_pigeon",3) 
n_shiya = sgs.CreateTriggerSkill{
	name = "n_shiya",
	events = {sgs.DamageCaused,sgs.DamageInflicted},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.from and damage.from:getHp() > damage.to:getHp() then
			room:notifySkillInvoked(player,self:objectName())
			room:broadcastSkillInvoke(self:objectName(),event==sgs.DamageCaused and 1 or 2)
			room:sendCompulsoryTriggerLog(player,self:objectName())
			damage.damage = damage.damage + 1
			data:setValue(damage)
		end
	end,
}
n_fayantansuan:addSkill(n_shiya)
n_baipiao = sgs.CreateTriggerSkill{
	name = "n_baipiao",
	events = {sgs.EventPhaseStart},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start then
			n_CompulsorySkill(room,player,self:objectName())
			local allplayers = room:getAlivePlayers() 
			local allnames = sgs.Sanguosha:getLimitedGeneralNames()
			table.remove(allnames,table.indexOf(allnames,"n_fayantansuan"))

            math.randomseed(tostring(os.time()):reverse():sub(1, 7))
			local targets = {}
			for i=1, 3 do
				local count = #allnames
				local index = math.random(1, count)  
				local selected = allnames[index] 
				table.insert(targets, selected) 
				allnames[selected] = nil 
			end
			local generals = table.concat(targets, "+")
			local general = sgs.Sanguosha:getGeneral(room:askForGeneral(player, generals))
			local skill_names = {}
			for _,skill in sgs.qlist(general:getVisibleSkillList())do
                if skill:isLordSkill() or skill:getFrequency() == sgs.Skill_Limited or skill:getFrequency() == sgs.Skill_Wake then
                    continue
				end
                if not table.contains(skill_names,skill:objectName()) then
                    table.insert(skill_names,skill:objectName())
                end
            end
            if #skill_names > 0 then
                local skill_name = room:askForChoice(player, "n_baipiao", table.concat(skill_names,"+"))
				local oskill = player:property("n_baipiaoskill"):toString()
				room:detachSkillFromPlayer(player,oskill)
				room:setPlayerProperty(player,"n_baipiaoskill",sgs.QVariant(skill_name))
				room:acquireSkill(player,skill_name)
				local jsonValue = {
					10,		--S_GAME_EVENT_HUASHEN,
					player:objectName(),
					player:getGeneralName(),
					--general:objectName(),	--变脸的武将名字
					skill_name,
				}
				room:doBroadcastNotify(sgs.CommandType.S_COMMAND_LOG_EVENT, json.encode(jsonValue))
				
			end
		end
	end,
}
n_fayantansuan:addSkill(n_baipiao)
sgs.LoadTranslationTable{
	["n_fayantansuan"] = "发烟碳酸",
	["&n_fayantansuan"] = "发烟神",
	["#n_fayantansuan"] = "资深玩家",
	["designer:n_fayantansuan"] = "Notify",
	["illustrator:n_fayantansuan"] = "网络",
	["n_shiya"] = "施压",
	["$n_shiya1"] = "别怕，我会对你很好的。",
	["$n_shiya2"] = "有操作的。",
	[":n_shiya"] = "锁定技。你造成或受到伤害时，若伤害来源体力值较多，此伤害+1。",
	["n_baipiao"] = "白嫖",
	["$n_baipiao1"] = "下次一定.jpg",
	["$n_baipiao2"] = "下次也不一定。",
	[":n_baipiao"] = "锁定技。准备阶段，你抽取三张已开通武将并获得其中一个技能然后失去之前以此法得到的技能。",
	["~n_fayantansuan"] = "我到底做错了什么？",
}

n_shenqiangshou = sgs.General(extension3,"n_shenqiangshou","n_pigeon",3,false)
n_chigua = sgs.CreateTriggerSkill{
	name = "n_chigua",
	events = {sgs.Damaged},
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local from,to = damage.from,damage.to
		for _,cg in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if from:objectName() ~= cg:objectName() and to:objectName() ~= cg:objectName() then
				local card = room:askForCard(cg,".|heart|.|.","#n_chigua" ,sgs.QVariant(), sgs.Card_MethodNone)
				if card then
					local choice = ""
					if cg:isWounded() then 
						choice = room:askForChoice(cg,self:objectName(),"peach+ex_nihilo")
					else
						choice = "ex_nihilo"
					end
					local _card = sgs.Sanguosha:cloneCard(choice)
					_card:addSubcard(card)
					_card:setSkillName(self:objectName())
					local use = sgs.CardUseStruct()
					use.from = cg
					use.card = _card
					room:useCard(use)
				end
			end
		end
	end
}
n_shenqiangshou:addSkill(n_chigua)
n_huashui = sgs.CreateTriggerSkill{
	name = "n_huashui",
	events = {sgs.DamageInflicted},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.from and damage.card and damage.card:isKindOf("TrickCard") then
			local card = room:askForCard(player,".|diamond|.|.","#n_huashui:"..damage.from:getGeneralName() ,sgs.QVariant(), sgs.Card_MethodNone,damage.from,false,self:objectName())
			if card then
				room:broadcastSkillInvoke(self:objectName())
				room:obtainCard(damage.from,card,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE,damage.from:objectName(), player:objectName(), self:objectName(), ""))
				damage.to = damage.from
				damage.transfer = true
				room:damage(damage)
				return true
			end
		end
	end
}
n_shenqiangshou:addSkill(n_huashui)
sgs.LoadTranslationTable{
	["n_shenqiangshou"] = "神枪手",
	["designer:n_shenqiangshou"] = "Notify",
	["illustrator:n_shenqiangshou"] = "网络",
	["~n_shenqiangshou"] = "太过分了自己说的话。",
	["#n_shenqiangshou"] = "吃瓜划水",
	["n_chigua"] = "吃瓜",
	["$n_chigua2"] = "不错不错！",
	["$n_chigua1"] = "继续继续！",
	[":n_chigua"] = "其他角色受到伤害来源不为你的伤害后，你可以将红桃牌当桃或无中生有使用",
	["n_huashui"] = "划水",
	["$n_huashui"] = "啊！我不背这个锅！",
	[":n_huashui"] = "你受到来自锦囊的伤害时，可交给伤害来源一张方块牌，然后将此伤害转移给其。",
	["#n_chigua"] = "吃瓜：你可以选择一张红桃牌发动“吃瓜”",
	["#n_huashui"] = "划水：你可以交给 %src 一张方片牌对其发动“划水”",
}

n_yupuyujin = sgs.General(extension3,"n_yupuyujin","n_pigeon",3,false,true)
n_jianshucard = sgs.CreateSkillCard{
	name = "n_jianshucard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		room:doSuperLightbox("n_yupuyujin", "n_jianshu")
		room:obtainCard(targets[1], sgs.Sanguosha:getCard(self:getSubcards():first()), sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(), targets[1]:objectName(), self:objectName(), ""))
		local players = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getOtherPlayers(targets[1])) do
			if p:inMyAttackRange(targets[1]) and p:objectName() ~= source:objectName() then
				players:append(p)
			end
		end
		if not players:isEmpty() then
			local player = room:askForPlayerChosen(source, players, self:objectName(), "@n_jianshu")
			targets[1]:pindian(player, "n_jianshu")
		end
	end
}
n_huoxincard = sgs.CreateSkillCard{
	name = "n_huoxincard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("n_huoxin",1)
		local suit = room:askForSuit(targets[1],"")
		local log = sgs.LogMessage()
		log.type = "#ChooseSuit"
		log.from = source
		log.arg = sgs.Card_Suit2String(suit)
		room:sendLog(log)
		room:obtainCard(targets[1], sgs.Sanguosha:getCard(self:getSubcards():first()), sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(), targets[1]:objectName(), self:objectName(), ""))
		room:showCard(targets[1], self:getEffectiveId())
		if self:getSuit() ~= suit then
			local choices = {"n_hxdm"}
			local players = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getOtherPlayers(targets[1])) do
				if p:inMyAttackRange(targets[1]) and p:objectName() ~= source:objectName() then
					players:append(p)
				end
			end
			if not players:isEmpty() then
				for _,cd in sgs.qlist(source:getCards("h")) do
					if cd:isBlack() then table.insert(choices,"n_hxjs");break; end
				end
			end
			local choice = room:askForChoice(source,"n_huoxin",table.concat(choices,"+"))
			room:broadcastSkillInvoke("n_huoxin",math.random(2,3))
			if choice == "n_hxdm" then
				room:damage(sgs.DamageStruct("n_huoxin",source,targets[1]))
			elseif choice == "n_hxjs" then
				local card = room:askForCard(source,".|black|.|hand","#n_jianshu:"..targets[1]:getGeneralName() ,sgs.QVariant(), sgs.Card_MethodNone)
				if card then
					local jscard = n_jianshucard:clone()
					jscard:addSubcard(card)
					local _use = sgs.CardUseStruct()
					_use.from = source
					_use.to:append(targets[1])
					_use.card = jscard
					room:useCard(_use)
				else	
					room:damage(sgs.DamageStruct("n_huoxin",source,targets[1]))
				end
			end
		end
	end
}
n_huoxinvs = sgs.CreateOneCardViewAsSkill{
	name = "n_huoxin",
	--response_or_use = true,
	view_filter = function(self, card)
		return not card:isEquipped()
	end,
	view_as = function(self, card)
		local cards = n_huoxincard:clone()
		cards:addSubcard(card)
		return cards
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_huoxincard")
	end,
}
n_huoxin = sgs.CreateTriggerSkill{
	name = "n_huoxin",
	view_as_skill = n_huoxinvs,
	events = {sgs.Pindian},
	on_trigger = function(self, event, player, data, room)
		local pindian = data:toPindian()
		if pindian.reason == "n_jianshu" then
			local winner = pindian.from
			local loser = pindian.to
			local players = sgs.SPlayerList()
			if pindian.from_card:getNumber() < pindian.to_card:getNumber() then
				winner = pindian.to
				loser = pindian.from
			elseif pindian.from_card:getNumber() == pindian.to_card:getNumber() then
				players:append(winner)
				winner = nil
			end
			players:append(loser)
			if winner then
				room:askForDiscard(winner, self:objectName(), 2, 2, false, true)
			end
			room:sortByActionOrder(players)
			for _, p in sgs.qlist(players) do
				if p:isAlive() then
					room:loseHp(p)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
n_yupuyujin:addSkill(n_huoxin)
n_yongmucard = sgs.CreateSkillCard{
	name = "n_yongmucard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@n_ypyj")
		room:doSuperLightbox("n_yupuyujin", "n_yongmu")
		local all = room:getOtherPlayers(source)
		for _,p in sgs.qlist(all) do
			local card = room:askForExchange(p, "n_yongmu", 999, 1, false, "#n_yongmu:"..source:getGeneralName(),false)
			local _data = sgs.QVariant()
			_data:setValue(card:getSubcards())
			room:setPlayerProperty(p,"n_yongmuids",_data)
		end
		local n = 0 
		for _,p in sgs.qlist(all) do
			local card = sgs.DummyCard(p:property("n_yongmuids"):toIntList())
			room:showCard(p,card:getEffectiveId())
		end
		for _,p in sgs.qlist(all) do
			local cards = p:property("n_yongmuids"):toIntList()
			if cards:length() > n then
				n = cards:length()
				room:setPlayerProperty(source,"n_yongmutarget",sgs.QVariant(p:objectName()))
			elseif cards:length() == n then
				local pstr = source:property("n_yongmutarget"):toString()
				if pstr == "" then pstr = p:objectName()
				else pstr = pstr.."+"..p:objectName() end
				room:setPlayerProperty(source,"n_yongmutarget",sgs.QVariant(pstr))
			end
		end
		local players = sgs.SPlayerList()
		local pstrs = source:property("n_yongmutarget"):toString()
		local ptable = pstrs:split("+")
		for _,str in ipairs(ptable) do
			players:append(findPlayerByObjectName(room,str))
		end
		if not players:isEmpty() then
			if not players:first():property("n_yongmuids"):toIntList():isEmpty() then
				local player
				if players:length() == 1 then player = players:first()
				else player = room:askForPlayerChosen(source,players,"n_yongmu","#n_yongmuobtain") end
				local card = sgs.DummyCard(player:property("n_yongmuids"):toIntList())
				source:obtainCard(card)
				n_gainMhp(player,card:getSubcards():length())
			end
		end
		
		for _,p in sgs.qlist(all) do
			local _data = sgs.QVariant()
			_data:setValue(sgs.IntList())
			room:setPlayerProperty(p,"n_yongmuids",_data)
		end
	end
}
n_yongmuvs = sgs.CreateViewAsSkill{
	name = "n_yongmu",
	n = 0,
	view_as = function(self, cards)
		return n_yongmucard:clone()
	end,
	enabled_at_play=function(self, player)
		return player:getMark("@n_ypyj") >= 1
	end
}
n_yongmu = sgs.CreateTriggerSkill{
	name = "n_yongmu",
	frequency = sgs.Skill_Limited,
	limit_mark = "@n_ypyj",
	events = {sgs.NonTrigger},
	view_as_skill = n_yongmuvs,
	on_trigger = function()	end
}
n_yupuyujin:addSkill(n_yongmu)
sgs.LoadTranslationTable{
	["n_yupuyujin"] = "玉璞瑜瑾",
	["designer:n_yupuyujin"] = "玊璞瑜瑾",
	["cv:n_yupuyujin"] = "西西里Evanism",
	["illustrator:n_yupuyujin"] = "网络",
	["~n_yupuyujin"] = "意料之外的事...发生了...",
	["#n_yupuyujin"] = "九叩问罪",
	["n_huoxin"] = "惑心",
	["$n_huoxin1"] = "好好想明白，这是你人生中最后一次选择。",
	["$n_huoxin2"] = "拿走我的东西，总得付出点代价吧。",
	["$n_huoxin3"] = "这一切，都是你咎由自取。",
	[":n_huoxin"] = "阶段技。你可以先选择一张手牌再令一名其他角色选择一种花色，然后该角色获得这张手牌并展示之，若此牌的花色与其所选的花色不同，则你可以选择：1.交给其一张黑色手牌，发动“间书”；2.对其造成一点伤害。",
	["n_jianshu"] = "间书",
	["@n_jianshu"] = "你已经发动了“间书”，请选择一名角色作为拼点的目标",
	["#n_jianshu"] = "你选择发动“间书”，请交给 %src 一张黑色手牌（点取消则对其造成伤害）",
	["n_hxjs"] = "交给其一张黑色手牌，发动“间书”",
	["n_hxdm"] = "对其造成一点伤害",
	["n_yongmu"] = "拥牧",
	["$n_yongmu"] = "生命无价，但确实可以标价。",
	[":n_yongmu"] = "限定技。出牌阶段，你可以令所有其他角色同时选择是否展示任意数量的牌，你获得以此法展示牌最多的角色的展示牌，然后其增加等量的体力上限。",
	["#n_yongmu"] = "拥牧：你可以选择是否展示任意数量的牌，若你是以此法展示牌最多的角色，则 %src 获得这些展示牌，你增加等量的体力上限。",
	["#n_yongmuobtain"] = "拥牧：请选择一名角色获得其展示的牌",
}

n_lianbangyi = sgs.General(extension3,"n_lianbangyi","n_pigeon",3,false)
n_tuishoucard = sgs.CreateSkillCard{
	name = "n_tuishoucard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local drawpile = room:getDrawPile()
		local diss = room:getDiscardPile()
		local jink
		for _,id in sgs.qlist(drawpile) do
			if sgs.Sanguosha:getCard(id):isKindOf("Jink") then
				jink = id;break
			end
		end
		if not jink then
			for _,id in sgs.qlist(diss) do
				if sgs.Sanguosha:getCard(id):isKindOf("Jink") then
					jink = id;break
				end
			end
		end
		if jink then source:obtainCard(sgs.Sanguosha:getCard(jink)) end
	end,
}
n_tuishou = sgs.CreateOneCardViewAsSkill{
	name = "n_tuishou",
	view_filter = function(self, card)
		return card:isKindOf("Slash")
	end,
	view_as = function(self,cards)
		local cd = n_tuishoucard:clone()
		cd:addSubcard(cards)
		return cd
	end,
	enabled_at_play = function(self,player)
		return not player:hasUsed("#n_tuishoucard")
	end
}
n_lianbangyi:addSkill(n_tuishou)
n_jinglve = sgs.CreateTriggerSkill{
	name = "n_jinglve",
	events = {sgs.EventPhaseStart,sgs.CardUsed,sgs.CardResponded},
	frequency=  sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				room:setPlayerMark(player,"n_jlfail",0)
			elseif player:getPhase() == sgs.Player_Finish then
				local n = 3
				if player:getMark("n_jlfail") > 0 then n = n - 1 end
				local cards = player:getCards("h")
				for _,c in sgs.qlist(cards) do
					if c:isKindOf("Slash") then n = n - 1;break end
				end
				if player:isKongcheng() then n = n - 1 else
					for _,c in sgs.qlist(cards) do
						if not c:isKindOf("Jink") then n = n - 1;break end
					end
				end
				if n > 0 then
					n_CompulsorySkill(room,player,self:objectName())
					player:drawCards(n)
				end
			end
		elseif event == sgs.CardUsed then
			if data:toCardUse().card:isKindOf("Slash") then
				room:addPlayerMark(player,"n_jlfail")
			end
		else
			if data:toCardResponse().m_card:isKindOf("Slash") then
				room:addPlayerMark(player,"n_jlfail")
			end
		end
	end,
}
n_lianbangyi:addSkill(n_jinglve)
sgs.LoadTranslationTable{
	["n_lianbangyi"] = "连邦翼",
	["designer:n_lianbangyi"] = "连邦翼",
	["cv:n_lianbangyi"] = "穆小橘",
	["illustrator:n_lianbangyi"] = "网络",
	["#n_lianbangyi"] = "舜星谋客",
	["&n_lianbangyi"] = "邦翼神",
	["~n_lianbangyi"] = "曾经或许温柔，此刻尽做仇雠...",
	["n_tuishou"] = "退守",
	["$n_tuishou1"] = "匆匆揽绣襟，花深入不见",
	["$n_tuishou2"] = "华胥梦，繁韶更，旧日江山春意盛",
	[":n_tuishou"] = "阶段技。你可以弃置一张杀，然后从牌堆或弃牌堆获得一张闪。",
	["n_jinglve"] = "精略",
	["$n_jinglve1"] = "一朝芙蓉暖，翩飞百鸟间",
	["$n_jinglve2"] = "叶舟清梦里，醉卧笑萧郎",
	[":n_jinglve"] = "锁定技。回合结束阶段，若：1.你的手牌中没有杀；2.你的手牌均为闪；3.你本回合没有使用或打出过杀。每满足其中一项，你便摸一张牌。",
}

n_muxiaoju = sgs.General(extension3,"n_muxiaoju","n_pigeon",3,false)
n_meiyincard = sgs.CreateSkillCard{
	name = "n_meiyincard",
	target_fixed = false,
	filter = function(self, selected, to_select)
		return (#selected == 0) and (to_select:objectName() ~= sgs.Self:objectName())
		and not to_select:isAllNude() and to_select:isMale() --getMark("n_meiyind") == 0
	end,
	on_effect = function(self, effect)
		local from = effect.from
		local to = effect.to
		local room = from:getRoom()
		if to:isAllNude() then return end
		room:obtainCard(from,room:askForCardChosen(from,to,"hej","n_meiyin"),false)
		local available_cards = {}
		for _,str in ipairs(patterns) do
			if isValidTarget(from,to,sgs.Sanguosha:cloneCard(str)) then
				table.insert(available_cards,str)
			end
		end
		if #available_cards == 0 then pattern = "^."
		elseif #available_cards == 1 then pattern = sgs.Sanguosha:cloneCard(available_cards[1]):getClassName()
		else
			local temp = {}
			for _,str in ipairs(available_cards) do
				table.insert(temp,sgs.Sanguosha:cloneCard(str):getClassName())
			end
			table.insert(temp,"NBrick")
			pattern = table.concat(temp,",")
		end
		local card = room:askForCard(from, pattern, "@n_meiyin",sgs.QVariant(),sgs.Card_MethodNone)
		if not card then from:turnOver()
		else
			local use = sgs.CardUseStruct()
			use.from = from
			use.to:append(to)
			use.card = card
			use.m_addHistory = true
			room:useCard(use)
		end
	end
}
n_meiyin = sgs.CreateViewAsSkill{
	name = "n_meiyin",
	n = 0,
	view_as = function(self,cards)	return n_meiyincard:clone()	end,
	enabled_at_play = function(self,player)
		return not player:hasUsed("#n_meiyincard")
	end
}
n_muxiaoju:addSkill(n_meiyin)
n_yanhui = sgs.CreateTriggerSkill{
	name = "n_yanhui",
	events = sgs.TurnedOver,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if player:faceUp() then return end
		local males = sgs.SPlayerList()
		for _,p in sgs.qlist(room:getAlivePlayers()) do
			if p:isMale() then males:append(p) end
		end	
		if males:isEmpty() then return end
		local to = room:askForPlayerChosen(player, males, self:objectName(),"#n_yanhui",true,true)
		if to then
			room:broadcastSkillInvoke(self:objectName())
			to:turnOver()
			player:drawCards(player:getMaxHp()-player:getHandcardNum())
			to:drawCards(to:getMaxHp()-to:getHandcardNum())
		end
	end
}
n_muxiaoju:addSkill(n_yanhui)
sgs.LoadTranslationTable{
	["n_muxiaoju"] = "穆小橘",
	["designer:n_muxiaoju"] = "思故凝殇",
	["cv:n_muxiaoju"] = "穆小橘",
	["illustrator:n_muxiaoju"] = "网络",
	["#n_muxiaoju"] = "cv大佬",
	["~n_muxiaoju"] = "",
	["n_meiyin"] = "魅音",
	["@n_meiyin"] = "魅音：请对目标使用一张牌，否则你翻面",
	[":n_meiyin"] = "阶段技。你可以指定一名男性角色，获得其一张牌，然后对其使用一张牌（须合法），否则你翻面。",
	["n_yanhui"] = "妍绘",
	["#n_yanhui"] = "妍绘：你现在可以选择一名男性角色发动“妍绘”",
	[":n_yanhui"] = "你翻至背面时可以选择一名男性角色，其翻面，然后你与其将手牌补至体力上限。",
}

n_tltl = sgs.General(extension3,"n_tltl","n_pigeon")
n_mouzan = sgs.CreateTriggerSkill{
	name = "n_mouzan",
	events = {sgs.TargetConfirmed, sgs.SlashMissed, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if player:objectName() == use.from:objectName() then
				if player:isAlive() and player:hasSkill(self:objectName()) then
					local slash = use.card
					if slash:isKindOf("Slash") then
						for _,p in sgs.qlist(use.to) do
							local ai_data = sgs.QVariant()
							ai_data:setValue(p)
							if player:askForSkillInvoke(self:objectName(), ai_data) then
								local choice
								if not player:isWounded() then
									choice = "tl_damage"
								else
									choice = room:askForChoice(player, self:objectName(), "tl_damage+tl_recover")
								end
								if choice == "tl_recover" then
									room:broadcastSkillInvoke(self:objectName(),2)
									room:recover(player,sgs.RecoverStruct(player))
								else
									room:broadcastSkillInvoke(self:objectName(),1)
									room:damage(sgs.DamageStruct(self:objectName(),player,p))
								end
								local mark = string.format("%s%s", self:objectName(), slash:toString())
								local count = p:getMark(mark) + 1
								room:setPlayerMark(p, mark,	count)
							end
						end
					end
				end
			end
		elseif event == sgs.SlashMissed then
			local effect = data:toSlashEffect()
			local dest = effect.to
			local source = effect.from
			local slash = effect.slash
			local mark = string.format("%s%s", self:objectName(), slash:toString())
			if dest:getMark(mark) > 0 then
				if source:isAlive() and dest:isAlive() then
					room:broadcastSkillInvoke(self:objectName(),3)
					room:damage(sgs.DamageStruct(self:objectName(),dest,source))
				end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") then
				local players = room:getAllPlayers()
				for _,p in sgs.qlist(players) do
					local mark = string.format("%s%s", self:objectName(), use.card:toString())
					room:setPlayerMark(p, mark, 0)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
n_tltl:addSkill(n_mouzan)
sgs.LoadTranslationTable{
	["n_tltl"] = "TL天狼",
	["&n_tltl"] = "天狼",
	["#n_tltl"] = "直勿",
	["~n_tltl"] = "想不到...会败在自己人手里...",
	["designer:n_tltl"] = "Notify",
	["cv:n_tltl"] = "TL天狼",
	["illustrator:n_tltl"] = "比利王二号",
	["tl_damage"] = "对目标造成一点伤害",
	["tl_recover"] = "回复一点体力",
	["n_mouzan"] = "谋赞",
	["$n_mouzan1"] = "挫敌精锐，亦是破敌之时。",
	["$n_mouzan2"] = "敌有留守，应退守以待良机",
	["$n_mouzan3"] = "居然还有这一手？",
	[":n_mouzan"] = "当你使用【杀】指定一名角色为目标后，你可以选择一项：回复一点体力，或对其造成一点伤害。若如此做，此【杀】被【闪】抵消时，该角色对你造成一点伤害。",
}

n_guici_typeTable = {1, 2, 4}
n_yzjcz = sgs.General(extension3,"n_yzjcz","n_pigeon",3,false)
n_guici = sgs.CreateTriggerSkill {
	name = "n_guici",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart, sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			if player:getPhase() ~= sgs.Player_Play then return end
			if not player:askForSkillInvoke(self:objectName()) then return end
			room:broadcastSkillInvoke(self:objectName())
			local x = player:getMark("n_guicimem")
			local id = room:drawCard()
			room:moveCardsAtomic(sgs.CardsMoveStruct(id, nil, nil, sgs.Player_DrawPile, sgs.Player_PlaceTable, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), self:objectName(), "")), true);
			local t = n_guici_typeTable[sgs.Sanguosha:getCard(id):getTypeId()]
			if bit32.band(x, t) == 0 then
				x = bit32.bor(x, t)
				room:setPlayerMark(player, "n_guicimem", x)
				player:obtainCard(sgs.Sanguosha:getCard(id))
			else
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), "");
				room:throwCard(sgs.Sanguosha:getCard(id), reason, nil);
			end
		else
			if player:getPhase() == sgs.Player_NotActive then
				room:setPlayerMark(player, "n_guicimem", 0)
			end
		end
	end,
}
n_yzjcz:addSkill(n_guici)
n_moran = sgs.CreateTriggerSkill {
	name = "n_moran",
	events = sgs.EventPhaseEnd,
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Discard then
			room:broadcastSkillInvoke(self:objectName())
			local handcards = player:getCards("h")
			local b, t, e = 1, 1, 1
			for _,cd in sgs.qlist(handcards) do
				if cd:isKindOf("BasicCard") then b = 0
				elseif cd:isKindOf("TrickCard") then t = 0
				elseif cd:isKindOf("EquipCard") then e = 0
				end
			end
			player:drawCards(b + t + e)
		end
	end
}
n_yzjcz:addSkill(n_moran)
sgs.LoadTranslationTable{
	["n_yzjcz"] = "宇佐见茶子",
	["~n_yzjcz"] = "救救猫猫啦~",
	["&n_yzjcz"] = "茶子",
	["#n_yzjcz"] = "惊鸿一瞥",
	["designer:n_yzjcz"] = "宇佐见茶子",
	["cv:n_yzjcz"] = "穆小橘",
	["illustrator:n_yzjcz"] = "来自网络",
	["n_guici"] = "瑰辞",
	["$n_guici1"] = "",
	["$n_guici2"] = "",
	["$n_guici3"] = "",	
	[":n_guici"] = "出牌阶段，当你使用牌时，你可以展示牌堆顶的一张牌，若你本回合未以此法获得过该类型的牌，则你获得之。",	
	["n_moran"] = "墨染",	
	["$n_moran1"] = "",	
	["$n_moran2"] = "",	
	["$n_moran3"] = "",	
	[":n_moran"] = "锁定技，弃牌阶段结束后，你摸x张牌（x为你手牌缺少的类型数）",	
}

n_xianhe = sgs.General(extension3,"n_xianhe","n_pigeon",4)
n_zhanghui = sgs.CreateTriggerSkill{
	name = "n_zhanghui",
	events = sgs.EventPhaseStart,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start then
			local choices = {}
			if not player:isNude() then
				table.insert(choices, "n_zhct")
			end
			local available_targets = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if not p:isNude() then
					available_targets:append(p)
				end
			end
			if not available_targets:isEmpty() then
				table.insert(choices, "n_zhcs")
			end

			if #choices ~= 0 then
				table.insert(choices, "cancel")
				local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"), sgs.QVariant())
				if choice == "n_zhct" then
					local msg = sgs.LogMessage()
					msg.type = "#InvokeSkill"
					msg.from = player
					msg.arg = self:objectName()
					room:sendLog(msg)
					room:notifySkillInvoked(player,self:objectName())
					room:broadcastSkillInvoke(self:objectName(), 1)

					local victim = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "n_zhct_ask")
					room:doAnimate(1, player:objectName(), victim:objectName())
					n_askForGiveCardTo(player, victim, self:objectName(), ".|.|.|.!", 
						"#ShenshouGive:"..victim:getGeneralName(), true)

					local use_to = sgs.SPlayerList()
					for _, p in sgs.qlist(room:getOtherPlayers(victim)) do
						if victim:inMyAttackRange(p) then
							use_to:append(p)
						end
					end
					if use_to:isEmpty() then return end
					local card = sgs.Sanguosha:cloneCard("peach")
					card:setSkillName("_n" .. self:objectName())
					local use = sgs.CardUseStruct()
					use.from = player
					for _, p in sgs.qlist(use_to) do use.to:append(p) end 
					use.card = card
					room:useCard(use, false)
				elseif choice == "n_zhcs" then
					local msg = sgs.LogMessage()
					msg.type = "#InvokeSkill"
					msg.from = player
					msg.arg = self:objectName()
					room:sendLog(msg)
					room:notifySkillInvoked(player,self:objectName())
					room:broadcastSkillInvoke(self:objectName(), 2)

					local victim = room:askForPlayerChosen(player, available_targets, self:objectName(), "n_zhcs_ask")
					room:doAnimate(1, player:objectName(), victim:objectName())
					n_askForGiveCardTo(victim, player, self:objectName(), ".|.|.|.!", 
						"#ShenshouGive:"..player:getGeneralName(), true)

					local use_to = sgs.SPlayerList()
					local card = sgs.Sanguosha:cloneCard("slash")
					card:setSkillName("_n" .. self:objectName())
					for _, p in sgs.qlist(room:getOtherPlayers(victim)) do
						if p:inMyAttackRange(victim) and victim:canSlash(p, card, false) then
							use_to:append(p)
						end
					end
					if use_to:isEmpty() then card:deleteLater(); return end
					local use = sgs.CardUseStruct()
					use.from = victim
					for _, p in sgs.qlist(use_to) do use.to:append(p) end 
					use.card = card
					room:useCard(use, false)
				end
			end
		end
	end
}
n_xianhe:addSkill(n_zhanghui)
n_tangrong = sgs.CreateTriggerSkill{
	name = "n_tangrong",
	events = {sgs.TargetConfirmed, sgs.CardFinished},
	can_trigger = function(self, target) return target end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		
		if event == sgs.CardFinished then
			for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				room:setPlayerMark(p, "n_tangrong_dontinvoke", 0)
			end
			return 
		end

		local use = data:toCardUse()
		local canInvoke = function(player, card_use)
			return card_use.card:isKindOf("BasicCard") 
				and card_use.to:length() > 1 
				and not card_use.to:contains(player)
				and player:getMark("n_tangrong_dontinvoke") == 0
		end

		for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if canInvoke(p, use) and room:askForSkillInvoke(p, self:objectName(), data) then
				room:notifySkillInvoked(p, self:objectName())
				if use.card:isKindOf("Slash") then
					room:broadcastSkillInvoke(self:objectName(), 2)
				else
					room:broadcastSkillInvoke(self:objectName(), 1)
				end

				use.to = sgs.SPlayerList()
				use.to:append(p)
				data:setValue(use)	
			else
				room:setPlayerMark(p, "n_tangrong_dontinvoke", 1)
			end
		end
	end
}
n_xianhe:addSkill(n_tangrong)
sgs.LoadTranslationTable{
    ["n_xianhe"] = "宪和",
    ["#n_xianhe"] = "闻歌云竹",
    ["designer:n_xianhe"] = "宪和",
    ["cv:n_xianhe"] = "Notify",
    ["illustrator:n_xianhe"] = "网络",
    ["n_zhanghui"] = "彰晦",
	["nn_zhanghui"] = "彰晦",
    [":n_zhanghui"] = "准备阶段，你可以选择：交给一名其他角色一张牌，然后视为对其攻击范围内的所有角色使用一张桃；" ..
	"令一名其他角色交给你一张牌，然后其视为对攻击范围内含有其的所有角色出杀。",
    ["n_zhct"] = "给别人一张牌，视为对他攻击范围内角色出桃",
	["n_zhcs"] = "向别人要一张牌，他视为对杀得到他的角色出杀",
	["n_zhct_ask"] = "彰晦：请选择一名其他角色，你将交给他一张牌",
	["n_zhcs_ask"] = "彰晦：请选择一名其他角色，你将向他要一张牌",
 	["$n_zhanghui1"] = "此非为肮脏交易，但求一方群员安宁。",
    ["$n_zhanghui2"] = "愿为管理，诛潜水之人，清群主之侧！",
    ["n_tangrong"] = "傥容",
    [":n_tangrong"] = "当有角色成为基本牌的目标时，若其不是此牌的唯一目标且你不是目标，你可以取消其中所有目标并令自己成为目标。",
    ["$n_tangrong1"] = "吾抱薪而来，怎可冻毙而去？",
    ["$n_tangrong2"] = "吾自制法，吾自犯之，何以服众？",
	["#ntangrongchange"] = "%from 发动了 “%arg”，本次结算目标变成了 %to",
    ["~n_xianhe"] = "丈夫何惧入地府，雄来利剑雌当纳。",
}

n_xianren = sgs.General(extension4,"n_xianren","n_n")
n_langbi = sgs.CreateTriggerSkill{
	name = "n_langbi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart,sgs.CardUsed,sgs.EventPhaseChanging},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_Discard then
				n_CompulsorySkill(room,player,self:objectName())
				player:skip(change.to)
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				n_CompulsorySkill(room,player,self:objectName())
				player:throwAllCards()
				player:drawCards(1)
			end
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if not (use.card:isKindOf("SkillCard")) then
				room:notifySkillInvoked(player,self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				player:drawCards(1)
			end
		end
		return false
	end
}
n_xianren:addSkill(n_langbi)
n_piruan = sgs.CreateTriggerSkill{
	name = "n_piruan",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardFinished,sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardFinished then
			local use = data:toCardUse()
			if not use.card:isKindOf("Skill") then
				room:setPlayerMark(player,"n_piruan",player:getMark("n_piruan")+1)
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				room:setPlayerMark(player,"n_piruan",0)
			elseif player:getPhase() == sgs.Player_Finish then
				if player:getMark("n_piruan") > player:getMaxHp() then
					
					local x = (player:getHandcardNum() + 1) / 2
					room:askForDiscard(player, "n_piruan", x, x, false)
					n_CompulsorySkill(room,player,self:objectName())
					room:loseHp(player,1)
				end
				room:setPlayerMark(player,"n_piruan",0)
			end
		end
	end,
}
n_xianren:addSkill(n_piruan)
sgs.LoadTranslationTable{
	["n_xianren"] = "仙人",
	["#n_xianren"] = "修仙不要虚",
	["~n_xianren"] = "咳咳...",
	["cv:n_xianren"] = "Notify",
	["designer:n_xianren"] = "Notify",
	["illustrator:n_xianren"] = "来自网络",
	["n_langbi"] = "浪逼",
	[":n_langbi"] = "锁定技。你跳过弃牌阶段；准备阶段开始时，你弃置包括判定区在内的所有牌然后摸一张牌；你使用牌后，摸一张牌。",
	["$n_langbi1"] = "下课了，不玩怎么可以呢！",
	["$n_langbi2"] = "老师没来，不要虚不要虚！",
	["n_piruan"] = "疲软",
	[":n_piruan"] = "锁定技。结束阶段，若你本回合使用牌的数目超过了体力上限，你弃一半的手牌（向上取整）并失去一点体力。",
	["$n_piruan"] = "好舒服啊",
}

n_jianpanxia = sgs.General(extension4,"n_jianpanxia","n_n",3)
n_xiabaicard = sgs.CreateSkillCard{
    name = "n_xiabaicard", 
    target_fixed = false, 
    will_throw = false, 
    filter = function(self, targets, to_select) 
        return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
        and not to_select:isKongcheng()
    end, 
    feasible = function(self, targets)
        return #targets == 1
    end,
    on_use = function(self, room, source, targets)
        source:pindian(targets[1], "n_xiabai")
	end,
}
n_xiabaivs = sgs.CreateViewAsSkill{
    name = "n_xiabai", 
    n = 0, 
    view_as = function(self, cards) 
        return n_xiabaicard:clone()
    end, 
    enabled_at_play = function(self, player)
        return not player:hasUsed("#n_xiabaicard") and not player:isKongcheng()
    end
}
n_xiabai = sgs.CreateTriggerSkill{
    name = "n_xiabai",  
    events = {sgs.Pindian}, 
    view_as_skill = n_xiabaivs, 
    on_trigger = function(self, event, player, data) 
        local pindian = data:toPindian()
        if pindian.reason == self:objectName() then
            if pindian.from_card:getNumber() > pindian.to_card:getNumber() then
                if pindian.from:objectName() == player:objectName() then
                    player:drawCards(2)
                    if not pindian.to:isKongcheng() then
                        local room = player:getRoom()
                        room:broadcastSkillInvoke(self:objectName())
                        player:pindian(pindian.to, "n_xiabai")
                    end
                end
            end
        end
        return false
    end
}
n_jianpanxia:addSkill(n_xiabai)
sgs.LoadTranslationTable{
    ["n_jianpanxia"]="键盘侠",
    ["designer:n_jianpanxia"]="Notify",
    ["illustrator:n_jianpanxia"]="来自网络",
    ["#n_jianpanxia"]="隔空血战",
    ["n_xiabai"]="瞎掰",
    [":n_xiabai"]="阶段技。你可以与一名其他角色拼点，若你赢，你摸两张牌并重复此流程。",
    ["$n_xiabai"]="尝尝我粗鄙的厉害！！",
	["~n_jianpanxia"]="竟然...比我还...厚颜无耻！！！",
}

n_nongfu = sgs.General(extension4,"n_nongfu","n_n",3)
n_sanquan = sgs.CreateTriggerSkill{
    name = "n_sanquan",
    frequency = sgs.Skill_Frequent,
    events = {sgs.CardUsed,sgs.EventPhaseChanging},
    on_trigger = function(self,event,player,data)
        local room = player:getRoom()
        if event == sgs.CardUsed then
            if player:getPhase() == sgs.Player_Play then
                room:addPlayerMark(player,"nfsq",1)
                local sanq = player:getMark("nfsq")
                if sanq == 1 then
                if room:askForSkillInvoke(player, self:objectName(), data) then
                    room:broadcastSkillInvoke(self:objectName())
                    local tgt = room:getOtherPlayers(player)
                    local targets = sgs.SPlayerList()
                    for _,p in sgs.qlist(tgt) do
                        if not p:isAllNude() then targets:append(p) end
                    end
                    if targets:isEmpty() then return end
                    local victim = room:askForPlayerChosen(player, targets, "nfsq_discard")
                    local id = room:askForCardChosen(player, victim, "hej", self:objectName())
                    room:throwCard(id, victim, player)
                end
                elseif sanq == 2 then
                if room:askForSkillInvoke(player, self:objectName(), data) then
                    room:broadcastSkillInvoke(self:objectName())
                    room:drawCards(player,1)
                end
                elseif sanq == 3 then
                if room:askForSkillInvoke(player, self:objectName(), data) then
                    room:broadcastSkillInvoke("n_sanquan")
                    local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
                    slash:setSkillName(self:objectName())
                    local targets = room:getOtherPlayers(player)
                    for _,p in sgs.qlist(targets) do
                        if not player:canSlash(p, slash, false) then targets:removeOne(p) end
                    end
					if targets:isEmpty() then return end
                    local target = room:askForPlayerChosen(player, targets, "nfsq_slash")
                    local card_use = sgs.CardUseStruct()
                    card_use.card = slash
                    card_use.from = player
                    card_use.to:append(target)
                    room:useCard(card_use, false)
                end
                end
            end
        elseif event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to == sgs.Player_NotActive then
                room:setPlayerMark(player,"nfsq",0)
            end
        end
    end
}
n_banyun = sgs.CreateTriggerSkill{
    name = "n_banyun",
    events = {sgs.Death},
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        if data:toDeath().who:objectName() == player:objectName() then
        if room:askForSkillInvoke(player, self:objectName(), data) then
            local target = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "n_banyun-invoke", true, true)
            if target then
                    room:broadcastSkillInvoke(self:objectName())
                    local skills = {"n_ruiquan", "n_rouquan", "n_feiquan"}
                    room:handleAcquireDetachSkills(target, skills[math.random(1, #skills)])
                    room:drawCards(target,2)
            end
        end
        end
    end,
    can_trigger = function(self, target)
        return target and target:hasSkill(self:objectName())
    end
}
n_ruiquan = sgs.CreateTriggerSkill{
    name = "n_ruiquan",
    frequency = sgs.Skill_Frequent,
    events={sgs.CardUsed,sgs.EventPhaseChanging},
    on_trigger = function(self,event,player,data)
        local room = player:getRoom()
        if event == sgs.CardUsed then
            if player:getPhase() == sgs.Player_Play then
                room:addPlayerMark(player,"nfsq",1)
                local sanq = player:getMark("nfsq")
                if sanq == 1 then
                if room:askForSkillInvoke(player, self:objectName(), data) then
                    room:broadcastSkillInvoke(self:objectName())
                    local tgt = room:getOtherPlayers(player)
                    local targets = sgs.SPlayerList()
                    for _,p in sgs.qlist(tgt) do
                        if not p:isAllNude() then targets:append(p) end
                    end
                    if targets:isEmpty() then return end
                    local victim = room:askForPlayerChosen(player, targets, "nfsq_discard")
                    local id = room:askForCardChosen(player, victim, "hej", self:objectName())
                    room:throwCard(id, victim, player)
                end
                end
            end
        elseif event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to == sgs.Player_NotActive then
                room:setPlayerMark(player,"nfsq",0)
            end
        end
    end
}
n_rouquan = sgs.CreateTriggerSkill{
    name = "n_rouquan",
    frequency = sgs.Skill_Frequent,
    events={sgs.CardUsed,sgs.EventPhaseChanging},
    on_trigger = function(self,event,player,data)
        local room = player:getRoom()
        if event == sgs.CardUsed then
            if player:getPhase() == sgs.Player_Play then
                room:addPlayerMark(player,"nfsq",1)
                local sanq = player:getMark("nfsq")
                if sanq == 2 then
                if room:askForSkillInvoke(player, self:objectName(), data) then
                    room:broadcastSkillInvoke(self:objectName())
                    room:drawCards(player,2)
                end
                end
            end
        elseif event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to == sgs.Player_NotActive then
                room:setPlayerMark(player,"nfsq",0)
            end
        end
    end
}
n_feiquan = sgs.CreateTriggerSkill{
    name = "n_feiquan",
    frequency = sgs.Skill_Frequent,
    events={sgs.CardUsed,sgs.EventPhaseChanging},
    on_trigger = function(self,event,player,data)
        local room = player:getRoom()
        if event == sgs.CardUsed then
            if player:getPhase() == sgs.Player_Play then
                room:addPlayerMark(player,"nfsq",1)
                local sanq = player:getMark("nfsq")
                if sanq == 3 then
                if room:askForSkillInvoke(player, self:objectName(), data) then
                    room:broadcastSkillInvoke("n_sanquan")
                    local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
                    slash:setSkillName(self:objectName())
                    local targets = room:getOtherPlayers(player)
                    for _,p in sgs.qlist(targets) do
                        if not player:canSlash(p, slash, false) then targets:removeOne(p) end
                    end
					if targets:isEmpty() then return end
                    local target = room:askForPlayerChosen(player, targets, "nfsq_slash")
                    local card_use = sgs.CardUseStruct()
                    card_use.card = slash
                    card_use.from = player
                    card_use.to:append(target)
                    room:useCard(card_use, false)
                end
                end
            end
        elseif event == sgs.EventPhaseChanging then
            local change = data:toPhaseChange()
            if change.to == sgs.Player_NotActive then
                room:setPlayerMark(player,"nfsq",0)
            end
        end
    end
}
n_anjiang:addSkill(n_rouquan)
n_anjiang:addSkill(n_ruiquan)
n_anjiang:addSkill(n_feiquan)
n_nongfu:addSkill(n_sanquan)
n_nongfu:addSkill(n_banyun)
sgs.LoadTranslationTable{
    ["n_nongfu"]="农夫",
    ["#n_nongfu"]="自然之力",
    ["designer:n_nongfu"]="Notify",
    ["illustrator:n_nongfu"]="网络",
    ["n_sanquan"]="三拳",
    ["nfsq_slash"]="三拳：选择【杀】的目标",
    ["nfsq_discard"]="三拳：选择弃牌目标",
    ["$n_sanquan"]="喝！",
    [":n_sanquan"]="出牌阶段，你使用第一张牌后，你可弃置一名其他角色一张牌；你使用第二张牌后，你可以摸一张牌；你使用第三张牌后，你可以视为使用了一张无距离限制的【杀】（不计入使用上限）",
    ["n_banyun"]="搬运",
    ["$n_banyun"]="我们只是大自然的搬运工。",
    [":n_banyun"]="你死亡时，可选择一名角色，令其摸两张牌并获得“三拳残本”。\
    \
    <font color='grey'>柔拳：出牌阶段，你使用第二张牌后，你可以摸两张牌</font>\
    \
    <font color='grey'>锐拳：出牌阶段，你使用第一张牌后，你可弃置一名其他角色一张牌</font>\
    \
    <font color='grey'>飞拳：出牌阶段，你使用第三张牌后，你可以视为使用了一张无距离限制的【杀】（不计入使用上限）</font>",
    ["n_banyun-invoke"]="选择一名角色随机获得一个技能",
    ["n_rouquan"]="柔拳",
    [":n_rouquan"]="出牌阶段，你使用第二张牌后，你可以摸两张牌",
    ["n_ruiquan"]="锐拳",
    [":n_ruiquan"]="出牌阶段，你使用第一张牌后，你可弃置一名其他角色一张牌",
    ["n_feiquan"]="飞拳",
    [":n_feiquan"]="出牌阶段，你使用第三张牌后，你可以视为使用了一张无距离限制的【杀】（不计入使用上限）",
}	

EnterMode = {}
n_commonmodes = {}
n_08pmodes = {}
n_02pmodes = {}
n_03pmodes = {}
n_04pmodes = {}
sgs.LoadTranslationTable{
	["brainholemd"] = "脑洞游戏模式",
}
EnterMode["cancel"] = function(player)
end

do		--挑战八废
table.insert(n_02pmodes,"ChallengeBafei")
bossbafei = sgs.General(extension5, "bossbafei" ,"god" ,2 ,true,true)
bossbafei:addSkill("nosjushou")
bossbafei:addSkill("yizhong")
bossbafei:addSkill("xinzhan")
bossbafei:addSkill("huilei")
bossbafei:addSkill("kuanggu")
bossbafei:addSkill("nosqianxun")
bossbafei:addSkill("noslianying")
bossbafei:addSkill("nosbuqu")
bossbafei:addSkill("yicong")
bossbafei:addSkill("nosleiji")
bossbafei:addSkill("guidao")

local bafei_generals = {
	"weiyan",
	"nos_caoren",
	"nos_zhoutai",
	"gongsunzan",
	"masu",
	"yujin",
	"nos_luxun",
	"nos_zhangjiao",
	"bossbafei"
}

function bafeify(player)
	local room = player:getRoom()
	local lord = room:getLord()
	local index = lord:getMark("@bf_killed") + 1
	room:changeHero(player,bafei_generals[index],true,true)
	if not player:isAlive() then room:revivePlayer(player,true) end
	
	--以下皆为过场
	room:doLightbox("$bafeibox"..index,4500)
	
	local log = sgs.LogMessage()
	log.type = "#ChallengeBafeiNextLevel"
	log.from = player
	room:sendLog(log)
end

function BafeiGameOverJudge(room)
	if room:getAlivePlayers():length() ~= 1 then return end
	for _,p in sgs.qlist(room:getAlivePlayers()) do
		if not p:isLord() then
			room:gameOver("rebel")
		elseif
			p:getMark("@bf_killed")>8 then room:gameOver("lord")
		end
	end
	return
end

ChallengeBafeiRule = sgs.CreateTriggerSkill{
	name = "#ChallengeBafeiRule",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.BeforeGameOverJudge,sgs.BuryVictim},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.BeforeGameOverJudge then
			--跳过正常规则
			room:setTag("SkipGameRule", sgs.QVariant(true))
		end
		if event == sgs.BuryVictim then	--处理阵亡角色的时机
			--跳过正常奖惩
			room:setTag("SkipNormalDeathProcess", sgs.QVariant(true))
			--判断一下是否结束，否则可能你一个人打牌了
			BafeiGameOverJudge(room)
			local death = data:toDeath()
			local who = death.who
			--local killer = death.damage.from
			who:bury()	--做出埋葬工作，比如把牌弃掉之类的
			local lord = room:getLord()
			lord:gainMark("@bf_killed",1)	--控制型语句
			--if killer and killer == lord then	--小奖励
				lord:drawCards(3)
				if lord:isWounded() then
					local recover = sgs.RecoverStruct()
					recover.recover = 1
					recover.who = lord
					room:recover(lord, recover)
				end
			--end
			--判断一下八废是否全部阵亡，并作出相应动作
			if who:getGeneralName() ~= "bossbafei" then
				bafeify(who)
			else
				BafeiGameOverJudge(room)
				return true
			end
			room:setTag("FirstRound",sgs.QVariant(true))
			who:drawCards(4)	--算是起始手牌，尚不规范
			room:setTag("FirstRound",sgs.QVariant(false))
			--以下可无视
			BafeiGameOverJudge(room)
			room:setTag("SkipNormalDeathProcess", sgs.QVariant(false)) 
			return true
		end
	end,
	can_trigger = function(self, target)	--必要的一手，不然不会正常运行
		return ( target ~= nil )
	end,
	priority = 1,							--比正常规则稍高一点的优先级
}
n_anjiang:addSkill(ChallengeBafeiRule)
EnterMode["ChallengeBafei"] = function(player)
	local room = player:getRoom()
    room:setTag("DisableMVP", sgs.QVariant(true))
	room:doLightbox("$WelcomeToChanllengeBafeiMode", 4000)
	
	local log = sgs.LogMessage()
	log.type = "#EnterChanllengeBafei"
	room:sendLog(log)
		
	local him = room:getLord():getNext()
	local players = room:getAllPlayers()
	for _,p in sgs.qlist(players) do
		room:acquireSkill(p,"#ChallengeBafeiRule")
	end
	
	bafeify(him)
		
	room:updateStateItem()
end

sgs.LoadTranslationTable{
	["ChallengeBafei"] = "挑战八废",
	["$WelcomeToChanllengeBafeiMode"] = "太阳神三国杀·挑战八废",
	["#EnterChanllengeBafei"] = "欢迎进入“挑战八废”模式！",
	["#ChallengeBafeiNextLevel"] = "恭喜进入下一关：%from",
	["@bf_killed"] = "人头",
	["bossbafei"] = "八废合体",
	["~bossbafei"] = "八废合体阵亡",
	["&bossbafei"] = "八废",
	["#bossbafei"] = "谁敢黑我",
	["$bafeibox1"] = "第 1 关\
	堕入地狱之番王，\
	        红血魔魏延",
	["$bafeibox2"] = "第 2 关\
	保卫宇宙之战士，\
	        蓝高达曹仁",
	["$bafeibox3"] = "第 3 关\
	盘踞大地之霸主，\
	        绿巨蜥周泰",
	["$bafeibox4"] = "第 4 关\
	蛰伏深渊的大蝎，\
	        白兽公孙瓒",
	["$bafeibox5"] = "第 5 关\
	赤色的夺魂蝙蝠，\
	        追命泪马谡",
	["$bafeibox6"] = "第 6 关\
	深海的蓄爆大龟，\
	        人亡盾于禁",
	["$bafeibox7"] = "第 7 关\
	草原的不死青蛇，\
	        无限连陆逊",
	["$bafeibox8"] = "第 8 关\
	极地的雷电蜗牛，\
	        劈你妹张角",
	["$bafeibox9"] = "最终关\
	八废合体\
	    仙福永享，寿与天齐",
}
end
do		--弹窗之战
table.insert(n_commonmodes,"popupwar")
n_popups = {
    "draw1card","draw2card",
    "rcv1hp","dis1cd",
    "dis2cd","lose1hp",
    "dmg1hp","cancel",
    "trnovr","chaind"
}
n_popupchat = {
    "建议选A",
    "建议选B",
    "建议选C",
    "弹窗出现了！！",
}
n_doReward = function(player,str)
    local room = player:getRoom()
    if str == "draw1card" then
        player:drawCards(1)
    elseif str == "draw2card" then
        player:drawCards(2)
    elseif str == "rcv1hp" then
        room:recover(player,sgs.RecoverStruct())
    elseif str == "dis1cd" then
        room:askForDiscard(player,"popupwar",1,1,false,true)
    elseif str == "dis2cd" then
        room:askForDiscard(player,"popupwar",2,2,false,true)
    elseif str == "lose1hp" then
        room:loseHp(player)
    elseif str == "dmg1hp" then
        room:damage(sgs.DamageStruct("popupwar",nil,player))
    elseif str == "trnovr" then
        player:turnOver()
    elseif str == "chaind" then
        player:setChained(not player:isChained())
        room:broadcastProperty(player, "chained")
        room:setEmotion(player, "chain")
        room:getThread():trigger(sgs.ChainStateChanged, room, player)
    end
end

popupwarRule = sgs.CreateTriggerSkill{
    name = "#popupwarRule",
    events = {sgs.CardUsed,sgs.CardResponded},
    on_trigger = function(self,event,player,data)
        local room = player:getRoom()
        math.randomseed(tostring(os.time()):reverse():sub(1, 7))
        local card
        if event == sgs.CardUsed then
        	card = data:toCardUse().card
        elseif event == sgs.CardResponded then
        	card = data:toCardResponse().m_card
        end
        if not card:isKindOf("SkillCard") then
            local probable = 0.25 + player:getCards("e"):length()*0.05
            if math.random() < probable then
                local str = ""
                if math.random() > 0.5 then
                    local a,b = 0,0
                    while a == b do 
                        a = math.floor(math.random(1,#n_popups))
                        b = math.floor(math.random(1,#n_popups))
                    end
                    str = n_popups[a].."+"..n_popups[b]
                else
                    local a,b,c = 0,0,0
                    while a == b or a == c or b == c do 
                        a = math.floor(math.random(1,#n_popups))
                        b = math.floor(math.random(1,#n_popups))
                        c = math.floor(math.random(1,#n_popups))
                    end
                    str = n_popups[a].."+"..n_popups[b].."+"..n_popups[c]
                end
                sgs.Sanguosha:playSystemAudioEffect("pop_up")
                if math.random() < 0.3 then player:speak(n_popupchat[math.random(1,#n_popupchat)]) end
                n_doReward(player,room:askForChoice(player,"popupwar",str,sgs.QVariant()))
            end
        end
    end
}
n_anjiang:addSkill(popupwarRule)

EnterMode["popupwar"] = function(player)
	local room = player:getRoom()
	room:doLightbox("$WelcomeToPopupwar", 4000)
	
	local log = sgs.LogMessage()
	log.type = "#EnterPopupwar"
	room:sendLog(log)
		
	local players = room:getAllPlayers()
	for _,p in sgs.qlist(players) do
		room:acquireSkill(p,"#popupwarRule")
	end
end

sgs.LoadTranslationTable{
    ["#n_ModeStart"] = "脑洞游戏模式",
	["popupwar"] = "弹窗之战",
	["$WelcomeToPopupwar"] = "太阳神三国杀·弹窗之战",
	["#EnterPopupwar"] = "欢迎进入“弹窗之战”模式！",
	["draw1card"] = "摸一张牌",
	["draw2card"] = "摸两张牌",
    ["rcv1hp"] = "回复一点体力",
    ["dis1cd"] = "弃一张牌",
    ["dis2cd"] = "弃两张牌",
    ["lose1hp"] = "失去一点体力",
    ["dmg1hp"] = "受到一点伤害",
    ["trnovr"] = "翻面",
    ["chaind"] = "横置/重置",
}
end
do		--随机之战
table.insert(n_commonmodes,"randomwar")

randomwarRule = sgs.CreateTriggerSkill{
    name = "#randomwarRule",
    events = {sgs.TurnStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local n = 15
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			n = math.min(p:getSeat(), n)
		end
		if player:getSeat() == n and not room:getTag("ExtraTurn"):toBool() then
			local list = room:getOtherPlayers(player)
			local roles = {}
			for _, p in sgs.qlist(list) do
				table.insert(roles,p:getRole())
			end
			
			for _, p in sgs.qlist(list) do
				math.randomseed(tostring(os.time()):reverse():sub(1, 7))
				local n = #roles
				local x = math.random(1,#roles)
				room:setPlayerProperty(p,"role",sgs.QVariant(roles[x]))
				room:setEmotion(p,p:getRole())
				table.remove(roles,x)
			end
			for _, p in sgs.qlist(list) do
				local p2 = list:at(math.random(1,list:length()))
				while p:objectName() == p2:objectName() do
					p2 = list:at(math.random(1,list:length()))
				end
				room:swapSeat(p,p2)
			end
		end
		return false
	end
}
n_anjiang:addSkill(randomwarRule)

EnterMode["randomwar"] = function(player)
	local room = player:getRoom()
	room:doLightbox("$WelcomeToRandomwar", 4000)
	
	local log = sgs.LogMessage()
	log.type = "#EnterRandomwar"
	room:sendLog(log)
		
	local players = room:getAllPlayers()
	for _,p in sgs.qlist(players) do
		room:acquireSkill(p,"#randomwarRule")
	end
end

sgs.LoadTranslationTable{
	["randomwar"] = "随机之战",
	["$WelcomeToRandomwar"] = "太阳神三国杀·随机之战",
	["#EnterRandomwar"] = "欢迎进入“随机之战”模式！",
}
end
do		--斗地主
table.insert(n_03pmodes,"FightingTheLandlord")

n_feiyangCard = sgs.CreateSkillCard{
	name = "n_feiyang",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local judge = room:askForCardChosen(source, source, "j", self:objectName(), false, sgs.Card_MethodDiscard)
		room:throwCard(judge, source, source)
	end
}
n_feiyangVS = sgs.CreateViewAsSkill{
	name = "n_feiyang", 
	n = 2,
	response_pattern = "@@n_feiyang",
	view_filter = function(self, selected, to_select)
		return #selected <= 2 and not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards ~= 2 then return nil end
		local c = n_feiyangCard:clone()
		for _, card in ipairs(cards) do
			c:addSubcard(card)
		end
		return c
	end
}
n_feiyang = sgs.CreatePhaseChangeSkill{
	name = "n_feiyang",
	frequency = sgs.Skill_NotFrequent,
	view_as_skill = n_feiyangVS,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Judge and player:getJudgingArea():length() > 0 and player:getHandcardNum() >= 2 then
			room:askForUseCard(player, "@@n_feiyang", "@n_feiyang")
		end
		return false
	end
}
n_anjiang:addSkill(n_feiyang)
n_bahu = sgs.CreatePhaseChangeSkill{
	name = "n_bahu",
	frequency = sgs.Skill_Compulsory,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			player:drawCards(1, self:objectName())
		end
		return false
	end
}
n_bahuSlashMore = sgs.CreateTargetModSkill{
	name = "#n_bahuSlashMore",
	frequency = sgs.Skill_Compulsory,
	pattern = "Slash",
	residue_func = function(self, player)
		if player:hasSkill("n_bahu") then
			return 1
		end
		return 0
	end
}
n_anjiang:addSkill(n_bahu)
n_anjiang:addSkill(n_bahuSlashMore)
extension5:insertRelatedSkills("n_bahu", "#n_bahuSlashMore")
n_fllrule = sgs.CreateTriggerSkill{
	name = "#n_fllrule",
	events = {sgs.BuryVictim},
	priority = 2,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		player:bury()
		local partner = nil
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if player:getRole() == p:getRole() then
				partner = p
				break
			end
		end
		local choiceList = {"draw2Cards"}
		if partner:isWounded() then table.insert(choiceList, "recoverOne") end
		table.insert(choiceList, "cancel")
		local choice = room:askForChoice(partner, "n_fllrule", table.concat(choiceList, "+"))
		if choice == "recoverOne" then
			room:recover(partner, sgs.RecoverStruct(partner))
		elseif choice == "draw2Cards" then
			partner:drawCards(2)
		end
		return true
	end,
	can_trigger = function(self, target)
		return target
	end
}
n_anjiang:addSkill(n_fllrule)

EnterMode["FightingTheLandlord"] = function(player)
	local room = player:getRoom()
	room:doLightbox("$WelcomeToFightingTheLandlord", 4000)
	
	local log = sgs.LogMessage()
	log.type = "#FightingTheLandlord"
	room:sendLog(log)
		
	local players = room:getAllPlayers()
	local chosenGenerals = room:getTag("chosenGenerals"):toString()
	for _, player in sgs.qlist(players) do
		if player:getRole() == "renegade" then
			player:setRole("rebel")
			room:setPlayerProperty(player, "role", sgs.QVariant("rebel"))
			room:updateStateItem()
			room:resetAI(player)
		end
	end
	local landlord = room:getLord()
	--room:doLightbox("$LordChooseAgain",3000)
	--local generals = sgs.Sanguosha:getLimitedGeneralNames()
	--local generalList = {}
	--while #generalList < 5 do
	--	local g = generals[math.random(1, #generals)]
	--	if not table.contains(generalList, g) and not string.find(chosenGenerals, g) then
	--		table.insert(generalList, g)
	--	end
	--end
	--room:changeHero(landlord,room:askForGeneral(landlord, table.concat(generalList, "+"), generalList[1]),false)
	room:setPlayerProperty(landlord, "maxhp", sgs.QVariant(landlord:getMaxHp() + 1))
	room:setPlayerProperty(landlord, "hp", sgs.QVariant(landlord:getMaxHp()))
	room:handleAcquireDetachSkills(landlord, "n_feiyang|n_bahu|#n_fllrule")
end

sgs.LoadTranslationTable{
	["FightingTheLandlord"] = "欢乐斗地主",
	["$WelcomeToFightingTheLandlord"] = "太阳神三国杀·欢乐斗地主",
	["#FightingTheLandlord"] = "欢迎进入“欢乐斗地主”模式！",
	["$LordChooseAgain"] = "请地主选择自己的武将",
	
	["n_feiyang"] = "飞扬",
	[":n_feiyang"] = "判定阶段开始时，若你的判定区有牌，你可以弃置两张手牌，并弃置你判定区的一张牌。",
	["@n_feiyang"] = "你可以弃置两张手牌来弃置你判定区里的一张牌",
	["~n_feiyang"] = "选择两张手牌→点击确定",
	
	["n_bahu"] = "跋扈",
	[":n_bahu"] = "锁定技。准备阶段，你立即摸一张牌；你出牌阶段使用【杀】的次数上限+1。",
	
	["n_fllrule"] = "奖励",
	["recoverOne"] = "回复1点体力",
	["draw2Cards"] = "摸两张牌",
}

end

do	--三国荣耀（伪）

table.insert(n_08pmodes, "SanguoGlory")

n_wall = sgs.General(extension5, "n_wall", "god", 15, true, true)
n_budong = sgs.CreateTriggerSkill{
	name = "n_budong",
	events = {sgs.TurnedOver},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:faceUp() then
			n_CompulsorySkill(room, player, self:objectName())
			player:turnOver()
		end
	end
}
n_wall:addSkill(n_budong)
n_buji = sgs.CreateTriggerSkill{
	name = "n_buji",
	frequency = sgs.Skill_Compulsory,
	on_trigger = function() end
}
n_wall:addSkill(n_buji)

n_sggrule = sgs.CreateTriggerSkill{
	name = "#n_sggrule",
	events = {sgs.Dying, sgs.GameOverJudge, sgs.BuryVictim, sgs.TurnStart},
	priority = 3,
	can_trigger = function(self, target) return target end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.BeforeGameOverJudge then
			room:setTag("SkipGameRule", sgs.QVariant(true))
		elseif event == sgs.BuryVictim then
			room:setTag("SkipNormalDeathProcess", sgs.QVariant(true))
			local death = data:toDeath()
			death.who:bury()
			if death.who:getGeneralName() == "n_wall" then
				room:gameOver(death.who:getRole() == "rebel" and "loyalist" or "rebel")
			end
			--room:setPlayerProperty(death.who, "@revive", sgs.QVariant(death.who:getMaxHp()))
		elseif event == sgs.Dying then
			local death = data:toDying()
			if death.who:getGeneralName() ~= "n_wall" then
				room:killPlayer(death.who, death.damage)
			end
		elseif event == sgs.TurnStart then
			local n = 15
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				n = math.min(p:getSeat(), n)
			end
			if player:getSeat() == n and not room:getTag("ExtraTurn"):toBool() then
				for _, p in sgs.qlist(room:getAllPlayers(true)) do
					if p:isDead() then
						--room:setPlayerProperty(p, "@revive", sgs.QVariant(p:property("@revive"):toInt()-1))
						room:setPlayerProperty(p, "hp", sgs.QVariant(p:getHp()+1))
						for _, pp in sgs.qlist(room:getAllPlayers()) do
							if pp:getGeneralName() == "n_wall" and pp:getRole() == p:getRole() then
								room:loseHp(pp)
							end
						end
						--if p:property("@revive"):toInt() == 0 then
						if p:getLostHp() == 0 then
							room:revivePlayer(p, true)
							--room:recover(p,sgs.RecoverStruct(nil, nil, p:getLostHp()))
							p:drawCards(3)
						end
					end
				end
			end
            
		end
	end
}
n_anjiang:addSkill(n_sggrule)

EnterMode["SanguoGlory"] = function(player)
	local room = player:getRoom()
	playConversation(room, "n_debugger", "$WelcomeToSanguoGlory")
	playConversation(room, "n_debugger", "$SanguoGloryRule1")
    room:setTag("DisableMVP", sgs.QVariant(true))
	room:acquireSkill(room:getLord(), "#n_sggrule")--, false)
	local players = room:getAllPlayers()
	--先把主内换成忠；
	for _, p in sgs.qlist(players) do
		if p:getRoleEnum() == sgs.Player_Lord or p:getRoleEnum() == sgs.Player_Renegade then
			if p:getRoleEnum() == sgs.Player_Lord then room:loseMaxHp(p ,1) end
			p:setRole("loyalist")
			room:setPlayerProperty(p, "role", sgs.QVariant("loyalist"))
		end
		room:broadcastProperty(p, "role")
		room:resetAI(p)
	end
	room:updateStateItem()
	--再分配泉水，优先机器人；
	local robots = {}
	for _, p in sgs.qlist(players) do
		if p:getState() == "robot" then
			table.insert(robots, p)
		end
	end
	local robotsSame = false
	if #robots >= 2 then
		local alla, allb = true, true
		for _, p in ipairs(robots) do
			if p:getRoleEnum() == sgs.Player_Loyalist then
				allb = false
			else alla = false end
		end
		robotsSame = alla or allb
	end
	if robotsSame then
		local role = robots[1]:getRole()
		for _, p in sgs.qlist(players) do
			if p:getState() ~= "robot" and p:getRole() ~= role then
				robots[1]:setRole(p:getRole())
				room:setPlayerProperty(robots[1], "role", sgs.QVariant(p:getRole()))
				p:setRole(role)
				room:setPlayerProperty(p, "role", sgs.QVariant(role))
				room:broadcastProperty(robots[1], "role")
				room:broadcastProperty(p, "role")
				room:resetAI(robots[1])
				room:resetAI(p)
				break
			end
		end
	end
	local a, b = true, true
	for _, p in sgs.qlist(players) do
		if p:getState() == "robot" then
			if p:getRoleEnum() == sgs.Player_Rebel and a then
				room:changeHero(p, "n_wall", true)
				a = false
			end
			if p:getRoleEnum() == sgs.Player_Loyalist and b then
				room:changeHero(p, "n_wall", true)
				b = false
			end
		end
	end
	if a then
		for _, p in sgs.qlist(players) do
			if p:getRoleEnum() == sgs.Player_Rebel then
				room:changeHero(p, "n_wall", true)
				a = false
			end
		end
	end
	if b then
		for _, p in sgs.qlist(players) do
			if p:getRoleEnum() == sgs.Player_Loyalist then
				room:changeHero(p, "n_wall", true)
				b = false
			end
		end
	end
end

sgs.LoadTranslationTable{
	["SanguoGlory"] = "王者杀（伪）",
	["$WelcomeToSanguoGlory"] = "欢迎来到王者模式！",
	["$SanguoGloryRule1"] = "任何普通角色进入濒死时直接死亡！击杀敌方军营获得胜利！",
	["n_wall"] = "军营",
	["n_budong"] = "不动",
	[":n_budong"] = "锁定技，你永远背面向上。敌方角色与你计算距离+x（x为存活的敌方角色数）",
	["n_buji"] = "补给",
	[":n_buji"] = "锁定技，一轮开始时，与你距离为1或座位相邻的友方角色回复一点体力；每有一名已阵亡友方角色，你失去一点体力使其加一点体力，当体力已达到体力上限时该阵亡角色复活。",
}

end

do

table.insert(n_04pmodes, "KillAoerjia")

n_boss_aoerjia = sgs.General(extension5, "n_boss_aoerjia", "god", 8, true, true)
n_boss_aoerjia:addSkill("n_jingshe")
n_boss_aoerjia:addSkill("n_buting")
n_danyu = sgs.CreatePhaseChangeSkill{
	name = "n_danyu",
	frequency = sgs.Skill_Compulsory,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start then
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:setSkillName("_" .. self:objectName())
			local targets = sgs.SPlayerList()
			local can_invoke = false;
			if (not player:isCardLimited(slash, sgs.Card_MethodUse)) then
				for _,p in sgs.qlist(room:getOtherPlayers(player)) do
					if (not room:isProhibited(player, p, slash)) then
						can_invoke = true
						targets:append(p)
					end
				end
			end
			if (not can_invoke) then
				--泄漏之
				--delete aa;
				return false
			end
			room:broadcastSkillInvoke(self:objectName())
			room:useCard(sgs.CardUseStruct(slash, player, targets));
		end
	end
}
n_boss_aoerjia:addSkill(n_danyu)
sgs.LoadTranslationTable{
	["n_boss_aoerjia"] = "奥尔加-觉醒",
	["&n_boss_aoerjia"] = "奥尔加",
	["#n_boss_aoerjia"] = "永不停息",
	["n_danyu"] = "弹雨",
	[":n_danyu"] = "锁定技。准备阶段，视为你对所有其他角色使用了【杀】。",
	["$n_danyu"] = "全部木大木大木大",
	["~n_boss_aoerjia"] = "不要停下来...",

	["n_ansha"] = "暗杀",
	["$WelcomeToKillAoerjia"] = "刺杀奥尔加",
	["KillAoerjia"] = "刺杀奥尔加",

	["n_alj1"] = "总感觉好安静啊，街上也没有加拉尔霍恩的人，",
	["n_alj2"] = "%&#（*￥@%我也是加把劲骑士！",
	["n_alj3"] = "啊，说的也是#%?1*(%&#全部木大%&@（#~@**",
	["n_alj4"] = "嗯？",
	["n_alj4_5"] = "团长！你在干什么啊！团长！！",
	["n_alj5"] = "（拿出手枪）喝啊！",

	["n_alj6"] = "哈哈，你们中计了！以为这么容易就能击杀我吗！",
	["n_alj7"] = "趁此机会让你们全部木大！",
	["n_alj8"] = "偷袭！",
}

n_killaoerjiarule = sgs.CreateTriggerSkill{
	name = "#n_killaoerjiarule",
	events = {sgs.BuryVictim, sgs.BeforeGameOverJudge},
	can_trigger = function(self, target) return target end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.BeforeGameOverJudge then
			room:setTag("SkipGameRule", sgs.QVariant(true))
		elseif event == sgs.BuryVictim then
			room:setTag("SkipNormalDeathProcess", sgs.QVariant(true))
			local death = data:toDeath()
			death.who:bury()
			if death.who:getRole() == "lord" then
				if death.who:getGeneralName() == "n_aoerjia" then
					playConversation(room, "n_aoerjia", "n_alj6")

					room:changeHero(death.who, "n_boss_aoerjia", true, true)
					room:setPlayerProperty(death.who, "kingdom", sgs.QVariant("god"))
					room:revivePlayer(death.who)
					room:addPlayerMark(death.who, "@n_buting")
					--room:setTag("FirstRound",sgs.QVariant(true))
					death.who:drawCards(8)

					playConversation(room, "n_boss_aoerjia", "n_alj7")
					playConversation(room, "n_boss_aoerjia", "n_alj8")

					for _, p in sgs.qlist(room:getOtherPlayers(death.who)) do
						room:damage(sgs.DamageStruct("n_rule", death.who, p))
					end
					return true
					--room:setTag("FirstRound",sgs.QVariant(false))
				else
					room:gameOver("rebel")
				end
			else
				if death.damage and death.damage.from then
					death.damage.from:drawCards(3)
				end
				if room:getAlivePlayers():length() == 1 then
					room:gameOver("lord")
				end
			end
		end
	end,
	priority = 3
}
n_anjiang:addSkill(n_killaoerjiarule)

EnterMode["KillAoerjia"] = function(player)
	local room = player:getRoom()
	room:setTag("DisableMVP", sgs.QVariant(true))
	room:doLightbox("$WelcomeToKillAoerjia", 2500)

	local lord = room:getLord()
	for _, p in sgs.qlist(room:getOtherPlayers(lord)) do
		p:setRole("rebel")
		room:setPlayerProperty(p, "role", sgs.QVariant("rebel"))
		room:broadcastProperty(p, "role")
		room:resetAI(p)
	end

	room:changeHero(lord, "n_aoerjia", true)
	room:setPlayerProperty(lord, "kingdom", sgs.QVariant("n_web"))
	room:acquireSkill(lord, "#n_killaoerjiarule")

	playConversation(room, "n_laide", "n_alj1")
	playConversation(room, "n_laide", "n_alj2")
	playConversation(room, "n_aoerjia", "n_alj3")
	playConversation(room, "n_aoerjia", "n_alj4")

	local data = sgs.QVariant()
	data:setValue(lord)
	for _, p in sgs.qlist(room:getOtherPlayers(lord)) do
		if p:askForSkillInvoke("n_ansha", data) then
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:setSkillName("_n_ansha")
			room:useCard(sgs.CardUseStruct(slash, p, lord))
		end
	end

	playConversation(room, "n_laide", "n_alj4_5")
	playConversation(room, "n_aoerjia", "n_alj5")
end

end

do
-- 新神杀：龙神模式
table.insert(n_02pmodes, "FightLongshen")
n_longshen = sgs.General(extension5, "n_longshen", "god", 3, false, true)
huashen_skills = {
	{"n_longlin", "n_jienu"},
	{"n_longshi", "n_qinlv"},
	{"n_bibao", "n_longhou"},
	{"n_lingxi", "n_suwei"},
	{"n_ruiyan", "n_chaiyue"},
	{"n_longlie"}
}
n_longshen_enternextstage = function(player)
	local room = player:getRoom()
	local num = player:getMark("@n_huashen")
	if num == 0 then return end
	n_gainMhp(player, 1)
	room:recover(player, sgs.RecoverStruct(nil, nil, player:getLostHp()))
	-- 改lua
	-- 这该怎么改呢
	--[[
	if num == 6 then
		room:handleAcquireDetachSkills(player, "n_longlie")
	elseif num == 5 then
		room:handleAcquireDetachSkills(player, "-n_longlie|n_chaiyue|n_ruiyan|#n_chaiyueTMD")
	elseif num == 4 then
		room:handleAcquireDetachSkills(player, "-n_chaiyue|-n_ruiyan|-#n_chaiyueTMD|n_lingxi|#n_lingximaxcard|n_suwei")
	elseif num == 3 then
		room:handleAcquireDetachSkills(player, "-n_lingxi|-#n_lingximaxcard|-n_suwei|n_bibao|n_longhou")
	elseif num == 2 then
		room:handleAcquireDetachSkills(player, "-n_bibao|-n_longhou|n_longshi|n_qinlv")
	else
		room:handleAcquireDetachSkills(player, "-n_longshi|-n_qinlv|n_longlin|n_jienu")
	end
	]]--
	room:detachSkillFromPlayer(player, player:property("huashen_skill"):toString())
	local to_acquire = huashen_skills[num][math.random(1, #huashen_skills[num])]
	room:setPlayerProperty(player, "huashen_skill", sgs.QVariant(to_acquire))
	room:acquireSkill(player, to_acquire)
end

n_huashen = sgs.CreateTriggerSkill{
	name = "n_huashen",
	frequency = sgs.Skill_Compulsory, 	-- 锁定技
	events = {
		-- sgs.GameStart, 	-- 游戏开始时
		sgs.EnterDying, -- 进入濒死状态时
	},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		-- 游戏开始的部分放在另外的地方写
		player:throwAllHandCardsAndEquips()	-- 你弃置手牌区及装备区所有牌
		room:removePlayerMark(player, "@n_huashen", 1)	-- 移去一枚“化神”标记
		n_longshen_enternextstage(player)	-- 进入下一形态
		player:drawCards(4)
		-- 进入下一形态是自定义函数，待会写

		-- 其它所有角色依次：
		for _, p in sgs.list(room:getOtherPlayers(player)) do
			--n_gainMhp(p, 1)
			room:recover(p, sgs.RecoverStruct())	-- 回复一点体力
			p:drawCards(1)		-- 摸一张牌
			
			-- 抽取三张武将获得一个技能
			-- 我之前恰好写过
			local allplayers = room:getAlivePlayers() 
			local allnames = sgs.Sanguosha:getLimitedGeneralNames()

            math.randomseed(tostring(os.time()):reverse():sub(1, 7))
			local targets = {}
			for i=1, 3 do
				local count = #allnames
				local index = math.random(1, count)  
				local selected = allnames[index] 
				table.insert(targets, selected) 
				allnames[selected] = nil 
			end
			local generals = table.concat(targets, "+")
			local general = sgs.Sanguosha:getGeneral(room:askForGeneral(p, generals))
			local skill_names = {}
			for _,skill in sgs.qlist(general:getVisibleSkillList())do
                if skill:isLordSkill() or skill:getFrequency() == sgs.Skill_Limited 
				or skill:getFrequency() == sgs.Skill_Wake then
                    continue
				end
                if not table.contains(skill_names,skill:objectName()) then
                    table.insert(skill_names,skill:objectName())
                end
            end
            if #skill_names > 0 then
                local skill_name = room:askForChoice(p, "n_baipiao", table.concat(skill_names,"+"))
				room:acquireSkill(p, skill_name)
			end
		end
	end,
}
n_longshen:addSkill(n_huashen)
n_longlie = sgs.CreateTriggerSkill{
	name = "n_longlie",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetConfirmed, sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		-- 人数大于2时，【杀】伤害+1：
		if event == sgs.DamageCaused then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash")	-- 如果是杀的伤害
			and room:getAlivePlayers():length() > 2 then	-- 并且游戏人数大于2
				damage.damage = damage.damage + 1 	-- 伤害+1
				data:setValue(damage)
			end
			return
		end
		local use = data:toCardUse()
		if (player:objectName() ~= use.from:objectName()) or (not use.card:isKindOf("Slash")) then return false end
		local jink_table = sgs.QList2Table(player:getTag("Jink_" .. use.card:toString()):toIntList())
		local index = 1
		for _, p in sgs.qlist(use.to) do
			local _data = sgs.QVariant()
			_data:setValue(p)
			room:broadcastSkillInvoke(self:objectName())
			jink_table[index] = 0
			index = index + 1
		end
		local jink_data = sgs.QVariant()
		jink_data:setValue(table2IntList(jink_table))
		player:setTag("Jink_" .. use.card:toString(), jink_data)
		return false
	end,
}
n_anjiang:addSkill(n_longlie)
n_chaiyue = sgs.CreateTriggerSkill{
	name = "n_chaiyue",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then	-- 受到伤害后
			local damage = data:toDamage()
			if damage.nature ~= sgs.DamageStruct_Normal then return end
			-- 必须是普通伤害才触发
			-- 每收到一点伤害
			for i = 1, damage.damage do
				player:drawCards(2)		-- 摸2
				local cards = room:askForExchange(player, self:objectName(), 1, 1, true, "@n_chaiyue")
				player:addToPile("n_bei", cards:getSubcards())	-- 将一张牌放在武将牌上称为“碑”
			end
		else
			if player:getPhase() == sgs.Player_Draw then
				player:drawCards(player:getPile("n_bei"):length())	-- 摸牌
			end
		end
	end
}
n_anjiang:addSkill(n_chaiyue)
n_chaiyueTMD = sgs.CreateTargetModSkill{
	name = "#n_chaiyueTMD",
	frequency = sgs.Skill_Compulsory,
	pattern = "Slash",
	residue_func = function(self, player)
		if player:hasSkill("n_chaiyue") then
			return player:getPile("n_bei"):length()		-- 多出杀
		end
		return 0
	end
}
n_anjiang:addSkill(n_chaiyueTMD)
extension5:insertRelatedSkills("n_chaiyue", "#n_chaiyueTMD")
n_ruiyan = sgs.CreateTriggerSkill{
	name = "n_ruiyan",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Start or player:getPhase() == sgs.Player_Finish then
			player:drawCards(player:getRoom():getOtherPlayers(player):length())
		end
	end
}
n_anjiang:addSkill(n_ruiyan)
n_lingxi = sgs.CreateTriggerSkill{
	name = "n_chaiyue",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then	-- 受到伤害后
			local damage = data:toDamage()
			if damage.nature ~= sgs.DamageStruct_Normal then return end
			-- 必须是普通伤害才触发
			-- 每收到一点伤害
			for i = 1, damage.damage do
				player:drawCards(1)		-- 摸1
				local cards = room:askForExchange(player, self:objectName(), 1, 1, true, "@n_chaiyue")
				player:addToPile("n_bei", cards:getSubcards())	-- 将一张牌放在武将牌上称为“碑”
			end
		else
			if player:getPhase() == sgs.Player_Draw then
				player:drawCards(player:getPile("n_bei"):length())	-- 摸牌
			end
		end
	end
}
n_anjiang:addSkill(n_lingxi)
n_lingximaxcard = sgs.CreateMaxCardsSkill{
	name = "#n_lingximaxcard",
	extra_func = function(self,target)
		if target:hasSkill("n_lingxi") then 
			return player:getPile("n_bei"):length()		-- 加手牌上限
		end
	end
}
n_anjiang:addSkill(n_lingximaxcard)
extension5:insertRelatedSkills("n_lingxi", "#n_lingximaxcard")
n_suwei = sgs.CreateTriggerSkill{
	name = "n_suwei",
	events = {sgs.CardUsed},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("SkillCard") then return false end
		for _,p in sgs.qlist(room:getOtherPlayers(use.from)) do
			if use.to:contains(p) and use.from:objectName() ~= p:objectName() and
			 p:canDiscard(use.from, "he") and p:hasSkill(self:objectName()) then
				p:drawCards(1)
				room:broadcastSkillInvoke(self:objectName())
				room:throwCard(room:askForCardChosen(p, use.from, "he", self:objectName(), false, sgs.Card_MethodDiscard), use.from, p)
			end
		end
	end,
	can_trigger = function(self, target)	return target end
}
n_anjiang:addSkill(n_suwei)
n_bibao = sgs.CreateTriggerSkill{
	name = "n_bibao",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused, sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:recover(player, sgs.RecoverStruct())
		local damage = data:toDamage()
		damage.damage = damage.damage + 1
		player:drawCards(damage.damage)
		data:setValue(damage)
	end
}
n_anjiang:addSkill(n_bibao)
n_longhou = sgs.CreateTriggerSkill{
	name = "n_longhou",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("SkillCard") then return end
		for _, p in sgs.list(use.to) do
			-- 所有目标加上限受到伤害
			n_gainMhp(p, 1)
			room:damage(sgs.DamageStruct(self:objectName(), nil, p, p:getLostHp()))
		end
	end
}
n_anjiang:addSkill(n_longhou)
n_longshi = sgs.CreateTriggerSkill{
	name = "n_longshi",
	frequency = sgs.Skill_Compulsory,
	events = sgs.EventPhaseStart,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Start then
			for _, p in sgs.list(room:getOtherPlayers(player)) do
				local discards = {}
				local dummy = sgs.DummyCard()
				dummy:deleteLater()
				local allcards = p:getCards("he")
				for i = 1, math.min(allcards:length(), 3) do
					local id = room:askForCardChosen(player, p, "he", self:objectName())
					table.insert(discards, id)
					dummy:addSubcard(id)
					room:throwCard(id, p, player)
				end
				local basic, trick, equip = 0, 0, 0
				for _, id in sgs.list(discards) do
					local c = sgs.Sanguosha:getCard(id)
					if c:isKindOf("BasicCard") then basic = 1
					elseif c:isKindOf("TrickCard") then trick = 1
					else equip = 1 end
				end
				local x = basic + trick + equip
				if x == 3 then
					player:obtainCard(dummy)
				elseif x == 2 then
					room:damage(sgs.DamageStruct(self:objectName(), player, p))
				else
					room:loseMaxHp(p, 1)
				end
			end
		end
	end
}
n_anjiang:addSkill(n_longshi)
n_qinlv = sgs.CreateTriggerSkill{
	name = "n_qinlv",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, target) return target end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Finish then
			for _, p in sgs.list(room:findPlayersBySkillName(self:objectName())) do
				-- 各回复一点体力
				room:recover(player, sgs.RecoverStruct())
				room:recover(p, sgs.RecoverStruct())
				local x = math.floor(player:getMaxHp() / 2)
				-- 若你仍然受伤
				if p:isWounded() then
					room:loseHp(player, x)
				else
					p:drawCards(x)
				end
			end
		end
	end
}
n_anjiang:addSkill(n_qinlv)
n_longlin = sgs.CreateTriggerSkill{
	name = "n_longlin",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart, sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			if data:toCardUse().card:isKindOf("EquipCard") then
				if player:isWounded() then
					room:recover(player, sgs.RecoverStruct())
					player:drawCards(1)
				else
					player:drawCards(3)
				end
			end
			return 
		end
		if player:getPhase() == sgs.Player_Start then
			local noweapon, noarmor, notreasure = true, true, true
			local spade, heart, club, diamond = 0, 0, 0, 0
			for _, c in sgs.list(player:getCards("e")) do
				if c:isKindOf("Weapon") then noweapon = false end
				if c:isKindOf("Armor") then noarmor = false end
				if c:isKindOf("Treasure") then notreasure = false end
				local suit = c:getSuit()
				if suit == sgs.Card_Spade then spade = 1
				elseif suit == sgs.Card_Heart then heart = 1
				elseif suit == sgs.Card_Club then club = 1
				elseif suit == sgs.Card_Diamond then diamond = 1 end
			end
			if noweapon then player:drawCards(2) end
			if noarmor then player:drawCards(2) end
			if notreasure then player:drawCards(2) end
			player:drawCards(spade + heart + club + diamond)
		end
	end
}
n_anjiang:addSkill(n_longlin)
n_jienu = sgs.CreateTriggerSkill{
	name = "n_jienu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TurnedOver, sgs.Damaged, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Play and player:getHp() < player:getLostHp() then
				player:turnOver()
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			if damage.nature == sgs.DamageStruct_Normal then
				room:setPlayerMark(player, "jienudamage", 0)
				room:setPlayerMark(player, "jienurecover", 0)
			elseif damage.nature == sgs.DamageStruct_Thunder then
				room:addPlayerMark(player, "jienurecover", 1)
			elseif damage.nature == sgs.DamageStruct_Fire then
				room:addPlayerMark(player, "jienudamage", 1)
			end
			if (player:getMark("jienudamage") > 4) or (player:getMark("jienurecover") > 4) then
				room:setPlayerMark(player, "jienudamage", 0)
				room:setPlayerMark(player, "jienurecover", 0)
			end
			player:turnOver()
		elseif event == sgs.TurnedOver then
			--if player:faceUp() then return end
			local jienudamage = player:getMark("jienudamage")
			local jienurecover = player:getMark("jienurecover")
			room:recover(player, sgs.RecoverStruct(nil, nil, jienurecover == 0 and 1 or 0))
			for _, p in sgs.list(room:getOtherPlayers(player)) do
				room:damage(sgs.DamageStruct(self:objectName(), player, p, jienudamage == 0 and 2 or 1,
				sgs.DamageStruct_Fire))		
			end
		end
	end
}
n_anjiang:addSkill(n_jienu)
EnterMode["FightLongshen"] = function(player)
	local room = player:getRoom()
	room:setTag("DisableMVP", sgs.QVariant(true))
	room:doLightbox("$WelcomeToFightLongshen", 2500)

	local log = sgs.LogMessage()
	log.type = "#EnterFightLongshen"
	room:sendLog(log)

	local lord = room:getLord()
	n_gainMhp(lord, 1)
	room:recover(lord, sgs.RecoverStruct())
	local him = lord:getNext()
	room:changeHero(him,"n_longshen",true,true)
	room:addPlayerMark(him, "@n_huashen", 6)
	n_longshen_enternextstage(him)
end

sgs.LoadTranslationTable{
	["FightLongshen"] = "新神杀-龙神模式",
	["$WelcomeToFightLongshen"] = "欢迎来到PVE龙神模式",
	["n_longshen"] = "龙神",
	["#n_longshen"] = "龙生九子",
	["designer:n_longshen"] = "新神杀制作组",
	["cv:n_longshen"] = "未知",
	["illustrator:n_longshen"] = "圆子",
	["n_huashen"] = "化神",
	[":n_huashen"] = "锁定技，游戏开始时，你获得6枚“化神”标记。游戏开始时，你移去一枚“化神”标记，"..
	"进入下一形态。当你进入濒死状态时，你弃置手牌区及装备区所有牌，移去一枚“化神”标记，进入下一形态；"..
	"若如此做，其它所有角色依次回复1点体力，摸一张牌，并从三名武将中选择一个，获得其一个技能。",
	["n_longlie"] = "龙烈",
	[":n_longlie"] = "锁定技，你使用的【杀】无法被响应，且游戏人数大于2时，此【杀】伤害+1。",
	["n_chaiyue"] = "豺月",
	[":n_chaiyue"] = "锁定技，你每受到1点普通伤害后，你摸两张牌并将一张牌置于武将牌上，称为【碑】；"..
	"摸牌阶段开始时，你摸X张牌；你的【杀】次数+X（X为【碑】数）",
	["n_bei"] = "碑",
	["n_ruiyan"] = "瑞烟",
	[":n_ruiyan"] = "锁定技，准备阶段或结束阶段开始时，你摸X张牌（X为其它角色数）。",
	["n_lingxi"] = "灵屃",
	[":n_lingxi"] = "锁定技，当你受到伤害后，你摸一张牌并将一张牌置于武将牌上，称为【碑】；"..
	"你的手牌上限+X；摸牌阶段开始时，你额外摸X张牌（X为碑的数目）。",
	["n_suwei"] = "肃威",
	[":n_suwei"] = "锁定技，当你成为一名其它角色使用牌的目标后，你摸一张牌并弃置其一张牌。",
	["n_bibao"] = "必报",
	[":n_bibao"] = "锁定技，你造成或受到伤害时，你回复1点体力且此伤害+1，你摸等同伤害+1张牌。",	-- 太阴间了
	["n_longhou"] = "龙吼",
	[":n_longhou"] = "锁定技，你使用牌指定目标后，目标角色体力上限+1，然后受到其已损失体力值的伤害。",	-- 确定不会弄死自己吗
	["n_longshi"] = "龙识",
	[":n_longshi"] = "锁定技，准备阶段开始时，你依次弃置其它角色各个区域三张牌；若你以此法弃置的卡牌类型之和："..
	"为3，你获得这些牌，为2，你对其造成一点伤害，不大于1，你扣减其一点体力上限。",
	["n_qinlv"] = "琴律",
	[":n_qinlv"] = "锁定技，每名角色结束阶段开始时，你与其各回复一点体力；若你仍受伤且不是你的回合，"..
	"其失去X点体力；若其未受伤，则你摸X张牌。（X为其体力上限一半，向下取整）",
	["n_longlin"] = "龙鳞",
	[":n_longlin"] = "锁定技，准备阶段开始时，若你的装备区：没有武器，你摸两张牌，没有防具，你摸两张牌，没有宝具，"..
	"你摸两张牌；摸牌阶段开始时，你额外摸装备区花色数张牌；当你使用装备牌时，若你已受伤，你回复一点体力并摸一张牌，若你未受伤，你摸三张牌。",
	["n_jienu"] = "介怒",
	[":n_jienu"] = "锁定技，当你翻面后，你回复一点体力并对所有其他角色造成两点火属性伤害；出牌阶段开始时，"..
	"若你的体力值小于已损失的体力值，你翻面；当你受到伤害后，你翻面。当你受到火焰伤害后，你翻面时因此技能造成的火焰伤害-1；"..
	"当你受到雷电伤害后，你翻面时因此技能回复体力值-1；当你受到普通伤害或者再次受到4次某种属性的伤害后，削弱效果消除。",
}


end

n_ModeStart = sgs.CreateTriggerSkill{
	name = "#n_ModeStart",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		--if true then return end
		local room = player:getRoom()
		local modeChoice = {}
		if room:getTag("InCustomMode"):toBool() then return end
		if string.find(room:getMode(),"p") then
		    for _,ch in ipairs(n_commonmodes) do
				table.insert(modeChoice,ch)
			end
		end
		if room:getMode() == "02p" then 
			for _,ch in ipairs(n_02pmodes) do
				table.insert(modeChoice,ch)
			end
		elseif room:getMode() == "08p" then 
			for _,ch in ipairs(n_08pmodes) do
				table.insert(modeChoice,ch)
			end
		elseif room:getMode() == "03p" then 
			for _,ch in ipairs(n_03pmodes) do
				table.insert(modeChoice,ch)
			end
		elseif room:getMode() == "04p" then 
			for _,ch in ipairs(n_04pmodes) do
				table.insert(modeChoice,ch)
			end
		end
		table.insert(modeChoice,"cancel")
		if player:getState() ~= "robot" then
			local choice = room:askForChoice(player,"#n_ModeStart",table.concat(modeChoice,"+"),data)
			--local choice = room:askForChoice(player,"liuyanhack","ly1+ly2+ly3+ly4+ly5+ly6+ly7",data)
			room:setTag("InCustomMode", sgs.QVariant(true))
			EnterMode[choice](player)
		end
	end,
	priority = -10,
}
sgs.LoadTranslationTable {
	["liuyanhack"] = "执行任何一项之后废除你的判定区",
	["ly1"] = "防止摸到红桃基本牌",
	["ly2"] = "起始手牌中加入【丈八蛇矛】",
	["ly3"] = "获得他人手牌时优先获得【丈八蛇矛】和多目标锦囊",
	["ly4"] = "【乐不思蜀】一定天过",
	["ly5"] = "摸到AOE概率增加",
	["ly6"] = "我全都要",
	["ly7"] = "讲武德",
}
n_anjiang:addSkill(n_ModeStart)
local generals = sgs.Sanguosha:getLimitedGeneralNames()
for _,name in ipairs(generals) do
	local general = sgs.Sanguosha:getGeneral(name)
	if general and not general:isTotallyHidden() then
		general:addSkill("#n_ModeStart")
	end
end
	
n_god_start = sgs.General(extension6,"n_god_start","god",2,false,true)
n_meiwang = sgs.CreateTriggerSkill{
	name = "n_meiwang",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, "n_meiwang", data) then
			local count = data:toInt() + 10
			data:setValue(count)
		end
	end
}
n_god_start:addSkill(n_meiwang)
sgs.LoadTranslationTable{
	["n_god_start"] = "初始lua武将",
	["#n_god_start"] = "第一课",
	["designer:n_god_start"] = "Notify",
	["n_meiwang"] = "美王",
	[":n_meiwang"] = "摸牌阶段，你可以多摸10张牌。",
}

n_god_zy = sgs.General(extension6,"n_god_zy","god")
n_geming = sgs.CreateTriggerSkill{
	name = "n_geming" ,
	--frequency = sgs.Skill_Compulsory ,
	events = {sgs.DamageCaused} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local invoke = false
		if damage.to:getMark("@n_ge") < 3 then
			n_CompulsorySkill(room,player,self:objectName())
			invoke = true
        elseif damage.to:getMark("@n_ge") < 6 then invoke = room:askForSkillInvoke(player, self:objectName()) end
        if invoke then
            room:broadcastSkillInvoke(self:objectName())
			damage.to:gainMark("@n_ge", damage.damage)
			player:drawCards(damage.damage)
			return true
		end
		return false
	end
}
n_god_zy:addSkill(n_geming)
n_zhigancard = sgs.CreateSkillCard{
	name = "n_zhigancard",
	target_fixed = false,
	filter = function(self, selected, to_select)
		return (to_select:objectName() ~= sgs.Self:objectName())
	end,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_effect = function(self, effect)
		local from = effect.from
		local to = effect.to
		local room = from:getRoom()
		local ges = to:getMark("@n_ge")
		room:damage(sgs.DamageStruct("n_zhigan", from, to, ges))
		to:loseMark("@n_ge",ges)
	end
}
n_zhigan = sgs.CreateViewAsSkill{
	name = "n_zhigan",
	n = 0,
	view_as = function(self, cards)
		return n_zhigancard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_zhigancard")
	end
}
n_god_zy:addSkill(n_zhigan)
sgs.LoadTranslationTable{
	["n_god_zy"] = "魔鸽",
	["#n_god_zy"] = "止肝鸽",
	["designer:n_god_zy"] = "Notify",
	["cv:n_god_zy"] = "你妹大神",
	["illustrator:n_god_zy"] = "来自网络",
	["~n_god_zy"] = "我的学妹呢...",
	["n_geming"] = "鸽鸣",
	["$n_geming1"] = "咕咕咕",
	["$n_geming2"] = "ng",
	[":n_geming"] = "每当你造成伤害时，若对方的“鸽”标记数量小于3，则其获得等量“鸽”标记，你摸等量牌，然后防止本次伤害；若鸽标记小于6且不小于3，你可以选择是否发动此技能。",
	["@n_ge"] = "鸽",
	["n_zhigan"] = "止肝",
	[":n_zhigan"] = "阶段技。你可以指定一名其他角色，对其造成等于其“鸽”标记数量的伤害，然后其失去等量“鸽”标记。",
	["$n_zhigan1"] = "三年之期还未到，劳资还不能用电脑",
	["$n_zhigan2"] = "君子不望洞，洞必有道",
}

n_god_wch = sgs.General(extension6,"n_god_wch","god",3)
n_shixian = sgs.CreateTriggerSkill{
	name = "n_shixian",
	events = {sgs.HpRecover},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		n_CompulsorySkill(room,player,self:objectName())
		local recover = data:toRecover().recover
		n_gainMhp(player,recover)
		--player:drawCards(recover)
	end
}
n_god_wch:addSkill(n_shixian)
n_jiaoyancard = sgs.CreateSkillCard{
	name = "n_jiaoyancard",
	target_fixed = false,
	filter = function(self, selected, to_select)
		return (to_select:isWounded())
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		for _,p in ipairs(targets) do
			room:recover(p,sgs.RecoverStruct(source),true)
			p:speak("吃饺")
		end
		room:loseMaxHp(source,#targets)
		source:drawCards(#targets)
	end
}
n_jiaoyan = sgs.CreateViewAsSkill{
	name = "n_jiaoyan",
	n = 0,
	view_as = function(self, cards)
		return n_jiaoyancard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#n_jiaoyancard")
	end
}
n_god_wch:addSkill(n_jiaoyan)
n_mojiao = sgs.CreateTriggerSkill{
	name = "n_mojiao",
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		if player:isAlive() then
			local wchs = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:hasSkill(self:objectName()) then
					wchs:append(p)
				end
			end
			while not wchs:isEmpty() do
				local wch = room:askForPlayerChosen(player, wchs, self:objectName(), "$zhongmo_to", true)
				if wch then
					wchs:removeOne(wch)
					
					local log = sgs.LogMessage()
                    log.type = "#InvokeOthersSkill"
                    log.from = player
                    log.to:append(wch)
                    log.arg = self:objectName()
                    room:sendLog(log)
                    room:notifySkillInvoked(wch, self:objectName())
					--room:broadcastSkillInvoke("luoyi")
					
					local judge = sgs.JudgeStruct()
					judge.pattern = ".|black|2~9"
					judge.good = true
					judge.reason = self:objectName()
					judge.who = player
					room:judge(judge)
					if judge:isGood() then
						room:setEmotion(player,"n_mobaiing")
						room:broadcastSkillInvoke(self:objectName())
						recover = sgs.RecoverStruct()
						recover.who = player
						room:recover(wch, recover)
					end
				else
					break
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
n_god_wch:addSkill(n_mojiao)
sgs.LoadTranslationTable{
	["n_god_wch"] = "饺神",
	["#n_god_wch"] = "万人迷",
	["designer:n_god_wch"] = "Notify",
	["illustrator:n_god_wch"] = "来自网络",
	["n_shixian"] = "实馅",
	["$n_shixian"] = "真是美味啊！",
	[":n_shixian"] = "锁定技。你每回复一点体力，加一点体力上限。",
	["n_jiaoyan"] = "饺宴",
	[":n_jiaoyan"] = "阶段技。你可以指定任意名角色，令他们各回复一点体力，然后你失去等量体力上限并摸等量牌。",
	["$n_jiaoyan"] = "一人一口，分而食之！",
	["n_mojiao"] = "膜饺",
	[":n_mojiao"] = "其他角色受到伤害后，可进行一次判定，若判定结果为黑色2~9，则其令你回复一点体力。",
	["$zhongmo_to"] = "请选择膜拜目标！",
	["$n_mojiao"] = "饺神现世，天下莫敌！",
	["~n_god_wch"] = "二十年后..又是一条..饺神！",
}

n_god_xy = sgs.General(extension6,"n_god_xy","god")
n_duanmo = sgs.CreateTriggerSkill{
	name="n_duanmo",
	frequency=sgs.Skill_Frequent,
	events = sgs.FinishJudge,
	can_trigger = function(self,target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local judge = data:toJudge()
		if judge.reason == "supply_shortage" and not judge:isGood() then
			for _,xyg in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if xyg:askForSkillInvoke(self:objectName()) then
					xyg:drawCards(2)
				end
			end
		end
	end,
}
n_god_xy:addSkill(n_duanmo)
sgs.LoadTranslationTable{
	["n_god_xy"] = "神逍遥哥",
	["#n_god_xy"] = "写啊",
	--["cv:n_zeroona"] = "zeroOna",
	["designer:n_god_xy"] = "逍遥自在唯我独尊",
	--["illustrator:n_zeroona"] = "来自网络",
	["n_duanmo"] = "断摸",
	[":n_duanmo"] = "其他角色的兵粮寸断生效后，你可以摸两张牌；你的兵粮寸断生效后，你依然可以摸两张牌。",
}

n_shenzy = sgs.General(extension6, "n_shenzy", "god", 2, true, true)
n_hundun = sgs.CreateTriggerSkill{
	name = "n_hundun",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EnterDying, sgs.QuitDying, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Finish then
				n_CompulsorySkill(player:getRoom(), player, self:objectName())
				player:drawCards(1)
			end
		else
			n_CompulsorySkill(player:getRoom(), player, self:objectName())
			--playConversation(player:getRoom(), player:getGeneralName(), "#n_hundun"..math.random(1,2))
			player:gainAnExtraTurn()
		end
	end
}
n_hundunmaxcard = sgs.CreateMaxCardsSkill{
	name = "#n_hundunmaxcard",
	extra_func = function(self,target)
		if target:hasSkill("n_hundun") then 
			return 2
		end
	end
}
n_shenzy:addSkill(n_hundun)
n_shenzy:addSkill(n_hundunmaxcard)
extension6:insertRelatedSkills("n_hundun", "#n_hundunmaxcard")
sgs.LoadTranslationTable{
	["n_shenzy"] = "神ZY",
	["&n_shenzy"] = "神ＺＹ",
	["#n_shenzy"] = "脑洞策划",
	["designer:n_shenzy"] = "Notify",
	["n_hundun"] = "混沌",
	[":n_hundun"] = "锁定技。你进入或脱离濒死状态时，立刻执行一个额外的回合；结束阶段开始时，你摸一张牌。你的手牌上限+2。",
	["#n_hundun1"] = "凡王之血，必以剑封。",
	["#n_hundun2"] = "正义？好一个冠冕堂皇之词！",
}

n_brick = sgs.CreateBasicCard{
	name = "n_brick",
	class_name = "NBrick",
	target_fixed = false,
	subtype = "attack_card",
	filter = function(self, selected, to_select, player)
		return (#selected <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, sgs.Self, self)) and (to_select:objectName() ~= player:objectName())
	end,
	about_to_use = function(self,room,card_use)
		local use, data = card_use, sgs.QVariant()
		data:setValue(use)
		local thread = room:getThread()
		thread:trigger(sgs.PreCardUsed, room, use.from, data)
		use = data:toCardUse()
		local log = sgs.LogMessage()
		log.from = use.from
		log.to = use.to
		log.type = "#UseCard"
		log.card_str = use.card:toString()
		room:sendLog(log)
		room:setEmotion(use.from, "n_brick")
		if not thread:trigger(sgs.CardUsed, room, use.from, data) then
			use = data:toCardUse()
			if not use.to:isEmpty() then
				room:sortByActionOrder(use.to)
				for _, to in sgs.qlist(use.to) do
					if to:isAlive() then
						if room:getCardOwner(self:getId()) then
							room:obtainCard(to, self, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, 
								room:getCardOwner(self:getId()):objectName(), to:objectName(), "n_brick", ""))
						else
							room:obtainCard(to, self)
						end
						room:damage(sgs.DamageStruct(self, use.from, to))
						thread:delay()
						--break
					end
				end
			end
		else
			for _,p in sgs.qlist(data:toCardUse().to) do
				room:setEmotion(p,"skill_nullify")
			end
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW, use.from:objectName(), nil, "n_brick", nil)
			room:moveCardTo(self, use.from, nil, sgs.Player_DiscardPile, reason, true)
		end
		thread:trigger(sgs.CardFinished, room, use.from, data)
	end
}
sgs.LoadTranslationTable{
	["n_brick"] = "砖",
	[":n_brick"] = "基本牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名其他角色<br /><b>效果</b>：交给其此牌，对目标角色造成1点伤害。",
}
for i = 0,1 do
	local cd = n_brick:clone()
	cd:setSuit(i*2)
	cd:setNumber(6)
	cd:setParent(extension7)
end

return {extension,extension2,extension3,extension4,extension5,extension6,extension7,extension8}

