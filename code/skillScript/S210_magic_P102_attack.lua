S210_magic_P102_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S210_magic_P102_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S210_magic_P102_attack.info_pool[effectScript.ID].Attacker)
        
		S210_magic_P102_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0174")
		PreLoadAvatar("S210_2")
		PreLoadAvatar("S210_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 45, "s" )
		effectScript:RegisterEvent( 48, "asfdfs" )
		effectScript:RegisterEvent( 67, "d" )
		effectScript:RegisterEvent( 69, "f" )
	end,

	a = function( effectScript )
		SetAnimation(S210_magic_P102_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("s0174")
	end,

	s = function( effectScript )
		SetAnimation(S210_magic_P102_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	asfdfs = function( effectScript )
		AttachAvatarPosEffect(false, S210_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(75, 100), 2, 100, "S210_2")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S210_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 70), 1.5, 100, "S210_1")
	end,

	f = function( effectScript )
			DamageEffect(S210_magic_P102_attack.info_pool[effectScript.ID].Attacker, S210_magic_P102_attack.info_pool[effectScript.ID].Targeter, S210_magic_P102_attack.info_pool[effectScript.ID].AttackType, S210_magic_P102_attack.info_pool[effectScript.ID].AttackDataList, S210_magic_P102_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
