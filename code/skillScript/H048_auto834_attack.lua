H048_auto834_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H048_auto834_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H048_auto834_attack.info_pool[effectScript.ID].Attacker)
        
		H048_auto834_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S830_1")
		PreLoadAvatar("S380_2")
		PreLoadAvatar("S830_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgfhhj" )
		effectScript:RegisterEvent( 8, "dsfdgfh" )
		effectScript:RegisterEvent( 18, "sfdsgfdh" )
		effectScript:RegisterEvent( 28, "fgfgjhj" )
		effectScript:RegisterEvent( 29, "dfdgfjh" )
	end,

	dfgfhhj = function( effectScript )
		SetAnimation(H048_auto834_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsfdgfh = function( effectScript )
		AttachAvatarPosEffect(false, H048_auto834_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-10, 0), 1.8, 100, "S830_1")
	end,

	sfdsgfdh = function( effectScript )
		AttachAvatarPosEffect(false, H048_auto834_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 120), 1.2, 100, "S380_2")
	end,

	fgfgjhj = function( effectScript )
		AttachAvatarPosEffect(false, H048_auto834_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S830_2")
	end,

	dfdgfjh = function( effectScript )
			DamageEffect(H048_auto834_attack.info_pool[effectScript.ID].Attacker, H048_auto834_attack.info_pool[effectScript.ID].Targeter, H048_auto834_attack.info_pool[effectScript.ID].AttackType, H048_auto834_attack.info_pool[effectScript.ID].AttackDataList, H048_auto834_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
