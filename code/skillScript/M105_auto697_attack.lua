M105_auto697_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M105_auto697_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M105_auto697_attack.info_pool[effectScript.ID].Attacker)
        
		M105_auto697_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S696_1")
		PreLoadAvatar("S696_1")
		PreLoadAvatar("S696_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdhgj" )
		effectScript:RegisterEvent( 33, "vbnn" )
		effectScript:RegisterEvent( 42, "dfgfh" )
		effectScript:RegisterEvent( 47, "fdg" )
		effectScript:RegisterEvent( 51, "dgh" )
	end,

	fdhgj = function( effectScript )
		SetAnimation(M105_auto697_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	vbnn = function( effectScript )
		AttachAvatarPosEffect(false, M105_auto697_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 2.5, 100, "S696_1")
	end,

	dfgfh = function( effectScript )
		AttachAvatarPosEffect(false, M105_auto697_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 2.5, 100, "S696_1")
	end,

	fdg = function( effectScript )
		AttachAvatarPosEffect(false, M105_auto697_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "S696_2")
	end,

	dgh = function( effectScript )
			DamageEffect(M105_auto697_attack.info_pool[effectScript.ID].Attacker, M105_auto697_attack.info_pool[effectScript.ID].Targeter, M105_auto697_attack.info_pool[effectScript.ID].AttackType, M105_auto697_attack.info_pool[effectScript.ID].AttackDataList, M105_auto697_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
