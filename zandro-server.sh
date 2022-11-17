#!/bin/bash

# TODO:
#   - handle mapsets of more than 1 wads
#   - whiptail wrapper function
#   - medals support for pre-QZ1.3

trap "exit 1" 10
PROC="$$"

#launcher
BTITLE="QC:DE Server Launcher"
WINH=16
WINW=56
LSTH=8

#engines
zandronumPath="/home/kulta/zandronum/zandronum-server"
qZandronumPath="/home/kulta/q-zandronum/q-zandronum-server"
qZandronumTestingPath="/home/kulta/q-zandronum-testing/q-zandronum-server"

#configuration
wads_load_always="qcde_pvpvisibility.pk3"
wads_optional="georgeexleyannouncer.pk3 qcde--frankfurtloadingscreen.pk3"

qcde="qcdev2.8_beta_8.pk3"
qcdemaps="qcdemaps2.8_beta_4.pk3"
communitymaps="qcde_communitymaps_v15.pk3"
qcdemus="qcdemus2.8_beta_2.pk3"
hdfaces="qcde--hdfaces2.7.pk3"
voxels="qcde--voxels2.2.pk3"

utweapons="qcde_ut_weapons_v2.8_beta_3.pk3"
utweapons_hires="qcde_ut_weapons_v2.8_hires_beta_3.pk3"
utvoxels="qcde_ut_weapons_v2.8_voxels_beta_3.pk3"
utmus="qcdemus_ut_v2.8_beta_2.pk3"

pve_maps_folder="/home/kulta/.config/zandronum/pvemaps"
pve_monster_folder="/home/kulta/.config/zandronum/pvemons"

maplist="QCDE01;QCDE02;QCDE05;QCDE06;QCDE08;QCDE09;QCDE10;QCDE11;QCDE13;QCDE14;QCDE15;QCDE16;QCDE18;QCDE19;QCDE20;QCDE21;QCDE22;QCDE24;QCDE25;QCDE26;QCDE27;QCDE28;QCDE29;QCDE30;QCDE31;QCDE32;QCDE35;QCDE36;QCDE37;QCDE38;QCDE39;QCDE40;QCDE41;QCDE42;QCDE43;QCDE44;QCDL02;QCDL03;QCDL04;QCDL05;QCDL06;QCDL07;QCDL08;QCDL09"
aeonlist=";AEON01;AEON02;AEON03;AEON04;AEON05;AEON06;AEON07;AEON08;AEON09;AEON10;AEON11;AEON12;AEON13;AEON14;AEON15;AEON16;AEON17;AEON18;AEON19;AEON20;AEON21;AEON22;AEON23;AEON24;AEON25;AEON26;AEON27;AEON28;AEON29;AEON30;AEON31;AEON32;AEON33"
neonlist=";NEON01;NEON02;NEON03;NEON04;NEON05;NEON06;NEON07;NEON08;NEON09;NEON10;NEON11;NEON12;NEON13;NEON14;NEON15"

export NEWT_COLORS='
    window=black,black
    border=white,black
    root=black,black
    compactbutton=white,black
    checkbox=white,black
    actcheckbox=black,white
    title=white,black
    textbox=white,black
    listbox=white,black
    actlistbox=gray,black
    actsellistbox=black,white
    roottext=white,black
    button=black,white
'

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  ran_with_args=1
  case $1 in
    -e|--engine)
      engine="$2"
      switches+=''
      shift # past argument
      shift # past value
      ;;
    -g|--gamemode)
      config="$2"
      switches+=''
      shift # past argument
      shift # past value
      ;;
    -m|--mapsets)
      mapsets="$2"
      switches+=''
      shift # past argument
      shift # past value
      ;;
    -o|--monsters)
      monsters="$2"
      switches+=''
      shift # past argument
      shift # past value
      ;;
    -t|--themes)
      selected_themes="$2"
      switches+=''
      shift # past argument
      shift # past value
      ;;
    --AeonDM)
      switches+=" 1"
      shift # past argument
      ;;
    --NeonDM)
      switches+=" 2"
      shift # past argument
      ;;
    --StackLeft)
      switches+=" 3"
      shift # past argument
      ;;
    --ItemTimers)
      switches+=" 4"
      shift # past argument
      ;;
    --UTWeapons)
      switches+=" 5"
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

function parse_maplist() {
    IFS=';' read -r -a maps <<< "$maplist"

    for map in "${maps[@]}"
    do
        load_maps+=" +addmap $map"
    done

    random_map=${maps[RANDOM%${#maps[@]}]}

    echo "$random_map|$load_maps"
}

function scan_folder() {
    cd $1
    i=0
    for f in *.*
    do
        files[i]="$f"
        files[i+1]=" "
        ((i+=2))
    done
}

function exit_handler() {
    TERM=ansi whiptail --backtitle "$BTITLE" --infobox "Exiting..." $WINH $WINW
    sleep 1
    clear
    kill -10 $PROC
}

function menu_engine() {
    whiptail --backtitle "$BTITLE" --title "Select engine" --noitem --menu " " $WINH $WINW $LSTH \
        "Q-Zandronum 1.3" "" \
        "Q-Zandronum 1.2" "" \
        "Zandronum" "" \
        "Quit" ""
}

function menu_gamemode() {
    whiptail --backtitle "$BTITLE" --title "Select game mode" --noitem --menu " " $WINH $WINW $LSTH \
        "FFA" "" \
        "TDM" "" \
        "Duel" "" \
        "Survival" "" \
        "InstaGib" "" \
        "FreezeTag" "" \
        "LGPractice" "" \
        "Invasion" "" \
        "Dominatrix" "" \
        "CTF" ""
}

function menu_mapset() {
    scan_folder $pve_maps_folder
    whiptail --backtitle "$BTITLE" --title "Select mapset" --menu " " $WINH $WINW $LSTH "${files[@]}"

    if [[ $? == 255 ]];
    then
        exit_handler
    fi
}

function menu_monsters() {
    scan_folder $pve_monster_folder
    whiptail --backtitle "$BTITLE" --title "Select monster sets" --noitem --checklist " " $WINH $WINW $LSTH "${files[@]}"

    if [[ $? == 255 ]];
    then
        exit_handler
    fi
}

function menu_themes() {

    read -a loaded_themes <<< "$monsters"

    on_off="OFF"
    themes_total=4+${#loaded_themes[@]}

    for (( i=0; i<=$themes_total; i++ ))
    do
        if [ $i -gt 4 ];
        then
            on_off="ON"
        fi

        themelist+="$i theme$i $on_off "
    done

    theme_selection=$(whiptail --backtitle "$BTITLE" --title "Select themes" --checklist " " $WINH $WINW $LSTH ${themelist[@]} 3>&1 1>&2 2>&3)

    if [[ $? == 255 ]];
    then
        exit_handler
    fi

    for (( i=0; i<=$themes_total; i++ ))
    do
        match=false

        for j in ${theme_selection[@]}
        do
            eval j=$j

            if [[ $i == $j ]];
            then
                theme_params+="+theme$i 1 "
                match=true
                break
            fi
        done

        if [ $match == false ];
        then
            theme_params+="+theme$i 0 "
        fi
    done

    echo $theme_params
}

function menu_switches() {
    whiptail --backtitle "$BTITLE" --title "Choose additional options" --separate-output --checklist " " $WINH $WINW $LSTH \
        "1" "AeonDM" OFF \
        "2" "NeonDM" OFF \
        "3" "StackLeft" ON \
        "4" "ItemTimers" ON \
        "5" "UT Weapons" OFF \
        "6" "RailJump / RailRecoil" OFF \
        "7" "RandomChampions" OFF

    if [[ $? == 255 ]];
    then
        exit_handler
    fi
}

# open menu if $engine is unset or empty string
if [ -z ${engine} ]; then
 engine=$(menu_engine 3>&1 1>&2 2>&3)
fi

case $engine in
    "Q-Zandronum 1.3")
        server_executable="$qZandronumTestingPath"
        qcdemaps+=" $communitymaps"
        maplist+=";QCCM01;QCCM02;QCCM03"
        additional_params+="+sv_playerspeed 85 "
        ;;

    "Q-Zandronum 1.2")
        server_executable="$qZandronumPath"
        qcde="qcdev2.7.pk3"
        qcdemaps="qcdemaps2.7.pk3"
        qcdemus=""
        wads_load_always+=" qcdeqzpatch2.7.pk3 newtextcolors_260.pk3"
        wads_optional+=" qcdemus2.7.pk3"
        additional_params+="+sv_playerspeed 85 +compat_disable_wall_friction 1"
        ;;

    "Zandronum")
        server_executable="$zandronumPath"
        qcde="qcdev2.7.pk3"
        qcdemaps="qcdemaps2.7.pk3"
        qcdemus=""
        wads_load_always+=" newtextcolors_260.pk3"
        wads_optional+=" qcdemus2.7.pk3"
        ;;

    "Quit"|*)
        exit_handler
        ;;
esac

# open menu if $config is unset or empty string
if [ -z ${config} ]; then
  config=$(menu_gamemode 3>&1 1>&2 2>&3)
fi

case $config in
    "FFA")
        useMapList=true
        config="Gametype/Deathmatch"
        additional_wads+=""
        additional_params+=""
        port=15666
        ;;

    "TDM")
        useMapList=true
        config="Gametype/TeamDeathmatch"
        additional_wads+="hypnobalance_v01.pk3"
        port=15766
        ;;

    "Duel")
        useMapList=true
        config="Gametype/Duel"
        additional_wads+=""
        additional_params+=""
        port=15866
        ;;

    "Survival")
        useMapList=false
        config="Gametype/Survival"
        
        if [ -z ${mapsets+x} ]; then
          mapsets=$(menu_mapset 3>&1 1>&2 2>&3)
        fi

        if [ -z ${monsters+x} ]; then
          monsters=$(menu_monsters 3>&1 1>&2 2>&3 | tr -d '"')
        fi

        if [ -z ${selected_themes+x} ]; then
          selected_themes=$(menu_themes)
        fi

        wads_load_always=${wads_load_always#"qcde_pvpvisibility.pk3"}
        additional_wads+=$monsters
        additional_params+="$selected_themes +map MAP01"
        port=16566
        ;;

    "InstaGib")
        useMapList=true
        config="Gametype/Instagib"
        additional_wads+="qcde--lmsextensions_v1.01.pk3"
        additional_params+="+addmap QCME01 +addmap QCME02"
        port=15966
        ;;

    "FreezeTag")
        useMapList=true
        config="Gametype/FreezeTag"
        additional_wads+="hypnobalance_v01.pk3 qcde--lmsextensions_v1.01.pk3"
        port=16066
        ;;

    "LGPractice")
        useMapList=false
        config="Gametype/LGPractice"
        additional_wads+="qcde--lgtrain_v1.25.pk3 qcde--lgtrain-arenas_v1.0.pk3"
        additional_params+="+addmap QCLG01 +addmap QCLG02 +map QCLG01"
        port=16166
        ;;

    "Invasion")
        useMapList=false
        config="Gametype/InvasionSurv"

        monsters=$(menu_monsters 3>&1 1>&2 2>&3 | tr -d '"')
        selected_themes=$(menu_themes)

        wads_load_always=${wads_load_always#"qcde_pvpvisibility.pk3"}
        additional_wads+="qcdeinvasionmapsv0.3.pk3 "$monsters
        additional_params+="$selected_themes +map QCIN01"

        port=16266
        ;;

    "Dominatrix")
        useMapList=true
        config="Gametype/Dominatrix"
        additional_wads+="dominatrix-v133.wad qcdemaps-domx0.8.pk3"
        port=16366
        ;;

    "CTF")
        useMapList=false
        config="Gametype/CTF"
        additional_wads+="qcde--qctf_v1.2.1.pk3 industronctfb3.1_hotfix.wad hypnobalance_v01.pk3 qcde--respawndelay_v1.0.pk3"
        additional_params+="+addmap QCTF01 +addmap QCTF03 +addmap INDUS03 +addmap INDUS02 +map QCTF01 +sv_playerspeed 70"
        port=16466
        ;;

    *)
        exit_handler
        ;;
esac


# open menu if $switches is unset: when no command line arguments are passed
if [ -z ${switches+x} ]; then
 switches=$(menu_switches 3>&1 1>&2 2>&3)
fi

stackleft=0
itemtimers=0
railrecoil=0

for sel in $switches; do
    case "$sel" in
    "1")
        useAeon=true
        ;;
    "2")
        useNeon=true
        ;;
    "3")
        if [ "$server_executable" == "$qZandronumTestingPath" ];
        then
            stackleft=1
        else
            additional_wads+=" qcde--stackleft.pk3"
        fi
        ;;
    "4")
        if [ "$server_executable" == "$qZandronumTestingPath" ];
        then
            itemtimers=1
        else
            additional_wads+=" qcde_megaarmorstimers_2.5.1.pk3"
        fi
        ;;
    "5")
        additional_wads+=" $utweapons"
        wads_optional+=" $utweapons_hires"
        qcdemus=$utmus
        voxels=$utvoxels
        ;;
    "6")
        case "$server_executable" in 
        "$qZandronumTestingPath")
            railrecoil=1
            ;;
        "$qZandronumPath")
            additional_wads+=" qcde--railjump-qzand_v1.3.pk3"
            ;;
        "$zandronumPath")
            additional_wads+=" qcde--railjump.pk3"
            ;;
        esac
        ;;
    "7")
        additional_wads+=" qcde--randomchampion_v1.26.pk3"
        ;;
    esac
done

if [ "$server_executable" == "$qZandronumTestingPath" ];
then
    additional_params+=" +sv_showStackLeft $stackleft +sv_showItemTimers $itemtimers +sv_railRecoil $railrecoil"
fi

if [ "$useAeon" == "true" ];
then
    mapsets="aeonqcde.pk3 aeonqcde_communitypatch_v0.2.pk3 "$mapsets
    maplist+=$aeonlist
fi

if [ "$useNeon" == "true" ];
then
    mapsets="neondm.pk3 "$mapsets
    maplist+=$neonlist
fi

if [ "$useMapList" == "true" ];
then
    IFS="|" read -r -a parsedMaps <<< $(parse_maplist)
    map_list=${parsedMaps[1]}
    starting_map="+map ${parsedMaps[0]}"
else
    qcdemaps=""
fi

if [ "$server_executable" == "$zandronumPath" ];
then
    let port+=50
fi

if [ -z "${iwad}" ];
then
    iwad="DOOM2.WAD"
fi

args="-port $port -iwad $iwad -file $mapsets $qcde $qcdemaps $qcdemus $wads_load_always -optfile $voxels $hdfaces $wads_optional -file $additional_wads $map_list +exec $config $additional_params $starting_map"

export LD_LIBRARY_PATH=$(dirname $server_executable)

if [[ $ran_with_args -ne 1 ]] && whiptail --backtitle "$BTITLE" --title "Would you like to edit the command line?" --yesno " " $WINH $WINW; then
    clear
    read -e -p $'\e[33m\nEdit command line parameters:\e[39m\n\n' -i "$args" args
    $server_executable $args
else
    clear
    echo -e "\n$server_executable $args\n"
    $server_executable $args $POSITIONAL_ARGS
fi

unset NEWT_COLORS
