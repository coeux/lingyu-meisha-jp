H033_auto496_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H033_auto496_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H033_auto496_attack.info_pool[effectScript.ID].Attacker)
        
		H033_auto496_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_03301")
		PreLoadSound("stalk_03301")
		PreLoadAvatar("H015_xuli")
		PreLoadAvatar("H015_xuli")
		PreLoadAvatar("H033_daoguang")
		PreLoadAvatar("S490_1")
		PreLoadSound("skill_03302")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsgg" )
		effectScript:RegisterEvent( 9, "dsggdfg" )
		effectScript:RegisterEvent( 14, "hgj" )
		effectScript:RegisterEvent( 22, "gjj" )
		effectScript:RegisterEvent( 25, "gfhgj" )
		effectScript:RegisterEvent( 28, "gfdj" )
	end,

	dsgg = function( effectScript )
		SetAnimation(H033_auto496_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_03301")
		PlaySound("stalk_03301")
	end,

	dsggdfg = function( effectScript )
		AttachAvatarPosEffect(false, H033_auto496_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-80, 140), 2, 100, "H015_xuli")
	end,

	hgj = function( effectScript )
		AttachAvatarPosEffect(false, H033_auto496_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-80, 140), 2, 100, "H015_xuli")
	end,

	gjj = function( effectScript )
		AttachAvatarPosEffect(false, H033_auto496_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(55, 90), 2, 100, "H033_daoguang")
	end,

	gfhgj = function( effectScript )
		AttachAvatarPosEffect(false, H033_auto496_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.8, 100, "S490_1")
		PlaySound("skill_03302")
	end,

	gfdj = function( effectScript )
			DamageEffect(H033_auto496_attack.info_pool[effectScript.ID].Attacker, H033_auto496_attack.info_pool[effectScript.ID].Targeter, H033_auto496_attack.info_pool[effectScript.ID].AttackType, H033_auto496_attack.info_pool[effectScript.ID].AttackDataList, H033_auto496_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
