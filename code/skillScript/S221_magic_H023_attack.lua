S221_magic_H023_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S221_magic_H023_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S221_magic_H023_attack.info_pool[effectScript.ID].Attacker)
        
		S221_magic_H023_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0233")
		PreLoadAvatar("S220")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "d" )
		effectScript:RegisterEvent( 24, "a" )
		effectScript:RegisterEvent( 33, "asf" )
		effectScript:RegisterEvent( 53, "s" )
	end,

	d = function( effectScript )
		SetAnimation(S221_magic_H023_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("s0233")
	end,

	a = function( effectScript )
		SetAnimation(S221_magic_H023_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	asf = function( effectScript )
		AttachAvatarPosEffect(false, S221_magic_H023_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 40), 3.5, 100, "S220")
	end,

	s = function( effectScript )
			DamageEffect(S221_magic_H023_attack.info_pool[effectScript.ID].Attacker, S221_magic_H023_attack.info_pool[effectScript.ID].Targeter, S221_magic_H023_attack.info_pool[effectScript.ID].AttackType, S221_magic_H023_attack.info_pool[effectScript.ID].AttackDataList, S221_magic_H023_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
