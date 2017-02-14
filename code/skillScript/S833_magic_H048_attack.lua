S833_magic_H048_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S833_magic_H048_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S833_magic_H048_attack.info_pool[effectScript.ID].Attacker)
        
		S833_magic_H048_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H048_gj1")
		PreLoadAvatar("H048_gj2")
		PreLoadAvatar("H048_gj3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ghrthrhdf" )
		effectScript:RegisterEvent( 10, "gergergerg" )
		effectScript:RegisterEvent( 28, "dgegergege" )
		effectScript:RegisterEvent( 34, "fghergffew" )
	end,

	ghrthrhdf = function( effectScript )
		SetAnimation(S833_magic_H048_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	gergergerg = function( effectScript )
		AttachAvatarPosEffect(false, S833_magic_H048_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-10, -10), 3, 100, "H048_gj1")
	end,

	dgegergege = function( effectScript )
		AttachAvatarPosEffect(false, S833_magic_H048_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -10), 3, 100, "H048_gj2")
	end,

	fghergffew = function( effectScript )
			DamageEffect(S833_magic_H048_attack.info_pool[effectScript.ID].Attacker, S833_magic_H048_attack.info_pool[effectScript.ID].Targeter, S833_magic_H048_attack.info_pool[effectScript.ID].AttackType, S833_magic_H048_attack.info_pool[effectScript.ID].AttackDataList, S833_magic_H048_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	AttachAvatarPosEffect(false, S833_magic_H048_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 3, 100, "H048_gj3")
	end,

}
