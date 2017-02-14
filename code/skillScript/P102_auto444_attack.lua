P102_auto444_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P102_auto444_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P102_auto444_attack.info_pool[effectScript.ID].Attacker)
        
		P102_auto444_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s01026")
		PreLoadAvatar("S430_3")
		PreLoadSound("atalk_010201")
		PreLoadAvatar("S430_5")
		PreLoadAvatar("S430_4")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hgfh" )
		effectScript:RegisterEvent( 27, "dsfdg" )
		effectScript:RegisterEvent( 28, "sfdfg" )
		effectScript:RegisterEvent( 31, "asfdsf" )
		effectScript:RegisterEvent( 32, "sasfd" )
	end,

	hgfh = function( effectScript )
		SetAnimation(P102_auto444_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("s01026")
	end,

	dsfdg = function( effectScript )
		AttachAvatarPosEffect(false, P102_auto444_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 70), 1, 100, "S430_3")
		PlaySound("atalk_010201")
	end,

	sfdfg = function( effectScript )
		AttachAvatarPosEffect(false, P102_auto444_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 70), 1.5, 100, "S430_5")
	end,

	asfdsf = function( effectScript )
		AttachAvatarPosEffect(false, P102_auto444_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.8, 100, "S430_4")
	end,

	sasfd = function( effectScript )
			DamageEffect(P102_auto444_attack.info_pool[effectScript.ID].Attacker, P102_auto444_attack.info_pool[effectScript.ID].Targeter, P102_auto444_attack.info_pool[effectScript.ID].AttackType, P102_auto444_attack.info_pool[effectScript.ID].AttackDataList, P102_auto444_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
