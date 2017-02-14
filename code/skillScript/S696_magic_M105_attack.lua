S696_magic_M105_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S696_magic_M105_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S696_magic_M105_attack.info_pool[effectScript.ID].Attacker)
        
		S696_magic_M105_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S697_3")
		PreLoadAvatar("S697_2")
		PreLoadAvatar("S697_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfgdg" )
		effectScript:RegisterEvent( 7, "fdhgh" )
		effectScript:RegisterEvent( 31, "dsf" )
		effectScript:RegisterEvent( 48, "fdhgfh" )
		effectScript:RegisterEvent( 54, "fdghfh" )
		effectScript:RegisterEvent( 59, "gfh" )
	end,

	dsfgdg = function( effectScript )
		SetAnimation(S696_magic_M105_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	fdhgh = function( effectScript )
		AttachAvatarPosEffect(false, S696_magic_M105_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S697_3")
	end,

	dsf = function( effectScript )
		AttachAvatarPosEffect(false, S696_magic_M105_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(120, 50), 2, 100, "S697_2")
	end,

	fdhgfh = function( effectScript )
		AttachAvatarPosEffect(false, S696_magic_M105_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 120), 2, 100, "S697_1")
	end,

	fdghfh = function( effectScript )
			DamageEffect(S696_magic_M105_attack.info_pool[effectScript.ID].Attacker, S696_magic_M105_attack.info_pool[effectScript.ID].Targeter, S696_magic_M105_attack.info_pool[effectScript.ID].AttackType, S696_magic_M105_attack.info_pool[effectScript.ID].AttackDataList, S696_magic_M105_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	gfh = function( effectScript )
			DamageEffect(S696_magic_M105_attack.info_pool[effectScript.ID].Attacker, S696_magic_M105_attack.info_pool[effectScript.ID].Targeter, S696_magic_M105_attack.info_pool[effectScript.ID].AttackType, S696_magic_M105_attack.info_pool[effectScript.ID].AttackDataList, S696_magic_M105_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
