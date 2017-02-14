S830_magic_H048_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S830_magic_H048_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S830_magic_H048_attack.info_pool[effectScript.ID].Attacker)
        
		S830_magic_H048_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S830_1")
		PreLoadAvatar("S380_2")
		PreLoadAvatar("S830_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgfhhj" )
		effectScript:RegisterEvent( 8, "dsfdgfh" )
		effectScript:RegisterEvent( 13, "sfdsgfdh" )
		effectScript:RegisterEvent( 24, "fgfgjhj" )
		effectScript:RegisterEvent( 26, "dfdgfjh" )
	end,

	dfgfhhj = function( effectScript )
		SetAnimation(S830_magic_H048_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsfdgfh = function( effectScript )
		AttachAvatarPosEffect(false, S830_magic_H048_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-10, 0), 1.8, 100, "S830_1")
	end,

	sfdsgfdh = function( effectScript )
		AttachAvatarPosEffect(false, S830_magic_H048_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 120), 1.2, 100, "S380_2")
	end,

	fgfgjhj = function( effectScript )
		AttachAvatarPosEffect(false, S830_magic_H048_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S830_2")
	end,

	dfdgfjh = function( effectScript )
			DamageEffect(S830_magic_H048_attack.info_pool[effectScript.ID].Attacker, S830_magic_H048_attack.info_pool[effectScript.ID].Targeter, S830_magic_H048_attack.info_pool[effectScript.ID].AttackType, S830_magic_H048_attack.info_pool[effectScript.ID].AttackDataList, S830_magic_H048_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
