S250_magic_H011_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S250_magic_H011_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S250_magic_H011_attack.info_pool[effectScript.ID].Attacker)
        
		S250_magic_H011_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01101")
		PreLoadSound("skill_01101")
		PreLoadAvatar("S250_1")
		PreLoadAvatar("S250_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "d" )
		effectScript:RegisterEvent( 19, "safdsg" )
		effectScript:RegisterEvent( 20, "s" )
		effectScript:RegisterEvent( 25, "adad" )
		effectScript:RegisterEvent( 26, "sadwd" )
		effectScript:RegisterEvent( 29, "h" )
		effectScript:RegisterEvent( 32, "gdhjhk" )
		effectScript:RegisterEvent( 34, "yhtjk" )
		effectScript:RegisterEvent( 37, "hgjkk" )
	end,

	d = function( effectScript )
		SetAnimation(S250_magic_H011_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_01101")
	end,

	safdsg = function( effectScript )
			PlaySound("skill_01101")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S250_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 85), 2, 100, "S250_1")
	end,

	adad = function( effectScript )
		AttachAvatarPosEffect(false, S250_magic_H011_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2.2, 100, "S250_2")
	end,

	sadwd = function( effectScript )
			DamageEffect(S250_magic_H011_attack.info_pool[effectScript.ID].Attacker, S250_magic_H011_attack.info_pool[effectScript.ID].Targeter, S250_magic_H011_attack.info_pool[effectScript.ID].AttackType, S250_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S250_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	h = function( effectScript )
			DamageEffect(S250_magic_H011_attack.info_pool[effectScript.ID].Attacker, S250_magic_H011_attack.info_pool[effectScript.ID].Targeter, S250_magic_H011_attack.info_pool[effectScript.ID].AttackType, S250_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S250_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	gdhjhk = function( effectScript )
			DamageEffect(S250_magic_H011_attack.info_pool[effectScript.ID].Attacker, S250_magic_H011_attack.info_pool[effectScript.ID].Targeter, S250_magic_H011_attack.info_pool[effectScript.ID].AttackType, S250_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S250_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	yhtjk = function( effectScript )
			DamageEffect(S250_magic_H011_attack.info_pool[effectScript.ID].Attacker, S250_magic_H011_attack.info_pool[effectScript.ID].Targeter, S250_magic_H011_attack.info_pool[effectScript.ID].AttackType, S250_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S250_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	hgjkk = function( effectScript )
			DamageEffect(S250_magic_H011_attack.info_pool[effectScript.ID].Attacker, S250_magic_H011_attack.info_pool[effectScript.ID].Targeter, S250_magic_H011_attack.info_pool[effectScript.ID].AttackType, S250_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S250_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
