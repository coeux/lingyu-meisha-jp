H039_auto744_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H039_auto744_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H039_auto744_attack.info_pool[effectScript.ID].Attacker)
        
		H039_auto744_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S740_2")
		PreLoadSound("skill_03903")
		PreLoadSound("atalk_03901")
		PreLoadAvatar("S740_3")
		PreLoadSound("skill_03901")
		PreLoadAvatar("S740_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgfhj" )
		effectScript:RegisterEvent( 12, "dsgh" )
		effectScript:RegisterEvent( 22, "fjhgkk" )
		effectScript:RegisterEvent( 26, "dgdh" )
		effectScript:RegisterEvent( 27, "sdfdg" )
	end,

	dfgfhj = function( effectScript )
		SetAnimation(H039_auto744_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsgh = function( effectScript )
		AttachAvatarPosEffect(false, H039_auto744_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 52), 1.5, 100, "S740_2")
		PlaySound("skill_03903")
		PlaySound("atalk_03901")
	end,

	fjhgkk = function( effectScript )
		AttachAvatarPosEffect(false, H039_auto744_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(170, 70), 2, 100, "S740_3")
		PlaySound("skill_03901")
	end,

	dgdh = function( effectScript )
		AttachAvatarPosEffect(false, H039_auto744_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "S740_1")
	end,

	sdfdg = function( effectScript )
			DamageEffect(H039_auto744_attack.info_pool[effectScript.ID].Attacker, H039_auto744_attack.info_pool[effectScript.ID].Targeter, H039_auto744_attack.info_pool[effectScript.ID].AttackType, H039_auto744_attack.info_pool[effectScript.ID].AttackDataList, H039_auto744_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
