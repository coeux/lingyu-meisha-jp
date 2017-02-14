H034_auto705_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H034_auto705_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H034_auto705_attack.info_pool[effectScript.ID].Attacker)
        
		H034_auto705_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_03301")
		PreLoadSound("stalk_03401")
		PreLoadAvatar("H015_xuli")
		PreLoadAvatar("H015_xuli")
		PreLoadAvatar("H015_xuli")
		PreLoadSound("attack_03201")
		PreLoadAvatar("S700_1")
		PreLoadAvatar("H034_fazhen")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdg" )
		effectScript:RegisterEvent( 12, "dgdh" )
		effectScript:RegisterEvent( 17, "safdg" )
		effectScript:RegisterEvent( 21, "dsg" )
		effectScript:RegisterEvent( 28, "dfgh" )
	end,

	dsfdg = function( effectScript )
		SetAnimation(H034_auto705_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_03301")
		PlaySound("stalk_03401")
	end,

	dgdh = function( effectScript )
		AttachAvatarPosEffect(false, H034_auto705_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-30, 100), 2, 100, "H015_xuli")
	end,

	safdg = function( effectScript )
		AttachAvatarPosEffect(false, H034_auto705_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-30, 100), 2, 100, "H015_xuli")
	end,

	dsg = function( effectScript )
		AttachAvatarPosEffect(false, H034_auto705_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-30, 100), 2, 100, "H015_xuli")
		PlaySound("attack_03201")
	end,

	dfgh = function( effectScript )
		AttachAvatarPosEffect(false, H034_auto705_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S700_1")
	AttachAvatarPosEffect(false, H034_auto705_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, -100, "H034_fazhen")
		DamageEffect(H034_auto705_attack.info_pool[effectScript.ID].Attacker, H034_auto705_attack.info_pool[effectScript.ID].Targeter, H034_auto705_attack.info_pool[effectScript.ID].AttackType, H034_auto705_attack.info_pool[effectScript.ID].AttackDataList, H034_auto705_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}