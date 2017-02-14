M009_auto647_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M009_auto647_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M009_auto647_attack.info_pool[effectScript.ID].Attacker)
        
		M009_auto647_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S647_1")
		PreLoadAvatar("S647_2")
		PreLoadAvatar("S647_beiji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgf" )
		effectScript:RegisterEvent( 12, "sfdsfg" )
		effectScript:RegisterEvent( 14, "dsafd" )
		effectScript:RegisterEvent( 37, "sdfgf" )
		effectScript:RegisterEvent( 39, "dfhg" )
	end,

	dfgf = function( effectScript )
		SetAnimation(M009_auto647_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	sfdsfg = function( effectScript )
		AttachAvatarPosEffect(false, M009_auto647_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S647_1")
	end,

	dsafd = function( effectScript )
		AttachAvatarPosEffect(false, M009_auto647_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S647_2")
	end,

	sdfgf = function( effectScript )
		AttachAvatarPosEffect(false, M009_auto647_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S647_beiji")
	end,

	dfhg = function( effectScript )
			DamageEffect(M009_auto647_attack.info_pool[effectScript.ID].Attacker, M009_auto647_attack.info_pool[effectScript.ID].Targeter, M009_auto647_attack.info_pool[effectScript.ID].AttackType, M009_auto647_attack.info_pool[effectScript.ID].AttackDataList, M009_auto647_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
