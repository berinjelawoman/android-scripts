#!/bin/bash
# script to extract all of the following apks to an android box


appsArray=("tv.pluto.android" "net.aljazeera.english" "com.vimeo.android.videoapp" "tv.twitch.android.app"
        "com.amazon.amazonvideo.livingroom" "com.hbo.hbonow" "com.globo.globotv"
        "com.cbs.ca" "com.netflix.ninja" "com.disney.disneyplus" "com.crunchyroll.crunchyroid"
        "com.google.android.youtube.tvmusic" "com.radio.fmradio" "com.spotify.tv.android"
        "deezer.android.tv" "tunein.player" "com.Funimation.FunimationNow.androidtv" "com.pokemontv" "com.google.android.youtube.tvkids"
        "com.nhl.gc1112.free" "com.ufc.brazil.app" "br.tv.horizonte.android.premierefc" "com.espn.score_center"
        "com.dazn" "com.formulaone.production" "pt.sporttv.app.androidtv" "com.flipps.fitetv"
        "com.nousguide.android.rbtv" "com.bamnetworks.mobile.android.gameday.atbat" "com.mlbam.wwe_asb_app"
        "com.usatoday.android.news" "com.abc.abcnews" "dw.com.androidtv.live"
        "com.bloomberg.btva" "com.cbsnews.ott" "com.haystack.android"
)

for pkg in ${appsArray[@]}; do
    mkdir $pkg
    apks=$(adb -s $1 shell pm path $pkg | cut -d: -f2)
    for apk in $apks; do
        adb -s $1 pull $apk $pkg
    done
done