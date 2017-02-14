H014_auto146_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H014_auto146_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H014_auto146_attack.info_pool[effectScript.ID].Attacker)
        
		H014_auto146_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("wing01_4")
		PreLoadAvatar("wing01_2")
		PreLoadAvatar("wing01_4")
		PreLoadAvatar("wing01_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 1, "sdfdh" )
	end,

	a = function( effectScript )
		SetAnimation(H014_auto146_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	AttachAvatarPosEffect(false, H014_auto146_attack.info_pool[effectScript.ID].Attacker, AvatarPos.right_wing, Vector2(0, 0), 1, -100, "wing01_4")
	AttachAvatarPosEffect(false, H014_auto146_attack.info_pool[effectScript.ID].Attacker, AvatarPos.right_wing, Vector2(0, 0), 1, -100, "wing01_2")
	AttachAvatarPosEffect(false, H014_auto146_attack.info_pool[effectScript.ID].Attacker, AvatarPos.left_wing, Vector2(0, 0), 1, -100, "wing01_4")
	AttachAvatarPosEffect(false, H014_auto146_attack.info_pool[effectScript.ID].Attacker, AvatarPos.left_wing, Vector2(0, 0), 1, -100, "wing01_2")
	end,

	sdfdh = function( effectScript )
		end,

}
