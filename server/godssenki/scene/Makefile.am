INCLUDES= -I$(top_srcdir)/yslib/ys_log 				\
		  -I$(top_srcdir)/yslib/mysql 				\
		  -I$(top_srcdir)/yslib/heart_beat 			\
		  -I$(top_srcdir)/yslib/perf 				\
		  -I$(top_srcdir)/yslib/utility 			\
		  -I$(top_srcdir)/yslib/rpc 				\
		  -I$(top_srcdir)/yslib/thread_pool 		\
		  -I$(top_srcdir)/yslib/package 			\
		  -I$(top_srcdir)/yslib/ys_lua/include  	\
		  -I$(top_srcdir)/yslib/ys_lua/lua-5.1.4 	\
		  -I$(top_srcdir)/yslib/ys_jpack 			\
		  -I$(top_srcdir)/yslib/db_service 			\
		  -I$(top_srcdir)/yslib/event 				\
		  -I../common/

CXXFLAGS = -Wall -g -O2 -fPIC -Wno-deprecated -std=c++0x -m64 -pipe -DUSE_TBB_MALLOC -DDEBUG_LOG -L/usr/lib64/mysql

LDFLAGS  = 

#LD_PRELOAD=/usr/lib/libtcmalloc_minimal4.so
#-ltcmalloc_minimal

scene_LDADD =\
				../common/libcommon.a\
				$(top_srcdir)/yslib/ys_jpack/libys_jpack.a    \
				$(top_srcdir)/yslib/rpc/libys_rpc.a            \
				$(top_srcdir)/yslib/thread_pool/libys_thread_pool.a            \
				$(top_srcdir)/yslib/ys_lua/libys_lua.a     	\
				$(top_srcdir)/yslib/perf/libys_perf.a         \
				$(top_srcdir)/yslib/db_service/libys_db_service.a \
				$(top_srcdir)/yslib/mysql/libys_mysql.a        \
				$(top_srcdir)/yslib/utility/libys_utility.a    \
				$(top_srcdir)/yslib/ys_log/libys_log.a         \
				/usr/local/lib/libboost_system-mt.a\
				/usr/local/lib/libboost_thread-mt.a\
				/usr/local/lib/libboost_regex-mt.a\
				-lreadline\
				-lcurl\
				-lcrypto\
				-lpthread\
				-ltbb\
				-ltbbmalloc\
				-lmysqlclient\
				-lrt\
				-lz\
				-ldl 

bin_PROGRAMS = scene 

noinst_PROGRAMS = 
noinst_LIBRARIES = 

scene_SOURCES = 		\
		sc_card_comment.cpp\
		sc_equip.cpp\
		sc_skill.cpp\
		sc_partner.cpp\
		sc_bag.cpp\
		sc_item.cpp\
		sc_team.cpp\
		sc_pro.cpp\
		sc_user.cpp\
		sc_cache.cpp\
		sc_pub.cpp\
		sc_city.cpp\
		sc_reward.cpp\
		sc_round.cpp\
		sc_new_round.cpp\
		sc_trial.cpp\
		sc_message.cpp\
		sc_task.cpp\
		sc_act_daily_task.cpp\
		sc_vip.cpp\
		sc_arena.cpp\
		sc_arena_rank.cpp\
		sc_boss.cpp\
		sc_battle_record.cpp\
		sc_arena_page_cache.cpp\
		sc_gang.cpp\
		sc_friend.cpp\
		sc_practice.cpp\
		sc_new_rune.cpp\
		sc_statics.cpp\
		sc_shop.cpp\
		sc_guidence.cpp\
		sc_test.cpp\
		sc_name.cpp\
		sc_service.cpp \
		sc_invcode_client.cpp\
		sc_session.cpp\
		sc_lua.cpp\
		sc_server.cpp\
		sc_treasure.cpp\
		sc_pay.cpp\
		sc_star.cpp\
		sc_city_boss.cpp\
		sc_scuffle.cpp\
		sc_bullet.cpp\
		sc_fp_rank.cpp\
		sc_lv_rank.cpp\
		sc_activity.cpp\
		sc_gmail.cpp\
		sc_rank_season.cpp\
		sc_guild_battle.cpp\
		sc_logic.cpp\
		sc_limit_round.cpp\
		sc_wing.cpp\
		sc_chronicle.cpp\
		sc_love_task.cpp\
		sc_battle_pvp.cpp\
		sc_sign.cpp\
		sc_union_rank.cpp\
		sc_card_rank.cpp\
		sc_friend_flower.cpp\
		sc_reward_mcard.cpp\
		sc_rank.cpp\
		sc_card_event.cpp\
		sc_achievement.cpp\
		sc_soul.cpp\
		sc_rank_match.cpp\
		sc_soulrank.cpp\
		sc_chip_smash.cpp\
		sc_gem_page.cpp\
		sc_farm.cpp\
		sc_pub_rank.cpp\
		sc_pet.cpp\
		sc_combo_pro.cpp\
		sc_report.cpp\
		sc_pub_mgr.cpp\
		main.cpp
