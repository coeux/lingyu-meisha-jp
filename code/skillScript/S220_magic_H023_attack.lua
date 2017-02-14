S220_magic_H023_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S220_magic_H023_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S220_magic_H023_attack.info_pool[effectScript.ID].Attacker)
        
		S220_magic_H023_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0233")
		PreLoadAvatar("S220")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "d" )
		effectScript:RegisterEvent( 45, "a" )
		effectScript:RegisterEvent( 57, "asf" )
		effectScript:RegisterEvent( 75, "s" )
	end,

	d = function( effectScript )
		SetAnimation(S220_magic_H023_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("s0233")
	end,

	a = function( effectScript )
		SetAnimation(S220_magic_H023_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	asf = function( effectScript )
		AttachAvatarPosEffect(false, S220_magic_H023_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 40), 3.5, 100, "S220")
	end,

	s = function( effectScript )
			DamageEffect(S220_magic_H023_attack.info_pool[effectScript.ID].Attacker, S220_magic_H023_attack.info_pool[effectScript.ID].Targeter, S220_magic_H023_attack.info_pool[effectScript.ID].AttackType, S220_magic_H023_attack.info_pool[effectScript.ID].AttackDataList, S220_magic_H023_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
