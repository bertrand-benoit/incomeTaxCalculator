#!/bin/bash
#
# Author: Bertrand BENOIT <bertrandbenoit.bsquare@gmail.com>
# Version: 1.2
# Description: French incomes taxes computer.
#
# usage: see usage function

#####################################################
#                Configuration
#####################################################

# General information.
TAXES_REDUCE_FACTOR=0.90
MONTHS=( none January February Marsh April May June July August September October November December )
DEFAULT_YEAR=$( date "+%Y" )

# 2013 taxes information.
# Cf. http://droit-finances.commentcamarche.net/faq/20217-bareme-2013-de-l-impot-sur-le-revenu-2012#q=bar%E8me+2013+impot+revenu&cur=2&url=%2F
TAXES_STEPS_2013=( 0 5963 11896 26420 70830 150000 999999 )
TAXES_STEPS_PERCENT_2013=( 0 0 5.5 14 30 41 45 )

# 2012 taxes information.
# Cf. http://droit-finances.commentcamarche.net/faq/3912-bareme-2012-de-l-impot-sur-le-revenu-2011
# Cf. http://www.francetransactions.com/actualites/info-epargne-0008591.html
# Cf. http://www.calcul-impot-revenu-2012.fr/bareme-tranches-impot-revenu-2012.html
TAXES_STEPS_2012=( 0 5963 11896 26420 70830 999999 )
TAXES_STEPS_PERCENT_2012=( 0 0 5.5 14 30 41 )

# 2011 taxes information.
# Cf. http://droit-finances.commentcamarche.net/faq/5808-loi-de-finances-2011-les-nouvelles-tranches-d-imposition
TAXES_STEPS_2011=( 0 5963 11896 26420 70830 999999 )
TAXES_STEPS_PERCENT_2011=( 0 0 5.5 14 30 41 )

# 2010 taxes information.
TAXES_STEPS_2010=( 0 5875 11720 26030 69783 999999 )
TAXES_STEPS_PERCENT_2010=( 0 0 5.5 14 30 40 )

# 2009 taxes information.
TAXES_STEPS_2009=( 0 5852 11673 25926 69505 999999 )
TAXES_STEPS_PERCENT_2009=( 0 0 5.5 14 30 40 )

# 2008 taxes information.
TAXES_STEPS_2008=( 0 5688 11345 25196 67547 999999 )
TAXES_STEPS_PERCENT_2008=( 0 0 5.5 14 30 40 )

#####################################################
#                Defines usages.
#####################################################
function usage {
  echo -e "usage: $0 -i|--incomes <incomes 1> [-c|--charges <charges 1>] [-d <charges 1.2>] [-u|--union <month>] [-k <incomes 1.2>] [-j <incomes 2>] [-l <incomes 2.2>] [-p|--part <part count>] [-y|--year <year of taxes>] [-h|--help]"
  echo -e "-h|--help\tshow this help"
  echo -e "<incomes 1>\tincomes to manage for the whole year of the first part in case of union's year"
  echo -e "<incomes 2>\tincomes of other people to manage for the whole year of the first part in case of union's year"
  echo -e "<incomes 1.2>\tincomes to manage for the second part in case of union's year"
  echo -e "<incomes 2.2>\tincomes of other people to manage for the second part in case of union's year"
  echo -e "<charges>\tpotential charges to manage for the whole year of the first part in case of union's year"
  echo -e "<charges 1.2>\tpotential charges to manage for the the second part in case of union's year"
  echo -e "<part count>\tcount of part (exclusive with -u|--union option)"
  echo -e "<month>\t\tthe month from which the union is concluded (can be something 1-12, to compute for each month) (exclusive with -p|--part option)"
  echo -e "<year>\t\tyear of taxes (default: $DEFAULT_YEAR)"
  echo -e "\nExamples:"
  echo -e "Computes incomes taxes for 1 person, with 10000€ incomes, 1000€ charges:"
  echo -e "  $0 -i 10000 -c 1000"
  echo -e "\nComputes incomes taxes for 2 persons, with total 20000€ incomes, and total 1000€ charges:"
  echo -e "  $0 -i 20000 -c 1000 -p 2"
  echo -e "\nJust Married or PACS -> computes APPROXIMATIVES incomes taxes for 2 persons united the 5th month, with 10000€ as first incomes, and 15000€ as seconds, total 1000€ charges:"
  echo -e "  $0 -i 10000 -j 15000 -c 1000 -u 5"
  echo -e "\nYou want to have an idea of the best month to be united ?"
  echo -e "  $0 -i 10000 -j 15000 -c 1000 -u 1-12"
  echo -e "\nJust Married or PACS -> computes precise incomes taxes for 2 persons united the xx/yy/zz, with precise incomes (first person: 3000€ earned from 01/01/zz to xx/yy/zz, and 7000€ earned from xx+1/12/zz; second person: 1000€ then 400€ for same periods), and precise charges (first person: 100€ then 400€; second person: no charge)"
  echo -e "  $0 -i 3000 -k 7000 -j 1000 -l 400 -c 100 -d 400"
  exit 1
}

#####################################################
#                Command line management.
#####################################################

# N.B.: variables names:
#  - incomes and incomes12 for first person
#  - incomes2 and incomes22 for second person
#  - charges and charges12 for first person

lastComptedTaxes=0
charges=0
partCount=1
incomes2=0
year=$DEFAULT_YEAR
while [ "$1" != "" ]; do
  if [ "$1" == "-i" ] || [ "$1" = "--incomes" ]; then
    shift
    incomes="$1"
  elif [ "$1" == "-j" ]; then
    shift
    incomes2="$1"
  elif [ "$1" == "-k" ]; then
    shift
    incomes12="$1"
  elif [ "$1" == "-l" ]; then
    shift
    incomes22="$1"
  elif [ "$1" == "-d" ]; then
    shift
    charges12="$1"
  elif [ "$1" == "-c" ] || [ "$1" = "--charges" ]; then
    shift
    charges="$1"
  elif [ "$1" == "-u" ] || [ "$1" = "--union" ]; then
    shift
    unionMonths="$1"
  elif [ "$1" == "-p" ] || [ "$1" = "--part" ]; then
    shift
    partCount="$1"
  elif [ "$1" == "-y" ] || [ "$1" = "--year" ]; then
    shift
    year="$1"
  elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
  else
    echo "Unknown parameter '$1'"
    usage
  fi

  shift
done

# TODO improve control -u/-p exclusive, ensure specified value are numbers ...
[ -z "$incomes" ] && echo -e "You must specify incomes" >&2 && usage

# Ensures information exists for year.
taxesSteps="TAXES_STEPS_$year"
taxesStepsPercent="TAXES_STEPS_PERCENT_$year"

[ -z "$( eval echo \${$taxesSteps[4]} )" ] && echo -e "Year $year is not supported" >&2 && usage

#####################################################
#                Functions
#####################################################

# usage: computeIncomesTaxes <incomes> <charges> <part count>
function computeIncomesTaxes() {
  local _incomes="$1"
  local _charges="$2"
  local _partCount="$3"

  remaningIncomes="$_incomes"
  echo -ne "Incomes: $remaningIncomes ... "

  # Reduces.
  remaningIncomes=$( echo "scale=2;$remaningIncomes*$TAXES_REDUCE_FACTOR" |bc )
  echo -ne "reduced to: $remaningIncomes ... "

  # Removes charges if any.
  if [ $( echo "$_charges>0" |bc ) -eq 1 ]; then
    remaningIncomes=$( echo "scale=2;$remaningIncomes-$_charges" |bc )
    echo -ne "less the charges: $remaningIncomes ... "
  fi

  # Memorizes the reference incomes to compute %.
  incomesRef="$remaningIncomes"

  # Takes care of part count.
  if [ $_partCount -gt 1 ]; then
    remaningIncomes=$( echo "scale=2;$remaningIncomes/$_partCount" |bc )
    echo -ne "divided by part count: $remaningIncomes ... "
  fi

  # For each step.
  taxes=0
  lastComptedTaxes=0
  echo -ne "taxes=0"
  lastStep=$( eval echo \${$taxesSteps[1]} )

  # Checks if incoms are greater than the "last" step, otherwise there is no taxe.
  if [ $( echo "$remaningIncomes>=$lastStep" |bc ) -eq 0 ]; then
    echo ""
  else
    for step in 2 3 4 5; do
      taxeStep=$( eval echo \${$taxesSteps[$step]} )
      taxePercent=$( eval echo \${$taxesStepsPercent[$step]} )

      if [ $( echo "$remaningIncomes>=$taxeStep" |bc ) -eq 1 ]; then
	incomesPart=$( echo "scale=2;$taxeStep-$lastStep" | bc )
	#remaningIncomes=$( echo "$remaningIncomes-$taxeStep" |bc )
      else
	incomesPart=$( echo "scale=2;$remaningIncomes-$lastStep" | bc )
	remaningIncomes=0
      fi
      lastStep=$taxeStep


      taxesPart=$( echo "scale=2;$incomesPart*$taxePercent/100" |bc )
      echo -ne "+$taxesPart"
      taxes=$( echo "scale=2;$taxes+$taxesPart" |bc )

      [ $( echo "$remaningIncomes==0" |bc ) -eq 1 ] && break
    done

    # Takes care of part count (must * by part count).
    if [ $_partCount -gt 1 ]; then
      echo -ne "=$taxes*$_partCount"
      taxes=$( echo "scale=2;$taxes*$_partCount" |bc )
    fi

    # Computes the taxes %.
    taxesPercent=$( echo "scale=2;100*$taxes/$incomesRef" |bc )

    lastComptedTaxes=$taxes

    # In cases, show the final taxes value.
    echo "=$taxes -> ratio=$taxesPercent%"
  fi
}

# usage: computeIncomesTaxes <incomes> <incomes 2> <charges> <month>
function computeIncomesTaxesWithUnionAtMonth() {
  local _incomes="$1"
  local _incomes2="$2"
  local _charges="$3"
  local _month="$4"

  taxesSum=0

  # Computes the taxes before the union.
  echo "Computing incomes taxes for month:" ${MONTHS[$_month]}
  echo -ne "Person 1  (before union): "
  incomesBefore1=$( echo "scale=2;$_incomes*$_month/12" |bc )
  chargesBefore=$( echo "scale=2;$_charges*$_month/12" |bc )
  computeIncomesTaxes "$incomesBefore1" "$chargesBefore" 1
  taxesSum=$( echo "scale=2;$taxesSum+$lastComptedTaxes" |bc )

  # Computes the taxes before the union.
  echo -ne "Person 2  (before union): "
  incomesBefore2=$( echo "scale=2;$_incomes2*$_month/12" |bc )
  computeIncomesTaxes "$incomesBefore2" 0 1
  taxesSum=$( echo "scale=2;$taxesSum+$lastComptedTaxes" |bc )

  # Computes the taxes after the union.
  echo -ne "Person 1&2 (after union): "
  incomesAfter=$( echo "scale=2;($_incomes+$_incomes2)*(12-$_month)/12" |bc )
  chargesAfter=$( echo "scale=2;$_charges*(12-$_month)/12" |bc )
  computeIncomesTaxes "$incomesAfter" "$chargesAfter" 2
  taxesSum=$( echo "scale=2;$taxesSum+$lastComptedTaxes" |bc )

  echo -e "The year incomes taxes sum=$taxesSum"

  lastComptedTaxes=$taxesSum
}

# usage: computeIncomesTaxesWithUnion <incomes>  <incomes 2> <charges> <month(s)>
function computeIncomesTaxesWithUnion() {
  local _incomes="$1"
  local _incomes2="$2"
  local _charges="$3"
  local _months="$4"

  echo "It's usually wrong but regards incomes as equally earned each month and charges equally lost each month ..."

  # Checks if it is a single value.
  if [ $( echo "$_months" |grep "\-" |wc -l ) -eq 0 ]; then
    computeIncomesTaxesWithUnionAtMonth "$_incomes" "$_incomes2" "$_charges" "$_months"
  else
    monthBegin=$( echo "$_months" |sed -e 's/-.*$//g;' )
    monthEnd=$( echo "$_months" |sed -e 's/^.*-//g;' )

    savedBestMonth=0
    savedBestTaxes=999999
    currentMonth=$monthBegin
    while [ $currentMonth -le $monthEnd ]; do
      computeIncomesTaxesWithUnionAtMonth "$_incomes" "$_incomes2" "$_charges" "$currentMonth"

      # Checks if this taxes is better.
      if [ $( echo "$lastComptedTaxes<$savedBestTaxes" |bc ) -eq 1 ]; then
        savedBestTaxes=$lastComptedTaxes
        savedBestMonth=$currentMonth
      fi

      currentMonth=$( expr $currentMonth + 1 )
    done

    echo "The lower year incomes taxes is $savedBestTaxes€, at month" ${MONTHS[$savedBestMonth]}
  fi
}

# usage: computePreciseIncomesTaxesWithUnion <incomes1.1> <incomes1.2> <incomes 2.1> <incomes 2.2> <charges 1.1> <charges 1.2>
function computePreciseIncomesTaxesWithUnion() {
  local _incomes11="$1" _incomes12="$2" _incomes21="$3" _incomes22="$4"
  local _charges11="$5" _charges12="$6"

  taxesSum=0

  ## Computes the taxes before the union.
  # First person.
  echo -ne "Person 1  (before union): "
  computeIncomesTaxes "$_incomes11" "$_charges11" 1
  taxesSum=$( echo "scale=2;$taxesSum+$lastComptedTaxes" |bc )

  # Second person.
  echo -ne "Person 2  (before union): "
  computeIncomesTaxes "$_incomes21" "0" 1
  taxesSum=$( echo "scale=2;$taxesSum+$lastComptedTaxes" |bc )

  ## Computes the taxes after the union.
  echo -ne "Person 1&2 (after union): "
  incomesAfter=$( echo "scale=2;$_incomes12+$_incomes22" |bc )
  chargesAfter="$_charges12"
  computeIncomesTaxes "$incomesAfter" "$chargesAfter" 2
  taxesSum=$( echo "scale=2;$taxesSum+$lastComptedTaxes" |bc )

  echo -e "The year incomes taxes sum=$taxesSum"
}

#####################################################
#                Instructions
#####################################################

# Checks if second part of incomes of first person has been specified; otherwise union month(s) have been specified.
if [ ! -z "$incomes12" ]; then
  computePreciseIncomesTaxesWithUnion "$incomes" "$incomes12" "$incomes2" "$incomes22" "$charges" "$charges12"
elif [ -z "$unionMonths" ]; then
  computeIncomesTaxes "$incomes" "$charges" "$partCount"
else
  computeIncomesTaxesWithUnion "$incomes" "$incomes2" "$charges" "$unionMonths"
fi
