S223_magic_H023_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S223_magic_H023_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S223_magic_H023_attack.info_pool[effectScript.ID].Attacker)
        
		S223_magic_H023_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0234")
		PreLoadAvatar("S222_1")
		PreLoadAvatar("S222_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 5, "awd" )
		effectScript:RegisterEvent( 18, "fesfe" )
		effectScript:RegisterEvent( 21, "d" )
		effectScript:RegisterEvent( 25, "s" )
	end,

	a = function( effectScript )
		SetAnimation(S223_magic_H023_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("s0234")
	end,

	awd = function( effectScript )
		AttachAvatarPosEffect(false, S223_magic_H023_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(60, 30), 2, 100, "S222_1")
	end,

	fesfe = function( effectScript )
		AttachAvatarPosEffect(false, S223_magic_H023_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -2.5, 100, "S222_2")
	end,

	d = function( effectScript )
			DamageEffect(S223_magic_H023_attack.info_pool[effectScript.ID].Attacker, S223_magic_H023_attack.info_pool[effectScript.ID].Targeter, S223_magic_H023_attack.info_pool[effectScript.ID].AttackType, S223_magic_H023_attack.info_pool[effectScript.ID].AttackDataList, S223_magic_H023_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	s = function( effectScript )
			DamageEffect(S223_magic_H023_attack.info_pool[effectScript.ID].Attacker, S223_magic_H023_attack.info_pool[effectScript.ID].Targeter, S223_magic_H023_attack.info_pool[effectScript.ID].AttackType, S223_magic_H023_attack.info_pool[effectScript.ID].AttackDataList, S223_magic_H023_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
