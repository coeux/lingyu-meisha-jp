S697_magic_M105_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S697_magic_M105_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S697_magic_M105_attack.info_pool[effectScript.ID].Attacker)
        
		S697_magic_M105_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S696_1")
		PreLoadAvatar("S696_1")
		PreLoadAvatar("S696_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdhgj" )
		effectScript:RegisterEvent( 33, "vbnn" )
		effectScript:RegisterEvent( 46, "dfgfh" )
		effectScript:RegisterEvent( 48, "fdg" )
		effectScript:RegisterEvent( 51, "dgh" )
	end,

	fdhgj = function( effectScript )
		SetAnimation(S697_magic_M105_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	vbnn = function( effectScript )
		AttachAvatarPosEffect(false, S697_magic_M105_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 2.5, 100, "S696_1")
	end,

	dfgfh = function( effectScript )
		AttachAvatarPosEffect(false, S697_magic_M105_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 2.5, 100, "S696_1")
	end,

	fdg = function( effectScript )
		AttachAvatarPosEffect(false, S697_magic_M105_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "S696_2")
	end,

	dgh = function( effectScript )
			DamageEffect(S697_magic_M105_attack.info_pool[effectScript.ID].Attacker, S697_magic_M105_attack.info_pool[effectScript.ID].Targeter, S697_magic_M105_attack.info_pool[effectScript.ID].AttackType, S697_magic_M105_attack.info_pool[effectScript.ID].AttackDataList, S697_magic_M105_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
