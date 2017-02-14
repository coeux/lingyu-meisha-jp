S431_magic_P102_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S431_magic_P102_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S431_magic_P102_attack.info_pool[effectScript.ID].Attacker)
        
		S431_magic_P102_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S430_1")
		PreLoadAvatar("S430_2")
		PreLoadAvatar("S430_3")
		PreLoadAvatar("S430_5")
		PreLoadAvatar("S430_4")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "bgfhh" )
		effectScript:RegisterEvent( 25, "hgfh" )
		effectScript:RegisterEvent( 47, "hgjgj" )
		effectScript:RegisterEvent( 57, "ghg" )
		effectScript:RegisterEvent( 68, "dsfdg" )
		effectScript:RegisterEvent( 69, "vfdgfg" )
		effectScript:RegisterEvent( 72, "dfg" )
		effectScript:RegisterEvent( 74, "asdff" )
	end,

	bgfhh = function( effectScript )
		SetAnimation(S431_magic_P102_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	hgfh = function( effectScript )
		SetAnimation(S431_magic_P102_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	hgjgj = function( effectScript )
		AttachAvatarPosEffect(false, S431_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-90, 0), 2, 100, "S430_1")
	end,

	ghg = function( effectScript )
		AttachAvatarPosEffect(false, S431_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-30, 70), 1, 100, "S430_2")
	end,

	dsfdg = function( effectScript )
		AttachAvatarPosEffect(false, S431_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-50, 70), 1, 100, "S430_3")
	end,

	vfdgfg = function( effectScript )
		AttachAvatarPosEffect(false, S431_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 70), 1.5, 100, "S430_5")
	end,

	dfg = function( effectScript )
		AttachAvatarPosEffect(false, S431_magic_P102_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S430_4")
	end,

	asdff = function( effectScript )
			DamageEffect(S431_magic_P102_attack.info_pool[effectScript.ID].Attacker, S431_magic_P102_attack.info_pool[effectScript.ID].Targeter, S431_magic_P102_attack.info_pool[effectScript.ID].AttackType, S431_magic_P102_attack.info_pool[effectScript.ID].AttackDataList, S431_magic_P102_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
