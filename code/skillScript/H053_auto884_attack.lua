H053_auto884_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H053_auto884_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H053_auto884_attack.info_pool[effectScript.ID].Attacker)
        
		H053_auto884_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05301")
		PreLoadSound("skill_05301")
		PreLoadAvatar("H053_4_1")
		PreLoadAvatar("H053_4_2")
		PreLoadAvatar("H053_4_2")
		PreLoadAvatar("H053_4_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hjkl" )
		effectScript:RegisterEvent( 18, "dfgy" )
		effectScript:RegisterEvent( 20, "hjklcvb" )
		effectScript:RegisterEvent( 30, "uyhiu" )
		effectScript:RegisterEvent( 32, "mjmng" )
	end,

	hjkl = function( effectScript )
		SetAnimation(H053_auto884_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_05301")
		PlaySound("skill_05301")
	end,

	dfgy = function( effectScript )
		AttachAvatarPosEffect(false, H053_auto884_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -15), 1.3, 100, "H053_4_1")
	end,

	hjklcvb = function( effectScript )
		AttachAvatarPosEffect(false, H053_auto884_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.25, 100, "H053_4_2")
	AttachAvatarPosEffect(false, H053_auto884_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -20), 1.3, 100, "H053_4_2")
	end,

	uyhiu = function( effectScript )
		AttachAvatarPosEffect(false, H053_auto884_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "H053_4_3")
	end,

	mjmng = function( effectScript )
			DamageEffect(H053_auto884_attack.info_pool[effectScript.ID].Attacker, H053_auto884_attack.info_pool[effectScript.ID].Targeter, H053_auto884_attack.info_pool[effectScript.ID].AttackType, H053_auto884_attack.info_pool[effectScript.ID].AttackDataList, H053_auto884_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
