n_shenshou_skill = {}
n_shenshou_skill.name = "n_shenshou"
table.insert(sgs.ai_skills, n_shenshou_skill)
n_shenshou_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#n_shenshouCard") then
		local parse = sgs.Card_Parse("#n_shenshouCard:.:")
		assert (parse ~= nil)
		return parse
	end
	return nil
end
sgs.ai_skill_use_func["#n_shenshouCard"] = function(card, use, self)
	self:sort(self.enemies, "handcard")
	for _,enemy in ipairs(self.enemies) do
		if not enemy:isNude() then
		use.card = card
		if use.to then use.to:append(enemy) end
		return
		end
	end
end

sgs.ai_use_priority.n_shenshouCard = 8.3
sgs.ai_skill_choice["n_shenshou"] = "equip"

sgs.ai_skill_cardask["#ShenshouGive"] = function(self, data)
	local card = self:getLijianCard()
	if not card then
		local cards = self.player:getCards("he")
		cards = sgs.QList2Table(cards)
		self:sortByKeepValue(cards)
		card = cards[1]:getEffectiveId()
	end
	return card
end

sgs.ai_skill_cardask["#moucaigive"] = function(self, data)
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	if #cards == 0 then return "." end
	card = cards[1]:getEffectiveId()
	return card
end

sgs.ai_chat_func[sgs.CardFinished].n_shenshou = function(self, player, data)
    local use = data:toCardUse()
    if use.card:objectName()=="n_shenshouCard" then
        local to = use.to:first()
        local to_name = to:getGeneral():getBriefName()
        local chat = {
            "膜拜"..to_name.." 求告知",
            to_name.."救救我",
            to_name.."，这个能写吗",
        }
        if math.random() < 0.3 then
            self.player:speak(chat[math.random(1, #chat)])
        end
    end
end

----------------------------------
n_qiuwu_skill = {}
n_qiuwu_skill.name = "n_qiuwu"
table.insert(sgs.ai_skills, n_qiuwu_skill)
n_qiuwu_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#n_qiuwuCard") then
		local parse = sgs.Card_Parse("#n_qiuwuCard:.:")
		assert (parse ~= nil)
		return parse
	end
	return nil
end
sgs.ai_skill_use_func["#n_qiuwuCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_priority.n_qiuwuCard = 1.2

sgs.ai_skill_discard.n_qiuwu = function(self, discard_num, min_num, optional, include_equip)
	local to_discard = {}
	local can_disc = {}
	local thecount = self.room:getTag("n_qiuwuCount"):toInt()
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	cards = sgs.reverse(cards)
	for _,card in ipairs(cards) do
		if card:getNumber() < thecount then
			table.insert(can_disc,card)
		end
	end
	if #can_disc == 0 then return {} end
	table.insert(to_discard, can_disc[1]:getEffectiveId())
	return to_discard
end

sgs.ai_skill_choice["n_qiuwu"] = function(self, choices, data)
	local target = self.room:getCurrent()
	if not self:isFriend(target) then
		return "killcxk"
	else
		return "cxkm1"
	end
end
----------------------------------
sgs.ai_skill_invoke.n_zhuangben = function(self, data)
	local player = self.player
	return not player:isAllNude()
end

sgs.ai_skill_discard.n_zhuangben = function(self, discard_num, min_num, optional, include_equip)
	local to_discard = {}
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	cards = sgs.reverse(cards)
	table.insert(to_discard, cards[1]:getEffectiveId())
	return to_discard
end

n_shenjiao_skill = {}
n_shenjiao_skill.name = "n_shenjiao"
table.insert(sgs.ai_skills, n_shenjiao_skill)
n_shenjiao_skill.getTurnUseCard = function(self)
	if self.player:getMark("@n_jiao") > 0 and self.player:getHandcardNum() < self.player:getHp() then
		local parse = sgs.Card_Parse("#n_shenjiaoCard:.:")
		assert (parse ~= nil)
		return parse
	end
	return nil
end
sgs.ai_skill_use_func["#n_shenjiaoCard"] = function(card,use,self)
	use.card = card
end

sgs.ai_use_priority.n_shenjiaoCard = 5.7

sgs.ai_skill_invoke.n_shenjiao = function(self, data)
	local dying = data:toDying()
	return self:isFriend(dying.who)
end

----------------------------------

n_shouhuo_skill = {}
n_shouhuo_skill.name = "n_shouhuo"
table.insert(sgs.ai_skills, n_shouhuo_skill)
n_shouhuo_skill.getTurnUseCard = function(self)
	--self.player:speak("Preparing for shouhuo...")
	local thenred = {}
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)

	for _,card in ipairs(cards) do
		if card:isRed() then 
			table.insert(thenred, card)
		end
	end
	if #thenred == 0 then return nil end
	self:sortByKeepValue(thenred,true)
	
	for _,cd in ipairs(thenred) do
		if cd:isKindOf("NDTrick") then
			local card_str = "#n_shouhuoCard:"..thenred:getId()..":"
			return sgs.Card_Parse(card_str)
		end
	end
	for _,crd in ipairs(thenred) do
		if not crd:isKindOf("Peach") then
			local card_str = "#n_shouhuoCard:"..crd:getId()..":"
			return sgs.Card_Parse(card_str)
		end
	end
	return nil
end
sgs.ai_skill_use_func["#n_shouhuoCard"] = function(card, use, self)
	local enemies = self.enemies
	local truetarget = {}
	for _,enemy in ipairs(enemies) do
		if not enemy:hasSkill("wumou") then
			table.insert(truetarget,enemy)
		end
	end
	if #truetarget == 0 then return end
	self:sort(truetarget, "handcard" ,true)
	use.card = card
	if use.to then use.to:append(truetarget[1]) end
	return
end

sgs.ai_use_priority.n_shouhuoCard = 8
sgs.ai_card_intention.n_shouhuoCard = 80

sgs.ai_cardneed.n_shouhuo = function(to, card)
	return card:isRed()
end

sgs.ai_skill_invoke.n_jieye = function(self, data)
	local target = self.room:getCurrent()
	local eqp = self:hasSkills(sgs.lose_equip_skill, target)
	local emy = not self:isFriend(target)
	return (not emy and eqp) or (not eqp and emy)
end

sgs.ai_skill_invoke.n_kuailiu = function(self, data)
	local room = self.room
	local all = room:getAllPlayers()
	for _,p in sgs.qlist(all) do
		if p:getMark("@n_confused") > 0 then
			return true
		end
	end
	if self:getCardsNum("Jink") < 1 then return true end
	return false
end

--------------------------------
sgs.ai_skill_invoke.n_liejie = function(self, data)
	for _,cd in sgs.qlist(self.player:getHandcards()) do
		if cd:isKindOf("Peach") then return true end
	end
	return false
end
---------------------------------
n_qieche_skill = {}
n_qieche_skill.name = "n_qieche"
table.insert(sgs.ai_skills, n_qieche_skill)
n_qieche_skill.getTurnUseCard = function(self)
	local player = self.player
	if not player:hasUsed("#n_qiecheCard")
	and player:getHandcardNum() < player:getMaxHp() then
		local parse = sgs.Card_Parse("#n_qiecheCard:.:")
		assert (parse ~= nil)
		return parse
	end
	return nil
end
sgs.ai_skill_use_func["#n_qiecheCard"] = function(card, use, self)
	local enemies = self.enemies
	local truetarget = {}
	for _,enemy in ipairs(enemies) do
		if enemy:getHandcardNum() > self.player:getHandcardNum() then
			table.insert(truetarget,enemy)
		end
	end
	if #truetarget == 0 then return end
	self:sort(truetarget, "handcard" ,true)
	use.card = card
	if use.to then use.to:append(truetarget[1]) end
	return
end

sgs.ai_use_priority.n_qiecheCard = -1
sgs.ai_card_intention.n_qiecheCard = 80
------------------------------

sgs.ai_skill_cardask["#quanjiaDisCard"] = function(self, data)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	local blackcard = {}
	for _,cd in ipairs(cards) do
		if cd:isBlack() then 
			table.insert(blackcard, cd)
		end
	end
	self:sortByKeepValue(blackcard)
	local use = data:toCardUse()
	if self:isEnemy(use.from) then return blackcard[1] else return "." end
end

n_liyou_skill = {}
n_liyou_skill.name = "n_liyou"
table.insert(sgs.ai_skills, n_liyou_skill)
n_liyou_skill.getTurnUseCard = function(self)
	local player = self.player
	if not player:hasUsed("#n_liyou") then
		local parse = sgs.Card_Parse("#n_liyou:.:")
		assert (parse ~= nil)
		return parse
	end
	return nil
end
sgs.ai_skill_use_func["#n_liyou"] = function(card, use, self)
	local enemies = self.enemies
	local truetarget = {}
	for _,enemy in ipairs(enemies) do
		if not enemy:isKongcheng() then
			table.insert(truetarget,enemy)
		end
	end
	if #truetarget < 2 then return end
	self:sort(truetarget, "handcard")
	use.card = card
	if use.to then
		use.to:append(truetarget[1])
		use.to:append(truetarget[2])
	end
	return
end

sgs.ai_use_priority.n_liyouCard = 5
sgs.ai_card_intention.n_liyouCard = 80

sgs.ai_skill_cardask["#liyouGive"] = function(self, data)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	local redcard = {}
	for _,cd in ipairs(cards) do
		if cd:isRed() and not (cd:isKindOf("Peach") or cd:isKindOf("Jink"))then 
			table.insert(redcard, cd)
		end
	end
	if #redcard == 0 then return "." end
	self:sortByKeepValue(redcard)
	return redcard[1]
end
------------------------------
sgs.ai_skill_invoke.n_jingyan = function(self, data)
	local room = self.room
	local player = self.player
	local handcards = sgs.QList2Table(player:getCards("h"))
	if #handcards == 0 then return false end
	local useful = {}
	for _,cd in ipairs(handcards) do
		if not cd:isKindOf("Jink") or cd:isKindOf("NDTrick")
		or cd:isKindOf("EquipCard") then 
			return true
		end
	end
	return false
end

sgs.ai_skill_invoke.n_tihai = function(self, data)
	return true
end
----------------------------------
sgs.ai_skill_invoke.n_jiyan = function(self, data)
	return true
end
sgs.ai_skill_playerchosen["@jiyanTarget"] = function(self, targets)
	return targets:first()
end
sgs.ai_skill_cardask["#jiyandisc"] = function(self, data)
	local suit = data:toInt()
	local handcards = sgs.QList2Table(self.player:getCards("h"))
	if #handcards == 0 then return "." end
	local useful = {}
	for _,cd in ipairs(handcards) do
		if cd:getSuit() == suit then 
			table.insert(useful,cd)
		end
	end
	if #handcards == 0 then return "." else return useful[1] end
end

n_xiameng_skill={}
n_xiameng_skill.name="n_xiameng"
table.insert(sgs.ai_skills,n_xiameng_skill)
n_xiameng_skill.getTurnUseCard = function(self)
	if self.player:usedTimes("#n_xiamengCard") >= self.player:getMaxHp() * 2 then return end
	return sgs.Card_Parse("#n_xiamengCard:.:")
end
sgs.ai_skill_use_func["#n_xiamengCard"]=function(card,use,self)
	use.card = card
end
sgs.ai_skill_suit["n_xiameng"] = function(self)
	return math.random(0, 3)
end

sgs.ai_use_priority.n_xiamengCard = -1

sgs.ai_skill_invoke.n_miaoshaskill = function(self,data)
	local damage = data:toDamage()
	if not self:isEnemy(damage.to) then return false 
	else return true end
	return false
end

sgs.ai_skill_invoke.n_shuaibei = function(self,data)
	return true
end

sgs.ai_skill_playerchosen["n_shuaibei"] = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, target in ipairs(targets) do
		if self:isEnemy(target) and target:isAlive() then
			return target
		end
	end
	return nil
end
----------------------------------------
local n_juanlao_skill = {}
n_juanlao_skill.name = "n_juanlao"
table.insert(sgs.ai_skills, n_juanlao_skill)
n_juanlao_skill.getTurnUseCard = function(self)
	if self.player:getMark("n_juanlaoused") == 0 and self.player:getPhase() == sgs.Player_Play and self.player:getMark("n_juanlao") > 0 then
	local card_str = ("%s:n_juanlao[no_suit:0]=."):format(sgs.Sanguosha:getCard(self.player:getMark("n_juanlao")):objectName())
	local archeryattack = sgs.Card_Parse(card_str)
	if archeryattack:isKindOf("IronChain") then return end
	assert(archeryattack)
	return archeryattack
	end
end

sgs.ai_skill_playerchosen["n_youhun"] = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, target in ipairs(targets) do
		if self:isEnemy(target) and target:isAlive() then
			return target
		end
	end
	return nil
end

sgs.ai_skill_playerchosen["n_mojiao"] = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, target in ipairs(targets) do
		if self:isFriend(target) and target:isAlive() then
			if target:isWounded() then
				return target
			end
		end
	end
	return nil
end

sgs.ai_playerchosen_intention["n_mojiao"] = -40

local n_jiaoyan_skill = {}
n_jiaoyan_skill.name = "n_jiaoyan"
table.insert(sgs.ai_skills, n_jiaoyan_skill)
n_jiaoyan_skill.getTurnUseCard = function(self)
	local player = self.player
	--local friends = self.friends
	if not player:hasUsed("#n_jiaoyancard") and player:getMaxHp() > 3 then
		local parse = sgs.Card_Parse("#n_jiaoyancard:.:")
		assert (parse ~= nil)
		return parse
	end
	return nil
end
function tbl_contains(tbl,object)
	if #tbl == 0 or type(tbl[1]) ~= type(object) then return false end
	for _, e in ipairs(tbl) do
		if e == object then return true end
	end
	return false
end

sgs.ai_skill_use_func["#n_jiaoyancard"] = function(card, use, self)
	local friends = self.friends
	local truetarget = {}
	for _,friend in ipairs(friends) do
		if friend:isWounded() then
			table.insert(truetarget,friend)
		end
	end
	if #truetarget == 0 then return end
	self:sort(truetarget, "hp")
	local gives = math.min(#truetarget,self.player:getMaxHp() - 3)
	use.card = card
	if use.to then
		for i = 1,gives do
			use.to:append(truetarget[i])
		end
	end
	return
end

-------------------------------------

local n_zhigan_skill = {}
n_zhigan_skill.name = "n_zhigan"
table.insert(sgs.ai_skills, n_zhigan_skill)
n_zhigan_skill.getTurnUseCard = function(self)
	local player = self.player
	--local friends = self.friends
	if not player:hasUsed("#n_zhigancard") then
		local parse = sgs.Card_Parse("#n_zhigancard:.:")
		assert (parse ~= nil)
		return parse
	end
	return nil
end
sgs.ai_skill_use_func["#n_zhigancard"] = function(card, use, self)
	self:sort(self.enemies, "hp", false)
	use.card = card
	if use.to then
		use.to:append(self.enemies[1])
	end
	return
end
--------------------------------------
sgs.ai_skill_cardask["njiyi"] = function(self, data)
	local handcards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByUseValue(handcards,true)
	return handcards[1]
end
--------------------------------------
n_yuyin_skill = {}
n_yuyin_skill.name = "n_yuyin"
table.insert(sgs.ai_skills, n_yuyin_skill)
n_yuyin_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#n_yuyincard") or self.player:isKongcheng() then return end
	
	--if self:shouldUseRende() then
		local cards = sgs.QList2Table(self.player:getCards("h"))
		self:sortByKeepValue(cards)
		local card_str = "#n_yuyincard:"..cards[1]:getId()..":"
		return sgs.Card_Parse(card_str)
	--end
end
sgs.ai_skill_use_func["#n_yuyincard"] = function(card, use, self)
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards, true)

	self:sort(self.friends, "handcard_defense")
	use.card = card
	if use.to then use.to:append(self.friends[1]) end
	return
end
sgs.ai_skill_use["@@n_yuyin"] = function(self, prompt)
	self:sort(self.enemies, "handcard_defense",true)
	local handcards = self.player:getCards("h")
	handcards = sgs.QList2Table(handcards)
	self:sortByKeepValue(handcards)
	local card = handcards[1] 
	local target = self.enemies[1]
	local card_str = string.format("#n_yuyincard:%d:->%s", card:getId(), target:objectName())
	return card_str
end

n_yindao_skill = {}
n_yindao_skill.name = "n_yindao"
table.insert(sgs.ai_skills, n_yindao_skill)
n_yindao_skill.getTurnUseCard = function(self)
	if (self.player:hasUsed("#n_yindaocard")) then return end
	return sgs.Card_Parse("#n_yindaocard:.:")
end
sgs.ai_skill_use_func["#n_yindaocard"] = function(card, use, self)
	local truetarget = {}
	local target = nil
	for _,p in ipairs(self.friends) do
		if p:isWounded() and not p:isKongcheng() then
			table.insert(truetarget,p)
		end
	end
	if self.player:isWounded() and not self.player:isKongcheng() then
		local handcards = sgs.QList2Table(self.player:getCards("h"))
		for _,cd in ipairs(handcards) do
			if cd:getSuit() == sgs.Card_Diamond then
				target = self.player
			end
		end
	end
	if target == nil and #truetarget ~= 0 then
		target = truetarget[1]
	else 
		return
	end
	use.card = card
	if use.to then use.to:append(target) end
	return
end
sgs.ai_cardshow["n_yindao"] = function(self, requestor)
	local cards = self.player:getCards("h")
	for _,card in sgs.qlist(cards) do
		if card:getSuit() == sgs.Card_Diamond then
			return card
		end
	end
	return cards:first()
end
--------------------------------
n_dafan_buy_skill = {}
n_dafan_buy_skill.name = "n_dafan_buy"
table.insert(sgs.ai_skills, n_dafan_buy_skill)
n_dafan_buy_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#n_dafan_buycard") or self.player:getHandcardNum() < 3 or self.player:getLostHp() <= 1 then return end
	
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByKeepValue(cards)
	local card_str = "#n_dafan_buycard:"..cards[1]:getId().."+"..cards[2]:getId().."+"..cards[3]:getId()..":"
	return sgs.Card_Parse(card_str)
	--end
end
sgs.ai_skill_use_func["#n_dafan_buycard"] = function(card, use, self)
	local target = nil
	for _,p in sgs.qlist(self.room:getAllPlayers()) do
		if p:getPile("n_food") and not p:getPile("n_food"):isEmpty() then
			target = p
			break
		end
	end
	
	if target == nil then return end
	use.card = card
	if use.to then use.to:append(target) end
	return
end
sgs.ai_use_priority.n_dafan_buycard = 9.8
-----------------------------
sgs.ai_skill_cardask["#n_fuduuse"] = function(self, data)
	local use = data:toCardUse()
	local target = use.to:at(0)
	if use.to:at(0):objectName() == self.player:objectName() then target = use.from end
	local card_name = use.card:objectName()
	local good = card_name == "ex_nihilo" or card_name == "peach" or use.card:objectName() == "analeptic"
	if (good and self:isFriend(target)) or (not good and self:isEnemy(target)) then
		local handcards = sgs.QList2Table(self.player:getCards("h"))
		local thenred = {}
		for _,card in ipairs(handcards) do
			if card:isRed() then 
				table.insert(thenred, card)
			end
		end
		if #thenred == 0 then
			self:sortByKeepValue(handcards)
			return handcards[1]
			--return "."
		else
			self:sortByKeepValue(thenred)
			return thenred[1]
		end
	end
	return "."
end

n_laofang_skill = {}
n_laofang_skill.name = "n_laofang"
table.insert(sgs.ai_skills, n_laofang_skill)
n_laofang_skill.getTurnUseCard = function(self)
	--if self:getOverflow() <= 0 then return end
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByUseValue(cards)
	--self.player:speak("Get Laofangcard");
	local black_cards = {}
	for _, cd in ipairs(cards) do
		--if self:getUseValue(cards[index]) >= 8 then break end
		if cd:isBlack() then
			if #black_cards < 2 then
				table.insert(black_cards, cd:getId())
				table.removeOne(cards, cd)
			end
			if #black_cards >=2 then break end
		end
	end
	if #black_cards == 2 then return sgs.Card_Parse("#n_laofangcard:" .. table.concat(black_cards, "+")..":") end
end

sgs.ai_skill_use_func["#n_laofangcard"] = function(card, use, self)
	local enemies = self.enemies
	local truetarget = {}
	for _,enemy in ipairs(enemies) do
		if enemy:isWounded() then
			table.insert(truetarget,enemy)
		end
	end
	if #truetarget == 0 then return end
	self:sort(truetarget, "hp")
	use.card = card
	if use.to then
		use.to:append(truetarget[1])
	end
	return
end

sgs.ai_use_priority.n_laofangcard =11

sgs.ai_skill_invoke.n_tuoyan = function(self, data)
	local who = data:toDamage().from
	if self:isFriend(who) then return true 
	else return self:isWeak() or not self:isWeak(who) end
end

n_chaoxi_skill = {}
n_chaoxi_skill.name = "n_chaoxi"
table.insert(sgs.ai_skills, n_chaoxi_skill)
n_chaoxi_skill.getTurnUseCard = function(self)
	if (self.player:getMark("chaoxiusd")<3) and self.player:getPhase() == sgs.Player_Play and self.player:getMark("chaoxienable") > 0 and not self.player:isKongcheng() then
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local red_card = cards[1]
	local suit = red_card:getSuitString()
	local number = red_card:getNumberString()
	local card_id = red_card:getEffectiveId()
	local card_str = ("%s:n_chaoxi[%s:%s]=%d"):format(sgs.Sanguosha:getCard(self.player:getMark("chaoxiid")):objectName(),suit,number,card_id)
	local archeryattack = sgs.Card_Parse(card_str)
	assert(archeryattack)
	return archeryattack
	end
end
sgs.ai_view_as.n_chaoxi = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if player:getMark("chaoxiusd")<3 and player:getMark("chaoxienable") > 0 then
		return ("%s:n_chaoxi[%s:%s]=%d"):format(sgs.Sanguosha:getCard(player:getMark("chaoxiid")):objectName(),suit,number,card_id)
	end
end

--=========================
sgs.ai_skill_invoke.n_kaigua = true
sgs.ai_skill_invoke.n_bianjie = function(self, data)
	return self:isEnemy(self.room:getCurrent())
end
--=========================

function SmartAI:useCardNBrick(n_brick, use)
	self:sort(self.enemies, "hp")


	local targets_num = math.min(#self.enemies,1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, n_brick))
	if use.isDummy and use.extra_target then targets_num = targets_num + use.extra_target end
	if targets_num == 0 then return end
	use.card = n_brick
	for i = 1, #self.enemies, 1 do
		if use.to and not (use.to:length() > 0) then
			use.to:append(self.enemies[i])
			if use.to:length() == targets_num then return end
		end
	end
end

sgs.dynamic_value.damage_card.NBrick = true

sgs.ai_use_value.NBrick = 4.5
sgs.ai_keep_value.NBrick = 3.6
sgs.ai_use_priority.NBrick = 2.6

sgs.ai_skill_invoke.n_dianliao = function(self, data)
	return self:isEnemy(data:toDamage().to)
end

sgs.ai_skill_invoke.n_juankuan = function(self, data)
	local diaochan = self.room:findPlayerBySkillName("lihun")
	local lihun_eff = (diaochan and self:isEnemy(diaochan))
	if lihun_eff then return false
	else
		return self.room:getOtherPlayers(self.player):length()>3
	end
end
sgs.ai_skill_invoke.n_qiantao = function(self, data)
	if not self.player:faceUp() then return true end
	local x=0
	for _,p in sgs.qlist(self.room:getAllPlayers()) do
		if p:getMark("n_juankuantar")>0 then
			x=x+1
		end
	end
	local fact1 = x>2
	local fact2 = self:getOverflow()>2
	return (fact1 or fact2)
end

n_juneng_skill = {}
n_juneng_skill.name = "n_juneng"
table.insert(sgs.ai_skills, n_juneng_skill)
n_juneng_skill.getTurnUseCard = function(self)
	if self.player:getMark("n_junengenable")>0 then return end
	local cards = sgs.QList2Table(self.player:getCards("h"))
	self:sortByUseValue(cards)
	if cards[1]:objectName() == "ex_nihilo" or cards[1]:isKindOf("AOE") then
		return sgs.Card_Parse("#n_junengcard:"..cards[1]:getId()..":")
	end
	return 
end

sgs.ai_skill_use_func["#n_junengcard"] = function(card, use, self)
	use.card = card
	return
end

sgs.ai_use_priority.n_junengcard =15

sgs.ai_skill_invoke.n_zhenli = function(self,data)
	return self:isFriend(data:toPlayer())
end

n_aoqiu_skill = {}
n_aoqiu_skill.name = "n_aoqiu"
table.insert(sgs.ai_skills, n_aoqiu_skill)
n_aoqiu_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#n_aoqiucard") then
		local parse = sgs.Card_Parse("#n_aoqiucard:.:")
		assert (parse ~= nil)
		return parse
	end
	return nil
end
sgs.ai_skill_use_func["#n_aoqiucard"] = function(card, use, self)
	local t = {}
	for _,p in ipairs(self.enemies) do
		if not p:isKongcheng() then table.insert(t,p) end
	end
	if #t == 0 then return end
	self:sort(t, "handcard")
	for _,enemy in ipairs(t) do
		use.card = card
		if use.to then use.to:append(enemy) end
		return
	end
end

sgs.ai_use_priority.n_aoqiucard = 8.3

sgs.ai_skill_invoke.n_baobi = function(self,data)
	return self:isFriend(data:toDamage().to)
end

sgs.ai_skill_invoke.n_huyin = function(self,data)
	return self:isFriend(data:toDamage().to)
end

n_shenwei_skill = {}
n_shenwei_skill.name = "n_shenwei"
table.insert(sgs.ai_skills, n_shenwei_skill)
n_shenwei_skill.getTurnUseCard = function(self)
	if self.player:getMark("@n_force") <= 0 then return end
	local good = 0
	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if self:isWeak(player) then
			if not self:isFriend(player) then
				good = good + 1
			end
		end
	end
	if good >= 2 then return sgs.Card_Parse("#n_shenweicard:.:") end
end

sgs.ai_skill_use_func["#n_shenweicard"] = function(card,use,self)
	use.card = card
end

n_biancheng_skill = {}
n_biancheng_skill.name = "n_biancheng"
table.insert(sgs.ai_skills, n_biancheng_skill)
n_biancheng_skill.getTurnUseCard = function(self)
	local card = sgs.Sanguosha:getCard(self.room:getDrawPile():first())
	card:setSkillName("n_biancheng")
	return card
end

----sgs.ai_view_as.n_biancheng = function(card, player, card_place)
--	return self.room:getDrawPile():first():getId()
--end

n_tiaoshi_skill = {}
n_tiaoshi_skill.name = "n_tiaoshi"
table.insert(sgs.ai_skills, n_tiaoshi_skill)
n_tiaoshi_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#n_tiaoshicard") then return sgs.Card_Parse("#n_tiaoshicard:.:") end
end

sgs.ai_skill_use_func["#n_tiaoshicard"] = function(card,use,self)
	use.card = card
end

n_choiceValue = {}
function SmartAI:n_getValue(str)
    local v = n_choiceValue[str]
    if type(v) == "number" then
        return v
    elseif type(v) == "function" then
        return v(self)
    else
        return 0
    end
end
n_choiceValue["draw1card"] = 1
n_choiceValue["draw2card"] = 2
n_choiceValue["rcv1hp"] = 2
n_choiceValue["dis1cd"] = -1
n_choiceValue["dis2cd"] = -2
n_choiceValue["lose1hp"] = function(self)
    local value = -2
    if self.player:hasSkill("zhaxiang") then value = value+3 end
    return value
end
n_choiceValue["dmg1hp"] = function(self)
    local value = -2
    local needDamaged = false
    if self.player:getHp() > getBestHp(self.player) then needDamaged = true end
    if not needDamaged and not sgs.isGoodTarget(self.player, self.friends, self) then needDamaged = true end
    if not needDamaged then
        for _, skill in sgs.qlist(self.player:getVisibleSkillList(true)) do
            local callback = sgs.ai_need_damaged[skill:objectName()]
            if type(callback) == "function" and callback(self, nil, self.player) then
                needDamaged = true
                break
            end
        end
    end
    if needDamaged then
        value = 0     
    end
    return value
end
n_choiceValue["trnovr"] = function(self)
    if self.player:faceUp() then
        return -3
    else
        return 3
    end
end
n_choiceValue["chaind"] = -0.5

sgs.ai_skill_choice["popupwar"] = function(self, choices, data)
	local choice_list = choices:split("+")
	local function compare_func(str1, str2)
	    return self:n_getValue(str1) > self:n_getValue(str2)
	end
	table.sort(choice_list,compare_func)
	return choice_list[1]
end

n_qunzhi_skill = {}
n_qunzhi_skill.name = "n_qunzhi"
table.insert(sgs.ai_skills,n_qunzhi_skill)
n_qunzhi_skill.getTurnUseCard = function(self)
    local source,room = self.player,self.room
	if source:hasFlag("ai_qunzhiused") then return end
    if source:getHp() > source:getHandcardNum() then return end
    local choices = {}
	for _, name in ipairs(trick_patterns) do
		local poi = sgs.Sanguosha:cloneCard(name, sgs.Card_NoSuit, -1)
		if poi:isAvailable(source) and source:getMark("n_qunzhi"..name) == 0 and not table.contains(sgs.Sanguosha:getBanPackages(), poi:getPackage()) then
			table.insert(choices, name)
		end
	end
	local toUse = {}
	local handcards = sgs.QList2Table(source:getCards("h"))
	self:sortByKeepValue(handcards)
	for i=1,math.ceil(#handcards/2) do
	    table.insert(toUse,handcards[i]:getId())
	    if self:isValuableCard(handcards[i]) then return end
	end
	for _,str in ipairs(choices) do
	    local card_str = ("%s:n_qunzhi[no_suit:0]=%s"):format(str,table.concat(toUse,"+"))
		
	    local card = sgs.Card_Parse(card_str)
	    local use = sgs.CardUseStruct()
	    self:useTrickCard(card, use)
		if use.card then
			if card:canRecast() and use.to:isEmpty() then continue end
			source:setFlags("ai_qunzhiused")
			return use.card
		end
	    if source:getCards("h"):length() ~= #handcards then
	        break
	    end
	end
	return
end

sgs.ai_skill_invoke.n_daotu = function(self,data)
	local use = data:toCardUse()
	local fact1 = self:isFriend(use.from)
	local fact2 = use.card:isKindOf("EquipCard")
	local fact3 = use.card:isKindOf("DelayedTrick")
	return (not (fact1 and (fact2 or fact3)))
end

local n_xiabai_skill = {}
n_xiabai_skill.name = "n_xiabai"
table.insert(sgs.ai_skills, n_xiabai_skill)
n_xiabai_skill.getTurnUseCard = function(self)
    if self.player:hasUsed("#n_xiabaicard") or self.player:isKongcheng() then return end   
    return sgs.Card_Parse("#n_xiabaicard:.:")    
end

sgs.ai_skill_use_func["#n_xiabaicard"] = function(card, use, self)
    local enemies = {}
    for _,p in ipairs(self.enemies) do
        if not p:isKongcheng() then
            table.insert(enemies,p)
        end
    end 
    if #enemies == 0 then return end
    self:sort(enemies,"defense")
    use.card = card
    if use.to then
        use.to:append(enemies[1])
    end
    return
end

sgs.ai_skill_invoke["n_xiabai"] = function(self,data)
    return true
end

sgs.ai_skill_playerchosen.n_discard = function(self,targets)
	return self:findPlayerToDiscard("hej",false,true,targets)
end
sgs.ai_skill_playerchosen.nfsq_discard = sgs.ai_skill_playerchosen.n_discard
sgs.ai_skill_playerchosen.nfsq_slash = sgs.ai_skill_playerchosen.zero_card_as_slash
sgs.ai_skill_invoke.n_banyun = function(self,data)
    return true
end
sgs.ai_skill_playerchosen.n_banyun = function(self, targets)
    local first, second
    targets = sgs.QList2Table(targets)
    self:sort(targets,"defense")
    for _, friend in ipairs(targets) do
        if self:isFriend(friend) and friend:isAlive() then
            if isLord(friend) then return friend end
            if not (friend:hasSkill("zhiji") and friend:getMark("zhiji") == 0 and not self:isWeak(friend) and friend:getPhase() == sgs.Player_NotActive) then
                if sgs.evaluatePlayerRole(friend) == "renegade" then second = friend
                elseif sgs.evaluatePlayerRole(friend) ~= "renegade" and not first then first = friend
                end
            end
        end
    end
    return first or second
end

n_xicun_skill = { name = "n_xicun"}
table.insert(sgs.ai_skills,n_xicun_skill)
n_xicun_skill.getTurnUseCard = function(self)
    local source,room = self.player,self.room
    local handcards = sgs.QList2Table(source:getCards("he"))
    self:sortByKeepValue(handcards)
    local x = (source:usedTimes("Snatch") == 0) and 1 or 2
    if x == 0 then return sgs.Card_Parse("snatch:n_xicun[no_suit:0]=.") end
    if #handcards < x then return end
    local toUse = {}
    for i=1,x do
        table.insert(toUse,handcards[i]:getId())
        if self:isValuableCard(handcards[i]) then return end
    end
    local card_str = ("snatch:n_xicun[no_suit:0]=%s"):format(table.concat(toUse,"+"))
        
    local card = sgs.Card_Parse(card_str)
    return card
end

sgs.ai_skill_invoke.n_jiding = function(self, data)
    return self:isEnemy(data:toPlayer())
end

sgs.ai_skill_invoke.n_kangkang = function(self, data)
    return self:isEnemy(data:toPlayer())
end

n_yaoqing_skill = {}
n_yaoqing_skill.name = "n_yaoqing"
table.insert(sgs.ai_skills, n_yaoqing_skill)
n_yaoqing_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#n_yaoqingcard") then return end
	if self:getOverflow() <= 0 then return end
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(cards)
	if #cards < 2 then return end
	if self:isValuableCard(cards[2]) then return end
	local card_str = "#n_yaoqingcard:"..cards[1]:getId().."+"..cards[2]:getId()..":"
	return sgs.Card_Parse(card_str)
end
sgs.ai_skill_use_func["#n_yaoqingcard"] = function(card, use, self)
	local valid = {}
	for _,p in ipairs(self.enemies) do
	    if not p:isAdjacentTo(self.player) then 
		    table.insert(valid,p)
        end
	end
	if #valid == 0 then return end
	self:sort(valid,"defense")
	use.card = card
	if use.to then use.to:append(valid[1]) end
	return
end

sgs.ai_skill_invoke.n_jujie = function(self, data)
    if self:isEnemy(data:toPlayer()) then
        local a,b = data:toPlayer():getHandcardNum(),self.player:getHandcardNum()
        return a>b
    end
end

sgs.ai_skill_invoke.n_suijie = function(self, data)
    if self:isFriend(data:toPlayer()) then return true end
    local a,b = data:toPlayer():getHandcardNum(),self.player:getHandcardNum()
    return a>b
end

sgs.ai_skill_invoke.n_kuanglang = function(self, data)
    return self.room:getTag("CurrentDamageStruct"):toDamage().from:objectName() ~= self.player:objectName()
end

n_songshi_skill = {}
n_songshi_skill.name = "n_songshi"
table.insert(sgs.ai_skills, n_songshi_skill)
n_songshi_skill.getTurnUseCard = function(self)
	local player = self.player
	local cando = true
	local blacks = sgs.IntList()
	local reds = sgs.IntList()
	for _,c in sgs.qlist(player:getHandcards()) do
		if c:isRed() then
			reds:append(c:getId())
		else
			blacks:append(c:getId())
		end
	end
	if (reds:isEmpty() or blacks:isEmpty()) then cando = false end
	if player:hasUsed("#n_songshicard") then cando = false end
	if cando then
		return sgs.Card_Parse("#n_songshicard:.:")
	end
	return nil
end
sgs.ai_skill_use_func["#n_songshicard"] = function(card,use,self)
	use.card = card
end
sgs.ai_skill_choice["n_songshi"] = "black"
sgs.ai_use_priority.n_songshicard = 9.9

sgs.ai_skill_cardask["#dingchuanDisCard"] = function(self, data)
	local cards = sgs.QList2Table(self.player:getCards("he"))
	local blackcard = {}
	for _,cd in ipairs(cards) do
		if cd:isBlack() then 
			table.insert(blackcard, cd)
		end
	end
	if #blackcard == 0 then return end
	self:sortByKeepValue(blackcard)
	local use = data:toCardUse()
	if self:isEnemy(self.room:getCurrent()) then return blackcard[1]:getId() else return "." end
end

n_shenfang_skill = {}
n_shenfang_skill.name = "n_shenfang"
table.insert(sgs.ai_skills, n_shenfang_skill)
n_shenfang_skill.getTurnUseCard = function(self)
	--if self.player:usedTimes("#n_songshicard") >= 1 then return end
	local room = self.room
	local all = room:getOtherPlayers(self.player)
	local n = 0
	for _,p in sgs.qlist(all) do
		if p:isWounded() then n = n + 1 end
	end
	local enemies = self.enemies
	local truetarget = {}
	for _,enemy in ipairs(enemies) do
		if enemy:isWounded() and math.fmod(enemy:getMark("@n_cough"),2)>0 then
			table.insert(truetarget,enemy)
		end
	end
	n = math.min(n,#truetarget)
	if n == 0 then return nil end
	local thenred = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)

	for _,card in ipairs(cards) do
		if card:isBlack() and self:getUseValue(card) <= 6 then 
			table.insert(thenred, card:getId())
			if #thenred >= n then break end
		end
	end
	if #thenred == 0 then return nil end
	
	
	return sgs.Card_Parse("#n_shenfangcard:" .. table.concat(thenred, "+")..":")
end

sgs.ai_skill_use_func["#n_shenfangcard"] = function(card, use, self)
	local enemies = self.enemies
	local truetarget = {}
	for _,enemy in ipairs(enemies) do
		if enemy:isWounded() and math.fmod(enemy:getMark("@n_cough"),2)>0 then
			table.insert(truetarget,enemy)
		end
	end
	if #truetarget == 0 then return end
	use.card = card
	if use.to then
		for i = 1,math.min(card:getSubcards():length(),#truetarget) do
			use.to:append(truetarget[i])
		end
	end
	return
end

sgs.ai_skill_playerchosen["n_tongyou"] = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, target in ipairs(targets) do
		if self:isFriend(target) and target:isAlive() then
			return target
		end
	end
	return nil
end
n_mianjin_skill = {}
n_mianjin_skill.name = "n_mianjin"
table.insert(sgs.ai_skills, n_mianjin_skill)
n_mianjin_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#n_mianjincard") then
		local parse = sgs.Card_Parse("#n_mianjincard:.:")
		assert (parse ~= nil)
		return parse
	end
	return nil
end
sgs.ai_skill_use_func["#n_mianjincard"] = function(card, use, self)
	local valid = {}
	for _,enemy in ipairs(self.enemies) do
		if enemy:isWounded() and not enemy:isKongcheng() then 
			table.insert(valid,enemy)
		end
	end
	if #valid == 0 then return end
	self:sort(valid,"handcard")
	use.card = card
	if use.to then use.to:append(valid[1]) end
	return
end
sgs.ai_skill_use["@@n_mianjin"] = function(self, prompt)
	self:sort(self.friends, "handcard_defense",true)
	local valid = {}
	for _,friend in ipairs(self.friends) do
		if #valid >= self.player:getMark("n_mianjingives") then break end
		if friend:getMark("n_mianjinsrc") == 0 and friend:getHandcardNum() < friend:getMaxHp() then
			table.insert(valid,friend:objectName())
		end
	end
	if #valid == 0 then return end
	local str = ""
	if #valid == 1 then str = valid[1] else str = table.concat(valid,"+") end
	local card_str = string.format("#n_mianjingivecard:.:->%s", str)
	return card_str
end

sgs.ai_skill_invoke.n_gaiguan = function(self,data)
	return self:isEnemy(data:toPlayer())
end

n_xinliao_skill = {}
n_xinliao_skill.name = "n_xinliao"
table.insert(sgs.ai_skills, n_xinliao_skill)
n_xinliao_skill.getTurnUseCard = function(self)
	if self.player:getMark("@n_heartcure") == 0 then return end
	if self.player:getRole() == "renegade" and self.room:getAllPlayers():length() > 5 then return end
	local room = self.room
	local cards = sgs.QList2Table(self.player:getCards("he"))
	local need_cards = {}
	local spade, club, heart, diamond
	for _, card in ipairs(cards) do
		if card:getSuit() == sgs.Card_Spade and not spade then spade = true; table.insert(need_cards, card:getId())
		elseif card:getSuit() == sgs.Card_Club and not club then club = true; table.insert(need_cards, card:getId())
		elseif card:getSuit() == sgs.Card_Heart and not heart then heart = true; table.insert(need_cards, card:getId())
		elseif card:getSuit() == sgs.Card_Diamond and not diamond then diamond = true; table.insert(need_cards, card:getId())
		end
	end
	local lord = room:getLord()
	local all = room:getOtherPlayers(self.player)
	local loyalist = {}
	local rebel = {}
	local renegade = {}
	for _,p in sgs.qlist(all) do
		if p:getRole() == "loyalist" then table.insert(loyalist,p) end
		if p:getRole() == "rebel" then table.insert(rebel,p) end
		if p:getRole() == "renegade" then table.insert(renegade,p) end
	end
	local enemies = {}
	if self.player:getRole() == "rebel" then enemies = loyalist;table.insert(enemies,lord); end
	if self.player:getRole() == "lord" or self.player:getRole() == "loyalist" then enemies = rebel end	--不搞内
	if self.player:getRole() == "renegade" then enemies = sgs.QList2Table(all) end
	if #enemies == 0 then return end
	if #need_cards > #enemies then
		for i=1 ,#self.enemies do
			table.remove(need_cards,i)
		end
	end
	return sgs.Card_Parse("#n_xinliaocard:" .. table.concat(need_cards, "+")..":")
end

sgs.ai_skill_use_func["#n_xinliaocard"] = function(card, use, self)
	local room = self.room
	local lord = room:getLord()
	local all = room:getOtherPlayers(self.player)
	local loyalist = {}
	local rebel = {}
	local renegade = {}
	for _,p in sgs.qlist(all) do
		if p:getRole() == "loyalist" then table.insert(loyalist,p) end
		if p:getRole() == "rebel" then table.insert(rebel,p) end
		if p:getRole() == "renegade" then table.insert(renegade,p) end
	end
	local enemies = {}
	if self.player:getRole() == "rebel" then enemies = loyalist;table.insert(enemies,lord); end
	if self.player:getRole() == "lord" or self.player:getRole() == "loyalist" then enemies = rebel end	--不搞内
	if self.player:getRole() == "renegade" then enemies = sgs.QList2Table(all) end
	if #enemies == 0 then return end
	use.card = card
	if use.to then
		for i = 1,math.min(card:getSubcards():length(),#enemies) do
			use.to:append(enemies[i])
		end
	end
	return
end

sgs.ai_use_priority.n_xinliaocard = 9.8

sgs.ai_skill_invoke.n_italy_artillery = function(self,data)
	return true
end


sgs.ai_skill_playerchosen.n_jiejian = sgs.ai_skill_playerchosen.n_discard
sgs.ai_skill_use["@@n_qiuxue"] = function(self, prompt)
	local valid = {}
	if #self.enemies > 1 then 
		table.insert(valid,self.enemies[1]:objectName());table.insert(valid,self.enemies[2]:objectName())
	else
		table.insert(valid,self.enemies[1]:objectName());table.insert(valid,self.player:objectName())
	end
	if #valid == 0 then return end
	local str = table.concat(valid,"+")
	local card_str = string.format("#n_qiuxuecard:.:->%s", str)
	return card_str
end
sgs.ai_skill_choice["n_qiuxue"] = function(self, choices, data)
    return choices[math.random(1,#choices)]
end

n_zhuiwen_skill = {}
n_zhuiwen_skill.name = "n_zhuiwen"
table.insert(sgs.ai_skills, n_zhuiwen_skill)
n_zhuiwen_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("#n_zhuiwencard") then
		local parse = sgs.Card_Parse("#n_zhuiwencard:.:")
		assert (parse ~= nil)
		return parse
	end
	return nil
end
sgs.ai_skill_use_func["#n_zhuiwenCard"] = function(card, use, self)
	--self:sort(self.enemies, "handcard")
	for _,enemy in ipairs(self.enemies) do
		use.card = card
		if use.to then use.to:append(enemy) end
		return
	end
end

sgs.ai_use_priority.n_zhuiwenCard = 8.3
sgs.ai_skill_choice["n_zhuiwent"] = function(self, choices, data)
    local target = self.room:getCurrent()
    if self:isFriend(target) then
        return "n_zwtk"
    else
		if not self:isWeak() then
			return "n_zwpd"
		else return "n_zwtk" end
    end
end

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

function Table_Rand(t)
	if t == nil then
		return
	end

	local tRet = {}
	local Total = #t
	while Total > 0 do
		local i = math.random(1,Total)
		table.insert(tRet,t[i])
		t[i] = t[Total]
		Total = Total -1
	end
	return tRet
end

n_xiaoshi_skill = {}
n_xiaoshi_skill.name = "n_xiaoshi"
table.insert(sgs.ai_skills,n_xiaoshi_skill)
n_xiaoshi_skill.getTurnUseCard = function(self)
    local cards = sgs.QList2Table(self.player:getPile("n_crime"))
	if #cards < 2 then return end
	local toUse = {cards[1],cards[2]}
	local strs,patterns = {},Table_Rand(generateAllCardObjectNameTablePatterns())
	
	
	for _,str in ipairs(patterns) do
	    local card_str = ("%s:n_xiaoshi[no_suit:0]=%s"):format(str,table.concat(toUse,"+"))
		
	    local card = sgs.Card_Parse(card_str)
	    local use = sgs.CardUseStruct()
		if card:isKindOf("BasicCard") then self:useBasicCard(card,use) 
		elseif card:isKindOf("TrickCard") then self:useTrickCard(card, use) end
		if use.card then
			if card:canRecast() and use.to:isEmpty() then continue end
			return use.card
		end
	end
end
--sgs.ai_view_as.n_xiaoshi = function(card, player, card_place)
--	local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
--	local cards = sgs.QList2Table(player:getPile("n_crime"))
--	if #cards < 2 then return end
--	if string.sub(pattern, 1, 1) == "." or string.sub(pattern, 1, 1) == "@" then return end
--	return ("%s:n_xiaoshi[no_suit:0]=%s"):format(pattern:split("+")[1],table.concat({cards[1],cards[2]},"+"))
--end

sgs.ai_skill_invoke.n_beishui = sgs.ai_skill_invoke.n_dianliao

sgs.ai_skill_choice["n_baipiao"] = function(self, choices, data)
	local r = math.random(1, #choices)
    return choices[r]
end

sgs.ai_skill_invoke.n_zimiao = sgs.ai_skill_invoke.n_gaiguan
sgs.ai_skill_invoke.n_leyou = function(self,data)
	local player = self.player
	for _,cd in sgs.qlist(player:getCards("h")) do
		if cd:isKindOf("NBrick") then return true end
		if cd:isKindOf("Slash") and cd:getNumber()>6 then
			local use = sgs.CardUseStruct()
			self:useBasicCard(cd,use)
			if use.card then return true end
		end
	end
	return false
end

sgs.ai_skill_choice["n_chigua"] = function(self, choices, data)
	if self:isWeak() then return "peach" end
	return "ex_nihilo"
end

sgs.ai_skill_playerchosen.n_tianhuang = function(self, targets)
	targets = sgs.QList2Table(targets)
	local tooo = self.room:getTag("CurrentDamageStruct"):toDamage().to
	for _, target in ipairs(targets) do
		if (self:isEnemy(target) and target:isLord() and tooo:getRole() == "loyalist")
			or (self:isFriend(target) and tooo:getRole() == "rebel")then
			return target
		end
	end
	return nil
end


sgs.ai_skill_invoke.n_ruya = sgs.ai_skill_invoke.n_gaiguan

sgs.ai_skill_discard.n_ruya = function(self)
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)

	table.insert(to_discard, cards[1]:getEffectiveId())

	return to_discard
end

sgs.ai_skill_cardask["#n_baotu"] = function(self, data)
	local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
	local to = damage.to
	if to:getRole() == "rebel" then
		if not (to:hasSkill("duanchang") or to:hasSkill("huilei")) then
			local cards = sgs.QList2Table(self.player:getCards("he"))
			if #cards == 0 then return end
			self:sortByKeepValue(cards)
			return cards[1]:getId()
		end
	end
	return "."
end

huoxin_skill = {}
huoxin_skill.name = "n_huoxin"
table.insert(sgs.ai_skills, huoxin_skill)
huoxin_skill.getTurnUseCard = function(self)
	if self.player:isKongcheng() then return nil end
	if self.player:hasUsed("#n_huoxincard") then return nil end
	return sgs.Card_Parse("#n_huoxincard:.:")
end

sgs.ai_skill_use_func.huoxinCard = function(card, use, self)
	self:sort(self.enemies, "defense")
	local target
	for _, enemy in ipairs(self.enemies) do
		if self:canAttack(enemy) and not self:hasSkills("qingnang|tianxiang", enemy) then
			target = enemy

			local wuguotai = self.room:findPlayerBySkillName("buyi")
			local care = (target:getHp() <= 1) and (self:isFriend(target, wuguotai))
			local ucard = nil
			local handcards = self.player:getCards("h")
			handcards = sgs.QList2Table(handcards)
			self:sortByKeepValue(handcards)
			for _,cd in ipairs(handcards) do
				local flag = not (cd:isKindOf("Peach") or cd:isKindOf("Analeptic"))
				local suit = cd:getSuit()
				if flag and care then
					flag = cd:isKindOf("BasicCard")
				end
				if flag and target:hasSkill("longhun") then
					flag = (suit ~= sgs.Card_Heart)
				end
				if flag and target:hasSkill("jiuchi") then
					flag = (suit ~= sgs.Card_Spade)
				end
				if flag and target:hasSkill("jijiu") then
					flag = (cd:isBlack())
				end
				if flag then
					ucard = cd
					break
				end
			end
			if ucard then
				local keep_value = self:getKeepValue(ucard)
				if ucard:getSuit() == sgs.Card_Diamond then keep_value = keep_value + 0.5 end
				if keep_value < 6 then
					use.card = sgs.Card_Parse("#n_huoxincard:" .. ucard:getEffectiveId()..":")
					if use.to then use.to:append(target) end
					return
				end
			end
		end
	end
end

n_yongmu_skill = {}
n_yongmu_skill.name = "n_yongmu"
table.insert(sgs.ai_skills, n_yongmu_skill)
n_yongmu_skill.getTurnUseCard = function(self)
	if self.player:getMark("@n_ypyj") > 0 then
		local parse = sgs.Card_Parse("#n_yongmucard:.:")
		assert (parse ~= nil)
		return parse
	end
	return nil
end
sgs.ai_skill_use_func["#n_yongmucard"] = function(card,use,self)
	use.card = card
end

n_tuishou_skill = {}
n_tuishou_skill.name = "n_tuishou"
table.insert(sgs.ai_skills, n_tuishou_skill)
n_tuishou_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#n_tuishoucard") then return end
	local cd
	for _,c in sgs.qlist(self.player:getCards("h")) do
		if c:isKindOf("Slash") then cd = c;break end
	end
	if not cd then return end
	local parse = sgs.Card_Parse("#n_tuishoucard:"..cd:getId()..":")
	return parse
end
sgs.ai_skill_use_func["#n_tuishoucard"] = function(card,use,self)
	use.card = card
end

sgs.ai_skill_playerchosen.n_kuangkua = function(self, targets, data)
    local card = self.room:getTag("n_kuangkua_data"):toCardUse().card
	if card:isKindOf("EquipCard") or card:isKindOf("DelayedTrick") then return end
	local function compare_func(pa,pb)	return pa:getHandcardNum() > pb:getHandcardNum() end
	table.sort(self.friends_noself,compare_func)
	if #self.friends_noself > 0 then return self.friends_noself[1]
	else return nil end
end

sgs.ai_skill_invoke.n_qiafan = function(self,data)
	local event = self.room:getTag("n_qiafan_event"):toInt()
	if event == sgs.DamageCaused then
		local p = data:toDamage().to
		if self:isFriend(p) then return true end
		if self:isWeak() and not self:isWeak(p) then return true end
	else
		local move = data:toMoveOneTime()
		local p = move.to
		local overflow = self:getOverflow(p)>0
		local enemy = self:isEnemy(p)
		return (overflow and not enemy)
			or (enemy and not overflow)
	end
end

n_meiyin_skill = {}
n_meiyin_skill.name = "n_meiyin"
table.insert(sgs.ai_skills, n_meiyin_skill)
n_meiyin_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#n_meiyincard") then return end
	local t = self.enemies
	for _,p in ipairs(t) do
		if p:isNude() or not p:isMale() then table.remove(t,table.indexOf(t,p)) end
	end
	if #t == 0 then return nil end
	local parse = sgs.Card_Parse("#n_meiyincard:.:")
	return parse
end

sgs.ai_skill_use_func["#n_meiyincard"] = function(card,use,self)
	local t = self.enemies
	for _,p in ipairs(t) do
		if p:isNude() or not p:isMale() then table.remove(t,table.indexOf(t,p)) end
	end
	if #t == 0 then return end
	local function compare_func(pa,pb)
		return pa:getCards("he"):length() < pb:getCards("he"):length()
	end
	table.sort(t,compare_func)
	use.card = card
	if use.to then use.to:append(t[1]) end
	return
end

sgs.ai_skill_playerchosen.n_yanhui = function(self, targets)
	self:updatePlayers()
	self:sort(self.friends_noself, "handcard")
	local target = nil
	for _, friend in ipairs(self.friends_noself) do
		if not friend:faceUp() then
				target = friend
			break
		end
		if not target then
			if not self:toTurnOver(friend, n, "n_yanhui") then
				target = friend
				break
			end
		end
		if not target then 
			if friend:getMaxHp() - friend:getHandcardNum() >= 3 then
				target = friend
			end
		end
	end
	if not target then
		self:sort(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if self:toTurnOver(enemy, n, "n_yanhui") then
				target = enemy
				break
			end
		end
	end

	return target
end

sgs.ai_skill_invoke.n_mouzan = sgs.ai_skill_invoke.n_gaiguan

sgs.ai_skill_choice.n_mouzan = function(self, choices, data)
	if self:isWeak() then return "tl_recover" end
	return "tl_damage"
end

sgs.ai_cardshow.n_polan = function(self,requestor)
	local ty = self.room:getTag("n_polan_ai"):toInt()
	local cards = self.player:getCards("h")
	for _,card in sgs.qlist(cards) do
		if card:getTypeId() == ty then
			return card
		end
	end
	return cards:first()
end

sgs.ai_skill_invoke.n_polan = sgs.ai_skill_invoke.n_gaiguan

local n_tiaoxin_skill = {}
n_tiaoxin_skill.name = "n_tiaoxin"
table.insert(sgs.ai_skills, n_tiaoxin_skill)
n_tiaoxin_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#n_tiaoxincard") then return end
	return sgs.Card_Parse("#n_tiaoxincard:.:")
end

sgs.ai_skill_use_func["#n_tiaoxincard"] = function(card,use,self)
	local distance = use.DefHorse and 1 or 0
	local targets = {}
	for _, enemy in ipairs(self.enemies) do
		if enemy:distanceTo(self.player, distance) <= enemy:getAttackRange() and not self:doNotDiscard(enemy) and self:isTiaoxinTarget(enemy) then
			table.insert(targets, enemy)
		end
	end

	if #targets == 0 then return end

	sgs.ai_use_priority.n_tiaoxincard = 8
	if not self.player:getArmor() and not self.player:isKongcheng() then
		for _, card in sgs.qlist(self.player:getCards("h")) do
			if card:isKindOf("Armor") and self:evaluateArmor(card) > 3 then
				sgs.ai_use_priority.n_tiaoxincard = 5.9
				break
			end
		end
	end

	if use.to then
		self:sort(targets, "defenseSlash")
		use.to:append(targets[1])
	end
	use.card = sgs.Card_Parse("#n_tiaoxincard:.:")
end

sgs.ai_card_intention.n_tiaoxincard = 80
sgs.ai_use_priority.n_tiaoxincard = 4

sgs.ai_skill_invoke.n_moran = true

sgs.ai_skill_choice.n_hunyuan = function(self, choices, data)
	local a, b, c = self.player:getMark("@n_hydamage0"), self.player:getMark("@n_hydamage1"), self.player:getMark("@n_hydamage2")
	if a == b and b == c then
		return choices[math.random(1, #choices)]
	else
		local t = {a, b, c}
		table.sort(t)
		if a == t[1] then
			return "n_toNormal"
		elseif b == t[1] then
			return "n_toFire"
		else
			return "n_toThunder"
		end
	end
end

sgs.ai_skill_playerchosen["n_hunyuan"] = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, target in ipairs(targets) do
		if self:isEnemy(target) and target:isAlive() then
			return target
		end
	end
	return nil
end

local n_tujin_skill = {}
n_tujin_skill.name = "n_tujin"
table.insert(sgs.ai_skills, n_tujin_skill)
n_tujin_skill.getTurnUseCard = function(self)
	local source,room = self.player,self.room
	local handcards = sgs.QList2Table(source:getCards("he"))
	local t = {}
	for _, cd in ipairs(handcards) do
		if cd:isKindOf("Weapon") or cd:isKindOf("OffensiveHorse") then
			table.insert(t, cd)
		end
	end
	if #t == 0 then return end
    local card_str = ("duel:n_tujin[%s:%d]=%d"):format(t[1]:getSuitString(), t[1]:getNumber(), t[1]:getId())
        
    local card = sgs.Card_Parse(card_str)
    return card
end

sgs.ai_skill_invoke.n_jingshe = sgs.ai_skill_invoke.n_zimiao

sgs.ai_skill_invoke.n_buting = true

sgs.ai_skill_invoke.n_ansha = true

sgs.ai_skill_invoke.n_pojun = sgs.ai_skill_invoke.n_zimiao
sgs.ai_skill_choice["n_pojun_num"] = function(self, choices, data)
    return #(choices:split("+"))
end

sgs.ai_skill_cardask["#n_juedi"] = function(self, data)
	if self:isEnemy(self.room:getTag("CurrentDamageStruct"):toDamage().to) then
		local cards = self:getCards("he")
		for _, cd in sgs.qlist(cards) do
			if cd:getSuit() == sgs.Card_Spade and not cd:isKindOf("Armor") then 
				return cd:getId()
			end
		end
	end
end

sgs.ai_skill_invoke.n_wochao = true
sgs.ai_skill_playerchosen.wochao_slash = sgs.ai_skill_playerchosen.zero_card_as_slash
-- dofile "./lua/ai/ng-ai.lua"
