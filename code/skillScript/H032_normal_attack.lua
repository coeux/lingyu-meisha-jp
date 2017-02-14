H032_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H032_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H032_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H032_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H032_pugong")
		PreLoadSound("attack_03201")
		PreLoadAvatar("q_pugong")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 18, "dsfdhg" )
		effectScript:RegisterEvent( 20, "gfh" )
		effectScript:RegisterEvent( 22, "shanghai" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H032_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	dsfdhg = function( effectScript )
		AttachAvatarPosEffect(false, H032_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, 80), 1.2, 100, "H032_pugong")
		PlaySound("attack_03201")
	end,

	gfh = function( effectScript )
		AttachAvatarPosEffect(false, H032_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(50, 80), -1.5, 100, "q_pugong")
	end,

	shanghai = function( effectScript )
			DamageEffect(H032_normal_attack.info_pool[effectScript.ID].Attacker, H032_normal_attack.info_pool[effectScript.ID].Targeter, H032_normal_attack.info_pool[effectScript.ID].AttackType, H032_normal_attack.info_pool[effectScript.ID].AttackDataList, H032_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
