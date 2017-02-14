H007_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H007_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H007_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H007_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("q_pugong")
		PreLoadSound("ares")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgsgwef" )
		effectScript:RegisterEvent( 23, "asdf" )
		effectScript:RegisterEvent( 24, "dff" )
		effectScript:RegisterEvent( 25, "cvd" )
	end,

	dgsgwef = function( effectScript )
		SetAnimation(H007_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	asdf = function( effectScript )
		AttachAvatarPosEffect(false, H007_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(120, 60), 1.5, 100, "q_pugong")
	end,

	dff = function( effectScript )
			PlaySound("ares")
	end,

	cvd = function( effectScript )
			DamageEffect(H007_normal_attack.info_pool[effectScript.ID].Attacker, H007_normal_attack.info_pool[effectScript.ID].Targeter, H007_normal_attack.info_pool[effectScript.ID].AttackType, H007_normal_attack.info_pool[effectScript.ID].AttackDataList, H007_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
