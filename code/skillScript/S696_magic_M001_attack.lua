S696_magic_M001_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S696_magic_M001_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S696_magic_M001_attack.info_pool[effectScript.ID].Attacker)
        
		S696_magic_M001_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S200")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sf" )
		effectScript:RegisterEvent( 27, "d" )
		effectScript:RegisterEvent( 29, "fd" )
	end,

	sf = function( effectScript )
		SetAnimation(S696_magic_M001_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S696_magic_M001_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 2, 100, "S200")
	end,

	fd = function( effectScript )
			DamageEffect(S696_magic_M001_attack.info_pool[effectScript.ID].Attacker, S696_magic_M001_attack.info_pool[effectScript.ID].Targeter, S696_magic_M001_attack.info_pool[effectScript.ID].AttackType, S696_magic_M001_attack.info_pool[effectScript.ID].AttackDataList, S696_magic_M001_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
