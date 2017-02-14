S312_magic_M060_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S312_magic_M060_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S312_magic_M060_attack.info_pool[effectScript.ID].Attacker)
		S312_magic_M060_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S312_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "A" )
		effectScript:RegisterEvent( 15, "V" )
		effectScript:RegisterEvent( 25, "b" )
	end,

	A = function( effectScript )
		SetAnimation(S312_magic_M060_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	V = function( effectScript )
		AttachAvatarPosEffect(false, S312_magic_M060_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 6), 1, 100, "S312_1")
	end,

	b = function( effectScript )
			DamageEffect(S312_magic_M060_attack.info_pool[effectScript.ID].Attacker, S312_magic_M060_attack.info_pool[effectScript.ID].Targeter, S312_magic_M060_attack.info_pool[effectScript.ID].AttackType, S312_magic_M060_attack.info_pool[effectScript.ID].AttackDataList, S312_magic_M060_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
