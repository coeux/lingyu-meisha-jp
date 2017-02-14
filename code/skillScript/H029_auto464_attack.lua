H029_auto464_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H029_auto464_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H029_auto464_attack.info_pool[effectScript.ID].Attacker)
        
		H029_auto464_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0291")
		PreLoadAvatar("H029_shifa_2")
		PreLoadAvatar("H029_shouji_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hjhgk" )
		effectScript:RegisterEvent( 34, "fdhgfj" )
		effectScript:RegisterEvent( 35, "hgkjhk" )
		effectScript:RegisterEvent( 38, "sfdg" )
		effectScript:RegisterEvent( 40, "jhgkjhk" )
	end,

	hjhgk = function( effectScript )
		SetAnimation(H029_auto464_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("s0291")
	end,

	fdhgfj = function( effectScript )
		end,

	hgkjhk = function( effectScript )
		AttachAvatarPosEffect(false, H029_auto464_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -20), 1.2, 100, "H029_shifa_2")
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, H029_auto464_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.2, 100, "H029_shouji_2")
	end,

	jhgkjhk = function( effectScript )
			DamageEffect(H029_auto464_attack.info_pool[effectScript.ID].Attacker, H029_auto464_attack.info_pool[effectScript.ID].Targeter, H029_auto464_attack.info_pool[effectScript.ID].AttackType, H029_auto464_attack.info_pool[effectScript.ID].AttackDataList, H029_auto464_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
