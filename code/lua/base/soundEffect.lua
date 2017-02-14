--soundEffect.lua
--============================================================================-
--============================================================================-
--所有声效定义
--

SoundEffect = 
{
	--通用
	common_click_close_btn = '';							--点击关闭按钮 一般为右上角的叉
	common_click_back_btn = '';								--点击返回按钮 一般有返回字样
	common_click_common_btn = '';							--点击普通按钮
	common_change_tabpage = '';								--切换分页
	common_success = '';									--升级/强化成功
	common_buy = '';										--商店购买音效？这个算通用？
	common_start_fight = '';								--开始战斗

	--登录
	login_enter_game = '';									--登录游戏
	
	--主城
	_around = '';											--场景环境音效？
	_npc = '';												--NPC交互？
	
	--战斗
	fight_get_card = '';									--技能卡 发牌
	fight_use_card = '';									--技能卡 出牌
	fight_del_card = '';									--技能卡 销毁
	fight_combo = '';										--combo值到了某个值的时候触发的音效
	fight_skill = '';										--立绘技能
	fight_win = '';											--战斗胜利
	fight_lose = '';										--战斗失败

	--升星
	rank_up_success = '';									--升星成功

	--装备
	equip_rank_up_success = '';								--装备升阶成功

	--宝石
	gem_inlay = '';											--宝石镶嵌
	gem_outoff = '';										--宝石卸下
	gem_syn = '';											--宝石合成

	--队伍
	
	--副本界面
	dungeons_enter_scene = '';								--进入副本场景
	dungeons_enter_fight = '';								--进入战斗
	
	--抽卡
	chouka_result = '';										--抽卡结果
	
	--公会
	gonghui_fuli_zhuanpan = '';								--轮盘转动
	gonghui_fuli_result = '';								--福利轮盘转动结果
	gonghui_boss_summon = '';								--召唤公会boss

	--秘境
	treasure_occupy = '';									--占领宝库
	treasure_defense = '';									--防守宝库
	
	--世界boss
	world_boss_count_down = '';								--世界boss倒计时？
	
	--远征
	
	
	--炼金
	lianjin_normal = '';									--普通炼金
	lianjin_small = '';										--炼金小爆击
	lianjin_big = '';										--炼金大爆击
	
	--任务
	task_complete = '';										--完成任务
	
	--星魂
	xinghun_refresh = '';									--刷新星魂
	
	--爱恋度
	lovetask_finish = '';									--爱恋度完成
};

SceneSound = 
{
	--家界面
	homePanel = '';

	
}
