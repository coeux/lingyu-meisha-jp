H021_auto115_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H021_auto115_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H021_auto115_attack.info_pool[effectScript.ID].Attacker)
        
		H021_auto115_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_02101")
		PreLoadSound("skill_02101")
		PreLoadAvatar("S110_1")
		PreLoadAvatar("S110_2")
		PreLoadSound("skill_02103")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdg" )
		effectScript:RegisterEvent( 13, "hgfj" )
		effectScript:RegisterEvent( 21, "fdg" )
		effectScript:RegisterEvent( 24, "dfgfh" )
		effectScript:RegisterEvent( 26, "sdgfdh" )
		effectScript:RegisterEvent( 27, "hgj" )
		effectScript:RegisterEvent( 30, "hgjhg" )
	end,

	sfdg = function( effectScript )
		SetAnimation(H021_auto115_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_02101")
	end,

	hgfj = function( effectScript )
			PlaySound("skill_02101")
	end,

	fdg = function( effectScript )
		AttachAvatarPosEffect(false, H021_auto115_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 75), 2.5, 100, "S110_1")
	end,

	dfgfh = function( effectScript )
		AttachAvatarPosEffect(false, H021_auto115_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "S110_2")
	end,

	sdgfdh = function( effectScript )
			PlaySound("skill_02103")
	end,

	hgj = function( effectScript )
			DamageEffect(H021_auto115_attack.info_pool[effectScript.ID].Attacker, H021_auto115_attack.info_pool[effectScript.ID].Targeter, H021_auto115_attack.info_pool[effectScript.ID].AttackType, H021_auto115_attack.info_pool[effectScript.ID].AttackDataList, H021_auto115_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	hgjhg = function( effectScript )
			DamageEffect(H021_auto115_attack.info_pool[effectScript.ID].Attacker, H021_auto115_attack.info_pool[effectScript.ID].Targeter, H021_auto115_attack.info_pool[effectScript.ID].AttackType, H021_auto115_attack.info_pool[effectScript.ID].AttackDataList, H021_auto115_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
