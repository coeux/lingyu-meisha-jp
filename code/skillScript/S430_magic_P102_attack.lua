S430_magic_P102_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S430_magic_P102_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S430_magic_P102_attack.info_pool[effectScript.ID].Attacker)
        
		S430_magic_P102_attack.info_pool[effectScript.ID] = nil
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
		effectScript:RegisterEvent( 45, "hgfh" )
		effectScript:RegisterEvent( 71, "hgjgj" )
		effectScript:RegisterEvent( 80, "ghg" )
		effectScript:RegisterEvent( 91, "dsfdg" )
		effectScript:RegisterEvent( 92, "sfdfg" )
		effectScript:RegisterEvent( 95, "asfdsf" )
		effectScript:RegisterEvent( 97, "sasfd" )
	end,

	bgfhh = function( effectScript )
		SetAnimation(S430_magic_P102_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	hgfh = function( effectScript )
		SetAnimation(S430_magic_P102_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	hgjgj = function( effectScript )
		AttachAvatarPosEffect(false, S430_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-90, 0), 2, 100, "S430_1")
	end,

	ghg = function( effectScript )
		AttachAvatarPosEffect(false, S430_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-30, 70), 1, 100, "S430_2")
	end,

	dsfdg = function( effectScript )
		AttachAvatarPosEffect(false, S430_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-50, 70), 1, 100, "S430_3")
	end,

	sfdfg = function( effectScript )
		AttachAvatarPosEffect(false, S430_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 70), 1.5, 100, "S430_5")
	end,

	asfdsf = function( effectScript )
		AttachAvatarPosEffect(false, S430_magic_P102_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S430_4")
	end,

	sasfd = function( effectScript )
			DamageEffect(S430_magic_P102_attack.info_pool[effectScript.ID].Attacker, S430_magic_P102_attack.info_pool[effectScript.ID].Targeter, S430_magic_P102_attack.info_pool[effectScript.ID].AttackType, S430_magic_P102_attack.info_pool[effectScript.ID].AttackDataList, S430_magic_P102_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
