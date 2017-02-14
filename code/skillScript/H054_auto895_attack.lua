H054_auto895_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H054_auto895_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H054_auto895_attack.info_pool[effectScript.ID].Attacker)
        
		H054_auto895_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_05402")
		PreLoadSound("stalk_05401")
		PreLoadAvatar("H054_3_1")
		PreLoadSound("skill_05401")
		PreLoadAvatar("H054_3_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "xdcfvgh" )
		effectScript:RegisterEvent( 10, "ghj" )
		effectScript:RegisterEvent( 12, "ui" )
		effectScript:RegisterEvent( 14, "cfvgh" )
	end,

	xdcfvgh = function( effectScript )
		SetAnimation(H054_auto895_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_05402")
		PlaySound("stalk_05401")
	end,

	ghj = function( effectScript )
		AttachAvatarPosEffect(false, H054_auto895_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 5), 1.2, 100, "H054_3_1")
		PlaySound("skill_05401")
	end,

	ui = function( effectScript )
		AttachAvatarPosEffect(false, H054_auto895_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.4, 100, "H054_3_2")
	end,

	cfvgh = function( effectScript )
			DamageEffect(H054_auto895_attack.info_pool[effectScript.ID].Attacker, H054_auto895_attack.info_pool[effectScript.ID].Targeter, H054_auto895_attack.info_pool[effectScript.ID].AttackType, H054_auto895_attack.info_pool[effectScript.ID].AttackDataList, H054_auto895_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
