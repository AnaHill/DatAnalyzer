# Kuinka avata sopivat file explorerit
# https://stackoverflow.com/questions/31504041/opening-multiple-file-explorer-windows-in-different-locations-on-the-desktop-usi

# Aliisa
# @echo off
setlocal
start explorer "C:\Local\maki9\Data\MATLAB\data_analyysi\Analyysit\AcuteHypoxia_Aliisa"; start explorer "C:\Local\maki9\Programs\OneDrive - TUNI.fi\Akuuttihypoksia\11311EURCCS_medhyp\28042022_EURCCS_MedHyp\MEA1B";
start explorer "C:\Local\maki9\Data\DataAnalyysi\Acute_Aliisa";  


rem // pause for 3 seconds to allow the windows to appear
timeout /t 3 >NUL

# powershell "(new-object -COM 'Shell.Application').TileVertically()" # järjestää kaikki avonaiset, myös jo aiemmin avatut