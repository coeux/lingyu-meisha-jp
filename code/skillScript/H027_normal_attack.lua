H027_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H027_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H027_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H027_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H027_pugong_1")
		PreLoadAvatar("H027_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "v" )
		effectScript:RegisterEvent( 7, "yujyi" )
		effectScript:RegisterEvent( 15, "dafd" )
		effectScript:RegisterEvent( 20, "dgfd" )
		effectScript:RegisterEvent( 24, "af" )
	end,

	v = function( effectScript )
		SetAnimation(H027_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	yujyi = function( effectScript )
		AttachAvatarPosEffect(false, H027_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(40, 75), 1, 100, "H027_pugong_1")
	end,

	dafd = function( effectScript )
		end,

	dgfd = function( effectScript )
		AttachAvatarPosEffect(false, H027_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -1, 100, "H027_pugong_2")
	end,

	af = function( effectScript )
			DamageEffect(H027_normal_attack.info_pool[effectScript.ID].Attacker, H027_normal_attack.info_pool[effectScript.ID].Targeter, H027_normal_attack.info_pool[effectScript.ID].AttackType, H027_normal_attack.info_pool[effectScript.ID].AttackDataList, H027_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
