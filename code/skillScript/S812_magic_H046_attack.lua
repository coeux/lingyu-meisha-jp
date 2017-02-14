S812_magic_H046_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S812_magic_H046_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S812_magic_H046_attack.info_pool[effectScript.ID].Attacker)
        
		S812_magic_H046_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H046_xuli_3")
		PreLoadSound("attack_04604")
		PreLoadAvatar("S812_1")
		PreLoadSound("attack_04603")
		PreLoadAvatar("S812_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdghfhj" )
		effectScript:RegisterEvent( 10, "fdg" )
		effectScript:RegisterEvent( 25, "fgfhjj" )
		effectScript:RegisterEvent( 27, "dfgfhhgf" )
		effectScript:RegisterEvent( 28, "dfdgh" )
	end,

	fdghfhj = function( effectScript )
		SetAnimation(S812_magic_H046_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	fdg = function( effectScript )
		AttachAvatarPosEffect(false, S812_magic_H046_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 0), 1.5, 100, "H046_xuli_3")
		PlaySound("attack_04604")
	end,

	fgfhjj = function( effectScript )
		AttachAvatarPosEffect(false, S812_magic_H046_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-15, 35), 1.2, 100, "S812_1")
		PlaySound("attack_04603")
	end,

	dfgfhhgf = function( effectScript )
		AttachAvatarPosEffect(false, S812_magic_H046_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -1.5, 100, "S812_2")
	end,

	dfdgh = function( effectScript )
			DamageEffect(S812_magic_H046_attack.info_pool[effectScript.ID].Attacker, S812_magic_H046_attack.info_pool[effectScript.ID].Targeter, S812_magic_H046_attack.info_pool[effectScript.ID].AttackType, S812_magic_H046_attack.info_pool[effectScript.ID].AttackDataList, S812_magic_H046_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
