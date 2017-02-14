P102_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P102_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P102_normal_attack.info_pool[effectScript.ID].Attacker)
        
		P102_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s01021")
		PreLoadAvatar("P102_pugong_3")
		PreLoadSound("atalk_010201")
		PreLoadAvatar("P102_pugong_2")
		PreLoadAvatar("P102_pugong_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asfdf" )
		effectScript:RegisterEvent( 30, "sfdf" )
		effectScript:RegisterEvent( 31, "dsff" )
		effectScript:RegisterEvent( 33, "dsfg" )
		effectScript:RegisterEvent( 35, "fdg" )
	end,

	asfdf = function( effectScript )
		SetAnimation(P102_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("s01021")
	end,

	sfdf = function( effectScript )
		AttachAvatarPosEffect(false, P102_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 100), 1, 100, "P102_pugong_3")
		PlaySound("atalk_010201")
	end,

	dsff = function( effectScript )
		AttachAvatarPosEffect(false, P102_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "P102_pugong_2")
	end,

	dsfg = function( effectScript )
		AttachAvatarPosEffect(false, P102_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -1.5, 100, "P102_pugong_1")
	end,

	fdg = function( effectScript )
			DamageEffect(P102_normal_attack.info_pool[effectScript.ID].Attacker, P102_normal_attack.info_pool[effectScript.ID].Targeter, P102_normal_attack.info_pool[effectScript.ID].AttackType, P102_normal_attack.info_pool[effectScript.ID].AttackDataList, P102_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
