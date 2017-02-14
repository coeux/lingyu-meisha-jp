S610_magic_M015_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S610_magic_M015_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S610_magic_M015_attack.info_pool[effectScript.ID].Attacker)
        
		S610_magic_M015_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H001_xuli")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hgfk" )
		effectScript:RegisterEvent( 10, "ghfj" )
		effectScript:RegisterEvent( 33, "dgfjh" )
	end,

	hgfk = function( effectScript )
		SetAnimation(S610_magic_M015_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	ghfj = function( effectScript )
		AttachAvatarPosEffect(false, S610_magic_M015_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -10), 1, 100, "H001_xuli")
	end,

	dgfjh = function( effectScript )
			DamageEffect(S610_magic_M015_attack.info_pool[effectScript.ID].Attacker, S610_magic_M015_attack.info_pool[effectScript.ID].Targeter, S610_magic_M015_attack.info_pool[effectScript.ID].AttackType, S610_magic_M015_attack.info_pool[effectScript.ID].AttackDataList, S610_magic_M015_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
