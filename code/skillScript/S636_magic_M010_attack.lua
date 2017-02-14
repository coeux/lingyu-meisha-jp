S636_magic_M010_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S636_magic_M010_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S636_magic_M010_attack.info_pool[effectScript.ID].Attacker)
        
		S636_magic_M010_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S636_1")
		PreLoadAvatar("S636_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfdg" )
		effectScript:RegisterEvent( 32, "dssssg" )
		effectScript:RegisterEvent( 38, "sfdsg" )
		effectScript:RegisterEvent( 51, "sdg" )
	end,

	dfdg = function( effectScript )
		SetAnimation(S636_magic_M010_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dssssg = function( effectScript )
		AttachAvatarPosEffect(false, S636_magic_M010_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 60), 1, 100, "S636_1")
	end,

	sfdsg = function( effectScript )
		AttachAvatarPosEffect(false, S636_magic_M010_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.8, 100, "S636_2")
	end,

	sdg = function( effectScript )
			DamageEffect(S636_magic_M010_attack.info_pool[effectScript.ID].Attacker, S636_magic_M010_attack.info_pool[effectScript.ID].Targeter, S636_magic_M010_attack.info_pool[effectScript.ID].AttackType, S636_magic_M010_attack.info_pool[effectScript.ID].AttackDataList, S636_magic_M010_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
