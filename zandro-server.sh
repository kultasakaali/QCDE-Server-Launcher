#!/usr/bin/env bash

clear
trap "exit 1" 10
PROC="$$"

#launcher
BTITLE="QC:DE Server Launcher"
WINH=16
WINW=56
LSTH=8

#engines
zandronumPath="${HOME}/zandronum/zandronum-server"
qZandronumPath="${HOME}/q-zandronum/q-zandronum-server"

#configuration
wads_load_always="qcde_pvpvisibility3.0_testing1.pk3"
wads_optional="qcde--frankfurtloadingscreen.pk3"

qcde="qcdev3.0.pk3"
qcdemaps="qcdemaps3.0.pk3"
aeonqcde="aeonqcde3.0_beta4.pk3"
neonqcde="neonqcde3.0.pk3"
retiredmaps="qcde_retiredmaps_v4.pk3"
qcdemus="qcdemus3.0.pk3"

community_balance="qcde--3.0_frankfurt_boomer_balance_v0.5.pk3"

utweapons="qcde_ut_weapons_v3.0.pk3"
utweapons_hires=""
utmovement="qcde_ut_movement_v3.0.pk3"
utmus="qcdemus_ut_v3.0.pk3"

wads_folder="${HOME}/.config/zandronum"
pve_maps_folder="${HOME}/.config/zandronum/pvemaps"
pve_monster_folder="${HOME}/.config/zandronum/pvemons"

maplist="QCDE01;QCDE02;QCDE03;QCDE04;QCDE05;QCDE06;QCDE07;QCDE08;QCDE09;QCDE10;QCDE11;QCDE13;QCDE14;QCDE15;QCDE16;QCDE17;QCDE18;QCDE19;QCDE20;QCDE21;QCDE22;QCDE23;QCDE24;QCDE25;QCDE26;QCDE27;QCDE28;QCDE29;QCDE30;QCDE31;QCDE32;QCDE33;QCDE34;QCDE35;QCDE36;QCDE37;QCDE38;QCDE39;QCDE40;QCDE41;QCDE42;QCDE43;QCDE44;QCDE45;QCDE46;QCDE47;QCDE48;QCDE49;QCDE50;QCDL02;QCDL03;QCDL04;QCDL05;QCDL06;QCDL07;QCDL09;QCDL10;QCDL13;QCME01;QCME02"
duellist="QCDE01;QCDE02;QCDE05;QCDE06;QCDE08;QCDE09;QCDE10;QCDE11;QCDE14;QCDE15;QCDE16;QCDE18;QCDE19;QCDE20;QCDE21;QCDE22;QCDE23;QCDE24;QCDE26;QCDE27;QCDE28;QCDE29;QCDE30;QCDE32;QCDE35;QCDE37;QCDE39;QCDE40;QCDE41;QCDE42;QCDE45;QCDE46;QCDE48;QCDE50;QCDL02;QCDL03;QCDL04;QCDL05;QCDL06;QCDL07;QCDL09;QCDL10;QCDL13"
retiredlist=";QCRT01;QCRT07"
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
      shift
      shift
      ;;
    -m|--mapsets)
      mapsets="$2"
      switches+=''
      shift
      shift
      ;;
    -o|--monsters)
      monsters="$2"
      switches+=''
      shift
      shift
      ;;
    -t|--themes)
      selected_themes="$2"
      switches+=''
      shift
      shift
      ;;
    --AeonDM)
      switches+=" 1"
      shift
      ;;
    --NeonDM)
      switches+=" 2"
      shift
      ;;
    --RetiredMaps)
      switches+=" 3"
      shift
      ;;
    --StackLeft)
      switches+=" 4"
      shift
      ;;
    --ItemTimers)
      switches+=" 5"
      shift
      ;;
    --UTWeapons)
      switches+=" 6"
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift
      ;;
  esac
done

function parse_maplist() {

    local map
    local maps
    local maplist_maps
    local random_map

    IFS=';' read -r -a maps <<< "$maplist"

    for map in "${maps[@]}"
    do
        maplist_maps+=" +addmap $map"
    done

    random_map=${maps[RANDOM%${#maps[@]}]}

    echo "$random_map|$maplist_maps"
}

function validate_files() {

    local segment
    local lc_segment
    local -a command_line
    local -a missing_wads
    
    echo $'\e[33m\nValidating files...\e[39m\n\n'
    
    IFS=' ' read -r -a command_line <<< "$args"

    for segment in "${command_line[@]}"
    do
        lc_segment=$(echo $segment | tr '[:upper:]' '[:lower:]')
        if [[ $lc_segment =~ ".pk3" ]] || [[ $lc_segment =~ ".wad" ]];
        then
            if ! [[ $(find "$wads_folder" -name "$segment") ]];
            then
                missing_wads+=("$segment")
            fi
        fi
    done

    if [[ ${#missing_wads[@]} == 0 ]];
    then
        true
    else
        if (whiptail --backtitle "$BTITLE" --title "File(s) missing" --yesno "Some files selected for loading could not be found.\nWould you like to try and download them automatically?" $WINH $WINW);
        then
            for file in "${missing_wads[@]}"
            do
                if ! tspg-get "$file";
                then
                    whiptail --backtitle "$BTITLE" --title "Download error!" --msgbox "Could not download $file\nPlease check if the specified file name is correct." $WINH $WINW
                    false
                else
                    true
                fi
            done
        elif whiptail --backtitle "$BTITLE" --title "File(s) missing" --yesno "Would you like to start the server anyway?" $WINH $WINW;
        then
            true
        else
            false
        fi
    fi
}

function start_server() {
    if validate_files;
    then
        echo $'\e[33m\nFiles validated, starting server...\e[39m\n\n'
        $server_executable $args $POSITIONAL_ARGS
    else
        echo $'\e[33m\nAn error occured, the server could not be started.\e[39m\n\n'
    fi
}

function scan_folder() {
    
    local i=0
    
    cd $1
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
        "Q-Zandronum" "" \
        "Zandronum" "" \
        "Quit" ""
}

function menu_gamemode() {
    whiptail --backtitle "$BTITLE" --title "Select game mode" --noitem --menu " " $WINH $WINW $LSTH \
        "FFA" "" \
        "TDM" "" \
        "Duel" "" \
        "Survival" "" \
        "ClanArena" "" \
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

    local -a loaded_themes
    local -a theme_selection
    local themes_total
    local theme_params
    local theme_list
    local on_off
    local match
    local i
    local j

    read -a loaded_themes <<< "$monsters"

    on_off="OFF"
    themes_total=4+${#loaded_themes[@]}

    for (( i=0; i<=$themes_total; i++ ))
    do
        if [[ $i -gt 4 ]];
        then
            on_off="ON"
        fi

        theme_list+="$i theme$i $on_off "
    done

    theme_selection=$(whiptail --backtitle "$BTITLE" --title "Select themes" --checklist " " $WINH $WINW $LSTH ${theme_list[@]} 3>&1 1>&2 2>&3)

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

        if [[ $match == false ]];
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
        "3" "RetiredMaps" ON \
        "4" "StackLeft" ON \
        "5" "ItemTimers" ON \
        "6" "UT Weapons" OFF \
        "7" "RailJump" OFF \
        "8" "RandomChampions" OFF \
        "9" "RandomRocketArena" OFF \
        "10" "Community Balance" OFF

    if [[ $? == 255 ]];
    then
        exit_handler
    fi
}

# open menu if $engine is unset or empty string
if [[ -z ${engine} ]]; then
 engine=$(menu_engine 3>&1 1>&2 2>&3)
fi

case $engine in
    "Q-Zandronum")
        server_executable="$qZandronumPath"
        ;;

    "Zandronum")
        server_executable="$zandronumPath"
        qcde="qcdev2.7c.pk3"
        qcdemaps="qcdemaps2.7.pk3"
        qcdemus="qcdemus2.7.pk3"
        wads_load_always+=" newtextcolors_260.pk3"
        wads_optional+=""
        ;;

    "Quit"|*)
        exit_handler
        ;;
esac

# open menu if $config is unset or empty string
if [[ -z ${config} ]]; then
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
        maplist=$duellist
        config="Gametype/Duel"
        additional_wads+=""
        additional_params+=""
        port=15866
        ;;

    "Survival")
        useMapList=false
        config="Gametype/Survival"

        if [[ -z ${mapsets+x} ]]; then
          mapsets=$(menu_mapset 3>&1 1>&2 2>&3)
        fi

        if [[ -z ${monsters+x} ]]; then
          monsters=$(menu_monsters 3>&1 1>&2 2>&3 | tr -d '"')
        fi

        if [[ -z ${selected_themes+x} ]]; then
          selected_themes=$(menu_themes)
        fi

        wads_load_always=${wads_load_always#"qcde_pvpvisibility.pk3"}
        additional_wads+=$monsters
        additional_params+="$selected_themes +map MAP01"
        port=16566
        ;;

    "ClanArena")
	    useMapList=true
	    config="Gametype/ClanArena"
	    additional_wads+="qcde--ca_patch3.0.pk3"
	    ;;

    "InstaGib")
        useMapList=true
        config="Gametype/Instagib"
        additional_wads+=""
        additional_params+="+addmap QCME01 +addmap QCME02"
        port=15966
        ;;

    "FreezeTag")
        useMapList=true
        config="Gametype/FreezeTag"
        additional_wads+="hypnobalance_v01.pk3"
        port=16066
        ;;

    "LGPractice")
        useMapList=false
        config="Gametype/LGPractice"
        requires_qcdemaps=true
        additional_wads+="qcde--lgtrain_v1.30.pk3"
        additional_params+="+addmap QCLG01 +addmap QCDL11 +addmap QCDL12"
        port=16166
        ;;

    "Invasion")
        useMapList=false
        config="Gametype/InvasionSurv"

        monsters=$(menu_monsters 3>&1 1>&2 2>&3 | tr -d '"')
        selected_themes=$(menu_themes)

        wads_load_always=${wads_load_always#"qcde_pvpvisibility.pk3"}
        additional_wads+=$monsters
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
        additional_wads+="hypnobalance_v01.pk3"
        additional_params+="+addmap QCTF01 +addmap QCTF02 +addmap QCTF03 +addmap QCTF04 +map QCTF01"
        port=16466
        ;;

    *)
        exit_handler
        ;;
esac


# open menu if $switches is unset: when no command line arguments are passed
if [[ -z ${switches+x} ]]; then
 switches=$(menu_switches 3>&1 1>&2 2>&3)
fi

stackleft=0
itemtimers=0
railjump=0

for sel in $switches; do
    case "$sel" in
    "1")
        useAeon=true
        ;;
    "2")
        useNeon=true
        ;;
    "3")
        useRetired=true
        ;;
    "4")
        if [ "$server_executable" == "$qZandronumPath" ];
        then
            stackleft=1
        else
            additional_wads+=" qcde--stackleft.pk3"
        fi
        ;;
    "5")
        if [ "$server_executable" == "$qZandronumPath" ];
        then
            itemtimers=1
        else
            additional_wads+=" qcde_megaarmorstimers_2.5.1.pk3"
        fi
        ;;
    "6")
        additional_wads+=" $utweapons $utmovement"
        wads_optional+=" $utweapons_hires"
        qcdemus=$utmus
        ;;
    "7")
        case "$server_executable" in
        "$qZandronumPath")
            ;;
        "$zandronumPath")
            additional_wads+=" qcde--railjump.pk3"
            ;;
        esac
        ;;
    "8")
        additional_wads+=" qcde--randomchampion_v1.3.pk3"
        ;;
    "9")
        additional_wads+=" qcde--randomrocketarena_v1.02.pk3"
        ;;
    "10")
        additional_wads+=" $community_balance"
        ;;
    esac
done

if [[ "$server_executable" == "$qZandronumPath" ]];
then
    additional_params+=" +sv_showStackLeft $stackleft +sv_showItemTimers $itemtimers"
fi

if [[ "$useAeon" == "true" ]];
then
    qcdemaps+=" $aeonqcde"
    maplist+=$aeonlist
fi

if [[ "$useNeon" == "true" ]];
then
    qcdemaps+=" $neonqcde"
    maplist+=$neonlist
fi

if [[ "$useRetired" == "true" ]];
then
    qcdemaps+=" $retiredmaps"
    maplist+=$retiredlist
fi

if [[ "$useMapList" == "true" ]];
then
    IFS="|" read -r -a parsedMaps <<< $(parse_maplist)
    map_list=${parsedMaps[1]}
    starting_map="+map ${parsedMaps[0]}"
elif [[ "$requires_qcdemaps" != "true" ]];
then
    qcdemaps=""
fi

if [[ "$server_executable" == "$zandronumPath" ]];
then
    (( port+=50 ))
fi

if [[ -z "${iwad}" ]];
then
    iwad="DOOM2.WAD"
fi

args="-port $port -iwad $iwad -file $mapsets $qcde $qcdemaps $wads_load_always -optfile $qcdemus $wads_optional -file $additional_wads $map_list +exec $config $additional_params $starting_map"

export LD_LIBRARY_PATH=$(dirname $server_executable)

if [[ $ran_with_args -ne 1 ]] && (whiptail --backtitle "$BTITLE" --title "Would you like to edit the command line?" --yesno " " $WINH $WINW);
then
    clear
    read -e -p $'\e[33m\nEdit command line parameters:\e[39m\n\n' -i "$args" args

    start_server
else
    clear
    echo -e "\n$server_executable $args\n"

    start_server
fi

unset NEWT_COLORS
unset LD_LIBRARY_PATH
