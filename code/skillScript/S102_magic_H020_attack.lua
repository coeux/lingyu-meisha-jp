S102_magic_H020_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S102_magic_H020_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S102_magic_H020_attack.info_pool[effectScript.ID].Attacker)
		S102_magic_H020_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S102")
		PreLoadSound("buff")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "b" )
	end,

	a = function( effectScript )
		SetAnimation(S102_magic_H020_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, S102_magic_H020_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.3, 100, "S102")
		PlaySound("buff")
	end,

}
