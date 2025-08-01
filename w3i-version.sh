#!/usr/bin/env bash

# INSTALLATION:
# NEED: MPQEDITOR.exe (Cygwin)
# NEED: lua, openssl
# Save this script in the same folder as MPQEDITOR.exe (or modify path below)
#
# Cygwin packages installation:
# Click through installer, select mirror server, next, next
# When you reach the table window with drop-down and search box:
# Select "Full" or "Not Installed" in drop-down menu
# Enter package name in search box: lua
# Find the package you are looking for, click on Version ("skip") and select latest version to install
# Repeat for other packages you want to install
# Finish installation, close window.
# Open "Cygwin Terminal"
#
# https://github.com/sop/cygextreg to execute .sh from explorer:
# Download the files from 'Releases' on the right and extract as it says in the readme
# Open Cygwin terminal, register file associations:
# 1. cygextreg -r
# 2. cygextreg -r --ext bash

# USAGE:
# ./w3i-version.sh "path/to/map.w3m"
# or you can drag'n'drop the map file onto the script file to run it.
# 

set -euo pipefail

MPQEDITOR="./MPQEditor.exe"
LISTFILE="listfile.txt"
EXTRACTDIR="./extracted/"
W3I='war3map.w3i'

sleepExit() {
	sleep 5
	exit "$1"
}

if [[ ! -f "$MPQEDITOR" ]]; then
	echo "MPQ EDITOR NOT FOUND!"
	echo "Path 1: '$MPQEDITOR'"
	echo "Path 2: '$(realpath "$MPQEDITOR")'"
	sleepExit 2
fi
if ! command -v "lua" >/dev/null || ! command -v "openssl" >/dev/null; then
	echo "lua, openssl must be installed! not found in PATH" >&2
	sleepExit 3
fi
if [[ ! -f "$LISTFILE" ]]; then
	echo "listfile.txt not found, outputting a poor substitute" >&2
	> "$LISTFILE" cat <<-EOF
scripts\war3map.j
scripts\war3map.lua
war3map.j
war3map.lua
war3map.w3i
EOF
fi

if [[ -z "$1" ]]; then
	echo "You must provide a map file as first argument. Or just drag-and-drop map file onto this script" >&2
	sleepExit 4
fi

if [[ ! -d "$EXTRACTDIR" ]]; then
	mkdir "$EXTRACTDIR"
fi

extractMetadataFiles() {
	#printf "Starting mpqeditor to extract '%s' from '%s' using list '%s'\n" "$W3I" "$mapFileWin" "$LISTFILE" >&2
	
	printf "Starting mpqeditor to extract metadata files from '%s' using list '%s'\n" "$mapFileWin" "$LISTFILE" >&2
	
	# here listfile acts as a control mechanism
	# if the map has a list file, then all war3map.* in root folder will be extracted (probably)
	# if the map doesn't have a list file, then only those files specified in our list file will match wildcard
	# also just extract "everything" from scripts
	# this is better than extracting ALL files from map MPQ
	"$MPQEDITOR" extract "$mapFileWin" "war3map.*" "$EXTRACTDIR" /listfile "$LISTFILE"
	"$MPQEDITOR" extract "$mapFileWin" "scripts/*" "$EXTRACTDIR" /listfile "$LISTFILE"

	echo "mpqeditor done" >&2

	if [[ ! -f "${EXTRACTDIR}${W3I}" ]]; then
		echo "File not found after extraction!" >&2
		sleepExit 7
	fi
}

processMetadata() {
	echo "$mapFileWin"
	basename "$mapFileWin"
	echo "MD5 and SHA256 hashes:"
	openssl dgst -md5 -r "$mapFileWin" | awk '{print $1}'
	openssl dgst -sha256 -r "$mapFileWin" | awk '{print $1}'

	lua - <<EOF
#!/usr/bin/env lua

versionTable = {
-- {"Date", "Addon", "Type", "Screen corner", "WE Build"},
{"2002-02-12", "ROC", "Beta", "BETA v3684", "3684"},
{"2002-04-16", "ROC", "Beta", "BETA v4073", "4073"},
{"2002-05-16", "ROC", "Beta", "BETA v4308", "4308"},
{"2002-07-03", "ROC", "Retail", "1.00", "4448"},
{"2002-07-05", "ROC", "Retail", "1.01", "4482"},
{"2002-07-10", "ROC", "Retail", "1.01b", "4482"},
{"2002-07-31", "ROC", "Retail", "1.01c", "4482"},
{"2002-08-16", "ROC", "Retail", "1.02", "4531"},
{"2002-09-06", "ROC", "Retail", "1.02a", "4531"},
{"2002-10-09", "ROC", "Retail", "1.03", "4572"},
{"2002-11-04", "ROC", "Retail", "1.04", "4654"},
{"2002-11-07", "ROC", "Retail", "1.04b", "4654"},
{"2003-01-30", "ROC", "Retail", "1.04c", "4654"},
{"2003-01-31", "ROC", "Retail", "1.05", "4654"},
{"2003-06-03", "ROC", "Retail", "1.06", "4654"},
{"2003-07-01", "TFT", "Retail", "1.07", "6031"},
{"2003-07-03", "TFT", "Retail", "1.10", "6034"},
{"2003-07-15", "TFT", "Retail", "1.11", "6035"},
{"2003-07-31", "TFT", "Retail", "1.12", "6036"},
{"2003-12-16", "TFT", "Retail", "1.13", "6037"},
{"2003-12-19", "TFT", "Retail", "1.13b", "6037"},
{"2004-01-07", "TFT", "Retail", "1.14", "6039"},
{"2004-01-10", "TFT", "Retail", "1.14b", "6040"},
{"2004-05-10", "TFT", "Retail", "1.15", "6043"},
{"2004-07-01", "TFT", "Retail", "1.16", "6046"},
{"2004-09-20", "TFT", "Retail", "1.17", "6050"},
{"2005-03-01", "TFT", "Retail", "1.18", "6051"},
{"2005-09-19", "TFT", "Retail", "1.19", "6052"},
{"2005-09-21", "TFT", "Retail", "1.19b", "6052"},
{"2005-10-03", "TFT", "Retail", "1.20", "6052"},
{"2005-12-12", "TFT", "Retail", "1.20b", "6052"},
{"2006-01-09", "TFT", "Retail", "1.20c", "6052"},
{"2006-04-21", "TFT", "Retail", "1.20d", "6052"},
{"2006-06-22", "TFT", "Retail", "1.20e", "6052"},
{"2007-01-22", "TFT", "Retail", "1.21", "6052"},
{"2008-02-06", "TFT", "Retail", "1.21b", "6052"},
{"2008-06-30", "TFT", "Retail", "1.22.0.6328", "6057"},
{"2009-03-20", "TFT", "Retail", "1.23.0.6352", "6058"},
{"", "TFT", "", "1.24.0.6366", "6059"},
{"2009-08-04", "TFT", "Retail", "1.24.0.6372", "6059"},
{"2009-08-25", "TFT", "Retail", "1.24.1.6374", "6059"},
{"2009-12-01", "TFT", "Retail", "1.24.2.6378", "6059"},
{"2010-01-21", "TFT", "Retail", "1.24.3.6384", "6059"},
{"2010-03-11", "TFT", "Retail", "1.24.4.6387", "6059"},
{"", "TFT", "PTR", "1.25.0.6394", "6059"},
{"2011-03-08", "TFT", "Retail", "1.25.1.6397", "6059"},
{"2011-03-24", "TFT", "Retail", "1.26.0.6401", "6059"},
{"2016-03-14", "TFT", "Retail", "1.27.0.52240", "6059"},
{"2016-12-13", "TFT", "Retail", "1.27.1.7085", "6059"},
{"2017-04-05", "TFT", "Retail", "1.28.0.7205", "6059"},
{"2017-04-27", "TFT", "Retail", "1.28.1.7365", "6059"},
{"2017-05-10", "TFT", "Retail", "1.28.2.7395", "6059"},
{"2017-07-06", "TFT", "Retail", "1.28.5.7680", "6059"},
{"2018-04-10", "TFT", "Retail", "1.29.0.9055", "6060"},
{"", "TFT", "PTR", "1.29.1.9120", "6060"},
{"2018-04-23", "TFT", "Retail", "1.29.1.9160", "6060"},
{"27.04.2018", "TFT", "PTR", "1.29.2.9208", "6060"},
{"2018-05-03", "TFT", "Retail", "1.29.2.9231", "6060"},
{"2018-08-08", "TFT", "Retail", "1.30.0.9900", "6061"},
{"2018-08-09", "TFT", "Retail", "1.30.0.9922", "6061"},
{"2018-09-13", "TFT", "Retail", "1.30.1.10211", "6061"},
{"2018-11-30", "TFT", "Retail", "1.30.2.11024", "6061"},
{"2018-11-30", "TFT", "Retail", "1.30.2.11029", "6061"},
{"2018-12-04", "TFT", "Retail", "1.30.2.11057", "6061"},
{"2018-12-06", "TFT", "Retail", "1.30.2.11065", "6061"},
{"2018-12-13", "TFT", "Retail", "1.30.2.11113", "6061"},
{"2019-01-04", "TFT", "Retail", "1.30.3.11235", "6061"},
{"2019-01-14", "TFT", "Retail", "1.30.4.11274", "6061"},
{"2019-05-28", "TFT", "Retail", "1.31.0", "6072"},
{"2019-06-10", "TFT", "Retail", "1.31.1.12164", "6072"},
{"2019-06-08", "TFT", "PTR", "1.31.1.12173", "6072"},
{"2019-11-04", "REF", "Beta", "1.32.0.2", "6092"},
{"2019-11-12", "REF", "Beta", "1.32.0.2.1", "6092"},
{"2019-11-19", "REF", "Beta", "1.32.0.13769", "6094"},
{"2019-12-02", "REF", "Beta", "1.32.0.13938", "6094"},
{"2019-12-06", "REF", "Beta", "1.32.0.13991", "6098"},
{"2020-01-08", "REF", "Beta", "1.32.0.14284", "6102"},
{"2020-01-09", "REF", "Beta", "1.32.0.14300", "6102"},
{"2020-01-17", "REF", "Beta", "1.32.0.14391", "6103"},
{"2020-01-19", "REF", "Beta", "1.32.0.14411", "6103"},
{"2020-01-28", "REF", "Retail", "1.32.0.14481", "6105"},
{"2020-02-06", "REF", "Retail", "1.32.1.14604", "6105"},
{"2020-02-24", "REF", "Retail", "1.32.2.14722", "6106"},
{"2020-03-18", "REF", "Retail", "1.32.3.14857", "6108"},
{"2020-03-23", "REF", "Retail", "1.32.3.14883", "6108"},
{"2021-12-03", "REF", "Retail", "1.32.10.18067", "6114"},
}
-- these values below aren't part of Firstrun70's online spreadsheet:
-- https://github.com/Drake53/War3Net/blob/master/src/War3Net.Build.Core/Resources/GameBuilds.json
table.insert(versionTable, {"2020-04-28", "REF", "Retail", "1.32.4.15098", "6109"})
table.insert(versionTable, {"2020-04-29", "REF", "Retail", "1.32.5.15129", "6109"})
table.insert(versionTable, {"2020-05-14", "REF", "Retail", "1.32.5.15216", "6109"})

table.insert(versionTable, {"2020-05-14", "REF", "Retail", "1.32.5.15216", "6110"})
table.insert(versionTable, {"2020-06-02", "REF", "Retail", "1.32.6.15355",  "6110" })
table.insert(versionTable, {"2020-07-07", "REF", "Retail", "1.32.7.15572",  "6110" })
table.insert(versionTable, {"2020-08-11", "REF", "Retail", "1.32.8.15762",  "6111" })
table.insert(versionTable, {"2020-08-12", "REF", "Retail", "1.32.8.15801",  "6111" })
table.insert(versionTable, {"2020-10-21", "REF", "Retail", "1.32.9.16207",  "6112" })
table.insert(versionTable, {"2020-12-14", "REF", "Retail", "1.32.9.16551",  "6112" })
table.insert(versionTable, {"2020-12-18", "REF", "Retail", "1.32.9.16589",  "6112" })
table.insert(versionTable, {"2021-04-13", "REF", "Retail", "1.32.10.17165", "6114" })
table.insert(versionTable, {"2021-06-01", "REF", "Retail", "1.32.10.17380", "6114" })
table.insert(versionTable, {"2021-08-24", "REF", "Retail", "1.32.10.17734", "6114" })
-- firstrun70 in here
table.insert(versionTable, {"2022-06-09", "REF", "Retail", "1.32.10.18820", "6114" })
table.insert(versionTable, {"2022-08-18", "REF", "Retail", "1.33.0.19194",  "6114" })
table.insert(versionTable, {"2022-08-19", "REF", "Retail", "1.33.0.19203",  "6114" })
table.insert(versionTable, {"2022-08-30", "REF", "Retail", "1.33.0.19252",  "6114" })
table.insert(versionTable, {"2022-09-13", "REF", "Retail", "1.33.0.19308",  "6114" })
table.insert(versionTable, {"2022-09-29", "REF", "Retail", "1.33.0.19378",  "6114" })
table.insert(versionTable, {"2022-12-01", "REF", "Retail", "1.34.0.19632",  "6114" })

-- These are newer than Drake53's list:
-- Cross reference: https://warcraft.wiki.gg/wiki/Warcraft_client_builds#Warcraft_III
table.insert(versionTable, {"2020-10-2x", "REF", "internal", "1.33.0.16269",  "6113" })
table.insert(versionTable, {"2020-11-xx", "REF", "internal", "1.33.0.17537",  "6114" })
table.insert(versionTable, {"2023-01-20", "REF", "Retail",   "1.35.0.19887",  "6115" })
table.insert(versionTable, {"2023-05-24", "REF", "Retail",   "1.36.0.20257",  "6115" })
table.insert(versionTable, {"2023-xx-xx", "REF", "internal", "1.36.1.20448",  "6115" })
table.insert(versionTable, {"2023-11-21", "REF", "Retail",   "1.36.1.20719",  "6115" })
table.insert(versionTable, {"2024-04-08", "REF", "PTR",      "1.36.1.21015",  "6115" })
table.insert(versionTable, {"2024-06-04", "REF", "Retail",   "1.36.2.21179",  "6115" })
table.insert(versionTable, {"2024-06-18", "REF", "Retail",   "1.36.2.21230",  "6115" })
table.insert(versionTable, {"2025-12-23", "REF", "Retail",   "2.0.1.22498",   "6115" })
table.insert(versionTable, {"2025-04-29", "REF", "Retail",   "2.0.2.22796",   "6115" })
table.insert(versionTable, {"2025-07-22", "REF", "Retail",   "2.0.3.22978",   "6116" })
table.insert(versionTable, {"2025-07-17", "REF", "Retail",   "2.0.3.22988",   "6116" })

versionRanges = {
-- { firstDate, lastDate?, nextVerDate?, addons = {addon...}, betaTypes = {betaType?...}, gameVersions={gameVer...}, weBuild }
}
versionRangesByBuild = {
-- [weBuild] = same table as above
}
knownGameVersions = {
	-- [1.35.0.0] = true
}
for k, data in pairs(versionTable) do
	local gameVer = data[4]
	knownGameVersions[gameVer] = true
end
function isGameVersionKnown(gameVer)
	return knownGameVersions[gameVer] and true or false
end

function getBuild(weBuild)
	assert(type(weBuild) == "number")
	return versionRangesByBuild[weBuild]
end
function setBuild(weBuild, tbl)
	assert(type(weBuild) == "number")
	assert(getBuild(weBuild) == nil, "build under this id already exists: '".. tostring(weBuild) .."'")
	
	table.insert(versionRanges, tbl)
	versionRangesByBuild[weBuild] = tbl
end
function addBuild(thisDate, nextVerDate, addon, betaType, gameVer, weBuild)
	local stored = getBuild(weBuild)
	if stored then
		-- merge
		stored.lastDate = thisDate
		
		for k, storedAddon in pairs(stored.addons) do
			if storedAddon ~= addon then
				table.insert(stored.addons, addon)
				break
			end
		end
		
		if betaType then
			for k, storedBeta in pairs(stored.betaTypes) do
				if storedBeta ~= betaType then
					table.insert(stored.betaTypes, betaType)
					break
				end
			end
		end
		
		for k, storedGameVer in pairs(stored.gameVersions) do
			if storedGameVer ~= gameVer then
				table.insert(stored.gameVersions, gameVer)
				break
			end
		end
		
	else
		-- create
		setBuild(weBuild, 
			{
				firstDate = thisDate,
				lastDate = nil,
				nextVerDate = nextVerDate,
				addons = {addon},
				betaTypes = {betaType},
				gameVersions = {gameVer},
				weBuild = weBuild
			}
		)
	end
end

function push2(t1, t2, value1, value2)
	table.insert(t1, value1)
	table.insert(t2, value2)
end
function getVersionStringByWeBuild(weBuild)
	-- build: release(beta/ptr?), earliest: dateRelease -- least if 2nd release -- until nextVersionDate, version1 / version2
	-- 6102: Reforged(Beta), earliest: 2020-01-08 -- at least 2020-01-09 -- newer game ver since 2020-01-17, 1.32.0.2 / 1.32.0.2.1
	local b = getBuild(weBuild)
	
	if not b then
		return string.format("unknown_we_build(%d)", weBuild)
	end
	
	local fmt = {}
	local param = {}
	
	push2(fmt, param, "we_version=%d: ", b.weBuild)
	push2(fmt, param, "%s", table.concat(b.addons, "/"))
	if #b.betaTypes == 0 then
		-- nothing
	else
		push2(fmt, param, " (%s)", table.concat(b.betaTypes, "/"))
	end
	if #b.gameVersions == 0 then
		push2(fmt, param, ", %s", "unknown game version")
	elseif #b.gameVersions == 1 then
		push2(fmt, param, ", patch=%s", b.gameVersions[1])
	else
		push2(fmt, param, ", patches={%s}", table.concat(b.gameVersions, ", "))
	end
	if b.firstDate then
		push2(fmt, param, ", earliest=%s", b.firstDate)
	end
	if b.lastDate then
		push2(fmt, param, ", until at least=%s", b.lastDate)
	end
	if b.nextVerDate then
		push2(fmt, param, ", newer game version since=%s", b.nextVerDate)
	end
	
	local unpack = table.unpack or unpack
	local fancyString = string.format(
		table.concat(fmt, ""),
		unpack(param)
	)
	
	return fancyString
end

for k, data in pairs(versionTable) do
	-- preprocess
	data[5] = tonumber(data[5])
	assert(data[5], string.format("date is empty/not a number. key=%s, date=%s", tostring(k), tostring(data[1])))
end
for k, data in pairs(versionTable) do
	local date = #data[1] > 0 and data[1] or "N/A"

	local addon = data[2] == "REF" and "Reforged" or data[2]
	
	local betaType = data[3]
	if betaType:lower() == "retail" then
		betaType = nil
	end
	
	local gameVer = data[4]
	local weBuild = data[5]
	
	local nextBuild, nextVerDate
	local previousKey = k
	while true do
		local n = next(versionTable, previousKey)
		if not n then
			break
		end
		
		local nextData = versionTable[n]
		if nextData[5] ~= weBuild then
			nextVerDate = #nextData[1] > 0 and nextData[1] or "N/A"
			nextBuild = nextData[5]
			break
		end
		
		previousKey = n
	end
	
	addBuild(date, nextVerDate, addon, betaType, gameVer, weBuild)
end

--print(getVersionStringByWeBuild(6116))

	-----------
	
	EXTRACTDIR=[====[$EXTRACTDIR]====]
	EXTRACTFILE=[====[$W3I]====]
	w3iPath=EXTRACTDIR .. EXTRACTFILE

	w3i = assert(io.open(w3iPath,"rb"))
	data = {}
	d = data
	d.format_version = string.unpack("<I4", w3i:read(4))
	if d.format_version >= 16 then
		d.save_count = string.unpack("<I4", w3i:read(4))
		d.editor_version = string.unpack("<I4", w3i:read(4))
	end
	if d.format_version >= 27 then
		local verA = string.unpack("<I4", w3i:read(4))
		local verB = string.unpack("<I4", w3i:read(4))
		local verC = string.unpack("<I4", w3i:read(4))
		local verD = string.unpack("<I4", w3i:read(4))
		d.game_version = string.format("%d.%d.%d.%d", verA, verB, verC, verD)
	end

	w3i:close()
	for _, name in pairs({"format_version", "save_count", "editor_version", "game_version"}) do
		if data[name] then
			print(string.format("%-17s %-s", name, data[name]))
		end
	end
	if d.editor_version and getVersionStringByWeBuild then
		print(getVersionStringByWeBuild(d.editor_version))
	end
	if d.game_version and isGameVersionKnown then
		if not isGameVersionKnown(d.game_version) then
			print(string.format("unknown_game_build(%s)", d.game_version))
		end
	end
EOF
}

extractScriptDate() {
	#printf "Starting mpqeditor to extract all files (searching for script) from '%s' using list '%s'\n" "$mapFileWin" "$LISTFILE" >&2

	#rm -- "$EXTRACTDIR"*
	#"$MPQEDITOR" extract "$mapFileWin" "*" "$EXTRACTDIR" /listfile "$LISTFILE" | grep -vF 'Extracting' >&2 || true
	
	# This can't work with Unicode paths :(
	# MOPAQ_SCRIPT_PATH="extractMapScript.mopaq2000script"
	# cat > "$MOPAQ_SCRIPT_PATH" <<-EOF
# extract "$mapFileWin" war3map.j "$EXTRACTDIR" /listfile "$LISTFILE" /lower
# extract "$mapFileWin" scripts\war3map.j "$EXTRACTDIR" /listfile "$LISTFILE" /lower
# extract "$mapFileWin" war3map.lua "$EXTRACTDIR" /listfile "$LISTFILE" /lower
# extract "$mapFileWin" scripts\war3map.j "$EXTRACTDIR" /listfile "$LISTFILE" /lower
# EOF
	#"$MPQEDITOR" /script "$MOPAQ_SCRIPT_PATH" | grep -vF 'Extracting' >&2 || true
	
	
	local scriptFileList="$(find "$EXTRACTDIR" \( -iname "war3map.j" -o -iname "war3map.lua" \) )"
	
	if [[ -z "$scriptFileList" ]]; then
		printf "ERROR: DID NOT FIND ANY MAP SCRIPT FILE FOR '%s'\n" "$(basename "$mapFileWin")" >&2
		printf "$scriptFileList"
	else
		grep --with-filename -F -C2 'Generated by' -- "$scriptFileList" || echo "INFO: Didn't find date in script."
		
	fi
	#rm -- "$EXTRACTDIR"*

	#echo "mapscript done" >&2
}

cleanExtractFolder() {
	rm -- "$EXTRACTDIR"* "${EXTRACTDIR}scripts/"* &>/dev/null || true
}

main() {
	printf "Processing %s files...\n" "$#" >&2
	
	cleanExtractFolder;
	
	while [[ $# -gt 0 ]]; do
		if [[ ! -f "$1" ]]; then
			echo "Could not find map file '$1'" >&2
			sleepExit 5
		fi
		mapFile="$1"
		mapFileWin="$(cygpath --windows "$mapFile")"

		printf "=--------=\n"
		extractMetadataFiles;
		processMetadata;
		echo;
		extractScriptDate;
		
		cleanExtractFolder;
		printf "=________=\n"

		shift; # pop first file
	done;
}
main "$@"

if [ -t 0 ]; then
	# interactive shell
	read -p "Press Enter to continue/quit"
fi