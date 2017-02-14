H022_auto345_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H022_auto345_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H022_auto345_attack.info_pool[effectScript.ID].Attacker)
        
		H022_auto345_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0224")
		PreLoadAvatar("S222_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sf" )
		effectScript:RegisterEvent( 26, "af" )
		effectScript:RegisterEvent( 27, "das" )
	end,

	sf = function( effectScript )
		SetAnimation(H022_auto345_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("s0224")
	end,

	af = function( effectScript )
		AttachAvatarPosEffect(false, H022_auto345_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -2, 100, "S222_2")
	end,

	das = function( effectScript )
			DamageEffect(H022_auto345_attack.info_pool[effectScript.ID].Attacker, H022_auto345_attack.info_pool[effectScript.ID].Targeter, H022_auto345_attack.info_pool[effectScript.ID].AttackType, H022_auto345_attack.info_pool[effectScript.ID].AttackDataList, H022_auto345_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
