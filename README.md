:warning: This project is now hosted on [Gitlab](https://gitlab.com/bertrand-benoit/incomeTaxCalculator); switch to it to get newer versions.

# French income tax calculator version 1.4
This is a free tool allowing to compute French incomes tax.

This script uses my [scripts-common](https://gitlab.com/bertrand-benoit/scripts-common) project.

## Usage
```
usage: ./incomeTaxCalculator.sh -i|--incomes <incomes 1> [-c|--charges <charges 1>] [-d <charges 1.2>] [-u|--union <month>] [-k <incomes 1.2>] [-j <incomes 2>] [-l <incomes 2.2>] [-p|--part <part count>] [-r <bic incomes>] [-s <service incomes>] [-t <sell incomes>] [-z] [-y|--year <year of taxes>] [-h|--help]
-h|--help	show this help
<incomes 1>	incomes to manage for the whole year of the first part in case of union's year
<incomes 2>	incomes of other people to manage for the whole year of the first part in case of union's year
<incomes 1.2>	incomes to manage for the second part in case of union's year
<incomes 2.2>	incomes of other people to manage for the second part in case of union's year
<charges>	potential charges to manage for the whole year of the first part in case of union's year
<charges 1.2>	potential charges to manage for the the second part in case of union's year
<part count>	count of part (exclusive with -u|--union option)
<month>		the month from which the union is concluded (can be something 1-12, to compute for each month) (exclusive with -p|--part option)
<bic incomes>	incomes of EURL/SARL in RSI (BIC IR)
<service incomes>	incomes of 'société individuelle' for 'prestation de services'
<sell incomes>	incomes of 'société individuelle' for 'ventes accessoires'
-z		indicates CGA for BIC IR
<year>		year of taxes (default: 2019)
```

## Samples

### Sample 1 - One person
Computes incomes taxes for 1 person, with 10 000€ incomes, 1000€ charges:
```bash
  ./incomeTaxCalculator.sh -i 10000 -c 1000
```

### Sample 2 - Two persons
Computes incomes taxes for 2 persons, with total 20 000€ incomes, and total 1000€ charges:
```bash
  ./incomeTaxCalculator.sh -i 20000 -c 1000 -p 2
```

### Sample 3 - best month to be unit
You want to have an idea of the best month to be united?
```bash
  ./incomeTaxCalculator.sh -i 10000 -j 15000 -c 1000 -u 1-12
```

### Sample 4 - Just Married or PACSed (approximatives computation)
-   computes APPROXIMATIVES incomes taxes for 2 persons united the 5th month
-   with 10 000€ as first incomes,
-   and 15 000€ as second incomes
-   and a total charges of 1000€
```bash
  ./incomeTaxCalculator.sh -i 10000 -j 15000 -c 1000 -u 5
```

### Sample 5 - Just Married or PACSed (precise computation)
Just Married or PACSed:
-   computes precise incomes taxes for 2 persons united the xx/yy/zz, with precise incomes
-   first person: 3000€ earned from 01/01/zz to xx/yy/zz, and 7000€ earned from xx+1/12/zz
-   second person: 1000€ then 400€ for same periods
-   and precise charges, first person: 100€ then 400€ and second person: no charge
```bash
  ./incomeTaxCalculator.sh -i 3000 -k 7000 -j 1000 -l 400 -c 100 -d 400
```

## Contributing
Don't hesitate to [contribute](https://opensource.guide/how-to-contribute/) or to contact me if you want to improve the project.
You can [report issues or request features](https://gitlab.com/bertrand-benoit/incomeTaxCalculator/issues) and propose [merge requests](https://gitlab.com/bertrand-benoit/incomeTaxCalculator/merge_requests).

## Versioning
The versioning scheme we use is [SemVer](http://semver.org/).

## Authors
[Bertrand BENOIT](mailto:contact@bertrand-benoit.net)

## License
This project is under the GPLv3 License - see the [LICENSE](LICENSE) file for details
