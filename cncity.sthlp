{smcl}
{* *! version 0.3.0 11Jul2026}{...}
{vieweralsosee "[R] regexm" "help regexm"}{...}
{vieweralsosee "[R] replace" "help replace"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "cncity##syntax"}{...}
{viewerjumpto "Standardization" "cncity##standardization"}{...}
{viewerjumpto "Example" "cncity##example"}{...}
{viewerjumpto "Variable" "cncity##variable"}{...}
{title:Title}

{p2colset 5 15 22 2}{...}
{p2col :{hi:cncity} {hline 2}}A Stata command for Chinese city name standardization{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}
{p 8 14 4}{cmd:cncity} {it:city_string} {ifin} [{cmd:,} {opt replace} {opt d:etail}]

{pstd}
{it:city_string} is a string variable with standardized or non-standardized city names.
{p_end}

{marker options}{...}
{title:Options}

{phang}
{opt replace} allows {cmd:cncity} to overwrite the generated variables
({bf:city_stname}, {bf:city_type}, {bf:city_prov}, {bf:city_code},
{bf:city_special}, {bf:special_ctlist})
if they already exist. Without this option, {cmd:cncity} exits with an error
when any of them exists.
{p_end}

{phang}
{opt d:etail} keeps {bf:city_special} and {bf:special_ctlist} in the dataset.
By default these two variables are used internally and dropped before exit.
{p_end}

{pstd}
After matching, {cmd:cncity} reports the number of observations matched to a city,
matched only to a prefecture/league (city_special), and unmatched.
{p_end}

{marker standarization}{...}
{title:Standarization}

{pstd}
See: {browse "https://mp.weixin.qq.com/s/Ox6z8b4P-mruAy7l_iGZWQ":4个直辖市、293个地级市、397个县级市名单}
{p_end}

{marker example}{...}
{title:Example}

{phang2}{cmd:. cncity city}{p_end}

{marker variable}{...}
{title:Variable}

{pstd}
{bf:city_stname}: Standardized city names, which must end in "市".
{p_end}
{pstd}
{bf:city_type}: City type, e.g. prefecture-level city, county-level city, municipality, etc.
{p_end}
{pstd}
{bf:city_prov}: The province of the city, or itself if it is a municipality.
{p_end}
{pstd}
{bf:city_code}: 6-digit administrative division code (GB/T 2260). Prefecture-level
cities end in "00"; county-level cities carry their full 6-digit code.
Empty for Taiwan cities and unmatched observations.
{p_end}
{pstd}
{bf:city_special} (only with {opt detail}): Some special demand, such as matching with regions, autonomous regions, and leagues.
{p_end}
{pstd}
{bf:special_ctlist} (only with {opt detail}): The city list for city_special.
{p_end}

{marker author}{...}
{title:Author}

{pstd}公众号：凯恩斯学计量{p_end}

{phang}{p_end}
