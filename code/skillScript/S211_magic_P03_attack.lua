S211_magic_P03_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S211_magic_P03_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S211_magic_P03_attack.info_pool[effectScript.ID].Attacker)
		S211_magic_P03_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("caijuezhiren")
		PreLoadAvatar("S211_P03")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "safr" )
		effectScript:RegisterEvent( 5, "df" )
		effectScript:RegisterEvent( 12, "safqwt" )
		effectScript:RegisterEvent( 31, "sxger" )
		effectScript:RegisterEvent( 36, "WFAF" )
	end,

	safr = function( effectScript )
		SetAnimation(S211_magic_P03_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("caijuezhiren")
	end,

	safqwt = function( effectScript )
		AttachAvatarPosEffect(false, S211_magic_P03_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1, 100, "S211_P03")
	end,

	sxger = function( effectScript )
			DamageEffect(S211_magic_P03_attack.info_pool[effectScript.ID].Attacker, S211_magic_P03_attack.info_pool[effectScript.ID].Targeter, S211_magic_P03_attack.info_pool[effectScript.ID].AttackType, S211_magic_P03_attack.info_pool[effectScript.ID].AttackDataList, S211_magic_P03_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	WFAF = function( effectScript )
		CameraShake()
	end,

}
