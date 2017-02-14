H034_auto707_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H034_auto707_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H034_auto707_attack.info_pool[effectScript.ID].Attacker)
        
		H034_auto707_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H034_xuli")
		PreLoadAvatar("S647_1")
		PreLoadSound("attack_03402")
		PreLoadSound("atalk_03401")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "safsg" )
		effectScript:RegisterEvent( 18, "dssg" )
		effectScript:RegisterEvent( 33, "fghfj" )
	end,

	safsg = function( effectScript )
		SetAnimation(H034_auto707_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	dssg = function( effectScript )
		AttachAvatarPosEffect(false, H034_auto707_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 0), 0.75, 100, "H034_xuli")
	AttachAvatarPosEffect(false, H034_auto707_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 0), 1, -100, "S647_1")
		PlaySound("attack_03402")
		PlaySound("atalk_03401")
	end,

	fghfj = function( effectScript )
			DamageEffect(H034_auto707_attack.info_pool[effectScript.ID].Attacker, H034_auto707_attack.info_pool[effectScript.ID].Targeter, H034_auto707_attack.info_pool[effectScript.ID].AttackType, H034_auto707_attack.info_pool[effectScript.ID].AttackDataList, H034_auto707_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
