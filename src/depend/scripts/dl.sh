#!/bin/sh
perl gamelist.pl -o driverlist.h -l gamelist.txt \
../../burn/drv/cave/cave.cpp \
../../burn/drv/cave/cave_palette.cpp \
../../burn/drv/cave/cave_sprite.cpp \
../../burn/drv/cave/cave_tile.cpp \
../../burn/drv/cave/d_dodonpachi.cpp \
../../burn/drv/cave/d_donpachi.cpp \
../../burn/drv/cave/d_esprade.cpp \
../../burn/drv/cave/d_feversos.cpp \
../../burn/drv/cave/d_gaia.cpp \
../../burn/drv/cave/d_guwange.cpp \
../../burn/drv/cave/d_hotdogst.cpp \
../../burn/drv/cave/d_korokoro.cpp \
../../burn/drv/cave/d_mazinger.cpp \
../../burn/drv/cave/d_metmqstr.cpp \
../../burn/drv/cave/d_pwrinst2.cpp \
../../burn/drv/cave/d_sailormn.cpp \
../../burn/drv/cave/d_tjumpman.cpp \
../../burn/drv/cave/d_uopoko.cpp \
../../burn/drv/capcom/cps.cpp \
../../burn/drv/capcom/cps2_crpt.cpp \
../../burn/drv/capcom/cpsr.cpp \
../../burn/drv/capcom/cpsrd.cpp \
../../burn/drv/capcom/cpst.cpp \
../../burn/drv/capcom/cps_config.cpp \
../../burn/drv/capcom/cps_draw.cpp \
../../burn/drv/capcom/cps_mem.cpp \
../../burn/drv/capcom/cps_obj.cpp \
../../burn/drv/capcom/cps_pal.cpp \
../../burn/drv/capcom/cps_run.cpp \
../../burn/drv/capcom/cps_rw.cpp \
../../burn/drv/capcom/cps_scr.cpp \
../../burn/drv/capcom/ctv.cpp \
../../burn/drv/capcom/ctv_make.cpp \
../../burn/drv/capcom/d_cps1.cpp \
../../burn/drv/capcom/d_cps2.cpp \
../../burn/drv/capcom/kabuki.cpp \
../../burn/drv/capcom/ps.cpp \
../../burn/drv/capcom/ps_m.cpp \
../../burn/drv/capcom/ps_z.cpp \
../../burn/drv/capcom/qs.cpp \
../../burn/drv/capcom/qs_c.cpp \
../../burn/drv/capcom/qs_z.cpp \
../../burn/drv/cps3/cps3run.cpp \
../../burn/drv/cps3/cps3snd.cpp \
../../burn/drv/cps3/d_cps3.cpp \
../../burn/drv/dataeast/deco16ic.cpp \
../../burn/drv/dataeast/d_backfire.cpp \
../../burn/drv/dataeast/d_boogwing.cpp \
../../burn/drv/dataeast/d_cbuster.cpp \
../../burn/drv/dataeast/d_cninja.cpp \
../../burn/drv/dataeast/d_darkseal.cpp \
../../burn/drv/dataeast/d_dassault.cpp \
../../burn/drv/dataeast/d_dec0.cpp \
../../burn/drv/dataeast/d_dec8.cpp \
../../burn/drv/dataeast/d_dietgogo.cpp \
../../burn/drv/dataeast/d_funkyjet.cpp \
../../burn/drv/dataeast/d_karnov.cpp \
../../burn/drv/dataeast/d_lemmings.cpp \
../../burn/drv/dataeast/d_rohga.cpp \
../../burn/drv/dataeast/d_sidepckt.cpp \
../../burn/drv/dataeast/d_simpl156.cpp \
../../burn/drv/dataeast/d_supbtime.cpp \
../../burn/drv/dataeast/d_tumblep.cpp \
../../burn/drv/dataeast/d_vaportra.cpp \
../../burn/drv/sega/d_angelkds.cpp \
../../burn/drv/sega/d_bankp.cpp \
../../burn/drv/sega/d_dotrikun.cpp \
../../burn/drv/sega/d_hangon.cpp \
../../burn/drv/sega/d_outrun.cpp \
../../burn/drv/sega/d_suprloco.cpp \
../../burn/drv/sega/d_sys1.cpp \
../../burn/drv/sega/d_sys16a.cpp \
../../burn/drv/sega/d_sys16b.cpp \
../../burn/drv/sega/d_sys18.cpp \
../../burn/drv/sega/d_xbrd.cpp \
../../burn/drv/sega/d_ybrd.cpp \
../../burn/drv/sega/fd1089.cpp \
../../burn/drv/sega/fd1094.cpp \
../../burn/drv/sega/genesis_vid.cpp \
../../burn/drv/sega/mc8123.cpp \
../../burn/drv/sega/sys16_fd1094.cpp \
../../burn/drv/sega/sys16_gfx.cpp \
../../burn/drv/sega/sys16_run.cpp \
../../burn/drv/galaxian/d_galaxian.cpp \
../../burn/drv/galaxian/gal_gfx.cpp \
../../burn/drv/galaxian/gal_run.cpp \
../../burn/drv/galaxian/gal_sound.cpp \
../../burn/drv/galaxian/gal_stars.cpp \
../../burn/drv/irem/d_m62.cpp \
../../burn/drv/irem/d_m63.cpp \
../../burn/drv/irem/d_m72.cpp \
../../burn/drv/irem/d_m90.cpp \
../../burn/drv/irem/d_m92.cpp \
../../burn/drv/irem/d_vigilant.cpp \
../../burn/drv/irem/irem_cpu.cpp \
../../burn/drv/pst90s/d_1945kiii.cpp \
../../burn/drv/pst90s/d_aerofgt.cpp \
../../burn/drv/pst90s/d_airbustr.cpp \
../../burn/drv/pst90s/d_aquarium.cpp \
../../burn/drv/pst90s/d_blmbycar.cpp \
../../burn/drv/pst90s/d_bloodbro.cpp \
../../burn/drv/pst90s/d_crospang.cpp \
../../burn/drv/pst90s/d_crshrace.cpp \
../../burn/drv/pst90s/d_dcon.cpp \
../../burn/drv/pst90s/d_ddragon3.cpp \
../../burn/drv/pst90s/d_deniam.cpp \
../../burn/drv/pst90s/d_diverboy.cpp \
../../burn/drv/pst90s/d_drtomy.cpp \
../../burn/drv/pst90s/d_egghunt.cpp \
../../burn/drv/pst90s/d_esd16.cpp \
../../burn/drv/pst90s/d_f1gp.cpp \
../../burn/drv/pst90s/d_fstarfrc.cpp \
../../burn/drv/pst90s/d_funybubl.cpp \
../../burn/drv/pst90s/d_fuukifg3.cpp \
../../burn/drv/pst90s/d_gaelco.cpp \
../../burn/drv/pst90s/d_gaiden.cpp \
../../burn/drv/pst90s/d_galpanic.cpp \
../../burn/drv/pst90s/d_gotcha.cpp \
../../burn/drv/pst90s/d_gumbo.cpp \
../../burn/drv/pst90s/d_hyperpac.cpp \
../../burn/drv/pst90s/d_jchan.cpp \
../../burn/drv/pst90s/d_kaneko16.cpp \
../../burn/drv/pst90s/d_lordgun.cpp \
../../burn/drv/pst90s/d_mcatadv.cpp \
../../burn/drv/pst90s/d_midas.cpp \
../../burn/drv/pst90s/d_mugsmash.cpp \
../../burn/drv/pst90s/d_news.cpp \
../../burn/drv/pst90s/d_nmg5.cpp \
../../burn/drv/pst90s/d_nmk16.cpp \
../../burn/drv/pst90s/d_ohmygod.cpp \
../../burn/drv/pst90s/d_pass.cpp \
../../burn/drv/pst90s/d_pirates.cpp \
../../burn/drv/pst90s/d_pktgaldx.cpp \
../../burn/drv/pst90s/d_powerins.cpp \
../../burn/drv/pst90s/d_pushman.cpp \
../../burn/drv/pst90s/d_raiden.cpp \
../../burn/drv/pst90s/d_seta.cpp \
../../burn/drv/pst90s/d_seta2.cpp \
../../burn/drv/pst90s/d_shadfrce.cpp \
../../burn/drv/pst90s/d_silkroad.cpp \
../../burn/drv/pst90s/d_speedspn.cpp \
../../burn/drv/pst90s/d_suna16.cpp \
../../burn/drv/pst90s/d_suprnova.cpp \
../../burn/drv/pst90s/d_taotaido.cpp \
../../burn/drv/pst90s/d_tecmosys.cpp \
../../burn/drv/pst90s/d_tumbleb.cpp \
../../burn/drv/pst90s/d_unico.cpp \
../../burn/drv/pst90s/d_vmetal.cpp \
../../burn/drv/pst90s/d_welltris.cpp \
../../burn/drv/pst90s/d_wwfwfest.cpp \
../../burn/drv/pst90s/d_xorworld.cpp \
../../burn/drv/pst90s/d_yunsun16.cpp \
../../burn/drv/pst90s/d_zerozone.cpp \
../../burn/drv/pst90s/nmk004.cpp \
../../burn/drv/konami/d_88games.cpp \
../../burn/drv/konami/d_ajax.cpp \
../../burn/drv/konami/d_aliens.cpp \
../../burn/drv/konami/d_blockhl.cpp \
../../burn/drv/konami/d_bottom9.cpp \
../../burn/drv/konami/d_contra.cpp \
../../burn/drv/konami/d_crimfght.cpp \
../../burn/drv/konami/d_gberet.cpp \
../../burn/drv/konami/d_gbusters.cpp \
../../burn/drv/konami/d_gradius3.cpp \
../../burn/drv/konami/d_gyruss.cpp \
../../burn/drv/konami/d_hcastle.cpp \
../../burn/drv/konami/d_hexion.cpp \
../../burn/drv/konami/d_mainevt.cpp \
../../burn/drv/konami/d_mogura.cpp \
../../burn/drv/konami/d_parodius.cpp \
../../burn/drv/konami/d_pooyan.cpp \
../../burn/drv/konami/d_rollerg.cpp \
../../burn/drv/konami/d_scotrsht.cpp \
../../burn/drv/konami/d_simpsons.cpp \
../../burn/drv/konami/d_spy.cpp \
../../burn/drv/konami/d_surpratk.cpp \
../../burn/drv/konami/d_thunderx.cpp \
../../burn/drv/konami/d_tmnt.cpp \
../../burn/drv/konami/d_twin16.cpp \
../../burn/drv/konami/d_ultraman.cpp \
../../burn/drv/konami/d_vendetta.cpp \
../../burn/drv/konami/d_xmen.cpp \
../../burn/drv/konami/k051316.cpp \
../../burn/drv/konami/k051733.cpp \
../../burn/drv/konami/k051960.cpp \
../../burn/drv/konami/k052109.cpp \
../../burn/drv/konami/k053245.cpp \
../../burn/drv/konami/k053247.cpp \
../../burn/drv/konami/k053251.cpp \
../../burn/drv/konami/k053936.cpp \
../../burn/drv/konami/k054000.cpp \
../../burn/drv/konami/konamiic.cpp \
../../burn/drv/megadrive/d_megadrive.cpp \
../../burn/drv/megadrive/megadrive.cpp \
../../burn/drv/neogeo/d_neogeo.cpp \
../../burn/drv/neogeo/neogeo.cpp \
../../burn/drv/neogeo/neo_decrypt.cpp \
../../burn/drv/neogeo/neo_palette.cpp \
../../burn/drv/neogeo/neo_run.cpp \
../../burn/drv/neogeo/neo_sprite.cpp \
../../burn/drv/neogeo/neo_text.cpp \
../../burn/drv/neogeo/neo_upd4990a.cpp \
../../burn/drv/pgm/d_pgm.cpp \
../../burn/drv/pgm/pgm_crypt.cpp \
../../burn/drv/pgm/pgm_draw.cpp \
../../burn/drv/pgm/pgm_prot.cpp \
../../burn/drv/pgm/pgm_run.cpp \
../../burn/drv/pgm/pgm_sprite_create.cpp \
../../burn/drv/psikyo/d_psikyo.cpp \
../../burn/drv/psikyo/d_psikyo4.cpp \
../../burn/drv/psikyo/d_psikyosh.cpp \
../../burn/drv/psikyo/psikyosh_render.cpp \
../../burn/drv/psikyo/psikyo_palette.cpp \
../../burn/drv/psikyo/psikyo_sprite.cpp \
../../burn/drv/psikyo/psikyo_tile.cpp \
../../burn/drv/snes/d_snes.cpp \
../../burn/drv/snes/snes_65816.cpp \
../../burn/drv/snes/snes_io.cpp \
../../burn/drv/snes/snes_main.cpp \
../../burn/drv/snes/snes_mem.cpp \
../../burn/drv/snes/snes_ppu.cpp \
../../burn/drv/snes/snes_spc700.cpp \
../../burn/drv/taito/cchip.cpp \
../../burn/drv/taito/d_arkanoid.cpp \
../../burn/drv/taito/d_ashnojoe.cpp \
../../burn/drv/taito/d_asuka.cpp \
../../burn/drv/taito/d_bublbobl.cpp \
../../burn/drv/taito/d_chaknpop.cpp \
../../burn/drv/taito/d_darius2.cpp \
../../burn/drv/taito/d_flstory.cpp \
../../burn/drv/taito/d_lkage.cpp \
../../burn/drv/taito/d_minivdr.cpp \
../../burn/drv/taito/d_othunder.cpp \
../../burn/drv/taito/d_retofinv.cpp \
../../burn/drv/taito/d_slapshot.cpp \
../../burn/drv/taito/d_superchs.cpp \
../../burn/drv/taito/d_taitob.cpp \
../../burn/drv/taito/d_taitof2.cpp \
../../burn/drv/taito/d_taitomisc.cpp \
../../burn/drv/taito/d_taitox.cpp \
../../burn/drv/taito/d_taitoz.cpp \
../../burn/drv/taito/d_tnzs.cpp \
../../burn/drv/taito/pc080sn.cpp \
../../burn/drv/taito/pc090oj.cpp \
../../burn/drv/taito/taito.cpp \
../../burn/drv/taito/taito_ic.cpp \
../../burn/drv/taito/taito_m68705.cpp \
../../burn/drv/taito/tc0100scn.cpp \
../../burn/drv/taito/tc0110pcr.cpp \
../../burn/drv/taito/tc0140syt.cpp \
../../burn/drv/taito/tc0150rod.cpp \
../../burn/drv/taito/tc0180vcu.cpp \
../../burn/drv/taito/tc0220ioc.cpp \
../../burn/drv/taito/tc0280grd.cpp \
../../burn/drv/taito/tc0360pri.cpp \
../../burn/drv/taito/tc0480scp.cpp \
../../burn/drv/taito/tc0510nio.cpp \
../../burn/drv/taito/tc0640fio.cpp \
../../burn/drv/taito/tnzs_prot.cpp \
../../burn/drv/toaplan/d_batrider.cpp \
../../burn/drv/toaplan/d_batsugun.cpp \
../../burn/drv/toaplan/d_battleg.cpp \
../../burn/drv/toaplan/d_bbakraid.cpp \
../../burn/drv/toaplan/d_demonwld.cpp \
../../burn/drv/toaplan/d_dogyuun.cpp \
../../burn/drv/toaplan/d_fixeight.cpp \
../../burn/drv/toaplan/d_ghox.cpp \
../../burn/drv/toaplan/d_hellfire.cpp \
../../burn/drv/toaplan/d_kbash.cpp \
../../burn/drv/toaplan/d_kbash2.cpp \
../../burn/drv/toaplan/d_mahoudai.cpp \
../../burn/drv/toaplan/d_outzone.cpp \
../../burn/drv/toaplan/d_pipibibs.cpp \
../../burn/drv/toaplan/d_rallybik.cpp \
../../burn/drv/toaplan/d_samesame.cpp \
../../burn/drv/toaplan/d_shippumd.cpp \
../../burn/drv/toaplan/d_snowbro2.cpp \
../../burn/drv/toaplan/d_tekipaki.cpp \
../../burn/drv/toaplan/d_tigerheli.cpp \
../../burn/drv/toaplan/d_truxton.cpp \
../../burn/drv/toaplan/d_truxton2.cpp \
../../burn/drv/toaplan/d_vfive.cpp \
../../burn/drv/toaplan/d_vimana.cpp \
../../burn/drv/toaplan/d_zerowing.cpp \
../../burn/drv/toaplan/toaplan.cpp \
../../burn/drv/toaplan/toaplan1.cpp \
../../burn/drv/toaplan/toa_bcu2.cpp \
../../burn/drv/toaplan/toa_extratext.cpp \
../../burn/drv/toaplan/toa_gp9001.cpp \
../../burn/drv/toaplan/toa_palette.cpp \
../../burn/drv/pre90s/d_1942.cpp \
../../burn/drv/pre90s/d_1943.cpp \
../../burn/drv/pre90s/d_4enraya.cpp \
../../burn/drv/pre90s/d_ambush.cpp \
../../burn/drv/pre90s/d_arabian.cpp \
../../burn/drv/pre90s/d_armedf.cpp \
../../burn/drv/pre90s/d_aztarac.cpp \
../../burn/drv/pre90s/d_baraduke.cpp \
../../burn/drv/pre90s/d_bionicc.cpp \
../../burn/drv/pre90s/d_blktiger.cpp \
../../burn/drv/pre90s/d_blockout.cpp \
../../burn/drv/pre90s/d_blueprnt.cpp \
../../burn/drv/pre90s/d_bombjack.cpp \
../../burn/drv/pre90s/d_commando.cpp \
../../burn/drv/pre90s/d_ddragon.cpp \
../../burn/drv/pre90s/d_dynduke.cpp \
../../burn/drv/pre90s/d_epos.cpp \
../../burn/drv/pre90s/d_exedexes.cpp \
../../burn/drv/pre90s/d_funkybee.cpp \
../../burn/drv/pre90s/d_galaga.cpp \
../../burn/drv/pre90s/d_gauntlet.cpp \
../../burn/drv/pre90s/d_ginganin.cpp \
../../burn/drv/pre90s/d_gng.cpp \
../../burn/drv/pre90s/d_gunsmoke.cpp \
../../burn/drv/pre90s/d_higemaru.cpp \
../../burn/drv/pre90s/d_ikki.cpp \
../../burn/drv/pre90s/d_jack.cpp \
../../burn/drv/pre90s/d_kangaroo.cpp \
../../burn/drv/pre90s/d_kyugo.cpp \
../../burn/drv/pre90s/d_ladybug.cpp \
../../burn/drv/pre90s/d_lwings.cpp \
../../burn/drv/pre90s/d_madgear.cpp \
../../burn/drv/pre90s/d_marineb.cpp \
../../burn/drv/pre90s/d_markham.cpp \
../../burn/drv/pre90s/d_meijinsn.cpp \
../../burn/drv/pre90s/d_mitchell.cpp \
../../burn/drv/pre90s/d_mole.cpp \
../../burn/drv/pre90s/d_mrdo.cpp \
../../burn/drv/pre90s/d_mrflea.cpp \
../../burn/drv/pre90s/d_mystston.cpp \
../../burn/drv/pre90s/d_pac2650.cpp \
../../burn/drv/pre90s/d_pacland.cpp \
../../burn/drv/pre90s/d_pacman.cpp \
../../burn/drv/pre90s/d_pce.cpp \
../../burn/drv/pre90s/d_pkunwar.cpp \
../../burn/drv/pre90s/d_prehisle.cpp \
../../burn/drv/pre90s/d_quizo.cpp \
../../burn/drv/pre90s/d_rallyx.cpp \
../../burn/drv/pre90s/d_renegade.cpp \
../../burn/drv/pre90s/d_route16.cpp \
../../burn/drv/pre90s/d_rpunch.cpp \
../../burn/drv/pre90s/d_scregg.cpp \
../../burn/drv/pre90s/d_sf.cpp \
../../burn/drv/pre90s/d_skyfox.cpp \
../../burn/drv/pre90s/d_skykid.cpp \
../../burn/drv/pre90s/d_snk68.cpp \
../../burn/drv/pre90s/d_solomon.cpp \
../../burn/drv/pre90s/d_sonson.cpp \
../../burn/drv/pre90s/d_srumbler.cpp \
../../burn/drv/pre90s/d_tecmo.cpp \
../../burn/drv/pre90s/d_terracre.cpp \
../../burn/drv/pre90s/d_tigeroad.cpp \
../../burn/drv/pre90s/d_toki.cpp \
../../burn/drv/pre90s/d_vulgus.cpp \
../../burn/drv/pre90s/d_wallc.cpp \
../../burn/drv/pre90s/d_wc90.cpp \
../../burn/drv/pre90s/d_wc90b.cpp \
../../burn/drv/pre90s/d_wwfsstar.cpp \
../../burn/drv/d_parent.cpp
