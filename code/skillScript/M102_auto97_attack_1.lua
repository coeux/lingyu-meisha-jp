M102_auto97_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M102_auto97_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M102_auto97_attack.info_pool[effectScript.ID].Attacker)
        
		M102_auto97_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S97_1")
		PreLoadAvatar("S97_2")
		PreLoadAvatar("S97_3")
		PreLoadAvatar("S97_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "saff" )
		effectScript:RegisterEvent( 4, "dsg" )
		effectScript:RegisterEvent( 15, "sfdg" )
		effectScript:RegisterEvent( 37, "fhgjh" )
		effectScript:RegisterEvent( 57, "fdg" )
		effectScript:RegisterEvent( 58, "sfdsg" )
	end,

	saff = function( effectScript )
		SetAnimation(M102_auto97_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dsg = function( effectScript )
		AttachAvatarPosEffect(false, M102_auto97_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 2, 100, "S97_1")
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, M102_auto97_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-200, 300), 1, 100, "S97_2")
	end,

	fhgjh = function( effectScript )
		AttachAvatarPosEffect(false, M102_auto97_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S97_3")
	end,

	fdg = function( effectScript )
		AttachAvatarPosEffect(false, M102_auto97_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(130, 0), 2, 100, "S97_1")
	end,

	sfdsg = function( effectScript )
			DamageEffect(M102_auto97_attack.info_pool[effectScript.ID].Attacker, M102_auto97_attack.info_pool[effectScript.ID].Targeter, M102_auto97_attack.info_pool[effectScript.ID].AttackType, M102_auto97_attack.info_pool[effectScript.ID].AttackDataList, M102_auto97_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
