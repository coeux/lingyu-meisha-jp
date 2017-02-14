H016_auto94_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H016_auto94_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H016_auto94_attack.info_pool[effectScript.ID].Attacker)
        
		H016_auto94_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S322_2")
		PreLoadSound("atalk_01601")
		PreLoadAvatar("S322_3")
		PreLoadAvatar("S322_4")
		PreLoadAvatar("S322_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adff" )
		effectScript:RegisterEvent( 16, "sdfdhg" )
		effectScript:RegisterEvent( 19, "sfdf" )
		effectScript:RegisterEvent( 30, "dgdfh" )
		effectScript:RegisterEvent( 32, "adfdsg" )
		effectScript:RegisterEvent( 33, "ghfj" )
		effectScript:RegisterEvent( 34, "adsaf" )
		effectScript:RegisterEvent( 36, "afdsf" )
		effectScript:RegisterEvent( 37, "dasf" )
	end,

	adff = function( effectScript )
		SetAnimation(H016_auto94_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	sdfdhg = function( effectScript )
	end,

	sfdf = function( effectScript )
		AttachAvatarPosEffect(false, H016_auto94_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 80), 1.8, 100, "S322_2")
	end,

	dgdfh = function( effectScript )
		PlaySound("atalk_01601")
	end,

	adfdsg = function( effectScript )
		AttachAvatarPosEffect(false, H016_auto94_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(110, 20), 2, 100, "S322_3")
	end,

	ghfj = function( effectScript )
	end,

	adsaf = function( effectScript )
		AttachAvatarPosEffect(false, H016_auto94_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 0), 1.5, 100, "S322_4")
	end,

	afdsf = function( effectScript )
		AttachAvatarPosEffect(false, H016_auto94_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "S322_1")
	end,

	dasf = function( effectScript )
			DamageEffect(H016_auto94_attack.info_pool[effectScript.ID].Attacker, H016_auto94_attack.info_pool[effectScript.ID].Targeter, H016_auto94_attack.info_pool[effectScript.ID].AttackType, H016_auto94_attack.info_pool[effectScript.ID].AttackDataList, H016_auto94_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
