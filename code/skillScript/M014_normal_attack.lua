M014_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M014_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M014_normal_attack.info_pool[effectScript.ID].Attacker)
        
		M014_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("M014_pugong_1")
		PreLoadAvatar("S430_4")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "jjhlkl" )
		effectScript:RegisterEvent( 16, "uyiuo" )
		effectScript:RegisterEvent( 18, "dgfdhgh" )
		effectScript:RegisterEvent( 20, "hgfjhgjhg" )
	end,

	jjhlkl = function( effectScript )
		SetAnimation(M014_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	uyiuo = function( effectScript )
		AttachAvatarPosEffect(false, M014_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 90), 1.5, 100, "M014_pugong_1")
	end,

	dgfdhgh = function( effectScript )
		AttachAvatarPosEffect(false, M014_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S430_4")
	end,

	hgfjhgjhg = function( effectScript )
			DamageEffect(M014_normal_attack.info_pool[effectScript.ID].Attacker, M014_normal_attack.info_pool[effectScript.ID].Targeter, M014_normal_attack.info_pool[effectScript.ID].AttackType, M014_normal_attack.info_pool[effectScript.ID].AttackDataList, M014_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
